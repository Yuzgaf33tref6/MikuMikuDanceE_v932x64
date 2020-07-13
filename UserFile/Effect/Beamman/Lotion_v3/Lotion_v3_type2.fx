////////////////////////////////////////////////////////////////////////////////////////////////
//
//  ���[�V�������G�t�F�N�g
//	�������ЂƁF���x���A
//
//  �������F�\�t�g���C�gHL�V�F�[�_
//  furia�l
//
////////////////////////////////////////////////////////////////////////////////////////////////

//�g�pUV�I���F
//0:����UV�g�p
//1:�ǉ�UV1�Ԏg�p
#define USE_UV 0

//�c�݌W��
float DistParam = 10;

//���˗͂̋���
int LotionPower = 128;
//���F�̋����iLotionPower��艺�����Y��ɏo��j
int LotionDiffusePower = 10;
//UV�l�X�P�[��
float LotionUVScale = 1;

//UV�X�N���[���X�s�[�h
float2 UVSpd = float2(0,-0.003);

float3 LotionSpecularColor = float3(1,1,1);
float4 LotionColor = float4(1,1,1,0.5); 

//---�\�t�g�V���h�E�ݒ�---//

//�\�t�g�V���h�E���邳�␳
float LightParam = 1;
//�\�t�g�V���h�E�p�ڂ�����
float SoftShadowParam = 1;
//�V���h�E�}�b�v�T�C�Y
//�ʏ�F1024 CTRL+G�ŉ𑜓x���グ���ꍇ 4096
#define SHADOWMAP_SIZE 1024

//��������G��Ȃ�

//�\�t�g���C�g�����֐�
float3 SoftLight(float3 fg , float3 bg){
	float3 under  = bg+(bg-pow(bg,2.0))*(2.0f*fg-1.0f);
	float3 middle = bg+(bg-pow(bg,2.0f))*(2.0f*fg-1.0f)*(3.0f-8.0f*bg);
	float3 upper  = bg+(pow(bg,0.5f)-bg)*(2.0f*fg-1.0f);

	const float bgLimit = 32.0f / 255.0f;
	
	float3 Dst = (float3)0;
	
	Dst.r = fg.r < 0.5f ? under.r : bg.r <= bgLimit ? middle.r : upper.r;
	Dst.g = fg.g < 0.5f ? under.g : bg.g <= bgLimit ? middle.g : upper.g;
	Dst.b = fg.b < 0.5f ? under.b : bg.b <= bgLimit ? middle.b : upper.b;

	return Dst;
}



// �����_�����O�^�[�Q�b�g�̃N���A�l
float4 ClearColor = {0,0,0,0};
float ClearDepth  = 1.0;

//�G��ۑ�����e�N�X�`��
texture MyColTex : RenderColorTarget
<
    float2 ViewPortRatio = {1.0,1.0};
    string Format = "A8R8G8B8" ;
>;
sampler MyColSampler = sampler_state {
    texture = <MyColTex>;
    Filter = LINEAR;
};
texture2D DepthBuffer : RENDERDEPTHSTENCILTARGET <
    float2 ViewPortRatio = {1.0,1.0};
    string Format = "D24S8";
>;


float time : TIME;

//���[�V�����p�@��
texture2D LotionNormalTex <
    string ResourceName = "Lotion_Tex_N_0.png";
    //string ResourceName = "Lotion_Tex_N_1.png";
    //string ResourceName = "Lotion_Tex_N_2.png";
    //string ResourceName = "Lotion_Tex_N_3.png";
>;
sampler LotionNormalSampler = sampler_state {
    texture = <LotionNormalTex>;
    Filter = LINEAR;
    AddressU  = WRAP;
    AddressV = WRAP;
};


// �p�����[�^�錾

// ���@�ϊ��s��
float4x4 WorldViewProjMatrix      : WORLDVIEWPROJECTION;
float4x4 WorldMatrix              : WORLD;
float4x4 ViewMatrix               : VIEW;
float4x4 LightWorldViewProjMatrix : WORLDVIEWPROJECTION < string Object = "Light"; >;

float3   LightDirection    : DIRECTION < string Object = "Light"; >;
float3   CameraPosition    : POSITION  < string Object = "Camera"; >;

// �}�e���A���F
float4   MaterialDiffuse   : DIFFUSE  < string Object = "Geometry"; >;
float3   MaterialAmbient   : AMBIENT  < string Object = "Geometry"; >;
float3   MaterialEmmisive  : EMISSIVE < string Object = "Geometry"; >;
float3   MaterialSpecular  : SPECULAR < string Object = "Geometry"; >;
float    SpecularPower     : SPECULARPOWER < string Object = "Geometry"; >;
float3   MaterialToon      : TOONCOLOR;
float4   EdgeColor         : EDGECOLOR;
// ���C�g�F
float3   LightDiffuse      : DIFFUSE   < string Object = "Light"; >;
float3   LightAmbient      : AMBIENT   < string Object = "Light"; >;
float3   LightSpecular     : SPECULAR  < string Object = "Light"; >;
static float4 DiffuseColor  = MaterialDiffuse  * float4(LightDiffuse, 1.0f);
static float3 AmbientColor  = saturate(MaterialAmbient  * LightAmbient + MaterialEmmisive);
static float3 SpecularColor = MaterialSpecular * LightSpecular;

bool     parthf;   // �p�[�X�y�N�e�B�u�t���O
bool     transp;   // �������t���O
bool	 spadd;    // �X�t�B�A�}�b�v���Z�����t���O
#define SKII1    1500
#define SKII2    8000
#define Toon     3

// �I�u�W�F�N�g�̃e�N�X�`��
texture ObjectTexture: MATERIALTEXTURE;
sampler ObjTexSampler = sampler_state {
    texture = <ObjectTexture>;
    MINFILTER = LINEAR;
    MAGFILTER = LINEAR;
};

