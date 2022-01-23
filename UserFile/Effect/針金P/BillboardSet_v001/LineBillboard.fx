////////////////////////////////////////////////////////////////////////////////////////////////
//
//  LineBillboard.fx ver0.0.1  ���C���r���{�[�h�̃T���v��
//  �쐬: �j��P
//
////////////////////////////////////////////////////////////////////////////////////////////////
// �p�����[�^�錾

float LocalLen = 2.0f;  // ���[�J�����W�n�ł̃{�[�h�ӂ̒���
float Thick = 5.0f;     // ���C���̑���

// �{�[�����W(���C���[�_)
float3 Point1 : CONTROLOBJECT < string name = "LineBillboard.pmx"; string item = "Point1"; >;
float3 Point2 : CONTROLOBJECT < string name = "LineBillboard.pmx"; string item = "Point2"; >;

// ���W�ϊ��s��
float4x4 ViewProjMatrix  : VIEWPROJECTION;

//�J�����ʒu
float3 CameraPosition  : POSITION  < string Object = "Camera"; >;

// ���C���r���{�[�h�s��(���[���h�ϊ��s��ɂȂ�)
static float3 xAxis = normalize( cross( Point2 - Point1, Point1 - CameraPosition ) );
static float3 yAxis = ( Point2 - Point1 ) / LocalLen;
static float3 zAxis = normalize( cross( xAxis, yAxis ) );
static float4x4 LineBillboardMatrix =  float4x4( xAxis * Thick,        0.0f,
                                                 yAxis,                0.0f,
                                                 zAxis,                0.0f,
                                                 (Point2+Point1)*0.5f, 1.0f );

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

    // �{�[�h���[�J�����W
    Pos = float4( LocalLen*(Tex.x - 0.5f), LocalLen*(0.5f - Tex.y), 0.0f, 1.0f );

    // �r���{�[�h(���[���h���W�ϊ�)
    Pos = mul( Pos, LineBillboardMatrix );

    // �J�������_�̃r���[�ˉe�ϊ�
    Out.Pos = mul( Pos, ViewProjMatrix );

    // �e�N�X�`�����W
    Out.Tex = Tex;

    return Out;
}

// �s�N�Z���V�F�[�_
float4 Billboard_PS( float2 Tex :TEXCOORD0 ) : COLOR0
{
    return tex2D( ObjTexSampler, Tex );
}

///////////////////////////////////////////////////////////////////////////////////////////////
//�e�N�j�b�N

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
