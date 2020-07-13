//-----------------------------------------------------------------------------
// MaterialTester�p�ɃJ�X�^�}�C�Y���ꂽ�AMaterialMap.fx
//-----------------------------------------------------------------------------

// �R���g���[����
// �e�X�g�p���f���ȊO�Ɋ��蓖�ĂĂ����삷��悤�ɃR���g���[�����𒼐ڎw�肷��B
#define TEST_CONTROLLER_NAME	"MaterialTester.pmx"
//#define TEST_CONTROLLER_NAME	"(self)"

//-----------------------------------------------------------------------------
// �@���}�b�v���g�p���邩?
#define USE_NORMALMAP
// USE_NCHL_SETTINGS�Ɨ����g���ꍇ�A�T�u�@���݂̂��L���ɂȂ�܂��B

// ���C���@���}�b�v
#define NORMALMAP_MAIN_FILENAME "brick_n.png" //�t�@�C����
//�R���g���[���Ŏw�肷��B
//const float NormalMapMainLoopNum = 1;				//�J��Ԃ���
//const float NormalMapMainHeightScale = 0.05;		//�����␳ ���ō����Ȃ� 0�ŕ��R

// �T�u�@���}�b�v(���ׂȉ��ʗp)
#define NORMALMAP_SUB_FILENAME "dummy_n.bmp" //�t�@�C����
const float NormalMapSubLoopNum = 7;			//�J��Ԃ���
const float NormalMapSubHeightScale = 0.2;		//�����␳ ���ō����Ȃ� 0�ŕ��R

// �ݒ肱���܂�
//-----------------------------------------------------------------------------


// ���@�ϊ��s��
float4x4 matW			: WORLD;
float4x4 matWV		: WORLDVIEW;
float4x4 matWVP		: WORLDVIEWPROJECTION;

// �}�e���A���F
float4	MaterialDiffuse		: DIFFUSE  < string Object = "Geometry"; >;
float3	MaterialAmbient		: AMBIENT  < string Object = "Geometry"; >;
float3	MaterialEmissive	: EMISSIVE < string Object = "Geometry"; >;
float3	MaterialSpecular	: SPECULAR < string Object = "Geometry"; >;
float	SpecularPower		: SPECULARPOWER < string Object = "Geometry"; >;

float3   CameraPosition    : POSITION  < string Object = "Camera"; >;
float3	LightDiffuse		: DIFFUSE   < string Object = "Light"; >;

static float4 DiffuseColor  = MaterialDiffuse;
static float3 SpecularColor = (MaterialSpecular * (LightDiffuse.r * 9 + 1)) * 0.9 + 0.05;

#define REF_CTRL	string name = TEST_CONTROLLER_NAME
float CustomMetalness : CONTROLOBJECT < REF_CTRL; string item = "Metalness"; >;
float CustomSmoothness : CONTROLOBJECT < REF_CTRL; string item = "Smoothness"; >;
float NonmetalF0 : CONTROLOBJECT < REF_CTRL; string item = "NonmetalF0"; >;
float CustomIntensity : CONTROLOBJECT < REF_CTRL; string item = "Intensity"; >;
float SSSValue : CONTROLOBJECT < REF_CTRL; string item = "SSSValue"; >;
float NormalMapMainHeightScale : CONTROLOBJECT < REF_CTRL; string item = "Normal1Height"; >;
float NormalMap1Loop : CONTROLOBJECT < REF_CTRL; string item = "Normal1Loop"; >;
static float NormalMapMainLoopNum = NormalMap1Loop * 10.0 + 1.0;

bool	 spadd;	// �X�t�B�A�}�b�v���Z�����t���O

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
sampler ObjSphareSampler = sampler_state {
	texture = <ObjectSphereMap>;
	MINFILTER = LINEAR;
	MAGFILTER = LINEAR;
	ADDRESSU  = WRAP;
	ADDRESSV  = WRAP;
};


#ifdef USE_NORMALMAP
//���C���@���}�b�v
#define ANISO_NUM 16

texture2D NormalMap <
    string ResourceName = NORMALMAP_MAIN_FILENAME;
>;
sampler NormalMapSamp = sampler_state {
    texture = <NormalMap>;
	MINFILTER = ANISOTROPIC;
	MAGFILTER = ANISOTROPIC;
	MIPFILTER = ANISOTROPIC;
	
	MAXANISOTROPY = ANISO_NUM;
};

//�T�u�@���}�b�v
texture2D NormalMapSub <
    string ResourceName = NORMALMAP_SUB_FILENAME;
>;
sampler NormalMapSampSub = sampler_state {
    texture = <NormalMapSub>;
	MINFILTER = ANISOTROPIC;
	MAGFILTER = ANISOTROPIC;
	MIPFILTER = ANISOTROPIC;
	
	MAXANISOTROPY = ANISO_NUM;
};
#endif

shared texture PPPNormalMapRT: RENDERCOLORTARGET;
shared texture PPPMaterialMapRT: RENDERCOLORTARGET;


///////////////////////////////////////////////////////////////////////////////////////////////
// 
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
#if !defined(USE_NORMALMAP)
	return float4(Normal,1);
