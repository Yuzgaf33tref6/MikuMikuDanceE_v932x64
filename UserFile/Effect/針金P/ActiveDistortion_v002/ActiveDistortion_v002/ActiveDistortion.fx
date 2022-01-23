////////////////////////////////////////////////////////////////////////////////////////////////
//
//  ActiveDistortion.fx ver0.0.2  ��Ԙc�݃G�t�F�N�g
//  �쐬: �j��P
//
////////////////////////////////////////////////////////////////////////////////////////////////
// �����̃p�����[�^��ύX���Ă�������

#define FLAG_DEPTH  1   // �[�x�ɉ����� 1:�c�ݓx�����𒲐�, 0:�c�ݑS��ʋψ�

// �c�݂ڂ������G�ɂȂ鎞�͂������グ��(�����d���Ȃ�܂�)
#define BLUR_COUNT  2   // (Si=0�`2��1, Si=2�`10��2, Si=10�`��3 ���炢���ڈ�)

#define UseHDR  0   // HDR�����_�����O�̗L��
// 0 : �ʏ��256�K���ŏ���
// 1 : ���Ɠx�������̂܂܏���

float3 BlendColor <
   string UIName = "�c�݃u�����h�F";
   string UIHelp = "�c�݂Ƀu�����h����F";
   string UIWidget = "Color";
   bool UIVisible =  true;
   float UIMin = 0.0;
   float UIMax = 1.0;
> = float3(1.0, 1.0, 1.0);

float BlendColorRate <
   string UIName = "�u�����h��";
   string UIHelp = "�F�̃u�����h��";
   string UIWidget = "Slider";
   bool UIVisible =  true;
   float UIMin = 0.0;
   float UIMax = 1.0;
> = float( 0.05 );

float DistPowerMax <
   string UIName = "�c�݋��x";
   string UIHelp = "�c�ݍő勭�x(�ő�l�����߂�Tr�Œ���)";
   string UIWidget = "Slider";
   bool UIVisible =  true;
   float UIMin = 0.0;
   float UIMax = 3.0;
> = float( 0.5 );


// ����Ȃ��l�͂������牺�͂�����Ȃ��ł�

////////////////////////////////////////////////////////////////////////////////////////////////
// �p�����[�^�錾

float Script : STANDARDSGLOBAL <
    string ScriptOutput = "color";
    string ScriptClass = "sceneorobject";
    string ScriptOrder = "postprocess";
> = 0.8;

float BlurPower = 0.05f;  // �c�݂ڂ������x
float BlurPowerB = 5.0f;  // �[�x�}�b�v�c�݂ڂ������x
//float BlurPowerB = 0.0f;  // �[�x�}�b�v�c�݂ڂ������x

float DistBlur <
   string UIName = "�c�݊g�U";
   string UIHelp = "�c�݂̂ڂ����x(�傫������Ƙc�ݕ����}�C���h�ɂȂ�܂�)";
   string UIWidget = "Slider";
   bool UIVisible =  true;
   float UIMin = 0.0;
   float UIMax = 10.0;
> = float( 1.0 );

float AcsSi : CONTROLOBJECT < string name = "(self)"; string item = "Si"; >;
float AcsTr : CONTROLOBJECT < string name = "(self)"; string item = "Tr"; >;

int RepertCount = BLUR_COUNT;  // �`�攽����
int RepertCountB = 2;          // �`�攽����(�[�x�}�b�v)
int RepertIndex;               // �`�攽���񐔂̃J�E���^

#define LOOP_COUNT  8   // �[�x�ɂ��c�ݔ���̃T���v�����O��

// �X�N���[���T�C�Y
float2 ViewportSize : VIEWPORTPIXELSIZE;
static float2 ViewportOffset = float2(0.5,0.5) / ViewportSize;
// �T���v�����O�Ԋu
static float2 SampStep  = (float2(1,1) / ViewportSize) * AcsSi * DistBlur * BlurPower / pow(6.0f, RepertIndex);
static float2 SampStepB = (float2(1,1) / ViewportSize) * BlurPowerB / pow(6.0f, RepertIndex);
static float2 SampStep1 = float2(2,2) / ViewportSize;
static float2 SampStep0 = float2(1,1) / ViewportSize;

#define DEPTH_FAR   5000.0f  // �[�x�ŉ��l

#ifndef MIKUMIKUMOVING
    #define OFFSCREEN_MASK  "AD_Mask.fxsub"
