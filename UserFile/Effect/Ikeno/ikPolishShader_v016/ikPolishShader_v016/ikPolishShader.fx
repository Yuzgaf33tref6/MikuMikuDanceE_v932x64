//-----------------------------------------------------------------------------
// PBR���V�F�[�_�[
//-----------------------------------------------------------------------------

#include "ikPolishShader.fxsub"

#include "Sources/structs.fxsub"
#include "Sources/colorutil.fxsub"


//****************** �ȉ��͘M��Ȃ��ق�����������

// �o�͌`��
#define OutputTexFormat		"A16B16G16R16F"
//#define OutputTexFormat		"A8R8G8B8"

// ���}�b�v�̃e�N�X�`���`��
//#define EnvTexFormat		"A8R8G8B8"
#define EnvTexFormat		"A16B16G16R16F"

// �f�荞�݌v�Z�p (RGB+�{�J���W��/�A�e)
#define ReflectionTexFormat		"A16B16G16R16F"

// �V���h�E�}�b�v�̌��ʂ��i�[ (�A�e+����)
#define ShadowMapTexFormat		"G16R16F"

#define AntiAliasMode		false
#define MipMapLevel			1

// �����_�����O�^�[�Q�b�g�̃N���A�l
const float4 BackColor = float4(0,0,0,0);
const float ClearDepth  = 1.0;

// �I�t�X�N���[�������_�����O�Ŗ�������ΏہF
#define HIDE_EFFECT	\
	"self = hide;" \
	CONTROLLER_NAME " = hide;" \
	"PPointLight*.* = hide;"

// �e�X�g�p
//#define DISP_AMBIENT

//-----------------------------------------------------------------------------

// float AcsSi : CONTROLOBJECT < string name = "(self)"; string item = "Si"; >;
// float AcsTr : CONTROLOBJECT < string name = "(self)"; string item = "Tr"; >;

float Script : STANDARDSGLOBAL <
	string ScriptOutput = "color";
	string ScriptClass = "scene";
	string ScriptOrder = "postprocess";
> = 0.8;

#define COLORMAP_SCALE		(1.0)
#define WORKSPACE_SCALE		(1.0 / WORKSPACE_RES)

// �X�N���[���T�C�Y
float2 ViewportSize : VIEWPORTPIXELSIZE;
static float2 WorkSize = floor(ViewportSize * WORKSPACE_SCALE);
static float2 ViewportOffset = float2(0.5,0.5) / ViewportSize;
static float2 ViewportOffset2 = float2(0.5,0.5) / WorkSize;
static float2 ViewportWorkScale = ViewportSize / WorkSize;
static float2 ViewportAspect = float2(1, ViewportSize.x/ViewportSize.y);
static float2 SampStep = float2(1.0,1.0) / ViewportSize;

float4x4 matV			: VIEW;
float4x4 matP			: PROJECTION;
float4x4 matVP			: VIEWPROJECTION;
float4x4 matInvV		: VIEWINVERSE;
float4x4 matInvP		: PROJECTIONINVERSE;
float4x4 matInvVP		: VIEWPROJECTIONINVERSE;

float3 LightSpecular	: SPECULAR  < string Object = "Light"; >;
float3 LightDirection	: DIRECTION < string Object = "Light"; >;
float3 CameraPosition	: POSITION  < string Object = "Camera"; >;
float3 CameraDirection	: DIRECTION < string Object = "Camera"; >;

float time : TIME;