#else
	float4 Norm = 1;

	float2 tex = Tex* NormalMapMainLoopNum;//���C��
	float4 NormalColor = tex2D( NormalMapSamp, tex) * 2 - 1;
	NormalColor.rg *= NormalMapMainHeightScale;
	NormalColor.rgb = normalize(NormalColor.rgb);

	float2 texSub = Tex * NormalMapSubLoopNum;//�T�u
	float4 NormalColorSub = tex2D( NormalMapSampSub, texSub)*2-1;	//-1�`1�̒l�ɂ���
	NormalColorSub.rg *= NormalMapSubHeightScale;
	NormalColorSub.rgb = normalize(NormalColorSub.rgb);

	NormalColor.rg += NormalColorSub.rg;
	NormalColor.rgb = normalize(NormalColor.rgb);

	float3x3 tangentFrame = compute_tangent_frame(Normal, Eye, Tex);
	Norm.rgb = normalize(mul(NormalColor.rgb, tangentFrame));

	return Norm;
#endif
}

///////////////////////////////////////////////////////////////////////////////////////////////
// �I�u�W�F�N�g�`��

struct VS_OUTPUT
{
	float4 Pos	: POSITION;
	float3 Normal	: TEXCOORD0;
	float2 Tex	: TEXCOORD1;
	float3 WPos	: TEXCOORD2;
	float Distance	: TEXCOORD3;
	float2 SpTex	: TEXCOORD4;
};

struct PS_OUT_MRT
{
	float4 Color		: COLOR0;
	float4 Normal		: COLOR1;
	float4 Material		: COLOR2;
};

VS_OUTPUT Basic_VS(float4 Pos : POSITION, float3 Normal : NORMAL, float2 Tex: TEXCOORD0,
	 uniform bool useTexture, uniform bool useSphereMap)
{
	VS_OUTPUT Out = (VS_OUTPUT)0;

	Out.Pos = mul( Pos, matWVP );
	Out.Normal = normalize(mul(Normal,(float3x3)matW));
	Out.Tex = Tex;

	Out.WPos = mul( Pos, matW ).xyz;
	Out.Distance = mul(Pos, matWV).z;

	if ( useSphereMap && !spadd) {
		float2 NormalWV = normalize(mul( Normal, (float3x3)matWV )).xy;
		Out.SpTex.x = NormalWV.x * 0.5f + 0.5f;
		Out.SpTex.y = NormalWV.y * -0.5f + 0.5f;
	}

	return Out;
}


PS_OUT_MRT Basic_PS( VS_OUTPUT IN, uniform bool useTexture, uniform bool useSphereMap) : COLOR
{
	float4 Color = DiffuseColor;
	if ( useTexture ) {
		float4 TexColor = tex2D( ObjTexSampler, IN.Tex );
		Color *= TexColor;
	}

	// clip(Color.a - AlphaThreshold);

	if ( useSphereMap && !spadd) {
		float4 TexColor = tex2D(ObjSphareSampler,IN.SpTex);
		Color.rgb *= TexColor.rgb;
	}

	const float3 V = normalize(CameraPosition - IN.WPos);
	const float3 N = CalcNormal(IN.Tex, V, normalize(IN.Normal)).xyz;

	float4 params = 1;
	params = float4(CustomMetalness, CustomSmoothness, CustomIntensity, SSSValue);

	PS_OUT_MRT Out;
	Out.Material = params;
	Out.Normal = float4(N, IN.Distance);

	// �X�y�L�����̐F�����ːF�Ƃ݂Ȃ�
	float metalness = params.x;
	float3 spColor = (Color.rgb * Color.rgb * 0.5 + 0.5) * SpecularColor;
	Color.rgb = lerp(NonmetalF0, spColor, metalness);

	Out.Color = Color;

	return Out;
}

#define OBJECT_TEC(name, mmdpass, tex, sphere) \
	technique name < string MMDPass = mmdpass; bool UseTexture = tex; bool UseSphereMap = sphere; \
	string Script = \
		"RenderColorTarget0=;" \
		"RenderColorTarget1=PPPNormalMapRT;" \
		"RenderColorTarget2=PPPMaterialMapRT;" \
		"RenderDepthStencilTarget=;" \
		"Pass=DrawObject;" \
		"RenderColorTarget1=;" \
		"RenderColorTarget2=;" \
	; \
	> { \
		pass DrawObject { \
			AlphaTestEnable = FALSE; \
			AlphaBlendEnable = FALSE; \
			VertexShader = compile vs_3_0 Basic_VS(tex, sphere); \
			PixelShader  = compile ps_3_0 Basic_PS(tex, sphere); \
		} \
	}


OBJECT_TEC(MainTec0, "object", false, false)
OBJECT_TEC(MainTec1, "object", true, false)
OBJECT_TEC(MainTec2, "object", false, true)
OBJECT_TEC(MainTec3, "object", true, true)
OBJECT_TEC(MainTecBS0, "object_ss", false, false)
OBJECT_TEC(MainTecBS1, "object_ss", true, false)
OBJECT_TEC(MainTecBS2, "object_ss", false, true)
OBJECT_TEC(MainTecBS3, "object_ss", true, true)

technique EdgeTec < string MMDPass = "edge"; > {}
technique ShadowTech < string MMDPass = "shadow";  > {}
technique ZplotTec < string MMDPass = "zplot"; > {}


///////////////////////////////////////////////////////////////////////////////////////////////
