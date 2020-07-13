////////////////////////////////////////////////////////////////////////////////////////////////
//
//  �J�������w�n�����G�t�F�N�g
//  �쐬: ���ڂ�
//
////////////////////////////////////////////////////////////////////////////////////////////////
// ���[�U�[�p�����[�^


// DOF�p�����[�^ //////////////////////////////////////////////////////////

// �ڂ����͈�(�傫����������ƎȂ��o�܂�)
float DOF_Extent
<
   string UIName = "DOF_Extent";
   string UIWidget = "Slider";
   bool UIVisible =  true;
   float UIMin = 0.00;
   float UIMax = 0.002;
> = float( 0.0005 );

//�ڂ��������l
float DOF_BlurLimit
<
   string UIName = "DOF_BlurLimit";
   string UIWidget = "Slider";
   bool UIVisible =  true;
   float UIMin = 0.0;
   float UIMax = 20.0;
> = 6;


float ShallowDOFPower
<
   string UIName = "ShallowDOFPower";
   string UIWidget = "Slider";
   bool UIVisible =  true;
   float UIMin = 0.0;
   float UIMax = 15.0;
> = 5;


//��O��DOF���[�v��
#define DOF_Shallow_LOOP 5

#define DOF_EXPBLUR 0

// ���[�V�����u���[�p�����[�^ //////////////////////////////////////////////

// �ڂ������x(�傫����������ƎȂ��o�܂�)
float DirectionalBlurStrength <
   string UIName = "DirBlur";
   string UIWidget = "Slider";
   string UIHelp = "���[�V�����u���[�ڂ������x";
   bool UIVisible =  true;
   float UIMin = 0;
   float UIMax = 2.0;
> = 0.4;

//�c������
float LineBlurLength <
   string UIName = "LineBlurLen";
   string UIWidget = "Slider";
   string UIHelp = "�c������";
   bool UIVisible =  true;
   float UIMin = 0;
   float UIMax = 4;
> = 1.5;

//�c���Z��
float LineBlurStrength <
   string UIName = "LineBlurStr";
   string UIWidget = "Slider";
   string UIHelp = "�c���Z��";
   bool UIVisible =  true;
   float UIMin = 0;
   float UIMax = 2;
> = 1;

//���x�̏���l
float VelocityLimit <
   string UIName = "VelocityLimit";
   string UIWidget = "Slider";
   string UIHelp = "���x�̏���l";
   bool UIVisible =  true;
   float UIMin = 0;
   float UIMax = 0.5;
> = 0.12;

//���x�̉����l
float VelocityUnderCut <
   string UIName = "VelocityUnder";
   string UIWidget = "Slider";
   string UIHelp = "���x�̉����l";
   bool UIVisible =  true;
   float UIMin = 0;
   float UIMax = 0.02;
> = 0.006;

//�V�[���؂�ւ�臒l
float SceneChangeThreshold <
   string UIName = "SCThreshold";
   string UIWidget = "Slider";
   string UIHelp = "�V�[���؂�ւ�����̈ړ���臒l";
   bool UIVisible =  true;
   float UIMin = 0;
   float UIMax = 100;
> = 20;

//�V�[���؂�ւ��p�x臒l
float SceneChangeAngleThreshold <
   string UIName = "SCAngle";
   string UIWidget = "Slider";
   string UIHelp = "�V�[���؂�ւ�����̊p�x臒l";
   bool UIVisible =  true;
   float UIMin = 0;
   float UIMax = 90;
> = 25;

//���C���u���[�̉𑜓x��{�ɂ��܂��B1�ŗL���A0�Ŗ���
#define LINEBLUR_QUAD  1


// AutoLuminous�p�����[�^ ////////////////////////////////////////////////

#ifdef MIKUMIKUMOVING

int Glare <
   string UIName = "Glare";
   string UIWidget = "Slider";
   string UIHelp = "��䊂̐����w�肵�܂��B";
   bool UIVisible =  true;
   int UIMin = 0;
   int UIMax = 6;
> = 0;

#endif

//MMM�p�O���A�p�x
float GlareAngle2 <
   string UIName = "GlareAngle";
   string UIWidget = "Slider";
   string UIHelp = "��䊊p�x";
   bool UIVisible =  true;
   float UIMin = 0;
   float UIMax = 180;
> = 0.0;

//MMM�p�O���A����
float GlareLength <
   string UIName = "GlareLength";
   string UIWidget = "Slider";
   string UIHelp = "��䊒���";
   bool UIVisible =  true;
   float UIMin = 0;
   float UIMax = 2.0;
> = 1.0;


//MMM�p�������x
float Power2 <
   string UIName = "LightPower";
   string UIWidget = "Slider";
   string UIHelp = "�������x";
   bool UIVisible =  true;
   float UIMin = 0;
   float UIMax = 20;
> = 1.0;

// �ڂ����͈�
float AL_Extent <
   string UIName = "AL_Extent";
   string UIWidget = "Slider";
   string UIHelp = "�����ڂ����͈�";
   bool UIVisible =  true;
   float UIMin = 0;
   float UIMax = 0.2;
> = 0.07;


//�O���A���x�@1.0�O��
float GlarePower <
   string UIName = "GlarePower";
   string UIWidget = "Slider";
   string UIHelp = "�O���A���x";
   bool UIVisible =  true;
   float UIMin = 0;
   float UIMax = 3;
> = 1.2;

//����ьW���@0�`1
float OverExposureRatio <
   string UIName = "OverExposure";
   string UIWidget = "Slider";
   string UIHelp = "����ьW��";
   bool UIVisible =  true;
   float UIMin = 0;
   float UIMax = 3;
> = 0.85;

//��������@0�`1
float Modest <
   string UIName = "Modest";
   string UIWidget = "Slider";
   string UIHelp = "�ア�������܂�g�U���Ȃ��Ȃ�܂�";
   bool UIVisible =  true;
   float UIMin = 0;
   float UIMax = 2.0;
> = 1.0;

#ifdef MIKUMIKUMOVING

float ScreenToneCurve <
   string UIName = "ToneCurve";
   string UIWidget = "Slider";
   string UIHelp = "�g�[���J�[�u�ύX";
   bool UIVisible =  true;
   float UIMin = 0;
   float UIMax = 1;
> = 0;

#endif



//�c�����x�@0�`50���x�@0�Ŗ���
#define AFTERGLOW  0

//������̃T���v�����O��
#define AL_SAMP_NUM   6

//�O���A�̈�����̃T���v�����O��
#define AL_SAMP_NUM2  12




//DOF�̃T���v�����O��
#define LightDOF_SAMP_NUM  4


//�ҏW���̓_�ł��t���[�����ɓ���������
//true���ƃt���[�����ɉ����Č��̋������ω�
//false���ƕҏW�����_�ł������܂�
#define SYNC false

//�g�[���J�[�u�̓K�p������
//0���I�t�A1���I���ł�
//ToneCurve.x��ǂݍ��ނ̂��ʓ|�ł���΃I���ɂ��܂�
#define SCREEN_TONECURVE  0

//�O���A���P���������������܂�
//0���I�t�A1���I���ł�
//�O���A�̃T���v�����O��������ɉ����đ��₵�܂�
#define GLARE_LONGONE  0

//�����A���t�@�o�̓��[�h
//MMD��ł̕\���͂��������Ȃ�܂����A�����摜�o�͂Ƃ��Ă�
//�����ɐ������A���t�@�t���f�[�^�������܂�
//���݂̂Ƃ���A���[�V�����u���[��DOF�v�f�ɂ͓K�p����܂���
//0���I�t�A1���I���ł�
#define ALPHA_OUT  0



// ���჌���Y�p�����[�^ ////////////////////////////////////////////////


//���჌���Y�G�t�F�N�g��L���ɂ��܂��@1�ŗL���A0�Ŗ���
#define FISHEYE_ENABLE 0


#if FISHEYE_ENABLE!=0
    
    //�����Y�c�݋��x
    float FishEyeStregth <
       string UIName = "FishEye";
       string UIWidget = "Slider";
       string UIHelp = "�����Y�c�݋��x";
       bool UIVisible =  true;
       float UIMin = 0;
       float UIMax = 3;
    > = 0.9;

    //���x�^�ǉ��T�C�Y
    float BetaSize <
       string UIName = "Beta";
       string UIWidget = "Slider";
       string UIHelp = "���x�^�ǉ��T�C�Y";
       bool UIVisible =  true;
       float UIMin = 0;
       float UIMax = 1;
    > = 0.095;

#endif


// ���ʃp�����[�^ //////////////////////////////////////////////////////


//�ȈՐF���␳�E�z���C�g�o�����X�����p
//const float3 ColorCorrection = float3( 1, 1, 1 );

//������̃T���v�����O��
#define SAMP_NUM   8

//�w�i�F
const float4 BackColor <
   string UIName = "BackColor";
   string UIWidget = "Color";
   string UIHelp = "�w�i�F";
   bool UIVisible =  true;
> = float4( 0, 0, 0, 0 );



///////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////
//����ȍ~�̓G�t�F�N�g�̒m���̂���l�ȊO�͐G��Ȃ�����


//�X�P�[���W��
#define SCALE_VALUE 4

//int LightSamplingLoopIndex = 0;
int AL_LoopIndex = 0;

int ShallowBlurLoopIndex = 0;
int ShallowBlurLoopCount = DOF_Shallow_LOOP;


float Script : STANDARDSGLOBAL <
    string ScriptOutput = "color";
    string ScriptClass = "sceneorobject";
    string ScriptOrder = "postprocess";
> = 0.8;


#define PI 3.14159
#define DEG_TO_RAD (PI / 180)


#define VPRATIO 1.0



//�I�[�g�t�H�[�J�X�̎g�p
bool UseAF : CONTROLOBJECT < string name = "TCLXAutoFocus.x"; >;
float3 AFPos : CONTROLOBJECT < string name = "TCLXAutoFocus.x"; >;
float AFScale : CONTROLOBJECT < string name = "TCLXAutoFocus.x"; >;

