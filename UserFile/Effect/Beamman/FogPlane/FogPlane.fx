
float2 FogScroll = float2(0.1,0.1);

float FogSpd = float(0.5);
float TexScale = float(0.75);

float FogAddAlpha = 0.0;
float FogAlpha = 0;

float FogGausePow = 0.5;
float FogGauseSpd = 0.99;
float FogPushPow = 1;

//�\�t�g�V���h�E�p�ڂ�����
float SoftShadowParam = 1;
//�V���h�E�}�b�v�T�C�Y
//�ʏ�F1024 CTRL+G�ŉ𑜓x���グ���ꍇ 4096
#define SHADOWMAP_SIZE 1024




bool     parthf;   // �p�[�X�y�N�e�B�u�t���O
bool     transp;   // �������t���O
bool	 spadd;    // �X�t�B�A�}�b�v���Z�����t���O
#define SKII1    1500
#define SKII2    8000
#define Toon     3
// �V���h�E�o�b�t�@�̃T���v���B"register(s0)"�Ȃ̂�MMD��s0���g���Ă��邩��
sampler DefSampler : register(s0);

#define BLENDMODE_SRC SRCALPHA
#define BLENDMODE_DEST INVSRCALPHA


////////////////////////////////////////////////////////////////////////////////////////////////
// �p�����[�^�錾

// ���@�ϊ��s��
float4x4 WorldMatrix      : WORLD;
float4x4 WorldViewProjMatrix      : WORLDVIEWPROJECTION;
float4x4 LightWorldViewProjMatrix : WORLDVIEWPROJECTION < string Object = "Light"; >;
float3   LightDirection    : DIRECTION < string Object = "Light"; >;
float3   CameraPosition    : POSITION  < string Object = "Camera"; >;
float3   LightPosition    : POSITION  < string Object = "Light"; >;
// �}�e���A���F
float4   MaterialDiffuse   : DIFFUSE  < string Object = "Geometry"; >;
// ���C�g�F
float3   LightDiffuse      : DIFFUSE   < string Object = "Light"; >;
float3   LightAmbient      : AMBIENT   < string Object = "Light"; >;
float3   LightSpecular     : SPECULAR  < string Object = "Light"; >;

texture FogTex<
    string ResourceName = "height.png";
>;
sampler Fog = sampler_state {
    texture = <FogTex>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = NONE;
    AddressU  = WRAP;
    AddressV  = WRAP;
};
texture NormalTex<
    string ResourceName = "normal.png";
>;
sampler NormalSamp = sampler_state {
    texture = <NormalTex>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = NONE;
    AddressU  = WRAP;
    AddressV  = WRAP;
};

//�q�b�g�p
#define HITTEX_SIZE 1024

texture VTFFOG_HitRT: OFFSCREENRENDERTARGET <
    string Description = "OffScreen RenderTarget for VTF_Fog.fx";
    int Width = HITTEX_SIZE;
    int Height = HITTEX_SIZE;
    float4 ClearColor = { 0, 0, 0, 1 };
    float ClearDepth = 1.0;
    string Format = "D3DFMT_R32F" ;
    bool AntiAlias = false;
    string DefaultEffect = 
        "self = hide;"
        "*=HitObject.fx;";
>;
sampler HitMap = sampler_state {
    texture = <VTFFOG_HitRT>;
    AddressU  = CLAMP;
    AddressV = CLAMP;
    Filter = LINEAR;
};

//�q�b�g�p�ۑ��A�ڂ���
texture HitTexBuf : RenderColorTarget
<
   int Width=HITTEX_SIZE;
   int Height=HITTEX_SIZE;
   string Format="R32F";
>;
sampler HitMapBuf = sampler_state {
    texture = <HitTexBuf>;
    AddressU  = CLAMP;
    AddressV = CLAMP;
    Filter = LINEAR;
};
texture HitTexBuf2 : RenderColorTarget
<
   int Width=HITTEX_SIZE;
   int Height=HITTEX_SIZE;
   string Format="R32F";
