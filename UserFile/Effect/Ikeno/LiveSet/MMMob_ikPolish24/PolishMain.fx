//-----------------------------------------------------------------------------
// �ėp�̃v���Z�b�g�B

//----------------------------------------------------------
// SSS�p�̐ݒ�

// �x���x�b�g���ʂ�L���ɂ��邩?
#define ENABLE_VELVET	0
const float VelvetExponent = 2.0;			// ���̑傫��
const float VelvetBaseReflection = 0.01;	// ���ʂł̖��邳 
#define VELVET_MUL_COLOR		float3(0.50, 0.50, 0.50)	// ���ʂ̐F(��Z)
#define VELVET_MUL_RIM_COLOR	float3(1.00, 1.00, 1.00)	// ���̐F(��Z)
#define VELVET_ADD_COLOR		float3(0.00, 0.00, 0.00)	// ���ʂ̐F(���Z)
#define VELVET_ADD_RIM_COLOR	float3(0.00, 0.00, 0.00)	// ���̐F(���Z)

//----------------------------------------------------------
// �X�y�L�����֘A

// ���̖т̐�p�̃X�y�L������ǉ�����
#define ENABLE_HAIR_SPECULAR	0
// ���̖т̃c��
const float HairSmoothness = 0.5;	// (0�`1)
// ���̖т̃X�y�L�����̋���
const float HairSpecularIntensity = 1.0;	// (0�`1)
// ���̖т̌����̊�ɂȂ�{�[����
// #define HAIR_CENTER_BONE_NAME	"��"


// �X�t�B�A�}�b�v�����B
#define IGNORE_SPHERE	1

// �X�t�B�A�}�b�v�̋��x
float3 SphereScale = float3(1.0, 1.0, 1.0) * 0.1;

// �X�y�L�����ɉ����ĕs�����x���グ��B
// �L���ɂ���ƁA�K���X�Ȃǂɉf��n�C���C�g����苭���o��B
// ���ȂǃA���t�@�������Ă���ꍇ�̓G�b�W�ɋ����n�C���C�g���o�邱�Ƃ�����B
#define ENABLE_SPECULAR_ALPHA	0


//----------------------------------------------------------
// ���̑�

#define ToonColor_Scale			0.5			// �g�D�[���F����������x�����B(0.0�`1.0)

// �A���t�@���J�b�g�A�E�g����
// �t���ςȂǂ̔����e�N�X�`���ŉ��������Ȃ�ꍇ�Ɏg���B
#define Enable_Cutout	0
#define CutoutThreshold	0.5		// ����/�s�����̋��E�̒l


//=============================================================================
// MikuMikuMob�Ή� ��������

// &InsertHeader;  ������MikuMikuMob�ݒ�w�b�_�R�[�h���}������܂�

// MikuMikuMob�Ή� �����܂�
//=============================================================================


//----------------------------------------------------------
// ���ʏ����̓ǂݍ���

//-----------------------------------------------------------------------------
//

#include "ikPolishShader.fxsub"
#include "constants.fxsub"
#include "structs.fxsub"
#include "mmdutil.fxsub"
#include "colorutil.fxsub"
#include "lighting.fxsub"

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
float4x4 matW			: WORLD;
float4x4 matV			: VIEW;
float4x4 matVP			: VIEWPROJECTION;
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
static float3	BaseEmissive = MaterialEmissive;

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

float ConvertToRoughness(float val) { return (1 - val) * (1 - val); }


/*
#if !defined(DISABLE_NORMALMAP)
float4 AdjustTexCoord(float4 nd, inout float2 texCoord)
{
	float4 nd0 = tex2D(NormalMap, texCoord);
	float4 nd1 = tex2D(NormalMap, texCoord + float2(-1, 0) / ViewportSize);
	float4 nd2 = tex2D(NormalMap, texCoord + float2( 1, 0) / ViewportSize);
	float4 nd3 = tex2D(NormalMap, texCoord + float2( 0,-1) / ViewportSize);
	float4 nd4 = tex2D(NormalMap, texCoord + float2( 0, 1) / ViewportSize);

	float d0 = abs(nd0.w - nd.w);
	float d1 = abs(nd1.w - nd.w);
	float d2 = abs(nd2.w - nd.w);
	float d3 = abs(nd3.w - nd.w);
	float d4 = abs(nd4.w - nd.w);

	// �G�b�W�ł͂Ȃ�
	if (d0 < 1.0)
	{
		return nd0;
	}

	if (d1 < 1.0) texCoord.x -= 1.0 / ViewportSize.x;
	if (d2 < 1.0) texCoord.x += 1.0 / ViewportSize.x;
	if (d3 < 1.0) texCoord.y -= 1.0 / ViewportSize.y;
	if (d4 < 1.0) texCoord.y += 1.0 / ViewportSize.y;

	return nd;
}
#endif
*/


