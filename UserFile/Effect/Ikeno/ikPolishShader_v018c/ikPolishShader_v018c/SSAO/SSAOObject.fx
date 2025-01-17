///////////////////////////////////////////////////////////////////////////////
//
///////////////////////////////////////////////////////////////////////////////

#include "../ikPolishShader.fxsub"
#include "../Sources/structs.fxsub"
#include "../Sources/mmdutil.fxsub"
#include "../Sources/colorutil.fxsub"

// 座標変換行列
//float4x4 matW				: WORLD;
float4x4 matWV				: WORLDVIEW;
float4x4 matP				: PROJECTION;
float4x4 CalcViewProjMatrix(float4x4 v, float4x4 p)
{
	p._11_22 *= GIFrameScale;
	return mul(v, p);
}
static float4x4 matWVP = CalcViewProjMatrix(matWV, matP);

// マテリアル色
float4 MaterialDiffuse   : DIFFUSE  < string Object = "Geometry"; >;

bool use_texture;

//-----------------------------------------------------------------------------
// オブジェクト描画

struct VS_OUTPUT {
	float4 Pos	   : POSITION;	// 射影変換座標
	float4 TexDistance	   : TEXCOORD0;   // テクスチャ + 深度
	float4 Color		: COLOR0;	// ディフューズ色
};


VS_OUTPUT Basic_VS(VS_AL_INPUT IN)
{
	VS_OUTPUT Out = (VS_OUTPUT)0;

	float4 pos = IN.Pos;
	Out.Pos = mul( pos, matWVP );

	// float3 Normal = IN.Normal.xyz;
	// Out.Normal = normalize( mul( Normal, (float3x3)matW ) );

	Out.TexDistance.xy = IN.Tex;
	Out.TexDistance.z = mul(pos, matWV).z;

	Out.Color = saturate( MaterialDiffuse );

	return Out;
}


float4 Basic_PS(VS_OUTPUT IN, uniform bool bUseTexture) : COLOR
{
	float4 Color = IN.Color;
	if (bUseTexture) Color *= GetTextureColor(IN.TexDistance.xy);
	clip(Color.a - AlphaThreshold);

	return float4(IN.TexDistance.z, 0,0,1);
}

#define OBJECT_TEC(name, mmdpass) \
	technique name < string MMDPass = mmdpass; \
	> { \
		pass DrawObject { \
			AlphaTestEnable = FALSE; AlphaBlendEnable = FALSE; \
			VertexShader = compile vs_3_0 Basic_VS(); \
			PixelShader  = compile ps_3_0 Basic_PS(use_texture); \
		} \
	}


OBJECT_TEC(MainTec0, "object")
OBJECT_TEC(MainTecBS1, "object_ss")

technique EdgeTec < string MMDPass = "edge"; > {}
technique ShadowTec < string MMDPass = "shadow"; > {}
technique ZplotTec < string MMDPass = "zplot"; > {}


//-----------------------------------------------------------------------------
