////////////////////////////////////////////////////////////////////////////////////////////////
// PBR���V�F�[�_�[
////////////////////////////////////////////////////////////////////////////////////////////////

#include "ikPolishShader.fxsub"

// �ݒ�́AikPolishShader.fxsub �ɏW�񂵂܂����B


//****************** �ȉ��͘M��Ȃ��ق�����������

// �o�͌`��
#if defined(ENABLE_HDR) && ENABLE_HDR > 0
#define OutputTexFormat		"A16B16G16R16F"
#else
#define OutputTexFormat		"A8R8G8B8"
#endif

// ���}�b�v�̃e�N�X�`���`��
#define EnvTexFormat		"A8R8G8B8"
//#define EnvTexFormat		"A16B16G16R16F"

// �f�荞�݌v�Z�p (RGB+�{�J���W��/�A�e)
//#define ReflectionTexFormat		"A8R8G8B8"
#define ReflectionTexFormat		"A16B16G16R16F"

// �V���h�E�}�b�v�̌��ʂ��i�[ (�A�e+����)
#define ShadowMapTexFormat		"G16R16F"


#define AntiAliasMode		false
#define MipMapLevel			1

// �����_�����O�^�[�Q�b�g�̃N���A�l
const float4 BackColor = float4(0,0,0,0);
const float ClearDepth  = 1.0;

// �e�X�g�p
//#define DISP_AMBIENT

////////////////////////////////////////////////////////////////////////////////////////////////

// float AcsSi : CONTROLOBJECT < string name = "(self)"; string item = "Si"; >;
// float AcsTr : CONTROLOBJECT < string name = "(self)"; string item = "Tr"; >;

float Script : STANDARDSGLOBAL <
	string ScriptOutput = "color";
	string ScriptClass = "scene";
	string ScriptOrder = "postprocess";
> = 0.8;


// ���[�N�e�N�X�`���̏k���x (1,2 �܂��� 4)
// 2�Ȃ��ʂ�1/2�̉𑜓x�B�傫���l�قǉ掿���򉻂������ɏȃ������E�������ɂȂ�
#define WORKSPACE_RES		1

#define COLORMAP_SCALE		(1.0)
#define WORKSPACE_SCALE		(1.0 / WORKSPACE_RES)

// �X�N���[���T�C�Y
float2 ViewportSize : VIEWPORTPIXELSIZE;
static float2 ViewportOffset = (float2(0.5,0.5)/ViewportSize);
static float2 ViewportOffset2 = (float2(0.5,0.5)/(ViewportSize * WORKSPACE_SCALE));
static float2 ViewportAspect = float2(1, ViewportSize.x/ViewportSize.y);
static float2 SampStep = (float2(1.0,1.0) / (ViewportSize * WORKSPACE_SCALE));

float4x4 matV			: VIEW;
float4x4 matP			: PROJECTION;
float4x4 matVP			: VIEWPROJECTION;
float4x4 matInvVP		: VIEWPROJECTIONINVERSE;

float3 LightSpecular	: SPECULAR  < string Object = "Light"; >;
float3 LightDirection	: DIRECTION < string Object = "Light"; >;
float3 CameraPosition	: POSITION  < string Object = "Camera"; >;
//float3 CameraDirection	: DIRECTION < string Object = "Camera"; >;

float time : TIME;

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

#if defined(ENABLE_SSGI) && ENABLE_SSGI > 0
float mGIP : CONTROLOBJECT < string name = CONTROLLER_NAME; string item = "GI+"; >;
float mGIM : CONTROLOBJECT < string name = CONTROLLER_NAME; string item = "GI-"; >;
static float GIScale = CalcLightValue(mGIP, mGIM, DefaultGIScale);
#endif

static float3 LightColor = LightSpecular * LightScale;
// sampler DefSampler : register(s0);

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


////////////////////////////////////////////////////////////////////////////////////////////////
// �e�N�X�`��

// �X�N���[��
texture2D ScnMap : RENDERCOLORTARGET <
	float2 ViewPortRatio = {1.0,1.0};
	int MipLevels = 1;
	bool AntiAlias = false;
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

// �x�[�X�J���[�}�b�v
texture ColorMapRT: OFFSCREENRENDERTARGET <
	float2 ViewPortRatio = {COLORMAP_SCALE, COLORMAP_SCALE};
	float4 ClearColor = { 0, 0, 0, 1 };
	float ClearDepth = 1.0;
	string Format = "A8R8G8B8" ;	// �A�e�v�Z�Ȃ��̐F�B���t���N�^���X�̌��f�[�^�Ƃ��Ďg�p�B
	int Miplevels = MipMapLevel;
	bool AntiAlias = AntiAliasMode;
	string Description = "MaterialMap for ikPolishShader";
	string DefaultEffect = 
		"self = hide;"
		CONTROLLER_NAME " = hide;"
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
	AddressU  = CLAMP;	AddressV = CLAMP;
};