#else
    #define OFFSCREEN_MASK  "AD_MaskMMM.fxsub"
#endif


//#define TEX_FORMAT "D3DFMT_A16B16G16R16F"
#define TEX_FORMAT "D3DFMT_A32B32G32R32F"

// �I�t�X�N���[���@���E�[�x�}�b�v
texture DistortionRT: OFFSCREENRENDERTARGET <
    string Description = "ActiveDistortion.fx�̖@���E�[�x�}�b�v, ������AD_�`.fx��K�p";
    float2 ViewPortRatio = {1.0, 1.0};
    float4 ClearColor = {0.5f, 0.5f, 0.0, 0.005};
    float ClearDepth = 1.0;
    string Format = TEX_FORMAT;
    bool AntiAlias = false;
    string DefaultEffect = 
        "self = hide;"
        #ifndef MIKUMIKUMOVING
        "DistObjPosControl.pmd = hide;"
        "DistObjUVControl.pmd = hide;"
        "DistJet.pmx = DistJet\\AD_Jet.fx;"
        "DistLine.x = DistLine\\AD_Line.fx;"
        "DistVortex.pmx = DistVortex\\AD_Vortex.fx;"
        "DistSpiral.x  = DistSpiral\\AD_Spiral.fx;"
        "DistParticle.x = DistParticle\\AD_Particle.fx;"
        "DistRipple.x = DistRipple\\AD_Ripple.fx;"
        "DistWind.x = DistWind\\AD_Wind.fx;"
        "DistFire.x = DistFire\\AD_Fire.fx;"
        "DistMangaTears.x = DistMangaTears\\AD_MangaTears.fx;"
        #endif
        "* =" OFFSCREEN_MASK ";";
>;
sampler NormalDepthMap = sampler_state {
    texture = <DistortionRT>;
    MinFilter = POINT;
    MagFilter = POINT;
    MipFilter = NONE;
    AddressU  = CLAMP;
    AddressV  = CLAMP;
};

//#define TEX_FORMATB "D3DFMT_R16F"
#define TEX_FORMATB "D3DFMT_R32F"

// �c�ݕ��ʂ��܂܂Ȃ��[�x�}�b�v
shared texture2D DepthTexB : RENDERCOLORTARGET <
    float2 ViewPortRatio = {1.0,1.0};
    int MipLevels = 0;
    string Format = TEX_FORMATB;
>;
sampler2D DepthMapB = sampler_state {
    texture = <DepthTexB>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = LINEAR;
    AddressU  = CLAMP;
    AddressV  = CLAMP;
};

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

#if UseHDR==0
    #define TEX_SCRFORMAT "D3DFMT_A8R8G8B8"
#else
    #define TEX_SCRFORMAT "D3DFMT_A16B16G16R16F"
    //#define TEX_SCRFORMAT "D3DFMT_A32B32G32R32F"
#endif

// �����_�����O�^�[�Q�b�g�̃N���A�l
float4 ClearColor = {0,0,0,1};
float4 ClearColorB = {1,0,0,1};
float ClearDepth  = 1.0;

// �I���W�i���̕`�挋�ʂ��L�^���邽�߂̃����_�[�^�[�Q�b�g
texture2D ScnTex : RENDERCOLORTARGET <
    float2 ViewPortRatio = {1.0, 1.0};
    int MipLevels = 0;
    string Format = TEX_SCRFORMAT;
>;
sampler2D ScnSmp = sampler_state {
    texture = <ScnTex>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = LINEAR;
    AddressU  = CLAMP;
    AddressV  = CLAMP;
};

// �����_�[�^�[�Q�b�g�̐[�x�X�e���V���o�b�t�@
texture2D DepthBuffer : RENDERDEPTHSTENCILTARGET <
    float2 ViewPortRatio = {1.0, 1.0};
    string Format = "D24S8";
>;

// X�����̂ڂ������ʂ��L�^���邽�߂̃����_�[�^�[�Q�b�g
texture2D NormalDepthTexX : RENDERCOLORTARGET <
    float2 ViewPortRatio = {1.0,1.0};
    int MipLevels = 1;
    string Format = TEX_FORMAT;
>;
sampler2D NormalDepthMapX = sampler_state {
    texture = <NormalDepthTexX>;
    MinFilter = POINT;
    MagFilter = POINT;
    MipFilter = NONE;
    AddressU  = CLAMP;
    AddressV  = CLAMP;
};