>;
sampler HitMapBuf2 = sampler_state {
    texture = <HitTexBuf2>;
    AddressU  = CLAMP;
    AddressV = CLAMP;
    Filter = LINEAR;
};
texture HitTexWork : RenderColorTarget
<
   int Width=HITTEX_SIZE;
   int Height=HITTEX_SIZE;
   string Format="R32F";
>;
sampler HitMapWork = sampler_state {
    texture = <HitTexWork>;
    AddressU  = CLAMP;
    AddressV = CLAMP;
    Filter = LINEAR;
};

texture DepthBuffer : RenderDepthStencilTarget <
   int Width=HITTEX_SIZE;
   int Height=HITTEX_SIZE;
    string Format = "D24S8";
>;

//-----------------------------------------------------------------------------
// �[�x�}�b�v
//
//-----------------------------------------------------------------------------
texture VTFFOG_DepthMapRT: OFFSCREENRENDERTARGET <
    string Description = "OffScreen RenderTarget for DepthMap.fx";
    float4 ClearColor = { 0, 0, 0, 1 };
    float ClearDepth = 1.0;
    string Format = "D3DFMT_R32F" ;
    bool AntiAlias = true;
    string DefaultEffect = 
        "self = hide;"
        "* = DepthMap.fx";
>;

sampler DepthMap = sampler_state {
    texture = <VTFFOG_DepthMapRT>;
    AddressU  = CLAMP;
    AddressV = CLAMP;
    Filter = LINEAR;
};
float3x3 compute_tangent_frame(float3 Normal, float3 View, float2 UV)
{
  float3 dp1 = ddx(View);
  float3 dp2 = ddy(View);
  float2 duv1 = ddx(UV);
  float2 duv2 = ddy(UV);

  float3x3 M = float3x3(dp1, dp2, cross(dp1, dp2));
  float2x3 inverseM = float2x3(cross(M[1], M[2]), cross(M[2], M[0]));
  float3 Tangent = mul(float2(duv1.x, duv2.x), inverseM);
  float3 Binormal = mul(float2(duv1.y, duv2.y), inverseM);

  return float3x3(normalize(Tangent), normalize(Binormal), Normal);
}


float time : Time;

///////////////////////////////////////////////////////////////////////////////////////////////

struct VS_OUTPUT
{
    float4 Pos        : POSITION;    // �ˉe�ϊ����W
    float2 Tex        : TEXCOORD0;   // �e�N�X�`��
    float4 LastPos	  : TEXCOORD1;	 // �ŏI�ϊ����W
    float4 WPos	  	  : TEXCOORD2;	 // World���W
    float4 DefPos	  	  : TEXCOORD3;	 // Local���W
    float3 Normal     : TEXCOORD4;	 // �@��
};

// ���_�V�F�[�_
VS_OUTPUT Mask_VS(float4 Pos : POSITION, float2 Tex : TEXCOORD0,float3 Normal : NORMAL)
{
    VS_OUTPUT Out;
    Out.DefPos = Pos;
    Out.WPos = mul(Pos,WorldMatrix);
    // �J�������_�̃��[���h�r���[�ˉe�ϊ�
    Out.Pos = mul( Pos, WorldViewProjMatrix );
    Out.LastPos = Out.Pos;
    Out.Normal = normalize( mul( Normal, (float3x3)WorldMatrix ) );
    // �e�N�X�`�����W
    Out.Tex = Tex;
    
    return Out;
}

