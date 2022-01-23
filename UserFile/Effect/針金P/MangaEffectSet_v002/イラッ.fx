////////////////////////////////////////////////////////////////////////////////////////////////
//
//  �C���b.fx ver0.0.2  ���敗�\���G�t�F�N�g(�C���b)
//  �쐬: �j��P
//
////////////////////////////////////////////////////////////////////////////////////////////////
// �����̃p�����[�^��ύX���Ă�������

#define TexFile  "ira.png"     // ���q�ɓ\��t����e�N�X�`���t�@�C����
int ParticleCount = 10;        // ���q�̕`��I�u�W�F�N�g��
float ParticleSize = 1.0;      // ���q�傫��
float ParticleRot = 1.0;       // ���q�̉�]�p
float ParticleLife = 1.5;      // ���q�̎���(�b)
float ParticleDecrement = 0.7; // ���q���������J�n���鎞��(ParticleLife�Ƃ̔�)

float Rmin = 3.0;      // �z�u���a�ŏ��l
float Rmax = 7.0;      // �z�u���a�ő�l
float Rotmin = -40.0;  // �ړ������p�ŏ��l
float Rotmax = 40.0;   // �ړ������p�ő�l

int SeedR = 3;         // �z�u���a�Ɋւ��闐���V�[�h
int SeedRot = 9;       // �ړ������p�Ɋւ��闐���V�[�h
int SeedPRot = 8;      // ���q��]�Ɋւ��闐���V�[�h
int SeedBlink = 8;     // ���q�_�łɊւ��闐���V�[�h


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


////////////////////////////////////////////////////////////////////////////////////////////////
// ���W��2D��]
float2 Rotation2D(float2 pos, float rot)
{
    float x = pos.x * cos(rot) - pos.y * sin(rot);
    float y = pos.x * sin(rot) + pos.y * cos(rot);

    return float2(x,y);
}

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
    float rand3 = 0.4f*sin(53 * SeedPRot * Index + 17) + 0.6f*cos(61 * SeedPRot * Index + 19);
    float rand4 = 0.6f*sin(37 * SeedBlink * Index + 13) + 0.4f*cos(71 * SeedBlink * Index + 17);

    // �p�[�e�B�N���T�C�Y
    Pos.xy *= ParticleSize;

    //  �p�[�e�B�N����]
    float prot = rand3;
    Pos.xy = Rotation2D(Pos.xy, ParticleRot*rand3);

    // �p�[�e�B�N���z�u
    float rot = lerp(diffDmin, diffDmax, rand1);
    float e = (Rmax-Rmin) * 0.1f;
    float r = lerp( Rmin-e, Rmax+e, rand2 );
    Pos.xy += float2( r*sin(rot), r*cos(rot) ) * 0.1f;

    // �r���{�[�h
    Pos.xyz = mul( Pos.xyz, BillboardMatrix );

    // ���[���h���W�ϊ�
    Pos = mul( Pos, WorldMatrix );

    // �J�������_�̃r���[�ˉe�ϊ�
    Out.Pos = mul( Pos, GET_VPMAT(Pos) );

    // ���q�̓��ߓx
    float t = fmod( time+ParticleLife*rand4, ParticleLife*2.0f );
    float alpha = (1.0f - smoothstep(ParticleDecrement*ParticleLife, ParticleLife, t)) * AcsTr;
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

