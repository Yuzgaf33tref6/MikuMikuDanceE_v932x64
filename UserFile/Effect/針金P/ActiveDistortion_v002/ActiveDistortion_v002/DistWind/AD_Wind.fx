////////////////////////////////////////////////////////////////////////////////////////////////
//
//  AD_Wind.fx ��Ԙc�݃G�t�F�N�g(���G�t�F�N�g�̉���,�@���E�[�x�}�b�v�쐬)
//  ( ActiveDistortion.fx ����Ăяo����܂��D�I�t�X�N���[���`��p)
//  �쐬: �j��P
//
////////////////////////////////////////////////////////////////////////////////////////////////
// �����̃p�����[�^��ύX���Ă�������

#define WIND_COUNT   30      // ���I�u�W�F�N�g��

// ���Ԑ���R���g���[���t�@�C����
#define TimrCtrlFileName  "TimeControl.x"

#ifndef MIKUMIKUMOVING
// ��MME�g�p���̂ݕύX(MMM��UI�R���g���[�����ύX��)

float WindLife = 0.5;        // ���I�u�W�F�N�g�̎���(�b)
float WindDecrement = 0.7;   // ���I�u�W�F�N�g���������J�n���鎞��(0.0�`1.0:ParticleLife�Ƃ̔�)
float WindSize = 2.0;        // ���I�u�W�F�N�g�̑傫��
float WindSizeRand = 1.0;    // ���I�u�W�F�N�g�̑傫���̂΂��
float WindThick = 0.05;      // ���I�u�W�F�N�g�̑���
float WindScaleUp = 2.0;     // ���I�u�W�F�N�g�̔�����̊g��x
float WindPosHeight = 20.0;  // ���I�u�W�F�N�g���S�ʒu�ő卂��
float WindPosRadius = 5.0;   // ���I�u�W�F�N�g���S�ʒu�����΂���x
float WindRotX = 10.0;       // ���I�u�W�F�N�gX����]�p(deg)
float WindRotZ = 10.0;       // ���I�u�W�F�N�gZ����]�p(deg)


// ����Ȃ��l�͂������牺�͂�����Ȃ��ł�

////////////////////////////////////////////////////////////////////////////////////////////////
// �p�����[�^�錾

#else
// MMM�p�����[�^

float WindLife <
   string UIName = "����(�b)";
   string UIHelp = "���I�u�W�F�N�g�̎���(�b)";
   string UIWidget = "Slider";
   bool UIVisible =  true;
   float UIMin = 0.0;
   float UIMax = 5.0;
> = float( 0.5 );

float WindDecrement <
   string UIName = "�����J�n��";
   string UIHelp = "���I�u�W�F�N�g���������J�n���鎞��(0.0�`1.0:ParticleLife�Ƃ̔�)";
   string UIWidget = "Slider";
   bool UIVisible =  true;
   float UIMin = 0.0;
   float UIMax = 1.0;
> = float( 0.3 );

float WindSize <
   string UIName = "�傫��";
   string UIHelp = "���I�u�W�F�N�g�̑傫��";
   string UIWidget = "Slider";
   bool UIVisible =  true;
   float UIMin = 0.0;
   float UIMax = 10.0;
> = float( 2.0 );

float WindSizeRand <
   string UIName = "�傫�����U";
   string UIHelp = "���I�u�W�F�N�g�̑傫���̂΂��";
   string UIWidget = "Slider";
   bool UIVisible =  true;
   float UIMin = 0.0;
   float UIMax = 10.0;
> = float( 1.0 );

float WindThick <
   string UIName = "����";
   string UIHelp = "���I�u�W�F�N�g�̑���";
   string UIWidget = "Slider";
   bool UIVisible =  true;
   float UIMin = 0.0;
   float UIMax = 0.2;
> = float( 0.03 );

float WindScaleUp <
   string UIName = "�g��x";
   string UIHelp = "���I�u�W�F�N�g�̔�����̊g��x";
   string UIWidget = "Slider";
   bool UIVisible =  true;
   float UIMin = 0.0;
   float UIMax = 5.0;
> = float( 2.0 );

float WindPosHeight <
   string UIName = "�������U";
   string UIHelp = "���I�u�W�F�N�g���S�ʒu�ő卂��";
   string UIWidget = "Slider";
   bool UIVisible =  true;
   float UIMin = 0.0;
   float UIMax = 50.0;
> = float( 20.0 );

