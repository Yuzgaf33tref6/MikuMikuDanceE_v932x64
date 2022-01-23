////////////////////////////////////////////////////////////////////////////////////////////////
//
//  ShadeFader.fx ver0.0.3  �V�F�[�_�n�G�t�F�N�g��ON/OFF���X���[�Y�ɐ؂�ւ���
//  �쐬: �j��P
//
////////////////////////////////////////////////////////////////////////////////////////////////
// �����̃p�����[�^��ύX���Ă�������

// �t�F�[�h���郂�f���t�@�C����(�Ƃ肠����10�̂܂Œ�`�\)
//#define ModelFileName01  "�����~�NVer2.pmd"  // ������ȕ��ɖ���`�̑���� "" �̊ԂɃ��f���t�@�C����������(�s�擪�� // �͍폜)
//#define ModelFileName02  "����`"
//#define ModelFileName03  "����`"
//#define ModelFileName04  "����`"
//#define ModelFileName05  "����`"
//#define ModelFileName06  "����`"
//#define ModelFileName07  "����`"
//#define ModelFileName08  "����`"
//#define ModelFileName09  "����`"
//#define ModelFileName10  "����`"

#define MaskFile "sampleMask.png"   // �t�F�[�h�}�X�N�ɗp����e�N�X�`���t�@�C����

float Threshold <  // �t�F�[�h��臒l(�l���������ƃt�F�[�h�̕ω����V���[�v�ő傫���ƃ}�C���h�ɂȂ�܂�)
   string UIName = "�t�F�[�h��臒l";
   string UIHelp = "�l���������ƃt�F�[�h�̕ω����V���[�v�ő傫���ƃ}�C���h�ɂȂ�܂�";
   string UIWidget = "Slider";
   bool UIVisible =  true;
   float UIMin = 0.0;
   float UIMax = 1.0;
> = 0.2;


// ����Ȃ��l�͂������牺�͂�����Ȃ��ł�

///////////////////////////////////////////////////////////////////////////////////////////////

#ifndef MIKUMIKUMOVING
    #define OFFSCREEN_FX_HIDE   "hide"
    #define OFFSCREEN_FX_NONE   "none"
    #define OFFSCREEN_FX_MASK1  "SF_Mask1.fx"       // �I�t�X�N���[���}�X�N�G�t�F�N�g1
    #define OFFSCREEN_FX_MASK2  "SF_Mask2.fxsub"    // �I�t�X�N���[���}�X�N�G�t�F�N�g2
#else
    #define OFFSCREEN_FX_HIDE   "Hide.fxsub"
    #define OFFSCREEN_FX_NONE   "SampleBase.fxsub"
    #define OFFSCREEN_FX_MASK1  "SF_Mask1_MMM.fxm"    // �I�t�X�N���[���}�X�N�G�t�F�N�g1
    #define OFFSCREEN_FX_MASK2  "SF_Mask2_MMM.fxsub"  // �I�t�X�N���[���}�X�N�G�t�F�N�g2
#endif


// ���f���̃}�X�N�Ɏg���I�t�X�N���[���o�b�t�@
texture MaskShadeFaderRT : OFFSCREENRENDERTARGET <
    string Description = "OffScreen RenderTarget for Mask of ShadeFader.fx";
    float2 ViewPortRatio = {1.0,1.0};
    float4 ClearColor = { 0, 0, 0, 1 };
    float ClearDepth = 1.0;
    bool AntiAlias = true;
    string DefaultEffect = 
        "self = " OFFSCREEN_FX_HIDE ";"
        #ifdef ModelFileName01
        ModelFileName01 "=" OFFSCREEN_FX_MASK1 ";"
        #endif
        #ifdef ModelFileName02
        ModelFileName02 "=" OFFSCREEN_FX_MASK1 ";"
        #endif
        #ifdef ModelFileName03
        ModelFileName03 "=" OFFSCREEN_FX_MASK1 ";"
        #endif
        #ifdef ModelFileName04
        ModelFileName04 "=" OFFSCREEN_FX_MASK1 ";"
        #endif
        #ifdef ModelFileName05
        ModelFileName05 "=" OFFSCREEN_FX_MASK1 ";"
        #endif
        #ifdef ModelFileName06
        ModelFileName06 "=" OFFSCREEN_FX_MASK1 ";"
        #endif
        #ifdef ModelFileName07
        ModelFileName07 "=" OFFSCREEN_FX_MASK1 ";"
        #endif
        #ifdef ModelFileName08
        ModelFileName08 "=" OFFSCREEN_FX_MASK1 ";"
        #endif
        #ifdef ModelFileName09
        ModelFileName09 "=" OFFSCREEN_FX_MASK1 ";"
        #endif
        #ifdef ModelFileName10
        ModelFileName10 "=" OFFSCREEN_FX_MASK1 ";"
        #endif
        "* = " OFFSCREEN_FX_MASK2 ";" ;
