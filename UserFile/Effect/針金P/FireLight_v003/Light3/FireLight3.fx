////////////////////////////////////////////////////////////////////////////////////////////////
//
//  FireLight.fx v0.0.3   �����ۂ��_�����G�t�F�N�g
//  �쐬: �j��P
//
////////////////////////////////////////////////////////////////////////////////////////////////
// �����̃p�����[�^��ύX���Ă�������

// ���C�gID�ԍ�
#define  LightID  3   // 1�`4�ȊO�ŐV���Ɍ����𑝂₷�ꍇ�̓t�@�C�����ύX�Ƃ��̒l��5,6,7���ƕς��Ă���

// �Z���t�V���h�E�̗L��
#define Use_SelfShadow  1  // 0:�Ȃ�, 1:�L��

// �\�t�g�V���h�E�̗L��
#define UseSoftShadow  1  // 0:�Ȃ�, 1:�L��

// �V���h�E�}�b�v�o�b�t�@�T�C�Y
#define ShadowMapSize  1024   // 512, 1024, 2048, 4096 �̂ǂꂩ�őI��

//-----------------------------------------------------
#ifndef MIKUMIKUMOVING
// MME�݂̂����̃p�����[�^��ύX���Ă�������(MMM�̓v���p�e�B�V�[�g���ύX�\)

// �\�t�g�V���h�E�̂ڂ������x
float ShadowBulrPower = 1.0;  // 0.5�`5.0���x�Œ���

// �Z���t�e�̔Z�x(0.0�`1.0�Œ���)
float ShadowDensity = 1.0f;

// �����̋����ɑ΂��錸���ʌW��(0.0�`1.0�Œ���)
float Attenuation = 0.2;

// �������U�����̋���(0.0�`1.0���x)
float AmbientPower = 0.03;

// ���C�g�F
float3 LightColor = {1.0, 0.3, 0.0}; // ���C�g�̐F

// ���̗h�炬�p�����[�^
float firePosAmpFactor = 0.7;   // ���̈ʒu�̗h�炬�U��
float firePosFreqFactor = 0.4;  // ���̈ʒu�̗h�炬���g��
float firePowAmpFactor = 0.3;   // ���̖��邳�h�炬�U��
float firePowFreqFactor = 5.0;  // ���̖��邳�h�炬���g��


// ����Ȃ��l�͂������牺�͂�����Ȃ��ł�

///////////////////////////////////////////////////////////////////

float3 AcsRxyz : CONTROLOBJECT < string name = "(self)"; string item = "Rxyz"; >;

static float3 degRxyz = degrees(AcsRxyz);
static float posAmp  = firePosAmpFactor  * max(degRxyz.x + 1.0f, 0.0f);  // ���̈ʒu�̗h�炬�U��
static float posFreq = firePosFreqFactor * max(degRxyz.y + 1.0f, 0.0f);  // ���̈ʒu�̗h�炬���g��
static float powAmp  = firePowAmpFactor;                                 // ���̖��邳�h�炬�U��
static float powFreq = firePowFreqFactor * max(degRxyz.z + 1.0f, 0.0f);  // ���̖��邳�h�炬���g��

#else

float Attenuation <
   string UIName = "��������";
   string UIHelp = "�����̋����ɑ΂��錸���ʌW��(0.0�`1.0�Œ���)";
   string UIWidget = "Slider";
   bool UIVisible =  true;
   float UIMin = 0.0;
   float UIMax = 1.0;
> = float( 0.2 );

float AmbientPower <
   string UIName = "�U����";
   string UIHelp = "�������U�����̋���(0.0�`1.0���x)";
   string UIWidget = "Slider";
   bool UIVisible =  true;
   float UIMin = 0.0;
   float UIMax = 1.0;
> = float( 0.03 );

float ShadowBulrPower <
   string UIName = "�e�ڂ���";
   string UIHelp = "�\�t�g�V���h�E�̂ڂ������x";
   string UIWidget = "Slider";
   bool UIVisible =  true;
   float UIMin = 0.0;
   float UIMax = 5.0;
> = float( 1.0 );

