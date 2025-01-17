//-----------------------------------------------------------------------------
// 材質設定ファイル

#include "Material_header.fxsub"

// マテリアルタイプ
#define MATERIAL_TYPE		MT_NORMAL
/*
MT_NORMAL	: 通常 (金属を含む)
MT_FACE		: 肌 (顔用)
MT_LEAF		: 葉やカーテンなど、裏が透ける材質用。
MT_MASK		: スカイドーム用。
*/

// 使用するテクスチャファイル名
#define TEXTURE_FILENAME_0	"textures/check.png"
#define TEXTURE_FILENAME_1	"textures/check.png"
#define TEXTURE_FILENAME_2	"textures/check.png"
#define TEXTURE_FILENAME_3	"textures/check.png"
// TEXTURE_FILENAME_x の数字を、以下の xxx_MAP_FILE で指定する。


// 金属かどうか。≒ 反射の強さ
// 数値が高いほど反射が強くなる＆元の色の影響を受けるようになる。
// 0: 非金属、1:金属。宝石などは0.1-0.2程度。
#define	METALNESS_VALUE			0.0
#define	METALNESS_MAP_ENABLE	0	// 0:VALUEを使う、1: テクスチャで指定する
#define METALNESS_MAP_FILE		0	// 使用するテクスチャファイル番号を指定。0-3
#define METALNESS_MAP_CHANNEL	R	// 使用するテクスチャのチャンネル。R,G,B,A
#define METALNESS_MAP_LOOPNUM	1.0
#define METALNESS_MAP_SCALE		1.0
#define METALNESS_MAP_OFFSET	0.0

// xxx_ENABLE: 1の場合、テクスチャから値を読み込む。
// xxx_LOOPNUM: テクスチャの繰り返す回数。1なら等倍。数字が大きいほど細かくなる。
// xxx_SCALE, xxx_OFFSET: 値は (テクスチャの値 * scale + offset) で計算する。


// 表面の滑らかさ
// SMOOTHNESS_TYPE = 1 の場合、0:マット、1:滑らか。
// SMOOTHNESS_TYPE = 2 の場合、0:滑らか、1:マット。

// Smoothnessの指定方法：
// 0: モデルのスペキュラパワーから自動で決定する。
// 1: スムースネスを使用。
// 2: ラフネスを使用。
#define SMOOTHNESS_TYPE		0

#define	SMOOTHNESS_VALUE		1.0
#define	SMOOTHNESS_MAP_ENABLE	0
#define SMOOTHNESS_MAP_FILE		0
#define SMOOTHNESS_MAP_CHANNEL	R
#define SMOOTHNESS_MAP_LOOPNUM	1.0
#define SMOOTHNESS_MAP_SCALE	1.0
#define SMOOTHNESS_MAP_OFFSET	0.0

// 金属の反射色をベース色だけから求める?
// 0: ベース色 * スペキュラ色で決定。(ver0.16以前の方式)
// 1: ベース色のみで決定。
// 2: スペキュラ色のみで決定。
// ※ 非金属の場合は、設定とは無関係に白になる。
#define SPECULAR_COLOR_TYPE		0


// スペキュラ強度

// Intensityの扱い：
#define INTENSITY_TYPE		0
// 0: Specular Intensity. スペキュラ強度の調整
// 1: Ambient Occlusion. 間接光へのマスク
// 2: Cavity. 全てのライティングを遮蔽
// 3: Cavity (View Dependent). 全てのライティングを遮蔽(視線依存)

// 0:ハイライトなし、1:ハイライトあり
#define	INTENSITY_VALUE			1.0
#define	INTENSITY_MAP_ENABLE	0
#define INTENSITY_MAP_FILE		0
#define INTENSITY_MAP_CHANNEL	R
#define INTENSITY_MAP_LOOPNUM	1.0
#define INTENSITY_MAP_SCALE		1.0
#define INTENSITY_MAP_OFFSET	0.0


// 発光度
// ※発光度と皮下散乱度は共有できない。
#define	EMISSIVE_TYPE			0
// 0: AL対応
// 1: 発光しない (軽い)
// 2: ここで指定。EMISSIVE_VALUE or EMISSIVE_MAP
// 3: 追加ライト用
// 4: 追加ライト用(スクリーン)

