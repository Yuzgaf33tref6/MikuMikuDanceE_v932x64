////////////////////////////////////////////////////////////////////////////////////////////////
//
//  �L���[��.fx ver0.0.2  ���敗�\���G�t�F�N�g(�L���[��)
//  �쐬: �j��P
//
////////////////////////////////////////////////////////////////////////////////////////////////
// �����̃p�����[�^��ύX���Ă�������

int ParticleCount = 30;   // �p�[�e�B�N���̕`��I�u�W�F�N�g��
float LightSize = 0.5;   // �����q�傫��
float LightCross = 1.0;   // �����q�̏\���x����
float LightAmp = 1.0;     // �����q�u���U��
float LightFreq = 3.0;    // �����q�u�����g��

float Xmin = -5.0;        // X�͈͍ŏ��l
float Xmax = 5.0;         // X�͈͍ő�l
float Ymin = -5.0;        // Y�͈͍ŏ��l
float Ymax = 7.0;         // Y�͈͍ő�l

int SeedXY = 7;           // �z�u�Ɋւ��闐���V�[�h
int SeedSize = 3;         // �T�C�Y�Ɋւ��闐���V�[�h
int SeedBlink = 13;       // �u���Ɋւ��闐���V�[�h
int SeedCross = 11;       // �\���x�����Ɋւ��闐���V�[�h


// ����Ȃ��l�͂������牺�͂�����Ȃ��ł�

////////////////////////////////////////////////////////////////////////////////////////////////
// �p�����[�^�錾

float AcsTr  : CONTROLOBJECT < string name = "(self)"; string item = "Tr"; >;

int Index;

float time : Time;

// ���W�ϊ��s��
float4x4 WorldMatrix            : WORLD;
float4x4 ViewMatrix             : VIEW;
float4x4 ProjMatrix             : PROJECTION;
float4x4 ViewProjMatrix         : VIEWPROJECTION;
float4x4 WorldViewMatrixInverse : WORLDVIEWINVERSE;

static float3x3 BillboardMatrix = {
    normalize(WorldViewMatrixInverse[0].xyz),
    normalize(WorldViewMatrixInverse[1].xyz),
    normalize(WorldViewMatrixInverse[2].xyz),
};

//�J�����ʒu
float3 CameraPosition  : POSITION  < string Object = "Camera"; >;


texture2D ParticleTex1 <
    string ResourceName = "kira1.png";
    int MipLevels = 0;
>;
sampler ParticleSamp1 = sampler_state {
    texture = <ParticleTex1>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = LINEAR;
    AddressU  = CLAMP;
    AddressV  = CLAMP;
};

texture2D ParticleTex2 <
    string ResourceName = "kira2.png";
    int MipLevels = 0;
>;
sampler ParticleSamp2 = sampler_state {
    texture = <ParticleTex2>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = LINEAR;
    AddressU  = CLAMP;
    AddressV  = CLAMP;
};


////////////////////////////////////////////////////////////////////////////////////////////////
//MMM�Ή�

#ifdef MIKUMIKUMOVING
    #define GET_VPMAT(p) (MMM_IsDinamicProjection ? mul(ViewMatrix, MMM_DynamicFov(ProjMatrix, length(CameraPosition-p.xyz))) : ViewProjMatrix)
#else
    #define GET_VPMAT(p) (ViewProjMatrix)
#endif


///////////////////////////////////////////////////////////////////////////////////////
// �p�[�e�B�N���`��
struct VS_OUTPUT2
{
    float4 Pos        : POSITION;    // �ˉe�ϊ����W
    float3 Tex        : TEXCOORD0;   // �e�N�X�`��
    float4 Color      : COLOR0;      // alpha�l
};

// ���_�V�F�[�_
VS_OUTPUT2 Particle_VS(float4 Pos : POSITION, float2 Tex : TEXCOORD0)
{
    VS_OUTPUT2 Out;

    // ������`
    float rand0 = 0.6f*sin(37 * SeedSize * Index + 13) + 0.4f*cos(71 * SeedSize * Index + 17)+1.2f;
    float rand1 = 0.4f*sin(53 * SeedBlink * Index + 17) + 0.6f*cos(61 * SeedBlink * Index + 19);
    float rand2 = abs(0.7f*sin(124 * SeedXY * Index + 19) + 0.3f*cos(235 * SeedXY * Index + 23));
    float rand3 = abs(0.6f*sin(83 * SeedXY * Index + 23) + 0.4f*cos(91 * SeedXY * Index + 29));
    float rand4 = (sin(47 * SeedCross * Index + 29) + cos(81 * SeedCross * Index + 31) + 3.0f) * 0.1f;

    // �p�[�e�B�N���T�C�Y
    Pos.xy *= max(rand0 * LightSize + LightAmp*sin(LightFreq*time+rand1*6.28f), 0.0f);

    // �p�[�e�B�N���z�u
    float x = lerp(Xmin, Xmax, rand2) * 0.1f;
    float y = lerp(Ymin, Ymax, rand3) * 0.1f;
    Pos.xy += float2(x, y);

    // �r���{�[�h
    Pos.xyz = mul( Pos.xyz, BillboardMatrix );

    // ���[���h���W�ϊ�
    Pos = mul( Pos, WorldMatrix );

    // �J�������_�̃r���[�ˉe�ϊ�
    Out.Pos = mul( Pos, GET_VPMAT(Pos) );

    // ���q�̓��ߓx
    Out.Color = float4(AcsTr, AcsTr, AcsTr, 1.0f);

    // �e�N�X�`�����W
    Out.Tex = float3(Tex, 1.0f+LightCross*rand4);

    return Out;
}

// �s�N�Z���V�F�[�_
float4 Particle_PS( VS_OUTPUT2 IN ) : COLOR0
{
    float4 Color = tex2D( ParticleSamp2, IN.Tex.xy );
    float2 Tex1 = (IN.Tex.xy-0.5f)*IN.Tex.z+0.5f;
    float4 Color1 = tex2D( ParticleSamp1, Tex1 );
    Color += Color1;
    Color.xyz *= IN.Color.xyz*0.5f;
    return Color;
}


///////////////////////////////////////////////////////////////////////////////////////
// �e�N�j�b�N
technique MainTec1 < string MMDPass = "object";
    string Script = "LoopByCount=ParticleCount;"
                    "LoopGetIndex=Index;"
                    "Pass=DrawObject;"
                    "LoopEnd=;"; >
{
    pass DrawObject {
        ZENABLE = FALSE;
        AlphaBlendEnable = TRUE;
        SrcBlend = ONE;
        DestBlend = ONE;
        VertexShader = compile vs_1_1 Particle_VS();
        PixelShader  = compile ps_2_0 Particle_PS();
    }
}

