////////////////////////////////////////////////////////////////////////////////////////////////
//
//  PowerDOF.fx ver0.0.5  ��ʊE�[�x�G�t�F�N�g
//  �쐬: �j��P( ���͉��P����Gaussian.fx���� )
//
////////////////////////////////////////////////////////////////////////////////////////////////
// �p�����[�^�X�C�b�`

#define FrontPowerBlur  0   // �O�{�P�̂ڂ������@
// 0 : �`�摬�x�D��A�����ڂ������|����ƎȖ͗l���o�܂��B
// 1 : ���Ȃ苭�͂Ȃڂ��������ꂢ�|�����܂����`�摬�x�͗�����B


#define UseHDR  0   // HDR�����_�����O�̗L��
// 0 : �ʏ��256�K���ŏ���
// 1 : ���Ɠx�������̂܂܏����A�ڂ������Ƃ���ɃO���A���ʂ��o��B


#define UseMLAA  0   // MLAA�@�ɂ���ʑ̂̃A���`�G�C���A�V���O����
// 0 : �������Ȃ��A�`�摬�x�D��A��{�P�ƃs���g����������ʑ̂̋��E�ɃW���M�[���o��B
// 1 : ��������A��ʑ̂̋��E�͂��ꂢ�ɂȂ邪�`�摬�x�͗�����B



// ����Ȃ��l�͂������牺�͂�����Ȃ��ł�

////////////////////////////////////////////////////////////////////////////////////////////////
// �p�����[�^�錾

float Script : STANDARDSGLOBAL <
    string ScriptOutput = "color";
    string ScriptClass = "scene";
    string ScriptOrder = "postprocess";
> = 0.8;

#ifndef MIKUMIKUMOVING
    #define OFFSCREEN_FX    "PDOF_Depth.fxsub"
    #define MLAA_TEX_FORMAT "D3DFMT_A4R4G4B4"
    #define AF_PAPAM1        100.0f
    #define AF_PAPAM2        20.0f
    #define COEF_BLUR_POWER  1.0f
#else
    #define OFFSCREEN_FX    "PDOF_DepthMMM.fxsub"
    #define MLAA_TEX_FORMAT "D3DFMT_A8R8G8B8"
    #define AF_PAPAM1        10.0f
    #define AF_PAPAM2        10.0f
    #define COEF_BLUR_POWER  0.5f
#endif

#if FrontPowerBlur==1
    #define FRONT_RERERT_COUNT  3
    #define FRONT_MIPLEVEL      1
    #define FRONT_MIPFILTER     NONE
#else
    #define FRONT_RERERT_COUNT  1
    #define FRONT_MIPLEVEL      0
    #define FRONT_MIPFILTER     LINEAR
#endif

float AcsSi : CONTROLOBJECT < string name = "(self)"; string item = "Si"; >;
float AcsTr : CONTROLOBJECT < string name = "(self)"; string item = "Tr"; >;

#define AF_FLIENAME   "PDOF_AutoFocus.x"
bool flagAF : CONTROLOBJECT < string name = AF_FLIENAME; >;
float AcsX  : CONTROLOBJECT < string name = AF_FLIENAME; string item = "X"; >;
float AcsY  : CONTROLOBJECT < string name = AF_FLIENAME; string item = "Y"; >;
float AcsRx : CONTROLOBJECT < string name = AF_FLIENAME; string item = "Rx"; >;
float AcsRy : CONTROLOBJECT < string name = AF_FLIENAME; string item = "Ry"; >;
static float AF_ElasticFactor = clamp(AF_PAPAM1 + degrees(AcsRx), 1.0f, 1000.0f);  // �I�[�g�t�H�[�J�X���ŋ����Ǐ]�̒e���x
static float AF_ResistFactor  = clamp(AF_PAPAM2 + degrees(AcsRy), 0.1f, 100.0f);   // �I�[�g�t�H�[�J�X���ŋ����Ǐ]�̒�R�x

