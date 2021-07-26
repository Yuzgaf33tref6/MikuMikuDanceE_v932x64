////////////////////////////////////////////////////////////////////////////////
//
//  AL_RimLighting.fx
//  �쐬: �~�[�t�H��
//
////////////////////////////////////////////////////////////////////////////////////////////////
// �p�����[�^�錾

#define PARENT_ACCESSORY "PostRimLighting.x"
#define TARGET_ACCESSORY "Target.x"

// �������C�g�̐F�̎w���ɏƖ��̐F���g�����ǂ���
static bool UseLightForRimLighting = true;

// MMM ��Ń������C�g�̎w���Ɏg���Ɩ��C���f�b�N�X
// �������A�Ɩ����͏Ɩ����L���ɂȂ��Ă��Ȃ��ƍX�V����Ȃ��̂ŁA�Ӗ������邩�͔���
static int RimLightingLightIndex = 0;

// �e�N�X�`���̃A���t�@���l�����邩�ǂ���
bool RimLightingUseTextureAlpha = true;

// �Ɩ��̐F���������C�g�Ɏg��Ȃ��ꍇ�̃������C�g�F
float3 DefaultRimLightingColor : CONTROLOBJECT < string name = PARENT_ACCESSORY; >;

// �������C�g�̋��x
// �������C�g�̐F�Ɋ|����l�ł��B1 �𒴂���l�╉�̒l���w��\�ł��B
float coRimLightingStrength : CONTROLOBJECT < string name = PARENT_ACCESSORY; string item = "Si"; >;

// �������C�g�̉s��
// 1 �ȏ�̒l�Őݒ�A�l����������ƃ������C�g�̓h�肪�������肷��
float coRimLightingPower : CONTROLOBJECT < string name = PARENT_ACCESSORY; string item = "Rx"; >;

// �������C�g�̊��x
// �l����������Ƃ��t���ɋ߂Â��Ȃ��ƃ������C�g���o�ɂ����Ȃ�
// 0 ���ƏƖ��̕����ɂ�����炸�������C�g���o��
float coRimLightingSensitivity : CONTROLOBJECT < string name = PARENT_ACCESSORY; string item = "Ry"; >;

// �������C�g�̕�
// �l����������ƃ������C�g�ɏƂ炳���͈͂��L���Ȃ�
float coRimLightingWidth : CONTROLOBJECT < string name = PARENT_ACCESSORY; string item = "Rz"; >;

////////////////////////////////////////////////////////////////////////////////////////////////

static float RimLightingStrength = coRimLightingStrength / 10;
static float RimLightingPower = coRimLightingPower == 0 ? 2 : coRimLightingPower / 3.1415926535 * 180;	// ����l 2
static float RimLightingWidth = coRimLightingWidth == 0 ? 1 : coRimLightingWidth / 3.1415926535 * 180;	// ����l 1
static float RimLightingSensitivity = coRimLightingSensitivity / 3.1415926535 * 180;

float4x4	WorldViewProjMatrix	: WORLDVIEWPROJECTION;
float4x4	WorldMatrix			: WORLD;
float4x4	ViewMatrix			: VIEW;
float4x4	ProjMatrix			: PROJECTION;
float3		CameraPosition		: POSITION		< string Object = "Camera"; >;

float4		MaterialDiffuse		: DIFFUSE		< string Object = "Geometry"; >;
float3		MaterialAmbient		: AMBIENT		< string Object = "Geometry"; >;
float3		MaterialEmmisive	: EMISSIVE		< string Object = "Geometry"; >;
float3		MaterialSpecular	: SPECULAR		< string Object = "Geometry"; >;
float		SpecularPower		: SPECULARPOWER	< string Object = "Geometry"; >;
float3		MaterialToon		: TOONCOLOR;
float4		EdgeColor			: EDGECOLOR;
float4		GroundShadowColor	: GROUNDSHADOWCOLOR;

float4		AddingTexture		: ADDINGTEXTURE;
float4		AddingSphere		: ADDINGSPHERETEXTURE;
float4		MultiplyTexture		: MULTIPLYINGTEXTURE;
float4		MultiplySphere		: MULTIPLYINGSPHERETEXTURE;

