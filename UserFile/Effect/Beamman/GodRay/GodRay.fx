//���ؕ\��
//�쐬�F�r�[���}��P
//
//�x�[�X�FRadialBlur Filter
//�K�E�X�ڂ����W���g�p
//Furia�l
////////////////////////////////////////////////////////////////////////////////////////////////


//�R���g���[���̒l�ǂݍ���
bool use_Cont : CONTROLOBJECT < string name = "GodRay.pmd";>;
float3 ContPos : CONTROLOBJECT < string name = "GodRay.pmd";string item = "�Z���^�[";>;
float morph_r : CONTROLOBJECT < string name = "GodRay.pmd"; string item = "��"; >;
float morph_g : CONTROLOBJECT < string name = "GodRay.pmd"; string item = "��"; >;
float morph_b : CONTROLOBJECT < string name = "GodRay.pmd"; string item = "��"; >;
float morph_len : CONTROLOBJECT < string name = "GodRay.pmd"; string item = "������"; >;
float morph_size : CONTROLOBJECT < string name = "GodRay.pmd"; string item = "���傫��"; >;
float morph_boke : CONTROLOBJECT < string name = "GodRay.pmd"; string item = "���ڂ�"; >;


//�}�X�N�p
shared texture ObjectMaskRT: OFFSCREENRENDERTARGET <
    string Description = "OffScreen RenderTarget for SunShaft.fx";
    float4 ClearColor = { 1, 1, 1, 1 };
    float ClearDepth = 1.0;
    bool AntiAlias = false;
    string DefaultEffect = 
        "self = hide;"
        "*=BlackObject.fx;";
>;

sampler MaskView = sampler_state {
    texture = <ObjectMaskRT>;
    Filter = NONE;
    AddressU  = CLAMP;
    AddressV = CLAMP;
};


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

float Script : STANDARDSGLOBAL <
    string ScriptOutput = "color";
    string ScriptClass = "scene";
    string ScriptOrder = "postprocess";
> = 0.8;

float  m_BlurPower;         //�ڂ����x(0.0f �Ń{�P�Ȃ�)

float4 MaterialDiffuse  : DIFFUSE  < string Object = "Geometry"; >;      
float3   LightAmbient      : AMBIENT   < string Object = "Light"; >;   

float4x4 WorldMatrix : World;
float4x4 mVP : ViewProjection;
static float3 Offset = WorldMatrix._41_42_43;

//�ڂ������x
static float BlurPower = 5.0;

// �X�N���[���T�C�Y
float2 ViewportSize : VIEWPORTPIXELSIZE;
static float2 SampStep = (float2(2,2)/ViewportSize);

// �����_�����O�^�[�Q�b�g�̃N���A�l
float4 ClearColor = {1,1,1,1};
float ClearDepth  = 1.0;


// �I���W�i���̕`�挋�ʂ��L�^���邽�߂̃����_�[�^�[�Q�b�g
texture2D ScnMap : RENDERCOLORTARGET <
    float2 ViewPortRatio = {1.0,1.0};
    int MipLevels = 1;
    string Format = "A8R8G8B8" ;
>;

sampler2D ScnSamp = sampler_state {
    texture = <ScnMap>;
    MinFilter = POINT;
    MagFilter = POINT;
    MipFilter = NONE;
    AddressU  = CLAMP;
    AddressV = CLAMP;
};
//�u���[�ۑ��p�����_�\�^�[�Q�b�g�P
texture2D BlurMap1 : RENDERCOLORTARGET <
    float2 ViewPortRatio = {1.0,1.0};
    int MipLevels = 1;
    string Format = "A8R8G8B8" ;
>;

sampler2D B1Samp = sampler_state {
    texture = <BlurMap1>;
    MinFilter = POINT;
    MagFilter = POINT;
    MipFilter = NONE;
    AddressU  = CLAMP;
    AddressV = CLAMP;
};
//�Q
texture2D BlurMap2 : RENDERCOLORTARGET <
    float2 ViewPortRatio = {1.0,1.0};
    int MipLevels = 1;
    string Format = "A8R8G8B8" ;
>;

sampler2D B2Samp = sampler_state {
    texture = <BlurMap2>;
    MinFilter = POINT;
    MagFilter = POINT;
    MipFilter = NONE;
    AddressU  = CLAMP;
    AddressV = CLAMP;
};
texture2D DepthBuffer : RENDERDEPTHSTENCILTARGET <
    float2 ViewPortRatio = {1.0,1.0};
    string Format = "D24S8";
>;
 
struct VS_OUTPUT {
    float4 Pos	: POSITION;
    float2 Tex	: TEXCOORD0;
    float2 Center	: TEXCOORD1;
    float Alpha : TEXCOORD2;
};
float3 LightDirection    : DIRECTION < string Object = "Light"; >;

VS_OUTPUT VS_BufferRender( float4 Pos : POSITION, float4 Tex : TEXCOORD0 ){
    VS_OUTPUT Out;
    
    Out.Pos = Pos - float4(0.0001f,-0.0001f,0.0f,0.0f);
    Out.Tex = Tex;
    float4 target = mul(float4(normalize(ContPos)*1000,1),mVP);
	Out.Center = 0.5f * (target.xy / target.w) + 0.5f;
	Out.Center.y = 1.0f-Out.Center.y;
	Out.Alpha = target.w;
    return Out;
}