//�}�j���A���t�H�[�J�X�̎g�p
bool UseMF : CONTROLOBJECT < string name = "TCLXManualFocus.x"; >;
float MFScale : CONTROLOBJECT < string name = "TCLXManualFocus.x"; >;
float4x4 MFWorld : CONTROLOBJECT < string name = "TCLXManualFocus.x"; >; 
static float MF_y = MFWorld._42;


//�t�H�[�J�X�̎g�p
bool FocusEnable : CONTROLOBJECT < string name = "TCLX_Focus.x"; >;
float FocusMode : CONTROLOBJECT < string name = "TCLX_Focus.x"; string item = "Ry"; >;
float FocusDeep : CONTROLOBJECT < string name = "TCLX_Focus.x"; string item = "Tr"; >;
float FocusScale : CONTROLOBJECT < string name = "TCLX_Focus.x"; >;
float4x4 FocusWorld : CONTROLOBJECT < string name = "TCLX_Focus.x"; >;
static float FocusY = FocusWorld._42;

//static float DOF_scaling = (UseMF ? MFScale : (UseAF ? AFScale : 0)) * 0.05;
static float DOF_scaling = FocusScale * 0.05;


//����p�ɂ��ڂ������x��
float4x4 ProjMatrix      : PROJECTION;
static float viewangle = atan(1 / ProjMatrix[0][0]);
static float viewscale = (45 / 2 * DEG_TO_RAD) / viewangle;

// �X�N���[���T�C�Y
float2 ViewportSize : VIEWPORTPIXELSIZE;
static float ViewportAspect = ViewportSize.x / ViewportSize.y;
static float2 ViewportOffset = (float2(0.5,0.5)/ViewportSize);
static float2 OnePx = (float2(1,1)/ViewportSize);

//�ڂ����T���v�����O�Ԋu
static float2 DOF_SampStep = (float2(DOF_Extent,DOF_Extent)/ViewportSize*ViewportSize.y);
static float2 DOF_SampStepScaled = DOF_SampStep  * DOF_scaling * viewscale / SAMP_NUM * 8.0;

static float DOF_BlurLimitScaled = DOF_BlurLimit / DOF_scaling;



// �A���t�@�擾
float alpha1 : CONTROLOBJECT < string name = "(self)"; string item = "Tr"; >;

float4x4 matWorld : CONTROLOBJECT < string name = "(self)"; >; 
static float pos_y = matWorld._42;
static float pos_z = matWorld._43;

static float OverLight = (pos_y + 100) / 100;


// �X�P�[���l�擾
float scaling0 : CONTROLOBJECT < string name = "(self)"; >;
static float scaling = scaling0 * 0.1 * (1.0 + pos_z / 100) * Power2;

// X��]
float3 rot : CONTROLOBJECT < string name = "(self)"; string item = "Rxyz"; >;

static float Power3 = scaling * (1.0 + pos_z / 100) * Power2;

//��䊂̐�

#ifndef MIKUMIKUMOVING

float Glare : CONTROLOBJECT < string name = "(self)"; string item = "X"; >;

#endif

//��䊂̒���
static float GlareAspect = (rot.y * 180 / PI + 100) / 100.0 * GlareLength;

//��䊊p�x
static float GlareAngle = rot.x + GlareAngle2 * PI / 180.0;


#ifndef MIKUMIKUMOVING
    #if SCREEN_TONECURVE==0
        bool ScreenToneCurve : CONTROLOBJECT < string name = "ToneCurve.x"; >;
    #else
        bool ScreenToneCurve = true;
    #endif
#endif

//����
float ftime : TIME <bool SyncInEditMode = SYNC;>;

static float timerate = (rot.z > 0) ? ((1 + cos(ftime * 2 * PI / (rot.z / PI * 180))) * 0.4 + 0.2)
                     : ((rot.z < 0) ? (frac(ftime / (-rot.z / PI * 180)) < 0.5) : 1.0);


//static float2 AL_SampStep = (float2(AL_Extent,AL_Extent) / ViewportSize * ViewportSize.y);
static float2 AL_SampStep = (AL_Extent * float2(1/ViewportAspect, 1));
static float2 AL_SampStepScaled = AL_SampStep * alpha1 / (float)AL_SAMP_NUM * 0.08;

static float AL_SampStep2 = AL_Extent * alpha1 / (float)AL_SAMP_NUM2 * GlareAspect;



bool ExternLightSampling : CONTROLOBJECT < string name = "LightSampling.x"; >;


bool TestMode : CONTROLOBJECT < string name = "AL_Test.x"; >;
float TestValue : CONTROLOBJECT < string name = "AL_Test.x"; >;




static float2 MBlurSampStep = (float2(DirectionalBlurStrength, DirectionalBlurStrength)/ViewportSize*ViewportSize.y);
static float2 MBlurSampStepScaled = MBlurSampStep * 1 / SAMP_NUM * 8;


////////////////////////////////////////////////////////////////////////////////////

//�x���V�e�B�}�b�v�o�b�t�@�t�H�[�}�b�g
#define VM_TEXFORMAT "A32B32G32R32F"
//#define VM_TEXFORMAT "A16B16G16R16F"

//�`��o�b�t�@�t�H�[�}�b�g
//#define DB_TEXFORMAT "A8R8G8B8"
#define DB_TEXFORMAT "A16B16G16R16F" //HDR��
//#define DB_TEXFORMAT "A32B32G32R32F" //HDR��

//�����o�b�t�@�t�H�[�}�b�g
#define AL_TEXFORMAT "D3DFMT_A16B16G16R16F"

////////////////////////////////////////////////////////////////////////////////////

#define TEXSIZE1  1
#define TEXSIZE2  0.5
#define TEXSIZE3  0.25
#define TEXSIZE4  0.125
#define TEXSIZE5  0.0625


///////////////////////////////////////////////////////////////////////////////////////////////
// �����˃I�u�W�F�N�g�`���

texture AL_EmitterRT: OFFSCREENRENDERTARGET <
    string Description = "EmitterDrawRenderTarget for AutoLuminous";
    float2 ViewPortRatio = {TEXSIZE1,TEXSIZE1};
    float4 ClearColor = { 0, 0, 0, 1 };
    float ClearDepth = 1.0;
    bool AntiAlias = true;
    int MipLevels = 0;
    string Format = AL_TEXFORMAT;
    string DefaultEffect = 
        "self = hide;"
        "*Luminous.x = hide;"
        "ToneCurve.x = hide;"
        
        //------------------------------------
        //�Z���N�^�G�t�F�N�g�͂����Ŏw�肵�܂�
        
        
        
        //------------------------------------
        
        //"*=hide"
        "* = AL_Object.fxsub;" 
    ;
>;


sampler EmitterView = sampler_state {
    texture = <AL_EmitterRT>;
    MinFilter = Linear;
    MagFilter = Linear;
    MipFilter = Point;
    AddressU  = Clamp;
    AddressV = Clamp;
};

////////////////////////////////////////////////////////////////////////////////////////////////

// ���P�x�������L�^���邽�߂̃����_�[�^�[�Q�b�g
texture2D HighLight : RENDERCOLORTARGET <
    float2 ViewPortRatio = {TEXSIZE1,TEXSIZE1};
    int MipLevels = 0;
    string Format = AL_TEXFORMAT ;
    
>;
sampler2D HighLightView = sampler_state {
    texture = <HighLight>;
    MinFilter = Linear;
    MagFilter = Linear;
    MipFilter = Point;
    AddressU  = Border;
    AddressV = Border;
};

// �O�����獂�P�x�������擾���邽�߂̃����_�[�^�[�Q�b�g
shared texture2D ExternalHighLight : RENDERCOLORTARGET <
    float2 ViewPortRatio = {1.0,1.0};
    int MipLevels = 1;
    string Format = AL_TEXFORMAT ;
    
>;
sampler2D ExternalHighLightView = sampler_state {
    texture = <ExternalHighLight>;
    MinFilter = Linear;
    MagFilter = Linear;
    MipFilter = NONE;
    AddressU  = Border;
    AddressV = Border;
};

// X�����̂ڂ������ʂ��L�^���邽�߂̃����_�[�^�[�Q�b�g
texture2D ScnMapX : RENDERCOLORTARGET <
    float2 ViewPortRatio = {TEXSIZE1,TEXSIZE1};
    int MipLevels = 1;
    string Format = AL_TEXFORMAT ;
>;
sampler2D ScnSampX = sampler_state {
    texture = <ScnMapX>;
    MinFilter = Linear;
    MagFilter = Linear;
    MipFilter = Point;
    AddressU  = Clamp;
    AddressV = Clamp;
};

// �o�͌��ʂ��L�^���邽�߂̃����_�[�^�[�Q�b�g
texture2D ScnMapOut : RENDERCOLORTARGET <
    float2 ViewPortRatio = {TEXSIZE1,TEXSIZE1};
    int MipLevels = 1;
    string Format = AL_TEXFORMAT ;
>;
sampler2D ScnSampOut = sampler_state {
    texture = <ScnMapOut>;
    MinFilter = Linear;
    MagFilter = Linear;
    MipFilter = Point;
    AddressU  = Clamp;
    AddressV = Clamp;
};

// X�����̂ڂ������ʂ��L�^���邽�߂̃����_�[�^�[�Q�b�g
texture2D ScnMapX2 : RENDERCOLORTARGET <
    float2 ViewPortRatio = {TEXSIZE2,TEXSIZE2};
    int MipLevels = 1;
    string Format = AL_TEXFORMAT ;
>;
sampler2D ScnSampX2 = sampler_state {
    texture = <ScnMapX2>;
    MinFilter = Linear;
    MagFilter = Linear;
    MipFilter = Point;
    AddressU  = Clamp;
    AddressV = Clamp;
};

