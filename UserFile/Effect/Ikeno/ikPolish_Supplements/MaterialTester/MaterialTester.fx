////////////////////////////////////////////////////////////////////////////////////////////////
// MaterialTester�p�ɃJ�X�^�}�C�Y����PolsihMain.fx
////////////////////////////////////////////////////////////////////////////////////////////////

// �p�����[�^�錾

#define ToonColor_Scale			0.5			// �g�D�[���F����������x�����B(0.0�`1.0)

// ���X�y�L����
// �Ԃ̃R�[�g�w�ƃ{�f�B�{�́A�畆�Ɗ��Ȃǂ̂悤�ɕ����̃n�C���C�g������ꍇ�p
const float SecondSpecularSmooth =	 0.4;		// 1�ɋ߂Â��قǃX�y�L�������s���Ȃ�B(0�`1)
const float SecondSpecularIntensity = 0.0;		// �X�y�L�����̋��x�B0�ŃI�t�B1�œ��{�B(0�`)

// PMXEditor�̊��F�����C�g�̋����̉e�����󂯂�悤�ɂ���B
// #define EMMISIVE_AS_AMBIENT
#define IGNORE_EMISSIVE			// ���F�𖳌��ɂ���B

// AutoLuminous�΍�B���邢�������J�b�g����B
// #define DISABLE_HDR

// �X�t�B�A�}�b�v����
// �X�t�B�A�}�b�v�ɂ��U�n�C���C�g���s���R�Ɍ�����ꍇ�ɖ���������B
// NCHL�p�̃��f�����g���ꍇ���A�X�t�B�A�}�b�v�𖳌��ɂ���B
//#define IGNORE_SPHERE

// �X�t�B�A�}�b�v�̋��x
float3 SphereScale = float3(1.0, 1.0, 1.0) * 0.25;

// �e�X�g�p�F�F�𖳎�����B
//#define DISABLE_COLOR

// �X�y�L�����ɉ����ĕs�����x���グ��B
// �L���ɂ���ƁA�K���X�Ȃǂɉf��n�C���C�g����苭���o��B
// #define ENABLE_SPECULAR_ALPHA

//----------------------------------------------------------
// SSS�p�̐ݒ�

// �t������̌��Ŗ��邭����(�J�[�e����t���ςȂǂɎg��)
//#define ENABLE_BACKLIGHT

// �ގ��ݒ��SSS�ɂ��A�ɂ��񂾌��ɂ��F
#define ScatterColor	MaterialToon
//#define ScatterColor	float3(1.0, 0.6, 0.3)

// SSS���ʂ�L���ɂ��邩�B
// #define ENABLE_SSS

// �\�w�F�\�ʂ̐F
const float3 TopCol = float3(1.0,1.0,1.0);	// �F
const float TopScale = 2.0;					// �����Ƃ̊p�x���ɔ�������x�����B
const float TopBias = 0.01;					// ���ʂłǂ̒��x�e����^���邩
const float TopIntensity = 0.0;				// �S�̉e���x
// �[�w�F�����̐F
const float3 BottomCol = float3(1.0, 1.0, 1.0);	// �F
const float BottomScale = 0.4;			// �����Ƃ̊p�x���ɔ�������x�����B
const float BottomBias = 0.2;			// ���ʂłǂ̒��x�e����^���邩
const float BottomIntensity = 0.0;			// �S�̉e���x

// #include "PolishMain_common.fxsub"


////////////////////////////////////////////////////////////////////////////////////////////////
//#include "../ikPolishShader.fxsub"
// �R���g���[����
#define CONTROLLER_NAME		"ikPolishController.pmx"
float DefaultLightScale = 1.0;		// ���ڌ�(=���C�g�̋���)�̃f�t�H���g�l
inline float CalcLightValue(float plusValue, float minusValue, float defaultValue)
{
	float v = plusValue - minusValue + 1.0;
	return ((v <= 1.0) ? v : ((v - 1.0) * 4.0 + 1.0)) * defaultValue;
}
//-------------------------


bool Exist_Polish : CONTROLOBJECT < string name = "ikPolishShader.x"; >;

// �A���r�G���g�}�b�v
shared texture2D PPPReflectionMap : RENDERCOLORTARGET;
sampler ReflectionMapSamp = sampler_state {
	texture = <PPPReflectionMap>;
	Filter = NONE;	AddressU  = CLAMP;	AddressV = CLAMP;
};