#if ENABLE_HAIR_SPECULAR > 0
//-----------------------------------------------------------------------------
// ���̖т̃X�y�L����

#if !defined(HAIR_CENTER_BONE_NAME)
#define HAIR_CENTER_BONE_NAME	"��"
#endif
float4x4 mHeadMat : CONTROLOBJECT < string name = "(self)"; string item = HAIR_CENTER_BONE_NAME; >;
float3 mHeadPos : CONTROLOBJECT < string name = "(self)"; string item = HAIR_CENTER_BONE_NAME; >;

float3 ComputeHairTangent(float3 N, float3 V, float3 WPos, float2 UV)
{
	// T�͍��{����ѐ�������w���B
#if 0
	// �^���W�F���g�}�b�v�����Č��߂�
	float3 dp1 = ddx(V);
	float3 dp2 = ddy(V);
	float2 duv1 = ddx(UV);
	float2 duv2 = ddy(UV);
	float3x3 M = float3x3(dp1, dp2, cross(dp1, dp2));
	float2x3 inverseM = float2x3(cross(M[1], M[2]), cross(M[2], M[0]));
	float3 T = normalize(mul(float2(duv1.x, duv2.x), inverseM));
	float3 B = normalize(mul(float2(duv1.y, duv2.y), inverseM));
	float2 t = tex2D(TangentMap, UV).xy;
	T = normalize(T * t.x + B * t.y);
#else
	// ���{�[���̉�����������
	// �����������قǓ��̒��S����̋����ɂ���
	float3 T0 = -mHeadMat[1].xyz;
	float3 T1 = WPos - mHeadPos;
	float l = length(T1);
	T1 /= max(l, 1);
	T0 = normalize(lerp(T0, T1, saturate(l - 5.0) ));
		// 50cm�`60cm�Ɋ|���Đڐ��̌������Ԃ���

	float3 B = normalize(cross(N, T0));
	float3 T = normalize(cross(B, N));
#endif

	return T;
}

// Gaussian distribution
float HairGaussian(float beta, float theta)
{
	#define SQRT_2PI	2.50662827		// sqrt(2.0 * PI) �� 2.5
	float beta2 = 2.0 * beta * beta;
	float theta2 = theta * theta;
//	return exp(-theta2 / beta2) / sqrt(PI * beta2);
	return exp(-theta2 / beta2) / (beta * SQRT_2PI);
}

// Marschner��K���ɉ�����������
float3 SimpleHairSepc(float3 N, float3 T, float3 V, float3 L, float smoothness, float3 attenuation)
{
	float shift = 3.0 * DEG_TO_RAD;	// �L���[�e�B�N���̌X��
	float roughness = lerp(10.0, 5.0, smoothness) * DEG_TO_RAD;	// �\�ʂ̑e���B
	float t = 0.75; // ���ߗ�

	float alphaR = -1.0 * shift;
	float alphaTT = 0.5 * shift;
	float alphaTRT = 2.0 * shift;
	float betaR = 1.0 * roughness;
	float betaTT = 0.5 * roughness;
	float betaTRT = 2.0 * roughness;

	float TL = dot(T, L);
	float thetaI = asin(TL);
	float thetaR = asin(dot(T, V));
	float thetaH = (thetaR + thetaI) * 0.5;
//	float thetaD = (thetaR - thetaI) * 0.5;

	float M_R = HairGaussian(betaR, thetaH - alphaR);
	float M_TT = HairGaussian(betaTT, thetaH - alphaTT);
	float M_TRT = HairGaussian(betaTRT, thetaH - alphaTRT);

	// �K���ȐF�̌����F�o�H�������قǐF����������B
	float l = 1.0 / (abs(TL) + 0.1);
	float3 N_TT = exp(-l * attenuation);
	float3 N_TRT = N_TT * N_TT;

	// �K���Ȕ���/���ߗ��F���̑��a��1�ȉ��ɗ}���邽�߂̏���
	float cosPhi = dot(N,L);
	float T_R = (1.0 - t) * saturate(cosPhi);
	float T_TT = (t * t) * saturate(cosPhi * -0.5 + 0.5);
	float T_TRT = (t * (1.0 - t) * t) * 1.0;

	return (M_R * T_R + M_TT *T_TT * N_TT + M_TRT * T_TRT * N_TRT) * HairSpecularIntensity;
}