// �o�͌��ʂ��L�^���邽�߂̃����_�[�^�[�Q�b�g
texture2D ScnMapOut2 : RENDERCOLORTARGET <
    float2 ViewPortRatio = {TEXSIZE2,TEXSIZE2};
    int MipLevels = 1;
    string Format = AL_TEXFORMAT ;
>;
sampler2D ScnSampOut2 = sampler_state {
    texture = <ScnMapOut2>;
    MinFilter = Linear;
    MagFilter = Linear;
    MipFilter = Point;
    AddressU  = Clamp;
    AddressV = Clamp;
};

// X�����̂ڂ������ʂ��L�^���邽�߂̃����_�[�^�[�Q�b�g
texture2D ScnMapX3 : RENDERCOLORTARGET <
    float2 ViewPortRatio = {TEXSIZE3,TEXSIZE3};
    int MipLevels = 1;
    string Format = AL_TEXFORMAT ;
>;
sampler2D ScnSampX3 = sampler_state {
    texture = <ScnMapX3>;
    MinFilter = Linear;
    MagFilter = Linear;
    MipFilter = Point;
    AddressU  = Clamp;
    AddressV = Clamp;
};

// �o�͌��ʂ��L�^���邽�߂̃����_�[�^�[�Q�b�g
texture2D ScnMapOut3 : RENDERCOLORTARGET <
    float2 ViewPortRatio = {TEXSIZE3,TEXSIZE3};
    int MipLevels = 1;
    string Format = AL_TEXFORMAT ;
>;
sampler2D ScnSampOut3 = sampler_state {
    texture = <ScnMapOut3>;
    MinFilter = Linear;
    MagFilter = Linear;
    MipFilter = Point;
    AddressU  = Clamp;
    AddressV = Clamp;
};

// X�����̂ڂ������ʂ��L�^���邽�߂̃����_�[�^�[�Q�b�g
texture2D ScnMapX4 : RENDERCOLORTARGET <
    float2 ViewPortRatio = {TEXSIZE4,TEXSIZE4};
    int MipLevels = 1;
    string Format = AL_TEXFORMAT ;
>;
sampler2D ScnSampX4 = sampler_state {
    texture = <ScnMapX4>;
    MinFilter = Linear;
    MagFilter = Linear;
    MipFilter = Point;
    AddressU  = Clamp;
    AddressV = Clamp;
};

// �o�͌��ʂ��L�^���邽�߂̃����_�[�^�[�Q�b�g
texture2D ScnMapOut4 : RENDERCOLORTARGET <
    float2 ViewPortRatio = {TEXSIZE4,TEXSIZE4};
    int MipLevels = 1;
    string Format = AL_TEXFORMAT ;
>;
sampler2D ScnSampOut4 = sampler_state {
    texture = <ScnMapOut4>;
    MinFilter = Linear;
    MagFilter = Linear;
    MipFilter = Point;
    AddressU  = Clamp;
    AddressV = Clamp;
};

// X�����̂ڂ������ʂ��L�^���邽�߂̃����_�[�^�[�Q�b�g
texture2D ScnMapX5 : RENDERCOLORTARGET <
    float2 ViewPortRatio = {TEXSIZE5,TEXSIZE5};
    int MipLevels = 1;
    string Format = AL_TEXFORMAT ;
>;
sampler2D ScnSampX5 = sampler_state {
    texture = <ScnMapX5>;
    MinFilter = Linear;
    MagFilter = Linear;
    MipFilter = Point;
    AddressU  = Clamp;
    AddressV = Clamp;
};

// �o�͌��ʂ��L�^���邽�߂̃����_�[�^�[�Q�b�g
texture2D ScnMapOut5 : RENDERCOLORTARGET <
    float2 ViewPortRatio = {TEXSIZE5,TEXSIZE5};
    int MipLevels = 1;
    string Format = AL_TEXFORMAT ;
>;
sampler2D ScnSampOut5 = sampler_state {
    texture = <ScnMapOut5>;
    MinFilter = Linear;
    MagFilter = Linear;
    MipFilter = Point;
    AddressU  = Clamp;
    AddressV = Clamp;
};

// �O���A���L�^���邽�߂̃����_�[�^�[�Q�b�g
texture2D ScnMapGlare : RENDERCOLORTARGET <
    float2 ViewPortRatio = {TEXSIZE2,TEXSIZE2};
    int MipLevels = 1;
    string Format = AL_TEXFORMAT ;
>;
sampler2D ScnSampGlare = sampler_state {
    texture = <ScnMapGlare>;
    MinFilter = Linear;
    MagFilter = Linear;
    MipFilter = Point;
    AddressU  = Clamp;
    AddressV = Clamp;
};



////////////////////////////////////////////////////////////////////////////////////////////////

//�[�x�t���x���V�e�B�}�b�v�쐬
shared texture DVMapDraw: OFFSCREENRENDERTARGET <
    string Description = "Depth && Velocity Map Drawing";
    float2 ViewPortRatio = {VPRATIO,VPRATIO};
    float4 ClearColor = { 0.5, 0.5, 100, 1 };
    float ClearDepth = 1.0;
    string Format = VM_TEXFORMAT ;
    bool AntiAlias = false;
    int MipLevels = 1;
    string DefaultEffect = 
        "self = hide;"
        "* = TCLX_Object.fxsub;"
        ;
>;

sampler DVSampler = sampler_state {
    texture = <DVMapDraw>;
    AddressU  = CLAMP;
    AddressV = CLAMP;
    Filter = NONE;
};


// �[�x�o�b�t�@
texture2D DepthBuffer : RENDERDEPTHSTENCILTARGET <
    float2 ViewPortRatio = {VPRATIO,VPRATIO};
    string Format = "D24S8";
>;
texture2D DepthBuffer2 : RENDERDEPTHSTENCILTARGET <
    float2 ViewPortRatio = {TEXSIZE2,TEXSIZE2};
    string Format = "D24S8";
>;
texture2D DepthBuffer3 : RENDERDEPTHSTENCILTARGET <
    float2 ViewPortRatio = {TEXSIZE3,TEXSIZE3};
    string Format = "D24S8";
>;
texture2D DepthBuffer4 : RENDERDEPTHSTENCILTARGET <
    float2 ViewPortRatio = {TEXSIZE4,TEXSIZE4};
    string Format = "D24S8";
>;
texture2D DepthBuffer5 : RENDERDEPTHSTENCILTARGET <
    float2 ViewPortRatio = {TEXSIZE5,TEXSIZE5};
    string Format = "D24S8";
>;

// �I���W�i���̕`�挋�ʂ��L�^���邽�߂̃����_�[�^�[�Q�b�g
texture2D ScnMap : RENDERCOLORTARGET <
    float2 ViewPortRatio = {VPRATIO,VPRATIO};
    int MipLevels = 0;
    string Format = DB_TEXFORMAT;
>;
sampler2D ScnSamp = sampler_state {
    texture = <ScnMap>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = LINEAR;
    AddressU  = CLAMP;
    AddressV = CLAMP;
};


// X�����̂ڂ������ʂ��L�^���邽�߂̃����_�[�^�[�Q�b�g
texture2D ScnMap2 : RENDERCOLORTARGET <
    float2 ViewPortRatio = {VPRATIO,VPRATIO};
    int MipLevels = 1;
    string Format = DB_TEXFORMAT;
>;
sampler2D ScnSamp2 = sampler_state {
    texture = <ScnMap2>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = LINEAR;
    AddressU  = CLAMP;
    AddressV = CLAMP;
};


//���C���u���[�o�̓o�b�t�@

#if LINEBLUR_QUAD==0
    #define LINEBLUR_GRIDSIZE 128
    #define LINEBLUR_BUFSIZE  256
#else
    #define LINEBLUR_GRIDSIZE 256
    #define LINEBLUR_BUFSIZE  512
    
    int loopindex = 0;
    int loopcount = 4;
    
#endif

texture2D LineBluerDepthBuffer : RENDERDEPTHSTENCILTARGET <
    int Width = LINEBLUR_BUFSIZE;
    int Height = LINEBLUR_BUFSIZE;
    string Format = "D24S8";
>;
texture2D LineBluerTex : RENDERCOLORTARGET <
    int Width = LINEBLUR_BUFSIZE;
    int Height = LINEBLUR_BUFSIZE;
    int MipLevels = 1;
    string Format = DB_TEXFORMAT;
>;
sampler2D LineBluerSamp = sampler_state {
    texture = <LineBluerTex>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = LINEAR;
    AddressU  = CLAMP;
    AddressV = CLAMP;
};

texture2D LineBluerInfoTex : RENDERCOLORTARGET <
    int Width = LINEBLUR_BUFSIZE;
    int Height = LINEBLUR_BUFSIZE;
    int MipLevels = 1;
    string Format = VM_TEXFORMAT;
>;
sampler2D LineBluerInfoSamp = sampler_state {
    texture = <LineBluerInfoTex>;
    MinFilter = NONE;
    MagFilter = NONE;
    MipFilter = NONE;
    AddressU  = CLAMP;
    AddressV = CLAMP;
};

//���X�N���[���Q�Ǝ��̃~�b�v���x��
static float ScnMipLevel1 = log2(ViewportSize.y / LINEBLUR_GRIDSIZE) + 0.5;
static float ScnMipLevel2 = log2(ViewportSize.y / LINEBLUR_BUFSIZE) + 0.5;


//�J�����ʒu�̋L�^

#define INFOBUFSIZE 2

float2 InfoBufOffset = float2(0.5 / INFOBUFSIZE, 0.5);

texture CameraBufferMB : RenderDepthStencilTarget <
   int Width=INFOBUFSIZE;
   int Height=1;
    string Format = "D24S8";
>;
texture CameraBufferTex : RenderColorTarget
<
    int Width=INFOBUFSIZE;
    int Height=1;
    bool AntiAlias = false;
    int Miplevels = 1;
    string Format="A32B32G32R32F";
>;

