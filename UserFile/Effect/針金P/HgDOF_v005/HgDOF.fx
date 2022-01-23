////////////////////////////////////////////////////////////////////////////////////////////////
//
//  HgDOF.fx ver0.0.5  ���i��(��������Ȃ�)��ʊE�[�x�G�t�F�N�g
//  �쐬: �j��P
//
////////////////////////////////////////////////////////////////////////////////////////////////
// �p�����[�^�X�C�b�`

#define MODE_HQ  1  // �O�{�P�p�X�N���[���o�b�t�@�𑜓x
// 0 : ���{�X�N���[���ŏ���(���i�ʂ����ǂ������d��)
// 1 : �����̃X�N���[���𑜓x�ŏ���


float FrontBlurLimit = 50.0;  // �O�{�P�ڂ������E�l


#define UseMLAA  1   // MLAA�@�ɂ���ʑ̂̃A���`�G�C���A�V���O����
// 0 : �������Ȃ��A�`�摬�x�D��A��{�P�ƃs���g����������ʑ̂̋��E�ɃW���M�[���o��B
// 1 : ��������A��ʑ̂̋��E�͂��ꂢ�ɂȂ邪�`�摬�x�͗�����B


//#define SizeFullHD  // 1920*1080�ŏo�͂���ꍇ�͂��̍s�擪�� // ���O��


// ����Ȃ��l�͂������牺�͂�����Ȃ��ł�

////////////////////////////////////////////////////////////////////////////////////////////////
// �p�����[�^�錾

float Script : STANDARDSGLOBAL <
    string ScriptOutput = "color";
    string ScriptClass = "sceneorobject";
    string ScriptOrder = "postprocess";
> = 0.8;

#ifndef MIKUMIKUMOVING
    #define OFFSCREEN_FX     "HgDOF_Depth.fxsub"
    #define AF_PAPAM1        100.0f
    #define AF_PAPAM2        20.0f
    #define COEF_BLUR_POWER  1.0f
#else
    #define OFFSCREEN_FX     "HgDOF_DepthMMM.fxsub"
    #define AF_PAPAM1        10.0f
    #define AF_PAPAM2        10.0f
    #define COEF_BLUR_POWER  0.8f
#endif

float AcsSi : CONTROLOBJECT < string name = "(self)"; string item = "Si"; >;
float AcsTr : CONTROLOBJECT < string name = "(self)"; string item = "Tr"; >;

#define AF_FLIENAME   "HgDOF_AutoFocus.x"
bool flagAF : CONTROLOBJECT < string name = AF_FLIENAME; >;
float AcsX  : CONTROLOBJECT < string name = AF_FLIENAME; string item = "X"; >;
float AcsY  : CONTROLOBJECT < string name = AF_FLIENAME; string item = "Y"; >;
float AcsRx : CONTROLOBJECT < string name = AF_FLIENAME; string item = "Rx"; >;
float AcsRy : CONTROLOBJECT < string name = AF_FLIENAME; string item = "Ry"; >;
static float AF_ElasticFactor = clamp(100.0f + degrees(AcsRx), 1.0f, 1000.0f);  // �I�[�g�t�H�[�J�X�œ_�Ǐ]�̒e���x
static float AF_ResistFactor  = clamp(20.0f + degrees(AcsRy), 0.1f, 100.0f);    // �I�[�g�t�H�[�J�X�œ_�Ǐ]�̒�R�x

float time : TIME;

// �O�{�P�`�攽����
#if MODE_HQ==0
    #ifndef SizeFullHD
    int RepertCountF = 256; 
    #else
    int RepertCountF = 512;
    #endif
#else
    #ifndef SizeFullHD
    int RepertCountF = 64;
    #else
    int RepertCountF = 128;
    #endif
#endif
int RepertCount = 3;  // ��{�P�`�攽����
int RepertIndex;      // �`�攽���񐔂̃J�E���^

#define DEPTH_FAR  5000.0f   // �[�x�ŉ��l
#define FOCUS_AREA  0.15f    // �s���g�������͈�
#define SAMP_NUM    8        // MLAA�@�̈�����̃T���v�����O��

// �ڂ��������̏d�݌W���F
//    �K�E�X�֐� exp( -x^2/(2*d^2) ) �� d=5, x=0�`7 �ɂ��Čv�Z�����̂��A
//    (WT_7 + WT_6 + �c + WT_1 + WT_0 + WT_1 + �c + WT_7) �� 1 �ɂȂ�悤�ɐ��K����������
float WT_COEF[8] = { 0.0920246,
                     0.0902024,
                     0.0849494,
                     0.0768654,
                     0.0668236,
                     0.0558158,
                     0.0447932,
                     0.0345379 };

#if MODE_HQ==0
    #define VIEWPORTRATIO  1.0
#else
    #define VIEWPORTRATIO  0.5
#endif

// �X�N���[���T�C�Y
float2 ViewportSize : VIEWPORTPIXELSIZE;
static float2 ViewportOffset = (float2(0.5,0.5)/ViewportSize);
#ifndef MIKUMIKUMOVING
static int2 ViewportSizeF = floor( ViewportSize * float2(VIEWPORTRATIO,VIEWPORTRATIO) );
#else
static int2 ViewportSizeF = floor( ViewportSize * float2(1,1) );
#endif
static float2 AASmpStep = float2(1,1) / ViewportSize;

// ���W�p�����[�^
float4x4 WorldMatrix  : WORLD;
float4x4 ProjMatrix   : PROJECTION;
float3 CameraPosition : POSITION  < string Object = "Camera"; >;

// �J��������̃p�[�X�y�N�e�B�u�t���O
static bool IsParth = ProjMatrix._44 < 0.5f;

