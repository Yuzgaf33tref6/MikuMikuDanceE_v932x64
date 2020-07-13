///////////////////////////////////////////////////////////////////////////////////////////////
// �ݒ�

// ���A�N�Z�T���̃T�C�Y�i�����c�j
//   �����̒l��ύX�����ꍇ�A�K��MirrorObject.fx�̓����̐ݒ�����킹�ĕύX���邱��
float2 MirrorSize = { 1, 1.5 };

// ���̐F�iRGB�j
//   �������x��MMD�̃A�N�Z�T������p�l���Őݒ�\ 
float3 MirrorColor = { 1.0, 1.0, 1.0 };

// ���e�N�X�`���̃T�C�Y
#define WIDTH   1024
#define HEIGHT  1024

////////////////////////////////////////////////////////////////////////////////////////////////
// �p�����[�^�錾

// ���@�ϊ��s��
float4x4 WorldViewProjMatrix      : WORLDVIEWPROJECTION;
float4x4 WorldViewMatrix          : WORLDVIEW;

float4   MaterialDiffuse   : DIFFUSE  < string Object = "Geometry"; >;


///////////////////////////////////////////////////////////////////////////////////////////////
// ���֘A

texture MirrorRT: OFFSCREENRENDERTARGET <
    string Description = "OffScreen RenderTarget for Mirror.fx";
    int Width = WIDTH;
    int Height = HEIGHT;
    float4 ClearColor = { 0, 0, 0, 0 };
    float ClearDepth = 1.0;
    bool AntiAlias = true;
    string DefaultEffect = 
        "self = hide;"
        "Mirror*.x = hide;"
        "*=MirrorObject.fx;";
>;

sampler MirrorView = sampler_state {
    texture = <MirrorRT>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = NONE;
    AddressU  = CLAMP;
    AddressV = CLAMP;
};


///////////////////////////////////////////////////////////////////////////////////////////////
// �I�u�W�F�N�g�`��

struct VS_OUTPUT {
    float4 Pos        : POSITION;    // �ˉe�ϊ����W
    float2 Tex        : TEXCOORD1;   // �e�N�X�`��
};

// ���_�V�F�[�_
VS_OUTPUT Mirror_VS(float4 Pos : POSITION, float2 Tex : TEXCOORD0)
{
    VS_OUTPUT Out = (VS_OUTPUT)0;
    
    Pos.xy *= MirrorSize;
    // �J�������_�̃��[���h�r���[�ˉe�ϊ�
    Out.Pos = mul( Pos, WorldViewProjMatrix );
    
    // �e�N�X�`�����W
    Out.Tex = Tex;
    
    if ( dot(WorldViewMatrix[2].xyz,WorldViewMatrix[3].xyz) > 0 ) {
        // ���̕\�̖ʂ̏ꍇ�AX���𔽓]���ĕ`�悵�Ă���̂ŁA�����Ŕ��]����B
        Out.Tex.x = 1 - Out.Tex.x;
    }
    
    return Out;
}

float rgb2gray(float3 rgb)
{
	return dot(float3(0.299, 0.587, 0.114), rgb);
}

// �s�N�Z���V�F�[�_
float4 Mirror_PS(VS_OUTPUT IN) : COLOR0
{
    float4 color = tex2D(MirrorView, IN.Tex);
    color.rgb *= MirrorColor;
	color.a *= MaterialDiffuse.a * rgb2gray(color.rgb);

    return color;
}

technique MainTec {
    pass DrawObject {
        CULLMODE = NONE;
        VertexShader = compile vs_2_0 Mirror_VS();
        PixelShader  = compile ps_2_0 Mirror_PS();
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////
