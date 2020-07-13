////////////////////////////////////////////////////////////////////////////////////////////////
//
//
////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////////

#include "../ikPolishShader.fxsub"
//#include "shadowCommons.fxsub"

// �e�V���h�E�}�b�v�̊Ԃ̋��E�̕�
#define BorderOffset	(1.0 / SHADOW_TEX_SIZE)

float4x4 matInvV		: VIEWINVERSE;
float4x4 matInvP		: PROJECTIONINVERSE;

float3	LightDirection	: DIRECTION < string Object = "Light"; >;
float3	CameraPosition	: POSITION  < string Object = "Camera"; >;
float3	CameraDirection	: DIRECTION  < string Object = "Camera"; >;

#include "shadow_common.fxsub"

////////////////////////////////////////////////////////////////////////////////////////////////
// ���@�ϊ��s��
float4x4 matW			: WORLD;

//static float4x4 lightMatWVP = mul(mul(matW, lightMatV), lightMatP);
static float4x4 matLightWVP = mul(mul(matW, matLightVs), matLightPs);

float4x4 matWVP				: WORLDVIEWPROJECTION;

// �}�e���A���F
float4   MaterialDiffuse   : DIFFUSE  < string Object = "Geometry"; >;

bool opadd;		// ���Z�����t���O

// �I�u�W�F�N�g�̃e�N�X�`��
texture ObjectTexture: MATERIALTEXTURE;
sampler ObjTexSampler = sampler_state {
	texture = <ObjectTexture>;
	MINFILTER = LINEAR; MAGFILTER = LINEAR; MIPFILTER = LINEAR;
	ADDRESSU  = WRAP; ADDRESSV  = WRAP;
};

///////////////////////////////////////////////////////////////////////////////////////////////
// �I�u�W�F�N�g�`��i�Z���t�V���h�EON�j

struct DrawObject_OUTPUT {
	float4 Pos		: POSITION;		// �ˉe�ϊ����W
	float2 Tex		: TEXCOORD0;	// �e�N�X�`��
	float2 Tex2		: TEXCOORD1;
	float4 PPos		: TEXCOORD2;
};

DrawObject_OUTPUT DrawObject_VS(float4 Pos : POSITION, float3 Normal : NORMAL, float2 Tex : TEXCOORD0, uniform int cascadeIndex)
{
	DrawObject_OUTPUT Out = (DrawObject_OUTPUT)0;
	Out.Pos = mul( Pos, matLightWVP );
	// Out.Pos /= Out.Pos.w; // matLightP��w�����͖����̂ŁAw��1���Ƃ���΁AmatW�ɂ��X�P�[�����O�B

	if (cascadeIndex == 0)
	{
		Out.Tex2 = float2(-1, 1);
	}
	else if (cascadeIndex == 1)
	{
		Out.Tex2 = float2( 1, 1);
	}
	else if (cascadeIndex == 2)
	{
		Out.Tex2 = float2(-1,-1);
	}
	else
	{
		Out.Tex2 = float2( 1,-1);
	}

	Out.Pos.xy = Out.Pos.xy * lightParam[cascadeIndex].xy + lightParam[cascadeIndex].zw;
	Out.Pos.xy = Out.Pos.xy * 0.5 + (Out.Tex2 * 0.5f);

	// depth clamping
	Out.Pos.z = max(Out.Pos.z, LightZMin / LightZMax);
	Out.Pos.w *= (opadd ? 0 : 1); // ���Z�������Ȃ疳������

	Out.PPos = Out.Pos;
	Out.Tex = Tex;

	return Out;
}

float4 DrawObject_PS(DrawObject_OUTPUT IN, uniform int cascadeIndex, uniform bool useTexture) : COLOR
{
	float2 clipUV = (IN.PPos.xy / IN.PPos.w - BorderOffset) * IN.Tex2;
	clip(  clipUV.x);
	clip(  clipUV.y);

	float alpha = MaterialDiffuse.a;
	alpha *= (abs(MaterialDiffuse.a - 0.98) >= 0.01); // ??
	if ( useTexture ) alpha *= tex2D( ObjTexSampler, IN.Tex.xy ).a;
	clip(alpha - CasterAlphaThreshold);

	float z = IN.PPos.z;
	return float4(z, z*z, 0, 1);
}


#if defined(ENABLE_DOUBLE_SIDE_SHADOW) && ENABLE_DOUBLE_SIDE_SHADOW > 0
#define	SetCullMode		CullMode = NONE;
#else
#define	SetCullMode
#endif

#define OBJECT_TEC(name, mmdpass, tex) \
	technique name < string MMDPass = mmdpass; \
	> { \
		pass DrawObject0 { \
			SetCullMode \
			AlphaBlendEnable = FALSE;	AlphaTestEnable = TRUE; \
			VertexShader = compile vs_3_0 DrawObject_VS(0); \
			PixelShader  = compile ps_3_0 DrawObject_PS(0, tex); \
		} \
		pass DrawObject1 { \
			SetCullMode \
			AlphaBlendEnable = FALSE;	AlphaTestEnable = TRUE; \
			VertexShader = compile vs_3_0 DrawObject_VS(1); \
			PixelShader  = compile ps_3_0 DrawObject_PS(1, tex); \
		} \
		pass DrawObject2 { \
			SetCullMode \
			AlphaBlendEnable = FALSE;	AlphaTestEnable = TRUE; \
			VertexShader = compile vs_3_0 DrawObject_VS(2); \
			PixelShader  = compile ps_3_0 DrawObject_PS(2, tex); \
		} \
		pass DrawObject3 { \
			SetCullMode \
			AlphaBlendEnable = FALSE;	AlphaTestEnable = TRUE; \
			VertexShader = compile vs_3_0 DrawObject_VS(3); \
			PixelShader  = compile ps_3_0 DrawObject_PS(3, tex); \
		} \
	}



technique DepthTec0 < string MMDPass = "object"; >{}

bool use_texture;
OBJECT_TEC(DepthTecBS2, "object_ss", use_texture)

technique EdgeTec < string MMDPass = "edge"; > {}
technique ShadowTec < string MMDPass = "shadow"; > {}
technique ZplotTec < string MMDPass = "zplot"; > {}


///////////////////////////////////////////////////////////////////////////////////////////////
