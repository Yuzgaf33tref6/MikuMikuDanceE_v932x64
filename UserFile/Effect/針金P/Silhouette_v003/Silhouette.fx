////////////////////////////////////////////////////////////////////////////////////////////////
//
//  Silhouette.fx ver0.0.3  ���f�����V���G�b�g�`�悵�܂�
//  �쐬: �j��P( ���͉��P����Mirror.fx���� )
//
////////////////////////////////////////////////////////////////////////////////////////////////
// �����̃p�����[�^��ύX���Ă�������

// �V���G�b�g�����郂�f���t�@�C����(�Ƃ肠����10�̂܂Œ�`�\)
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


#define UseTex  1                 // �V���G�b�g�f�����C0:�P�F�C1:�e�N�X�`��, 2:�A�j��GIF�APNG, 3:Screen.bmp�A�j��
#define TexFile  "sample.png"     // ��ʂɓ\��t����e�N�X�`���t�@�C����(�P�F�Screen.bmp�̏ꍇ�͖���)
#define AnimeStart 0.0            // �A�j��GIF�APNG�̏ꍇ�̃A�j���[�V�����J�n����(�P�ʁF�b)(�A�j��GIF�APNG�ȊO�ł͖���)

#define AlphaType  0              // 0:����������, 1:���Z����

#define MaskFile "sampleMask.png" // �t�F�[�h�}�X�N�ɗp����e�N�X�`���t�@�C����
float Threshold = 0.2;            // �t�F�[�h��臒l(�l���������ƃt�F�[�h�̕ω����V���[�v�ő傫���ƃ}�C���h�ɂȂ�܂�)

float TexWidthSize  = 1.0;       // ��ʂɑ΂���e�N�X�`���摜�̕��䗦(�P�F�̏ꍇ�͖���)
float TexHeightSize = 1.0;       // ��ʂɑ΂���e�N�X�`���摜�̍����䗦(�P�F�̏ꍇ�͖���)


// ����Ȃ��l�͂������牺�͂�����Ȃ��ł�

///////////////////////////////////////////////////////////////////////////////////////////////

#ifndef MIKUMIKUMOVING
    #define OFFSCREEN_FX_MASK1  "Silhouette_Obj.fx"          // �I�t�X�N���[���}�X�N�G�t�F�N�g1
    #define OFFSCREEN_FX_MASK2  "Silhouette_Mask.fxsub"      // �I�t�X�N���[���}�X�N�G�t�F�N�g2
#else
    #define OFFSCREEN_FX_MASK1  "Silhouette_Obj_MMM.fxm"     // �I�t�X�N���[���}�X�N�G�t�F�N�g1
    #define OFFSCREEN_FX_MASK2  "Silhouette_Mask_MMM.fxsub"  // �I�t�X�N���[���}�X�N�G�t�F�N�g2
#endif


// ���f���̃}�X�N�Ɏg���I�t�X�N���[���o�b�t�@
texture SilhouetteRT : OFFSCREENRENDERTARGET <
    string Description = "OffScreen RenderTarget for Silhouette.fx";
    float2 ViewPortRatio = {1.0,1.0};
    float4 ClearColor = { 0, 0, 0, 1 };
    float ClearDepth = 1.0;
    bool AntiAlias = true;
    string DefaultEffect = 
        "self = hide;"
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
sampler SilhouetteView = sampler_state {
    texture = <SilhouetteRT>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = NONE;
    AddressU  = CLAMP;
    AddressV = CLAMP;
};


float time : TIME;

// �A�N�Z�T���p�����[�^
float4x4 WorldMatrix : WORLD;
float4 MaterialDiffuse : DIFFUSE  < string Object = "Geometry"; >;
float3 AcsRound : CONTROLOBJECT < string name = "Silhouette.x"; string item = "Rxyz"; >;
static float3 AcsOffset = WorldMatrix._41_42_43;
static float AcsScaling = length(WorldMatrix._11_12_13)*0.1f; 
static float AcsAlpha = MaterialDiffuse.a;
static float TexScaling = abs(WorldMatrix._43)<1.0f ? 1.0f : (WorldMatrix._43>0.0f ? 1.0f/WorldMatrix._43 : abs(WorldMatrix._43));

// �X�N���[���T�C�Y
float2 ViewportSize : VIEWPORTPIXELSIZE;
static float2 ViewportOffset = float2(0.5f, 0.5f)/ViewportSize;


#if(UseTex == 1)
// ��ʂɓ\��t����e�N�X�`��
texture2D screen_tex <
    string ResourceName = TexFile;
    int MipLevels = 0;
>;
#endif

#if(UseTex == 2)
// ��ʂɓ\��t����A�j���[�V�����e�N�X�`��
texture screen_tex : ANIMATEDTEXTURE <
    string ResourceName = TexFile;
    int MipLevels = 1;
    float Offset = AnimeStart;
>;
#endif

#if(UseTex == 3)
// �I�u�W�F�N�g�̃e�N�X�`��
texture screen_tex: MATERIALTEXTURE;
#endif

#if(UseTex > 0)
sampler TexSampler = sampler_state {
    texture = <screen_tex>;
    MINFILTER = LINEAR;
    MAGFILTER = LINEAR;
    MagFilter = LINEAR;
    AddressU  = WRAP;
    AddressV = WRAP;
};
#endif

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
//���ʋ����`��V�F�[�_
struct VS_OUTPUT {
    float4 Pos : POSITION;
    float2 Tex : TEXCOORD0;
};

VS_OUTPUT VS_Mirror(float4 Pos : POSITION, float4 Tex : TEXCOORD0)
{
    VS_OUTPUT Out = (VS_OUTPUT)0; 

    Out.Pos = Pos;
    Out.Tex = Tex + ViewportOffset;

    return Out;
}

float4 PS_Mirror(float2 Tex: TEXCOORD0) : COLOR
{
    // �I�t�X�N���[���o�b�t�@�̐F
    float4 ColorOff = tex2D(SilhouetteView, Tex);

#if(UseTex == 0)
    // �P�F�w��̏ꍇ�̐F
    float4 Color = saturate( float4(degrees(AcsRound), 1.0f) );
#else
    // �\��t����e�N�X�`���̐F
    float2 texCoord = float2( Tex.x/TexWidthSize + AcsOffset.x*time,
                              Tex.y/TexHeightSize + AcsOffset.y*time ) * TexScaling;
    float4 Color = tex2D(TexSampler, texCoord);
#endif

    Color.a *= ColorOff.r;

    // �}�X�N����e�N�X�`���̐F
    float4 MaskColor = tex2D( MaskSamp, Tex );

    // �O���C�X�P�[���v�Z
    float v = (MaskColor.r + MaskColor.g + MaskColor.b)*0.333333f;

    // �t�F�[�h���ߒl�v�Z
    float a = (1.0+Threshold)*AcsScaling - 0.5f*Threshold;
    float minLen = a - 0.5f*Threshold;
    float maxLen = a + 0.5f*Threshold;
    Color.a *= AcsAlpha*saturate( (maxLen - v)/(maxLen - minLen) );

    return Color;
}

////////////////////////////////////////////////////////////////////////////////////////////////
//�e�N�j�b�N

technique MainTec{
    pass DrawObject < string Script= "Draw=Buffer;"; > {
#if(AlphaType == 1)
        AlphaBlendEnable = TRUE;
        SrcBlend = SRCALPHA;
        DestBlend = ONE;
#endif
        VertexShader = compile vs_2_0 VS_Mirror();
        PixelShader  = compile ps_2_0 PS_Mirror();
    }
    
}
////////////////////////////////////////////////////////////////////////////////////////////////