// �[�x�}�b�v�`���I�t�X�N���[���o�b�t�@
texture HgDOF_DepthRT : OFFSCREENRENDERTARGET <
    string Description = "OffScreen RenderTarget for HgDOF.fx";
    float2 ViewPortRatio = {1.0,1.0};
    float4 ClearColor = { 1, 1, 1, 1 };
    float ClearDepth = 1.0f;
    string Format = "D3DFMT_R32F";
    bool AntiAlias = false;
    string DefaultEffect = 
        "self = hide;"
        "* =" OFFSCREEN_FX ";"
    ;
>;
sampler DepthMapSmp = sampler_state {
    texture = <HgDOF_DepthRT>;
    MinFilter = POINT;
    MagFilter = POINT;
    MipFilter = NONE;
    AddressU  = CLAMP;
    AddressV  = CLAMP;
};
sampler DepthMapSmp2 : register(s3) = sampler_state {
    texture = <HgDOF_DepthRT>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = NONE;
    AddressU  = CLAMP;
    AddressV  = CLAMP;
};

// �����_�����O�^�[�Q�b�g�̃N���A�l
float4 ClearColor = {1,1,1,0};
float4 ClearColorF = {0,0,0,0};
float ClearDepth  = 1.0f;

//#define TEX_FORMAT "D3DFMT_A8R8G8B8"
#define TEX_FORMAT "D3DFMT_A16B16G16R16F"
//#define TEX_FORMAT "D3DFMT_A32B32G32R32F"

// �I���W�i���̕`�挋�ʂ��L�^���邽�߂̃����_�[�^�[�Q�b�g
texture2D ScnMap : RENDERCOLORTARGET <
    float2 ViewPortRatio = {1.0,1.0};
    int MipLevels = 1;
    string Format = TEX_FORMAT;
>;
sampler2D ScnSamp = sampler_state {
    texture = <ScnMap>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = NONE;
    AddressU  = CLAMP;
    AddressV  = CLAMP;
};

texture2D DepthBuffer : RENDERDEPTHSTENCILTARGET <
    float2 ViewPortRatio = {1.0,1.0};
    string Format = "D3DFMT_D24S8";
>;

// X�����̂ڂ������ʂ��L�^���邽�߂̃����_�[�^�[�Q�b�g
texture2D ScnMap2 : RENDERCOLORTARGET <
    float2 ViewPortRatio = {1.0,1.0};
    int MipLevels = 1;
    string Format = TEX_FORMAT;
>;
sampler2D ScnSamp2 = sampler_state {
    texture = <ScnMap2>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = NONE;
    AddressU  = CLAMP;
    AddressV  = CLAMP;
};

// �O�{�P�p�̕`�挋�ʂ��L�^���邽�߂̃����_�[�^�[�Q�b�g
texture2D ScnMapF : RENDERCOLORTARGET <
    float2 ViewPortRatio = {VIEWPORTRATIO,VIEWPORTRATIO};
    int MipLevels = 1;
    string Format = TEX_FORMAT;
>;
sampler2D ScnSampF = sampler_state {
    texture = <ScnMapF>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = NONE;
    AddressU  = CLAMP;
    AddressV  = CLAMP;
};

texture2D DepthBufferF : RENDERDEPTHSTENCILTARGET <
    float2 ViewPortRatio = {VIEWPORTRATIO,VIEWPORTRATIO};
    string Format = "D3DFMT_D24S8";
>;

// �O�{�P�p�̉��Z�E�F�C�g���L�^���邽�߂̃����_�[�^�[�Q�b�g
texture2D WeightMapF : RENDERCOLORTARGET <
    float2 ViewPortRatio = {VIEWPORTRATIO,VIEWPORTRATIO};
    int MipLevels = 1;
    #if MODE_HQ==0
    string Format = "D3DFMT_R32F" ;
    #else
    string Format = "D3DFMT_A32B32G32R32F" ;
    #endif
>;
sampler2D WeightSampF = sampler_state {
    texture = <WeightMapF>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = NONE;
    AddressU  = CLAMP;
    AddressV  = CLAMP;
};

// �s�N�Z���{�[�h�}�X�N�e�N�X�`��
texture DestMaskTex <
    string ResourceName = "PixMask.png";
>;
sampler DestMaskSmp = sampler_state {
    texture = <DestMaskTex>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = NONE;
    AddressU  = CLAMP;
    AddressV  = CLAMP;
};

#if UseMLAA==1
// �֊s���o���ʂ��L�^���邽�߂̃����_�[�^�[�Q�b�g
texture2D OutlineMap : RENDERCOLORTARGET <
    float2 ViewPortRatio = {1.0,1.0};
    int MipLevels = 1;
    string Format = "D3DFMT_A8R8G8B8";
>;
sampler2D OutlineMapSamp = sampler_state {
    texture = <OutlineMap>;
    MinFilter = POINT;
    MagFilter = POINT;
    MipFilter = NONE;
    AddressU  = CLAMP;
    AddressV = CLAMP;
};
#endif

// �I�[�g�t�H�[�J�X�̍��ŋ����L�^�p
texture AutoFocusTex : RENDERCOLORTARGET
<
   int Width=1;
   int Height=1;
   string Format="D3DFMT_A32B32G32R32F";
>;
sampler AutoFocusSmp = sampler_state
{
   Texture = <AutoFocusTex>;
   AddressU  = CLAMP;
   AddressV = CLAMP;
   MinFilter = NONE;
   MagFilter = NONE;
   MipFilter = NONE;
};
texture AutoFocusDepthBuffer : RenderDepthStencilTarget <
   int Width=1;
   int Height=1;
    string Format = "D3DFMT_D24S8";
>;
float4 AutoFocusDep[1] : TEXTUREVALUE <
   string TextureName = "AutoFocusTex";
>;