// �s�N�Z���V�F�[�_
float4 Mask_PS( VS_OUTPUT IN ,uniform bool bShadow) : COLOR0
{

	float2 VPUV = IN.Tex;
	float hit = pow(tex2D(HitMapBuf2,VPUV).r,1)*FogPushPow;
	//return float4(hit,0,0,1);
	IN.Tex *= TexScale;
	time *= FogSpd;
	float2 tex = IN.Tex+FogScroll*time;
	float3 normal;
	float3 Eye = normalize(CameraPosition.xyz - IN.WPos.xyz);
	float4 NormalColor = tex2D( NormalSamp, tex);
	float3x3 tangentFrame = compute_tangent_frame(IN.Normal, Eye, tex);
	normal = normalize(mul(2.0f * NormalColor - 1.0f, tangentFrame));
	normal = normalize(normal * (1-hit));
	LightDirection *= -1;
	float3 pos = (LightDirection * 1024)-IN.WPos.xyz; //** ���C�g�ւ̃x�N�g��
	float lc = dot(normalize(pos) , normalize(normal));// * IN.Color; //** �J���[

	//�X�N���[��UV
	float3 TgtPos = IN.LastPos.xyz/IN.LastPos.w;
	TgtPos.y *= -1;
	TgtPos.xy += 1;
	TgtPos.xy *= 0.5;
	
	float myZ = IN.LastPos.z/IN.LastPos.w;
	float tgtZ = tex2D(DepthMap,TgtPos.xy).r;
	
	float4 col = 1;//col1;// + col2 + col3;
	col.a = lerp(0,col.r,pow(tgtZ,FogAlpha));
	col.rgb = 0;
	col.a = saturate(col.a + FogAddAlpha);
	col.a *= (saturate(length(tgtZ - myZ)*1024));
	col.a *= 1-hit;
	col.rgb += lc;
	col.rgb = saturate(col.rgb);
	
	
	if(bShadow)
	{
		IN.DefPos.xyz += (normal)*0.02;
		float4 ZCalcTex = IN.DefPos;
		
		// ���C�g���_�ɂ�郏�[���h�r���[�ˉe�ϊ�
	    ZCalcTex = mul( ZCalcTex, LightWorldViewProjMatrix );
	
	    // �e�N�X�`�����W�ɕϊ�
	    ZCalcTex /= ZCalcTex.w;
	    float2 TransTexCoord;
	    TransTexCoord.x = (1.0f + ZCalcTex.x)*0.5f;
	    TransTexCoord.y = (1.0f - ZCalcTex.y)*0.5f;
	    
	    if( any( saturate(TransTexCoord) != TransTexCoord ) ) {
	        // �V���h�E�o�b�t�@�O
	        return col;
	    } else {
	    	float shadow = tex2D(DefSampler,TransTexCoord).r;
	        float comp = 0;
			float U = SoftShadowParam / SHADOWMAP_SIZE;
			float V = SoftShadowParam / SHADOWMAP_SIZE;
	        if(parthf) {
	            // �Z���t�V���h�E mode2
		        comp += saturate(max(ZCalcTex.z-tex2D(DefSampler,TransTexCoord+float2(0,0)).r , 0.0f)*SKII2*TransTexCoord.y-0.3f);
		        comp += saturate(max(ZCalcTex.z-tex2D(DefSampler,TransTexCoord+float2(U,0)).r , 0.0f)*SKII2*TransTexCoord.y-0.3f);
		        comp += saturate(max(ZCalcTex.z-tex2D(DefSampler,TransTexCoord+float2(-U,0)).r , 0.0f)*SKII2*TransTexCoord.y-0.3f);
		        comp += saturate(max(ZCalcTex.z-tex2D(DefSampler,TransTexCoord+float2(0,V)).r , 0.0f)*SKII2*TransTexCoord.y-0.3f);
		        comp += saturate(max(ZCalcTex.z-tex2D(DefSampler,TransTexCoord+float2(0,-V)).r , 0.0f)*SKII2*TransTexCoord.y-0.3f);
		        comp += saturate(max(ZCalcTex.z-tex2D(DefSampler,TransTexCoord+float2(U,V)).r , 0.0f)*SKII2*TransTexCoord.y-0.3f);
		        comp += saturate(max(ZCalcTex.z-tex2D(DefSampler,TransTexCoord+float2(-U,V)).r , 0.0f)*SKII2*TransTexCoord.y-0.3f);
		        comp += saturate(max(ZCalcTex.z-tex2D(DefSampler,TransTexCoord+float2(-U,-V)).r , 0.0f)*SKII2*TransTexCoord.y-0.3f);
		        comp += saturate(max(ZCalcTex.z-tex2D(DefSampler,TransTexCoord+float2(U,-V)).r , 0.0f)*SKII2*TransTexCoord.y-0.3f);
	        } else {
	            // �Z���t�V���h�E mode1
		        comp += saturate(max(ZCalcTex.z-tex2D(DefSampler,TransTexCoord+float2(0,0)).r , 0.0f)*SKII1-0.3f);
		        comp += saturate(max(ZCalcTex.z-tex2D(DefSampler,TransTexCoord+float2(U,0)).r , 0.0f)*SKII1-0.3f);
		        comp += saturate(max(ZCalcTex.z-tex2D(DefSampler,TransTexCoord+float2(-U,0)).r , 0.0f)*SKII1-0.3f);
		        comp += saturate(max(ZCalcTex.z-tex2D(DefSampler,TransTexCoord+float2(0,V)).r , 0.0f)*SKII1-0.3f);
		        comp += saturate(max(ZCalcTex.z-tex2D(DefSampler,TransTexCoord+float2(0,-V)).r , 0.0f)*SKII1-0.3f);
		        comp += saturate(max(ZCalcTex.z-tex2D(DefSampler,TransTexCoord+float2(U,V)).r , 0.0f)*SKII1-0.3f);
		        comp += saturate(max(ZCalcTex.z-tex2D(DefSampler,TransTexCoord+float2(-U,V)).r , 0.0f)*SKII1-0.3f);
		        comp += saturate(max(ZCalcTex.z-tex2D(DefSampler,TransTexCoord+float2(-U,-V)).r , 0.0f)*SKII1-0.3f);
		        comp += saturate(max(ZCalcTex.z-tex2D(DefSampler,TransTexCoord+float2(U,-V)).r , 0.0f)*SKII1-0.3f);
	        }
	        comp = 1-saturate(comp/9);
	        float4 ShadowColor;
			ShadowColor.rgb = col.xyz * 0.5; //**�e�̐F�͌��ݐF���Â��������̂��g�p������...
	        ShadowColor.a = col.a;
	        float4 ans = lerp(ShadowColor, col, comp);       
	        
	        return ans;
	    }
	}
	
	
    return col;
}
struct HV_OUT
{
    float4 Pos        : POSITION;    // �ˉe�ϊ����W
    float2 Tex        : TEXCOORD0;   // �e�N�X�`��
};