// 以下は EMISSIVE_TYPE 2の場合の設定：
#define	EMISSIVE_VALUE			1.0 // 0.0〜8.0
#define	EMISSIVE_MAP_ENABLE		0
#define EMISSIVE_MAP_FILE		0
#define EMISSIVE_MAP_CHANNEL	R
#define EMISSIVE_MAP_LOOPNUM	1.0
#define EMISSIVE_MAP_SCALE		1.0 // 0.0〜8.0
#define EMISSIVE_MAP_OFFSET		0.0


// 皮下散乱度：肌、プラスチックなどの半透明なものに指定。
// 0:不透明。1:半透明。
// 金属の場合は無視される。
#define	SSS_VALUE			0.0
#define	SSS_MAP_ENABLE		0
#define SSS_MAP_FILE		0
#define SSS_MAP_CHANNEL		R
#define SSS_MAP_LOOPNUM		1.0
#define SSS_MAP_SCALE		1.0
#define SSS_MAP_OFFSET		0.0



//-----------------------------------------------------------------------------
// その他

// この値以下の半透明度ならマテリアル的には透明扱いにする。
#define AlphaThreshold		0.5


//-----------------------------------------------------------------------------
// 法線マップ

// 法線マップを使用するか? 0:未使用。1:使用
#define NORMALMAP_ENABLE		0

// メイン法線マップ
#define NORMALMAP_MAIN_FILENAME "textures/dummy_n.bmp"
#define NORMALMAP_MAIN_LOOPNUM	1.0
#define NORMALMAP_MAIN_HEIGHT	1.0

// サブ法線マップ
#define NORMALMAP_SUB_ENABLE	0
#define NORMALMAP_SUB_FILENAME "textures/dummy_n.bmp"
#define NORMALMAP_SUB_LOOPNUM	1.0
#define NORMALMAP_SUB_HEIGHT	1.0


//=============================================================================
// MikuMikuMob対応 ここから

// &InsertHeader;  ここにMikuMikuMob設定ヘッダコードが挿入されます

// MikuMikuMob対応 ここまで
//=============================================================================

// スフィアマップを無視する
#define	IGNORE_SPHERE

/*
#if MATERIAL_TYPE != MT_EMISSIVE
#undef	EMISSIVE_TYPE
#define	EMISSIVE_TYPE	1
#endif
*/

// 座法変換行列
float4x4 matW		: WORLD;
float4x4 matV		: VIEW;
float4x4 matVP		: VIEWPROJECTION;

// マテリアル色
float4	MaterialDiffuse		: DIFFUSE  < string Object = "Geometry"; >;
float3	MaterialAmbient		: AMBIENT  < string Object = "Geometry"; >;
float3	MaterialEmissive	: EMISSIVE < string Object = "Geometry"; >;
float3	MaterialSpecular	: SPECULAR < string Object = "Geometry"; >;
float	SpecularPower		: SPECULARPOWER < string Object = "Geometry"; >;

float3	CameraPosition		: POSITION  < string Object = "Camera"; >;
float3	LightDiffuse		: DIFFUSE   < string Object = "Light"; >;

// 材質モーフ対応
float4	TextureAddValue		: ADDINGTEXTURE;
float4	TextureMulValue		: MULTIPLYINGTEXTURE;
float4	SphereAddValue		: ADDINGSPHERETEXTURE;
float4	SphereMulValue		: MULTIPLYINGSPHERETEXTURE;

bool	use_texture;
bool	use_subtexture;    // サブテクスチャフラグ
bool	spadd;	// スフィアマップ加算合成フラグ

sampler MMDSamp0 : register(s0);
sampler MMDSamp1 : register(s1);
sampler MMDSamp2 : register(s2);

// オブジェクトのテクスチャ
texture ObjectTexture: MATERIALTEXTURE;
sampler ObjTexSampler = sampler_state {
	texture = <ObjectTexture>;
	MINFILTER = LINEAR;	MAGFILTER = LINEAR;
	ADDRESSU  = WRAP;	ADDRESSV  = WRAP;
};
#if EMISSIVE_TYPE == 4
shared texture SavedScreen: RENDERCOLORTARGET;
sampler LightSamp = sampler_state {
	texture = <SavedScreen>;
	MinFilter = LINEAR;	MagFilter = LINEAR;	MipFilter = LINEAR;
	AddressU  = CLAMP; AddressV  = CLAMP;
};
#endif


#if !defined(IGNORE_SPHERE)
// スフィアマップのテクスチャ
texture ObjectSphereMap: MATERIALSPHEREMAP;
sampler ObjSphereSampler = sampler_state {
	texture = <ObjectSphereMap>;
	MINFILTER = LINEAR;	MAGFILTER = LINEAR;
	ADDRESSU  = WRAP;	ADDRESSV  = WRAP;
};
#endif