// X�����̂ڂ������ʂ��L�^���邽�߂̃����_�[�^�[�Q�b�g
texture2D NormalDepthTexY : RENDERCOLORTARGET <
    float2 ViewPortRatio = {1.0,1.0};
    int MipLevels = 1;
    string Format = TEX_FORMAT;
>;
sampler2D NormalDepthMapY = sampler_state {
    texture = <NormalDepthTexY>;
    MinFilter = POINT;
    MagFilter = POINT;
    MipFilter = NONE;
    AddressU  = CLAMP;
    AddressV  = CLAMP;
};

// �c�ݕ��ʂ��܂܂Ȃ��[�x�}�b�v�ڂ����p
shared texture2D DepthTexB2 : RENDERCOLORTARGET <
    float2 ViewPortRatio = {1.0,1.0};
    int MipLevels = 1;
    string Format = TEX_FORMATB;
>;
sampler2D DepthMapB2 = sampler_state {
    texture = <DepthTexB2>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = NONE;
    AddressU  = CLAMP;
    AddressV  = CLAMP;
};


////////////////////////////////////////////////////////////////////////////////////////////////
// �@���̂ڂ���,�ڂ����ɂ��[�x�␳

struct VS_OUTPUT {
    float4 Pos : POSITION;
    float2 Tex : TEXCOORD0;
};

// ���ʂ̒��_�V�F�[�_
VS_OUTPUT VS_Common(float4 Pos : POSITION, float2 Tex: TEXCOORD)
{
    VS_OUTPUT Out = (VS_OUTPUT)0; 

    Out.Pos = Pos;
    Out.Tex = Tex + ViewportOffset;

    return Out;
}

// �o�b�t�@�̃R�s�[
float4 PS_Copy( float2 Tex: TEXCOORD0 ) : COLOR0
{
    return tex2D( NormalDepthMap, Tex );
}

// X�����ڂ���
float4 PS_GaussianX( float2 Tex: TEXCOORD0 ) : COLOR0
{
    float4 Color;
    float3 normal;
    float  dep;

    Color  = tex2D( NormalDepthMapY, Tex );
    normal = WT_COEF[0] * Color.rgb;  dep = Color.a;

    [unroll]
    for(int i=1; i<8; i++){
        Color = tex2D( NormalDepthMapY, Tex+float2(SampStep.x*i, 0) );
        normal += WT_COEF[i] * Color.rgb;  if(Color.a > 0.5f && dep < Color.a) dep = Color.a;
        Color = tex2D( NormalDepthMapY, Tex-float2(SampStep.x*i, 0) );
        normal += WT_COEF[i] * Color.rgb;  if(Color.a > 0.5f && dep < Color.a) dep = Color.a;
    }

    return float4(normal, dep);
}

// Y�����ڂ���
float4 PS_GaussianY( float2 Tex: TEXCOORD0 ) : COLOR0
{
    float4 Color;
    float3 normal;
    float  dep;

    Color  = tex2D( NormalDepthMapX, Tex );
    normal = WT_COEF[0] * Color.rgb;  dep = Color.a;

    [unroll]
    for(int i=1; i<8; i++){
        Color = tex2D( NormalDepthMapX, Tex+float2(0, SampStep.y*i) );
        normal += WT_COEF[i] * Color.rgb;  if(Color.a > 0.5f && dep < Color.a) dep = Color.a;
        Color = tex2D( NormalDepthMapX, Tex-float2(0, SampStep.y*i) );
        normal += WT_COEF[i] * Color.rgb;  if(Color.a > 0.5f && dep < Color.a) dep = Color.a;
    }

    return float4(normal, dep);
}

////////////////////////////////////////////////////////////////////////////////////////////////
// �[�x�}�b�v�̂ڂ���

// X�����ڂ���
float4 PS_DepthGaussianX( float2 Tex: TEXCOORD0 ) : COLOR
{
    //float MipLv = log2( max(ViewportSize.x*SampStepB, 1.0f) );
    float MipLv = 0;

    float dep, sumRate = WT_COEF[0];
    float dep0 = tex2Dlod( DepthMapB, float4(Tex,0,MipLv) ).r;
    float sumDep = WT_COEF[0] * dep0;

    // �����ɂ���[�x�̓T���v�����O���Ȃ�
    [unroll]
    for(int i=1; i<8; i++){
        dep = tex2Dlod( DepthMapB, float4(Tex.x-SampStepB.x*i,Tex.y,0,MipLv) ).r;
        sumDep += WT_COEF[i] * dep * step(dep, dep0);  sumRate += WT_COEF[i] * step(dep, dep0);
        dep = tex2Dlod( DepthMapB, float4(Tex.x+SampStepB.x*i,Tex.y,0,MipLv) ).r;
        sumDep += WT_COEF[i] * dep * step(dep, dep0);  sumRate += WT_COEF[i] * step(dep, dep0);
    }

    dep = sumDep / sumRate;
    return float4(dep, 0, 0, 1);
}