HV_OUT Hit_VS(float4 Pos : POSITION,float2 Tex : TEXCOORD0)
{
   HV_OUT Out;
   Out.Pos = Pos.xzyw;
   Out.Tex = Tex + float2(0.5/HITTEX_SIZE, 0.5/HITTEX_SIZE);
   return Out;
}
// �ڂ��������̏d�݌W���F
//    �K�E�X�֐� exp( -x^2/(2*d^2) ) �� d=5, x=0�`7 �ɂ��Čv�Z�����̂��A
//    (WT_7 + WT_6 + �c + WT_1 + WT_0 + WT_1 + �c + WT_7) �� 1 �ɂȂ�悤�ɐ��K����������
#define  WT_0  0.0920246
#define  WT_1  0.0902024
#define  WT_2  0.0849494
#define  WT_3  0.0768654
#define  WT_4  0.0668236
#define  WT_5  0.0558158
#define  WT_6  0.0447932
#define  WT_7  0.0345379


static float2 ViewportOffset = (float2(0.5,0.5)/HITTEX_SIZE);
static float2 SampStep = (float2(0.1,1)/HITTEX_SIZE);


float4 HitX_PS( HV_OUT IN) : COLOR0
{
	float4 Color;
	IN.Tex = IN.Tex+FogScroll*FogSpd*0.05;
	
	Color  = WT_0 *   tex2D( HitMapBuf, IN.Tex );
	Color += WT_1 * ( tex2D( HitMapBuf, IN.Tex+float2(SampStep.x  ,0) ) + tex2D( HitMapBuf, IN.Tex-float2(SampStep.x  ,0) ) );
	Color += WT_2 * ( tex2D( HitMapBuf, IN.Tex+float2(SampStep.x*2,0) ) + tex2D( HitMapBuf, IN.Tex-float2(SampStep.x*2,0) ) );
	Color += WT_3 * ( tex2D( HitMapBuf, IN.Tex+float2(SampStep.x*3,0) ) + tex2D( HitMapBuf, IN.Tex-float2(SampStep.x*3,0) ) );
	Color += WT_4 * ( tex2D( HitMapBuf, IN.Tex+float2(SampStep.x*4,0) ) + tex2D( HitMapBuf, IN.Tex-float2(SampStep.x*4,0) ) );
	Color += WT_5 * ( tex2D( HitMapBuf, IN.Tex+float2(SampStep.x*5,0) ) + tex2D( HitMapBuf, IN.Tex-float2(SampStep.x*5,0) ) );
	Color += WT_6 * ( tex2D( HitMapBuf, IN.Tex+float2(SampStep.x*6,0) ) + tex2D( HitMapBuf, IN.Tex-float2(SampStep.x*6,0) ) );
	Color += WT_7 * ( tex2D( HitMapBuf, IN.Tex+float2(SampStep.x*7,0) ) + tex2D( HitMapBuf, IN.Tex-float2(SampStep.x*7,0) ) );


	return Color * FogGauseSpd;
}
float4 HitY_PS( HV_OUT IN) : COLOR0
{
	float4 Color;
	IN.Tex = IN.Tex+FogScroll*FogSpd*0.05;
	
	Color  = WT_0 *   tex2D( HitMapWork, IN.Tex );
	Color += WT_1 * ( tex2D( HitMapWork, IN.Tex+float2(0,SampStep.y  ) ) + tex2D( HitMapWork, IN.Tex-float2(0,SampStep.y  ) ) );
	Color += WT_2 * ( tex2D( HitMapWork, IN.Tex+float2(0,SampStep.y*2) ) + tex2D( HitMapWork, IN.Tex-float2(0,SampStep.y*2) ) );
	Color += WT_3 * ( tex2D( HitMapWork, IN.Tex+float2(0,SampStep.y*3) ) + tex2D( HitMapWork, IN.Tex-float2(0,SampStep.y*3) ) );
	Color += WT_4 * ( tex2D( HitMapWork, IN.Tex+float2(0,SampStep.y*4) ) + tex2D( HitMapWork, IN.Tex-float2(0,SampStep.y*4) ) );
	Color += WT_5 * ( tex2D( HitMapWork, IN.Tex+float2(0,SampStep.y*5) ) + tex2D( HitMapWork, IN.Tex-float2(0,SampStep.y*5) ) );
	Color += WT_6 * ( tex2D( HitMapWork, IN.Tex+float2(0,SampStep.y*6) ) + tex2D( HitMapWork, IN.Tex-float2(0,SampStep.y*6) ) );
	Color += WT_7 * ( tex2D( HitMapWork, IN.Tex+float2(0,SampStep.y*7) ) + tex2D( HitMapWork, IN.Tex-float2(0,SampStep.y*7) ) );
	

	return Color * FogGauseSpd;
}
float4 Hit_CpyPS( HV_OUT IN) : COLOR0
{
	float col = 0;
	col = tex2D(HitMap,IN.Tex).r + tex2D(HitMapWork,IN.Tex).r;

	if(time == 0)
	{
		col = 0;	
	}
	return float4(col,0,0,1);
}