float ShadowDensity <
   string UIName = "�e�Z�x";
   string UIHelp = "�Z���t�e�̔Z�x(0.0�`1.0�Œ���)";
   string UIWidget = "Slider";
   bool UIVisible =  true;
   float UIMin = 0.0;
   float UIMax = 1.0;
> = float( 1.0 );

// ���̗h�炬�p�����[�^
float posAmp <
   string UIName = "�h��U��";
   string UIHelp = "���̈ʒu�̗h�炬�U��";
   string UIWidget = "Slider";
   bool UIVisible =  true;
   float UIMin = 0.0;
   float UIMax = 10.0;
> = float( 0.7 );

float posFreq <
   string UIName = "�h����g��";
   string UIHelp = "���̈ʒu�̗h�炬���g��";
   string UIWidget = "Slider";
   bool UIVisible =  true;
   float UIMin = 0.0;
   float UIMax = 2.0;
> = float( 0.4 );

float powAmp <
   string UIName = "���x�U��";
   string UIHelp = "���̖��邳�h�炬�U��";
   string UIWidget = "Slider";
   bool UIVisible =  true;
   float UIMin = 0.0;
   float UIMax = 1.0;
> = float( 0.3 );

float powFreq <
   string UIName = "���x���g��";
   string UIHelp = "���̖��邳�h�炬���g��";
   string UIWidget = "Slider";
   bool UIVisible =  true;
   float UIMin = 0.0;
   float UIMax = 10.0;
> = float( 5.0 );

float3 LightColor <
   string UIName = "���C�g�F";
   string UIHelp = "���̐F";
   string UIWidget = "Color";
   bool UIVisible =  true;
   float UIMin = 0.0;
   float UIMax = 1.0;
> = float3(1.0, 0.3, 0.0);


#endif


float Script : STANDARDSGLOBAL <
    string ScriptOutput = "color";
    string ScriptClass = "sceneorobject";
    string ScriptOrder = "postprocess";
> = 0.8;


#ifdef MIKUMIKUMOVING
// �����_�����O�^�[�Q�b�g�̃N���A�l
float4 ClearColor = {0,0,0,1};
float ClearDepth  = 1.0;

// �e�N�X�`���t�H�[�}�b�g
#define TEX_FORMAT "D3DFMT_A16B16G16R16F"

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
    AddressU = CLAMP;
    AddressV = CLAMP;
};

texture2D DepthBuffer : RENDERDEPTHSTENCILTARGET <
    float2 ViewPortRatio = {1.0,1.0};
    string Format = "D3DFMT_D24S8";
>;
#endif


////////////////////////////////////////////////////////////////////////////////////////////////
// ���I�o�����ʃV���h�E�}�b�v�`���I�t�X�N���[���o�b�t�@

#if LightID > 1
    #define  ShadowMap(n)  FL_ShadowMap##n                          // �V���h�E�}�b�v�e�N�X�`����
    #define  ShadowMap_FileName(n)  "* = FL_ShadowMap"#n".fxsub;"   // �V���h�E�}�b�vfx�t�@�C����
    #define  ShadowMap_FA_FileName(n)  "FloorAssist.x = FL_ShadowMapFA"#n".fxsub;"   // �V���h�E�}�b�v(���⏕)fx�t�@�C����
#else
    #define  ShadowMap(n)  FL_ShadowMap                             // �V���h�E�}�b�v�e�N�X�`����
    #define  ShadowMap_FileName(n)  "* = FL_ShadowMap.fxsub;"       // �V���h�E�}�b�vfx�t�@�C����
    #define  ShadowMap_FA_FileName(n)  "FloorAssist.x = FL_ShadowMapFA.fxsub;"   // �V���h�E�}�b�v(���⏕)fx�t�@�C����
#endif

#if Use_SelfShadow==1

// �V���h�E�}�b�v�o�b�t�@�T�C�Y
#if ShadowMapSize==512
    #define SMAPSIZE_WIDTH   512
    #define SMAPSIZE_HEIGHT  1024
#endif
#if ShadowMapSize==1024
    #define SMAPSIZE_WIDTH   1024
    #define SMAPSIZE_HEIGHT  2048
#endif
#if ShadowMapSize==2048
    #define SMAPSIZE_WIDTH   2048
    #define SMAPSIZE_HEIGHT  4096