float4 CameraBuffer[INFOBUFSIZE] : TEXTUREVALUE <
    string TextureName = "CameraBufferTex";
>;

//�J�����ʒu
float3 CameraPosition : POSITION  < string Object = "Camera"; >;
float3 CameraDirection : DIRECTION < string Object = "Camera"; >;

//�V�[���؂�ւ����ǂ�������
static bool IsSceneChange = (length(CameraPosition - CameraBuffer[0].xyz) > SceneChangeThreshold)
                            || (dot(CameraDirection, CameraBuffer[1].xyz) < cos(SceneChangeAngleThreshold * 3.14 / 180));




////////////////////////////////////////////////////////////////////////////////////////////////
// ���ʒ��_�V�F�[�_
struct VS_OUTPUT {
    float4 Pos            : POSITION;
    float2 Tex            : TEXCOORD0;
};

VS_OUTPUT VS_passDraw( float4 Pos : POSITION, float2 Tex : TEXCOORD0 ) {
    VS_OUTPUT Out = (VS_OUTPUT)0; 
    
    Out.Pos = Pos;
    Out.Tex = Tex + ViewportOffset;
    
    return Out;
}


////////////////////////////////////////////////////////////////////////////////////////////////
//DOF�ڂ������x�}�b�v�擾�֐��Q

float DOF_GetDepthMap(float2 screenPos){
    return tex2Dlod( DVSampler, float4(screenPos, 0, 0) ).z;
    
}

// �œ_��艜�� ////////////////////////////////////////////

float DOF_DeepDepthToBlur(float depth){
    float blrval = max(depth - (1.0 / SCALE_VALUE), 0);
    blrval = pow(blrval, 0.6);
    return blrval;
}

float GetDeepBlurMap(float2 screenPos){
    float depth = DOF_GetDepthMap(screenPos);
    float blr = DOF_DeepDepthToBlur(depth);
    blr = min(DOF_BlurLimitScaled, blr);
    return blr;
}


// �œ_����O�� ////////////////////////////////////////////

float DOF_GetShallowBlurMap(float2 screenPos){
    float depth = DOF_GetDepthMap(screenPos);
    float blr = max((depth - (1.0 / SCALE_VALUE)) * -SCALE_VALUE, 0);
    
    return blr;
}

float DOF_ShallowBlurLoopValue(){
    float val = (float)(ShallowBlurLoopIndex + 1) / DOF_Shallow_LOOP;
    val = pow(val, 1 + ShallowDOFPower * 0.1);
    return val;
}

float DOF_GetShallowBlurMapLoopAlpha(float2 screenPos){
    float blrval = DOF_GetShallowBlurMap(screenPos);
    float blrtgt = DOF_ShallowBlurLoopValue();
    //blrval = sqrt(blrval);
    blrtgt = sqrt(blrtgt);
    return max(0, 1.0 - (abs(blrval - blrtgt) * (float)ShallowBlurLoopCount));
}


////////////////////////////////////////////////////////////////////////////////////////////////

float DOF_BlurRate(float blr_samp, float blr_cnt){
    float r = blr_samp / blr_cnt;
    return pow(saturate(r), 2);
}

////////////////////////////////////////////////////////////////////////////////////////////////
// �o�b�t�@�̃R�s�[

float4 PS_BufCopy( float2 Tex: TEXCOORD0 , uniform sampler2D samp ) : COLOR {   
    return tex2Dlod( samp , float4(Tex, 0, 0) );
}


////////////////////////////////////////////////////////////////////////////////////////////////
//�[�x�t���x���V�e�B�}�b�v�Q�Ɗ֐��Q

#define VELMAP_SAMPLER  DVSampler
#define MB_DEPTH w

//�}�b�v�i�[��񂩂瑬�x�x�N�g���𓾂�
float2 MB_VelocityPreparation(float4 rawvec){
    float2 vel = rawvec.xy - 0.5;
    float len = length(vel);
    vel = max(0, len - VelocityUnderCut) * normalize(vel);
    
    vel = min(vel, float2(VelocityLimit, VelocityLimit));
    vel = max(vel, float2(-VelocityLimit, -VelocityLimit));
    
    return vel;
}

float2 MB_GetBlurMap(float2 Tex){
    return MB_VelocityPreparation(tex2Dlod( VELMAP_SAMPLER, float4(Tex, 0, 0) ));
}

float MB_GetDepthMap(float2 Tex){
    return tex2Dlod( VELMAP_SAMPLER, float4(Tex, 0, 0) ).MB_DEPTH;
}

float2 MB_GetBlurMapAround(float2 Tex){
    float4 vm, vms;
    const float step = 4.5 / LINEBLUR_BUFSIZE;
    float z0, n = 1;
    
    vms = tex2Dlod( VELMAP_SAMPLER, float4(Tex, 0, 0) );
    
    z0 = vms.MB_DEPTH;
    
    vm = tex2Dlod( VELMAP_SAMPLER, float4( Tex.x + step, Tex.y , 0, 0) );
    vms += vm * (vm.MB_DEPTH >= z0);
    n += (vm.MB_DEPTH >= z0);
    
    vm = tex2Dlod( VELMAP_SAMPLER, float4( Tex.x - step, Tex.y , 0, 0) );
    vms += vm * (vm.MB_DEPTH >= z0);
    n += (vm.MB_DEPTH >= z0);
    
    vm = tex2Dlod( VELMAP_SAMPLER, float4( Tex.x, Tex.y + step , 0, 0) );
    vms += vm * (vm.MB_DEPTH >= z0);
    n += (vm.MB_DEPTH >= z0);
    
    vm = tex2Dlod( VELMAP_SAMPLER, float4( Tex.x, Tex.y - step , 0, 0) );
    vms += vm * (vm.MB_DEPTH >= z0);
    n += (vm.MB_DEPTH >= z0);
    
    vms /= n;
    
    return MB_VelocityPreparation(vms);
}



////////////////////////////////////////////////////////////////////////////////////////////////
// DOF

////////////////////////////////////////////////////////////////////////////////////////////////
// �����ڂ���

float4 PS_DeepDOF( VS_OUTPUT IN , uniform bool Horizontal, uniform sampler2D Samp ) : COLOR {   
    float e, n = 0;
    float2 stex;
    float4 Color, sum = 0;
    float centerblr = GetDeepBlurMap(IN.Tex);
    float step = (Horizontal ? DOF_SampStepScaled.x : DOF_SampStepScaled.y) * centerblr;
    float depth, centerdepth = DOF_GetDepthMap(IN.Tex) - 0.01;
    
    [unroll] //���[�v�W�J
    for(int i = -SAMP_NUM; i <= SAMP_NUM; i++){
        e = exp(-pow((float)i / (SAMP_NUM / 2.0), 2) / 2); //���K���z
        stex = IN.Tex + float2(Horizontal, !Horizontal) * (step * (float)i);
        
        //��O���s���g�̍����Ă��镔������̃T���v�����O�͎キ
        depth = DOF_GetDepthMap(stex);
        float blrrate = DOF_BlurRate(DOF_DeepDepthToBlur(depth), centerblr);
        e *= max(blrrate, (depth >= centerdepth));
        
        #if DOF_EXPBLUR==0
            sum += tex2D( Samp, stex ) * e;
        #else
            sum += exp(tex2D( Samp, stex )) * e;
        #endif
        
        n += e;
    }
    
    Color = sum / n;
    
    #if DOF_EXPBLUR!=0
        Color = log(Color);
    #endif
    
    return Color;
}

////////////////////////////////////////////////////////////////////////////////////////////////
// ��O��X�����ڂ���

float4 PS_ShallowDOF_X(float2 Tex: TEXCOORD0) : COLOR {   
    float4 Color, sum = 0;
    float e, n = 0;
    float loopval = DOF_ShallowBlurLoopValue();
    float step = DOF_SampStepScaled.x * min(DOF_BlurLimitScaled, loopval) * ShallowDOFPower;
    
    [unroll] //���[�v�W�J
    for(int i = -SAMP_NUM ; i <= SAMP_NUM; i++){
        float2 stex = Tex + float2(1, 0) * (float)i * step;
        e = exp(-pow((float)i / (SAMP_NUM / 2.0), 2) / 2); //���K���z
        
        float4 org_color = tex2D( ScnSampX , stex );
        org_color.a *= DOF_GetShallowBlurMapLoopAlpha(stex);
        sum += org_color * e;
        n += e;
    }
    
    Color = sum / n;
    return Color;
}

////////////////////////////////////////////////////////////////////////////////////////////////
// ��O��X�����ڂ���

float4 PS_ShallowDOF_Y( float2 Tex: TEXCOORD0 ) : COLOR {   
    float4 Color, sum = 0;
    float e, n = 0;
    float loopval = DOF_ShallowBlurLoopValue();
    float step = DOF_SampStepScaled.y * min(DOF_BlurLimitScaled, loopval) * ShallowDOFPower;
    
    [unroll] //���[�v�W�J
    for(int i = -SAMP_NUM; i <= SAMP_NUM; i++){
        float2 stex = Tex + float2(0, 1) * (float)i * step;
        e = exp(-pow((float)i / (SAMP_NUM / 2.0), 2) / 2); //���K���z
        sum += tex2D( ScnSamp2, stex ) * e;
        n += e;
    }
    
    Color = sum / n;
    
    float ar = (2.5 + step * (350 * SAMP_NUM / 8));
    Color.a = saturate(min(Color.a * ar, loopval * ar * 0.4));
    
    //float p = DOF_GetShallowBlurMap(Tex);
    //Color = float4(p,p,p,1);
    
    return Color;
}


////////////////////////////////////////////////////////////////////////////////////////////////
// MotionBlur
////////////////////////////////////////////////////////////////////////////////////////////////
//�x���V�e�B�}�b�v�ɏ]���������u���[��������

struct PS_OUTPUT_DBL
{
   float4 Color0 : COLOR0;
   float4 Color1 : COLOR1;
};