bool mExistPolish : CONTROLOBJECT < string name = CONTROLLER_NAME; >;
float mDirectLightP : CONTROLOBJECT < string name = CONTROLLER_NAME; string item = "���ڌ�+"; >;
float mDirectLightM : CONTROLOBJECT < string name = CONTROLLER_NAME; string item = "���ڌ�-"; >;
float mIndirectLightP : CONTROLOBJECT < string name = CONTROLLER_NAME; string item = "�Ԑڌ�+"; >;
float mIndirectLightM : CONTROLOBJECT < string name = CONTROLLER_NAME; string item = "�Ԑڌ�-"; >;
float mSSAOP : CONTROLOBJECT < string name = CONTROLLER_NAME; string item = "SSAO+"; >;
float mSSAOM : CONTROLOBJECT < string name = CONTROLLER_NAME; string item = "SSAO-"; >;
float mSSAOBias : CONTROLOBJECT < string name = CONTROLLER_NAME; string item = "SSAO�o�C�A�X"; >;
float mReflectionP : CONTROLOBJECT < string name = CONTROLLER_NAME; string item = "�f�荞��+"; >;
float mReflectionM : CONTROLOBJECT < string name = CONTROLLER_NAME; string item = "�f�荞��-"; >;
float mExposureP : CONTROLOBJECT < string name = CONTROLLER_NAME; string item = "�I��+"; >;
float mExposureM : CONTROLOBJECT < string name = CONTROLLER_NAME; string item = "�I��-"; >;
float mSoftShadow : CONTROLOBJECT < string name = CONTROLLER_NAME; string item = "�V���h�E"; >;

static float LightScale = CalcLightValue(mDirectLightP, mDirectLightM, DefaultLightScale);
static float AmbientScale = CalcLightValue(mIndirectLightP, mIndirectLightM, DefaultAmbientScale);
static float AmbientPower = CalcLightValue(mSSAOP, mSSAOM, DefaultAmbientPower);
static float ReflectionScale = CalcLightValue(mReflectionP, mReflectionM, DefaultReflectionScale);
static float ExposureScale = (CalcLightValue(mExposureP, mExposureM, DefaultExposureScale) - 1.0) * 0.5 + 1.0;
	// log2(1.0 + val) ��0�`1�`1.6

#if defined(SSSBlurCount) && SSSBlurCount > 0
float mSSSP : CONTROLOBJECT < string name = CONTROLLER_NAME; string item = "SSS+"; >;
float mSSSM : CONTROLOBJECT < string name = CONTROLLER_NAME; string item = "SSS-"; >;
static float SSSScale = CalcLightValue(mSSSP, mSSSM, DefaultSSSScale);
#endif

#if (defined(ENABLE_SSDO) && ENABLE_SSDO > 0) || SSAORayCount > 0
float mGIP : CONTROLOBJECT < string name = CONTROLLER_NAME; string item = "GI+"; >;
float mGIM : CONTROLOBJECT < string name = CONTROLLER_NAME; string item = "GI-"; >;
static float GIScale = CalcLightValue(mGIP, mGIM, DefaultGIScale);
#endif


static float3 LightColor = LightSpecular * LightScale;

#define	PI	(3.14159265359)

// �ڂ��������̏d�݌W���F
//	�K�E�X�֐� exp( -x^2/(2*d^2) ) �� d=5, x=0�`7 �ɂ��Čv�Z�����̂��A
//	(WT_7 + WT_6 + �c + WT_1 + WT_0 + WT_1 + �c + WT_7) �� 1 �ɂȂ�悤�ɐ��K����������
static const float BlurWeight[] = {
	0.0920246,
	0.0902024,
	0.0849494,
	0.0768654,
	0.0668236,
	0.0558158,
	0.0447932,
	0.0345379,
};


//-----------------------------------------------------------------------------
// �e�N�X�`��

// �X�N���[��
texture2D ScnMap : RENDERCOLORTARGET <
	float2 ViewPortRatio = {1.0,1.0};
	int MipLevels = 1;
	string Format = OutputTexFormat;
>;
sampler ScnSamp = sampler_state {
	texture = <ScnMap>;
	MinFilter = POINT;	MagFilter = POINT;	MipFilter = NONE;
	AddressU  = CLAMP;	AddressV = CLAMP;
};

texture2D DepthBuffer : RENDERDEPTHSTENCILTARGET <
	string Format = "D24S8";
>;