// ���w�p�����[�^(�K��)
static float3 FocusPos = WorldMatrix._41_42_43;   // �}�j���A���t�H�[�J�X�̍��ňʒu
static float2 AutoFocusPos = saturate( float2(0.5f+0.5f*AcsX, 0.5f-0.5f*AcsY) ); // �I�[�g�t�H�[�J�X����X�N���[�����W
static float FocusDistance = flagAF ? AutoFocusDep[0].x : length(FocusPos - CameraPosition); // ���ŋ���
static float DiaphragmVal = 0.25f * sqrt(AcsSi*0.1f);            // �i��l(�ڂ����̊�l)
static float FocusLength = max(FOCUS_AREA * FocusDistance / pow(AcsSi * 0.1f, 0.25f), 5.0f); // �s���g�������͈�
static float FocusFar = FocusDistance + FocusLength;             // ��ʊE�[�x�̌�[
static float FocusNear = max(FocusDistance - FocusLength, 0.1f); // ��ʊE�[�x�̑O�[


////////////////////////////////////////////////////////////////////////////////////////////////

// �[�x�}�b�v�̓ǂݎ��
float GetDepth(float2 Tex)
{
    return tex2D( DepthMapSmp, Tex ).r * DEPTH_FAR;
}

// �[�x�}�b�v�̓ǂݎ��(�O�{�P�p)
float GetDepthF(float2 Tex)
{
    float dep = tex2Dlod( DepthMapSmp2, float4(Tex,0,0) ).r * DEPTH_FAR;
    dep = max(FocusNear - dep, 0.0f) / FocusNear;
    return dep;
}

// ��{�P�̂ڂ������x
float BackBlurPower(float dep)
{
    float blurLength = FocusFar * pow(6.0f, RepertIndex);
    float pixLen = max( DiaphragmVal * (dep - FocusFar) / blurLength, 0.0f);
    float viewLen = IsParth ? ProjMatrix._22 / dep : max(0.001f/ProjMatrix._11, 0.0001f);
    float blurPower = ViewportSize.y * pixLen * viewLen / 8.0f;
    return blurPower * COEF_BLUR_POWER;
}

// ��{�P�̃T���v�����O���[�g(��O�Ɉʒu����T���v���̓��[�g��������)
float BackBlurRate(float2 Tex, float dep0)
{
    float dep = GetDepth(Tex);
    float blurLength = FocusFar * pow(6.0f, RepertIndex);
    return saturate( (dep - FocusFar) / clamp(dep0 - FocusFar, 0.0001f, blurLength) );
}

// �[�x�ɉ������s�N�Z���g�嗦
float GetDepthScale(float2 Tex, float viewHeight, int level)
{
    float dep = tex2Dlod( DepthMapSmp, float4(Tex, 0, level) ).r * DEPTH_FAR;
    float pixLen = max( DiaphragmVal * (FocusDistance - dep - FocusLength) / FocusDistance, 0.0f);
    float viewLen = IsParth ? ProjMatrix._22 / dep : max(0.001f/ProjMatrix._11, 0.0001f);
    return min(1.0f + viewHeight * pixLen * viewLen * AcsTr, FrontBlurLimit);
}

// �������Z
int div(int a, int b) {
    return floor((a+0.1f)/b);
}

// ������]�Z
int mod(int a, int b) {
    return (a - div(a,b)*b);
};


////////////////////////////////////////////////////////////////////////////////////////////////
// ���ʂ̒��_�V�F�[�_

struct VS_OUTPUT {
    float4 Pos : POSITION;
    float2 Tex : TEXCOORD0;
};

VS_OUTPUT VS_Common( float4 Pos : POSITION, float2 Tex : TEXCOORD0 )
{
    VS_OUTPUT Out = (VS_OUTPUT)0; 

    Out.Pos = Pos;
    Out.Tex = Tex + ViewportOffset;

    return Out;
}


////////////////////////////////////////////////////////////////////////////////////////////////
// ��{�PX����

float4 PS_BackGaussianX( float2 Tex: TEXCOORD0 ) : COLOR
{
    float dep = GetDepth(Tex);
    float SmpStep = BackBlurPower(dep) / ViewportSize.x;

    float rate, sumRate = WT_COEF[0];
    float4 Color = WT_COEF[0] *  tex2D( ScnSamp, Tex );

    // ��O�Ɉʒu����T���v���̓��[�g�������ĉ��Z
    [unroll]
    for(int i=1; i<8; i++){
        rate = WT_COEF[i] * BackBlurRate(Tex-float2(SmpStep*i,0), dep);
        sumRate += rate;
        Color += rate * tex2D( ScnSamp, Tex-float2(SmpStep*i,0) );

        rate = WT_COEF[i] * BackBlurRate(Tex+float2(SmpStep*i,0), dep);
        sumRate += rate;
        Color += rate * tex2D( ScnSamp, Tex+float2(SmpStep*i,0) );
    }

    Color /= sumRate;

    return Color;
}


////////////////////////////////////////////////////////////////////////////////////////////////
// ��{�PY����

float4 PS_BackGaussianY(float2 Tex: TEXCOORD0) : COLOR
{
    float dep = GetDepth(Tex);
    float SmpStep = BackBlurPower(dep) / ViewportSize.y;

    float rate, sumRate = WT_COEF[0];
    float4 Color = WT_COEF[0] * tex2D( ScnSamp2, Tex );

    // ��O�Ɉʒu����T���v���̓��[�g�������ĉ��Z
    [unroll]
    for(int i=1; i<8; i++){
        rate = WT_COEF[i] * BackBlurRate(Tex-float2(0,SmpStep*i), dep);
        sumRate += rate;
        Color += rate * tex2D( ScnSamp2, Tex-float2(0,SmpStep*i) );

        rate = WT_COEF[i] * BackBlurRate(Tex+float2(0,SmpStep*i), dep);
        sumRate += rate;
        Color += rate * tex2D( ScnSamp2, Tex+float2(0,SmpStep*i) );
    }

    Color /= sumRate;

    return Color;
}


////////////////////////////////////////////////////////////////////////////////////////////////
// �O�{�P�`��

struct VS_OUTPUT2
{
    float4 Pos    : POSITION;    // �ˉe�ϊ����W
    float2 Tex    : TEXCOORD0;   // �e�N�X�`�����W
    float4 ScnTex : TEXCOORD1;   // �X�N���[���e�N�X�`�����W
};

// ���_�V�F�[�_
VS_OUTPUT2 VS_FrontBlur(float4 Pos : POSITION, float2 Tex : TEXCOORD0)
{
    VS_OUTPUT2 Out=(VS_OUTPUT2)0;

    // �s�N�Z���{�[�h�̃C���f�b�N�X
    int Index = round( Pos.z * 100.0f ) + RepertIndex * 4096;
    int i = mod(Index, ViewportSizeF.x);
    int j = div(Index, ViewportSizeF.x);

    // �s�N�Z���{�[�h�̃��[�J�����W
    Pos.x = 2.0f * (Tex.x - 0.5f) / ViewportSizeF.x;
    Pos.y = 2.0f * (0.5f - Tex.y) / ViewportSizeF.y;
    Pos.z = 0.0f;

    // �s�N�Z���{�[�h�̃X�N���[�����W
    float2 texCoord = float2(0.5f+i, 0.5f+j) / ViewportSizeF;
    float2 Pos0 = (2.0f * texCoord - 1.0f) * float2(1,-1);

    // �O�{�P�p���K�����ꂽ�[�x
    float dep = GetDepthF(texCoord);

    // �s�N�Z���{�[�h�g�嗦
    float scale = GetDepthScale(texCoord, ViewportSizeF.y, 0);
    scale = abs( scale );
    scale *= step(j, ViewportSizeF.y) * step(0.00001f, dep);
    Pos.xy *= scale;

    // �X�N���[�����W�Ɉړ�
    Out.Pos.xy = Pos.xy + Pos0;
    Out.Pos.zw = float2(0, 1);

    // �X�N���[���e�N�X�`�����W
    Out.ScnTex.xy = texCoord;
    Out.ScnTex.z = 1.0f / scale; // z�Ƀs�N�Z���F�̕t�^��
    Out.ScnTex.w = 2.0f * scale - 1.0f; // ��𑜓x���̓��{�𑜓x���Z�X�P�[��

    // �s�N�Z���{�[�h�e�N�X�`�����W
    Out.Tex = Tex + float2(0.5f, 0.5f) / scale;

    return Out;
}


struct PS_OUTPUT
{
    float4 Color  : COLOR0;  // �X�N���[���̐F
    float4 Weight : COLOR1;  // �E�F�C�g
};

// �s�N�Z���V�F�[�_
PS_OUTPUT PS_FrontBlur( VS_OUTPUT2 IN )
{
    PS_OUTPUT Out=(PS_OUTPUT)0;

    // �X�N���[���̐F
    float4 Color = tex2D(ScnSamp, IN.ScnTex.xy);

    // �i��`��̃}�X�N
    float Mask = tex2D(DestMaskSmp, IN.Tex).r;

    // ���̃s�N�Z���ւ̉e���x(�E�F�C�g)
    float Weight = sqrt(IN.ScnTex.z) * Mask;
    //float x = length(IN.Tex * 2.0f - 1.0f);
    //float Weight = IN.ScnTex.z * Mask * (0.1f + 0.9f * exp(-x*x/0.18f));

    #if MODE_HQ==1
        // ��𑜓x�ł͗֊s�������̂łڂ���
        float2 SmpStep = float2(1,1)/ViewportSize;
        Color += Color;
        Color += tex2D( ScnSamp, IN.ScnTex.xy+SmpStep*float2( 0,-1) );
        Color += tex2D( ScnSamp, IN.ScnTex.xy+SmpStep*float2( 0, 1) );
        Color += tex2D( ScnSamp, IN.ScnTex.xy+SmpStep*float2(-1, 0) );
        Color += tex2D( ScnSamp, IN.ScnTex.xy+SmpStep*float2( 1, 0) );
        Color += tex2D( ScnSamp, IN.ScnTex.xy+SmpStep*float2(-1,-1) );
        Color += tex2D( ScnSamp, IN.ScnTex.xy+SmpStep*float2( 1,-1) );
        Color += tex2D( ScnSamp, IN.ScnTex.xy+SmpStep*float2(-1, 1) );
        Color += tex2D( ScnSamp, IN.ScnTex.xy+SmpStep*float2( 1, 1) );
        Color *= 0.1f;
    #endif

    // �X�N���[���F���E�F�C�g�t���ŉ��Z����
    Out.Color = Color * Weight;
    #if MODE_HQ==0
    Out.Weight = float4(Weight, 0, 0, 1);
    #else
    Out.Weight = float4(Weight, IN.ScnTex.w, 1, 1);
    #endif

    return Out;
}


////////////////////////////////////////////////////////////////////////////////////////////////
// �X�N���[���o�b�t�@�̍���

float4 PS_MixScreen( float2 Tex: TEXCOORD0 ) : COLOR
{
    // ���̃X�N���[���F(��{�P�����ς�)
    float4 Color = tex2D(ScnSamp, Tex);
    // �O�{�P�p�o�b�t�@�̐F
    float4 ColorF = tex2D( ScnSampF, Tex );
    // �O�{�P�p�o�b�t�@�̃E�F�C�g
    float Weight = tex2D( WeightSampF, Tex ).r;
    // �O�{�P�p�[�x
    float dep = GetDepthF(Tex);

    // �O�{�P�ȊO�̉ӏ�������
    #if MODE_HQ==0
    if(dep <= 0.00001f){
        ColorF += Color;
        Weight += 1.0f;
    }
    #else
    if(dep < 0.001f || Weight == 0.0f){
        ColorF += Color*0.8f;
        Weight += 0.8f;
    }
    #endif

    // �X�N���[���F�̉��d����
    Color.rgb = ColorF.rgb / max(Weight, 0.0001f);
    Color.a = 1.0f;

    return Color;
}