>;
sampler MaskShadeFader = sampler_state {
    texture = <MaskShadeFaderRT>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = NONE;
    AddressU  = CLAMP;
    AddressV = CLAMP;
};


// MMD�W���`��̃I�t�X�N���[�������_
texture ShadeFaderRT: OFFSCREENRENDERTARGET <
    string Description = "OffScreen RenderTarget for ShadeFader.fx";
    float2 ViewPortRatio = {1.0,1.0};
    float4 ClearColor = { 0, 0, 0, 0 };
    float ClearDepth = 1.0;
    bool AntiAlias = true;
    string DefaultEffect = 
        "self = " OFFSCREEN_FX_HIDE ";"
        #ifdef ModelFileName01
        ModelFileName01 "=" OFFSCREEN_FX_NONE ";"
        #endif
        #ifdef ModelFileName02
        ModelFileName02 "=" OFFSCREEN_FX_NONE ";"
        #endif
        #ifdef ModelFileName03
        ModelFileName03 "=" OFFSCREEN_FX_NONE ";"
        #endif
        #ifdef ModelFileName04
        ModelFileName04 "=" OFFSCREEN_FX_NONE ";"
        #endif
        #ifdef ModelFileName05
        ModelFileName05 "=" OFFSCREEN_FX_NONE ";"
        #endif
        #ifdef ModelFileName06
        ModelFileName06 "=" OFFSCREEN_FX_NONE ";"
        #endif
        #ifdef ModelFileName07
        ModelFileName07 "=" OFFSCREEN_FX_NONE ";"
        #endif
        #ifdef ModelFileName08
        ModelFileName08 "=" OFFSCREEN_FX_NONE ";"
        #endif
        #ifdef ModelFileName09
        ModelFileName09 "=" OFFSCREEN_FX_NONE ";"
        #endif
        #ifdef ModelFileName10
        ModelFileName10 "=" OFFSCREEN_FX_NONE ";"
        #endif
        "* = " OFFSCREEN_FX_HIDE ";" ;
>;
sampler ShadeFaderView = sampler_state {
    texture = <ShadeFaderRT>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = NONE;
    AddressU  = CLAMP;
    AddressV = CLAMP;
};


// �X�N���[���T�C�Y
float2 ViewportSize : VIEWPORTPIXELSIZE;
static float2 ViewportOffset = float2(0.5f, 0.5f)/ViewportSize;

// �A�N�Z�T���p�����[�^
float4x4 WorldMatrix : WORLD;
static float AcsScaling = length(WorldMatrix._11_12_13)*0.1f; 
// �}�e���A���F
float4 MaterialDiffuse   : DIFFUSE  < string Object = "Geometry"; >;
static float AcsAlpha = MaterialDiffuse.a;

// �}�X�N�ɗp����e�N�X�`��
texture2D mask_tex <
    string ResourceName = MaskFile;
    int MipLevels = 1;
>;
sampler MaskSamp = sampler_state {
    texture = <mask_tex>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = NONE;
    AddressU  = CLAMP;
    AddressV = CLAMP;
};

////////////////////////////////////////////////////////////////////////////////////////////////
// MMD�W���`��̏㏑��

struct VS_OUTPUT {
    float4 Pos : POSITION;
    float2 Tex : TEXCOORD0;
};

VS_OUTPUT VS_Shader(float4 Pos : POSITION, float4 Tex : TEXCOORD0)
{
    VS_OUTPUT Out = (VS_OUTPUT)0; 

    Out.Pos = Pos;
    Out.Tex = Tex + ViewportOffset;

    return Out;
}

float4 PS_Shader(float2 Tex: TEXCOORD0) : COLOR
{
    // �I�t�X�N���[���o�b�t�@�̐F
    float4 Color = tex2D(ShadeFaderView, Tex);
    float4 Color2 = tex2D(MaskShadeFader, Tex);
    Color.a *= Color2.r;

    // �}�X�N����e�N�X�`���̐F
    float4 MaskColor = tex2D( MaskSamp, Tex );

    // �O���C�X�P�[���v�Z
    float v = (MaskColor.r + MaskColor.g + MaskColor.b)*0.333333f;

    // �t�F�[�h���ߒl�v�Z
    float a = (1.0+Threshold)*AcsScaling - 0.5f*Threshold;
    float minLen = a - 0.5f*Threshold;
    float maxLen = a + 0.5f*Threshold;
    Color.a *= (1.0f-AcsAlpha)*saturate( (maxLen - v)/(maxLen - minLen) );

    return Color;
}

////////////////////////////////////////////////////////////////////////////////////////////////
//�e�N�j�b�N

technique MainTec{
    pass DrawObject < string Script= "Draw=Buffer;"; > {
        VertexShader = compile vs_2_0 VS_Shader();
        PixelShader  = compile ps_2_0 PS_Shader();
    }
}
////////////////////////////////////////////////////////////////////////////////////////////////