#ifdef MIKUMIKUMOVING

float		EdgeWidth			: EDGEWIDTH;

bool		LightEnables[MMM_LightCount]		: LIGHTENABLES;
float4x4	LightWVPMatrices[MMM_LightCount]	: LIGHTWVPMATRICES;
float3		LightDirection[MMM_LightCount]		: LIGHTDIRECTIONS;

float3		LightDiffuses[MMM_LightCount]		: LIGHTDIFFUSECOLORS;
float3		LightAmbients[MMM_LightCount]		: LIGHTAMBIENTCOLORS;
float3		LightSpeculars[MMM_LightCount]		: LIGHTSPECULARCOLORS;

float3		LightPositions[MMM_LightCount]		: LIGHTPOSITIONS;
float		LightZFars[MMM_LightCount]			: LIGHTZFARS;

static float4 DiffuseColor[MMM_LightCount] =
{
	MaterialDiffuse * float4(LightDiffuses[0], 1.0f),
	MaterialDiffuse * float4(LightDiffuses[1], 1.0f),
	MaterialDiffuse * float4(LightDiffuses[2], 1.0f)
};
static float3 AmbientColor[MMM_LightCount] =
{
	saturate(MaterialAmbient * LightAmbients[0] + MaterialEmmisive),
	saturate(MaterialAmbient * LightAmbients[1] + MaterialEmmisive),
	saturate(MaterialAmbient * LightAmbients[2] + MaterialEmmisive)
};
static float3 SpecularColor[MMM_LightCount] =
{
	MaterialSpecular * LightSpeculars[0],
	MaterialSpecular * LightSpeculars[1],
	MaterialSpecular * LightSpeculars[2]
};

#else

#define MMM_LightCount 1

float		EdgeWidth							= 1;

float4x4	LightWorldViewProjMatrix			: WORLDVIEWPROJECTION < string Object = "Light"; >;
float3		LightDirection0						: DIRECTION < string Object = "Light"; >;
float3		LightDiffuse						: DIFFUSE   < string Object = "Light"; >;
float3		LightAmbient						: AMBIENT   < string Object = "Light"; >;
float3		LightSpecular						: SPECULAR  < string Object = "Light"; >;

static bool		LightEnables[MMM_LightCount]		= { true };
static float4x4	LightWVPMatrices[MMM_LightCount]	= { LightWorldViewProjMatrix };
static float3	LightDirection[MMM_LightCount]		= { LightDirection0 };

static float3	LightDiffuses[MMM_LightCount]		= { LightDiffuse };
static float3	LightAmbients[MMM_LightCount]		= { LightAmbient };
static float3	LightSpeculars[MMM_LightCount]		= { LightSpecular };

static float4 DiffuseColor[MMM_LightCount] =
{
	MaterialDiffuse * float4(LightDiffuses[0], 1.0f)
};
static float3 AmbientColor[MMM_LightCount] =
{
	saturate(MaterialAmbient * LightAmbients[0] + MaterialEmmisive)
};
static float3 SpecularColor[MMM_LightCount] =
{
	MaterialSpecular * LightSpeculars[0]
};

#endif

bool	use_texture;		// �e�N�X�`���g�p
bool	use_spheremap;		// �X�t�B�A�}�b�v�g�p
bool	use_toon;			// �g�D�[���`�悩�ǂ��� (�A�N�Z�T��: false, ���f��: true)
bool	transp;				// �������t���O
bool	spadd;				// �X�t�B�A�}�b�v���Z�����t���O

#ifdef MIKUMIKUMOVING

bool    usetoontexturemap;	// Toon �e�N�X�`�����g�p���邩�ǂ����� (MMM)

#else

bool	parthf;				// �Z���t�V���h�E�t���O (mode1: false, mode2: true)
#define SKII1	1500
#define SKII2	8000
#define Toon	3
sampler DefSampler : register(s0);

#endif