#if MODE_HQ==1
// ��𑜓x�����ł͗֊s�������̂łڂ���
float4 PS_MixScreen2( float2 Tex: TEXCOORD0 ) : COLOR
{
    float4 Color = tex2D(ScnSamp2, Tex);

    float4 Info = tex2D( WeightSampF, Tex );
    float Weight = Info.r;
    float Scale = Info.g / max(Info.b, 0.5f); // �O�{�P���ϊg�嗦

    if(Weight > 0.0f){
        float2 SmpStep = float2(1,1)/ViewportSize;
        Color += Color;
        Color += tex2D( ScnSamp2, Tex+SmpStep*float2( 0,-1) );
        Color += tex2D( ScnSamp2, Tex+SmpStep*float2( 0, 1) );
        Color += tex2D( ScnSamp2, Tex+SmpStep*float2(-1, 0) );
        Color += tex2D( ScnSamp2, Tex+SmpStep*float2( 1, 0) );
        Color += tex2D( ScnSamp2, Tex+SmpStep*float2(-1,-1) );
        Color += tex2D( ScnSamp2, Tex+SmpStep*float2( 1,-1) );
        Color += tex2D( ScnSamp2, Tex+SmpStep*float2(-1, 1) );
        Color += tex2D( ScnSamp2, Tex+SmpStep*float2( 1, 1) );
        Color *= 0.1f;

        // �g�嗦1�`2�Ԃ͌��摜�Ƃ̐��`���
        #ifndef MIKUMIKUMOVING
        if(Scale < 2.0f){
            Scale = saturate(Scale - 1.0f);
            Color = Color * Scale + tex2D(ScnSamp, Tex) * (1.0f-Scale);
        }
        #else
        if(Scale < 4.0f){
            Scale = saturate((Scale - 1.0f) / 3.0f);
            Color = Color * Scale + tex2D(ScnSamp, Tex) * (1.0f-Scale);
        }
        #endif
    }

    return Color;
}
#endif


#if UseMLAA==1
////////////////////////////////////////////////////////////////////////////////////////////////
// �֊s���o

float4 PS_PickupOutline( float2 Tex: TEXCOORD0 ) : COLOR
{
    // �[�x
    float dep0 = GetDepth( Tex );
    float depL = GetDepth( Tex-float2(AASmpStep.x,0) );
    float depR = GetDepth( Tex+float2(AASmpStep.x,0) );
    float depB = GetDepth( Tex+float2(0,AASmpStep.y) );
    float depT = GetDepth( Tex-float2(0,AASmpStep.y) );

    // ��ʊE�[�x�̌�[�̋��E���o
    float bflagL = (dep0 > FocusFar && FocusFar >= depL);
    float bflagR = (dep0 > FocusFar && FocusFar >= depR);
    float bflagB = (dep0 > FocusFar && FocusFar >= depB);
    float bflagT = (dep0 > FocusFar && FocusFar >= depT);

    return float4(bflagL, bflagR, bflagB, bflagT);
}

////////////////////////////////////////////////////////////////////////////////////////////////
// MLAA�@�ɂ��A���`�G�C���A�V���O����

// ���E�F�̃u�����h
float4 AAColorBlend(float4 color0, float4 color1, float4 color2, float2 linePt1, float2 linePt2)
{
    float s = 0.0f;

    if(linePt1.y * linePt2.y == 0.0f){
        // L�^���E�̏���
        float x1 = (linePt1.y == 0.0f) ? max(linePt1.x, linePt2.x-SAMP_NUM-1) : linePt1.x;
        float x2 = (linePt2.y == 0.0f) ? min(linePt2.x, linePt1.x+SAMP_NUM+1) : linePt2.x;
        float h1 = lerp(linePt1.y, linePt2.y, (-0.5f-x1)/(x2-x1));
        float h2 = lerp(linePt1.y, linePt2.y, ( 0.5f-x1)/(x2-x1));
        if(h1 >= 0.0f && h2 >= 0.0f){
            s = 0.5f * (h1 + h2);
        }else if(h1 > 0.0f){
            s = 0.25f * h1;
        }else if(h2 > 0.0f){
            s = 0.25f * h2;
        }
    }else if(linePt1.y * linePt2.y < 0.0f){
        // Z�^���E�̏���
        float h1 = lerp(linePt1.y, linePt2.y, (-0.5f-linePt1.x)/(linePt2.x-linePt1.x));
        float h2 = lerp(linePt1.y, linePt2.y, ( 0.5f-linePt1.x)/(linePt2.x-linePt1.x));
        if(h1 >= 0.0f && h2 >= 0.0f){
            s = 0.5f * (h1 + h2);
        }else if(h1 > 0.0f){
            s = 0.25f * h1;
        }else if(h2 > 0.0f){
            s = 0.25f * h2;
        }
    }else if(linePt1.y > 0.0f && linePt2.y > 0.0f){
        // U�^���E�̏���
        float h1, h2;
        float x0 = (linePt1.x + linePt2.x) * 0.5f;
        if(x0 >= 0.5f){
            h1 = lerp(linePt1.y, 0.0f, (-0.5f-linePt1.x)/(x0-linePt1.x));
            h2 = lerp(linePt1.y, 0.0f, ( 0.5f-linePt1.x)/(x0-linePt1.x));
            s = 0.5f * (h1 + h2);
        }else if(x0 <= -0.5f){
            h1 = lerp(0.0f, linePt2.y, (-0.5f-x0)/(linePt2.x-x0));
            h2 = lerp(0.0f, linePt2.y, ( 0.5f-x0)/(linePt2.x-x0));
            s = 0.5f * (h1 + h2);
        }else{
            h1 = lerp(linePt1.y, 0.0f, (-0.5f-linePt1.x)/(-linePt1.x));
            h2 = lerp(0.0f, linePt2.y,   0.5f           /( linePt2.x));
            s = 0.25f * (h1 + h2);
        }
    }

    color1 = (color1 - color2 * s) / (1.0f - s); // �u�����h�F��AA�O�̐F�ɖ߂�

    return lerp(color0, color1, s);
}


