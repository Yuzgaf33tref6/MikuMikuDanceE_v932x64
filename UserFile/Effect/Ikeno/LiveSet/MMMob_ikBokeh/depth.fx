//=============================================================================
// depth.fx
// ikBokeh.fxのために、線形の深度情報を出力する。
//=============================================================================

//=============================================================================
// MikuMikuMob対応 ここから

// &InsertHeader;  ここにMikuMikuMob設定ヘッダコードが挿入されます

// MikuMikuMob対応 ここまで
//=============================================================================


// パラメータ宣言

// 抜きテクスチャを無視するα値の上限
const float AlphaThroughThreshold = 0.2;

// なにもない描画しない場合の、背景までの距離
// これを弄る場合、ikBokeh.fxの同じ値も変更する必要がある。
#define FAR_DEPTH		1000

#define USE_TEXTURE		1

//=============================================================================

//=============================================================================
// depth.fx
// ikBokeh.fxのために、線形の深度情報を出力する。
//=============================================================================

//=============================================================================

// 座法変換行列
float4x4 WorldViewProjMatrix      : WORLDVIEWPROJECTION;
float4x4 WorldMatrix              : WORLD;
float4x4 ViewMatrix               : VIEW;
float4x4 ProjMatrix				  : PROJECTION;
float4x4 LightWorldViewProjMatrix : WORLDVIEWPROJECTION < string Object = "Light"; >;

float4x4 matW	: WORLD;
float4x4 matV	: VIEW;
float4x4 matVP	: VIEWPROJECTION;

float3   LightDirection    : DIRECTION < string Object = "Light"; >;
float3   CameraPosition    : POSITION  < string Object = "Camera"; >;

// マテリアル色
float4   MaterialDiffuse   : DIFFUSE  < string Object = "Geometry"; >;
// 材質モーフ対応
float4	TextureAddValue   : ADDINGTEXTURE;
float4	TextureMulValue   : MULTIPLYINGTEXTURE;

#if USE_TEXTURE > 0
// オブジェクトのテクスチャ
texture ObjectTexture: MATERIALTEXTURE;
sampler ObjTexSampler = sampler_state {
    texture = <ObjectTexture>;
    MINFILTER = LINEAR;
    MAGFILTER = LINEAR;
};
#endif

// MMD本来のsamplerを上書きしないための記述です。削除不可。
sampler MMDSamp0 : register(s0);
sampler MMDSamp1 : register(s1);
sampler MMDSamp2 : register(s2);


#if USE_TEXTURE > 0
float4 GetTextureColor(float2 uv)
{
	float4 TexColor = tex2D( ObjTexSampler, uv);
	TexColor.rgb = lerp(1, TexColor * TextureMulValue + TextureAddValue, TextureMulValue.a + TextureAddValue.a).rgb;
	return TexColor;
}
#else
float4 GetTextureColor(float2 uv) { return 1; }
#endif

//=============================================================================

struct BufferShadow_OUTPUT {
	float4 Pos		: POSITION;		// 射影変換座標
	float2 Tex		: TEXCOORD1;	// テクスチャ
	float4 VPos		: TEXCOORD2;	// Position
};


//=============================================================================
// 頂点シェーダ
BufferShadow_OUTPUT BufferShadow_VS(
	float4 Pos : POSITION, 
	float3 Normal : NORMAL, 
	float2 Tex : TEXCOORD0, 
	int vIndex : _INDEX, 
	uniform bool useTexture)
{
	BufferShadow_OUTPUT Out = (BufferShadow_OUTPUT)0;

	float4 LPos = mul( Pos, matW );
	float4 WPos = MOB_TransformPosition(LPos, vIndex);

	Out.Pos = mul(WPos, matVP);
	Out.VPos = mul(WPos, matV);

	Out.Tex = Tex;

	return Out;
}

float4 BufferShadow_PS(BufferShadow_OUTPUT IN, uniform bool useTexture) : COLOR
{
	float alpha = MaterialDiffuse.a;
	if ( useTexture ) {
		alpha *= GetTextureColor( IN.Tex ).a;
	}

	clip(alpha - AlphaThroughThreshold);

	float distance = length(IN.VPos.xyz);

	return float4(distance / FAR_DEPTH, 0, 0, 1);
}

#define BASICSHADOW_TEC(name, mmdpass, tex) \
	technique name < \
		string MMDPass = mmdpass; bool UseTexture = tex; \
		string Script = MOB_LOOPSCRIPT_OBJECT; \
	> { \
		pass DrawObject { \
			VertexShader = compile vs_3_0 BufferShadow_VS(tex); \
			PixelShader  = compile ps_3_0 BufferShadow_PS(tex); \
		} \
	}

BASICSHADOW_TEC(BTec0, "object", false)
BASICSHADOW_TEC(BTec1, "object", true)

BASICSHADOW_TEC(BSTec0, "object_ss", false)
BASICSHADOW_TEC(BSTec1, "object_ss", true)


technique EdgeTec < string MMDPass = "edge"; > {}
technique ShadowTech < string MMDPass = "shadow";  > {}
technique ZplotTec < string MMDPass = "zplot"; > {}

//=============================================================================