// �ގ��}�b�v
shared texture PPPMaterialMapRT: RENDERCOLORTARGET;
sampler MaterialMap = sampler_state {
	texture = <PPPMaterialMapRT>;
	Filter = NONE;	AddressU  = CLAMP;	AddressV = CLAMP;

};

// �@���}�b�v
shared texture PPPNormalMapRT: RENDERCOLORTARGET;
sampler NormalMap = sampler_state {
	texture = <PPPNormalMapRT>;
	Filter = NONE;	AddressU  = CLAMP;	AddressV = CLAMP;
};


/////////////////////////////////////////////////////////////////////////////////////////

float mDirectLightP : CONTROLOBJECT < string name = CONTROLLER_NAME; string item = "���ڌ�+"; >;
float mDirectLightM : CONTROLOBJECT < string name = CONTROLLER_NAME; string item = "���ڌ�-"; >;
float mTestMode : CONTROLOBJECT < string name = CONTROLLER_NAME; string item = "�e�X�g���[�h"; >;

// ���@�ϊ��s��
float4x4 WorldViewProjMatrix	: WORLDVIEWPROJECTION;
float4x4 WorldViewMatrix		: WORLDVIEW;
float4x4 WorldMatrix			: WORLD;
float4x4 ViewMatrix				: VIEW;
float4x4 LightWorldViewProjMatrix	: WORLDVIEWPROJECTION < string Object = "Light"; >;
float3	LightDirection	: DIRECTION < string Object = "Light"; >;
float3	CameraPosition	: POSITION  < string Object = "Camera"; >;

// ���C�g�F
float3	LightDiffuse		: DIFFUSE   < string Object = "Light"; >;
float3	LightSpecular	 	: SPECULAR  < string Object = "Light"; >;

// �}�e���A���F
float4	MaterialDiffuse		: DIFFUSE  < string Object = "Geometry"; >;
float3	MaterialAmbientOrig	: AMBIENT  < string Object = "Geometry"; >;
float3	MaterialEmissiveOrig	: EMISSIVE < string Object = "Geometry"; >;
float3	MaterialSpecular	: SPECULAR < string Object = "Geometry"; >;
float3	MaterialToon		: TOONCOLOR;

// �A�N�Z�T���̃X�y�L������1/10����Ă���̂ł����␳����
#define SpecularColor	Degamma(MaterialSpecular * (LightDiffuse.r * 9 + 1))
/*
// NCHL�̐ݒ�
#define SpecularColor	saturate(MaterialSpecular.g * 2)
*/

#if defined(IGNORE_EMISSIVE)
static float3	MaterialAmbient = MaterialAmbientOrig;
static float3	MaterialEmissive = 0;
#elif defined(EMMISIVE_AS_AMBIENT)
static float3	MaterialAmbient = saturate(MaterialAmbientOrig + MaterialEmissiveOrig);
static float3	MaterialEmissive = 0;
#else
static float3	MaterialAmbient = MaterialAmbientOrig;
static float3	MaterialEmissive = MaterialEmissiveOrig;
#endif

// ���C�g�̋��x
static float LightScale = CalcLightValue(mDirectLightP, mDirectLightM, DefaultLightScale);
static float3 LightColor = LightSpecular * LightScale;

// �ގ����[�t�Ή�
float4	TextureAddValue   : ADDINGTEXTURE;
float4	TextureMulValue   : MULTIPLYINGTEXTURE;
float4	SphereAddValue    : ADDINGSPHERETEXTURE;
float4	SphereMulValue    : MULTIPLYINGSPHERETEXTURE;

float2 ViewportSize : VIEWPORTPIXELSIZE;
static float2 ViewportOffset = (float2(0.5,0.5)/ViewportSize);

bool use_texture;
bool use_spheremap;
bool use_toon;

bool	 parthf;   // �p�[�X�y�N�e�B�u�t���O
bool	 transp;   // �������t���O
bool	 spadd;	// �X�t�B�A�}�b�v���Z�����t���O
#define SKII1	1500
#define SKII2	8000
#define Toon	 3