#endif
#if ShadowMapSize==4096
    #define SMAPSIZE_WIDTH   4096
    #define SMAPSIZE_HEIGHT  8192
#endif

shared texture ShadowMap(LightID) : OFFSCREENRENDERTARGET <
    string Description = "FireLight.fx�̃V���h�E�}�b�v�o�b�t�@";
    int Width  = SMAPSIZE_WIDTH;
    int Height = SMAPSIZE_HEIGHT;
    float4 ClearColor = { 1, 1, 1, 1 };
    float ClearDepth = 1.0;
    #if UseSoftShadow==1
    string Format = "D3DFMT_G32R32F" ;
    int Miplevels = 0;
    #else
    string Format = "D3DFMT_R32F" ;
    int Miplevels = 1;
    #endif
    bool AntiAlias = false;
    string DefaultEffect = 
        "self = hide;"
        "FireLight*.x = hide;"
        ShadowMap_FA_FileName(LightID)
        ShadowMap_FileName(LightID)
    ;
>;

#endif

///////////////////////////////////////////////////////////////////
// FireLighting�`���I�t�X�N���[���o�b�t�@

#if LightID > 1
    #define  ObjectDraw_RT(n)  FireLightingRT##n                // �I�u�W�F�N�g�`��e�N�X�`����
    #define  ObjectDraw_FileName(n)  "* = FL_Object"#n".fxsub;" // �I�u�W�F�N�g�`��fx�t�@�C����
#else
    #define  ObjectDraw_RT(n)  FireLightingRT                 // �I�u�W�F�N�g�`��e�N�X�`����
    #define  ObjectDraw_FileName(n)  "* = FL_Object.fxsub;"   // �I�u�W�F�N�g�`��fx�t�@�C����
#endif

texture ObjectDraw_RT(LightID) : OFFSCREENRENDERTARGET <
    string Description = "FireLight.fx�̃��f���̓_�����I�u�W�F�N�g�`��";
    float2 ViewPortRatio = {1.0, 1.0};
    float4 ClearColor = { 0, 0, 0, 1 };
    float ClearDepth = 1.0;
    string Format = "D3DFMT_A8R8G8B8" ;
    bool AntiAlias = true;
    string DefaultEffect = 
        "self = hide;"
        "FloorAssist.x = hide;"
        ObjectDraw_FileName(LightID)
    ;
>;
sampler FireLightingView = sampler_state {
    Texture = <ObjectDraw_RT(LightID)>;
    MinFilter = POINT;
    MagFilter = POINT;
    MipFilter = NONE;
    AddressU  = CLAMP;
    AddressV = CLAMP;
};

///////////////////////////////////////////////////////////////////
// ���̃t�@�C���̕ϐ����I�t�X�N���[���o�b�t�@�ɓn�����߂Ƀe�N�X�`���ɋL�^����

#define  OwnerDataTex(n)  FireLight_OwnerDataTex##n                        // �f�[�^�o�b�t�@�̃e�N�X�`����
#define  OwnerDataRT(n)  "RenderColorTarget0=FireLight_OwnerDataTex"#n";"  // �f�[�^�o�b�t�@�̃����_�^�[�Q�b�g

shared texture OwnerDataTex(LightID) : RENDERCOLORTARGET <
    int Width=4;
    int Height=1;
    int Miplevels = 1;
    string Format="D3DFMT_A32B32G32R32F";
>;
texture OwnerDataDepthBuffer : RenderDepthStencilTarget <
    int Width=4;
    int Height=1;
    string Format = "D3DFMT_D24S8";
>;

float time : TIME;

struct VS_OUTPUT {
    float4 Pos : POSITION;
    float2 Tex : TEXCOORD0;
};

// ���_�V�F�[�_
VS_OUTPUT VS_OwnerData(float4 Pos : POSITION, float2 Tex : TEXCOORD0)
{
    VS_OUTPUT Out = (VS_OUTPUT)0; 

    Out.Pos = Pos;
    Out.Tex = Tex+float2(0.125,0.5);

    return Out;
}

