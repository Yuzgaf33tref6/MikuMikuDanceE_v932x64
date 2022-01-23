////////////////////////////////////////////////////////////////////////////////////////////////
//
//  Ghost.fx ver0.0.5  ���f���̔������`��ɂ��H��\��
//  �쐬: �j��P
//
////////////////////////////////////////////////////////////////////////////////////////////////
// �����̃p�����[�^��ύX���Ă�������

// �������ɂ��郂�f���t�@�C����(�Ƃ肠����10�̂܂Œ�`�\)
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


// �t�F�[�h�p�����[�^
float HeightMin <  // �t�F�[�h�J�n�����
   string UIName = "�t�F�[�h�J�n��";
   string UIHelp = "�t�F�[�h�J�n�����";
   string UIWidget = "Numeric";
   bool UIVisible =  true;
   float UIMin = 0.0;
   float UIMax = 100.0;
> = 0.0;

float HeightMax <  // �t�F�[�h�I�������
   string UIName = "�t�F�[�h�I����";
   string UIHelp = "�t�F�[�h�I�������";
   string UIWidget = "Numeric";
   bool UIVisible =  true;
   float UIMin = 0.0;
   float UIMax = 100.0;
> = 20.0;

float Threshold <  // �t�F�[�h��臒l(�l���������ƃt�F�[�h�̕ω����V���[�v�ő傫���ƃ}�C���h�ɂȂ�܂�)
   string UIName = "�t�F�[�h��臒l";
   string UIHelp = "�l���������ƃt�F�[�h�̕ω����V���[�v�ő傫���ƃ}�C���h�ɂȂ�܂�";
   string UIWidget = "Slider";
   bool UIVisible =  true;
   float UIMin = 0.0;
   float UIMax = 1.0;
> = 0.5;


// ����Ȃ��l�͂������牺�͂�����Ȃ��ł�

///////////////////////////////////////////////////////////////////////////////////////////////

#ifndef MIKUMIKUMOVING
    #define OFFSCREEN_FX_HIDE   "hide"
    #define OFFSCREEN_FX_NONE   "none"
    #define OFFSCREEN_FX_MASK1  "Ghost_Mask1.fx"    // �I�t�X�N���[���}�X�N�G�t�F�N�g1
    #define OFFSCREEN_FX_MASK2  "Ghost_Mask2.fx"    // �I�t�X�N���[���}�X�N�G�t�F�N�g2
#else
    #define OFFSCREEN_FX_HIDE   "Hide.fxsub"
    #define OFFSCREEN_FX_NONE   "SampleBase.fxsub"
    #define OFFSCREEN_FX_MASK1  "Ghost_Mask1_MMM.fxm"    // �I�t�X�N���[���}�X�N�G�t�F�N�g1
    #define OFFSCREEN_FX_MASK2  "Ghost_Mask2_MMM.fxsub"  // �I�t�X�N���[���}�X�N�G�t�F�N�g2
#endif


// ���f���̃I�t�X�N���[�������_
texture GhostRT: OFFSCREENRENDERTARGET <
    string Description = "OffScreen RenderTarget for Ghost.fx";
    float2 ViewPortRatio = {1.0, 1.0};
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
sampler GhostView = sampler_state {
    texture = <GhostRT>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = NONE;
    AddressU  = CLAMP;
    AddressV = CLAMP;
};


// ���f���̃}�X�N�Ɏg���I�t�X�N���[���o�b�t�@
texture MaskGhostRT : OFFSCREENRENDERTARGET <
    string Description = "OffScreen RenderTarget for Mask of Ghost.fx";
    float2 ViewPortRatio = {1.0, 1.0};
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
sampler MaskGhost = sampler_state {
    texture = <MaskGhostRT>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = NONE;
    AddressU  = CLAMP;
    AddressV = CLAMP;
};


// �X�N���[���T�C�Y
float2 ViewportSize : VIEWPORTPIXELSIZE;
static float2 ViewportOffset = float2(0.5f, 0.5f) / ViewportSize;

// �A�N�Z�T���p�����[�^
float AcsX  : CONTROLOBJECT < string name = "(self)"; string item = "X"; >;
float AcsY  : CONTROLOBJECT < string name = "(self)"; string item = "Y"; >;
float AcsSi : CONTROLOBJECT < string name = "(self)"; string item = "Si"; >;
float AcsTr : CONTROLOBJECT < string name = "(self)"; string item = "Tr"; >;

static float Xoffset = AcsX + HeightMin;
static float Yoffset = AcsY + HeightMax;


////////////////////////////////////////////////////////////////////////////////////////////////
// ���f���������`��

struct VS_OUTPUT {
    float4 Pos : POSITION;
    float2 Tex : TEXCOORD0;
};

VS_OUTPUT VS_Ghost(float4 Pos : POSITION, float4 Tex : TEXCOORD0)
{
    VS_OUTPUT Out = (VS_OUTPUT)0; 

    Out.Pos = Pos;
    Out.Tex = Tex + ViewportOffset;

    return Out;
}

float4 PS_Ghost(float2 Tex: TEXCOORD0) : COLOR
{
    // �I�t�X�N���[���o�b�t�@�̐F
    float4 Color = tex2D(GhostView, Tex);
    float4 Color2 = tex2D(MaskGhost, Tex);
    Color.a *= Color2.r;

    // �t�F�[�h���ߒl�v�Z
    float h = Color2.g * 100.0f + Color2.b * 10.0f;
    float v = 1.0f-saturate( ( h - Xoffset ) / ( Yoffset - Xoffset ) );
    float a = (1.0+Threshold)*AcsSi*0.1f - 0.5f*Threshold;
    float minLen = a - 0.5f*Threshold;
    float maxLen = a + 0.5f*Threshold;
    Color.a *= AcsTr * saturate( (maxLen - v)/(maxLen - minLen) );

    return Color;
}

////////////////////////////////////////////////////////////////////////////////////////////////
//�e�N�j�b�N

technique MainTec{
    pass DrawObject < string Script= "Draw=Buffer;"; > {
        VertexShader = compile vs_2_0 VS_Ghost();
        PixelShader  = compile ps_2_0 PS_Ghost();
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////