// �x�[�X�J���[�}�b�v(�X�y�L�����F�Ƃ��Ďg��)
texture ColorMapRT: OFFSCREENRENDERTARGET <
	float2 ViewPortRatio = {COLORMAP_SCALE, COLORMAP_SCALE};
	float4 ClearColor = { 0, 0, 0, 1 };
	float ClearDepth = 1.0;
	string Format = "A8R8G8B8" ;	// �A�e�v�Z�Ȃ��̐F�B���t���N�^���X�̌��f�[�^�Ƃ��Ďg�p�B
	int Miplevels = MipMapLevel;
	bool AntiAlias = AntiAliasMode;
	string Description = "MaterialMap for ikPolishShader";
	string DefaultEffect = 
		HIDE_EFFECT
		"*.pmd = ./Materials/MaterialMap.fx;"
		"*.pmx = ./Materials/MaterialMap.fx;"
		"*.x = ./Materials/MaterialMap.fx;"
		"* = hide;";
>;
sampler ColorMap = sampler_state {
	texture = <ColorMapRT>;
	MinFilter = POINT;	MagFilter = POINT;	MipFilter = NONE;
	AddressU  = CLAMP;	AddressV = CLAMP;
};

// �ގ��}�b�v
shared texture PPPMaterialMapRT: RENDERCOLORTARGET <
	float2 ViewPortRatio = {COLORMAP_SCALE, COLORMAP_SCALE};
	string Format = "A8R8G8B8" ;		// ���^���l�X�A�X���[�X�l�X�A�C���e���V�e�B�BSSS�B
	int Miplevels = 1;
	bool AntiAlias = AntiAliasMode;
	float4 ClearColor = { 0.0, 0.0, 0.0, 0.0};
>;
sampler MaterialMap = sampler_state {
	texture = <PPPMaterialMapRT>;
	MinFilter = POINT;	MagFilter = POINT;	MipFilter = NONE;
	AddressU  = CLAMP;	AddressV = CLAMP;
};

// �@���}�b�v
shared texture PPPNormalMapRT: RENDERCOLORTARGET <
	float2 ViewPortRatio = {COLORMAP_SCALE, COLORMAP_SCALE};
	#if SSAO_QUALITY >= 3
		string Format = "A32B32G32R32F";		// RGB�ɖ@���BA�ɂ͐[�x���
	#else
	string Format = "A16B16G16R16F";		// RGB�ɖ@���BA�ɂ͐[�x���
	#endif
	float4 ClearColor = { 0, 0, 0, 1 };
	int Miplevels = 1;
	bool AntiAlias = AntiAliasMode;
>;
sampler NormalSamp = sampler_state {
	texture = <PPPNormalMapRT>;
	MinFilter = POINT;	MagFilter = POINT;	MipFilter = NONE;
	AddressU = BORDER; AddressV = BORDER; BorderColor = float4(0,0,0,0);
};

// �A���x�h�}�b�v
shared texture PPPAlbedoMapRT: RENDERCOLORTARGET <
	float2 ViewPortRatio = {COLORMAP_SCALE, COLORMAP_SCALE};
	string Format = "A8R8G8B8" ;
	int Miplevels = 1;
	bool AntiAlias = AntiAliasMode;
	float4 ClearColor = { 0.0, 0.0, 0.0, 0.0};
>;
sampler AlbedoSamp = sampler_state {
	texture = <PPPAlbedoMapRT>;
	MinFilter = POINT;	MagFilter = POINT;	MipFilter = NONE;
	AddressU  = CLAMP;	AddressV = CLAMP;
};


// �A���r�G���g�Ɖf�荞�݂��i�[����B
shared texture2D PPPReflectionMap : RENDERCOLORTARGET <
	float2 ViewPortRatio = {1, 1};
	string Format = ReflectionTexFormat;
>;
sampler ReflectionMapSamp = sampler_state {
	texture = <PPPReflectionMap>;
	MinFilter = LINEAR;	MagFilter = LINEAR;	MipFilter = NONE;
	AddressU = BORDER; AddressV = BORDER; BorderColor = float4(0,0,0,0);
};

// ���[�N
texture2D FullWorkMap : RENDERCOLORTARGET <
	float2 ViewPortRatio = {1, 1};
	string Format = ReflectionTexFormat;