PS_OUTPUT_DBL PS_DirectionalBlur( float2 Tex: TEXCOORD0, uniform sampler2D samp , uniform sampler2D samp2 ) {   
    float e, n = 0;
    float2 stex;
    //float4 Color;
    PS_OUTPUT_DBL Out = (PS_OUTPUT_DBL)0;
    float4 sum = 0, sum2 = 0;
    float2 vel = MB_GetBlurMap(Tex);
    
    float4 info;
    float2 step = MBlurSampStepScaled * vel / SAMP_NUM;
    float depth, centerdepth = MB_GetDepthMap(Tex) - 0.01;
    
    float bp = saturate(length(vel) * 10);
    
    step *= (!IsSceneChange); //�V�[���؂�ւ��̓u���[����
    
    [unroll] //���[�v�W�J
    for(int i = -SAMP_NUM; i <= SAMP_NUM; i++){
        e = exp(-pow((float)i / (SAMP_NUM / 2.0), 2) / 2); //���K���z
        stex = Tex + (step * (float)i);
        
        //��O�����܂蓮���Ă��Ȃ���������̃T���v�����O�͎キ
        if(i != 0){
            depth = MB_GetDepthMap(stex);
            e *= max(saturate(length(MB_GetBlurMap(stex)) / 0.02), (depth > centerdepth));
        }
        
        //�T���v�����O
        sum += tex2D( samp, stex ) * e;
        sum2 += tex2D( samp2, stex ) * e;
        n += e;
    }
    
    Out.Color0 = sum / n;
    Out.Color1 = sum2 / n;
    
    return Out;
    
}



////////////////////////////////////////////////////////////////////////////////////////////////
//���C���u���[�o�̓o�b�t�@�̏����l�ݒ�


struct PS_OUTPUT_CLB
{
   float4 Color : COLOR0;
   float4 Info  : COLOR1;
};

PS_OUTPUT_CLB PS_ClearLineBluer( float2 Tex: TEXCOORD0 ) {
    
    PS_OUTPUT_CLB OUT = (PS_OUTPUT_CLB)0;
    
    //�A���t�@�l��0�ɂ������X�N���[���摜�Ŗ��߂�
    OUT.Color = tex2D( ScnSamp, Tex );
    OUT.Color.a = 0;
    
    //���C���u���[�Ŏg�p������}�b�v���o��
    OUT.Info.xy = MB_GetBlurMapAround( Tex );
    OUT.Info.z = MB_GetDepthMap( Tex );
    OUT.Info.w = 1;
    
    return OUT;
}


/////////////////////////////////////////////////////////////////////////////////////
//���C���u���[�`��

struct VS_OUTPUT3 {
    float4 Pos: POSITION;
    float4 Color: COLOR0;
    float3 Tex : TEXCOORD0;
    float2 BaseVel : TEXCOORD1;
    float2 Tex2 : TEXCOORD2;
};

VS_OUTPUT3 VS_LineBluer(float4 Pos : POSITION, int index: _INDEX)
{
    VS_OUTPUT3 Out;
    float2 PosEx = Pos.xy;
    //bool IsTip = (Pos.x > 0); //���C���̐L�т���[
    
    float findex = Pos.z;
    
#if LINEBLUR_QUAD!=0
    findex += loopindex * (128 * 128);
#endif
    
    float2 findex_xy = float2(findex % LINEBLUR_GRIDSIZE, trunc(findex / LINEBLUR_GRIDSIZE));
    
    float2 TexPos = findex_xy / LINEBLUR_GRIDSIZE;
    float2 ScreenPos = (TexPos * 2 - 1) * float2(1,-1);
    
    //�x���V�e�B�}�b�v�Q��
    float4 VelMap = tex2Dlod( VELMAP_SAMPLER, float4(TexPos, 0, 0) );
    float2 Velocity = MB_VelocityPreparation(VelMap);
    
    float2 AspectedVelocity = -Velocity / float2(ViewportAspect, 1);
    
    float VelLen = length(Velocity) * alpha1;
    
    Out.BaseVel = Velocity; //PS�ɑ��x��n���B
    
    Out.Tex2 = Pos.xy;
    
    //���C����
    PosEx *= (1.0 / LINEBLUR_GRIDSIZE);
    //���C������
    PosEx.x += Pos.x * sqrt(VelLen) * 0.08 * LineBlurLength;
    
    
    //�΂߃��C���͑���
    PosEx.y *= 1.5 + 0.4 * abs(sin(atan2(AspectedVelocity.x, AspectedVelocity.y) * 2));
    
    //���C����]
    float2 AxU = normalize(AspectedVelocity);
    float2 AxV = float2(AxU.y, -AxU.x);
    
    PosEx = PosEx.x * AxU + PosEx.y * AxV;
    
    //���_�ʒu�ɂ��T���v�����O�ʒu�̃I�t�Z�b�g
    //TexPos += (-Pos.y * AxV) / (LINEBLUR_GRIDSIZE * 2);
    
    //���X�N���[���Q��
    Out.Color = tex2Dlod( ScnSamp, float4(TexPos, 0, ScnMipLevel1) );
    
    //�u���[���x����A���t�@�ݒ�E���C����[�͓�����
    //Out.Color.a *= saturate(VelLen * 250) * (1 - IsTip);
    Out.Color.a *= saturate(VelLen * 250);
    
    Out.Color.a *= (!IsSceneChange); //�V�[���؂�ւ��̓u���[����
    
    //�o�b�t�@�o��
    Out.Pos.xy = ScreenPos + PosEx + (2000 * (Out.Color.a < 0.01));
    Out.Pos.z = 0;
    Out.Pos.w = 1;
    
    //�X�N���[���e�N�X�`�����W
    Out.Tex.xy = (Out.Pos.xy * float2(1,-1) + 1) * 0.5 + (0.5 / LINEBLUR_BUFSIZE);
    Out.Tex.z = VelMap.z; //TEXCOORD0��Z���؂�āA�c���̔�������Z�l��n��
    
    return Out;
}

float4 PS_LineBluer( VS_OUTPUT3 IN ) : COLOR0
{
    
    float4 Info = tex2D( LineBluerInfoSamp, IN.Tex.xy);
    float4 Color = IN.Color;
    float alpha = 1.0 - abs(IN.Tex2.x); //��[�𓧖���
    
    Color.a *= alpha;
    
    float BaseZ = Info.z; //���摜��Z
    float AfImZ = IN.Tex.z; //�c����Z
    
    //��O�̃I�u�W�F�N�g��̎c���͉B��
    Color.a *= saturate(1 - (AfImZ - BaseZ) * 3);
    //Color.a *= saturate(1 - (AfImZ - BaseZ) * 200);
    
    float2 vel = Info.xy;
    
    //�w�i�̑��x�x�N�g������v���Ă���Ƃ��͔���
    float vdrate = max(length(vel), length(IN.BaseVel));
    vdrate = (vdrate == 0) ? 0 : (1 / vdrate);
    float VelDif = length(vel - IN.BaseVel) * vdrate;
    Color.a *= saturate(VelDif);
    
    return Color;
}


////////////////////////////////////////////////////////////////////////////////////////////////
//���C���u���[�̍���

VS_OUTPUT VS_MixLineBluer( float4 Pos : POSITION, float2 Tex : TEXCOORD0 ) {
    VS_OUTPUT Out = (VS_OUTPUT)0; 
    
    Out.Pos = Pos;
    Out.Tex = Tex + (0.5 / LINEBLUR_BUFSIZE);
    
    return Out;
}

#define LBSAMP LineBluerSamp

float4 PS_MixLineBluer( float2 Tex: TEXCOORD0 ) : COLOR {   
    float2 step = 1.4 / LINEBLUR_BUFSIZE;
    float4 Color = tex2D( LineBluerSamp, Tex);
    
    //������𑜓x�Ȃ̂ŁA�W���M�[�����̂��߂Ɍy���ڂ���
    [unroll] for(int j = -1; j <= 1; j++){
        [unroll] for(int i = -1; i <= 1; i++){
            Color += tex2D( LineBluerSamp, Tex + step * float2(i,j) );
            
        }
    }
    
    Color /= 10;
    
    Color.a *= LineBlurStrength;
    
    return Color;
}

////////////////////////////////////////////////////////////////////////////////////////////////
//�J�����ʒu�̋L�^

VS_OUTPUT VS_CameraBuffer( float4 Pos : POSITION, float2 Tex : TEXCOORD0 ) {
    VS_OUTPUT Out = (VS_OUTPUT)0; 
    
    Out.Pos = Pos;
    Out.Tex = Tex + InfoBufOffset;
    
    return Out;
}

float4 PS_CameraBuffer( float4 Tex : TEXCOORD0 ) : COLOR {   
    float4 Color = float4(CameraPosition, 1);
    Color = (Tex.x >= 0.5) ? float4(CameraDirection, 1) : Color;
    return Color;
}


////////////////////////////////////////////////////////////////////////////////////////////////
// ���Ꮘ��

#if FISHEYE_ENABLE!=0

float4 PS_FishEye( float2 Tex: TEXCOORD0 ) : COLOR {   
    float4 Color;
    float2 tex_conv;
    
    if(true){
        tex_conv = Tex - 0.5;
        tex_conv.x *= ViewportAspect;
        
        float D = 1;
        float r = length(tex_conv);
        float2 dir = normalize(tex_conv);
        
        float vang1 = viewangle * 2 * FishEyeStregth;
        float resize = 1;
        
        float phai = r * vang1;
        r = asin(phai);
        r /= (vang1);
        
        tex_conv = r * dir;
        tex_conv.x /= ViewportAspect;
        tex_conv += 0.5;
        
        Color = tex2D( ScnSamp, tex_conv );
        
        //�\���̈�O�͍��œh��Ԃ�
        Color = (0 <= phai && phai <= 1) ? Color : float4(0,0,0,1);
        Color = (0 <= tex_conv.x && tex_conv.x <= 1 && 0 <= tex_conv.y && tex_conv.y <= 1) ? Color : float4(0,0,0,1);
        
        Color = (BetaSize <= Tex.x && Tex.x <= (1 - BetaSize) && BetaSize <= Tex.y && Tex.y <= (1 - BetaSize)) ? Color : float4(0,0,0,1);
        
    }else{
        
        Color = tex2D( ScnSamp2, Tex );
        
    }
    
    return Color;
}

