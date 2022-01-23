////////////////////////////////////////////////////////////////////////////////////////////////
//
//  SoftShadow.fx ver0.0.4 �n�ʉe���ڂ����Ă��瓊�e�ł���悤�ɂ��܂�
//  �쐬: �j��P( ���͉��P����Mirror.fx, Gaussian.fx���� )
//
////////////////////////////////////////////////////////////////////////////////////////////////
// �����̃p�����[�^��ύX���Ă�������

#define SampCount  8    // �ڂ����ɗp����T���v�����O��
#define TEXSIZE    512  // �n�ʃe�N�X�`���̃T�C�Y


float3 MaterialAmbient <      // �n�ʉe��Ambient�F(RBG)
   string UIName = "�eAmbient";
   string UIWidget = "Color";
   bool UIVisible =  true;
   float UIMin = 0.0;
   float UIMax = 1.0;
> = float3(0.3,0.3,0.3);

float3 MaterialEmmisive <      // �n�ʉe��Emmisive�F(RBG)
   string UIName = "�eEmmisive";
   string UIWidget = "Color";
   bool UIVisible =  true;
   float UIMin = 0.0;
   float UIMax = 1.0;
> = float3(0.2,0.2,0.2);

float GaussianLangth < // �n�ʉe�ڂ�������
   string UIName = "�e�ڂ�����l";
   string UIWidget = "Numeric";
   bool UIVisible =  true;
   float UIMin = 0.0;
   float UIMax = 100.0;
> = float( 30.0 );


// ����Ȃ��l�͂������牺�͂�����Ȃ��ł�

///////////////////////////////////////////////////////////////////////////////////////////////

// ���W�ϊ��s��
float4x4 WorldMatrix     : WORLD;
float4x4 ViewMatrix      : VIEW;
float4x4 ProjMatrix      : PROJECTION;
float4x4 ViewProjMatrix  : VIEWPROJECTION;

//�J�����ʒu
float3 CameraPosition : POSITION  < string Object = "Camera"; >;

// �}�e���A���F
float4 MaterialDiffuse : DIFFUSE < string Object = "Geometry"; >;

// ���C�g�F
float3 LightAmbient : AMBIENT < string Object = "Light"; >;
static float3 MaterialColor = saturate(MaterialAmbient * LightAmbient + MaterialEmmisive);


#ifndef MIKUMIKUMOVING
    #define OFFSCREEN_FX_HIDE    "hide"
    #define OFFSCREEN_FX_SHADOW  "SoftShadowObject.fxsub"          // �I�t�X�N���[���e�`��G�t�F�N�g
    #define GET_VPMAT(p) (ViewProjMatrix)
#else
    #define OFFSCREEN_FX_HIDE    "Hide.fxsub"
    #define OFFSCREEN_FX_SHADOW  "SoftShadowObject_MMM.fxsub"     // �I�t�X�N���[���e�`��G�t�F�N�g
    #define GET_VPMAT(p) (MMM_IsDinamicProjection ? mul(ViewMatrix, MMM_DynamicFov(ProjMatrix, length(CameraPosition-p.xyz))) : ViewProjMatrix)
#endif


// �n�ʉe�`��p�I�t�X�N���[���o�b�t�@
texture SoftShadowRT: OFFSCREENRENDERTARGET <
    string Description = "OffScreen RenderTarget for SoftShadow.fx";
    int Width = TEXSIZE;
    int Height = TEXSIZE;
    float4 ClearColor = { 0, 0, 0, 1 };
    float ClearDepth = 1.0;
    bool AntiAlias = true;
    string DefaultEffect = 
        "self = " OFFSCREEN_FX_HIDE ";"

        "*.pmd =" OFFSCREEN_FX_SHADOW ";"
        "*.pmx =" OFFSCREEN_FX_SHADOW ";"

        "* = " OFFSCREEN_FX_HIDE ";" ;
>;
sampler SoftShadowView = sampler_state {
    texture = <SoftShadowRT>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = NONE;
    AddressU  = CLAMP;
    AddressV = CLAMP;
};


///////////////////////////////////////////////////////////////////////////////////////////////

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

// �X�N���[���T�C�Y
float2 ViewportSize = float2(TEXSIZE, TEXSIZE);
static float2 ViewportOffset = float2(0.5f,0.5f)/ViewportSize;