// MMD�{����sampler���㏑�����Ȃ����߂̋L�q�ł��B�폜�s�B
sampler MMDSamp0 : register(s0);
sampler MMDSamp1 : register(s1);
sampler MMDSamp2 : register(s2);

// �I�u�W�F�N�g�̃e�N�X�`��
texture ObjectTexture: MATERIALTEXTURE;
sampler ObjTexSampler = sampler_state {
	texture = <ObjectTexture>;
	MINFILTER = LINEAR;
	MAGFILTER = LINEAR;
	ADDRESSU  = WRAP;
	ADDRESSV  = WRAP;
};

// �X�t�B�A�}�b�v�̃e�N�X�`��
texture ObjectSphereMap: MATERIALSPHEREMAP;
sampler ObjSphereSampler = sampler_state {
	texture = <ObjectSphereMap>;
	MINFILTER = LINEAR;
	MAGFILTER = LINEAR;
	ADDRESSU  = WRAP;
	ADDRESSV  = WRAP;
};

/*
//�g�D�[���}�b�v�̃e�N�X�`��
texture ObjectToonTexture: MATERIALTOONTEXTURE;
sampler ObjToonSampler = sampler_state {
	texture = <ObjectToonTexture>;
	MINFILTER = LINEAR;
	MAGFILTER = LINEAR;
	MIPFILTER = NONE;
	ADDRESSU  = CLAMP;
	ADDRESSV  = CLAMP;
};
*/

////////////////////////////////////////////////////////////////////////////////////////////////
//

#define	PI	(3.14159265359)

// �K���}�␳
const float gamma = 2.2;
const float epsilon = 1.0e-6;
inline float3 Degamma(float3 col) { return pow(max(col,epsilon), gamma); }
inline float3 Gamma(float3 col) { return pow(max(col,epsilon), 1.0/gamma); }
inline float4 Degamma4(float4 col) { return float4(Degamma(col.rgb), col.a); }
inline float4 Gamma4(float4 col) { return float4(Gamma(col.rgb), col.a); }
inline float rgb2gray(float3 rgb)
{
	return dot(float3(0.299, 0.587, 0.114), max(rgb,0));
}

float3 CalcNormalizedToon()
{
	float3 result = 0;
	if (use_toon)
	{
		float3 linearColor = Degamma(MaterialToon);
		float g = rgb2gray(linearColor) * 0.75;
			// �O���[�X�P�[�������ۂ��Â������̂́A�萔Toon�ɂ�閾�邳�̒�グ�ɑ�������B
		result = (g - linearColor) * ToonColor_Scale / (g - g*g + 1e-4);
	}
	return result;
}

static float3 NormalizedToon = CalcNormalizedToon();

inline float3 CalcToonColor(float3 c)
{
	float3 c0 = saturate(c);
	return saturate(NormalizedToon * (c0 * c0 - c0) + c);
}

static float3 MaterialBaseColor = Degamma((!use_toon) ? MaterialDiffuse.rgb : MaterialAmbient);

inline float CalcDiffuse(float3 L, float3 N, float3 V, float smoothness, float3 f0)
{
	float roughness = (1 - smoothness);
	float sigma2 = roughness * roughness;

	// A tiny improvement of Oren-Nayar reflectance model
	float NL = saturate(dot(N ,L));
	float NV = abs(dot(N, V)+1e-5);
	float LV = saturate(dot(L, V));
	float s = LV - NL * NV;
	float st = (s <= 0.0) ? s : (s / (max(NL,NV)+1e-6));
//	float A = 1.0 / ((PI * 0.5 - 2.0/3.0) * sigma2 + PI);
	float A = 1 / ((0.5 - 2.0/3.0/PI) * sigma2 + 1);  // MEMO: ���K������߂��B
	float B = sigma2 * A;
	float result = NL * (A + B * st);

	return saturate(result);
}


// �����̏ꍇ�AF0��rgb���ɈقȂ�l������
inline float3 CalcFresnel(float NV, float3 F0)
{
	// Schlick�̋ߎ���
//	return F0 + (1.0 - F0) * pow(1 - NV, 5);
	float fc = pow(max(1 - NV, 1e-5), 5);
	return (1.0 - F0) * fc + F0;
}

