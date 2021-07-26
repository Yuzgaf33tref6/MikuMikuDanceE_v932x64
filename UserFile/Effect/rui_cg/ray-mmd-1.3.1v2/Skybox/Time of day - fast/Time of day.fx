#include "shader/math.fxsub"
#include "shader/common.fxsub"
#include "shader/phase.fxsub"
#include "shader/atmospheric.fxsub"

static const float3 sunScaling = 2000;
static const float3 sunTranslate = 80000;

static const float3 moonScaling = 2000;
static const float3 moonTranslate = -float3(10000, -5000,10000);

static const float3 jupiterScaling = 4000;
static const float3 jupiterTranslate = float3(10000, 5000, 10000);

texture MoonMap<string ResourceName = "Shader/Textures/moon.jpg";>;
sampler MoonMapSamp = sampler_state
{
	texture = <MoonMap>;
	MINFILTER = LINEAR; MAGFILTER = LINEAR; MIPFILTER = LINEAR;
	ADDRESSU = WRAP; ADDRESSV = WRAP;
};
texture JupiterMap<string ResourceName = "Shader/Textures/jupiter.jpg";>;
sampler JupiterMapSamp = sampler_state
{
	texture = <JupiterMap>;
	MINFILTER = LINEAR; MAGFILTER = LINEAR; MIPFILTER = LINEAR;
	ADDRESSU = WRAP; ADDRESSV = WRAP;
};
texture SunMap<string ResourceName = "Shader/Textures/realsun.jpg";>;
sampler SunMapSamp = sampler_state
{
	texture = <SunMap>;
	MINFILTER = LINEAR; MAGFILTER = LINEAR; MIPFILTER = LINEAR;
	ADDRESSU = WRAP; ADDRESSV = WRAP;
};

void SphereVS(
	in float4 Position : POSITION,
	in float4 Texcoord : TEXCOORD0,
	out float4 oTexcoord0 : TEXCOORD0,
	out float4 oTexcoord1 : TEXCOORD1,
	out float3 oTexcoord2 : TEXCOORD2,
	out float4 oPosition : POSITION,
	uniform float3 translate, uniform float3 scale)
{
	oTexcoord0 = Texcoord;
	oTexcoord1 = normalize(Position);
	oPosition = mul(float4(oTexcoord1.xyz * scale + translate, 1), matViewProject);
}

float4 SpherePS(
	in float2 coord : TEXCOORD0,
	in float3 normal : TEXCOORD1,
	uniform sampler source) : COLOR
{
	float4 diffuse = tex2D(source, coord + float2(time / 200, 0));
	diffuse.rgb *= saturate(dot(normal, -LightDirection) + 0.15);
	return diffuse;
}

void SunVS(
	in float4 Position : POSITION,
	in float4 Texcoord : TEXCOORD0,
	out float4 oTexcoord0 : TEXCOORD0,
	out float4 oTexcoord1 : TEXCOORD1,
	out float4 oTexcoord2 : TEXCOORD2,
	out float4 oPosition : POSITION,
	uniform float3 translate, uniform float3 scale)
{
	float3 sunDirection = normalize(-LightDirection);

	oTexcoord0 = Texcoord;
	oTexcoord1 = float4(normalize(Position.xyz), 1);
	oTexcoord2 = float4(oTexcoord1.xyz * scale * mSunRadius + sunDirection * translate, 1);
	oPosition = mul(oTexcoord2, matViewProject);
}

float4 SunPS(
	in float2 coord : TEXCOORD0,
	in float3 normal : TEXCOORD1,
	in float3 viewdir : TEXCOORD2,
	uniform sampler source) : COLOR
{
	float3 V = normalize(viewdir - CameraPosition);
	float4 diffuse = tex2D(source, coord);
	diffuse *= diffuse;
	diffuse *= saturate(dot(normalize(normal), -LightDirection) + 0.1) * 1.5;
	diffuse *= (1 - mSunRadianceM) * (step(0, V.y) + exp2(-abs(V.y) * 100));
	return diffuse;
}