static float4 DiffuseColor  = float4(saturate((MaterialAmbient.rgb+MaterialEmissive.rgb)),MaterialDiffuse.a);


// ガンマ補正
#define Degamma(x)	pow(max(x,1e-4), 2.2)
float Luminance(float3 rgb)
{
	return dot(float3(0.299, 0.587, 0.114), max(rgb,0));
}

//static float3 SpecularColor = (Degamma(MaterialSpecular)) * 0.95 + 0.05;
static float3 SpecularColor = (Degamma(MaterialSpecular * (LightDiffuse.r * 9 + 1))) * 0.95 + 0.05;
	// MaterialSpecular はモデルなら1、アクセサリなら1/10になる。
	// LightDiffuse は モデルなら0,0,0、アクセサリなら1,1,1になる。


//-----------------------------------------------------------------------------
// 

// 指定IDのテクスチャを使用しているか?
#define USE_TEXTURE_ID(n)	\
	((METALNESS_MAP_ENABLE > 0 && METALNESS_MAP_FILE == n) || \
	(SMOOTHNESS_MAP_ENABLE > 0 && SMOOTHNESS_MAP_FILE == n) || \
	(EMISSIVE_MAP_ENABLE > 0 && EMISSIVE_MAP_FILE == n) || \
	(INTENSITY_MAP_ENABLE > 0 && INTENSITY_MAP_FILE == n) || \
	(SSS_MAP_ENABLE > 0 && SSS_MAP_FILE == n))

#define TEXTURER_SAMPLER(_TexID)	TextureSamp_##_TexID

// テクスチャの登録
#define DECL_TEXTURE( _TexID) \
	texture2D TextureMap_##_TexID < string ResourceName = TEXTURE_FILENAME_##_TexID; >; \
	sampler2D TEXTURER_SAMPLER(_TexID) = sampler_state { \
		texture = <TextureMap_##_TexID>; \
		MinFilter = Linear;	MagFilter = Linear;	MipFilter = None; \
		AddressU  = WRAP;	AddressV  = WRAP; \
	};

#define GET_CHANNEL_VALUE(vals, ch)	vals##.##ch