#endif


////////////////////////////////////////////////////////////////////////////////////////////////
//AutoLuminous


float4 PS_HighLightDOF( float2 Tex: TEXCOORD0, uniform sampler2D Samp ) : COLOR {
    /*
    float4 Color;
    
    Color = tex2Dlod(Samp, float4(Tex,0,0));
    
    return Color;
    */
    
    
    ///*
    
    if(!FocusEnable) {
        return tex2Dlod(Samp, float4(Tex,0,0));
        
    }else{
    
    //�ȈՋʃ{�P�\��
    int x, y;
    float e, n = 0;
    float2 stex;
    float4 Color, sum = 0;
    float centerblr = GetDeepBlurMap(Tex);
    float2 step = DOF_SampStepScaled * centerblr * (1.0 * SAMP_NUM / LightDOF_SAMP_NUM);
    float depth, centerdepth = DOF_GetDepthMap(Tex) - 0.01;
    
    [unroll] //���[�v�W�J
    for(y = -LightDOF_SAMP_NUM; y <= LightDOF_SAMP_NUM; y++){
        [unroll] //���[�v�W�J
        for(x = -LightDOF_SAMP_NUM; x <= LightDOF_SAMP_NUM; x++){
            
            e = (x*x+y*y <= LightDOF_SAMP_NUM*LightDOF_SAMP_NUM); //�~�`
            stex = Tex + float2(x, y) * step;
            
            //��O���s���g�̍����Ă��镔������̃T���v�����O�͎キ
            //depth = DOF_GetDepthMap(stex);
            //float blrrate = DOF_BlurRate(DOF_DeepDepthToBlur(depth), centerblr);
            //e *= max(blrrate, (depth >= centerdepth));
            
            sum += exp(tex2D( Samp, stex )) * e;
            n += e;
            
        }
    }
    
    Color = log(sum / n);
    
    return Color;
    
    }
    //*/
    
}


////////////////////////////////////////////////////////////////////////////////////////////////
// ���Ƃѕ\���֐�
float4 OverExposure(float4 color){
    float4 newcolor = color;
    
    //����F��1�𒴂���ƁA���̐F�ɂ��ӂ��
    newcolor.gb += max(color.r - 1, 0) * OverExposureRatio * float2(0.65, 0.6);
    newcolor.rb += max(color.g - 1, 0) * OverExposureRatio * float2(0.5, 0.6);
    newcolor.rg += max(color.b - 1, 0) * OverExposureRatio * float2(0.5, 0.6);
    
    return newcolor;
}


////////////////////////////////////////////////////////////////////////////////////////////////
//�g�[���J�[�u�̒���
//�����ł������ǂ��Ȃ��Ă��邩�悭�킩��Ȃ��֐��ɂȂ��Ă��܂������A
//���ƂȂ����܂������Ă���̂ŕ|���Ă�����Ȃ�

float4 ToneCurve(float4 Color){
    float3 newcolor;
    const float th = 0.65;
    newcolor = normalize(Color.rgb) * (th + sqrt(max(0, (length(Color.rgb) - th) / 2)));
    newcolor.r = (Color.r > 0) ? newcolor.r : Color.r;
    newcolor.g = (Color.g > 0) ? newcolor.g : Color.g;
    newcolor.b = (Color.b > 0) ? newcolor.b : Color.b;
    
    Color.rgb = min(Color.rgb, newcolor);
    
    return Color;
}


////////////////////////////////////////////////////////////////////////////////////////////////
//AL���ʒ��_�V�F�[�_

VS_OUTPUT VS_ALDraw( float4 Pos : POSITION, float2 Tex : TEXCOORD0 , uniform int miplevel) {
    VS_OUTPUT Out = (VS_OUTPUT)0; 
    
    #ifdef MIKUMIKUMOVING
    float ofsetsize = 1;
    #else
    float ofsetsize = pow(2, miplevel);
    #endif
    
    Out.Pos = Pos;
    Out.Tex = Tex + float2(ViewportOffset.x, ViewportOffset.y) * ofsetsize;
    
    return Out;
}

////////////////////////////////////////////////////////////////////////////////////////////////
//���P�x�����̒��o

float4 PS_DrawHighLight( float2 Tex: TEXCOORD0 ) : COLOR0 {
    float4 Color, OrgColor, OverLightColor, ExtColor;
    
    Color = tex2Dlod(EmitterView, float4(Tex, 0, 0));
    //Color.a = 0;
    
    //���X�N���[���̍��P�x�����̒��o
    OrgColor = tex2Dlod(ScnSamp, float4(Tex, 0, 0));
    OverLightColor = OrgColor * OverLight;
    OverLightColor = max(0, OverLightColor - 0.98);
    OverLightColor = ToneCurve(OverLightColor);
    
    Color *= timerate;
    
    ExtColor = tex2Dlod(ExternalHighLightView, float4(Tex, 0, 0));
    Color.rgb += (OverLightColor.rgb * !ExternLightSampling + ExtColor.rgb);
    
    Color *= scaling * 2;
    
    Color.a = 1;
    
    return Color;
}

////////////////////////////////////////////////////////////////////////////////////////////////

#define HLSampler HighLightView

////////////////////////////////////////////////////////////////////////////////////////////////
// MipMap���p�ڂ���

float4 PS_AL_Gaussian( float2 Tex: TEXCOORD0, 
           uniform bool Horizontal, uniform sampler2D Samp, 
           uniform int miplevel, uniform int scalelevel
           ) : COLOR {
    
    float e, n = 0;
    float2 stex;
    float4 Color, sum = 0;
    float scalepow = pow(2, scalelevel);
    float step = (Horizontal ? AL_SampStepScaled.x : AL_SampStepScaled.y) * scalepow;
    const float2 dir = float2(Horizontal, !Horizontal);
    float4 scolor;
    
    [unroll] //���[�v�W�J
    for(int i = -AL_SAMP_NUM; i <= AL_SAMP_NUM; i++){
        e = exp(-pow((float)i / (AL_SAMP_NUM / 2.0), 2) / 2); //���K���z
        stex = Tex + dir * (step * (float)i);
        scolor = tex2Dlod( Samp, float4(stex, 0, miplevel));
        sum += scolor * e;
        n += e;
    }
    
    Color = sum / n;
    
    //��P�x�̈�̌��̍L����𐧌�
    //if(!Horizontal) Color = max(0, abs(Color) - scalepow * (2 - alpha1) * 0.002) * sign(Color);
    //Color = max(0, abs(Color) - scalepow * 0.0007) * sign(Color);
    if(!Horizontal) Color = min(abs(Color), pow(abs(Color), 1 + scalelevel * 0.1 * (2 - alpha1) * Modest)) * sign(Color);
    
    return Color;
}


////////////////////////////////////////////////////////////////////////////////////////////////

float4 PS_AL_DirectionalBlur( float2 Tex: TEXCOORD0 , uniform sampler2D Samp, uniform bool isfirst) : COLOR {   
    float e, n = 0;
    float2 stex1, stex2, stex3, stex4;
    float4 Color, sum = 0;
    float4 sum1 = 0, sum2 = 0, sum3 = 0, sum4 = 0;
    
    float step = AL_SampStep2 * (1.0 + cos(AL_LoopIndex * 5.1 + rot.x * 10) * 0.3);
    
    float ang = (AL_LoopIndex * 180.0 / (int)Glare) * PI / 180 + GlareAngle;
    float2 dir = float2(cos(ang) / ViewportAspect, sin(ang)) * step;
    float p = 1;
    
    #if GLARE_LONGONE!=0
        p = (1 + (AL_LoopIndex == 0)) * 0.7;
        dir *= p;
    #endif
    
    [unroll] //���[�v�W�J
    for(int i = -AL_SAMP_NUM2; i <= AL_SAMP_NUM2; i++){
        e = exp(-pow((float)i / (AL_SAMP_NUM2 / 2.0), 2) / 2); //���K���z
        if(isfirst){
            stex1 = Tex + dir * ((float)i * 1.0);
            stex2 = Tex + dir * ((float)i * 1.8);
            stex3 = Tex + dir * ((float)i * 3.9);
            //stex4 = Tex + dir * ((float)i * 7.7);
        }else{
            stex1 = Tex + dir * ((float)i * 0.75);
        }
        if(isfirst){
            sum1 += max(0, tex2Dlod( Samp, float4(stex1, 0, 1) )) * e;
            sum2 += max(0, tex2Dlod( Samp, float4(stex2, 0, 2) )) * e;
            sum3 += max(0, tex2Dlod( Samp, float4(stex3, 0, 3) )) * e;
            //sum4 += max(0, tex2Dlod( Samp, float4(stex4, 0, 4) )) * e;
        }else{
            sum1 += max(0, tex2Dlod( Samp, float4(stex1, 0, 0) )) * e;
        }
        
        n += e;
    }
    
    sum1 /= n;
    sum2 /= n;
    sum3 /= n;
    //sum4 /= n;
    
    sum1 = max(0, sum1 - 0.006); sum2 = max(0, sum2 - 0.015); sum3 = max(0, sum3 - 0.029); //sum4 = max(0, sum4 - 0.032);
    
    Color = sum1 + sum2 + sum3 + sum4;
    
    if(isfirst){
        Color *= GlareAspect;
        Color *= p;
        Color /= sqrt(0.2 + (float)((int)Glare));
        Color = ToneCurve(Color * GlarePower);
    }
    
    return Color;
}

////////////////////////////////////////////////////////////////////////////////////////////////