// �A���r�G���g�Ɖf�荞�݂��i�[����B
shared texture2D PPPReflectionMap : RENDERCOLORTARGET <
	float2 ViewPortRatio = {WORKSPACE_SCALE, WORKSPACE_SCALE};
	string Format = ReflectionTexFormat;
>;
sampler ReflectionMapSamp = sampler_state {
	texture = <PPPReflectionMap>;
	MinFilter = LINEAR;	MagFilter = LINEAR;	MipFilter = NONE;
	AddressU  = CLAMP;	AddressV = CLAMP;
};

// ���[�N
texture2D ReflectionWorkMap : RENDERCOLORTARGET <
	float2 ViewPortRatio = {WORKSPACE_SCALE, WORKSPACE_SCALE};
	string Format = ReflectionTexFormat;
>;
sampler ReflectionWorkMapSamp = sampler_state {
	texture = <ReflectionWorkMap>;
	MinFilter = LINEAR;	MagFilter = LINEAR;	MipFilter = NONE;
	AddressU  = CLAMP;	AddressV = CLAMP;
};
sampler ReflectionWorkMapSampPoint = sampler_state {
	texture = <ReflectionWorkMap>;
	MinFilter = POINT;	MagFilter = POINT;	MipFilter = NONE;
	AddressU = BORDER; AddressV = BORDER; BorderColor = float4(0,0,0,0);
};

// �V���h�E�}�b�v�̌v�Z���ʊi�[�p
texture2D ShadowmapMap : RENDERCOLORTARGET <
	float2 ViewPortRatio = {WORKSPACE_SCALE, WORKSPACE_SCALE};
	string Format = ShadowMapTexFormat;
>;
sampler ShadowmapSamp = sampler_state {
	texture = <ShadowmapMap>;
	MinFilter = LINEAR;	MagFilter = LINEAR;	MipFilter = LINEAR;
	AddressU  = CLAMP;	AddressV = CLAMP;
};

// SSDO�̌v�Z�ƌ��ʊi�[�p (SSDO.rgb + �Օ��x)
texture2D SSAOWorkMap : RENDERCOLORTARGET <
	float2 ViewPortRatio = {WORKSPACE_SCALE, WORKSPACE_SCALE};
	string Format = ReflectionTexFormat;
>;
sampler SSAOWorkMapSamp = sampler_state {
	texture = <SSAOWorkMap>;
	MinFilter = LINEAR;	MagFilter = LINEAR;	MipFilter = LINEAR;
	AddressU  = CLAMP;	AddressV = CLAMP;
};


////////////////////////////////////////////////////////////////////////////////////////////////
// 

#include "Sources/commons.fxsub"

#include "Environments/environmentmap.fxsub"
#include "Shadows/shadowmap.fxsub"
#include "Sources/diffusion.fxsub"
#include "Sources/ssao.fxsub"
#include "RSM/rsm.fxsub"

// �g�U���˂̌v�Z
#include "Sources/indirectlight.fxsub"

// ���ʔ��˂̌v�Z
#include "Sources/reflection.fxsub"

// ����
float4 PS_Draw( float2 Tex: TEXCOORD0 ) : COLOR
{
	float3 BaseColor = Degamma(tex2D( ScnSamp, Tex ).rgb);
	float4 RefColor = tex2D(ReflectionMapSamp, Tex );

	#if defined(DISP_AMBIENT)
	return float4(RefColor.rgb, 1);
	#endif

	//-------------------------------------------------
	// �ԐڃX�y�L����
	float3 WPos, N;
	float Depth;
	GetWND(Tex, WPos, N, Depth);
	float3 V = normalize(CameraPosition - WPos);
	float3 mat = tex2D( MaterialMap, Tex).xyz;
	float smoothness = mat.y;
	float3 f0 = tex2D( ColorMap, Tex).rgb;
	RefColor.rgb *= CalcReflectance(mat, N, V, f0);
	RefColor.rgb += CalcMultiLightSpecular(WPos, N, V, smoothness, f0);
	RefColor.rgb *= lerp(GetSSAO(Tex), 1, smoothness);
	//-------------------------------------------------

	// return float4(GetSSAO(Tex).xxx, 1);
	// return float4(tex2D( MaterialMap, Tex ).xyz, 1);
	// return float4(RefColor.rgb, 1);
	// return float4(RefColor.www, 1);
	// return float4(tex2D(ShadowmapSamp, Tex ).xxx, 1);
	// return float4(tex2D(SSGISamp, Tex ).rgb, 1);
	// return float4(normalize(tex2Dlod( NormalSamp, float4(Tex,0,0)).xyz) * 0.5 + 0.5, 1);
	// ambientOccu = 0;
	RefColor.rgb *= ReflectionScale;
	float3 Color = BaseColor + RefColor.rgb;
	Color.rgb *= ExposureScale;

	#if defined(ENABLE_AA) && ENABLE_AA > 0
	// �A���`�G�C���A�X��ɃK���}�␳���|����B
	return float4(Color.rgb, 1);
	#else
	return float4(Gamma(Color.rgb), 1);
	#endif
}