// LeftRight���E��AA����
float4 PS_MLAA_LeftRight(float2 Tex: TEXCOORD0) : COLOR
{
    float4 Color   = tex2D( ScnSamp, Tex );
    float4 colorL1 = tex2D( ScnSamp, Tex-float2(AASmpStep.x  ,0) );
    float4 colorL2 = tex2D( ScnSamp, Tex-float2(AASmpStep.x*2,0) );
    float4 colorR1 = tex2D( ScnSamp, Tex+float2(AASmpStep.x  ,0) );
    float4 colorR2 = tex2D( ScnSamp, Tex+float2(AASmpStep.x*2,0) );

    float4 bflag = tex2D( OutlineMapSamp, Tex ); // �֊s�t���O

    // Left���E��AA����
    if(bflag.x > 0.5f){
        // Left���E�̃W���M�[�`����
        float4 bflag0, bflagL;
        float2 linePt1 = float2(-0.5f-SAMP_NUM, 0.0f);
        float2 linePt2 = float2( 0.5f+SAMP_NUM, 0.0f);
        [unroll] //���[�v�W�J
        for(int i=SAMP_NUM; i>=0; i--){
            bflag0 = tex2D( OutlineMapSamp, Tex+float2( 0          , AASmpStep.y*i) );
            bflagL = tex2D( OutlineMapSamp, Tex+float2(-AASmpStep.x, AASmpStep.y*i) );
            if(bflag0.x < 0.5f){
                linePt1 = float2( 0.5f-i, 0.0f);
            }else if(bflag0.z > 0.5f){
                linePt1 = float2(-0.5f-i, 0.5f);
            }else if(bflagL.z > 0.5f){
                linePt1 = float2(-0.5f-i,-0.5f);
            }

            bflag0 = tex2D( OutlineMapSamp, Tex+float2( 0          ,-AASmpStep.y*i) );
            bflagL = tex2D( OutlineMapSamp, Tex+float2(-AASmpStep.x,-AASmpStep.y*i) );
            if(bflag0.x < 0.5f){
                linePt2 = float2(-0.5f+i, 0.0f);
            }else if(bflag0.w > 0.5f){
                linePt2 = float2( 0.5f+i, 0.5f);
            }else if(bflagL.w > 0.5f){
                linePt2 = float2( 0.5f+i,-0.5f);
            }
        }
        // Left���E�F�u�����h
        Color = AAColorBlend(Color, colorL1, colorL2, linePt1, linePt2);
    }

    // Right���E��AA����
    if(bflag.y > 0.5f){
        // Right���E�̃W���M�[�`����
        float4 bflag0, bflagR;
        float2 linePt1 = float2(-0.5f-SAMP_NUM, 0.0f);
        float2 linePt2 = float2( 0.5f+SAMP_NUM, 0.0f);
        [unroll] //���[�v�W�J
        for(int i=SAMP_NUM; i>=0; i--){
            bflag0 = tex2D( OutlineMapSamp, Tex+float2( 0          , AASmpStep.y*i) );
            bflagR = tex2D( OutlineMapSamp, Tex+float2( AASmpStep.x, AASmpStep.y*i) );
            if(bflag0.y < 0.5f){
                linePt1 = float2( 0.5f-i, 0.0f);
            }else if(bflag0.z > 0.5f){
                linePt1 = float2(-0.5f-i, 0.5f);
            }else if(bflagR.z > 0.5f){
                linePt1 = float2(-0.5f-i,-0.5f);
            }

            bflag0 = tex2D( OutlineMapSamp, Tex+float2( 0          ,-AASmpStep.y*i) );
            bflagR = tex2D( OutlineMapSamp, Tex+float2( AASmpStep.x,-AASmpStep.y*i) );
            if(bflag0.y < 0.5f){
                linePt2 = float2(-0.5f+i, 0.0f);
            }else if(bflag0.w > 0.5f){
                linePt2 = float2( 0.5f+i, 0.5f);
            }else if(bflagR.w > 0.5f){
                linePt2 = float2( 0.5f+i,-0.5f);
            }
        }
        // Right���E�F�u�����h
        Color = AAColorBlend(Color, colorR1, colorR2, linePt1, linePt2);
    }

    return Color;
}