// �����_�����O�^�[�Q�b�g�̃N���A�l
float4 ClearColor = {0,0,0,1};
float ClearDepth  = 1.0;

// X�����̂ڂ������ʂ��L�^���邽�߂̃����_�[�^�[�Q�b�g
texture2D ScnMapX : RENDERCOLORTARGET <
    int Width = TEXSIZE;
    int Height = TEXSIZE;
    int MipLevels = 1;
    string Format = "A8R8G8B8" ;
>;
sampler2D ScnSampX = sampler_state {
    texture = <ScnMapX>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = NONE;
    AddressU  = CLAMP;
    AddressV = CLAMP;
};

// Y�����̂ڂ������ʂ��L�^���邽�߂̃����_�[�^�[�Q�b�g
texture2D ScnMapY : RENDERCOLORTARGET <
    int Width = TEXSIZE;
    int Height = TEXSIZE;
    int MipLevels = 1;
    string Format = "A8R8G8B8" ;
>;
sampler2D ScnSampY = sampler_state {
    texture = <ScnMapY>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = NONE;
    AddressU  = CLAMP;
    AddressV = CLAMP;
};

texture2D DepthBuffer : RENDERDEPTHSTENCILTARGET <
    int Width = TEXSIZE;
    int Height = TEXSIZE;
    string Format = "D24S8";
>;

////////////////////////////////////////////////////////////////////////////////////////////////

struct VS_OUTPUT {
    float4 Pos	: POSITION;
    float2 Tex	: TEXCOORD0;
};

VS_OUTPUT VS_Common( float4 Pos : POSITION, float2 Tex : TEXCOORD0 )
{
    VS_OUTPUT Out = (VS_OUTPUT)0; 

    Out.Pos = Pos;
    Out.Tex = Tex + ViewportOffset;

    return Out;
}

////////////////////////////////////////////////////////////////////////////////////////////////
// X�����ڂ���

float4 PS_passX( float2 Tex: TEXCOORD0 ) : COLOR
{
    // �T���v�����O�͈͓��̍ő�Օ�����
    float len = 0.0f;
    [unroll] //���[�v�W�J����
    for(int i=-SampCount; i<=SampCount; i++){
       float4 c = tex2D( SoftShadowView, Tex+float2(i*ceil(GaussianLangth/SampCount), 0)/TEXSIZE );
       len = max(len, c.g * 100.0f + c.b * 10.0f);
    }

    // �T���v�����O�Ԋu
    float  LStep = 0.12f*SampCount/TEXSIZE * min(len/GaussianLangth, 1.0f);
    float4 Color = tex2D( SoftShadowView, Tex );

    float r = WT_0 * Color.r;
    r += WT_1 * ( tex2D( SoftShadowView, Tex+float2(LStep  , 0) ).r + tex2D( SoftShadowView, Tex-float2(LStep  , 0) ).r );
    r += WT_2 * ( tex2D( SoftShadowView, Tex+float2(LStep*2, 0) ).r + tex2D( SoftShadowView, Tex-float2(LStep*2, 0) ).r );
    r += WT_3 * ( tex2D( SoftShadowView, Tex+float2(LStep*3, 0) ).r + tex2D( SoftShadowView, Tex-float2(LStep*3, 0) ).r );
    r += WT_4 * ( tex2D( SoftShadowView, Tex+float2(LStep*4, 0) ).r + tex2D( SoftShadowView, Tex-float2(LStep*4, 0) ).r );
    r += WT_5 * ( tex2D( SoftShadowView, Tex+float2(LStep*5, 0) ).r + tex2D( SoftShadowView, Tex-float2(LStep*5, 0) ).r );
    r += WT_6 * ( tex2D( SoftShadowView, Tex+float2(LStep*6, 0) ).r + tex2D( SoftShadowView, Tex-float2(LStep*6, 0) ).r );
    r += WT_7 * ( tex2D( SoftShadowView, Tex+float2(LStep*7, 0) ).r + tex2D( SoftShadowView, Tex-float2(LStep*7, 0) ).r );

    Color.r = r;
    return Color;
}

////////////////////////////////////////////////////////////////////////////////////////////////
// Y�����ڂ���

