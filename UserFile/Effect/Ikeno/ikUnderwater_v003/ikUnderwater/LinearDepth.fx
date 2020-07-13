// �J��������̋������i�[����
// ���z�����Ƃ̉A�e�v�Z�̌��ʂ��i�[����B

#include "Settings.fxsub"
#include "Commons.fxsub"

// �������𖳎�����臒l
const float ShadowAlphaThreshold = 0.6;


///////////////////////////////////////////////////////////////////////////////////////////////
// �p�����[�^�錾

// ���@�ϊ��s��
float4x4 matWVP	: WORLDVIEWPROJECTION;
float4x4 matWV	: WORLDVIEW;

// MMD�{����sampler���㏑�����Ȃ����߂̋L�q�ł��B�폜�s�B
sampler MMDSamp0 : register(s0);
sampler MMDSamp1 : register(s1);
sampler MMDSamp2 : register(s2);

bool	use_texture;		// �e�N�X�`���g�p

// �I�u�W�F�N�g�̃e�N�X�`��
texture ObjectTexture: MATERIALTEXTURE;
sampler ObjTexSampler = sampler_state {
    texture = <ObjectTexture>;
    MINFILTER = LINEAR;
    MAGFILTER = LINEAR;
};

float4   MaterialDiffuse	: DIFFUSE  < string Object = "Geometry"; >;


///////////////////////////////////////////////////////////////////////////////////////////////
// �I�u�W�F�N�g�`��i�Z���t�V���h�EOFF�j

struct VS_OUTPUT
{
	float4 Pos		: POSITION;    // �ˉe�ϊ����W
	float3 VPos		: TEXCOORD0;
	float2 Tex		: TEXCOORD1;
	float3 Normal	: TEXCOORD2;
	float4 WPos		: TEXCOORD3;
};

// ���_�V�F�[�_
VS_OUTPUT Basic_VS(float4 Pos : POSITION, float3 Normal : NORMAL,float2 Tex: TEXCOORD0)
{
	VS_OUTPUT Out = (VS_OUTPUT)0;
	Out.Pos = mul( Pos, matWVP );
	Out.WPos = Out.Pos;
	Out.VPos = mul( Pos, matWV).xyz;
	Out.Tex = Tex;
	Out.Normal = Normal;
	return Out;
}

// �s�N�Z���V�F�[�_
float4 Basic_PS( VS_OUTPUT IN ) : COLOR
{
	float alpha = MaterialDiffuse.a;
	if (use_texture) alpha *= tex2D( ObjTexSampler, IN.Tex ).a;
	clip(alpha - ShadowAlphaThreshold);

	float distance = length(IN.VPos);

	float3 L = normalize(WaveLightPosition - IN.WPos.xyz);
	// float3 L = -WaveLightDirection;
	float NL = saturate(dot(IN.Normal, L));
	// �����ɉ����Č���
	// NL *= saturate(100.0 / distance);

	return float4(distance / FAR_Z, NL, 0, 1);
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
        VertexShader = compile vs_2_0 Basic_VS();
        PixelShader  = compile ps_2_0 Basic_PS();
    }
}

technique EdgeTec < string MMDPass = "edge"; > {}
technique ShadowTech < string MMDPass = "shadow";  > {}

///////////////////////////////////////////////////////////////////////////////////////////////
