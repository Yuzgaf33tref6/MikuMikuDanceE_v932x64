// �J��������̋������i�[����


// �p�����[�^
float AlphaThroughThreshold = 0.2;

#define FAR_Z	1000

// �p�����[�^�錾

// ���@�ϊ��s��
float4x4 matWVP	: WORLDVIEWPROJECTION;
float4x4 matWV	: WORLDVIEW;

#ifndef MIKUMIKUMOVING
// MMD�{����sampler���㏑�����Ȃ����߂̋L�q�ł��B�폜�s�B
sampler MMDSamp0 : register(s0);
sampler MMDSamp1 : register(s1);
sampler MMDSamp2 : register(s2);
#endif

bool	use_texture;		// �e�N�X�`���g�p

// �I�u�W�F�N�g�̃e�N�X�`��
texture ObjectTexture: MATERIALTEXTURE;
sampler ObjTexSampler = sampler_state {
    texture = <ObjectTexture>;
    MINFILTER = LINEAR;
    MAGFILTER = LINEAR;
};

float3   CameraPosition	: POSITION  < string Object = "Camera"; >;


////////////////////////////////////////////////////////////////////////////////////////////////
//MMM�Ή�

#ifdef MIKUMIKUMOVING
    
    #define GETPOS MMM_SkinnedPosition(IN.Pos, IN.BlendWeight, IN.BlendIndices, IN.SdefC, IN.SdefR0, IN.SdefR1)
    
#else
    
    struct MMM_SKINNING_INPUT{
        float4 Pos : POSITION;
        float2 Tex : TEXCOORD0;
        float4 AddUV1 : TEXCOORD1;
        float4 AddUV2 : TEXCOORD2;
        float4 AddUV3 : TEXCOORD3;
        float4 Normal : NORMAL;
        
    };
    
    #define GETPOS (IN.Pos)
    
#endif


///////////////////////////////////////////////////////////////////////////////////////////////
// �I�u�W�F�N�g�`��i�Z���t�V���h�EOFF�j

struct VS_OUTPUT
{
	float4 Pos		: POSITION;    // �ˉe�ϊ����W
	float3 VPos		: TEXCOORD0;
	float2 Tex		: TEXCOORD1;
};

// ���_�V�F�[�_
VS_OUTPUT Basic_VS(MMM_SKINNING_INPUT IN)
{
	VS_OUTPUT Out = (VS_OUTPUT)0;

	float4 Pos = GETPOS;	// MMM�Ή�

	Out.Pos = mul( Pos, matWVP );
	Out.VPos = mul( Pos, matWV);
	Out.Tex = IN.Tex;
	return Out;
}

// �s�N�Z���V�F�[�_
float4 Basic_PS( VS_OUTPUT IN ) : COLOR
{
	if (use_texture)
	{
		// ���l��臒l�ȉ��̉ӏ��͕`�悵�Ȃ�
		float alpha = tex2D( ObjTexSampler, IN.Tex ).a;
		clip(alpha - AlphaThroughThreshold);
	}

	float distance = length(IN.VPos);

	return float4(distance / FAR_Z,0,0,1);
}

// �I�u�W�F�N�g�`��p�e�N�j�b�N
technique MainTec < string MMDPass = "object"; > {
    pass DrawObject
    {
        VertexShader = compile vs_2_0 Basic_VS();
        PixelShader  = compile ps_2_0 Basic_PS();
    }
}

// �I�u�W�F�N�g�`��p�e�N�j�b�N
technique MainTecBS  < string MMDPass = "object_ss"; > {
    pass DrawObject {
        AlphaBlendEnable = FALSE;
        VertexShader = compile vs_2_0 Basic_VS();
        PixelShader  = compile ps_2_0 Basic_PS();
    }
}

technique EdgeTec < string MMDPass = "edge"; > {}
technique ShadowTech < string MMDPass = "shadow";  > {}

///////////////////////////////////////////////////////////////////////////////////////////////