float WindPosRadius <
   string UIName = "�������U";
   string UIHelp = "���I�u�W�F�N�g���S�ʒu�����΂���x��";
   string UIWidget = "Slider";
   bool UIVisible =  true;
   float UIMin = 0.0;
   float UIMax = 20.0;
> = float( 5.0 );

float WindRotX <
   string UIName = "X��]";
   string UIHelp = "���I�u�W�F�N�gX����]�p(deg)";
   string UIWidget = "Slider";
   bool UIVisible =  true;
   float UIMin = 0.0;
   float UIMax = 50.0;
> = float( 10.0 );

float WindRotZ <
   string UIName = "Z��]";
   string UIHelp = "���I�u�W�F�N�gZ����]�p(deg)";
   string UIWidget = "Slider";
   bool UIVisible =  true;
   float UIMin = 0.0;
   float UIMax = 50.0;
> = float( 10.0 );

#endif


#define WindRandFileName "WindRand.pfm" // �������t�@�C����
#define TEX_WIDTH_A  2            // �������e�N�X�`���s�N�Z����
#define TEX_WIDTH    1            // �e�N�X�`���s�N�Z����
#define TEX_HEIGHT   1024         // �e�N�X�`���s�N�Z������

#define PAI 3.14159265f   // ��

#define DEPTH_FAR  5000.0f   // �[�x�ŉ��l

float AcsTr : CONTROLOBJECT < string name = "(self)"; string item = "Tr"; >;

int RepertCount = WIND_COUNT;  // �V�F�[�_���`�攽����
int RepertIndex;               // �������f���J�E���^

float3 CameraPosition : POSITION  < string Object = "Camera"; >;

// ���W�ϊ��s��
float4x4 WorldMatrix       : WORLD;
float4x4 ViewMatrix        : VIEW;
float4x4 ProjMatrix        : PROJECTION;
float4x4 ViewProjMatrix    : VIEWPROJECTION;


// �@���}�b�v�e�N�X�`��
texture2D NormalMapTex <
    string ResourceName = "NormalMapSample.png";
    int MipLevels = 0;
>;
sampler NormalMapSamp = sampler_state {
    texture = <NormalMapTex>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = LINEAR;
    AddressU  = CLAMP;
    AddressV  = CLAMP;
};

// �������e�N�X�`��
texture2D ArrangeTex <
    string ResourceName = WindRandFileName;
>;
sampler ArrangeSmp : register(s3) = sampler_state{
    texture = <ArrangeTex>;
    MinFilter = POINT;
    MagFilter = POINT;
    MipFilter = NONE;
};


////////////////////////////////////////////////////////////////////////////////////////////////
// ���Ԑݒ�

// ���Ԑ���R���g���[���p�����[�^
bool IsTimeCtrl : CONTROLOBJECT < string name = TimrCtrlFileName; >;
float TimeSi : CONTROLOBJECT < string name = TimrCtrlFileName; string item = "Si"; >;
float TimeTr : CONTROLOBJECT < string name = TimrCtrlFileName; string item = "Tr"; >;
static bool TimeSync = IsTimeCtrl ? ((TimeSi>0.001f) ? true : false) : true;
static float TimeRate = IsTimeCtrl ? TimeTr : 1.0f;

float time1 : Time;
float time2 : Time < bool SyncInEditMode = true; >;
static float time0 = TimeSync ? time1 : time2;

// �X�V�����L�^�p
texture TimeTex : RENDERCOLORTARGET
<
   int Width=1;
   int Height=1;
   string Format = "D3DFMT_G32R32F" ;
>;
sampler TimeTexSmp = sampler_state
{
   Texture = <TimeTex>;
    AddressU  = CLAMP;
    AddressV = CLAMP;
    MinFilter = NONE;
    MagFilter = NONE;
    MipFilter = NONE;
};
texture TimeDepthBuffer : RenderDepthStencilTarget <
   int Width=1;
   int Height=1;
    string Format = "D3DFMT_D24S8";
>;
static float time = tex2Dlod(TimeTexSmp, float4(0.5f,0.5f,0,0)).y;

float4 UpdateTime_VS(float4 Pos : POSITION) : POSITION
{
    return Pos;
}

float4 UpdateTime_PS() : COLOR
{
   float2 timeDat = tex2D(TimeTexSmp, float2(0.5f,0.5f)).xy;
   float etime = timeDat.y + clamp(time0 - timeDat.x, 0.0f, 0.1f) * TimeRate;
   if(time0 < 0.001f) etime = 0.0;
   return float4(time0, etime, 0, 1);
}