float time : TIME;

int RepertCount = 3;  // �`�攽����
int RepertCountF = FRONT_RERERT_COUNT;  // �O�{�P�`�攽����
int RepertIndex;      // �`�攽���񐔂̃J�E���^

#define DEPTH_FAR   5000.0f  // �[�x�ŉ��l
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

// �X�N���[���T�C�Y
float2 ViewportSize : VIEWPORTPIXELSIZE;
static float2 ViewportOffset = (float2(0.5,0.5)/ViewportSize);
static float2 AASmpStep = float2(1,1) / ViewportSize;

// ���W�p�����[�^
float4x4 WorldMatrix  : WORLD;
float4x4 ProjMatrix   : PROJECTION;
float3 CameraPosition : POSITION  < string Object = "Camera"; >;

// �J��������̃p�[�X�y�N�e�B�u�t���O
static bool IsParth = ProjMatrix._44 < 0.5f;

// �[�x�}�b�v�`���I�t�X�N���[���o�b�t�@
texture PDOF_DepthRT : OFFSCREENRENDERTARGET <
    string Description = "OffScreen RenderTarget for PowerDOF.fx";
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
    texture = <PDOF_DepthRT>;
    MinFilter = POINT;
    MagFilter = POINT;
    MipFilter = NONE;
    AddressU  = CLAMP;
    AddressV  = CLAMP;
};

// �����_�����O�^�[�Q�b�g�̃N���A�l
float4 ClearColor = {1,1,1,0};
float ClearDepth  = 1.0f;

#if UseHDR==0
    #define TEX_FORMAT "D3DFMT_A8R8G8B8"
#else
    #define TEX_FORMAT "D3DFMT_A16B16G16R16F"
    //#define TEX_FORMAT "D3DFMT_A32B32G32R32F"
#endif

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
    string Format = "D24S8";
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

// �O�{�P�`�挋�ʂ��L�^���邽�߂̃����_�[�^�[�Q�b�g
texture2D ScnMap3 : RENDERCOLORTARGET <
    float2 ViewPortRatio = {1.0,1.0};
    int MipLevels = FRONT_MIPLEVEL;
    string Format = TEX_FORMAT;
>;
sampler2D ScnSamp3 = sampler_state {
    texture = <ScnMap3>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = FRONT_MIPFILTER;
    AddressU  = CLAMP;
    AddressV  = CLAMP;
};

// �O�{�P�p�[�x�}�b�v���L�^���邽�߂̃����_�[�^�[�Q�b�g
texture DepthMapBuff : RENDERCOLORTARGET <
    float2 ViewPortRatio = {1.0,1.0};
    int MipLevels = 1;
    string Format = "D3DFMT_R32F";
>;
sampler DepthMapBuffSmp = sampler_state {
    texture = <DepthMapBuff>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = NONE;
    AddressU  = CLAMP;
    AddressV  = CLAMP;
};

// �O�{�P�p�[�x�}�b�v��X�����̂ڂ������ʂ��L�^���邽�߂̃����_�[�^�[�Q�b�g
texture DepthMapBuff2 : RENDERCOLORTARGET <
    float2 ViewPortRatio = {1.0,1.0};
    int MipLevels = 1;
    string Format = "D3DFMT_R32F";