texture ObjectTexture : MATERIALTEXTURE;
sampler ObjTexSampler = sampler_state
{
	Texture = <ObjectTexture>;
	MinFilter = Anisotropic;
	MagFilter = Anisotropic;
	MipFilter = Linear;
	MaxAnisotropy = 16;
};
texture ObjectSphereMap : MATERIALSPHEREMAP;
sampler ObjSphereSampler = sampler_state
{
	Texture = <ObjectSphereMap>;
	MinFilter = Anisotropic;
	MagFilter = Anisotropic;
	MipFilter = Linear;
	MaxAnisotropy = 16;
};
texture ObjectToonTexture : MATERIALTOONTEXTURE;
sampler ObjToonSampler = sampler_state
{
	texture = <ObjectToonTexture>;
	MinFilter = Linear;
	MagFilter = Linear;
	MipFilter = None;
	AddressU = Clamp;
	AddressV = Clamp;
};

///////////////////////////////////////////////////////////////////////////////////////////////

struct VS_OUTPUT
{
	float4 Pos			: POSITION;		// �ˉe�ϊ����W
	float4 Pos2			: POSITION1;
	float4 ZCalcTex		: TEXCOORD0;	// Z �l
	float2 Tex			: TEXCOORD1;	// �e�N�X�`��
	float3 Normal		: TEXCOORD2;	// �@��
	float3 Eye			: TEXCOORD3;	// �J�����Ƃ̑��Έʒu
	float2 SpTex		: TEXCOORD4;	// �X�t�B�A�}�b�v�e�N�X�`�����W
#ifdef MIKUMIKUMOVING
	float4 SS_UV1		: TEXCOORD5;	// �Z���t�V���h�E�e�N�X�`�����W
	float4 SS_UV2		: TEXCOORD6;	// �Z���t�V���h�E�e�N�X�`�����W
	float4 SS_UV3		: TEXCOORD7;	// �Z���t�V���h�E�e�N�X�`�����W
#endif
#ifdef USE_EXCELLENTSHADOW
	float4 ScreenTex	: TEXCOORD8;
#endif
	float4 Color		: COLOR0;		// �f�B�t���[�Y�F
};