//�X�y�L�����̌v�Z
float3 CalcSpecular(float3 L, float3 N, float3 V, float smoothness, float3 f0)
{
	float3 H = normalize(L + V);

	float a = max(1 - smoothness, 1e-3);
	a *= a;

	float NH = saturate(dot(N, H));
	float NL = saturate(dot(N, L));
	float LH = saturate(dot(L, H));

	float CosSq = (NH * NH) * (a - 1) + 1;
	float D = a / (CosSq * CosSq); // MEMO: ���K������1.0/PI������Ă���B
	float3 F = CalcFresnel(LH, f0);

	float k2 = a * a * 0.25;	// = (a * 0.5)^2
	float vis = (1.0/4.0) / (LH * LH * (1 - k2) + k2);
	return saturate(NL * D * F * vis);
}

inline float3 CalcReflectance(float smoothness, float3 N, float3 V, float3 f0)
{
	float NV = abs(dot(N,V));
	float3 f = CalcFresnel(NV, f0);
	float roughness = max(1.0 - smoothness, 1.0e-4);
	float g = 1.0 / pow(2, roughness * 4.0); // ���t�ȂقǈÂ��Ȃ�
	return saturate(f) * g;
}



////////////////////////////////////////////////////////////////////////////////////////////////
// �֊s�`��
technique EdgeTec < string MMDPass = "edge"; > {}


///////////////////////////////////////////////////////////////////////////////////////////////
// �e�i��Z���t�V���h�E�j�`��
technique ShadowTec < string MMDPass = "shadow"; > {}


///////////////////////////////////////////////////////////////////////////////////////////////
// �Z���t�V���h�E�pZ�l�v���b�g

struct VS_ZValuePlot_OUTPUT {
	float4 Pos : POSITION;				// �ˉe�ϊ����W
	float4 ShadowMapTex : TEXCOORD0;	// Z�o�b�t�@�e�N�X�`��
};

VS_ZValuePlot_OUTPUT ZValuePlot_VS( float4 Pos : POSITION, float2 Tex : TEXCOORD0 )
{
	VS_ZValuePlot_OUTPUT Out = (VS_ZValuePlot_OUTPUT)0;
	Out.Pos = mul( Pos, LightWorldViewProjMatrix );
	Out.ShadowMapTex = Out.Pos;
	return Out;
}

// �s�N�Z���V�F�[�_
float4 ZValuePlot_PS( float4 ShadowMapTex : TEXCOORD0, float2 Tex : TEXCOORD1 ) : COLOR
{
	return float4(ShadowMapTex.z/ShadowMapTex.w,0,0,1);
}

technique ZplotTec < string MMDPass = "zplot"; > {
	pass ZValuePlot {
		AlphaBlendEnable = FALSE;
		VertexShader = compile vs_2_0 ZValuePlot_VS();
		PixelShader  = compile ps_2_0 ZValuePlot_PS();
	}
}


///////////////////////////////////////////////////////////////////////////////////////////////
// �I�u�W�F�N�g�`��i�Z���t�V���h�EON�j

// �V���h�E�o�b�t�@�̃T���v���B"register(s0)"�Ȃ̂�MMD��s0���g���Ă��邩��
sampler DefSampler : register(s0);

struct BufferShadow_OUTPUT {
	float4 Pos		: POSITION;	// �ˉe�ϊ����W
	float4 ZCalcTex	: TEXCOORD0;	// Z�l
	float2 Tex		: TEXCOORD1;	// �e�N�X�`��
	float3 Normal	: TEXCOORD2;	// �@��
	float3 Eye		: TEXCOORD3;	// �J�����Ƃ̑��Έʒu
	float2 SpTex	: TEXCOORD4;	// �X�t�B�A�}�b�v�e�N�X�`�����W
	float4 ScreenTex	: TEXCOORD5;   // �X�N���[�����W
};