>;
sampler FullWorkSamp = sampler_state {
	texture = <FullWorkMap>;
	MinFilter = LINEAR;	MagFilter = LINEAR;	MipFilter = NONE;
	AddressU = BORDER; AddressV = BORDER; BorderColor = float4(0,0,0,0);
};
sampler FullWorkSampPoint = sampler_state {
	texture = <FullWorkMap>;
	MinFilter = POINT;	MagFilter = POINT;	MipFilter = NONE;
	AddressU = BORDER; AddressV = BORDER; BorderColor = float4(0,0,0,0);
};

#if WORKSPACE_RES != 1
// �k���o�b�t�@
texture2D HalfWorkMap : RENDERCOLORTARGET <
	float2 ViewPortRatio = {WORKSPACE_SCALE, WORKSPACE_SCALE};
	string Format = ReflectionTexFormat;
>;
sampler HalfWorkSamp = sampler_state {
	texture = <HalfWorkMap>;
	MinFilter = POINT;	MagFilter = POINT;	MipFilter = NONE;
	AddressU = BORDER; AddressV = BORDER; BorderColor = float4(0,0,0,0);
};
texture2D HalfWorkMap2 : RENDERCOLORTARGET <
	float2 ViewPortRatio = {WORKSPACE_SCALE, WORKSPACE_SCALE};
	string Format = ReflectionTexFormat;
>;
sampler HalfWorkSamp2 = sampler_state {
	texture = <HalfWorkMap2>;
	MinFilter = POINT;	MagFilter = POINT;	MipFilter = NONE;
	AddressU = BORDER; AddressV = BORDER; BorderColor = float4(0,0,0,0);
};
#endif


// �V���h�E�}�b�v�̌v�Z���ʊi�[�p
texture2D ShadowmapMap : RENDERCOLORTARGET <
	float2 ViewPortRatio = {1, 1};
	string Format = ShadowMapTexFormat;
>;
sampler ShadowmapSamp = sampler_state {
	texture = <ShadowmapMap>;
	MinFilter = LINEAR;	MagFilter = LINEAR;	MipFilter = LINEAR;
	AddressU = BORDER; AddressV = BORDER; BorderColor = float4(0,0,0,0);
};

// SSDO�̌v�Z�ƌ��ʊi�[�p (SSDO.rgb + �Օ��x)
texture2D SSAOWorkMap : RENDERCOLORTARGET <
	float2 ViewPortRatio = {1, 1};
	string Format = ReflectionTexFormat;
>;
sampler SSAOWorkSamp = sampler_state {
	texture = <SSAOWorkMap>;
	MinFilter = LINEAR;	MagFilter = LINEAR;	MipFilter = LINEAR;
	AddressU = BORDER; AddressV = BORDER; BorderColor = float4(0,0,0,0);
};


//-----------------------------------------------------------------------------
// 

#include "Sources/commons.fxsub"

#include "Environments/environmentmap.fxsub"
#include "Sources/rsm.fxsub"
#include "Sources/ssao.fxsub"
#include "Shadows/shadowmap.fxsub"
#include "Sources/indirectlight.fxsub"
#include "Sources/sss.fxsub"
#include "Sources/reflection.fxsub"
#include "Sources/antialias.fxsub"