float4  PS_RadialBlur(float2 Tex: TEXCOORD0 ,float2 Center: TEXCOORD1,float Alpha: TEXCOORD2) : COLOR0
{
	float4 Color;
	Color = tex2D( B2Samp, Tex);
	Color *= (1-(pow(length(Tex - Center)*((1-morph_size)*50.0),(1-morph_boke)*1.0)-1));
	Color = saturate(Color);
	Color.rgb *= float3(1-morph_r,1-morph_g,1-morph_b);
	if(Alpha < 0)
		Color = 0;
	return Color;
}
//�J��Ԃ��p�u���[
float4  PS_Blur(float2 Tex: TEXCOORD0 ,float2 Center: TEXCOORD1,uniform sampler2D Samp,uniform bool Cpy) : COLOR0
{
	float4 Color;
	if(!Cpy)
	{
		//�u���[�̒��S�ʒu �� ���݂̃e�N�Z���ʒu
		float2 dir = Center - Tex;
		dir *= 0.5+morph_len*2.0;
		//�������v�Z����
		float len = length( dir );
		
		//�����x�N�g���̐��K�����A�P�e�N�Z�����̒����ƂȂ�����x�N�g�����v�Z����
		dir = normalize( dir );
		dir *= SampStep;
		float2 BackDir = dir*0.5;
		
		//������ώZ���邱�Ƃɂ��A�����̒��S�ʒu�ɋ߂��قǃu���[�̉e�����������Ȃ�悤�ɂ���
		dir *= BlurPower * len;
		//���Ε����͏��1
		
		if(len < 0){
			Color = tex2D( Samp, Tex);
		}else{
			Color  = WT_0 *   tex2D( Samp, Tex );
			Color += WT_1 * ( tex2D( Samp, Tex+dir  ) + tex2D( Samp, Tex-BackDir  ) );
			Color += WT_2 * ( tex2D( Samp, Tex+dir*2) + tex2D( Samp, Tex-BackDir*2) );
			Color += WT_3 * ( tex2D( Samp, Tex+dir*3) + tex2D( Samp, Tex-BackDir*3) );
			Color += WT_4 * ( tex2D( Samp, Tex+dir*4) + tex2D( Samp, Tex-BackDir*4) );
			Color += WT_5 * ( tex2D( Samp, Tex+dir*5) + tex2D( Samp, Tex-BackDir*5) );
			Color += WT_6 * ( tex2D( Samp, Tex+dir*6) + tex2D( Samp, Tex-BackDir*6) );
			Color += WT_7 * ( tex2D( Samp, Tex+dir*7) + tex2D( Samp, Tex-BackDir*7) );
		}
	}else{
		Color = tex2D( Samp, Tex);
	}
	
	return Color;
}

int loop = 2;

technique PostEffect <
    string Script = 
		"RenderColorTarget0=;"
		"RenderDepthStencilTarget=;"
			"ScriptExternal=Color;"

		"RenderDepthStencilTarget=DepthBuffer;"			
		"RenderColorTarget0=BlurMap1;"
			"Clear=Color;"
			"Clear=Depth;"
			"Pass=Cpy;"
					
		"RenderColorTarget0=BlurMap2;"
			"Clear=Color;"
			"Clear=Depth;"
			"Pass=Blur2;"
		"LoopByCount=loop;"
		
		"RenderColorTarget0=BlurMap1;"
			"Clear=Color;"
			"Clear=Depth;"
			"Pass=Blur1;"
			
		"RenderColorTarget0=BlurMap2;"
			"Clear=Color;"
			"Clear=Depth;"
			"Pass=Blur2;"			
		"LoopEnd=;"
		
		"RenderColorTarget0=;"
			"RenderDepthStencilTarget=;"
			"Pass=DrawRadialBlur;"

    ;
> {
    pass DrawRadialBlur < string Script= "Draw=Buffer;"; > {
        SRCBLEND = ONE;
        DESTBLEND = ONE;
        VertexShader = compile vs_2_0 VS_BufferRender();
        PixelShader  = compile ps_2_0 PS_RadialBlur();
    }
    pass Cpy < string Script= "Draw=Buffer;"; > {
        AlphaBlendEnable = FALSE;
        VertexShader = compile vs_2_0 VS_BufferRender();
        PixelShader  = compile ps_2_0 PS_Blur(MaskView,true);
    }
    pass Blur1 < string Script= "Draw=Buffer;"; > {
        AlphaBlendEnable = FALSE;
        VertexShader = compile vs_2_0 VS_BufferRender();
        PixelShader  = compile ps_2_0 PS_Blur(B2Samp,false);
    }
    pass Blur2 < string Script= "Draw=Buffer;"; > {
        AlphaBlendEnable = FALSE;
        VertexShader = compile vs_2_0 VS_BufferRender();
        PixelShader  = compile ps_2_0 PS_Blur(B1Samp,false);
    }
}