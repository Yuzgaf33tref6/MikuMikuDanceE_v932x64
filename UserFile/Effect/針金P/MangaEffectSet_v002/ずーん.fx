////////////////////////////////////////////////////////////////////////////////////////////////
//
//  ���[��.fx ver0.0.2  ���敗�\���G�t�F�N�g(���[��)
//  �쐬: �j��P
//
////////////////////////////////////////////////////////////////////////////////////////////////
// �����̃p�����[�^��ύX���Ă�������

float2 Size = float2(0.7, 0.5); // �傫��
float ScrollSpeed = 0.2;        // �X�N���[���X�s�[�h
float LineAmp = 0.03;           // �c�g���U��
float LineWaveLen = 10.0;       // �c�g���g��
float LineFreq = 1.5;           // �c�g�����g��


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


texture2D Tex1 <
    string ResourceName = "zooon1.png";
    int MipLevels = 0;
>;
sampler Samp1 = sampler_state {
    texture = <Tex1>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = LINEAR;
    AddressU  = CLAMP;
    AddressV  = WRAP;
};

texture2D Tex2 <
    string ResourceName = "zooon2.png";
    int MipLevels = 0;
>;
sampler Samp2 = sampler_state {
    texture = <Tex2>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = LINEAR;
    AddressU  = CLAMP;
    AddressV  = CLAMP;
};

texture2D Tex3 <
    string ResourceName = "zooon3.png";
    int MipLevels = 0;
>;
sampler Samp3 = sampler_state {
    texture = <Tex3>;
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
};

// ���_�V�F�[�_
VS_OUTPUT2 Particle_VS(float4 Pos : POSITION, float2 Tex : TEXCOORD0)
{
    VS_OUTPUT2 Out;

    // �I�u�W�F�N�g�T�C�Y
    Pos.xy *= Size;

    // �r���{�[�h
    Pos.xyz = mul( Pos.xyz, BillboardMatrix );

    // ���[���h���W�ϊ�
    Pos = mul( Pos, WorldMatrix );

    // �J�������_�̃r���[�ˉe�ϊ�
    Out.Pos = mul( Pos, GET_VPMAT(Pos) );

    // �e�N�X�`�����W
    Out.Tex = Tex;

    return Out;
}

// �s�N�Z���V�F�[�_
float4 Particle_PS( VS_OUTPUT2 IN ) : COLOR0
{
    // �w�ʃe�N�X�`��
    float2 Tex1 = float2(IN.Tex.x, IN.Tex.y-ScrollSpeed*time);
    float4 Color = tex2D( Samp1, Tex1 );

    // �w�ʃe�N�X�`���̌^����
    float4 Color1 = tex2D( Samp3, IN.Tex );
    Color.a *= Color1.r;

    // �c�g���e�N�X�`��
    float2 Tex2 = float2(IN.Tex.x+LineAmp*sin(LineWaveLen*IN.Tex.y+LineFreq*time), IN.Tex.y);
    float4 Color2 = tex2D( Samp2, Tex2 );

    // ���`����
    Color.xyz = lerp(Color.xyz, Color2.xyz, Color2.a);
    Color.a = ( 1.0f - (1.0f-Color.a)*(1.0f-Color2.a) ) * AcsTr;

    return Color;
}


///////////////////////////////////////////////////////////////////////////////////////
// �e�N�j�b�N
technique MainTec1 < string MMDPass = "object"; >
{
    pass DrawObject {
        ZENABLE = FALSE;
        AlphaBlendEnable = TRUE;
        VertexShader = compile vs_1_1 Particle_VS();
        PixelShader  = compile ps_2_0 Particle_PS();
    }
}