// ����
float4 PS_Draw( float2 Tex: TEXCOORD0 ) : COLOR
{
	float3 BaseColor = ColorCorrectFromInput(tex2D(ScnSamp, Tex).rgb);

	// for debug
	#if defined(DISP_AMBIENT)
	return float4(tex2D(ReflectionMapSamp, Tex ).rgb, 1);
	#endif

	//-------------------------------------------------
	// gather indirect specular
	GeometryInfo geom = GetWND(Tex);
	MaterialParam material = GetMaterial(Tex);
	float3 RefColor = tex2D(ReflectionMapSamp, Tex + ViewportOffset).rgb;
	float3 V = normalize(CameraPosition - geom.wpos);
	float3 N = geom.nd.normal;
	float3 f0 = tex2D( ColorMap, Tex).rgb;
	float ao = lerp(GetSSAO(Tex), 1, material.smoothness);
	RefColor.rgb *= CalcReflectance(material, N, V, f0);
	RefColor.rgb += CalcMultiLightSpecular(geom.wpos, N, V, material.smoothness, f0);
	RefColor.rgb *= ao * ReflectionScale;
	//-------------------------------------------------

	// return tex2D(EnvMapSamp, Tex);
	// return tex2D(EnvMapSamp0, Tex);
	// return float4(tex2D(RSMAlbedoSamp, Tex ).rgb, 1);
	// return float4(GetSSAO(Tex).xxx, 1);
	// return float4(tex2D( MaterialMap, Tex ).xyz, 1);
	// return float4(RefColor.rgb, 1);
	// return float4(RefColor.www, 1);
	// return float4(tex2D(ShadowmapSamp, Tex ).xxx, 1);
	// return float4(tex2D(SSDOSamp, Tex ).rgb, 1);
	// return float4(normalize(tex2Dlod( NormalSamp, float4(Tex,0,0)).xyz) * 0.5 + 0.5, 1);

	float3 Color = BaseColor + RefColor.rgb;

	Color.rgb *= ExposureScale;

	#if defined(ENABLE_AA) && ENABLE_AA > 0
	// �A���`�G�C���A�X���L���ȏꍇ�́AAA��ɃJ���[�R���N�g���s���B
	#else
	Color.rgb = ColorCorrectToOutput(Color.rgb);
	#endif

	return float4(Color.rgb, 1);
}



//-----------------------------------------------------------------------------

#define BufferRenderStates	\
		AlphaBlendEnable = false;	AlphaTestEnable = false; \
//		ZEnable = false;	ZWriteEnable = false;	ZFunc = ALWAYS;

technique PolishShader <
	string Script = 
		"ClearSetColor=BackColor;"
		"ClearSetDepth=ClearDepth;"

		// ���}�b�v�̐���
		"RenderDepthStencilTarget=EnvDepthBuffer;"
		"RenderColorTarget0=EnvMap2;	Pass=SynthEnvPass;"
		#if ENV_MIPMAP > 0
		"RenderColorTarget0=EnvMap3;	Pass=EnvMipmapPass;"
		#endif

		// �V���h�E�}�b�v
		"RenderDepthStencilTarget=DepthBuffer;"
		"RenderColorTarget0=SSAOWorkMap;		Pass=ShadowMapPass;"
		"RenderColorTarget0=FullWorkMap;		Pass=ShadowBlurPassX;"
		"RenderColorTarget0=ShadowmapMap;		Pass=ShadowBlurPassY;"

		// ���ڌ��̏��E�ǂł̔���
		#if defined(RSMCount) && RSMCount > 0
		#if WORKSPACE_RES != 1
			"RenderColorTarget0=HalfWorkMap2;	Pass=CalcRSMPass;"
		#else
			"RenderColorTarget0=FullWorkMap;	Pass=CalcRSMPass;"
		#endif
		#endif

		// SSDO�̌v�Z
		#if SSAORayCount > 0
		#if WORKSPACE_RES != 1
			"RenderColorTarget0=HalfWorkMap;	Pass=SSAOPass;"
			"RenderColorTarget0=HalfWorkMap2;	Pass=HalfBlurXPass;"
			"RenderColorTarget0=HalfWorkMap;	Pass=HalfBlurYPass;"
			"RenderColorTarget0=SSAOWorkMap;	Pass=UpscalePass;"
		#else
			"RenderColorTarget0=SSAOWorkMap;	Pass=SSAOPass;"
			"RenderColorTarget0=FullWorkMap;	Pass=BlurXSSAOPass;"
			"RenderColorTarget0=SSAOWorkMap;	Pass=BlurYSSAOPass;"
		#endif
		#endif

		// �f�t���[�Y�̌v�Z
		"RenderColorTarget0=PPPReflectionMap;	Pass=CalcDiffusePass;"
		// �牺�U���̌v�Z
		#if SSSBlurCount > 0
		"RenderColorTarget0=FullWorkMap;		Pass=SSSBlurXPass;"
		"RenderColorTarget0=PPPReflectionMap;	Pass=SSSBlurYPass;"
		#endif

		// �ʏ�̃��f���`��
		"RenderColorTarget0=ScnMap;"
		"RenderDepthStencilTarget=DepthBuffer;"
		"Clear=Color; Clear=Depth;"
		"ScriptExternal=Color;"

		// RLR�̌v�Z
		#if !defined(DISP_AMBIENT)
		#if RLRRayCount > 0
		#if WORKSPACE_RES != 1
			"RenderColorTarget0=HalfWorkMap;	Pass=RLRPass;"
		#else
			"RenderColorTarget0=FullWorkMap;	Pass=RLRPass;"
		#endif
		"RenderColorTarget0=PPPReflectionMap;	Pass=RLRPass2;"
		"RenderColorTarget0=FullWorkMap;		Pass=RLRBlurXPass;"
		"RenderColorTarget0=PPPReflectionMap;	Pass=RLRBlurYPass;"
		#else
		// RLR���g�p���Ȃ��ꍇ�͊��}�b�v�݂̂��甽�ː������쐬����B
		"RenderColorTarget0=PPPReflectionMap;	Pass=WriteEnvPass;"
		#endif
		#endif

		#if defined(ENABLE_AA) && ENABLE_AA > 0
		// ����
		"RenderColorTarget0=" RENDERTARGET_ANTIALIAS_STRING ";"
		"Pass=DrawPass;"

		// �A���`�G�C���A�X
		"RenderColorTarget0=;"
		"RenderDepthStencilTarget=;"
		"Pass=AntialiasPass;"
		#else
		// ����
		"RenderColorTarget0=;"
		"RenderDepthStencilTarget=;"
		"Pass=DrawPass;"
		#endif
	;
