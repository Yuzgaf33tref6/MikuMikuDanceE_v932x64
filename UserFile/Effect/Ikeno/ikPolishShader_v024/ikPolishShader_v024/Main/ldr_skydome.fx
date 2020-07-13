//-----------------------------------------------------------------------------
// ��HDRI�ȃX�J�C�h�[���p
//-----------------------------------------------------------------------------
// �p�����[�^�錾

// ���@�ϊ��s��
float4x4 WorldViewProjMatrix		: WORLDVIEWPROJECTION;

bool bLinearBegin : CONTROLOBJECT < string name = "ikLinearBegin.x"; >;
bool bLinearEnd : CONTROLOBJECT < string name = "ikLinearEnd.x"; >;
static bool bOutputLinear = (bLinearEnd && !bLinearBegin);

// �I�u�W�F�N�g�̃e�N�X�`��
texture ObjectTexture: MATERIALTEXTURE;
sampler ObjTexSampler = sampler_state {
	texture = <ObjectTexture>;
	MINFILTER = LINEAR;
	MAGFILTER = LINEAR;
	MIPFILTER = LINEAR;
	ADDRESSU  = WRAP;
	ADDRESSV  = WRAP;
};

// �K���}�␳
const float gamma = 2.2;
const float epsilon = 1.0e-6;
inline float3 Degamma(float3 col) { return pow(max(col,epsilon), gamma); }
inline float3 Gamma(float3 col) { return pow(max(col,epsilon), 1.0/gamma); }
inline float4 Degamma4(float4 col) { return float4(Degamma(col.rgb), col.a); }
inline float4 Gamma4(float4 col) { return float4(Gamma(col.rgb), col.a); }


//-----------------------------------------------------------------------------
// 

technique EdgeTec < string MMDPass = "edge"; > {}
technique ShadowTec < string MMDPass = "shadow"; > {}
technique ZplotTec < string MMDPass = "zplot"; > {}


//-----------------------------------------------------------------------------
// �I�u�W�F�N�g�`��

struct VS_OUTPUT {
	float4 Pos		: POSITION;	// �ˉe�ϊ����W
	float2 Tex		: TEXCOORD1;	// �e�N�X�`��
};


VS_OUTPUT Object_VS(
	float4 Pos : POSITION, float3 Normal : NORMAL, 
	float2 Tex : TEXCOORD0, float2 Tex2 : TEXCOORD1)
{
	VS_OUTPUT Out = (VS_OUTPUT)0;

	Out.Pos = mul( Pos, WorldViewProjMatrix );
	Out.Tex = Tex;
	return Out;
}


float4 Object_PS(VS_OUTPUT IN) : COLOR
{
	float4 Color = tex2D( ObjTexSampler, IN.Tex );
	Color.rgb = bOutputLinear ? Color.rgb : Gamma(Color.rgb);
	Color.a = 1;
	return Color;
}


#define OBJECT_TEC(name, mmdpass) \
	technique name < string MMDPass = mmdpass; > { \
		pass DrawObject { \
			VertexShader = compile vs_3_0 Object_VS(); \
			PixelShader  = compile ps_3_0 Object_PS(); \
		} \
	}

OBJECT_TEC(MainTec0, "object")
OBJECT_TEC(MainTecBS0, "object_ss")


//-----------------------------------------------------------------------------