// �A���`�G�C���A�X
#include "Sources/antialias.fxsub"


////////////////////////////////////////////////////////////////////////////////////////////////

#define BufferRenderStates	\
		AlphaBlendEnable = false;	AlphaTestEnable = false; \
//		ZEnable = false;	ZWriteEnable = false;	ZFunc = ALWAYS;

technique PolishShader <
	string Script = 
		"RenderDepthStencilTarget=DepthBuffer;"
		"ClearSetColor=BackColor;"
		"ClearSetDepth=ClearDepth;"

		// ���}�b�v�̐���
		#if !defined(USE_STATIC_ENV)
		"RenderDepthStencilTarget=EnvDepthBuffer;"
		"RenderColorTarget0=EnvMap2;	Clear=Color;	Pass=SynthEnvPass;"
		"RenderDepthStencilTarget=DepthBuffer;"
		#endif

		// �V���h�E�}�b�v�̃u���[
		"RenderColorTarget0=ReflectionWorkMap;	Pass=ShadowBlurPassX;"
		"RenderColorTarget0=ShadowmapMap;		Pass=ShadowBlurPassY;"

		// SSDO�̌v�Z
		#if SSAORayCount > 0
		"RenderColorTarget0=SSAOWorkMap;"
		"Clear=Color;"
		"Pass=SSAOPass;"
		"RenderColorTarget0=ReflectionWorkMap;	Pass=BlurXSSAOPass;"
		"RenderColorTarget0=SSAOWorkMap;		Pass=BlurYSSAOPass;"
		#endif

		// ���ڌ��̏��E�ǂł̔���
		#if defined(RSMCount) && RSMCount > 0
		"RenderColorTarget0=RSMWorkMap;			Pass=CalcRSMPass;"
		"RenderColorTarget0=ReflectionWorkMap;	Pass=RSMBlurXPass;"
		"RenderColorTarget0=RSMWorkMap;			Pass=RSMBlurYPass;"
		#endif

		// �f�t���[�Y�̌v�Z
		"RenderColorTarget0=PPPReflectionMap;	Pass=SSAOEnvPass;"
		#if SSSBlurCount > 0
		"RenderColorTarget0=ReflectionWorkMap;	Pass=SSSBlurXPass;"
		"RenderColorTarget0=PPPReflectionMap;	Pass=SSSBlurYPass;"
		#endif

		// �ʏ�̃��f���`��
		"RenderColorTarget0=ScnMap;"
		"RenderDepthStencilTarget=DepthBuffer;"
		"Clear=Color;"
		"Clear=Depth;"
		"ScriptExternal=Color;"

		// RLR�̌v�Z
		#if !defined(DISP_AMBIENT)
		#if RLRRayCount > 0
		"RenderColorTarget0=ReflectionWorkMap;	Pass=RLRPass;"
		"RenderColorTarget0=PPPReflectionMap;	Pass=RLRPass2;"
		"RenderColorTarget0=ReflectionWorkMap;	Pass=RLRBlurXPass;"
		"RenderColorTarget0=PPPReflectionMap;	Pass=RLRBlurYPass;"
		#else
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
	#if !defined(USE_STATIC_ENV)
	pass SynthEnvPass < string Script= "Draw=Buffer;"; > {
		BufferRenderStates
		VertexShader = compile vs_3_0 VS_Common();
		PixelShader  = compile ps_3_0 PS_SynthEnv();
	}
	#endif

	/////////////////////////////////////////////////////////////////
	// Shadow map

	pass ShadowBlurPassX < string Script= "Draw=Buffer;"; > {
		BufferRenderStates
		VertexShader = compile vs_3_0 VS_Common();
		PixelShader  = compile ps_3_0 PS_BlurShadow(ShadowSamp, true, true);
	}
	pass ShadowBlurPassY < string Script= "Draw=Buffer;"; > {
		BufferRenderStates
		VertexShader = compile vs_3_0 VS_Common();
		PixelShader  = compile ps_3_0 PS_BlurShadow(ReflectionWorkMapSamp, false, false);
	}

	/////////////////////////////////////////////////////////////////
	// 

	#if SSAORayCount > 0
	pass SSAOPass < string Script= "Draw=Buffer;"; > {
		BufferRenderStates
		VertexShader = compile vs_3_0 VS_Common();
		PixelShader  = compile ps_3_0 PS_SSAO();
	}

	pass BlurXSSAOPass < string Script= "Draw=Buffer;"; > {
		BufferRenderStates
		VertexShader = compile vs_3_0 VS_Common();
		PixelShader  = compile ps_3_0 PS_BlurSSAO(true, SSAOWorkMapSamp);
	}
	pass BlurYSSAOPass < string Script= "Draw=Buffer;"; > {
		BufferRenderStates
		VertexShader = compile vs_3_0 VS_Common();
		PixelShader  = compile ps_3_0 PS_BlurSSAO(false, ReflectionWorkMapSamp);
	}
	#endif

	#if defined(RSMCount) && RSMCount > 0
	pass CalcRSMPass < string Script= "Draw=Buffer;"; > {
		BufferRenderStates
		VertexShader = compile vs_3_0 VS_Common();
		PixelShader  = compile ps_3_0 PS_CalcRSM();
	}
	pass RSMBlurXPass < string Script= "Draw=Buffer;"; > {
		BufferRenderStates
		VertexShader = compile vs_3_0 VS_Common();
		PixelShader  = compile ps_3_0 PS_BlurSSAO(true, RSMWorkLinear);
	}
	pass RSMBlurYPass < string Script= "Draw=Buffer;"; > {
		BufferRenderStates
		VertexShader = compile vs_3_0 VS_Common();
		PixelShader  = compile ps_3_0 PS_BlurSSAO(false, ReflectionWorkMapSamp);
	}
	#endif

	pass SSAOEnvPass < string Script= "Draw=Buffer;"; > {
		BufferRenderStates
		VertexShader = compile vs_3_0 VS_Common();
		PixelShader  = compile ps_3_0 PS_SSAOEnv();
	}
	#if SSSBlurCount > 0
	pass SSSBlurXPass < string Script= "Draw=Buffer;"; > {
		BufferRenderStates
		VertexShader = compile vs_3_0 VS_Common();
		PixelShader  = compile ps_3_0 PS_BlurSSS1(ReflectionMapSamp);
	}
	pass SSSBlurYPass < string Script= "Draw=Buffer;"; > {
		BufferRenderStates
		VertexShader = compile vs_3_0 VS_Common();
		PixelShader  = compile ps_3_0 PS_BlurSSS2(ReflectionWorkMapSamp);
	}
	#endif

	/////////////////////////////////////////////////////////////////
	// 

	#if RLRRayCount > 0
	pass RLRPass < string Script= "Draw=Buffer;"; > {
		BufferRenderStates
		VertexShader = compile vs_3_0 VS_Common();
		PixelShader  = compile ps_3_0 PS_RLR();
	}
	pass RLRPass2 < string Script= "Draw=Buffer;"; > {
		BufferRenderStates
		VertexShader = compile vs_3_0 VS_Common();
		PixelShader  = compile ps_3_0 PS_RLR2();
	}
	pass RLRBlurXPass < string Script= "Draw=Buffer;"; > {
		BufferRenderStates
		VertexShader = compile vs_3_0 VS_Common();
		PixelShader  = compile ps_3_0 PS_BlurRLR(true, ReflectionMapSamp);
	}
	pass RLRBlurYPass < string Script= "Draw=Buffer;"; > {
		BufferRenderStates
		VertexShader = compile vs_3_0 VS_Common();
		PixelShader  = compile ps_3_0 PS_BlurRLR(false, ReflectionWorkMapSamp);
	}
	#else
	pass WriteEnvPass < string Script= "Draw=Buffer;"; > {
		BufferRenderStates
		VertexShader = compile vs_3_0 VS_Common();
		PixelShader  = compile ps_3_0 PS_WriteEnvAsReflection();
	}
	#endif

	/////////////////////////////////////////////////////////////////
	// 

	pass DrawPass < string Script= "Draw=Buffer;"; > {
		BufferRenderStates
		VertexShader = compile vs_3_0 VS_Common();
		PixelShader  = compile ps_3_0 PS_Draw();
	}

	#if defined(ENABLE_AA) && ENABLE_AA > 0
	pass AntialiasPass < string Script= "Draw=Buffer;"; > {
		BufferRenderStates
		VertexShader = compile vs_3_0 VS_Common();
		PixelShader  = compile ps_3_0 PS_Antialias(RENDERTARGET_ANTIALIAS_SAMPLER);
	}
	#endif
}

////////////////////////////////////////////////////////////////////////////////////////////////