// BottomTop���E��AA����
float4 PS_MLAA_BottomTop(float2 Tex: TEXCOORD0) : COLOR
{
    float4 Color   = tex2D( ScnSamp2, Tex );
    float4 colorB1 = tex2D( ScnSamp2, Tex+float2(0,AASmpStep.y  ) );
    float4 colorB2 = tex2D( ScnSamp2, Tex+float2(0,AASmpStep.y*2) );
    float4 colorT1 = tex2D( ScnSamp2, Tex-float2(0,AASmpStep.y  ) );
    float4 colorT2 = tex2D( ScnSamp2, Tex-float2(0,AASmpStep.y*2) );

    float4 bflag = tex2D( OutlineMapSamp, Tex ); // �֊s�t���O

    // Bottom���E��AA����
    if(bflag.z > 0.5f){
        // Bottom���E�̃W���M�[�`����
        float4 bflag0, bflagB;
        float2 linePt1 = float2(-0.5f-SAMP_NUM, 0.0f);
        float2 linePt2 = float2( 0.5f+SAMP_NUM, 0.0f);
        [unroll] //���[�v�W�J
        for(int i=SAMP_NUM; i>=0; i--){
            bflag0 = tex2D( OutlineMapSamp, Tex+float2(-AASmpStep.x*i, 0          ) );
            bflagB = tex2D( OutlineMapSamp, Tex+float2(-AASmpStep.x*i, AASmpStep.y) );
            if(bflag0.z < 0.5f){
                linePt1 = float2( 0.5f-i, 0.0f);
            }else if(bflag0.x > 0.5f){
                linePt1 = float2(-0.5f-i, 0.5f);
            }else if(bflagB.x > 0.5f){
                linePt1 = float2(-0.5f-i,-0.5f);
            }

            bflag0 = tex2D( OutlineMapSamp, Tex+float2( AASmpStep.x*i, 0          ) );
            bflagB = tex2D( OutlineMapSamp, Tex+float2( AASmpStep.x*i, AASmpStep.y) );
            if(bflag0.z < 0.5f){
                linePt2 = float2(-0.5f+i, 0.0f);
            }else if(bflag0.y > 0.5f){
                linePt2 = float2( 0.5f+i, 0.5f);
            }else if(bflagB.y > 0.5f){
                linePt2 = float2( 0.5f+i,-0.5f);
            }
        }
        // Bottom���E�F�u�����h
        Color = AAColorBlend(Color, colorB1, colorB2, linePt1, linePt2);
    }

    // Top���E��AA����
    if(bflag.w > 0.5f){
        // Top���E�̃W���M�[�`����
        float4 bflag0, bflagT;
        float2 linePt1 = float2(-0.5f-SAMP_NUM, 0.0f);
        float2 linePt2 = float2( 0.5f+SAMP_NUM, 0.0f);
        [unroll] //���[�v�W�J
        for(int i=SAMP_NUM; i>=0; i--){
            bflag0 = tex2D( OutlineMapSamp, Tex+float2(-AASmpStep.x*i, 0          ) );
            bflagT = tex2D( OutlineMapSamp, Tex+float2(-AASmpStep.x*i, AASmpStep.y) );
            if(bflag0.w < 0.5f){
                linePt1 = float2( 0.5f-i, 0.0f);
            }else if(bflag0.x > 0.5f){
                linePt1 = float2(-0.5f-i, 0.5f);
            }else if(bflagT.x > 0.5f){
                linePt1 = float2(-0.5f-i,-0.5f);
            }

            bflag0 = tex2D( OutlineMapSamp, Tex+float2( AASmpStep.x*i, 0          ) );
            bflagT = tex2D( OutlineMapSamp, Tex+float2( AASmpStep.x*i, AASmpStep.y) );
            if(bflag0.w < 0.5f){
                linePt2 = float2(-0.5f+i, 0.0f);
            }else if(bflag0.y > 0.5f){
                linePt2 = float2( 0.5f+i, 0.5f);
            }else if(bflagT.y > 0.5f){
                linePt2 = float2( 0.5f+i,-0.5f);
            }
        }
        // Top���E�F�u�����h
        Color = AAColorBlend(Color, colorT1, colorT2, linePt1, linePt2);
    }

    return Color;
    //return tex2D( OutlineMapSamp, Tex );
}

#endif

////////////////////////////////////////////////////////////////////////////////////////////////
// �I�[�g�t�H�[�J�X�̍��ŋ����v�Z

// ���ʂ̒��_�V�F�[�_
VS_OUTPUT VS_FocusDepth(float4 Pos : POSITION, float2 Tex: TEXCOORD)
{
    VS_OUTPUT Out = (VS_OUTPUT)0; 

    Out.Pos = Pos;
    Out.Tex = Tex + float2(0.5f, 0.5f);

    return Out;
}

// �[�x�X�V
float4 PS_FocusDepth(float2 Tex: TEXCOORD0) : COLOR
{
    // �I�u�W�F�N�g�̐[�x
    float4 Pos = tex2D(AutoFocusSmp, Tex);
    if( time < 0.001f ){
        // 0�t���[���Đ��Ń��Z�b�g
        float dep = GetDepth( AutoFocusPos );
        Pos = float4(dep, dep, 0, 0);
    }
    float dep1 = Pos.x;  // ���݂̐[�x
    float dep2 = Pos.y;  // 1�t���[���O�̐[�x

    // 1�t���[���̎��ԊԊu
    float Dt = clamp(time - Pos.z, 0.001f, 0.05f);

    // �[�x�ύX���x
    float Vel = ( dep1  - dep2 ) / Dt;

    // �[�x�}�b�v�̒l
    float dep0 = GetDepth( AutoFocusPos );

    // �����x�v�Z(�e����+���x��R��)
    float Accel = sign(dep0 - dep1) * min(abs(dep0 - dep1), clamp(35000.0f/dep0, 50.0f, 1000.0f))
                  * AF_ElasticFactor - Vel * AF_ResistFactor;
    if(Accel > 0.0f && Vel > 0.0f){
        Accel *= 0.2f + 0.8f * smoothstep(30.0f, 150.0f, dep1);
    }

    // �V�����[�x�ɍX�V
    dep2 = dep1;
    dep1 += Dt * (Vel + Dt * Accel);

    //return float4(dep0, dep0, 0, 0);
    return float4(dep1, dep2, time, 0);
}


////////////////////////////////////////////////////////////////////////////////////////////////
// �e�N�j�b�N

