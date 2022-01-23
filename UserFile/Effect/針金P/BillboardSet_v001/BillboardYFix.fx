////////////////////////////////////////////////////////////////////////////////////////////////
//
//  BillboardYFix.fx ver0.0.1  �r���{�[�h�T���v��(Y���Œ��)
//  �쐬: �j��P
//
////////////////////////////////////////////////////////////////////////////////////////////////
// �p�����[�^�錾

// ���W�ϊ��s��
float4x4 WorldMatrix         : WORLD;
float4x4 WorldViewProjMatrix : WORLDVIEWPROJECTION;

//�J�����ʒu
float3 CameraPosition  : POSITION  < string Object = "Camera"; >;

// �J����Z��]�Ǐ]�̃r���{�[�h�s��
static float3 xAxis = cross( float3(0.0f, 1.0f, 0.0f), WorldMatrix._41_42_43 - CameraPosition );
static float3 yAxis = float3(0.0f, 1.0f, 0.0f);
static float3 zAxis = cross( xAxis, yAxis );
static float3x3 RotMatrix = mul( float3x3(xAxis, yAxis, zAxis), transpose((float3x3)WorldMatrix) );
static float3x3 BillboardYFixMatrix = float3x3( normalize(RotMatrix[0].xyz),
                                                normalize(RotMatrix[1].xyz),
                                                normalize(RotMatrix[2].xyz) );

// �I�u�W�F�N�g�̃e�N�X�`��
texture2D ObjectTexture <
    string ResourceName = "sample.png";
    int MipLevels = 0;
>;
sampler ObjTexSampler = sampler_state {
    texture = <ObjectTexture>;
    MinFilter = ANISOTROPIC;
    MagFilter = ANISOTROPIC;
    MipFilter = LINEAR;
    MaxAnisotropy = 16;
    AddressU  = CLAMP;
    AddressV  = CLAMP;
};


///////////////////////////////////////////////////////////////////////////////////////////////

struct VS_OUTPUT
{
    float4 Pos : POSITION;    // �ˉe�ϊ����W
    float2 Tex : TEXCOORD0;   // �e�N�X�`��
};

// ���_�V�F�[�_
VS_OUTPUT Billboard_VS(float4 Pos : POSITION, float2 Tex : TEXCOORD0)
{
    VS_OUTPUT Out;

    // �r���{�[�h
    Pos.xyz = mul( Pos.xyz, BillboardYFixMatrix );

    // �J�������_�̃��[���h�r���[�ˉe�ϊ�
    Out.Pos = mul( Pos, WorldViewProjMatrix );

    // �e�N�X�`�����W
    Out.Tex = Tex;

    return Out;
}

// �s�N�Z���V�F�[�_
float4 Billboard_PS( float2 Tex :TEXCOORD0 ) : COLOR0
{
    return tex2D( ObjTexSampler, Tex );
}

//�e�N�j�b�N
technique MainTec0 < string MMDPass = "object"; >
{
    pass DrawObject {
        ZENABLE = false;
        VertexShader = compile vs_1_1 Billboard_VS();
        PixelShader  = compile ps_2_0 Billboard_PS();
    }
}

