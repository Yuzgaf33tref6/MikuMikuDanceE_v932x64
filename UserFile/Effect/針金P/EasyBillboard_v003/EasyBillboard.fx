////////////////////////////////////////////////////////////////////////////////////////////////
//
//  EasyBillboard.fx ver0.0.3  ���G�`���c�[���ō쐬�����A�N�Z���g���ȈՔėp�r���{�[�h
//  �쐬: �j��P
//
////////////////////////////////////////////////////////////////////////////////////////////////
// �p�����[�^�錾

// ���W�ϊ��s��
float4x4 WorldMatrix            : WORLD;
float4x4 ViewMatrix             : VIEW;
float4x4 ProjMatrix             : PROJECTION;
float4x4 WorldViewProjMatrix    : WORLDVIEWPROJECTION;
float4x4 WorldViewMatrixInverse : WORLDVIEWINVERSE;

static float3x3 BillboardMatrix = {
    normalize(WorldViewMatrixInverse[0].xyz),
    normalize(WorldViewMatrixInverse[1].xyz),
    normalize(WorldViewMatrixInverse[2].xyz),
};

//�J�����ʒu
float3 CameraPosition  : POSITION  < string Object = "Camera"; >;

// �A�N�Z�T���p�����[�^
float AcsTr : CONTROLOBJECT < string name = "(self)"; string item = "Tr"; >;

// �I�u�W�F�N�g�̃e�N�X�`��
texture ObjectTexture: MATERIALTEXTURE;
sampler ObjTexSampler = sampler_state {
    texture = <ObjectTexture>;
    MINFILTER = LINEAR;
    MAGFILTER = LINEAR;
#ifndef MIKUMIKUMOVING
    #ifndef MME_MIPMAP
    MIPFILTER = LINEAR;
    #endif
#endif
    AddressU  = BORDER;
    AddressV  = BORDER;
    BorderColor = float4(0,0,0,0);
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
    Pos.xyz = mul( Pos.xyz, BillboardMatrix );

#ifndef MIKUMIKUMOVING
    // �J�������_�̃��[���h�r���[�ˉe�ϊ�
    Out.Pos = mul( Pos, WorldViewProjMatrix );
#else
    // ���_���W
    if (MMM_IsDinamicProjection)
    {
        Pos = mul( Pos, WorldMatrix );
        float4x4 vpmat = mul( ViewMatrix, MMM_DynamicFov(ProjMatrix, length( CameraPosition - Pos.xyz )) );
        Out.Pos = mul( Pos, vpmat );
    }
    else
    {
        Out.Pos = mul( Pos, WorldViewProjMatrix );
    }
#endif

    // �e�N�X�`�����W
    Out.Tex = Tex;

    return Out;
}

// �s�N�Z���V�F�[�_
float4 Billboard_PS( float2 Tex :TEXCOORD0 ) : COLOR0
{
    float4 Color = tex2D( ObjTexSampler, Tex );
    Color.a *= AcsTr;
    return Color;
}

technique MainTec0 < string MMDPass = "object"; >
{
    pass DrawObject {
        ZENABLE = false;
        VertexShader = compile vs_1_1 Billboard_VS();
        PixelShader  = compile ps_2_0 Billboard_PS();
    }
}

technique MainTec1 < string MMDPass = "object_ss"; >
{
    pass DrawObject {
        ZENABLE = false;
        VertexShader = compile vs_1_1 Billboard_VS();
        PixelShader  = compile ps_2_0 Billboard_PS();
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////
//�e��֊s�͕`�悵�Ȃ�
technique EdgeTec < string MMDPass = "edge"; > { }
technique ShadowTec < string MMDPass = "shadow"; > { }
technique ZplotTec < string MMDPass = "zplot"; > { }

///////////////////////////////////////////////////////////////////////////////////////////////
