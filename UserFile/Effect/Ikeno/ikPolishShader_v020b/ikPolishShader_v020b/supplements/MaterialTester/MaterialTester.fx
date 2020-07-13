//-----------------------------------------------------------------------------
// MaterialTester�p�ɃJ�X�^�}�C�Y����PolsihMain.fx
//-----------------------------------------------------------------------------

#define TEST_CONTROLLER_NAME	"MaterialTester.pmx"


//----------------------------------------------------------
// SSS�p�̐ݒ�

// �x���x�b�g���ʂ�L���ɂ��邩?
// #define ENABLE_VELVET

const float VelvetExponent = 2.0;			// ���̑傫��
const float VelvetBaseReflection = 0.01;	// ���ʂł̖��邳 
#define VELVET_COLOR		float3(0.20, 0.20, 0.20)	// ���ʂ̐F
#define VELVET_RIM_COLOR	float3(1.00, 1.00, 1.00)	// ���̐F

//----------------------------------------------------------
// �X�y�L�����֘A

// �N���A�R�[�g����
// ���f���̏�ɓ����ȃ��C���[��ǉ�����B
#define ENABLE_CLEARCOAT		1			// 0:�����A1:�L��
const float USE_POLYGON_NORMAL = 1.0;		// �N���A�R�[�g�w�̖@���}�b�v�𖳎�����?
const float ClearcoatSmoothness =  0.95;		// 1�ɋ߂Â��قǃX�y�L�������s���Ȃ�B(0�`1)
//const float ClearcoatIntensity = 0.5;		// �X�y�L�����̋��x�B0�ŃI�t�B(0�`1.0)
float ClearcoatIntensity : CONTROLOBJECT < string name = TEST_CONTROLLER_NAME; string item = "Clearcoat"; >;
const float3 ClearcoatF0 = float3(0.05,0.05,0.05);	// �X�y�L�����̔��˓x
const float4 ClearcoatColor = float4(1,1,1, 0.0);	// �N���A�R�[�g�̐F

// �X�t�B�A�}�b�v�����B
#define IGNORE_SPHERE

// �X�t�B�A�}�b�v�̋��x
float3 SphereScale = float3(1.0, 1.0, 1.0) * 0.1;

// �X�y�L�����ɉ����ĕs�����x���グ��B
// �L���ɂ���ƁA�K���X�Ȃǂɉf��n�C���C�g����苭���o��B
// ���ȂǃA���t�@�������Ă���ꍇ�̓G�b�W�ɋ����n�C���C�g���o�邱�Ƃ�����B
// #define ENABLE_SPECULAR_ALPHA


//----------------------------------------------------------
// ���̑�

#define ToonColor_Scale			0.5			// �g�D�[���F����������x�����B(0.0�`1.0)



//-----------------------------------------------------------------------------
//

#include "../../ikPolishShader.fxsub"

#include "../../Sources/constants.fxsub"
#include "../../Sources/structs.fxsub"
#include "../../Sources/mmdutil.fxsub"
#include "../../Sources/colorutil.fxsub"
#include "../../Sources/lighting.fxsub"

bool ExistPolish : CONTROLOBJECT < string name = "ikPolishShader.x"; >;


// �g�U����
shared texture2D PPPDiffuseMap : RENDERCOLORTARGET;
sampler DiffuseMapSamp = sampler_state {
	texture = <PPPDiffuseMap>;
	MinFilter = LINEAR;	MagFilter = LINEAR;	MipFilter = NONE;
	AddressU  = CLAMP;	AddressV = CLAMP;
};

// ���ʔ���
shared texture2D PPPReflectionMap : RENDERCOLORTARGET;
sampler ReflectionMapSamp = sampler_state {
	texture = <PPPReflectionMap>;
	MinFilter = LINEAR;	MagFilter = LINEAR;	MipFilter = NONE;
	AddressU  = CLAMP;	AddressV = CLAMP;
};