float4 PS_AL_Mix( float2 Tex: TEXCOORD0 , uniform bool FullOut) : COLOR {
    
    float4 Color;
    
    float crate1 = 1, crate2 = 1, crate3 = 1, crate4 = 0.8;
    
    Color = tex2D(ScnSampOut, Tex);
    Color += tex2D(ScnSampOut2, Tex) * crate1;
    Color += tex2D(ScnSampOut3, Tex) * crate2;
    Color += tex2D(ScnSampOut4, Tex) * crate3;
    Color += tex2D(ScnSampOut5, Tex) * crate4;
    
    Color *= (1 - 0.3 * (Glare >= 1));
    
    Color += tex2D(ScnSampGlare, Tex);
    
    if(!ScreenToneCurve) Color = ToneCurve(Color); //�g�[���J�[�u�̒���
    
    if(!FullOut){
        Color.a = saturate(Color.a);
        return Color;
    }
    
    
    float4 basecolor = tex2D(ScnSamp2, Tex);
    basecolor.rgb *= OverLight;
    Color = Color + basecolor;
    
    //���Ƃѕ\��
    Color = OverExposure(Color);
    
    if(ScreenToneCurve) Color = ToneCurve(Color); //�g�[���J�[�u�̒���
    
    Color.a = basecolor.a + length(Color.rgb);
    Color.a = saturate(Color.a);
    Color.rgb /= Color.a;
    
    return Color;
}



////////////////////////////////////////////////////////////////////////////////////////////////

float4 PS_Test( float2 Tex: TEXCOORD0 ) : COLOR {
    //return float4(tex2D(HighLightView, Tex).rgb, 1);
    //return float4(tex2D(EmitterView, Tex).rgb, 1);
    return float4(tex2D(ScnSamp, Tex).rgb, 1);
    
}

////////////////////////////////////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////////////////////////////////////////
//�e�N�j�b�N

// �����_�����O�^�[�Q�b�g�̃N���A�l
float4 ClearColor = {0,0,0,0};
float4 ClearColor2 = {0,0,0,0};
float ClearDepth  = 1.0;


technique TrueCameraLX <
    string Script = 
        
        "RenderColorTarget0=ExternalHighLight;"
        "ClearSetColor=ClearColor;"
        "Clear=Color;"
        
        "RenderColorTarget0=ScnMap;"
        "RenderDepthStencilTarget=DepthBuffer;"
        "ClearSetColor=BackColor;"
        "ClearSetDepth=ClearDepth;"
        "Clear=Color;"
        "Clear=Depth;"
        "ScriptExternal=Color;"
        
        
        "RenderColorTarget0=HighLight;"
        "ClearSetColor=ClearColor;"
        "Clear=Color;"
        "ClearSetDepth=ClearDepth;"
        "Clear=Depth;"
        "Pass=DrawHighLight;"
        
        
        "LoopByCount=FocusEnable;"
        
            "RenderColorTarget0=ScnMap2;"
            "RenderDepthStencilTarget=DepthBuffer;"
            "ClearSetColor=ClearColor2; Clear=Color;"
            "ClearSetDepth=ClearDepth; Clear=Depth;"
            "Pass=DeepDOF_X;"
            
            "RenderColorTarget0=ScnMapX;"
            "RenderDepthStencilTarget=DepthBuffer;"
            "ClearSetColor=ClearColor2; Clear=Color;"
            "ClearSetDepth=ClearDepth; Clear=Depth;"
            "Pass=DeepDOF_Y;"
            
            
            "RenderColorTarget0=ScnMap;"
            "RenderDepthStencilTarget=DepthBuffer;"
            "ClearSetColor=ClearColor2; Clear=Color;"
            "ClearSetDepth=ClearDepth; Clear=Depth;"
            "Pass=BufCopy;"
            
            
            /*
            
            //�e�X�g
            "RenderColorTarget0=;"
            "RenderDepthStencilTarget=;"
            "ClearSetColor=ClearColor; ClearSetDepth=ClearDepth;"
            "Clear=Depth;"
            "Clear=Color;"
            "Pass=AL_Test;"
            */
            
            "LoopByCount=ShallowBlurLoopCount;"
            "LoopGetIndex=ShallowBlurLoopIndex;"
                
                "RenderColorTarget0=ScnMap2;"
                "RenderDepthStencilTarget=DepthBuffer;"
                "ClearSetColor=ClearColor2; Clear=Color;"
                "ClearSetDepth=ClearDepth; Clear=Depth;"
                "Pass=ShallowDOF_X;"
                
                "RenderColorTarget0=ScnMap;"
                "RenderDepthStencilTarget=DepthBuffer;"
                "Pass=ShallowDOF_Y;"
                
            "LoopEnd=;"
        
        "LoopEnd=;"
        
        
        "RenderColorTarget0=ScnMap2;"
        "RenderColorTarget1=ScnMapX;"
        "RenderDepthStencilTarget=DepthBuffer;"
        "ClearSetColor=BackColor;"
        "ClearSetDepth=ClearDepth;"
        "Clear=Color;"
        "Clear=Depth;"
        "Pass=DirectionalBlur;"
        
        
        "RenderColorTarget0=LineBluerTex;"
        "RenderColorTarget1=LineBluerInfoTex;"
        "RenderDepthStencilTarget=LineBluerDepthBuffer;"
        "ClearSetColor=ClearColor2; Clear=Color;"
        "ClearSetDepth=ClearDepth; Clear=Depth;"
        "Pass=ClearLineBluer;"
        
        "RenderColorTarget0=LineBluerTex;"
        "RenderColorTarget1=;"
        "Clear=Depth;"
        
        #if LINEBLUR_QUAD==0
            //1�񂾂�
            "Pass=DrawLineBluer;"
        #else
            //4��J��Ԃ�
            "LoopByCount=loopcount;"
            "LoopGetIndex=loopindex;"
            "Pass=DrawLineBluer;"
            "LoopEnd=;"
        #endif
        
        
        "RenderColorTarget0=ScnMap2;"
        "RenderDepthStencilTarget=DepthBuffer;"
        //"Clear=Color;"
        "Pass=MixLineBluer;"
        
        
        
        
        
        
        "RenderColorTarget0=HighLight;"
        "RenderDepthStencilTarget=DepthBuffer;"
        "ClearSetColor=ClearColor; ClearSetDepth=ClearDepth;"
        "Clear=Color; Clear=Depth;"
        "Pass=HighLightDOF;"
        
        
        "RenderColorTarget0=ScnMapGlare;"
        "RenderColorTarget1=;"
        "RenderDepthStencilTarget=DepthBuffer2;"
        "Clear=Color; Clear=Depth;"
        
        "LoopByCount=Glare;"
        "LoopGetIndex=AL_LoopIndex;"
            
            "RenderColorTarget0=ScnMapX2;"
            "Clear=Color; Clear=Depth;"
            "Pass=AL_DirectionalBlur1;"
            
            "RenderColorTarget0=ScnMapGlare;"
            "Clear=Depth;"
            "Pass=AL_DirectionalBlur2;"
            
        "LoopEnd=;"
        
        
        "RenderColorTarget0=ScnMapX;"
        "RenderColorTarget1=;"
        "RenderDepthStencilTarget=DepthBuffer;"
        "ClearSetColor=ClearColor; ClearSetDepth=ClearDepth;"
        "Clear=Color; Clear=Depth;"
        "Pass=AL_Gaussian_X;"
        
        "RenderColorTarget0=ScnMapOut;"
        "Clear=Color; Clear=Depth;"
        "Pass=AL_Gaussian_Y;"
        
        "RenderColorTarget0=ScnMapX2;"
        "RenderDepthStencilTarget=DepthBuffer2;"
        "Clear=Color; Clear=Depth;"
        "Pass=AL_Gaussian_X2;"
        
        "RenderColorTarget0=ScnMapOut2;"
        "Clear=Color; Clear=Depth;"
        "Pass=AL_Gaussian_Y2;"
        
        "RenderColorTarget0=ScnMapX3;"
        "RenderDepthStencilTarget=DepthBuffer3;"
        "Clear=Color; Clear=Depth;"
        "Pass=AL_Gaussian_X3;"
        
        "RenderColorTarget0=ScnMapOut3;"
        "Clear=Color; Clear=Depth;"
        "Pass=AL_Gaussian_Y3;"
        
        "RenderColorTarget0=ScnMapX4;"
        "RenderDepthStencilTarget=DepthBuffer4;"
        "Clear=Color; Clear=Depth;"
        "Pass=AL_Gaussian_X4;"
        
        "RenderColorTarget0=ScnMapOut4;"
        "Clear=Color; Clear=Depth;"
        "Pass=AL_Gaussian_Y4;"
        
        
        "RenderColorTarget0=ScnMapX5;"
        "RenderDepthStencilTarget=DepthBuffer5;"
        "Clear=Color; Clear=Depth;"
        "Pass=AL_Gaussian_X5;"
        
        "RenderColorTarget0=ScnMapOut5;"
        "Clear=Color; Clear=Depth;"
        "Pass=AL_Gaussian_Y5;"
        
        
        #if FISHEYE_ENABLE==0
            "RenderColorTarget0=;"
            "RenderDepthStencilTarget=;"
        #else
            "RenderColorTarget0=ScnMap;"
            "RenderDepthStencilTarget=DepthBuffer;"
        #endif
        
        "ClearSetColor=ClearColor; ClearSetDepth=ClearDepth;"
        "Clear=Depth;"
        "Clear=Color;"
        "Pass=AL_Mix;"
        
        
        
        
        
        #if FISHEYE_ENABLE!=0
            "RenderColorTarget=;"
            "RenderDepthStencilTarget=;"
            "Pass=FishEye;"
        #endif
        
        
        
        "RenderColorTarget=CameraBufferTex;"
        "RenderDepthStencilTarget=CameraBufferMB;"
        "Pass=DrawCameraBuffer;"
        
    ;
    
