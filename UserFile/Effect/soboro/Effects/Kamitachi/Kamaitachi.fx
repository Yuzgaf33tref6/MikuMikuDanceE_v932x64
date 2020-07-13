

//�V���G�b�g�F(R,G,B,A�@�e0�`1)
float4 SilhouetteColor = float4(0.25, 0, 1, 0.6);

///////////////////////////////////////////////////////////////////////////////////////////////


// ���@�ϊ��s��
float4x4 WorldViewProjMatrix      : WORLDVIEWPROJECTION;

float4   MaterialDiffuse   : DIFFUSE  < string Object = "Geometry"; >;

bool use_texture;  //�e�N�X�`���̗L��

// �I�u�W�F�N�g�̃e�N�X�`��
texture ObjectTexture: MATERIALTEXTURE;
sampler ObjTexSampler = sampler_state
{
    texture = <ObjectTexture>;
    MINFILTER = LINEAR;
    MAGFILTER = LINEAR;
};

// MMD�{����sampler���㏑�����Ȃ����߂̋L�q�ł��B�폜�s�B
sampler MMDSamp0 : register(s0);
sampler MMDSamp1 : register(s1);
sampler MMDSamp2 : register(s2);


///////////////////////////////////////////////////////////////////////////////////////////////
// �I�u�W�F�N�g�`��

struct VS_OUTPUT
{
    float4 Pos        : POSITION;    // �ˉe�ϊ����W
    float2 Tex        : TEXCOORD1;   // �e�N�X�`��
};

// ���_�V�F�[�_
VS_OUTPUT Basic_VS(float4 Pos : POSITION, float3 Normal : NORMAL, float2 Tex : TEXCOORD0)
{
    VS_OUTPUT Out = (VS_OUTPUT)0;
    
    // �J�������_�̃��[���h�r���[�ˉe�ϊ�
    Out.Pos = mul( Pos, WorldViewProjMatrix );
    
    // �e�N�X�`�����W
    Out.Tex = Tex;
    
    return Out;
}

// �s�N�Z���V�F�[�_
float4 Basic_PS( VS_OUTPUT IN ) : COLOR0
{
    
    float4 Color = SilhouetteColor;
    
    Color.a *= MaterialDiffuse.a;
    
    if ( use_texture ) Color.a *= tex2D( ObjTexSampler, IN.Tex ).a;
    
    return Color;
}



stateblock state1 = stateblock_state
{
    StencilEnable = true;
    StencilRef = 5;
    StencilFunc = Greater;
    StencilFail = Keep;
    StencilPass = Replace;
    VertexShader = compile vs_2_0 Basic_VS();
    PixelShader  = compile ps_2_0 Basic_PS();
};

// �I�u�W�F�N�g�`��p�e�N�j�b�N
technique MainTec < string MMDPass = "object"; > {
    pass DrawObject
    {
        StateBlock = (state1);
    }
}
technique MainTecSS < string MMDPass = "object_ss"; > {
    pass DrawObject
    {
        StateBlock = (state1);
    }
}

// �֊s�Ɖe�͕`�悵�Ȃ�
technique EdgeTec < string MMDPass = "edge"; > {}
technique ShadowTec < string MMDPass = "shadow"; > {}