void ScatteringVS(
	in float4 Position   : POSITION,
	out float4 oTexcoord0 : TEXCOORD0,
	out float3 oTexcoord1 : TEXCOORD1,
	out float3 oTexcoord2 : TEXCOORD2,
	out float4 oPosition : POSITION)
{
	oTexcoord0 = normalize(Position);
	oTexcoord1 = ComputeWaveLengthMie(mWaveLength, mMieColor, mMieTurbidity, 4);
	oTexcoord2 = ComputeWaveLengthRayleigh(mWaveLength) * mFogColor;
	oPosition = mul(Position + float4(CameraPosition, 0), matViewProject);
}

float4 ScatteringPS(
	in float3 viewdir : TEXCOORD0,
	in float3 mieLambda : TEXCOORD1,
	in float3 rayleight : TEXCOORD2) : COLOR
{
	float3 V = normalize(viewdir);

	float scaling = 1000;

	ScatteringParams setting;
	setting.sunRadiance = mSunRadiance;
	setting.mieG = mMiePhase;
	setting.mieHeight = mMieHeight * scaling;
	setting.rayleighHeight = mRayleighHeight * scaling;
	setting.earthRadius = 6360 * scaling;
	setting.earthAtmTopRadius = 6380 * scaling;
	setting.earthCenter = float3(0, -setting.earthRadius, 0);
	setting.waveLambdaMie = mieLambda;
	setting.waveLambdaRayleigh = rayleight;

	float4 insctrColor = ComputeSkyInscattering(setting, CameraPosition + float3(0, scaling, 0), V, LightDirection);

	return linear2srgb(insctrColor);
}

const float4 BackColor = 0.0;

#define OBJECT_TEC(name, mmdpass) \
	technique name<string MMDPass = mmdpass;\
		string Script =\
		"RenderColorTarget=;"\
		"ClearSetColor=BackColor;"\
		"Clear=Color;"\
		"Pass=DrawJupiter;"\
		"Pass=DrawMoon;"\
		"Pass=DrawSun;"\
		"Pass=DrawScattering;";\
	>{\
		pass DrawJupiter {\
			AlphaBlendEnable = false; AlphaTestEnable = false;\
			ZEnable = false; ZWriteEnable = false;\
			VertexShader = compile vs_3_0 SphereVS(jupiterTranslate, jupiterScaling);\
			PixelShader  = compile ps_3_0 SpherePS(JupiterMapSamp);\
		}\
		pass DrawMoon {\
			AlphaBlendEnable = false; AlphaTestEnable = false;\
			ZEnable = false; ZWriteEnable = false;\
			VertexShader = compile vs_3_0 SphereVS(moonTranslate, moonScaling);\
			PixelShader  = compile ps_3_0 SpherePS(MoonMapSamp);\
		}\
		pass DrawSun {\
			AlphaBlendEnable = true; AlphaTestEnable = false;\
			ZEnable = false; ZWriteEnable = false;\
			SrcBlend = ONE; DestBlend = INVSRCALPHA;\
			VertexShader = compile vs_3_0 SunVS(sunTranslate, sunScaling);\
			PixelShader  = compile ps_3_0 SunPS(SunMapSamp);\
		}\
		pass DrawScattering {\
			AlphaBlendEnable = true; AlphaTestEnable = false;\
			ZEnable = false; ZWriteEnable = false;\
			SrcBlend = ONE; DestBlend = SRCALPHA;\
			VertexShader = compile vs_3_0 ScatteringVS();\
			PixelShader  = compile ps_3_0 ScatteringPS();\
		}\
	}

OBJECT_TEC(MainTec0, "object")
OBJECT_TEC(MainTecBS0, "object_ss")

technique EdgeTec<string MMDPass = "edge";>{}
technique ShadowTec<string MMDPass = "shadow";>{}
technique ZplotTec<string MMDPass = "zplot";>{}