// �o�b�N���C�g�A�x���x�b�g�A�N���A�R�[�g�Ŗ@�����g���B����ȊO�͕s�v
#if !defined(DISABLE_NORMALMAP)
// �@���}�b�v
shared texture PPPNormalMapRT: RENDERCOLORTARGET;
sampler NormalMap = sampler_state {
	texture = <PPPNormalMapRT>;
	MinFilter = POINT;	MagFilter = POINT;	MipFilter = NONE;
	AddressU  = CLAMP;	AddressV = CLAMP;
};
#endif


//-----------------------------------------------------------------------------

float mDirectLightP : CONTROLOBJECT < string name = CONTROLLER_NAME; string item = "���ڌ�+"; >;
float mDirectLightM : CONTROLOBJECT < string name = CONTROLLER_NAME; string item = "���ڌ�-"; >;

bool bLinearBegin : CONTROLOBJECT < string name = "ikLinearBegin.x"; >;
bool bLinearEnd : CONTROLOBJECT < string name = "ikLinearEnd.x"; >;
static bool bOutputLinear = (bLinearEnd && !bLinearBegin);

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
float3	LightSpecular		: SPECULAR  < string Object = "Light"; >;

// �}�e���A���F
float4	MaterialDiffuse		: DIFFUSE  < string Object = "Geometry"; >;
float3	MaterialAmbient		: AMBIENT  < string Object = "Geometry"; >;
float3	MaterialEmissive	: EMISSIVE < string Object = "Geometry"; >;
float3	MaterialSpecular	: SPECULAR < string Object = "Geometry"; >;
float3	MaterialToon		: TOONCOLOR;

// �A�N�Z�T���̃X�y�L������1/10����Ă���̂ł����␳����
//#define SpecularColor	Degamma(MaterialSpecular * (LightDiffuse.r * 9 + 1))

static float3	BaseAmbient = MaterialAmbient;
static float3	BaseEmissive = 0;

// ���C�g�̋��x
static float3 LightColor = LightSpecular * CalcLightValue(mDirectLightP, mDirectLightM, DefaultLightScale);

float2 ViewportSize : VIEWPORTPIXELSIZE;
static float2 ViewportOffset = (float2(0.5,0.5)/ViewportSize);

bool use_texture;
bool use_subtexture;	// �T�u�e�N�X�`���t���O
bool use_spheremap;
bool use_toon;

bool	transp;   // �������t���O
#define Toon	3

float SmoothnessToRoughness(float smoothness)
{
	return (1.0 - smoothness * smoothness);
}

#if !defined(ENABLE_CLEARCOAT)
#define	ENABLE_CLEARCOAT	0
#else
#if ENABLE_CLEARCOAT > 0
static float ClearcoatRoughness = SmoothnessToRoughness(ClearcoatSmoothness);

#include "../../Sources/octahedron.fxsub"

shared texture PPPEnvMap2: RENDERCOLORTARGET;
sampler EnvMapSamp0 = sampler_state {
	texture = <PPPEnvMap2>;
	MinFilter = LINEAR;	MagFilter = LINEAR;	MipFilter = LINEAR;
	AddressU  = WRAP;	AddressV = WRAP;
};

texture2D EnvironmentBRDFTex <
	string ResourceName = "../../Sources/Assets/EnvironmentBRDF.dds";
	// string Format = "A16B16G16R16F";
	int MipLevels = 1;
>;
sampler EnvironmentBRDF = sampler_state {
	texture = <EnvironmentBRDFTex>;
	MinFilter = LINEAR;	MagFilter = LINEAR;	MipFilter = NONE;
	AddressU  = CLAMP;	AddressV  = CLAMP;
};

static float MAX_MIP_LEVEL = log2(ENV_WIDTH) - 1.0;

float4 GetEnvColor(float3 vec, float roughness)
{
	float s = 1 - roughness;
	roughness = (1 - s * s);
	float lod = roughness * MAX_MIP_LEVEL;
	float2 uv = EncodeOctahedron(vec);
	return tex2Dlod(EnvMapSamp0, float4(uv,0,lod));
}