////////////////////////////////////////////////////////////////////////////////////////////////
// �z�u��������e�N�X�`������f�[�^�����o��
float3 Color2Float(int index, int item)
{
    return tex2Dlod(ArrangeSmp, float4((item+0.5f)/TEX_WIDTH_A, (index+0.5f)/TEX_HEIGHT, 0, 0)).xyz;
}


////////////////////////////////////////////////////////////////////////////////////////////////
// �������Z
int div(int a, int b) {
    return floor((a+0.1f)/b);
}

// ������]�Z
int mod(int a, int b) {
    return (a - div(a,b)*b);
};

////////////////////////////////////////////////////////////////////////////////////////////////
// ���[���h�ϊ��s��擾
float4x4 GetWorldMatrix(float3 pos, float3 rot, float scale)
{
   float3x3 wldRotX = { 1,           0,          0,
                        0,  cos(rot.x), sin(rot.x),
                        0, -sin(rot.x), cos(rot.x) };

   float3x3 wldRotY = { cos(rot.y), 0, -sin(rot.y),
                                 0, 1,           0,
                        sin(rot.y), 0,  cos(rot.y) };

   float3x3 wldRotZ = { cos(rot.z), sin(rot.z), 0,
                       -sin(rot.z), cos(rot.z), 0,
                                 0,          0, 1 };

   float3x3 wldRot = mul(mul(wldRotY, wldRotX), wldRotZ);

   float4x4 wldMat = float4x4( wldRot[0]*scale, 0,
                               wldRot[1]*scale, 0,
                               wldRot[2]*scale, 0,
                                           pos, 1 );

   return mul(wldMat, WorldMatrix);
}

////////////////////////////////////////////////////////////////////////////////////////////////
// �ڋ�ԉ�]�s��擾

float3x3 GetTangentFrame(float3 Normal, float3 View, float2 UV)
{
  float3 dp1 = ddx(View);
  float3 dp2 = ddy(View);
  float2 duv1 = ddx(UV);
  float2 duv2 = ddy(UV);

  float3x3 M = float3x3(dp1, dp2, cross(dp1, dp2));
  float2x3 inverseM = float2x3(cross(M[1], M[2]), cross(M[2], M[0]));
  float3 Tangent = mul(float2(duv1.x, duv2.x), inverseM);
  float3 Binormal = mul(float2(duv1.y, duv2.y), inverseM);

  return float3x3(normalize(Tangent), normalize(Binormal), Normal);
}


///////////////////////////////////////////////////////////////////////////////////////////////
//MMM�Ή�
#ifndef MIKUMIKUMOVING
    #define GET_VPMAT(p) (ViewProjMatrix)
#else
    #define GET_VPMAT(p) (MMM_IsDinamicProjection ? mul(ViewMatrix, MMM_DynamicFov(ProjMatrix, length(CameraPosition-p.xyz))) : ViewProjMatrix)
#endif


///////////////////////////////////////////////////////////////////////////////////////
// ���I�u�W�F�N�g�`��

struct VS_OUTPUT
{
    float4 Pos    : POSITION;    // �ˉe�ϊ����W
    float3 Normal : TEXCOORD0;   // �@��
    float4 VPos   : TEXCOORD1;   // �r���[���W
    float2 Tex    : TEXCOORD2;   // �e�N�X�`��
    float  Alpha  : TEXCOORD3;   // ���l
};