// ���_�V�F�[�_
BufferShadow_OUTPUT DrawObject_VS(float4 Pos : POSITION, float3 Normal : NORMAL, float2 Tex : TEXCOORD0, uniform bool useSelfShadow)
{
	BufferShadow_OUTPUT Out = (BufferShadow_OUTPUT)0;

	// �J�������_�̃��[���h�r���[�ˉe�ϊ�
	Out.Pos = mul( Pos, WorldViewProjMatrix );
	float4 WPos = mul( Pos, WorldMatrix );

	// �J�����Ƃ̑��Έʒu
	Out.Eye = CameraPosition - WPos.xyz;
	// ���_�@��
	Out.Normal = normalize( mul( Normal, (float3x3)WorldMatrix ) );

	if (useSelfShadow)
	{
		// ���C�g���_�ɂ�郏�[���h�r���[�ˉe�ϊ�
		Out.ZCalcTex = mul( Pos, LightWorldViewProjMatrix );
	}

	Out.ScreenTex = Out.Pos;

	// �e�N�X�`�����W
	Out.Tex = Tex;

	#if !defined(IGNORE_SPHERE)
	if ( use_spheremap ) {
		// �X�t�B�A�}�b�v�e�N�X�`�����W
		float2 NormalWV = mul( Normal, (float3x3)WorldViewMatrix ).xy;
		Out.SpTex.x = NormalWV.x * 0.5f + 0.5f;
		Out.SpTex.y = NormalWV.y * -0.5f + 0.5f;
	}
	#endif

	return Out;
}


inline float CalcShadow(BufferShadow_OUTPUT IN, float shadowVal)
{
#if defined(ADD_DEFAULT_SHADOW)
	float shadow = 1;

	// �e�N�X�`�����W�ɕϊ�
	IN.ZCalcTex /= IN.ZCalcTex.w;
	float2 TransTexCoord;
	TransTexCoord.x = (1.0f + IN.ZCalcTex.x)*0.5f;
	TransTexCoord.y = (1.0f - IN.ZCalcTex.y)*0.5f;
	if( any( saturate(TransTexCoord) != TransTexCoord ) ) {
		; // �V���h�E�o�b�t�@�O
	} else {
		float a = (parthf) ? SKII2*TransTexCoord.y : SKII1;
		float d = IN.ZCalcTex.z;
		float z = tex2D(DefSampler,TransTexCoord).r;
		shadow = 1 - saturate(max(d - z , 0.0f)*a-0.3f);
	}

	return min(shadow, shadowVal);
#else
	return shadowVal;
#endif
}

inline float4 GetTextureColor(float2 uv)
{
	float4 TexColor = tex2D( ObjTexSampler, uv);
	TexColor.rgb = lerp(1, TexColor * TextureMulValue + TextureAddValue, TextureMulValue.a + TextureAddValue.a).rgb;
	return TexColor;
}

inline float4 GetSphereColor(float2 uv)
{
	float4 TexColor = tex2D(ObjSphereSampler, uv);
	TexColor.rgb = lerp(spadd?0:1, TexColor * SphereMulValue + SphereAddValue, SphereMulValue.a + SphereAddValue.a).rgb;
	return TexColor;
}