technique MainTech <
    string Script = 
        // �I���W�i���̕`��
        "RenderColorTarget0=ScnMap;"
            "RenderDepthStencilTarget=DepthBuffer;"
            "ClearSetColor=ClearColor;"
            "ClearSetDepth=ClearDepth;"
            "Clear=Color;"
            "Clear=Depth;"
            "ScriptExternal=Color;"

        "LoopByCount=flagAF;"
            // �I�[�g�t�H�[�J�X�̍��ŋ����v�Z
            "RenderColorTarget0=AutoFocusTex;"
                "RenderDepthStencilTarget=AutoFocusDepthBuffer;"
                "Pass=FocusUpdate;"
        "LoopEnd=;"

        "LoopByCount=RepertCount;"
        "LoopGetIndex=RepertIndex;"
            // ��{�P����
            "RenderColorTarget0=ScnMap2;"
                "RenderDepthStencilTarget=DepthBuffer;"
                "ClearSetColor=ClearColor;"
                "ClearSetDepth=ClearDepth;"
                "Clear=Color;"
                "Clear=Depth;"
                "Pass=BackGaussian_X;"
            "RenderColorTarget0=ScnMap;"
                "RenderDepthStencilTarget=DepthBuffer;"
                "ClearSetColor=ClearColor;"
                "ClearSetDepth=ClearDepth;"
                "Clear=Color;"
                "Clear=Depth;"
                "Pass=BackGaussian_Y;"
        "LoopEnd=;"

        #if UseMLAA==1
        // ��ʊE�[�x�̌�[�̃A���`�G�C���A�V���O����
        "RenderColorTarget0=OutlineMap;"
        "RenderDepthStencilTarget=DepthBuffer;"
            "ClearSetColor=ClearColor;"
            "ClearSetDepth=ClearDepth;"
            "Clear=Color;"
            "Clear=Depth;"
            "Pass=PickupOutline;"
        "RenderColorTarget0=ScnMap2;"
        "RenderDepthStencilTarget=DepthBuffer;"
            "ClearSetColor=ClearColor;"
            "ClearSetDepth=ClearDepth;"
            "Clear=Color;"
            "Clear=Depth;"
            "Pass=MLAA_LeftRight;"
        "RenderColorTarget0=ScnMap;"
            "RenderDepthStencilTarget=DepthBuffer;"
            "ClearSetColor=ClearColor;"
            "ClearSetDepth=ClearDepth;"
            "Clear=Color;"
            "Clear=Depth;"
            "Pass=MLAA_BottomTop;"
        #endif

        //  �O�{�P����
        "RenderColorTarget0=ScnMapF;"
        "RenderColorTarget1=WeightMapF;"
            "RenderDepthStencilTarget=DepthBufferF;"
            "ClearSetColor=ClearColorF;"
            "ClearSetDepth=ClearDepth;"
            "Clear=Color;"
            "Clear=Depth;"
            "LoopByCount=RepertCountF;"
            "LoopGetIndex=RepertIndex;"
                "Pass=FrontDrawPass;"
            "LoopEnd=;"
        "RenderColorTarget0=ScnMapF;"
        "RenderColorTarget1=;"
            "Clear=Depth;"

        // �`�挋�ʍ����E�����o��
        #if MODE_HQ==0
        "RenderColorTarget0=;"
            "RenderDepthStencilTarget=;"
            "Pass=MixPass;"
        #else
        "RenderColorTarget0=ScnMap2;"
            "RenderDepthStencilTarget=DepthBuffer;"
            "Pass=MixPass;"
        "RenderColorTarget0=;"
            "RenderDepthStencilTarget=;"
            "Pass=MixPass2;"
        #endif
    ; >
{
    pass FocusUpdate < string Script = "Draw=Buffer;";>
    {
        ALPHABLENDENABLE = FALSE;
        ALPHATESTENABLE=FALSE;
        VertexShader = compile vs_1_1 VS_FocusDepth();
        PixelShader  = compile ps_2_0 PS_FocusDepth();
    }
    pass BackGaussian_X < string Script= "Draw=Buffer;"; > {
        AlphaBlendEnable = FALSE;
        AlphaTestEnable = FALSE;
        VertexShader = compile vs_3_0 VS_Common();
        PixelShader  = compile ps_3_0 PS_BackGaussianX();
    }
    pass BackGaussian_Y < string Script= "Draw=Buffer;"; > {
        AlphaBlendEnable = FALSE;
        AlphaTestEnable = FALSE;
        VertexShader = compile vs_3_0 VS_Common();
        PixelShader  = compile ps_3_0 PS_BackGaussianY();
    }
    #if UseMLAA==1
    pass PickupOutline < string Script= "Draw=Buffer;"; > {
        AlphaBlendEnable = FALSE;
        AlphaTestEnable = FALSE;
        VertexShader = compile vs_3_0 VS_Common();
        PixelShader  = compile ps_3_0 PS_PickupOutline();
    }
    pass MLAA_LeftRight < string Script= "Draw=Buffer;"; > {
        AlphaBlendEnable = FALSE;
        AlphaTestEnable = FALSE;
        VertexShader = compile vs_3_0 VS_Common();
        PixelShader  = compile ps_3_0 PS_MLAA_LeftRight();
    }
    pass MLAA_BottomTop < string Script= "Draw=Buffer;"; > {
        AlphaBlendEnable = FALSE;
        AlphaTestEnable = FALSE;
        VertexShader = compile vs_3_0 VS_Common();
        PixelShader  = compile ps_3_0 PS_MLAA_BottomTop();
    }
    #endif
    pass FrontDrawPass < string Script= "Draw=Geometry;"; > {
        ZEnable = FALSE;
        CullMode = NONE;
        AlphaBlendEnable = TRUE;
        AlphaTestEnable = FALSE;
        DestBlend = ONE;
        SrcBlend = ONE;
        VertexShader = compile vs_3_0 VS_FrontBlur();
        PixelShader  = compile ps_3_0 PS_FrontBlur();
    }
    pass MixPass < string Script= "Draw=Buffer;"; > {
        AlphaBlendEnable = FALSE;
        AlphaTestEnable = FALSE;
        VertexShader = compile vs_3_0 VS_Common();
        PixelShader  = compile ps_3_0 PS_MixScreen();
    }
    #if MODE_HQ==1
    pass MixPass2 < string Script= "Draw=Buffer;"; > {
        AlphaBlendEnable = FALSE;
        AlphaTestEnable = FALSE;
        VertexShader = compile vs_3_0 VS_Common();
        PixelShader  = compile ps_3_0 PS_MixScreen2();
    }
    #endif
}


////////////////////////////////////////////////////////////////////////////////////////////////
