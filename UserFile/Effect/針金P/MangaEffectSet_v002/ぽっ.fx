////////////////////////////////////////////////////////////////////////////////////////////////
//
//  �ۂ�.fx ver0.0.2  ���敗�\���G�t�F�N�g(�ۂ�)
//  �쐬: �j��P
//
////////////////////////////////////////////////////////////////////////////////////////////////
// �����̃p�����[�^��ύX���Ă�������

#define TexFile  "hart.png"   // ���q�ɓ\��t����e�N�X�`���t�@�C����
int ParticleCount = 30;    // ���q�̕`��I�u�W�F�N�g��
float ParticleSize = 0.5;  // ���q�傫��
float ParticleSpeed = 0.3; // ���q�̃X�s�[�h
float ParticleAmp = 1.0;   // ���q�̐����ړ��U��
float ParticleFreq = 2.0;  // ���q�̐����ړ����g��

float Rmin = 2.0;          // �z�u���a�ŏ��l
float Rmax = 9.0;          // �z�u���a�ő�l
float Rotmin = -30.0;      // �ړ������p�ŏ��l
float Rotmax = 30.0;       // �ړ������p�ő�l

int SeedR = 3;             // �z�u���a�Ɋւ��闐���V�[�h
int SeedRot = 13;          // �ړ������p�Ɋւ��闐���V�[�h
int SeedShake = 8;         // �����ړ��Ɋւ��闐���V�[�h


// ����Ȃ��l�͂������牺�͂�����Ȃ��ł�

////////////////////////////////////////////////////////////////////////////////////////////////
// �p�����[�^�錾

float AcsTr  : CONTROLOBJECT < string name = "(self)"; string item = "Tr"; >;

static float diffDmin = radians( Rotmin );
static float diffDmax = radians( Rotmax );

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


texture2D ParticleTex <
    string ResourceName = TexFile;
    int MipLevels = 0;
>;
sampler ParticleSamp = sampler_state {
    texture = <ParticleTex>;
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
    float2 Tex        : TEXCOORD0;   // �e�N�X�`��
    float4 Color      : COLOR0;      // alpha�l
};

// ���_�V�F�[�_
VS_OUTPUT2 Particle_VS(float4 Pos : POSITION, float2 Tex : TEXCOORD0)
{
    VS_OUTPUT2 Out;

    // ������`
    float rand1 = abs(0.7f*sin(124 * SeedRot * Index + 19) + 0.3f*cos(235 * SeedRot * Index + 23));
    float rand2 = abs(0.6f*sin(83 * SeedR * Index + 23) + 0.4f*cos(91 * SeedR * Index + 29));
    float rand3 = 0.4f*sin(53 * SeedShake * Index + 17) + 0.6f*cos(61 * SeedShake * Index + 19);

    // �p�[�e�B�N���T�C�Y
    Pos.xy *= ParticleSize;

    // �p�[�e�B�N���z�u
    float rot = lerp(diffDmin, diffDmax, rand1);
    float e = (Rmax-Rmin) * 0.1f;
    float r = lerp( Rmin-e, Rmax+e, fmod(rand2+ParticleSpeed*time, 1.0f) );
    Pos.xy += float2( r*sin(rot), r*cos(rot) ) * 0.1f;
    Pos.x += ParticleAmp * sin( ParticleFreq * time + rand3 * 6.28f ) * smoothstep(Rmin, Rmax, r) * 0.1f;

    // �r���{�[�h
    Pos.xyz = mul( Pos.xyz, BillboardMatrix );

    // ���[���h���W�ϊ�
    Pos = mul( Pos, WorldMatrix );

    // �J�������_�̃r���[�ˉe�ϊ�
    Out.Pos = mul( Pos, GET_VPMAT(Pos) );

    // ���q�̓��ߓx
    r = abs( (r-Rmin)/(Rmax-Rmin) - 0.5f );
    float alpha = ( 1.0f-smoothstep(0.2f, 0.5f, r) ) * AcsTr;
    Out.Color = float4(1.0f, 1.0f, 1.0f, alpha);

    // �e�N�X�`�����W
    Out.Tex = Tex;

    return Out;
}

// �s�N�Z���V�F�[�_
float4 Particle_PS( VS_OUTPUT2 IN ) : COLOR0
{
   float4 Color = tex2D( ParticleSamp, IN.Tex );
   Color *= IN.Color;
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
        VertexShader = compile vs_1_1 Particle_VS();
        PixelShader  = compile ps_2_0 Particle_PS();
    }
}