// Y�����ڂ���
float4 PS_DepthGaussianY(float2 Tex: TEXCOORD0) : COLOR
{
    float dep, sumRate = WT_COEF[0];
    float dep0 = tex2D( DepthMapB2, Tex ).r;
    float sumDep = WT_COEF[0] * dep0;

    // �����ɂ���[�x�̓T���v�����O���Ȃ�
    [unroll]
    for(int i=1; i<8; i++){
        dep = tex2D( DepthMapB2, Tex-float2(0,SampStepB.y*i) ).r;
        sumDep += WT_COEF[i] * dep * step(dep, dep0);  sumRate += WT_COEF[i] * step(dep, dep0);
        dep = tex2D( DepthMapB2, Tex+float2(0,SampStepB.y*i) ).r;
        sumDep += WT_COEF[i] * dep * step(dep, dep0);  sumRate += WT_COEF[i] * step(dep, dep0);
    }

    dep = sumDep / sumRate;
    return float4(dep, 0, 0, 1);
}

////////////////////////////////////////////////////////////////////////////////////////////////
// �I���W�i���`��̘c�ݏ���

float4 PS_Object( float2 Tex: TEXCOORD0 ) : COLOR0
{
    // ���̖@���E�[�x
    float4 Color0 = tex2D( NormalDepthMap, Tex );
    // �ڂ���������̖@���E�[�x
    float4 Color1 = tex2D( NormalDepthMapY, Tex );

    //float3 Normal = normalize( Color1.rgb*(255.0f/127.0f) - 1.0f ); // �o�b�t�@��8bit�������炱������g��
    float3 Normal = normalize( Color1.rgb*2.0f - 1.0f ); // �@��
    float distDep = (Color1.a > 0.5f) ? (2.0f * Color1.a - 1.0f) * DEPTH_FAR : 0.0f; // �ڂ���������̐[�x
    float srcDep  = abs(2.0f * Color0.a - 1.0f) * DEPTH_FAR;                         // �ڂ��������O�̐[�x

    // ��O���ɂ��郂�f���̂ڂ����ɂ��ɂ��݂����Z�b�g
    if(Color0.a <= 0.5f && distDep > srcDep){
        Normal = float3(0,0,-1);
        distDep = 0.0f;
    }

    // �c�݋��x
    #if(FLAG_DEPTH > 0)
    float  depB = max(tex2D( DepthMapB, Tex ).r * DEPTH_FAR - distDep, 0.0f);
    float2 dist = Normal.xy * DistPowerMax * AcsTr * clamp(depB / DEPTH_FAR + 0.1f, 0.1f, 1.0f);
    #else
    float2 dist = Normal.xy * DistPowerMax * AcsTr * min(20.0f / distDep, 1.0f);
    #endif
    dist *= float2(ViewportSize.y / ViewportSize.x, -1.0f);

    // �c�ݏ���
    float ex = pow(100.0f, 1.0f/float(LOOP_COUNT));
    float depStep = 1.0f;
    float4 Color = tex2D( ScnSmp, Tex );
    if(Color1.a > 0.5f){
        [unroll] //���[�v�W�J
        for(int i=1; i<=LOOP_COUNT; i++){
            depStep *= ex;
            // �T���v�����O�ʒu�����X�Ɋg���Ď�O�ɂ��郂�f�����E��Ȃ��悤�ɂ���
            float2 texCoord = Tex - dist * float(i) / float(LOOP_COUNT);
            float rayDep = distDep + depStep; // ���C�ʒu�̐[�x(�K��)
            float smpDep  = tex2D( NormalDepthMap, texCoord ).a; // AA�̃u�����h�ʒu���E��Ȃ��悤��4�����`�F�b�N
            float smpDepL = tex2D( NormalDepthMap, texCoord+float2(-SampStep1.x,0) ).a;
            float smpDepR = tex2D( NormalDepthMap, texCoord+float2( SampStep1.x,0) ).a;
            float smpDepB = tex2D( NormalDepthMap, texCoord+float2(0,-SampStep1.y) ).a;
            float smpDepT = tex2D( NormalDepthMap, texCoord+float2(0, SampStep1.y) ).a;
            if( (smpDep  > 0.5f || abs(2.0f * smpDep  - 1.0f) * DEPTH_FAR > distDep) &&
                (smpDepL > 0.5f || abs(2.0f * smpDepL - 1.0f) * DEPTH_FAR > distDep) &&
                (smpDepR > 0.5f || abs(2.0f * smpDepR - 1.0f) * DEPTH_FAR > distDep) &&
                (smpDepB > 0.5f || abs(2.0f * smpDepB - 1.0f) * DEPTH_FAR > distDep) &&
                (smpDepT > 0.5f || abs(2.0f * smpDepT - 1.0f) * DEPTH_FAR > distDep) ){
                // �[�x�����C�ʒu�̎�O�ɂ��鎞�͏E��Ȃ�
                #if(FLAG_DEPTH > 0)
                depB = tex2D( DepthMapB, texCoord ).r * DEPTH_FAR + 0.01f;
                if(i==1 || rayDep < depB){
                    Color = tex2D( ScnSmp, texCoord );
                }
                #else
                    Color = tex2D( ScnSmp, texCoord );
                #endif
            }
        }
    }

    /*
    // �c�ݏ���
    float4 Color = tex2D( ScnSmp, Tex );
    if(Color1.a > 0.5f){
        // �T���v�����O�ʒu��񕪒T���ŋ��߂�
        float rayDepMin = distDep;
        float rayDepMax = distDep + 100.0f;
        for(int i=1; i<=LOOP_COUNT; i++){
            float rayDep = (rayDepMin + rayDepMax) * 0.5f; // ���C�ʒu�̐[�x(�K��)
            float2 texCoord = Tex - dist * (rayDep - distDep) / 100.0f;
            // ��O�ɂ��郂�f�����E��Ȃ��悤�ɂ���
            float smpDep  = tex2D( NormalDepthMap, texCoord ).a; // AA�̃u�����h�ʒu���E��Ȃ��悤��4�����`�F�b�N
            float smpDepL = tex2D( NormalDepthMap, texCoord+float2(-SampStep1.x,0) ).a;
            float smpDepR = tex2D( NormalDepthMap, texCoord+float2( SampStep1.x,0) ).a;
            float smpDepB = tex2D( NormalDepthMap, texCoord+float2(0,-SampStep1.y) ).a;
            float smpDepT = tex2D( NormalDepthMap, texCoord+float2(0, SampStep1.y) ).a;
            if( (smpDep  > 0.5f || abs(2.0f * smpDep  - 1.0f) * DEPTH_FAR > distDep) &&
                (smpDepL > 0.5f || abs(2.0f * smpDepL - 1.0f) * DEPTH_FAR > distDep) &&
                (smpDepR > 0.5f || abs(2.0f * smpDepR - 1.0f) * DEPTH_FAR > distDep) &&
                (smpDepB > 0.5f || abs(2.0f * smpDepB - 1.0f) * DEPTH_FAR > distDep) &&
                (smpDepT > 0.5f || abs(2.0f * smpDepT - 1.0f) * DEPTH_FAR > distDep) ){
                // �[�x�����C�ʒu�̎�O�ɂ��鎞�͏E��Ȃ�
                #if(FLAG_DEPTH > 0)
                depB = tex2D( DepthMapB, texCoord ).r * DEPTH_FAR;
                if(i==1 || rayDep < depB){
                    Color = tex2D( ScnSmp, texCoord );
                }
                #else
                    Color = tex2D( ScnSmp, texCoord );
                #endif
                rayDepMin = rayDep;
            }else{
                rayDepMax = rayDep;
            }
        }
    }
    */

    // �w��F�ƃu�����h
    float len = length(Normal.xy)*AcsTr;
    Color.xyz = lerp(Color.xyz, BlendColor, saturate(BlendColorRate*sqrt(len)));

    //Color = float4((Normal+1)*0.5,1);
    //Color = tex2D( NormalDepthMap, Tex );
    //Color = float4(tex2D( NormalDepthMap, Tex ).w,0,0,1);
    //Color = float4(distDep/30,0,0,1);
    //Color = float4(abs(2.0f * Color0.a - 1.0f) * DEPTH_FAR/200,0,0,1);
    //Color = float4(tex2D( DepthMapB, Tex ).r * DEPTH_FAR/200,0,0,1);

    return Color;
}