// �s�N�Z���V�F�[�_
float4 DrawObject_PS(BufferShadow_OUTPUT IN, uniform bool useSelfShadow) : COLOR
{
	float3 L = -LightDirection;
	float3 V = normalize(IN.Eye);
	float3 N = normalize(IN.Normal);

	float2 texCoord = IN.ScreenTex.xy / IN.ScreenTex.w;;
	texCoord.x = (1.0f + texCoord.x) * 0.5f;
	texCoord.y = (1.0f - texCoord.y) * 0.5f;
	texCoord += ViewportOffset;

	float4 mat = float4(0, 0.5, 1.0, 0.5);
	if (Exist_Polish)
	{
		#if !defined(DISABLE_NORMALMAP)
		// MEMO: ���݂̐[�x�ƃf�v�X���Ⴂ�߂�����A���̖@�����g��?
		// ���̏ꍇ�A�A�e�v�Z�����͂���[�x�ɉ����ĕ�Ԃ���K�v������B
		float4 nd = tex2D(NormalMap, texCoord);
		N = normalize(nd.xyz);
		// float depth = nd.w; // = mul(WPos, matWV).z
		#endif
		mat = tex2D(MaterialMap, texCoord);
	}

	float metalness = mat.x;
	float smoothness = mat.y;
	float intensity = mat.z;
	float sss = mat.w * (1 - metalness);

	// �f�ގ��̂̐F
	float4 albedo = float4(MaterialBaseColor,1);
	if ( use_texture ) albedo *= Degamma4(GetTextureColor(IN.Tex));

	float3 SpSpecular = 0;
	#if !defined(IGNORE_SPHERE)
	if ( use_spheremap ) {
		float4 TexColor = GetSphereColor(IN.SpTex);
		if(spadd) {
			SpSpecular = TexColor.rgb * LightSpecular * SphereScale;
		} else {
			albedo.rgb *= (Degamma(TexColor.rgb) * SphereScale + (1.0 - SphereScale));
		}
	}
	#endif

	// ���C�g�̌v�Z
	float3 f0 = lerp(0.05, (albedo.rgb * 0.8 + 0.2) * SpecularColor, metalness);
	float3 specular = CalcSpecular(L, N, V, smoothness, f0);
	specular += CalcSpecular(L, N, V, SecondSpecularSmooth, f0) * SecondSpecularIntensity;
	specular *= intensity;
	float reflectance = rgb2gray(CalcReflectance(smoothness, N, V, f0));

	float4 ambient = Exist_Polish ? tex2D(ReflectionMapSamp, texCoord) : float4(0,0,0,1);
	float diffuse = CalcDiffuse(L, N, V, smoothness, f0);
	float shadow = (useSelfShadow) ? CalcShadow(IN, ambient.w) : 1;
//	float directLight = min(diffuse, shadow);
	float directLight = diffuse * shadow;
	float3 directLight3 = directLight * LightColor;
	float3 light = Exist_Polish ? ambient.rgb : directLight3;

	#if defined(ScatterColor)
	// ���̟��݂��A���C�g�F�̕ω�
	float3 dif = light - directLight3;
	light = directLight3 + dif * lerp(1, ScatterColor, sss * saturate(1 - rgb2gray(dif)));
	#endif

	#if defined(ENABLE_BACKLIGHT)
	// �t���ɂ�閾�邳�̒ǉ�
	float diffuseBack = CalcDiffuse(L, -N, V, smoothness, f0);
	diffuseBack = max(diffuseBack - diffuse, 0) * shadow;
	float3 diffuseDiff = albedo.rgb * albedo.rgb * diffuseBack;
	light += diffuseDiff * LightColor;
	#endif

	#if !defined(DISABLE_COLOR)
	albedo = saturate(albedo);
	if (mTestMode > 0.5) albedo.rgb = 1;
	#else
	albedo.rgb = 1;
	#endif

	#if defined(ENABLE_SSS)
	// �\�ʐF�Ɠ����F�����߂ɂ���Č�����B
	float NV = dot(N, normalize(V));
	float plusNV = saturate(NV);
	float top = pow(1-plusNV, TopScale) * (1.0 - TopBias) + TopBias;
	float bottom = pow(1-plusNV, BottomScale) * (1.0 - BottomBias) + BottomBias;
	albedo.rgb = lerp(albedo.rgb, BottomCol, bottom * BottomIntensity);
	albedo.rgb = lerp(albedo.rgb, TopCol, top * TopIntensity);
	#endif

	light = saturate(CalcToonColor(light) + MaterialEmissive);

	float4 result = float4(light, MaterialDiffuse.a) * albedo;
	result.rgb *= saturate(1 - reflectance);	// �f�肱�ޕ��A�Â�����B

	specular = specular * LightSpecular * shadow + SpSpecular;

	#if defined(ENABLE_SPECULAR_ALPHA)
	// �X�y�L�����ɉ����ĕs�����x���グ��B
	float alpha = result.a;
	float alpha2 = saturate(1 - (1.0 - alpha) * (1.0 - rgb2gray(specular)));
	result.rgb = (result.rgb * alpha + specular) / alpha2;
	result.a = alpha2 * saturate(alpha * (1.0 / (5.0/255.0)));
	#else
	result.rgb += specular;
	#endif

	#if defined(DISABLE_HDR)
	result = saturate(result);
	#endif

	return Gamma4(result);
}


#define OBJECT_TEC(name, mmdpass, selfshadow) \
	technique name < string MMDPass = mmdpass; bool UseSelfShadow = selfshadow;\
	> { \
		pass DrawObject { \
			VertexShader = compile vs_3_0 DrawObject_VS(selfshadow); \
			PixelShader  = compile ps_3_0 DrawObject_PS(selfshadow); \
		} \
	}


OBJECT_TEC(MainTec0, "object", false)
OBJECT_TEC(MainTecBS0, "object_ss", true)

///////////////////////////////////////////////////////////////////////////////////////////////