> {
	pass SynthEnvPass < string Script= "Draw=Buffer;"; > {
		BufferRenderStates
		VertexShader = compile vs_3_0 VS_EnvBuffer();
		PixelShader  = compile ps_3_0 PS_SynthEnv();
	}
	#if ENV_MIPMAP > 0
	pass EnvMipmapPass < string Script= "Draw=Buffer;"; > {
		BufferRenderStates
		VertexShader = compile vs_3_0 VS_EnvBuffer();
		PixelShader  = compile ps_3_0 PS_CreateEnvMipmap();
	}
	#endif

	//-------------------------------------------------
	// Shadow map

	pass ShadowMapPass < string Script= "Draw=Buffer;"; > {
		BufferRenderStates
		VertexShader = compile vs_3_0 VS_Buffer();
		PixelShader  = compile ps_3_0 PS_Shadowmap();
	}
	pass ShadowBlurPassX < string Script= "Draw=Buffer;"; > {
		BufferRenderStates
		VertexShader = compile vs_3_0 VS_BlurShadow(true);
		PixelShader  = compile ps_3_0 PS_BlurShadow(SSAOWorkSamp);
	}
	pass ShadowBlurPassY < string Script= "Draw=Buffer;"; > {
		BufferRenderStates
		VertexShader = compile vs_3_0 VS_BlurShadow(false);
		PixelShader  = compile ps_3_0 PS_BlurShadow(FullWorkSamp);
	}

	//-------------------------------------------------
	// 

	#if WORKSPACE_RES != 1
	pass UpscalePass < string Script= "Draw=Buffer;"; > {
		BufferRenderStates
		VertexShader = compile vs_3_0 VS_Buffer();
		PixelShader  = compile ps_3_0 PS_Upscale(HalfWorkSamp);
	}
	pass HalfBlurXPass < string Script= "Draw=Buffer;"; > {
		BufferRenderStates
		VertexShader = compile vs_3_0 VS_BlurSSAO(true);
		PixelShader  = compile ps_3_0 PS_BlurSSAO(HalfWorkSamp);
	}
	pass HalfBlurYPass < string Script= "Draw=Buffer;"; > {
		BufferRenderStates
		VertexShader = compile vs_3_0 VS_BlurSSAO(false);
		PixelShader  = compile ps_3_0 PS_BlurSSAO(HalfWorkSamp2);
	}
	#endif

	#if defined(RSMCount) && RSMCount > 0
	pass CalcRSMPass < string Script= "Draw=Buffer;"; > {
		BufferRenderStates
		VertexShader = compile vs_3_0 VS_Buffer();
		PixelShader  = compile ps_3_0 PS_CalcRSM();
	}
	#endif

	#if SSAORayCount > 0
	pass SSAOPass < string Script= "Draw=Buffer;"; > {
		BufferRenderStates
		VertexShader = compile vs_3_0 VS_Buffer();
		PixelShader  = compile ps_3_0 PS_SSAO();
	}
	#if WORKSPACE_RES == 1
	pass BlurXSSAOPass < string Script= "Draw=Buffer;"; > {
		BufferRenderStates
		VertexShader = compile vs_3_0 VS_BlurSSAO(true);
		PixelShader  = compile ps_3_0 PS_BlurSSAO(SSAOWorkSamp);
	}
	pass BlurYSSAOPass < string Script= "Draw=Buffer;"; > {
		BufferRenderStates
		VertexShader = compile vs_3_0 VS_BlurSSAO(false);
		PixelShader  = compile ps_3_0 PS_BlurSSAO(FullWorkSamp);
	}
	#endif
	#endif

	pass CalcDiffusePass < string Script= "Draw=Buffer;"; > {
		BufferRenderStates
		VertexShader = compile vs_3_0 VS_Buffer();
		PixelShader  = compile ps_3_0 PS_CalcDiffuse();
	}
	#if SSSBlurCount > 0
	pass SSSBlurXPass < string Script= "Draw=Buffer;"; > {
		BufferRenderStates
		VertexShader = compile vs_3_0 VS_Buffer();
		PixelShader  = compile ps_3_0 PS_BlurSSS1(ReflectionMapSamp);
	}
	pass SSSBlurYPass < string Script= "Draw=Buffer;"; > {
		BufferRenderStates
		VertexShader = compile vs_3_0 VS_Buffer();
		PixelShader  = compile ps_3_0 PS_BlurSSS2(FullWorkSamp);
	}
	#endif

	//-------------------------------------------------
	// 

	#if RLRRayCount > 0
	pass RLRPass < string Script= "Draw=Buffer;"; > {
		BufferRenderStates
		VertexShader = compile vs_3_0 VS_Buffer();
		PixelShader  = compile ps_3_0 PS_RLR();
	}
	pass RLRPass2 < string Script= "Draw=Buffer;"; > {
		BufferRenderStates
		VertexShader = compile vs_3_0 VS_Buffer();
		PixelShader  = compile ps_3_0 PS_RLR2();
	}
	pass RLRBlurXPass < string Script= "Draw=Buffer;"; > {
		BufferRenderStates
		VertexShader = compile vs_3_0 VS_BlurRLR(true);
		PixelShader  = compile ps_3_0 PS_BlurRLR(true, ReflectionMapSamp);
	}
	pass RLRBlurYPass < string Script= "Draw=Buffer;"; > {
		BufferRenderStates
		VertexShader = compile vs_3_0 VS_BlurRLR(false);
		PixelShader  = compile ps_3_0 PS_BlurRLR(false, FullWorkSamp);
	}
	#else
	pass WriteEnvPass < string Script= "Draw=Buffer;"; > {
		BufferRenderStates
		VertexShader = compile vs_3_0 VS_Buffer();
		PixelShader  = compile ps_3_0 PS_WriteEnvAsReflection();
	}
	#endif

	//-------------------------------------------------
	// 

	pass DrawPass < string Script= "Draw=Buffer;"; > {
		BufferRenderStates
		VertexShader = compile vs_3_0 VS_Buffer();
		PixelShader  = compile ps_3_0 PS_Draw();
	}

	#if defined(ENABLE_AA) && ENABLE_AA > 0
	pass AntialiasPass < string Script= "Draw=Buffer;"; > {
		BufferRenderStates
		VertexShader = compile vs_3_0 VS_Buffer();
		PixelShader  = compile ps_3_0 PS_Antialias(RENDERTARGET_ANTIALIAS_SAMPLER);
	}
	#endif
}

//-----------------------------------------------------------------------------