////////////////////////////////////////////////////////////////////////////////////////////////
// �e�N�j�b�N

technique MainTec1 < string MMDPass = "object";
    string Script = 
        "RenderColorTarget0=ScnTex;"
            "RenderDepthStencilTarget=DepthBuffer;"
            "ClearSetColor=ClearColor;"
            "ClearSetDepth=ClearDepth;"
            "Clear=Color;"
            "Clear=Depth;"
            "ScriptExternal=Color;"

        "RenderColorTarget0=NormalDepthTexY;"
        "RenderDepthStencilTarget=DepthBuffer;"
            "ClearSetColor=ClearColor;"
            "ClearSetDepth=ClearDepth;"
            "Clear=Color;"
            "Clear=Depth;"
            "Pass=BuffCopy;"

        "LoopByCount=RepertCount;"
        "LoopGetIndex=RepertIndex;"
            "RenderColorTarget0=NormalDepthTexX;"
            "RenderDepthStencilTarget=DepthBuffer;"
                "ClearSetColor=ClearColor;"
                "ClearSetDepth=ClearDepth;"
                "Clear=Color;"
                "Clear=Depth;"
                "Pass=GaussianX;"
            "RenderColorTarget0=NormalDepthTexY;"
            "RenderDepthStencilTarget=DepthBuffer;"
                "ClearSetColor=ClearColor;"
                "ClearSetDepth=ClearDepth;"
                "Clear=Color;"
                "Clear=Depth;"
                "Pass=GaussianY;"
        "LoopEnd=;"

        #if(FLAG_DEPTH > 0)
        "LoopByCount=RepertCountB;"
        "LoopGetIndex=RepertIndex;"
        "RenderColorTarget0=;"
        "RenderColorTarget0=DepthTexB2;"
        "RenderDepthStencilTarget=DepthBuffer;"
            "ClearSetColor=ClearColor;"
            "ClearSetDepth=ClearDepth;"
            "Clear=Color;"
            "Clear=Depth;"
            "Pass=GaussianXB;"
        "RenderColorTarget0=DepthTexB;"
        "RenderDepthStencilTarget=DepthBuffer;"
            "ClearSetColor=ClearColor;"
            "ClearSetDepth=ClearDepth;"
            "Clear=Color;"
            "Clear=Depth;"
            "Pass=GaussianYB;"
        "LoopEnd=;"
        #endif

        "RenderColorTarget0=;"
            "RenderDepthStencilTarget=;"
            "Pass=DrawObject;"

        "RenderColorTarget0=DepthTexB;"
            "ClearSetColor=ClearColorB;"
            "Clear=Color;"
        "RenderColorTarget0=;"
            "RenderDepthStencilTarget=;"
        ; >
{
    pass BuffCopy < string Script= "Draw=Buffer;"; > {
        AlphaBlendEnable = FALSE;
        VertexShader = compile vs_1_1 VS_Common();
        PixelShader  = compile ps_2_0 PS_Copy();
    }
    pass GaussianX < string Script= "Draw=Buffer;"; > {
        AlphaBlendEnable = FALSE;
        VertexShader = compile vs_3_0 VS_Common();
        PixelShader  = compile ps_3_0 PS_GaussianX();
    }
    pass GaussianY < string Script= "Draw=Buffer;"; > {
        AlphaBlendEnable = FALSE;
        VertexShader = compile vs_3_0 VS_Common();
        PixelShader  = compile ps_3_0 PS_GaussianY();
    }
    #if(FLAG_DEPTH > 0)
    pass GaussianXB < string Script= "Draw=Buffer;"; > {
        AlphaBlendEnable = FALSE;
        VertexShader = compile vs_3_0 VS_Common();
        PixelShader  = compile ps_3_0 PS_DepthGaussianX();
    }
    pass GaussianYB < string Script= "Draw=Buffer;"; > {
        AlphaBlendEnable = FALSE;
        VertexShader = compile vs_3_0 VS_Common();
        PixelShader  = compile ps_3_0 PS_DepthGaussianY();
    }
    #endif
    pass DrawObject < string Script= "Draw=Buffer;"; > {
        AlphaBlendEnable = FALSE;
        VertexShader = compile vs_3_0 VS_Common();
        PixelShader  = compile ps_3_0 PS_Object();
    }
}