// �����_�����O�^�[�Q�b�g�̃N���A�l
float4 ClearColor = {0,0,0,1};
float ClearDepth  = 1.0;

technique MainTec < string MMDPass = "object";     

	string Script = 
		"ClearSetColor=ClearColor;"
		"ClearSetDepth=ClearDepth;"
		"RenderDepthStencilTarget=DepthBuffer;"
		"RenderColorTarget0=HitTexBuf;"
		"Clear=Color;"
		"Clear=Depth;"
        "Pass=HitCpy;"
		
		"RenderColorTarget0=HitTexWork;"
		"Clear=Color;"
		"Clear=Depth;"
		"Pass=HitDrawX;"

		"RenderColorTarget0=HitTexBuf2;"
		"Pass=HitDrawY;"
		
		"RenderDepthStencilTarget=;"
		"RenderColorTarget0=;"
	    "Pass=DrawObject;"
	    ;
	> {
    pass DrawObject {
		ZENABLE = TRUE;
		ZWRITEENABLE = FALSE;
		CULLMODE = NONE;
		ALPHABLENDENABLE = TRUE;
        VertexShader = compile vs_3_0 Mask_VS();
        PixelShader  = compile ps_3_0 Mask_PS(false);
    }
    pass HitDrawX {
	    ALPHABLENDENABLE = FALSE;
	    ALPHATESTENABLE=FALSE;
		ZENABLE = FALSE;
		ZWRITEENABLE = FALSE;
        VertexShader = compile vs_3_0 Hit_VS();
        PixelShader  = compile ps_3_0 HitX_PS();
    }
    pass HitDrawY {
	    ALPHABLENDENABLE = FALSE;
	    ALPHATESTENABLE=FALSE;
		ZENABLE = FALSE;
		ZWRITEENABLE = FALSE;
        VertexShader = compile vs_3_0 Hit_VS();
        PixelShader  = compile ps_3_0 HitY_PS();
    }
    pass HitCpy {
	    ALPHABLENDENABLE = FALSE;
	    ALPHATESTENABLE=FALSE;
		ZENABLE = FALSE;
		ZWRITEENABLE = FALSE;
        VertexShader = compile vs_3_0 Hit_VS();
        PixelShader  = compile ps_3_0 Hit_CpyPS();
    }
}