// �s�N�Z���V�F�[�_
float4 PS_OwnerData(VS_OUTPUT IN) : COLOR
{
    // ���̌����ʒu�̗h�炬
    float time2 = time + 0.25;
    float3 ltOffset = float3(posAmp * (0.66f * (abs(frac(2.1f * posFreq * time ) * 2.0f - 1.0f) - 0.5)
                                     + 0.33f * (abs(frac(3.3f * posFreq * time2) * 2.0f - 1.0f) - 0.5) ),
                             posAmp * (0.42f * (abs(frac(3.2f * posFreq * time ) * 2.0f - 1.0f) - 0.5)
                                     + 0.58f * (abs(frac(1.3f * posFreq * time2) * 2.0f - 1.0f) - 0.5) ),
                             posAmp * (0.71f * (abs(frac(2.7f * posFreq * time ) * 2.0f - 1.0f) - 0.5)
                                     + 0.29f * (abs(frac(1.9f * posFreq * time2) * 2.0f - 1.0f) - 0.5) ) );

    // ���̖��邳�̗h�炬
    float ltPow = 1.0f + powAmp * (0.66f * sin(2.1f * time * powFreq)
                                 + 0.33f * cos(3.3f * time * powFreq) );

    if(IN.Tex.x < 0.25f){
       return float4(ltOffset, max(ltPow, 0));
    }else if(IN.Tex.x < 0.5f){
       return float4(ShadowBulrPower, ShadowDensity, 1.0f/max(lerp(0.1f, 5.0f, Attenuation), 0.1f), AmbientPower);
    }else if(IN.Tex.x < 0.75f){
       return float4(LightColor, 0);
    }else{
       return float4(0, 0, 0, 0);
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////

// �X�N���[���T�C�Y
float2 ViewportSize : VIEWPORTPIXELSIZE;
static float2 ViewportOffset = (float2(0.5,0.5)/ViewportSize);

// ���_�V�F�[�_
VS_OUTPUT VS_Draw( float4 Pos : POSITION, float2 Tex : TEXCOORD0 )
{
    VS_OUTPUT Out = (VS_OUTPUT)0; 

    Out.Pos = Pos;
    Out.Tex = Tex + ViewportOffset;

    return Out;
}

// �s�N�Z���V�F�[�_
float4 PS_Draw( float2 Tex: TEXCOORD0 ) : COLOR
{
    float4 Color = tex2D( FireLightingView, Tex );

    #ifdef MIKUMIKUMOVING
    float4 Color0 = tex2D( ScnSamp, Tex );
    Color.rgb += Color0.rgb;
    Color.a = Color0.a;
    #endif

    return Color;
}


///////////////////////////////////////////////////////////////////////////////////////
// �e�N�j�b�N

technique MainTech1 <
    string Script = 
        OwnerDataRT(LightID)
            "RenderDepthStencilTarget=OwnerDataDepthBuffer;"
            "Pass=SetOwnerData;"
        #ifdef MIKUMIKUMOVING
        "RenderColorTarget0=ScnMap;"
            "RenderDepthStencilTarget=DepthBuffer;"
            "ClearSetColor=ClearColor;"
            "ClearSetDepth=ClearDepth;"
            "Clear=Color;"
            "Clear=Depth;"
            "ScriptExternal=Color;"
        #endif
        "RenderColorTarget0=;"
            "RenderDepthStencilTarget=;"
            #ifndef MIKUMIKUMOVING
            "ScriptExternal=Color;"
            #endif
            "Pass=DrawPass;"
        ; >
{
    pass SetOwnerData < string Script= "Draw=Buffer;"; > {
        AlphaBlendEnable = FALSE;
        AlphaTestEnable = FALSE;
        VertexShader = compile vs_2_0 VS_OwnerData();
        PixelShader  = compile ps_2_0 PS_OwnerData();
    }
    pass DrawPass < string Script= "Draw=Buffer;"; > {
        #ifndef MIKUMIKUMOVING
        ZEnable = FALSE;
        AlphaBlendEnable = TRUE;
        SrcBlend = ONE;
        DestBlend = ONE;
        #endif
        VertexShader = compile vs_2_0 VS_Draw();
        PixelShader  = compile ps_2_0 PS_Draw();
    }
}