float4 PS_passY(float2 Tex: TEXCOORD0) : COLOR
{
    // �T���v�����O�͈͓��̍ő�Օ�����
    float len = 0.0f;
    [unroll] //���[�v�W�J����
    for(int i=-SampCount; i<=SampCount; i++){
       float4 c = tex2D( SoftShadowView, Tex+float2(0, i*ceil(GaussianLangth/SampCount))/TEXSIZE );
       len = max(len, c.g * 100.0f + c.b * 10.0f);
    }

    // �T���v�����O�Ԋu
    float  LStep = 0.12f*SampCount/TEXSIZE * min(len/GaussianLangth, 1.0f);
    float4 Color = tex2D( ScnSampX, Tex );

    float r = WT_0 * Color.r;
    r += WT_1 * ( tex2D( ScnSampX, Tex+float2(0, LStep  ) ).r + tex2D( ScnSampX, Tex-float2(0, LStep  ) ).r );
    r += WT_2 * ( tex2D( ScnSampX, Tex+float2(0, LStep*2) ).r + tex2D( ScnSampX, Tex-float2(0, LStep*2) ).r );
    r += WT_3 * ( tex2D( ScnSampX, Tex+float2(0, LStep*3) ).r + tex2D( ScnSampX, Tex-float2(0, LStep*3) ).r );
    r += WT_4 * ( tex2D( ScnSampX, Tex+float2(0, LStep*4) ).r + tex2D( ScnSampX, Tex-float2(0, LStep*4) ).r );
    r += WT_5 * ( tex2D( ScnSampX, Tex+float2(0, LStep*5) ).r + tex2D( ScnSampX, Tex-float2(0, LStep*5) ).r );
    r += WT_6 * ( tex2D( ScnSampX, Tex+float2(0, LStep*6) ).r + tex2D( ScnSampX, Tex-float2(0, LStep*6) ).r );
    r += WT_7 * ( tex2D( ScnSampX, Tex+float2(0, LStep*7) ).r + tex2D( ScnSampX, Tex-float2(0, LStep*7) ).r );

    Color.r = r;
    return Color;
}

///////////////////////////////////////////////////////////////////////////////////////////////
// �I�u�W�F�N�g�`��

// ���_�V�F�[�_
VS_OUTPUT SoftShadow_VS(float4 Pos : POSITION, float2 Tex : TEXCOORD0)
{
    VS_OUTPUT Out = (VS_OUTPUT)0;

    // ���[���h���W�ϊ�
    Pos = mul( Pos, WorldMatrix );

    // �J�������_�̃r���[�ˉe�ϊ�
    Out.Pos = mul( Pos, GET_VPMAT(Pos) );

    // �e�N�X�`�����W
    Out.Tex = Tex;

    return Out;
}

// �s�N�Z���V�F�[�_
float4 SoftShadow_PS(float2 Tex : TEXCOORD0) : COLOR0
{
    float4 Color = tex2D(ScnSampY, Tex);
    return float4(MaterialColor, Color.r * MaterialDiffuse.a);
}

///////////////////////////////////////////////////////////////////////////////////////////////
technique MainTec <
    string Script = 
        "RenderColorTarget0=ScnMapX;"
	    "RenderDepthStencilTarget=DepthBuffer;"
		"ClearSetColor=ClearColor;"
		"ClearSetDepth=ClearDepth;"
		"Clear=Color;"
		"Clear=Depth;"
	    "Pass=Gaussian_X;"
        "RenderColorTarget0=ScnMapY;"
	    "RenderDepthStencilTarget=DepthBuffer;"
		"ClearSetColor=ClearColor;"
		"ClearSetDepth=ClearDepth;"
		"Clear=Color;"
		"Clear=Depth;"
	   "Pass=Gaussian_Y;"
        "RenderColorTarget0=;"
	    "RenderDepthStencilTarget=;"
	    "Pass=DrawObject;"
    ;
> {
    pass Gaussian_X < string Script= "Draw=Buffer;"; > {
        AlphaBlendEnable = FALSE;
        VertexShader = compile vs_3_0 VS_Common();
        PixelShader  = compile ps_3_0 PS_passX();
    }
    pass Gaussian_Y < string Script= "Draw=Buffer;"; > {
        AlphaBlendEnable = FALSE;
        VertexShader = compile vs_3_0 VS_Common();
        PixelShader  = compile ps_3_0 PS_passY();
    }
    pass DrawObject {
        VertexShader = compile vs_2_0 SoftShadow_VS();
        PixelShader  = compile ps_2_0 SoftShadow_PS();
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////