technique MainTec_SS < string MMDPass = "object_ss";     

	string Script = 
		"ClearSetColor=ClearColor;"
		"ClearSetDepth=ClearDepth;"
		"RenderDepthStencilTarget=DepthBuffer;"
		"RenderColorTarget0=HitTexBuf;"
		"Clear=Color;"
		"Clear=Depth;"
        "Pass=HitCpy;"
		
		"RenderColorTarget0=HitTexWork;"
		"Clear=Color;"
		"Clear=Depth;"
		"Pass=HitDrawX;"

		"RenderColorTarget0=HitTexBuf2;"
		"Pass=HitDrawY;"
		
		"RenderDepthStencilTarget=;"
		"RenderColorTarget0=;"
	    "Pass=DrawObject;"
	    ;
	> {
    pass DrawObject {
		ZENABLE = TRUE;
		ZWRITEENABLE = FALSE;
		CULLMODE = NONE;
		ALPHABLENDENABLE = TRUE;
        VertexShader = compile vs_3_0 Mask_VS();
        PixelShader  = compile ps_3_0 Mask_PS(true);
    }
    pass HitDrawX {
	    ALPHABLENDENABLE = FALSE;
	    ALPHATESTENABLE=FALSE;
		ZENABLE = FALSE;
		ZWRITEENABLE = FALSE;
        VertexShader = compile vs_3_0 Hit_VS();
        PixelShader  = compile ps_3_0 HitX_PS();
    }
    pass HitDrawY {
	    ALPHABLENDENABLE = FALSE;
	    ALPHATESTENABLE=FALSE;
		ZENABLE = FALSE;
		ZWRITEENABLE = FALSE;
        VertexShader = compile vs_3_0 Hit_VS();
        PixelShader  = compile ps_3_0 HitY_PS();
    }
    pass HitCpy {
	    ALPHABLENDENABLE = FALSE;
	    ALPHATESTENABLE=FALSE;
		ZENABLE = FALSE;
		ZWRITEENABLE = FALSE;
        VertexShader = compile vs_3_0 Hit_VS();
        PixelShader  = compile ps_3_0 Hit_CpyPS();
    }
}
// Z�l�v���b�g�p�e�N�j�b�N
technique ZplotTec < string MMDPass = "zplot"; > {

}