float3 ApplyClearCoat(float3 N, float3 NPoly, float3 L, float3 V, 
	float shadow, float3 bodyColor, inout float3 specular)
{
	float3 clearcoatN = normalize(lerp(N, NPoly, USE_POLYGON_NORMAL));
	float3 clearcoatR = reflect(-V, clearcoatN);
	float clearcoatNV = abs(dot(clearcoatN, V));

	float3 brdf = tex2D(EnvironmentBRDF, float2(ClearcoatRoughness, clearcoatNV)).xyz;
	float3 reflectance = (ClearcoatF0 * brdf.x + brdf.y);

	float3 diffuse = CalcDiffuse(L, clearcoatN, V) * shadow * LightColor;
	diffuse += GetEnvColor(clearcoatN, 1.0) * brdf.z;

	float coatThickness = (1 - clearcoatNV) * (1 - ClearcoatColor.a) + ClearcoatColor.a;
	coatThickness *= ClearcoatColor.a;
	bodyColor = lerp(bodyColor, ClearcoatColor.rgb * diffuse, coatThickness);
	specular *= lerp(1, ClearcoatColor.rgb, coatThickness);

	float3 ccSpecular;
	ccSpecular = CalcSpecular(L, clearcoatN, V, ClearcoatRoughness, ClearcoatF0);
	ccSpecular *= LightColor * shadow;
	ccSpecular += GetEnvColor(clearcoatR, ClearcoatRoughness) * reflectance;
	specular = lerp(specular, ccSpecular, ClearcoatIntensity);

	return bodyColor;
}
#endif
#endif


//-----------------------------------------------------------------------------
//

float3 CalcNormalizedToon()
{
	float3 result = 0;
	if (use_toon)
	{
		float3 linearColor = Degamma(MaterialToon);
		float g = Luminance(linearColor) * 0.75;
			// �O���[�X�P�[�������ۂ��Â������̂́A�萔Toon�ɂ�閾�邳�̒�グ�ɑ�������B
		result = (g - linearColor) * ToonColor_Scale / (g - g*g + 1e-4);
	}

	return result;
}

static float3 NormalizedToon = CalcNormalizedToon();

float3 CalcToonColor(float3 c)
{
	float3 c0 = saturate(c);
	return (NormalizedToon * (c0 * c0 - c0) + c);
}

static float3 MaterialBaseColor = Degamma((!use_toon) ? MaterialDiffuse.rgb : BaseAmbient);


//-----------------------------------------------------------------------------
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

float4 ZValuePlot_PS( float4 ShadowMapTex : TEXCOORD0, float2 Tex : TEXCOORD1 ) : COLOR
{
	return float4(ShadowMapTex.z/ShadowMapTex.w,0,0,1);
}

technique ZplotTec < string MMDPass = "zplot"; > {
	pass ZValuePlot {
		AlphaBlendEnable = FALSE;
		VertexShader = compile vs_3_0 ZValuePlot_VS();
		PixelShader  = compile ps_3_0 ZValuePlot_PS();
	}
}


//-----------------------------------------------------------------------------
// �I�u�W�F�N�g�`��

struct BufferShadow_OUTPUT {
	float4 Pos		: POSITION;		// �ˉe�ϊ����W

	float4 Tex		: TEXCOORD1;	// �e�N�X�`��
	float3 Normal	: TEXCOORD2;	// �@��
	float3 Eye		: TEXCOORD3;	// �J�����Ƃ̑��Έʒu
	float4 PPos		: TEXCOORD4;	// �X�N���[�����W
	#if !defined(IGNORE_SPHERE)
	float2 SpTex	: TEXCOORD5;	// �X�t�B�A�}�b�v�e�N�X�`�����W
	#endif
};

BufferShadow_OUTPUT DrawObject_VS(
	VS_AL_INPUT IN, uniform bool useSelfShadow)
{
	BufferShadow_OUTPUT Out = (BufferShadow_OUTPUT)0;

	float4 Pos = IN.Pos;
	float3 Normal = IN.Normal.xyz;

	Out.Pos = mul( Pos, WorldViewProjMatrix );

	float4 WPos = mul( Pos, WorldMatrix );
	Out.Eye = CameraPosition - WPos.xyz;

	Out.Normal = normalize( mul( Normal, (float3x3)WorldMatrix ) );

	Out.PPos = Out.Pos;
	Out.Tex.xy = IN.Tex;

	#if !defined(IGNORE_SPHERE)
	if ( use_spheremap && use_subtexture) Out.SpTex = IN.AddUV1.xy;
	#endif

	return Out;
}