// �X�t�B�A�}�b�v�̃e�N�X�`��
texture ObjectSphereMap: MATERIALSPHEREMAP;
sampler ObjSphareSampler = sampler_state {
    texture = <ObjectSphereMap>;
    MINFILTER = LINEAR;
    MAGFILTER = LINEAR;
};

// MMD�{����sampler���㏑�����Ȃ����߂̋L�q�ł��B�폜�s�B
sampler MMDSamp0 : register(s0);
sampler MMDSamp1 : register(s1);
sampler MMDSamp2 : register(s2);

////////////////////////////////////////////////////////////////////////////////////////////////
// �֊s�`��

// ���_�V�F�[�_
float4 ColorRender_VS(float4 Pos : POSITION) : POSITION 
{
    // �J�������_�̃��[���h�r���[�ˉe�ϊ�
    return mul( Pos, WorldViewProjMatrix );
}

// �s�N�Z���V�F�[�_
float4 ColorRender_PS() : COLOR
{
    // �֊s�F�œh��Ԃ�
    return EdgeColor;
}

// �֊s�`��p�e�N�j�b�N
technique EdgeTec < string MMDPass = "edge"; > {
    pass DrawEdge {
        AlphaBlendEnable = FALSE;
        AlphaTestEnable  = FALSE;

        VertexShader = compile vs_3_0 ColorRender_VS();
        PixelShader  = compile ps_3_0 ColorRender_PS();
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////
// �e�i��Z���t�V���h�E�j�`��

// ���_�V�F�[�_
float4 Shadow_VS(float4 Pos : POSITION) : POSITION
{
    // �J�������_�̃��[���h�r���[�ˉe�ϊ�
    return mul( Pos, WorldViewProjMatrix );
}

// �s�N�Z���V�F�[�_
float4 Shadow_PS() : COLOR
{
    // �A���r�G���g�F�œh��Ԃ�
    return float4(AmbientColor.rgb, 0.65f);
}

// �e�`��p�e�N�j�b�N
technique ShadowTec < string MMDPass = "shadow"; > {
    pass DrawShadow {
        VertexShader = compile vs_3_0 Shadow_VS();
        PixelShader  = compile ps_3_0 Shadow_PS();
    }
}
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


///////////////////////////////////////////////////////////////////////////////////////////////
// �I�u�W�F�N�g�`��i�Z���t�V���h�EOFF�j

struct VS_OUTPUT {
    float4 Pos      : POSITION;     // �ˉe�ϊ����W
    float2 Tex      : TEXCOORD0;    // �e�N�X�`��
    float2 AddTex   : TEXCOORD1;    // �ǉ��e�N�X�`��
    float3 Normal   : TEXCOORD2;    // �@��
    float3 Eye      : TEXCOORD3;    // �J�����Ƃ̑��Έʒu
    float2 SpTex    : TEXCOORD4;	 // �X�t�B�A�}�b�v�e�N�X�`�����W
    float4 WPos     : TEXCOORD5;     // ���[���h���W�l
    float4 LastPos	: TEXCOORD6;
    float4 Color    : COLOR0;       // �f�B�t���[�Y�F
};

// ���_�V�F�[�_
VS_OUTPUT Basic_VS(float4 Pos : POSITION, float3 Normal : NORMAL, float2 Tex : TEXCOORD0,float4 AddTex : TEXCOORD1, uniform bool useTexture, uniform bool useSphereMap, uniform bool useToon)
{
    VS_OUTPUT Out = (VS_OUTPUT)0;
	Out.WPos = mul(Pos,WorldMatrix);
    // �J�������_�̃��[���h�r���[�ˉe�ϊ�
    Out.Pos = mul( Pos, WorldViewProjMatrix );
    
    // �J�����Ƃ̑��Έʒu
    Out.Eye = CameraPosition - mul( Pos, WorldMatrix );
    // ���_�@��
    Out.Normal = normalize( mul( Normal, (float3x3)WorldMatrix ) );
    
    // �f�B�t���[�Y�F�{�A���r�G���g�F �v�Z
    Out.Color.rgb = AmbientColor;
    if ( !useToon ) {
        Out.Color.rgb += max(0,dot( Out.Normal, -LightDirection )) * DiffuseColor.rgb;
    }
    Out.Color.a = DiffuseColor.a;
    Out.Color = saturate( Out.Color );
    
    // �e�N�X�`�����W
    Out.Tex = Tex;
    Out.AddTex = AddTex.xy;
    Out.LastPos = Out.Pos;
    if ( useSphereMap ) {
        // �X�t�B�A�}�b�v�e�N�X�`�����W
        float2 NormalWV = mul( Out.Normal, (float3x3)ViewMatrix );
        Out.SpTex.x = NormalWV.x * 0.5f + 0.5f;
        Out.SpTex.y = NormalWV.y * -0.5f + 0.5f;
    }
    
    return Out;
}

// �s�N�Z���V�F�[�_
float4 Basic_PS(VS_OUTPUT IN, uniform bool useTexture, uniform bool useSphereMap, uniform bool useToon) : COLOR0
{
    // �X�y�L�����F�v�Z
    float3 HalfVector = normalize( normalize(IN.Eye) + -LightDirection );
    float3 Specular = pow( max(0,dot( HalfVector, normalize(IN.Normal) )), SpecularPower ) * SpecularColor;
    
    float4 Color = IN.Color;
    
    float4 ShadowColor = float4(AmbientColor, Color.a);  // �e�̐F
    
    if ( useTexture ) {
        // �e�N�X�`���K�p
        float4 TexColor = tex2D( ObjTexSampler, IN.Tex );
        Color *= TexColor;
        ShadowColor *= TexColor;
    }
    if ( useSphereMap ) {
        // �X�t�B�A�}�b�v�K�p
        float4 TexColor = tex2D(ObjSphareSampler,IN.SpTex);
        if(spadd) {
            Color += TexColor;
            ShadowColor += TexColor;
        } else {
            Color *= TexColor;
            ShadowColor *= TexColor;
        }
    }
    // �X�y�L�����K�p
    Color.rgb += Specular;
    
    float4 ans;
    float comp = 1;
    if(useToon){
        comp = min(saturate(dot(IN.Normal,-LightDirection)*Toon),comp);
		ans = ShadowColor * (comp+float4(MaterialToon,1)*(1-comp)) +  float4(Specular,0) * comp;
		
		float diffContrib = dot( normalize(IN.Normal) , -LightDirection) * 0.5 +0.5;
		
	    float RimPower = max( 0.0f, dot( -normalize(IN.Eye), -LightDirection ) );
	    float Rim = 1.0f - max( 0.0f, dot( normalize(IN.Normal),normalize(IN.Eye)) );
	    diffContrib += Rim*RimPower;
	    
	    diffContrib = pow(diffContrib,1.0f/0.75);
	    
		float3 mColor = diffContrib * ans;
		float3 sColor = SoftLight( diffContrib * 0.75f, ans);

		//�ʓx�擾
		float Imax,Imin;
		Imax = max(ans.r , max(ans.g , ans.b ));
		Imin = min(ans.r , min(ans.g , ans.b ));
		
		//HSV �ʓx
		float s = (Imax-Imin) / Imax;

		s = s/2.0f;
		s = pow(s,1.0f/0.5f);

        ans.rgb = lerp(sColor,mColor,s);
        
    }else{
        ans = (0 + MaterialDiffuse * pow(dot(normalize(IN.Normal), -LightDirection ) *0.5+0.5,1/0.5));
        ans = (ans*Color + float4(Specular,0))*comp + 0*Color*(1-comp);
    }
    return ans;
}
///////////////////////////////////////////////////////////////////////////////////////////////
// �Z���t�V���h�E�pZ�l�v���b�g

struct VS_ZValuePlot_OUTPUT {
    float4 Pos : POSITION;              // �ˉe�ϊ����W
    float4 ShadowMapTex : TEXCOORD0;    // Z�o�b�t�@�e�N�X�`��
};

// ���_�V�F�[�_
VS_ZValuePlot_OUTPUT ZValuePlot_VS( float4 Pos : POSITION )
{
    VS_ZValuePlot_OUTPUT Out = (VS_ZValuePlot_OUTPUT)0;

    // ���C�g�̖ڐ��ɂ�郏�[���h�r���[�ˉe�ϊ�������
    Out.Pos = mul( Pos, LightWorldViewProjMatrix );

    // �e�N�X�`�����W�𒸓_�ɍ��킹��
    Out.ShadowMapTex = Out.Pos;

    return Out;
}

// �s�N�Z���V�F�[�_
float4 ZValuePlot_PS( float4 ShadowMapTex : TEXCOORD0 ) : COLOR
{
    // R�F������Z�l���L�^����
    return float4(ShadowMapTex.z/ShadowMapTex.w,0,0,1);
}

// Z�l�v���b�g�p�e�N�j�b�N
technique ZplotTec < string MMDPass = "zplot"; > {
    pass ZValuePlot {
        AlphaBlendEnable = FALSE;
        VertexShader = compile vs_3_0 ZValuePlot_VS();
        PixelShader  = compile ps_3_0 ZValuePlot_PS();
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////
// �I�u�W�F�N�g�`��i�Z���t�V���h�EON�j

// �V���h�E�o�b�t�@�̃T���v���B"register(s0)"�Ȃ̂�MMD��s0���g���Ă��邩��
sampler DefSampler : register(s0);

struct BufferShadow_OUTPUT {
    float4 Pos      : POSITION;     // �ˉe�ϊ����W
    float4 ZCalcTex : TEXCOORD0;    // Z�l
    float2 Tex      : TEXCOORD1;    // �e�N�X�`��
    float2 AddTex   : TEXCOORD2;    // �ǉ��e�N�X�`��
    float3 Normal   : TEXCOORD3;    // �@��
    float3 Eye      : TEXCOORD4;    // �J�����Ƃ̑��Έʒu
    float2 SpTex    : TEXCOORD5;	 // �X�t�B�A�}�b�v�e�N�X�`�����W
    float4 WPos     : TEXCOORD6;     // ���[���h���W�l
    float4 LastPos	: TEXCOORD7;
    float4 Color    : COLOR0;       // �f�B�t���[�Y�F
};

// ���_�V�F�[�_
BufferShadow_OUTPUT BufferShadow_VS(float4 Pos : POSITION, float3 Normal : NORMAL, float2 Tex : TEXCOORD0,float4 AddTex : TEXCOORD1, uniform bool useTexture, uniform bool useSphereMap, uniform bool useToon)
{
    BufferShadow_OUTPUT Out = (BufferShadow_OUTPUT)0;
	Out.WPos = mul(Pos,WorldMatrix);
    // �J�������_�̃��[���h�r���[�ˉe�ϊ�
    Out.Pos = mul( Pos, WorldViewProjMatrix );
    
    // �J�����Ƃ̑��Έʒu
    Out.Eye = CameraPosition - mul( Pos, WorldMatrix );
    // ���_�@��
    Out.Normal = normalize( mul( Normal, (float3x3)WorldMatrix ) );
	// ���C�g���_�ɂ�郏�[���h�r���[�ˉe�ϊ�
    Out.ZCalcTex = mul( Pos, LightWorldViewProjMatrix );
    
    // �f�B�t���[�Y�F�{�A���r�G���g�F �v�Z
    Out.Color.rgb = AmbientColor;
    if ( !useToon ) {
        Out.Color.rgb += max(0,dot( Out.Normal, -LightDirection )) * DiffuseColor.rgb;
    }
    Out.Color.a = DiffuseColor.a;
    Out.Color = saturate( Out.Color );
    
    // �e�N�X�`�����W
    Out.Tex = Tex;
    Out.AddTex = AddTex.xy;
    Out.LastPos = Out.Pos;
    if ( useSphereMap ) {
        // �X�t�B�A�}�b�v�e�N�X�`�����W
        float2 NormalWV = mul( Out.Normal, (float3x3)ViewMatrix );
        Out.SpTex.x = NormalWV.x * 0.5f + 0.5f;
        Out.SpTex.y = NormalWV.y * -0.5f + 0.5f;
    }
    
    return Out;
}
// �s�N�Z���V�F�[�_
float4 BufferShadow_PS(BufferShadow_OUTPUT IN, uniform bool useTexture, uniform bool useSphereMap, uniform bool useToon) : COLOR
{
    // �X�y�L�����F�v�Z
    float3 HalfVector = normalize( normalize(IN.Eye) + -LightDirection );
    float3 Specular = pow( max(0,dot( HalfVector, normalize(IN.Normal) )), SpecularPower ) * SpecularColor;
    
    float4 Color = IN.Color;
    
    float4 ShadowColor = float4(AmbientColor, Color.a);  // �e�̐F
    
    if ( useTexture ) {
        // �e�N�X�`���K�p
        float4 TexColor = tex2D( ObjTexSampler, IN.Tex );
        Color *= TexColor;
        ShadowColor *= TexColor;
    }
    if ( useSphereMap ) {
        // �X�t�B�A�}�b�v�K�p
        float4 TexColor = tex2D(ObjSphareSampler,IN.SpTex);
        if(spadd) {
            Color += TexColor;
            ShadowColor += TexColor;
        } else {
            Color *= TexColor;
            ShadowColor *= TexColor;
        }
    }
    // �X�y�L�����K�p
    Color.rgb += Specular;
    
    
    // �e�N�X�`�����W�ɕϊ�
    IN.ZCalcTex /= IN.ZCalcTex.w;
    float2 TransTexCoord;
    TransTexCoord.x = (1.0f + IN.ZCalcTex.x)*0.5f;
    TransTexCoord.y = (1.0f - IN.ZCalcTex.y)*0.5f;
    
    if( any( saturate(TransTexCoord) != TransTexCoord ) ) {
       		 // �V���h�E�o�b�t�@�O
       		 float4 ans;
       		 float comp = 1;
	       if(useToon){
	       		comp = min(saturate(dot(IN.Normal,-LightDirection)*Toon),comp);
				ans = ShadowColor * (comp+float4(MaterialToon,1)*(1-comp)) +  float4(Specular,0) * comp;
				
				float diffContrib = dot( normalize(IN.Normal) , -LightDirection) * 0.5 +0.5;
				
			    float RimPower = max( 0.0f, dot( -normalize(IN.Eye), -LightDirection ) );
			    float Rim = 1.0f - max( 0.0f, dot( normalize(IN.Normal),normalize(IN.Eye)) );
			    diffContrib += Rim*RimPower;
			    
			    diffContrib = pow(diffContrib,1.0f/0.75);
			    
				float3 mColor = diffContrib * ans;
				float3 sColor = SoftLight( diffContrib * 0.75f, ans);

				//�ʓx�擾
				float Imax,Imin;
				Imax = max(ans.r , max(ans.g , ans.b ));
				Imin = min(ans.r , min(ans.g , ans.b ));
				
				//HSV �ʓx
				float s = (Imax-Imin) / Imax;

				s = s/2.0f;
				s = pow(s,1.0f/0.5f);

	        	ans.rgb = lerp(sColor,mColor,s);
	        	
	        }else{
	       		ans = (0 + MaterialDiffuse * pow(dot(normalize(IN.Normal), -LightDirection ) *0.5+0.5,1/0.5));
	       		ans = (ans*Color + float4(Specular,0))*comp + 0*Color*(1-comp);
	        }
	       	return ans;
    } else {
        float comp = 0;
		float U = SoftShadowParam / SHADOWMAP_SIZE;
		float V = SoftShadowParam / SHADOWMAP_SIZE;
        if(parthf) {
            // �Z���t�V���h�E mode2
	        comp += saturate(max(IN.ZCalcTex.z-tex2D(DefSampler,TransTexCoord+float2(0,0)).r , 0.0f)*SKII2*TransTexCoord.y-0.3f);
	        comp += saturate(max(IN.ZCalcTex.z-tex2D(DefSampler,TransTexCoord+float2(U,0)).r , 0.0f)*SKII2*TransTexCoord.y-0.3f);
	        comp += saturate(max(IN.ZCalcTex.z-tex2D(DefSampler,TransTexCoord+float2(-U,0)).r , 0.0f)*SKII2*TransTexCoord.y-0.3f);
	        comp += saturate(max(IN.ZCalcTex.z-tex2D(DefSampler,TransTexCoord+float2(0,V)).r , 0.0f)*SKII2*TransTexCoord.y-0.3f);
	        comp += saturate(max(IN.ZCalcTex.z-tex2D(DefSampler,TransTexCoord+float2(0,-V)).r , 0.0f)*SKII2*TransTexCoord.y-0.3f);
	        comp += saturate(max(IN.ZCalcTex.z-tex2D(DefSampler,TransTexCoord+float2(U,V)).r , 0.0f)*SKII2*TransTexCoord.y-0.3f);
	        comp += saturate(max(IN.ZCalcTex.z-tex2D(DefSampler,TransTexCoord+float2(-U,V)).r , 0.0f)*SKII2*TransTexCoord.y-0.3f);
	        comp += saturate(max(IN.ZCalcTex.z-tex2D(DefSampler,TransTexCoord+float2(-U,-V)).r , 0.0f)*SKII2*TransTexCoord.y-0.3f);
	        comp += saturate(max(IN.ZCalcTex.z-tex2D(DefSampler,TransTexCoord+float2(U,-V)).r , 0.0f)*SKII2*TransTexCoord.y-0.3f);
        } else {
            // �Z���t�V���h�E mode1
	        comp += saturate(max(IN.ZCalcTex.z-tex2D(DefSampler,TransTexCoord+float2(0,0)).r , 0.0f)*SKII1-0.3f);
	        comp += saturate(max(IN.ZCalcTex.z-tex2D(DefSampler,TransTexCoord+float2(U,0)).r , 0.0f)*SKII1-0.3f);
	        comp += saturate(max(IN.ZCalcTex.z-tex2D(DefSampler,TransTexCoord+float2(-U,0)).r , 0.0f)*SKII1-0.3f);
	        comp += saturate(max(IN.ZCalcTex.z-tex2D(DefSampler,TransTexCoord+float2(0,V)).r , 0.0f)*SKII1-0.3f);
	        comp += saturate(max(IN.ZCalcTex.z-tex2D(DefSampler,TransTexCoord+float2(0,-V)).r , 0.0f)*SKII1-0.3f);
	        comp += saturate(max(IN.ZCalcTex.z-tex2D(DefSampler,TransTexCoord+float2(U,V)).r , 0.0f)*SKII1-0.3f);
	        comp += saturate(max(IN.ZCalcTex.z-tex2D(DefSampler,TransTexCoord+float2(-U,V)).r , 0.0f)*SKII1-0.3f);
	        comp += saturate(max(IN.ZCalcTex.z-tex2D(DefSampler,TransTexCoord+float2(-U,-V)).r , 0.0f)*SKII1-0.3f);
	        comp += saturate(max(IN.ZCalcTex.z-tex2D(DefSampler,TransTexCoord+float2(U,-V)).r , 0.0f)*SKII1-0.3f);
        }
        comp = 1-saturate(comp/9);
        float4 ans;
        if(useToon){
			ans = ShadowColor * (comp+float4(MaterialToon,1)*(1-comp)) +  float4(Specular,0) * comp;
			
			float diffContrib = dot( normalize(IN.Normal) , -LightDirection) * 0.5 +0.5;
			
		    float RimPower = max( 0.0f, dot( -normalize(IN.Eye), -LightDirection ) );
		    float Rim = 1.0f - max( 0.0f, dot( normalize(IN.Normal),normalize(IN.Eye)) );
		    diffContrib += Rim*RimPower;
		    
		    diffContrib = pow(diffContrib,1.0f/0.75);
		    
			float3 mColor = diffContrib * ans;
			float3 sColor = SoftLight( diffContrib * 0.75f, ans);

			//�ʓx�擾
			float Imax,Imin;
			Imax = max(ans.r , max(ans.g , ans.b ));
			Imin = min(ans.r , min(ans.g , ans.b ));
			
			//HSV �ʓx
			float s = (Imax-Imin) / Imax;

			s = s/2.0f;
			s = pow(s,1.0f/0.5f);

        	ans.rgb = lerp(sColor,mColor,s);
        	
        }else{
       		ans = (0 + MaterialDiffuse * pow(dot(normalize(IN.Normal), -LightDirection ) *0.5+0.5,1/0.5));
       		ans = (ans*Color + float4(Specular,0))*comp + 0*Color*(1-comp);
        }
        
        if( transp ) ans.a = 0.5f;
        return ans;
    }
}
// �s�N�Z���V�F�[�_
float4 Lotion_PS(BufferShadow_OUTPUT IN, uniform bool useTexture, uniform bool useSphereMap, uniform bool useToon) : COLOR
{
	#if(USE_UV == 0)
		float2 lot_tex = IN.Tex;
	#else
		float2 lot_tex = IN.AddTex+(IN.Tex-0.5)*0.01;
	#endif
	lot_tex += UVSpd * time;
	float3 normal;
	float4 NormalColor = tex2D( LotionNormalSampler, lot_tex * LotionUVScale);
	float4 DiffColor = tex2D( LotionNormalSampler, lot_tex * LotionUVScale);
	DiffColor = (DiffColor.r + DiffColor.g + DiffColor.b)/3;
	
	NormalColor = NormalColor.rgba;
	NormalColor.a = 1; 
	float3 Eye = normalize(CameraPosition.xyz - IN.WPos.xyz); 
	float3x3 tangentFrame = compute_tangent_frame(IN.Normal, Eye, lot_tex);
	normal = normalize(mul(2.0f * NormalColor - 1.0f, tangentFrame));
	
    // �X�y�L�����F�v�Z
    float3 HalfVector = normalize( normalize(IN.Eye) + -LightDirection );
    float3 Specular = pow( max(0,dot( HalfVector, normalize(IN.Normal) )), SpecularPower ) * SpecularColor;
    
    //���[�V�����̃X�y�L������ǉ�
    float LotionPow = pow( max(0,dot( HalfVector, normalize(normal) )), LotionPower );
    float LotionDiffPow = pow( max(0,dot( HalfVector, normalize(normal) )), LotionDiffusePower );
    float3 LotionSpecular = LotionPow * LotionSpecularColor;
    Specular += LotionSpecular * LightSpecular;
    
    float4 Color = float4(Specular,1);
    
	float2 ScrTex;
    ScrTex.x = (IN.LastPos.x / IN.LastPos.w)*0.5+0.5;
	ScrTex.y = (-IN.LastPos.y / IN.LastPos.w)*0.5+0.5;
    
    float4 Base = tex2D(MyColSampler,ScrTex);
    
    ScrTex += pow(normalize(mul(normal,WorldViewProjMatrix).xy),10)*DistParam*(0.05/length(IN.Eye));

	Color = tex2D(MyColSampler,ScrTex);
	Color = lerp(Base,Color,pow(Color.a,10));
	//Color = Base;
	
    //���[�V�����̒��F
    Color.rgb = lerp(Color.rgb,LotionColor.rgb,LotionDiffPow*LotionColor.a);
    // �X�y�L�����K�p
    Color.rgb += Specular;
    return Color;
}
//SS����
// �I�u�W�F�N�g�`��p�e�N�j�b�N�i�A�N�Z�T���p�j
technique MainTec0  < string MMDPass = "object"; bool UseTexture = false; bool UseSphereMap = false; bool UseToon = false;
    string Script = 
        "RenderColorTarget0=MyColTex;"
	    "RenderDepthStencilTarget=DepthBuffer;"
		"ClearSetColor=ClearColor;"
		"ClearSetDepth=ClearDepth;"
		"Clear=Color;"
		"Clear=Depth;"
        "Pass=DrawCol;"

	    //�ŏI����
        "RenderColorTarget0=;"
	    "RenderDepthStencilTarget=;"
	    "Pass=DrawObject;"
    ;
> {
    pass DrawCol {
        VertexShader = compile vs_3_0 Basic_VS(false, false, false);
        PixelShader  = compile ps_3_0 Basic_PS(false, false, false);
    }
    pass DrawObject {
        VertexShader = compile vs_3_0 BufferShadow_VS(false, false, false);
        PixelShader  = compile ps_3_0 Lotion_PS(false, false, false);
    }
}
technique MainTec1  < string MMDPass = "object"; bool UseTexture = true; bool UseSphereMap = false; bool UseToon = false;
    string Script = 
        "RenderColorTarget0=MyColTex;"
	    "RenderDepthStencilTarget=DepthBuffer;"
		"ClearSetColor=ClearColor;"
		"ClearSetDepth=ClearDepth;"
		"Clear=Color;"
		"Clear=Depth;"
        "Pass=DrawCol;"

	    //�ŏI����
        "RenderColorTarget0=;"
	    "RenderDepthStencilTarget=;"
	    "Pass=DrawObject;"
    ;
> {
    pass DrawCol {
        VertexShader = compile vs_3_0 Basic_VS(true, false, false);
        PixelShader  = compile ps_3_0 Basic_PS(true, false, false);
    }
    pass DrawObject {
        VertexShader = compile vs_3_0 BufferShadow_VS(true, false, false);
        PixelShader  = compile ps_3_0 Lotion_PS(true, false, false);
    }
}

technique MainTec2  < string MMDPass = "object"; bool UseTexture = false; bool UseSphereMap = true; bool UseToon = false;
    string Script = 
        "RenderColorTarget0=MyColTex;"
	    "RenderDepthStencilTarget=DepthBuffer;"
		"ClearSetColor=ClearColor;"
		"ClearSetDepth=ClearDepth;"
		"Clear=Color;"
		"Clear=Depth;"
        "Pass=DrawCol;"

	    //�ŏI����
        "RenderColorTarget0=;"
	    "RenderDepthStencilTarget=;"
	    "Pass=DrawObject;"
    ;
> {
    pass DrawCol {
        VertexShader = compile vs_3_0 Basic_VS(false, true, false);
        PixelShader  = compile ps_3_0 Basic_PS(false, true, false);
    }
    pass DrawObject {
        VertexShader = compile vs_3_0 BufferShadow_VS(false, true, false);
        PixelShader  = compile ps_3_0 Lotion_PS(false, true, false);
    }
}

technique MainTec3  < string MMDPass = "object"; bool UseTexture = true; bool UseSphereMap = true; bool UseToon = false;
    string Script = 
        "RenderColorTarget0=MyColTex;"
	    "RenderDepthStencilTarget=DepthBuffer;"
		"ClearSetColor=ClearColor;"
		"ClearSetDepth=ClearDepth;"
		"Clear=Color;"
		"Clear=Depth;"
        "Pass=DrawCol;"

	    //�ŏI����
        "RenderColorTarget0=;"
	    "RenderDepthStencilTarget=;"
	    "Pass=DrawObject;"
    ;
> {
    pass DrawCol {
        VertexShader = compile vs_3_0 Basic_VS(true, true, false);
        PixelShader  = compile ps_3_0 Basic_PS(true, true, false);
    }
    pass DrawObject {
        VertexShader = compile vs_3_0 BufferShadow_VS(true, true, false);
        PixelShader  = compile ps_3_0 Lotion_PS(true, true, false);
    }
}

// �I�u�W�F�N�g�`��p�e�N�j�b�N�iPMD���f���p�j
technique MainTec4  < string MMDPass = "object"; bool UseTexture = false; bool UseSphereMap = false; bool UseToon = true;
    string Script = 
        "RenderColorTarget0=MyColTex;"
	    "RenderDepthStencilTarget=DepthBuffer;"
		"ClearSetColor=ClearColor;"
		"ClearSetDepth=ClearDepth;"
		"Clear=Color;"
		"Clear=Depth;"
        "Pass=DrawCol;"

	    //�ŏI����
        "RenderColorTarget0=;"
	    "RenderDepthStencilTarget=;"
	    "Pass=DrawObject;"
    ;
> {
    pass DrawCol {
        VertexShader = compile vs_3_0 Basic_VS(false, false, true);
        PixelShader  = compile ps_3_0 Basic_PS(false, false, true);
    }
    pass DrawObject {
        VertexShader = compile vs_3_0 BufferShadow_VS(false, false, true);
        PixelShader  = compile ps_3_0 Lotion_PS(false, false, true);
    }
}

technique MainTec5  < string MMDPass = "object"; bool UseTexture = true; bool UseSphereMap = false; bool UseToon = true; 
    string Script = 
        "RenderColorTarget0=MyColTex;"
	    "RenderDepthStencilTarget=DepthBuffer;"
		"ClearSetColor=ClearColor;"
		"ClearSetDepth=ClearDepth;"
		"Clear=Color;"
		"Clear=Depth;"
        "Pass=DrawCol;"

	    //�ŏI����
        "RenderColorTarget0=;"
	    "RenderDepthStencilTarget=;"
	    "Pass=DrawObject;"
    ;
> {
    pass DrawCol {
        VertexShader = compile vs_3_0 Basic_VS(true, false, true);
        PixelShader  = compile ps_3_0 Basic_PS(true, false, true);
    }
    pass DrawObject {
        VertexShader = compile vs_3_0 BufferShadow_VS(true, false, true);
        PixelShader  = compile ps_3_0 Lotion_PS(true, false, true);
    }
}

technique MainTec6  < string MMDPass = "object"; bool UseTexture = false; bool UseSphereMap = true; bool UseToon = true;
    string Script = 
        "RenderColorTarget0=MyColTex;"
	    "RenderDepthStencilTarget=DepthBuffer;"
		"ClearSetColor=ClearColor;"
		"ClearSetDepth=ClearDepth;"
		"Clear=Color;"
		"Clear=Depth;"
        "Pass=DrawCol;"

	    //�ŏI����
        "RenderColorTarget0=;"
	    "RenderDepthStencilTarget=;"
	    "Pass=DrawObject;"
    ;
> {
    pass DrawCol {
        VertexShader = compile vs_3_0 Basic_VS(false, true, true);
        PixelShader  = compile ps_3_0 Basic_PS(false, true, true);
    }
    pass DrawObject {
        VertexShader = compile vs_3_0 BufferShadow_VS(false, true, true);
        PixelShader  = compile ps_3_0 Lotion_PS(false, true, true);
    }
}

technique MainTec7  < string MMDPass = "object"; bool UseTexture = true; bool UseSphereMap = true; bool UseToon = true;
    string Script = 
        "RenderColorTarget0=MyColTex;"
	    "RenderDepthStencilTarget=DepthBuffer;"
		"ClearSetColor=ClearColor;"
		"ClearSetDepth=ClearDepth;"
		"Clear=Color;"
		"Clear=Depth;"
        "Pass=DrawCol;"

	    //�ŏI����
        "RenderColorTarget0=;"
	    "RenderDepthStencilTarget=;"
	    "Pass=DrawObject;"
    ;
> {
    pass DrawCol {
        VertexShader = compile vs_3_0 Basic_VS(true, true, true);
        PixelShader  = compile ps_3_0 Basic_PS(true, true, true);
    }
    pass DrawObject {
        VertexShader = compile vs_3_0 BufferShadow_VS(true, true, true);
        PixelShader  = compile ps_3_0 Lotion_PS(true, true, true);
    }
}

//SS�L��
// �I�u�W�F�N�g�`��p�e�N�j�b�N�i�A�N�Z�T���p�j
technique MainTecBS0  < string MMDPass = "object_ss"; bool UseTexture = false; bool UseSphereMap = false; bool UseToon = false;
    string Script = 
        "RenderColorTarget0=MyColTex;"
	    "RenderDepthStencilTarget=DepthBuffer;"
		"ClearSetColor=ClearColor;"
		"ClearSetDepth=ClearDepth;"
		"Clear=Color;"
		"Clear=Depth;"
        "Pass=DrawCol;"

	    //�ŏI����
        "RenderColorTarget0=;"
	    "RenderDepthStencilTarget=;"
	    "Pass=DrawObject;"
    ;
> {
    pass DrawCol {
        VertexShader = compile vs_3_0 BufferShadow_VS(false, false, false);
        PixelShader  = compile ps_3_0 BufferShadow_PS(false, false, false);
    }
    pass DrawObject {
        VertexShader = compile vs_3_0 BufferShadow_VS(false, false, false);
        PixelShader  = compile ps_3_0 Lotion_PS(false, false, false);
    }
}
technique MainTecBS1  < string MMDPass = "object_ss"; bool UseTexture = true; bool UseSphereMap = false; bool UseToon = false;
    string Script = 
        "RenderColorTarget0=MyColTex;"
	    "RenderDepthStencilTarget=DepthBuffer;"
		"ClearSetColor=ClearColor;"
		"ClearSetDepth=ClearDepth;"
		"Clear=Color;"
		"Clear=Depth;"
        "Pass=DrawCol;"

	    //�ŏI����
        "RenderColorTarget0=;"
	    "RenderDepthStencilTarget=;"
	    "Pass=DrawObject;"
    ;
> {
    pass DrawCol {
        VertexShader = compile vs_3_0 BufferShadow_VS(true, false, false);
        PixelShader  = compile ps_3_0 BufferShadow_PS(true, false, false);
    }
    pass DrawObject {
        VertexShader = compile vs_3_0 BufferShadow_VS(true, false, false);
        PixelShader  = compile ps_3_0 Lotion_PS(true, false, false);
    }
}

technique MainTecBS2  < string MMDPass = "object_ss"; bool UseTexture = false; bool UseSphereMap = true; bool UseToon = false;
    string Script = 
        "RenderColorTarget0=MyColTex;"
	    "RenderDepthStencilTarget=DepthBuffer;"
		"ClearSetColor=ClearColor;"
		"ClearSetDepth=ClearDepth;"
		"Clear=Color;"
		"Clear=Depth;"
        "Pass=DrawCol;"

	    //�ŏI����
        "RenderColorTarget0=;"
	    "RenderDepthStencilTarget=;"
	    "Pass=DrawObject;"
    ;
> {
    pass DrawCol {
        VertexShader = compile vs_3_0 BufferShadow_VS(false, true, false);
        PixelShader  = compile ps_3_0 BufferShadow_PS(false, true, false);
    }
    pass DrawObject {
        VertexShader = compile vs_3_0 BufferShadow_VS(false, true, false);
        PixelShader  = compile ps_3_0 Lotion_PS(false, true, false);
    }
}

technique MainTecBS3  < string MMDPass = "object_ss"; bool UseTexture = true; bool UseSphereMap = true; bool UseToon = false;
    string Script = 
        "RenderColorTarget0=MyColTex;"
	    "RenderDepthStencilTarget=DepthBuffer;"
		"ClearSetColor=ClearColor;"
		"ClearSetDepth=ClearDepth;"
		"Clear=Color;"
		"Clear=Depth;"
        "Pass=DrawCol;"

	    //�ŏI����
        "RenderColorTarget0=;"
	    "RenderDepthStencilTarget=;"
	    "Pass=DrawObject;"
    ;
> {
    pass DrawCol {
        VertexShader = compile vs_3_0 BufferShadow_VS(true, true, false);
        PixelShader  = compile ps_3_0 BufferShadow_PS(true, true, false);
    }
    pass DrawObject {
        VertexShader = compile vs_3_0 BufferShadow_VS(true, true, false);
        PixelShader  = compile ps_3_0 Lotion_PS(true, true, false);
    }
}

// �I�u�W�F�N�g�`��p�e�N�j�b�N�iPMD���f���p�j
technique MainTecBS4  < string MMDPass = "object_ss"; bool UseTexture = false; bool UseSphereMap = false; bool UseToon = true;
    string Script = 
        "RenderColorTarget0=MyColTex;"
	    "RenderDepthStencilTarget=DepthBuffer;"
		"ClearSetColor=ClearColor;"
		"ClearSetDepth=ClearDepth;"
		"Clear=Color;"
		"Clear=Depth;"
        "Pass=DrawCol;"

	    //�ŏI����
        "RenderColorTarget0=;"
	    "RenderDepthStencilTarget=;"
	    "Pass=DrawObject;"
    ;
> {
    pass DrawCol {
        VertexShader = compile vs_3_0 BufferShadow_VS(false, false, true);
        PixelShader  = compile ps_3_0 BufferShadow_PS(false, false, true);
    }
    pass DrawObject {
        VertexShader = compile vs_3_0 BufferShadow_VS(false, false, true);
        PixelShader  = compile ps_3_0 Lotion_PS(false, false, true);
    }
}

technique MainTecBS5  < string MMDPass = "object_ss"; bool UseTexture = true; bool UseSphereMap = false; bool UseToon = true; 
    string Script = 
        "RenderColorTarget0=MyColTex;"
	    "RenderDepthStencilTarget=DepthBuffer;"
		"ClearSetColor=ClearColor;"
		"ClearSetDepth=ClearDepth;"
		"Clear=Color;"
		"Clear=Depth;"
        "Pass=DrawCol;"

	    //�ŏI����
        "RenderColorTarget0=;"
	    "RenderDepthStencilTarget=;"
	    "Pass=DrawObject;"
    ;
> {
    pass DrawCol {
        VertexShader = compile vs_3_0 BufferShadow_VS(true, false, true);
        PixelShader  = compile ps_3_0 BufferShadow_PS(true, false, true);
    }
    pass DrawObject {
        VertexShader = compile vs_3_0 BufferShadow_VS(true, false, true);
        PixelShader  = compile ps_3_0 Lotion_PS(true, false, true);
    }
}

technique MainTecBS6  < string MMDPass = "object_ss"; bool UseTexture = false; bool UseSphereMap = true; bool UseToon = true;
    string Script = 
        "RenderColorTarget0=MyColTex;"
	    "RenderDepthStencilTarget=DepthBuffer;"
		"ClearSetColor=ClearColor;"
		"ClearSetDepth=ClearDepth;"
		"Clear=Color;"
		"Clear=Depth;"
        "Pass=DrawCol;"

	    //�ŏI����
        "RenderColorTarget0=;"
	    "RenderDepthStencilTarget=;"
	    "Pass=DrawObject;"
    ;
> {
    pass DrawCol {
        VertexShader = compile vs_3_0 BufferShadow_VS(false, true, true);
        PixelShader  = compile ps_3_0 BufferShadow_PS(false, true, true);
    }
    pass DrawObject {
        VertexShader = compile vs_3_0 BufferShadow_VS(false, true, true);
        PixelShader  = compile ps_3_0 Lotion_PS(false, true, true);
    }
}

technique MainTecBS7  < string MMDPass = "object_ss"; bool UseTexture = true; bool UseSphereMap = true; bool UseToon = true;
    string Script = 
        "RenderColorTarget0=MyColTex;"
	    "RenderDepthStencilTarget=DepthBuffer;"
		"ClearSetColor=ClearColor;"
		"ClearSetDepth=ClearDepth;"
		"Clear=Color;"
		"Clear=Depth;"
        "Pass=DrawCol;"

	    //�ŏI����
        "RenderColorTarget0=;"
	    "RenderDepthStencilTarget=;"
	    "Pass=DrawObject;"
    ;
> {
    pass DrawCol {
        VertexShader = compile vs_3_0 BufferShadow_VS(true, true, true);
        PixelShader  = compile ps_3_0 BufferShadow_PS(true, true, true);
    }
    pass DrawObject {
        VertexShader = compile vs_3_0 BufferShadow_VS(true, true, true);
        PixelShader  = compile ps_3_0 Lotion_PS(true, true, true);
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////