#ifdef MIKUMIKUMOVING
VS_OUTPUT Basic_VS(MMM_SKINNING_INPUT IN, uniform bool useSelfShadow, uniform bool isEdge)
{
	MMM_SKINNING_OUTPUT SkinOut = MMM_SkinnedPositionNormal(IN.Pos, IN.Normal, IN.BlendWeight, IN.BlendIndices, IN.SdefC, IN.SdefR0, IN.SdefR1);
	float4 Pos = SkinOut.Position;
	float3 Normal = SkinOut.Normal;
	float2 Tex = IN.Tex;
#else
VS_OUTPUT Basic_VS(float4 Pos : POSITION, float3 Normal : NORMAL, float2 Tex : TEXCOORD0, uniform bool useSelfShadow, uniform bool isEdge)
{
#endif
	VS_OUTPUT Out = (VS_OUTPUT)0;
	
	Out.Eye = CameraPosition - mul(Pos, WorldMatrix);

	float dist = length(Out.Eye);

	if (isEdge)
	{
		float EdgeWeight = 0.001;

		if (!use_toon)
			EdgeWeight *= 0.1;

#ifdef MIKUMIKUMOVING
		EdgeWeight = IN.EdgeWeight;
#endif

#ifdef MIKUMIKUMOVING
		if (MMM_IsDinamicProjection)
			EdgeWeight *= MMM_GetDynamicFovEdgeRate(dist);
#endif

		Pos += float4(Normal, 0) * EdgeWeight * EdgeWidth * dist;
	}

#ifdef MIKUMIKUMOVING
	Out.Pos = mul(Pos, MMM_IsDinamicProjection ? mul(mul(WorldMatrix, ViewMatrix), MMM_DynamicFov(ProjMatrix, dist)) : WorldViewProjMatrix);
#else
	Out.Pos = mul(Pos, WorldViewProjMatrix);
#endif

	Out.Normal = normalize(mul(Normal, (float3x3)WorldMatrix));
	
	float3 color = 0;
	float3 ambient = 0;
	int count = 0;

	[unroll]
	for (int i = 0; i < MMM_LightCount; i++)
		if (LightEnables[i])
		{
			color += (float3(1, 1, 1) - color) * max(0, DiffuseColor[i] * dot(Out.Normal, -LightDirection[i]));
			ambient += AmbientColor[i];
			count++;
		}

	Out.Color.rgb = saturate(ambient / count + color);
	Out.Color.a = DiffuseColor[0].a;
	Out.Tex = Tex;
	
	if (use_spheremap)
		Out.SpTex = mul(Out.Normal, (float3x3)ViewMatrix) * float2(0.5, -0.5) + float2(0.5, 0.5);

#ifdef MIKUMIKUMOVING
	if (!use_spheremap)
		Out.SpTex.xy = IN.AddUV1.xy;

	if (useSelfShadow)
	{
		float4 dpos = mul(Pos, WorldMatrix);

		Out.SS_UV1 = mul(dpos, LightWVPMatrices[0]);
		Out.SS_UV2 = mul(dpos, LightWVPMatrices[1]);
		Out.SS_UV3 = mul(dpos, LightWVPMatrices[2]);
		Out.SS_UV1.y = -Out.SS_UV1.y;
		Out.SS_UV2.y = -Out.SS_UV2.y;
		Out.SS_UV3.y = -Out.SS_UV3.y;
		Out.SS_UV1.z = length(LightPositions[0] - Pos) / LightZFars[0];
		Out.SS_UV2.z = length(LightPositions[1] - Pos) / LightZFars[1];
		Out.SS_UV3.z = length(LightPositions[2] - Pos) / LightZFars[2];
	}
#else
	Out.ZCalcTex = mul(Pos, LightWorldViewProjMatrix);
#endif

#ifdef USE_EXCELLENTSHADOW
	Out.ScreenTex = Out.Pos;
	Out.Pos.z -= max(0, (int)((CameraDistance1 - 6000) * 0.05));
#endif

	Out.Pos2 = Out.Pos;

	return Out;
}

float4 Basic_PS(VS_OUTPUT IN, uniform bool useSelfShadow, uniform bool isEdge) : COLOR0
{
	if (isEdge)
		return 0;
	
	float3 L = normalize(LightDirection[RimLightingLightIndex]);
	float3 N = normalize(IN.Normal);
	float3 E = normalize(IN.Eye);
	float3 Kr = (UseLightForRimLighting
		&& DefaultRimLightingColor.x == 0
		&& DefaultRimLightingColor.y == 0
		&& DefaultRimLightingColor.z == 0 ? LightAmbients[RimLightingLightIndex] : DefaultRimLightingColor) * RimLightingStrength;
	float4 Color = IN.Color;

	Color.rgb *= LightDiffuses[RimLightingLightIndex] * max(dot(N, L), 0);
	Color.rgb += Kr * (1 - saturate(max(dot(-L, E), 0) * RimLightingSensitivity)) * (1 - max(pow(max(0, dot(N, E)), RimLightingWidth), 0) * RimLightingPower);

	if (use_texture && RimLightingUseTextureAlpha)
		Color.a *= tex2D(ObjTexSampler, IN.Tex).a;

	return saturate(Color);
}

#define DRAW_EDGE_PASS(useSelfShadow) \
	pass DrawEdge \
	{ \
		CullMode = CW; \
		AlphaTestEnable = true; \
		VertexShader = compile vs_3_0 Basic_VS(useSelfShadow, true); \
		PixelShader  = compile ps_3_0 Basic_PS(useSelfShadow, true); \
	}

#define DRAW_OBJECT_PASS(useSelfShadow) \
	pass DrawObject \
	{ \
		AlphaTestEnable = true; \
		VertexShader = compile vs_3_0 Basic_VS(useSelfShadow, false); \
		PixelShader  = compile ps_3_0 Basic_PS(useSelfShadow, false); \
	}

technique MainTec0 < string MMDPass = "object"; >
{
	DRAW_OBJECT_PASS(false)
	DRAW_EDGE_PASS(false)
}

technique MainTec1 < string MMDPass = "object_ss"; >
{
	DRAW_OBJECT_PASS(true)
	DRAW_EDGE_PASS(true)
}