// ���_�V�F�[�_
VS_OUTPUT Wind_VS(float4 Pos : POSITION, float3 Normal : NORMAL, float2 Tex : TEXCOORD0)
{
    VS_OUTPUT Out = (VS_OUTPUT)0;

    // �I�u�W�F�N�g�C���f�b�N�X
    float ds = (time - WindLife) * WIND_COUNT / WindLife;
    float stage = float(RepertIndex + 1.0f - frac(ds)) / float(WIND_COUNT);
    int i = floor( ds );
    i = mod(i, TEX_HEIGHT);
    i += RepertIndex;
    if(i >= TEX_HEIGHT) i -= TEX_HEIGHT;

    // �����ݒ�
    float3 rand1 = Color2Float(i, 0);
    float3 rand2 = Color2Float(i, 1);

    // �I�u�W�F�N�g�̃��[���h�ϊ��s��
    float pos_r = lerp(0.0f, WindPosRadius*0.1f, rand1.x);
    float pos_h = lerp(0.0f, WindPosHeight*0.1f, rand1.y);
    float pos_s = lerp(-PAI, PAI, rand1.z);
    float rot_x = lerp(-radians(WindRotX), radians(WindRotX), rand2.x);
    float rot_y = lerp(-PAI, PAI, rand2.y);
    float rot_z = lerp(-radians(WindRotZ), radians(WindRotZ), rand2.z);
    float scale = max(lerp(WindSize-WindSizeRand*0.5f, WindSize+WindSizeRand*0.5f, (rand1.x+rand1.z)*0.5f), 0.0f)
                   - WindScaleUp * WindLife * stage;

    float3 pos0 = float3(pos_r*cos(pos_s), pos_h, pos_r*sin(pos_s));
    float3 rot0 = float3(rot_x, rot_y, rot_z);
    float4x4 wldMat = GetWorldMatrix(pos0, rot0, scale);

    // �I�u�W�F�N�g�̃��[���h���W�ϊ�
    Pos.y *= WindThick * (1.0f - stage);
    Pos = mul(Pos, wldMat);

    // �J�������_�̃r���[�ϊ�
    Out.VPos = mul( Pos, ViewMatrix );

    // �J�������_�̃r���[�ˉe�ϊ�
    Out.Pos = mul( Pos, GET_VPMAT(Pos) );

    // �@���̃J�������_�̃��[���h�r���[�ϊ�
    Out.Normal = mul( Normal, (float3x3)mul(wldMat, ViewMatrix) );

    // �e�N�X�`�����W
    Out.Tex = Tex;

    // ���l
    Out.Alpha = smoothstep(0.0f, 1.0f-WindDecrement, stage) * smoothstep(-1.0f, -0.9f, -stage);

    return Out;
}

// �s�N�Z���V�F�[�_
float4 Wind_PS( VS_OUTPUT IN ) : COLOR0
{
    // �m�[�}���}�b�v���܂ޖ@���擾
    float3 eye = -IN.VPos.xyz / IN.VPos.w;
    float3x3 tangentFrame = GetTangentFrame(IN.Normal, eye, IN.Tex);
    float3 Normal = normalize(mul(2.0f * tex2D(NormalMapSamp, IN.Tex).rgb - 1.0f, tangentFrame));

    // �@��(0�`1�ɂȂ�悤�␳)
    Normal = (Normal + 1.0f) / 2.0f;
    Normal = lerp(float3(0.5, 0.5, 0.0f), Normal, AcsTr * IN.Alpha);

    // �[�x(0�`DEPTH_FAR��0.5�`1.0�ɐ��K��)
    float dep = length(IN.VPos.xyz / IN.VPos.w);
    dep = (saturate(dep / DEPTH_FAR) + 1.0f) * 0.5f;

    return float4(Normal, dep);
}


///////////////////////////////////////////////////////////////////////////////////////
// �e�N�j�b�N

technique MainTec1 < string MMDPass = "object";
    string Script = 
        "RenderColorTarget0=;"
	    "RenderDepthStencilTarget=;"
            "LoopByCount=RepertCount;"
            "LoopGetIndex=RepertIndex;"
                "Pass=DrawObject;"
            "LoopEnd=;"
        "RenderColorTarget0=TimeTex;"
            "RenderDepthStencilTarget=TimeDepthBuffer;"
            "Pass=UpdateTime;"
        "RenderColorTarget0=;"
	    "RenderDepthStencilTarget=;"
        ;
>{
    pass DrawObject {
        ZEnable = TRUE;
        ZwriteEnable = FALSE;
        ALPHABLENDENABLE = FALSE;
        CULLMODE = NONE;
        VertexShader = compile vs_3_0 Wind_VS();
        PixelShader  = compile ps_3_0 Wind_PS();
    }
    pass UpdateTime < string Script= "Draw=Buffer;"; > {
        ZEnable = FALSE;
        AlphaBlendEnable = FALSE;
        AlphaTestEnable = FALSE;
        VertexShader = compile vs_1_1 UpdateTime_VS();
        PixelShader  = compile ps_2_0 UpdateTime_PS();
    }
}


///////////////////////////////////////////////////////////////////////////////////////
// �G�b�W�E�n�ʉe�EZPlot�͕\�����Ȃ�
technique EdgeTec < string MMDPass = "edge"; > { }
technique ShadowTec < string MMDPass = "shadow"; > { }
technique ZplotTec < string MMDPass = "zplot";> { }