> {
    
    
    //DOF
    
    pass DeepDOF_X < string Script= "Draw=Buffer;"; > {
        AlphaBlendEnable = false;
        AlphaTestEnable = false;
        VertexShader = compile vs_3_0 VS_passDraw();
        PixelShader  = compile ps_3_0 PS_DeepDOF(true, ScnSamp);
    }
    pass DeepDOF_Y < string Script= "Draw=Buffer;"; > {
        AlphaBlendEnable = false;
        AlphaTestEnable = false;
        VertexShader = compile vs_3_0 VS_passDraw();
        PixelShader  = compile ps_3_0 PS_DeepDOF(false, ScnSamp2);
    }
    
    pass BufCopy < string Script= "Draw=Buffer;"; > {
        AlphaBlendEnable = false;
        AlphaTestEnable = false;
        VertexShader = compile vs_3_0 VS_passDraw();
        PixelShader  = compile ps_3_0 PS_BufCopy(ScnSampX);
    }
    
    
    pass ShallowDOF_X < string Script= "Draw=Buffer;"; > {
        AlphaBlendEnable = false;
        AlphaTestEnable = false;
        VertexShader = compile vs_3_0 VS_passDraw();
        PixelShader  = compile ps_3_0 PS_ShallowDOF_X();
    }
    pass ShallowDOF_Y < string Script= "Draw=Buffer;"; > {
        DestBlend = InvSrcAlpha; SrcBlend = SrcAlpha; //���Z�����̃L�����Z��
        AlphaBlendEnable = true;
        AlphaTestEnable = true;
        VertexShader = compile vs_3_0 VS_passDraw();
        PixelShader  = compile ps_3_0 PS_ShallowDOF_Y();
    }
    
    
    
    
    //�������u���[
    pass DirectionalBlur < string Script= "Draw=Buffer;"; > {
        AlphaBlendEnable = false;
        VertexShader = compile vs_3_0 VS_passDraw();
        PixelShader  = compile ps_3_0 PS_DirectionalBlur( ScnSamp, HighLightView );
    }
    
    
    //���C���u���[
    pass ClearLineBluer < string Script= "Draw=Buffer;"; > {
        AlphaBlendEnable = false;
        AlphaTestEnable = false;
        VertexShader = compile vs_3_0 VS_passDraw();
        PixelShader  = compile ps_3_0 PS_ClearLineBluer();
    }
    
    pass DrawLineBluer < string Script= "Draw=Geometry;"; > {
        DestBlend = InvSrcAlpha; SrcBlend = SrcAlpha; //���Z�����̃L�����Z��
        AlphaBlendEnable = true;
        AlphaTestEnable = true;
        CullMode = none;
        ZEnable = false;
        VertexShader = compile vs_3_0 VS_LineBluer();
        PixelShader  = compile ps_3_0 PS_LineBluer();
    }
    
    pass MixLineBluer < string Script= "Draw=Buffer;"; > {
        AlphaBlendEnable = true;
        //AlphaBlendEnable = false;AlphaTestEnable = false;
        DestBlend = InvSrcAlpha; SrcBlend = SrcAlpha; //���Z�����̃L�����Z��
        
        VertexShader = compile vs_3_0 VS_MixLineBluer();
        PixelShader  = compile ps_3_0 PS_MixLineBluer();
    }
    
    
    
    //AL
    
    pass HighLightDOF < string Script= "Draw=Buffer;"; > {
        AlphaBlendEnable = false;
        AlphaTestEnable = false;
        VertexShader = compile vs_3_0 VS_passDraw();
        PixelShader  = compile ps_3_0 PS_HighLightDOF(ScnSampX);
    }
    
    
    pass AL_Gaussian_X < string Script= "Draw=Buffer;"; > {
        AlphaBlendEnable = false;
        AlphaTestEnable = false;
        VertexShader = compile vs_3_0 VS_ALDraw(0);
        PixelShader  = compile ps_3_0 PS_AL_Gaussian(true, HLSampler, 0, 0);
    }
    pass AL_Gaussian_Y < string Script= "Draw=Buffer;"; > {
        AlphaBlendEnable = false;
        AlphaTestEnable = false;
        VertexShader = compile vs_3_0 VS_ALDraw(0);
        PixelShader  = compile ps_3_0 PS_AL_Gaussian(false, ScnSampX, 0, 0);
    }
    
    pass AL_Gaussian_X2 < string Script= "Draw=Buffer;"; > {
        AlphaBlendEnable = false;
        AlphaTestEnable = false;
        VertexShader = compile vs_3_0 VS_ALDraw(1);
        PixelShader  = compile ps_3_0 PS_AL_Gaussian(true, HLSampler, 2, 2);
    }
    pass AL_Gaussian_Y2 < string Script= "Draw=Buffer;"; > {
        AlphaBlendEnable = false;
        AlphaTestEnable = false;
        VertexShader = compile vs_3_0 VS_ALDraw(1);
        PixelShader  = compile ps_3_0 PS_AL_Gaussian(false, ScnSampX2, 0, 2);
    }
    
    pass AL_Gaussian_X3 < string Script= "Draw=Buffer;"; > {
        AlphaBlendEnable = false;
        AlphaTestEnable = false;
        VertexShader = compile vs_3_0 VS_ALDraw(2);
        PixelShader  = compile ps_3_0 PS_AL_Gaussian(true, HLSampler, 4, 4);
    }
    pass AL_Gaussian_Y3 < string Script= "Draw=Buffer;"; > {
        AlphaBlendEnable = false;
        AlphaTestEnable = false;
        VertexShader = compile vs_3_0 VS_ALDraw(2);
        PixelShader  = compile ps_3_0 PS_AL_Gaussian(false, ScnSampX3, 0, 4);
    }
    
    pass AL_Gaussian_X4 < string Script= "Draw=Buffer;"; > {
        AlphaBlendEnable = false;
        AlphaTestEnable = false;
        VertexShader = compile vs_3_0 VS_ALDraw(3);
        PixelShader  = compile ps_3_0 PS_AL_Gaussian(true, HLSampler, 5, 5);
    }
    pass AL_Gaussian_Y4 < string Script= "Draw=Buffer;"; > {
        AlphaBlendEnable = false;
        AlphaTestEnable = false;
        VertexShader = compile vs_3_0 VS_ALDraw(3);
        PixelShader  = compile ps_3_0 PS_AL_Gaussian(false, ScnSampX4, 0, 5);
    }
    
    pass AL_Gaussian_X5 < string Script= "Draw=Buffer;"; > {
        AlphaBlendEnable = false;
        AlphaTestEnable = false;
        VertexShader = compile vs_3_0 VS_ALDraw(4);
        PixelShader  = compile ps_3_0 PS_AL_Gaussian(true, HLSampler, 7, 7);
    }
    pass AL_Gaussian_Y5 < string Script= "Draw=Buffer;"; > {
        AlphaBlendEnable = false;
        AlphaTestEnable = false;
        VertexShader = compile vs_3_0 VS_ALDraw(4);
        PixelShader  = compile ps_3_0 PS_AL_Gaussian(false, ScnSampX5, 0, 7);
    }
    
    
    
    pass AL_DirectionalBlur1 < string Script= "Draw=Buffer;"; > {
        SRCBLEND = ONE;
        DESTBLEND = ONE;
        AlphaTestEnable = false;
        VertexShader = compile vs_3_0 VS_ALDraw(1);
        PixelShader  = compile ps_3_0 PS_AL_DirectionalBlur(HLSampler, true);
    }
    
    pass AL_DirectionalBlur2 < string Script= "Draw=Buffer;"; > {
        SRCBLEND = ONE;
        DESTBLEND = ONE;
        AlphaTestEnable = false;
        VertexShader = compile vs_3_0 VS_ALDraw(1);
        PixelShader  = compile ps_3_0 PS_AL_DirectionalBlur(ScnSampX2, false);
    }
    pass AL_DirectionalBlur3 < string Script= "Draw=Buffer;"; > {
        SRCBLEND = ONE;
        DESTBLEND = ONE;
        AlphaTestEnable = false;
        VertexShader = compile vs_3_0 VS_ALDraw(1);
        PixelShader  = compile ps_3_0 PS_AL_DirectionalBlur(ScnSampOut2, false);
    }
    
    
    
    
    pass DrawHighLight < string Script= "Draw=Buffer;"; > {
        AlphaTestEnable = false;
        AlphaBlendEnable = false;
        
        VertexShader = compile vs_3_0 VS_ALDraw(0);
        PixelShader  = compile ps_3_0 PS_DrawHighLight();
    }
    
    pass AL_Mix < string Script= "Draw=Buffer;"; > {
        
        #if ALPHA_OUT!=0
            AlphaBlendEnable = false;
            AlphaTestEnable = false;
        #endif
        
        VertexShader = compile vs_3_0 VS_ALDraw(0);
        PixelShader  = compile ps_3_0 PS_AL_Mix(true);
    }
    
    pass AL_Test < string Script= "Draw=Buffer;"; > {
        AlphaBlendEnable = false;
        AlphaTestEnable = false;
        VertexShader = compile vs_3_0 VS_ALDraw(0);
        PixelShader  = compile ps_3_0 PS_Test();
    }
    
    
    //�J�����ʒu�ۑ�
    pass DrawCameraBuffer < string Script= "Draw=Buffer;"; > {
        AlphaBlendEnable = false;
        AlphaTestEnable = false;
        VertexShader = compile vs_3_0 VS_CameraBuffer();
        PixelShader  = compile ps_3_0 PS_CameraBuffer();
    }
    
    #if FISHEYE_ENABLE!=0
        //����
        pass FishEye < string Script= "Draw=Buffer;"; > {
            AlphaBlendEnable = false;
            AlphaTestEnable = false;
            VertexShader = compile vs_3_0 VS_passDraw();
            PixelShader  = compile ps_3_0 PS_FishEye();
        }
    #endif
    
    
    
    
    
    
}
////////////////////////////////////////////////////////////////////////////////////////////////