float3 CalcHairColor()
{
	// �����F�̃u�[�X�g
	float3 attenuation = saturate(1.0 - Degamma(MaterialToon));
	float g0 = Luminance(attenuation);
	attenuation *= attenuation;
	attenuation *= attenuation;
	float g1 = Luminance(attenuation);
	attenuation = attenuation * g0 / max(g1, 0.01) + 0.01;
	return attenuation;
}

float3 GetHairSepcular(float3 N, float3 V, float3 L, float3 WPos, float2 uv, float3 attenuation)
{
	float3 T = ComputeHairTangent(N, V, WPos, uv);
	float3 hairSpec = SimpleHairSepc(N, T, V, L, HairSmoothness, attenuation);
	hairSpec *= Luminance(LightSpecular);
	return hairSpec;
}
#endif


//-----------------------------------------------------------------------------
//

float3 CalcNormalizedToon()
{
	float3 result = 1;
	if (use_toon)
	{
		float3 linearColor = Degamma(MaterialToon);
		float g = Luminance(linearColor);
		result = lerp(1, linearColor / max(g, 0.01), saturate(ToonColor_Scale));
	}

	return result;
}

float3 CalcToonLight(float3 c, float3 toonColor)
{
	float g = saturate(Luminance(c) * 2.0 - 0.5);
	return c * lerp(toonColor, 1, g);
}

static float3 MaterialBaseColor = Degamma(
	((!use_toon) ? MaterialDiffuse.rgb : BaseAmbient)
	#if IS_LIGHT > 0
		+ MaterialEmissive
	#endif
);


//-----------------------------------------------------------------------------
// �I�u�W�F�N�g�`��

struct BufferShadow_OUTPUT {
	float4 Pos		: POSITION;		// �ˉe�ϊ����W

	float4 Tex		: TEXCOORD0;	// �e�N�X�`��
	float4 Normal	: TEXCOORD1;	// �@��, �[�x
	float3 Eye		: TEXCOORD2;	// �J�����Ƃ̑��Έʒu
	float4 PPos		: TEXCOORD3;	// �X�N���[�����W
	#if IGNORE_SPHERE == 0
	float2 SpTex	: TEXCOORD4;	// �X�t�B�A�}�b�v�e�N�X�`�����W
	#endif
	float4 ToonColor	: TEXCOORD5;

	#if ENABLE_HAIR_SPECULAR > 0
	float4 WPos		: TEXCOORD6;
	float4 HairColor	: TEXCOORD7;
	#endif
};

BufferShadow_OUTPUT DrawObject_VS(
	VS_AL_INPUT IN, int vIndex : _INDEX, uniform bool useSelfShadow)
{
	BufferShadow_OUTPUT Out = (BufferShadow_OUTPUT)0;

	float4 LPos = mul( IN.Pos, matW );
	float3 LNormal = mul( IN.Normal.xyz, (float3x3)matW );
	MOB_TRANSFORM TrOut = MOB_TransformPositionNormal(LPos, LNormal, vIndex);
	float4 WPos = TrOut.Pos;
	float3 WNormal = TrOut.Normal;

	Out.Pos = mul( WPos, matVP );
	Out.Eye = CameraPosition - WPos.xyz;

	Out.Normal.xyz = WNormal;
	Out.Normal.w = mul(WPos, matV).z;

	Out.PPos = Out.Pos;
	Out.Tex.xy = IN.Tex;

	#if IGNORE_SPHERE == 0
	if ( use_spheremap && use_subtexture) Out.SpTex = IN.AddUV1.xy;
	#endif

	Out.ToonColor.rgb = CalcNormalizedToon();

	#if ENABLE_HAIR_SPECULAR > 0
	Out.WPos = WPos;
	Out.HairColor.rgb = CalcHairColor();
	#endif

	return Out;
}



