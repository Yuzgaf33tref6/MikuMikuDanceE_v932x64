////////////////////////////////////////////////////////////////////////////////////////////////
// uv���W�Ƀ��[���h���W����������
//	���E���]�����ăe�N�X�`�����g���܂킵�Ă���P�[�X������̂ŁA
//	���𔼕��ɂ��āA���E���]���������̂�`�悷��B
////////////////////////////////////////////////////////////////////////////////////////////////
// �p�����[�^�錾

// ���ȏ�̔������͕s�����Ƃ݂Ȃ��B
const float AlphaThreshold = 0.75;

// ���@�ϊ��s��
float4x4 WorldMatrix			: WORLD;

// �I�u�W�F�N�g�̃e�N�X�`��
texture ObjectTexture: MATERIALTEXTURE;
sampler ObjTexSampler = sampler_state {
	texture = <ObjectTexture>;
	MINFILTER = LINEAR;
	MAGFILTER = LINEAR;
};

// MMD�{����sampler���㏑�����Ȃ����߂̋L�q�ł��B�폜�s�B
sampler MMDSamp0 : register(s0);
sampler MMDSamp1 : register(s1);
sampler MMDSamp2 : register(s2);

///////////////////////////////////////////////////////////////////////////////////////////////
// �I�u�W�F�N�g�`��i�Z���t�V���h�EOFF�j

struct VS_OUTPUT {
	float4 Pos			: POSITION;
	float2 Tex			: TEXCOORD0;
	float4 WPos			: TEXCOORD1;
};

// ���_�V�F�[�_
VS_OUTPUT BasicL_VS(float4 Pos : POSITION, float3 Normal : NORMAL, float2 Tex : TEXCOORD0, uniform bool useTexture)
{
	VS_OUTPUT Out = (VS_OUTPUT)0;

	float2 uv = Tex.xy * 2.0 - 1;
	uv.x = uv.x * 0.5 + 0.5;
	uv.y = -uv.y;
	Out.Pos = float4(uv, 0, 1);
	Out.WPos = mul( Pos, WorldMatrix );
	Out.Tex = Tex;

	return Out;
}

VS_OUTPUT BasicR_VS(float4 Pos : POSITION, float3 Normal : NORMAL, float2 Tex : TEXCOORD0, uniform bool useTexture)
{
	VS_OUTPUT Out = (VS_OUTPUT)0;

	float2 uv = Tex.xy * 2.0 - 1;
	uv.x = -uv.x * 0.5 - 0.5;
	uv.y = -uv.y;
	Out.Pos = float4(uv, 0, 1);
	Out.WPos = mul( Pos, WorldMatrix );
	Out.Tex = Tex;

	return Out;
}


// �s�N�Z���V�F�[�_
float4 Basic_PS(VS_OUTPUT IN, uniform bool useTexture) : COLOR0
{
	float4 Color = 1;
	if ( useTexture ) {
		// �e�N�X�`���K�p
		Color.a *= tex2D( ObjTexSampler, IN.Tex ).a;
		clip(Color.a - AlphaThreshold);
	}

	Color.rgb = IN.WPos;
	Color.a = 1;

	return Color;
}

#define OBJECT_TEC(name, mmdpass, tex) \
	technique name < string MMDPass = mmdpass; bool UseTexture = tex;\
		string Script = \
			"Pass=DrawObjectL;" \
			"Pass=DrawObjectR;" \
		; \
	> { \
		pass DrawObjectL { \
			VertexShader = compile vs_3_0 BasicL_VS(tex); \
			PixelShader  = compile ps_3_0 Basic_PS(tex); \
		} \
		pass DrawObjectR { \
			VertexShader = compile vs_3_0 BasicR_VS(tex); \
			PixelShader  = compile ps_3_0 Basic_PS(tex); \
		} \
	}


OBJECT_TEC(MainTec0, "object", true)
OBJECT_TEC(MainTec4, "object", false)

OBJECT_TEC(BSTec0, "object_ss", true)
OBJECT_TEC(BSTec4, "object_ss", false)


technique EdgeTec < string MMDPass = "edge"; > {}
technique ShadowTec < string MMDPass = "shadow";  > {}
technique ZplotTec < string MMDPass = "zplot"; > { }

///////////////////////////////////////////////////////////////////////////////////////////////