>;
sampler DepthMapBuffSmp2 = sampler_state {
    texture = <DepthMapBuff2>;
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
    string Format = MLAA_TEX_FORMAT;
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
   string Format="A32B32G32R32F";
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
    string Format = "D24S8";
>;


// ���w�p�����[�^(�K��)
static float3 FocusPos = WorldMatrix._41_42_43;   // �}�j���A���t�H�[�J�X�̍��ňʒu
static float2 AutoFocusPos = saturate( float2(0.5f+0.5f*AcsX, 0.5f-0.5f*AcsY) ); // �I�[�g�t�H�[�J�X����X�N���[�����W
static float FocusDistance = flagAF ? tex2D(AutoFocusSmp, float2(0.5f,0.5f)).x : length(FocusPos - CameraPosition); // ���ŋ���
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

// �O�{�P�p�[�x�}�b�v�̂ڂ������x
float DepthBlurPower()
{
    float dep = 0.9f;
    float dep0 = (1.0f - dep) * FocusDistance;
    float pixLen = DiaphragmVal * dep;
    float viewLen = IsParth ? ProjMatrix._22 / dep0 : max(0.001f/ProjMatrix._11, 0.0001f);
    float blurPower = ViewportSize.y * pixLen * viewLen / 8.0f;
    return blurPower*FocusDistance*0.005f/sqrt(AcsSi*0.1f);
}

// �O�{�P�̂ڂ������x
float FrontBlurPower(float2 Tex)
{
    float dep = tex2D( DepthMapBuffSmp, Tex ).r;
    float dep0 = (1.0f - dep) * FocusDistance;
    float pixLen = DiaphragmVal * dep;
    float viewLen = IsParth ? ProjMatrix._22 / dep0 : max(0.001f/ProjMatrix._11, 0.0001f);
    float blurPower = ViewportSize.y * pixLen * viewLen / 8.0f;
    return blurPower*AcsTr*0.25f/pow(6.0f, RepertIndex);
}


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
// �O�{�P�p�[�x�}�b�v�̐��K��

float4 PS_InitDepth( float2 Tex: TEXCOORD0 ) : COLOR
{
    float dep = max(FocusNear - GetDepth(Tex), 0.0f) / FocusNear;
    return float4(dep, 0, 0, 1);
}


////////////////////////////////////////////////////////////////////////////////////////////////
// �O�{�P�p�[�x�}�b�v�̂ڂ���X����

float4 PS_DepthGaussianX( float2 Tex: TEXCOORD0 ) : COLOR
{
    float SmpStep = DepthBlurPower() / ViewportSize.x;

    //float MipLv = log2( max(ViewportSize.x*SmpStep, 1.0f) );
    float MipLv = 0;

    float dep, sumRate = WT_COEF[0];
    float dep0 = tex2Dlod( DepthMapBuffSmp, float4(Tex,0,MipLv) ).r;
    float sumDep = WT_COEF[0] * dep0;

    // �����ɂ���[�x�̓T���v�����O���Ȃ�
    [unroll]
    for(int i=1; i<8; i++){
        dep = tex2Dlod( DepthMapBuffSmp, float4(Tex.x-SmpStep.x*i,Tex.y,0,MipLv) ).r;
        sumDep += WT_COEF[i] * dep * step(dep0, dep);
        sumRate += WT_COEF[i] * step(dep0, dep);

        dep = tex2Dlod( DepthMapBuffSmp, float4(Tex.x+SmpStep.x*i,Tex.y,0,MipLv) ).r;
        sumDep += WT_COEF[i] * dep * step(dep0, dep);
        sumRate += WT_COEF[i] * step(dep0, dep);
    }

    dep = sumDep / sumRate;
    return float4(dep, 0, 0, 1);
}


////////////////////////////////////////////////////////////////////////////////////////////////
// �O�{�P�p�[�x�}�b�v�̂ڂ���Y����

float4 PS_DepthGaussianY(float2 Tex: TEXCOORD0) : COLOR
{
    float SmpStep = DepthBlurPower() / ViewportSize.y;

    float dep, sumRate = WT_COEF[0];
    float dep0 = tex2D( DepthMapBuffSmp2, Tex ).r;
    float sumDep = WT_COEF[0] * dep0;

    // �����ɂ���[�x�̓T���v�����O���Ȃ�
    [unroll]
    for(int i=1; i<8; i++){
        dep = tex2D( DepthMapBuffSmp2, Tex-float2(0,SmpStep*i) ).r;
        sumDep += WT_COEF[i] * dep * step(dep0, dep);
        sumRate += WT_COEF[i] * step(dep0, dep);

        dep = tex2D( DepthMapBuffSmp2, Tex+float2(0,SmpStep*i) ).r;
        sumDep += WT_COEF[i] * dep * step(dep0, dep);
        sumRate += WT_COEF[i] * step(dep0, dep);
    }

    dep = sumDep / sumRate;
    return float4(dep, 0, 0, 1);
}


////////////////////////////////////////////////////////////////////////////////////////////////
// �O�{�PX����

float4 PS_FrontGaussianX( float2 Tex: TEXCOORD0 ) : COLOR
{
    float SmpStep = FrontBlurPower(Tex) / ViewportSize.x;

    #if FrontPowerBlur==0
    float MipLv = log2( max(ViewportSize.x*SmpStep, 1.0f) );
    #else
    float MipLv = 0;
    #endif

    float4 Color = WT_COEF[0] * tex2Dlod( ScnSamp3, float4(Tex,0,MipLv) );
    [unroll]
    for(int i=1; i<8; i++){
        Color += WT_COEF[i] * ( tex2Dlod( ScnSamp3, float4(Tex.x-SmpStep.x*i,Tex.y,0,MipLv) )
                              + tex2Dlod( ScnSamp3, float4(Tex.x+SmpStep.x*i,Tex.y,0,MipLv) ) );
    }

    return Color;
}


////////////////////////////////////////////////////////////////////////////////////////////////
// �O�{�PY����

float4 PS_FrontGaussianY(float2 Tex: TEXCOORD0) : COLOR
{
    float SmpStep = FrontBlurPower(Tex) / ViewportSize.y;

    float4 Color = WT_COEF[0] * tex2D( ScnSamp2, Tex );
    [unroll]
    for(int i=1; i<8; i++){
        Color += WT_COEF[i] * ( tex2D( ScnSamp2, Tex+float2(0,SmpStep*i) )
                              + tex2D( ScnSamp2, Tex-float2(0,SmpStep*i) ) );
    }

    return Color;
}


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

// �X�N���[���o�b�t�@�̃R�s�[
float4 PS_CopyScreen( float2 Tex: TEXCOORD0 ) : COLOR
{
    return tex2D( ScnSamp, Tex );
}


// �X�N���[���o�b�t�@�̍���
float4 PS_MixScreen( float2 Tex: TEXCOORD0 ) : COLOR
{
    float4 ColorB = tex2D( ScnSamp, Tex );
    float4 ColorF = tex2D( ScnSamp3, Tex );

    float dep = GetDepth(Tex);

    if(dep >= FocusNear){
       float depF = tex2D( DepthMapBuffSmp, Tex ).r;
       float r = clamp(0.1f * AcsSi * sqrt(AcsTr), 0.5f, 100.0f);
       float s = pow( depF, 0.3f*pow(0.45f, log10(r)) );
       ColorF = ColorF * s + ColorB * (1-s);
    }

    return ColorF;
}



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

        // �O�{�P�p�[�x�}�b�v�`��
        "RenderColorTarget0=DepthMapBuff;"
            "RenderDepthStencilTarget=DepthBuffer;"
            "ClearSetColor=ClearColor;"
            "ClearSetDepth=ClearDepth;"
            "Clear=Color;"
            "Clear=Depth;"
            "Pass=DepthInitPass;"

        "LoopByCount=RepertCount;"
        "LoopGetIndex=RepertIndex;"
            // �O�{�P�p�[�x�}�b�v�̂ڂ���
            "RenderColorTarget0=DepthMapBuff2;"
                "RenderDepthStencilTarget=DepthBuffer;"
                "ClearSetColor=ClearColor;"
                "ClearSetDepth=ClearDepth;"
                "Clear=Color;"
                "Clear=Depth;"
                "Pass=DepthGaussian_X;"
            "RenderColorTarget0=DepthMapBuff;"
                "RenderDepthStencilTarget=DepthBuffer;"
                "ClearSetColor=ClearColor;"
                "ClearSetDepth=ClearDepth;"
                "Clear=Color;"
                "Clear=Depth;"
                "Pass=DepthGaussian_Y;"

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

        // �X�N���[���o�b�t�@�̃R�s�[
        "RenderColorTarget0=ScnMap3;"
            "RenderDepthStencilTarget=DepthBuffer;"
            "Pass=FrontCopyPass;"

        "LoopByCount=RepertCountF;"
        "LoopGetIndex=RepertIndex;"
            // �O�{�P����
            "RenderColorTarget0=ScnMap2;"
                "RenderDepthStencilTarget=DepthBuffer;"
                "ClearSetColor=ClearColor;"
                "ClearSetDepth=ClearDepth;"
                "Clear=Color;"
                "Clear=Depth;"
                "Pass=FrontGaussian_X;"
            "RenderColorTarget0=ScnMap3;"
                "RenderDepthStencilTarget=DepthBuffer;"
                "ClearSetColor=ClearColor;"
                "ClearSetDepth=ClearDepth;"
                "Clear=Color;"
                "Clear=Depth;"
                "Pass=FrontGaussian_Y;"
        "LoopEnd=;"

        // �`�挋�ʏ����o��
        "RenderColorTarget0=;"
            "RenderDepthStencilTarget=;"
            "Pass=MixPass;"
    ; >
{
    pass FocusUpdate < string Script = "Draw=Buffer;";>
    {
        ALPHABLENDENABLE = FALSE;
        ALPHATESTENABLE=FALSE;
        VertexShader = compile vs_1_1 VS_FocusDepth();
        PixelShader  = compile ps_2_0 PS_FocusDepth();
    }
    pass DepthInitPass < string Script= "Draw=Buffer;"; > {
        AlphaBlendEnable = FALSE;
        AlphaTestEnable = FALSE;
        VertexShader = compile vs_2_0 VS_Common();
        PixelShader  = compile ps_2_0 PS_InitDepth();
    }
    pass DepthGaussian_X < string Script= "Draw=Buffer;"; > {
        AlphaBlendEnable = FALSE;
        AlphaTestEnable = FALSE;
        VertexShader = compile vs_3_0 VS_Common();
        PixelShader  = compile ps_3_0 PS_DepthGaussianX();
    }
    pass DepthGaussian_Y < string Script= "Draw=Buffer;"; > {
        AlphaBlendEnable = FALSE;
        AlphaTestEnable = FALSE;
        VertexShader = compile vs_3_0 VS_Common();
        PixelShader  = compile ps_3_0 PS_DepthGaussianY();
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
    pass FrontGaussian_X < string Script= "Draw=Buffer;"; > {
        AlphaBlendEnable = FALSE;
        AlphaTestEnable = FALSE;
        VertexShader = compile vs_3_0 VS_Common();
        PixelShader  = compile ps_3_0 PS_FrontGaussianX();
    }
    pass FrontGaussian_Y < string Script= "Draw=Buffer;"; > {
        AlphaBlendEnable = FALSE;
        AlphaTestEnable = FALSE;
        VertexShader = compile vs_3_0 VS_Common();
        PixelShader  = compile ps_3_0 PS_FrontGaussianY();
    }
    pass FrontCopyPass < string Script= "Draw=Buffer;"; > {
        AlphaBlendEnable = FALSE;
        AlphaTestEnable = FALSE;
        VertexShader = compile vs_2_0 VS_Common();
        PixelShader  = compile ps_2_0 PS_CopyScreen();
    }
    pass MixPass < string Script= "Draw=Buffer;"; > {
        AlphaBlendEnable = FALSE;
        AlphaTestEnable = FALSE;
        VertexShader = compile vs_2_0 VS_Common();
        PixelShader  = compile ps_2_0 PS_MixScreen();
    }
}



////////////////////////////////////////////////////////////////////////////////////////////////