float4 DrawObject_PS(BufferShadow_OUTPUT IN, uniform bool useSelfShadow) : COLOR
{
	float3 L = -LightDirection;
	float3 V = normalize(IN.Eye);
	float3 N = normalize(IN.Normal.xyz);
	float3 NPoly = N;

	float2 texCoord = IN.PPos.xy / IN.PPos.w * float2(0.5, -0.5) + 0.5;
	texCoord += ViewportOffset;

	// �f�ގ��̂̐F
	float4 albedo = float4(MaterialBaseColor,1);

	#if !defined(DISABLE_NORMALMAP)
	// float4 nd = AdjustTexCoord(IN.Normal, texCoord);
	float4 nd = tex2D(NormalMap, texCoord);
	N = normalize(nd.xyz);
	#endif

	if ( use_texture )
	{
		albedo *= Degamma(GetTextureColor(IN.Tex.xy));
	}

	float3 subSpecular = 0;
	#if IGNORE_SPHERE == 0
	if ( use_spheremap ) {
		float2 SpTex = mul( N, (float3x3)matV ).xy * float2(0.5, -0.5) + 0.5;
		float4 TexColor = GetSphereColor(use_subtexture ? IN.SpTex : SpTex);
		if(spadd) {
			subSpecular = TexColor.rgb * LightSpecular * SphereScale;
		} else {
			albedo.rgb *= (Degamma(TexColor.rgb) * SphereScale + (1.0 - SphereScale));
		}
	}
	#endif

	#if defined(ENABLE_VELVET) && ENABLE_VELVET > 0
	float velvetLevel = pow(1.0 - abs(dot(N,V)), VelvetExponent);
	velvetLevel = saturate(velvetLevel * (1.0 - VelvetBaseReflection) + VelvetBaseReflection);
	float3 velvetMulCol = lerp(VELVET_MUL_COLOR, VELVET_MUL_RIM_COLOR, velvetLevel);
	float3 velvetAddCol = lerp(VELVET_ADD_COLOR, VELVET_ADD_RIM_COLOR, velvetLevel);
	albedo.rgb = saturate(albedo.rgb * velvetMulCol + velvetAddCol);
	#endif

	// ���C�g�̌v�Z
	float4 diffusemap = tex2D(DiffuseMapSamp, texCoord);
	float4 specmap = tex2D(ReflectionMapSamp, texCoord);
	float shadow = (useSelfShadow) ? diffusemap.w : 1;

	// �g�U����(���ڌ�+����)
	float3 light = diffusemap.rgb;

	// ���ʔ���
	float3 specular = specmap.rgb + subSpecular;
	// ���̖т̃X�y�L����
	#if ENABLE_HAIR_SPECULAR > 0
	float3 hairSpec = GetHairSepcular(N, V, L, IN.WPos.xyz, texCoord, IN.HairColor.rgb);
	// return float4(hairSpec * saturate(diffusemap.rgb), 1);
	specular += hairSpec * saturate(diffusemap.rgb);
	#endif

	// �ŏI�I�ȐF�̌v�Z
	light = CalcToonLight(light, IN.ToonColor.rgb);
	if (!ExistPolish) light = 1; // �K��
	float4 result = float4(light, MaterialDiffuse.a) * albedo;

	#if Enable_Cutout > 0
	clip(result.a - CutoutThreshold);
	result.a = 1;
	#endif

	// �N���A�R�[�g�w
	// (���Ή�)

	#if ENABLE_SPECULAR_ALPHA > 0
	// �X�y�L�����ɉ����ĕs�����x���グ��B
	result.rgb = result.rgb * result.a + specular;
	float2 luminnance = max(result.rg, result.ba);
	float alpha = saturate(max(luminnance.x, luminnance.y));
	result.rgb /= max(alpha, 1.0/1024);
	result.a = alpha;
	#else
	result.rgb += specular;
	#endif

	result.rgb = bOutputLinear ? result.rgb : Gamma(result.rgb);

	return result;
}


#define OBJECT_TEC(name, mmdpass, selfshadow) \
	technique name < string MMDPass = mmdpass; bool UseSelfShadow = selfshadow;\
		string Script = MOB_LOOPSCRIPT_OBJECT; \
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
technique ZplotTec < string MMDPass = "zplot"; > {}

//-----------------------------------------------------------------------------