#define DECL_READ_TEXTURE( _FuncName, _MacroName) \
	float Get##_FuncName(float2 uv) { \
		float4 vals = tex2D( TEXTURER_SAMPLER(_MacroName##_FILE), uv * (_MacroName##_LOOPNUM)); \
		float val = GET_CHANNEL_VALUE(vals, _MacroName##_CHANNEL); \
		return (val * (_MacroName##_SCALE) + (_MacroName##_OFFSET)); \
	}

#if USE_TEXTURE_ID(0)
DECL_TEXTURE(0)
#endif
#if USE_TEXTURE_ID(1)
DECL_TEXTURE(1)
#endif
#if USE_TEXTURE_ID(2)
DECL_TEXTURE(2)
#endif
#if USE_TEXTURE_ID(3)
DECL_TEXTURE(3)
#endif

#if METALNESS_MAP_ENABLE > 0
DECL_READ_TEXTURE( Metalness, METALNESS_MAP)
#else
float GetMetalness(float2 uv) { return METALNESS_VALUE; }
#endif

#if SMOOTHNESS_MAP_ENABLE > 0
DECL_READ_TEXTURE( Smoothness, SMOOTHNESS_MAP)
#else
	#if SMOOTHNESS_TYPE == 0
	float GetSmoothness(float2 uv) { return saturate((log2(SpecularPower+1)-1)/8.0); }
	#else
	float GetSmoothness(float2 uv) { return SMOOTHNESS_VALUE; }
	#endif
#endif

#if SSS_MAP_ENABLE > 0
DECL_READ_TEXTURE( SSSValue, SSS_MAP)
#else
float GetSSSValue(float2 uv) { return SSS_VALUE; }
#endif

#if INTENSITY_MAP_ENABLE > 0
DECL_READ_TEXTURE( Intensity, INTENSITY_MAP)
#else
float GetIntensity(float2 uv) { return 1.0; }
#endif


//-----------------------------------------------------------------------------


#if NORMALMAP_ENABLE > 0
//メイン法線マップ
#define ANISO_NUM 16

#define DECL_NORMAL_TEXTURE( _name, _res) \
	texture2D _name##Map < string ResourceName = _res; >; \
	sampler2D _name##Samp = sampler_state { \
		texture = <_name##Map>; \
		MINFILTER = ANISOTROPIC;	MAGFILTER = ANISOTROPIC;	MIPFILTER = ANISOTROPIC; \
		MAXANISOTROPY = ANISO_NUM; \
		AddressU  = WRAP;	AddressV  = WRAP; \
	}; \

DECL_NORMAL_TEXTURE( NormalMain, NORMALMAP_MAIN_FILENAME)
#if NORMALMAP_SUB_ENABLE > 0
DECL_NORMAL_TEXTURE( NormalSub, NORMALMAP_SUB_FILENAME)
#endif
#endif

shared texture PPPNormalMapRT: RENDERCOLORTARGET;
shared texture PPPMaterialMapRT: RENDERCOLORTARGET;
// shared texture PPPAlbedoMapRT: RENDERCOLORTARGET;
#if SMOOTHNESS_TYPE == 2
float ConvertToRoughness(float val) { return val; }
#else
float ConvertToRoughness(float val) { return 1 - val; }
#endif


#if EMISSIVE_TYPE == 0
#define ENABLE_AL	1
#elif EMISSIVE_TYPE == 3 || EMISSIVE_TYPE == 4
#define IS_LIGHT	1
#endif


struct VS_OUTPUT
{
	float4 Pos		: POSITION;
	float3 Normal	: TEXCOORD0;
	float4 Tex		: TEXCOORD1;
	float4 WPos		: TEXCOORD2;
	#if !defined(IGNORE_SPHERE)
	float2 SpTex	: TEXCOORD3;
	#endif
	float Smoothness	: TEXCOORD4;

	#if ENABLE_AL > 0
	float4 ColorAL	: COLOR0;		// AL用の発光色
	#endif
};

struct PS_OUT_MRT
{
	float4 Color		: COLOR0;
	float4 Normal		: COLOR1;
	float4 Material		: COLOR2;
//	float4 Albedo		: COLOR3;
};


//-----------------------------------------------------------------------------
// 自己発光

#if ENABLE_AL > 0

//テクスチャ高輝度識別閾値
float LightThreshold = 0.9;

bool	use_spheremap;		//	スフィアフラグ
bool	use_toon;

#include "autoluminous.fxsub"
#endif

#if IS_LIGHT > 0
#define MaxLightIntensity	8
float mLightIntensityP : CONTROLOBJECT < string name = "(self)"; string item = "ライト強度+"; >;
float mLightIntensityN : CONTROLOBJECT < string name = "(self)"; string item = "ライト強度-"; >;
static float3 LightIntensity = (mLightIntensityP * (MaxLightIntensity - 1) + 1.0) * saturate(1.0 - mLightIntensityN);
#endif

#if EMISSIVE_TYPE == 2
#if EMISSIVE_MAP_ENABLE > 0
DECL_READ_TEXTURE( EmissiveValue, EMISSIVE_MAP)
#else
float GetEmissiveValue(float2 uv) { return EMISSIVE_VALUE; }
#endif
#endif

float4 GetEmissiveColor(VS_OUTPUT IN, float4 baseColor, out float emissive)
{
	emissive = 0;

#if ENABLE_AL > 0
	float4 alColor = GetAutoluminousColor(IN.ColorAL, IN.Tex);
	baseColor.rgb += alColor.rgb;
	emissive = alColor.w;

#elif EMISSIVE_TYPE == 1
	// 発行しない

#elif EMISSIVE_TYPE == 2
	// 真っ黒または透明なら無視
	float colorIntensity = dot(baseColor.rgb, 1);
	emissive = GetEmissiveValue(IN.Tex) * baseColor.a * (colorIntensity > 0.0);
	baseColor.a = (emissive > 0.0) ? 1 : baseColor.a;

#elif IS_LIGHT > 0
	// 追加ライト EMISSIVE_TYPE == 3, 4
/*
	// ??? ライトの色にすべき?
	float isLight = dot(MaterialEmissive, 1.0) > 0.0;
	emissive = isLight * LightIntensity;
	baseColor.rgb = isLight ? MaterialEmissive : baseColor;
*/
	// @@@emissive
	emissive = (dot(baseColor.rgb, 1) * baseColor.a > 0.0) * LightIntensity;

#endif

	emissive = saturate(emissive  / 8.0); // * baseColor.a
	return baseColor;
}


//-----------------------------------------------------------------------------
// 

#if NORMALMAP_ENABLE > 0
float3x3 compute_tangent_frame(float3 Normal, float3 View, float2 UV)
{
  float3 dp1 = ddx(View);
  float3 dp2 = ddy(View);
  float2 duv1 = ddx(UV);
  float2 duv2 = ddy(UV);

  float3x3 M = float3x3(dp1, dp2, cross(dp1, dp2));
  float2x3 inverseM = float2x3(cross(M[1], M[2]), cross(M[2], M[0]));
  float3 Tangent = mul(float2(duv1.x, duv2.x), inverseM);
  float3 Binormal = mul(float2(duv1.y, duv2.y), inverseM);

  return float3x3(normalize(Tangent), normalize(Binormal), Normal);
}

float4 CalcNormal(float2 Tex,float3 Eye,float3 Normal)
{
	float2 tex = Tex* NORMALMAP_MAIN_LOOPNUM; //メイン
	float4 NormalColor = tex2D( NormalMainSamp, tex) * 2 - 1;
	NormalColor.xy *= NORMALMAP_MAIN_HEIGHT;

	#if NORMALMAP_SUB_ENABLE > 0
	float2 texSub = Tex * NORMALMAP_SUB_LOOPNUM; //サブ
	float4 NormalColorSub = tex2D( NormalSubSamp, texSub) * 2 - 1;
	NormalColor.xy += NormalColorSub.xy * NORMALMAP_SUB_HEIGHT;
	#endif

	NormalColor.xyz = normalize(NormalColor.xyz);
	NormalColor.w = 1;

	float4 Norm = 1;
	float3x3 tangentFrame = compute_tangent_frame(Normal, Eye, Tex);
	Norm.xyz = normalize(mul(NormalColor.xyz, tangentFrame));
	return Norm;
}
#else
float4 CalcNormal(float2 Tex,float3 Eye,float3 Normal)
{
	return float4(Normal,1);
}
#endif


float4 GetTextureColor(float2 uv)
{
	float4 TexColor = tex2D( ObjTexSampler, uv);

	#if EMISSIVE_TYPE == 4
	TexColor.rgb = tex2D( LightSamp, uv).rgb;
	#endif

	TexColor.rgb = lerp(1, TexColor * TextureMulValue + TextureAddValue, TextureMulValue.a + TextureAddValue.a).rgb;
	return TexColor;
}

float4 GetSphereColor(float2 uv)
{
	#if !defined(IGNORE_SPHERE)
	float4 TexColor = tex2D(ObjSphereSampler, uv);
	TexColor.rgb = lerp(spadd?0:1, TexColor * SphereMulValue + SphereAddValue, SphereMulValue.a + SphereAddValue.a).rgb;
	return TexColor;
	#else
	return 1;
	#endif
}


//-----------------------------------------------------------------------------
// オブジェクト描画

VS_OUTPUT Basic_VS(float4 inPos : POSITION,
	float3 inNormal : NORMAL,
	float2 Tex: TEXCOORD0,
	#if ENABLE_AL > 0
	float4 AddUV1 : TEXCOORD1,
	float4 AddUV2 : TEXCOORD2,
	float4 AddUV3 : TEXCOORD3,
	#endif
	int vIndex : _INDEX, 
	uniform bool useTexture, uniform bool useSphereMap)
{
	VS_OUTPUT Out = (VS_OUTPUT)0;

	float4 LPos = mul( inPos, matW );
	float3 LNormal = mul( inNormal.xyz, (float3x3)matW );
	MOB_TRANSFORM TrOut = MOB_TransformPositionNormal(LPos, LNormal, vIndex);
	float4 WPos = TrOut.Pos;
	float3 WNormal = TrOut.Normal;

	Out.Pos = mul( WPos, matVP );
	Out.Normal = WNormal;
	Out.Tex.xy = Tex;
	Out.WPos = float4(WPos.xyz, mul(WPos, matV).z);

	#if !defined(IGNORE_SPHERE)
	if ( useSphereMap && !spadd) {
		float2 NormalWV = normalize(mul( WNormal, (float3x3)matV )).xy;
		Out.SpTex.x = NormalWV.x * 0.5f + 0.5f;
		Out.SpTex.y = NormalWV.y * -0.5f + 0.5f;
	}
	#endif

	#if ENABLE_AL > 0
	float2 ALTex;
	Out.ColorAL = DecodeALInfo(AddUV1, AddUV2, AddUV3, ALTex);
	Out.Tex.zw = ALTex;
	#endif

	#if SMOOTHNESS_MAP_ENABLE == 0
	Out.Smoothness.x = GetSmoothness(0);
	#endif

	return Out;
}


PS_OUT_MRT Basic_PS( VS_OUTPUT IN, uniform bool useTexture, uniform bool useSphereMap) : COLOR
{
	PS_OUT_MRT Out = (PS_OUT_MRT)0;

	float2 texCoord = IN.Tex.xy;

	float4 albedo = DiffuseColor;
	#if MATERIAL_TYPE == MT_MASK && MASK_FOR_SKYDOME > 0
	#else
	if ( useTexture ) albedo *= GetTextureColor(texCoord);
	#endif

	#if !defined(IGNORE_SPHERE)
	if ( useSphereMap && !spadd) albedo.rgb *= GetSphereColor(IN.SpTex).rgb;
	#endif
	albedo.rgb = Degamma(albedo.rgb);

	float3 V = normalize(CameraPosition - IN.WPos.xyz);
	float3 N = CalcNormal(texCoord, V, normalize(IN.Normal)).xyz;
	float depth = IN.WPos.w;

#if MATERIAL_TYPE != MT_MASK

	float metalness = saturate(GetMetalness(texCoord));
	#if SMOOTHNESS_MAP_ENABLE > 0
	float smoothness = GetSmoothness(texCoord);
	#else
	float smoothness = IN.Smoothness.x;
	#endif
	float roughness = saturate(ConvertToRoughness(smoothness));
	float sssValue = lerp(saturate(GetSSSValue(texCoord)), 0, metalness);
	float intensity = saturate(GetIntensity(texCoord) * 0.5);

	float emissive = 0;
	albedo = GetEmissiveColor(IN, albedo, emissive);

	clip(albedo.a - AlphaThreshold);

	//-----------------------------------------------------------------------------
	// 属性設定
	// emissiveとsssは排他的
	float attribute = (emissive >= 1.0/255.0) ? (MT_EMISSIVE) : (MATERIAL_TYPE);
	float extraValue = (attribute == MT_EMISSIVE) ? emissive : sssValue;

	#if INTENSITY_TYPE == 0
	// 何もしない
	#elif INTENSITY_TYPE == 1
	attribute += MT_AO;
	#elif INTENSITY_TYPE == 2
	attribute += MT_CAVITY;
	#elif INTENSITY_TYPE == 3
	attribute += MT_CAVITY;
	float NV = saturate(dot(N,V));
	float cavity = (1.0 - NV) * (1.0 - NV);
	intensity = lerp(intensity, 1, cavity);
	#endif
	float extraValue2 = intensity;

	float materialID = attribute / 255.0;

	//-----------------------------------------------------------------------------

	#if USE_ALBEDO_AS_SPECULAR_COLOR == 0
	// OLD STYLE
	float3 speccol = (albedo.rgb * 0.5 + 0.5) * SpecularColor;
	albedo.rgb = lerp(albedo.rgb, speccol, metalness);
	#elif USE_ALBEDO_AS_SPECULAR_COLOR == 1
	// なにもしない
	#elif USE_ALBEDO_AS_SPECULAR_COLOR == 2
	// スペキュラ色のみで決定
	albedo.rgb = lerp(albedo.rgb, SpecularColor, metalness);
	#endif

	Out.Color = float4(albedo.rgb, extraValue2);
	Out.Material = float4(metalness, roughness, extraValue, materialID);
//	Out.Albedo = float4(albedo.rgb, 1);

#else
	// マスク
#endif

	Out.Normal = float4(N, depth);

	return Out;
}

#define OBJECT_TEC(name, mmdpass, tex, sphere) \
	technique name < string MMDPass = mmdpass; \
	string Script = \
		"RenderColorTarget0=;" \
		"RenderColorTarget1=PPPNormalMapRT;" \
		"RenderColorTarget2=PPPMaterialMapRT;" \
		MOB_LOOPSCRIPT_OBJECT \
	; \
	> { \
		pass DrawObject { \
			AlphaTestEnable = FALSE; AlphaBlendEnable = FALSE; \
			VertexShader = compile vs_3_0 Basic_VS(tex, sphere); \
			PixelShader  = compile ps_3_0 Basic_PS(tex, sphere); \
		} \
	}


OBJECT_TEC(MainTec0, "object", use_texture, use_subtexture)
OBJECT_TEC(MainTecBS0, "object_ss", use_texture, use_subtexture)

technique EdgeTec < string MMDPass = "edge"; > {}
technique ShadowTech < string MMDPass = "shadow";  > {}
technique ZplotTec < string MMDPass = "zplot"; > {}

//-----------------------------------------------------------------------------