float4 DrawObject_PS(BufferShadow_OUTPUT IN, uniform bool useSelfShadow) : COLOR
{
	float3 L = -LightDirection;
	float3 V = normalize(IN.Eye);
	float3 N = normalize(IN.Normal);
	float3 NPoly = N;

	float2 texCoord = IN.PPos.xy / IN.PPos.w * float2(0.5, -0.5) + 0.5;
	texCoord += ViewportOffset;

	// �f�ގ��̂̐F
	float4 albedo = float4(MaterialBaseColor,1);

		#if !defined(DISABLE_NORMALMAP)
		// MEMO: ���݂̐[�x�ƃf�v�X���Ⴂ�߂�����A���̖@�����g��?
		// ���̏ꍇ�A�A�e�v�Z�����͂���[�x�ɉ����ĕ�Ԃ���K�v������B
		float4 nd = tex2D(NormalMap, texCoord);
		N = normalize(nd.xyz);
		#endif

	if ( use_texture )
	{
		albedo *= Degamma(GetTextureColor(IN.Tex.xy));
	}

	float3 subSpecular = 0;
	#if !defined(IGNORE_SPHERE)
	if ( use_spheremap ) {
		float2 SpTex = mul( N, (float3x3)ViewMatrix ).xy * float2(0.5, -0.5) + 0.5;
		float4 TexColor = GetSphereColor(use_subtexture ? IN.SpTex : SpTex);
		if(spadd) {
			subSpecular = TexColor.rgb * LightSpecular * SphereScale;
		} else {
			albedo.rgb *= (Degamma(TexColor.rgb) * SphereScale + (1.0 - SphereScale));
		}
	}
	#endif

	#if defined(ENABLE_VELVET)
	float velvetLevel = pow(1.0 - abs(dot(N,V)), VelvetExponent);
	velvetLevel = saturate(velvetLevel * (1.0 - VelvetBaseReflection) + VelvetBaseReflection);
	albedo.rgb = saturate(albedo.rgb * lerp(VELVET_COLOR, VELVET_RIM_COLOR, velvetLevel));
		#endif

	// ���C�g�̌v�Z
	float4 diffusemap = tex2D(DiffuseMapSamp, texCoord);
	float4 specmap = tex2D(ReflectionMapSamp, texCoord);
	float shadow = (useSelfShadow) ? diffusemap.w : 1;

	// �g�U����(���ڌ�+����)
	float3 light = diffusemap.rgb;

	// ���ʔ���
	float3 specular = specmap.rgb + subSpecular;

	// �ŏI�I�ȐF�̌v�Z
	light = CalcToonColor(light);
	if (!ExistPolish) light = 1; // �K��
	float4 result = float4(light, MaterialDiffuse.a) * albedo;

	// �N���A�R�[�g�w
	#if ENABLE_CLEARCOAT > 0
	result.rgb = ApplyClearCoat(N, NPoly, L, V, shadow, result.rgb, specular);
	#endif

	#if defined(ENABLE_SPECULAR_ALPHA)
	// �X�y�L�����ɉ����ĕs�����x���グ��B
	result.rgb = result.rgb * result.a + specular;
	float2 luminnance = max(result.rg, result.ba);
	float alpha = saturate(max(luminnance.x, luminnance.y));
	result.rgb /= max(alpha, 1.0/1024);
	result.a = alpha;
	#else
	result.rgb += specular;
	#endif

	result = bOutputLinear ? result : Gamma(result);

	return result;
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

technique EdgeTec < string MMDPass = "edge"; > {}
technique ShadowTec < string MMDPass = "shadow"; > {}

//-----------------------------------------------------------------------------

