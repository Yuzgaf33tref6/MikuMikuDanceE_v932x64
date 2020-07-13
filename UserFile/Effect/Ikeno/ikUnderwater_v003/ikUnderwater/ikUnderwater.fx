////////////////////////////////////////////////////////////////////////////////////////////////
//
//
////////////////////////////////////////////////////////////////////////////////////////////////

#include "Settings.fxsub"
#include "Commons.fxsub"

////////////////////////////////////////////////////////////////////////////////////////////////

float mGodrayIntensity : CONTROLOBJECT < string name = CTRL_NAME; string item = "�S�b�h���C���x"; >;
float mCausticsIntensity : CONTROLOBJECT < string name = CTRL_NAME; string item = "�R�[�X�e�B�N�X���x"; >;
float mSpecularIntensity : CONTROLOBJECT < string name = CTRL_NAME; string item = "�X�y�L�������x"; >;

float mWaveFreq : CONTROLOBJECT < string name = CTRL_NAME; string item = "�g�̖��x"; >;
float mWaveSpeed : CONTROLOBJECT < string name = CTRL_NAME; string item = "�g�̑��x"; >;
float mWaveHeight : CONTROLOBJECT < string name = CTRL_NAME; string item = "�g��"; >;

float mLightR : CONTROLOBJECT < string name = CTRL_NAME; string item = "���C�gR"; >;
float mLightG : CONTROLOBJECT < string name = CTRL_NAME; string item = "���C�gG"; >;
float mLightB : CONTROLOBJECT < string name = CTRL_NAME; string item = "���C�gB"; >;

float ftime : TIME <bool SyncInEditMode=false;>;

static float GodrayIntensity = CalcVariable(GodrayIntensityMin, GodrayIntensityMax, mGodrayIntensity, GodrayIntensityDefault) * EffectAmount;
static float CausticsIntensity = CalcVariable(CausticsIntensityMin, CausticsIntensityMax, mCausticsIntensity, CausticsIntensityDefault) * EffectAmount;
static float SpecularIntensity = CalcVariable(SpecularIntensityMin, SpecularIntensityMax, mSpecularIntensity, SpecularIntensityDefault) * EffectAmount;



static float WaveFreq = CalcVariable(WaveFreqMin, WaveFreqMax, mWaveFreq, WaveFreqDefault);
static float WaveSpeed = ftime * CalcVariable(WaveSpeedMin, WaveSpeedMax, mWaveSpeed, WaveSpeedDefault);
static float WaveHeight = CalcVariable(WaveHeightMin, WaveHeightMax, mWaveHeight, WaveHeightDefault);

#define CalcLightRate(a)	(a * a * 2.0)
static float3 LightRate = float3( CalcLightRate(mLightR), CalcLightRate(mLightG), CalcLightRate(mLightB));


////////////////////////////////////////////////////////////////////////////////////////////////

texture LightSpaceDepth: OFFSCREENRENDERTARGET <
	string Description = "���C�g����I�u�W�F�N�g�ւ̋��� for ikUW";
	string Format = SHADOW_TEXFORMAT;
	float Width = SHADOW_BUFSIZE;
	float Height = SHADOW_BUFSIZE;
	float4 ClearColor = { 1.0, 0, 0, 0 };
	float ClearDepth = 1.0;
	bool AntiAlias = false; //�A���`�G�C���A�X�ݒ�
	string DefaultEffect = 
		"self = hide;"
		CTRL_NAME " = hide;"
		"* = ShadowBuffer.fx;" 
	;
>;

sampler LightDepthSamp = sampler_state {
	texture = <LightSpaceDepth>;
	AddressU = CLAMP; AddressV = CLAMP;
	MinFilter = LINEAR;	MagFilter = LINEAR;	MipFilter = LINEAR;
};

texture CameraSpaceDepth: OFFSCREENRENDERTARGET <
	string Description = "�J��������I�u�W�F�N�g�ւ̋��� for ikUW";
	float2 ViewportRatio = {1,1};
	float4 ClearColor = {1.0, 0, 0, 1};
	float ClearDepth = 1.0;
	string Format = DEPTH_TEXFORMAT;
	bool AntiAlias = false;
	string DefaultEffect = 
		"self = hide;"
		CTRL_NAME " = hide;"
		"* = LinearDepth.fx";
>;

sampler DepthSamp = sampler_state {
	texture = <CameraSpaceDepth>;
	AddressU = CLAMP; AddressV = CLAMP;
	MinFilter = LINEAR;	MagFilter = LINEAR;	MipFilter = LINEAR;
};

#if ENABLE_WATERPLANE > 0
texture ReflectionMap : OFFSCREENRENDERTARGET <
	string Description = "���ʂɔ��˂�����̂�`�� for ikUW";
	float2 ViewPortRatio = {1.0/REFLECTION_BUFFER_SCALE,1.0/REFLECTION_BUFFER_SCALE};
	float4 ClearColor = { 0, 0, 0, 0 };
	float ClearDepth = 1.0;
	string Format = SCREEN_TEXFORMAT;
	bool AntiAlias = true;
	string DefaultEffect = 
		"self = hide;"
		CTRL_NAME " = hide;"
		"* = Reflection.fx;" ;
>;
sampler ReflectionSamp = sampler_state {
	texture = <ReflectionMap>;
	MinFilter = LINEAR; MagFilter = LINEAR;
	AddressU  = CLAMP; AddressV = CLAMP;
};

#if ENABLE_REFRACTION_MAP > 0
texture RefractionMap : OFFSCREENRENDERTARGET <
	string Description = "���ʂŋ��܂�����̂�`�� for ikUW";
	float2 ViewPortRatio = {1.0/REFLECTION_BUFFER_SCALE,1.0/REFLECTION_BUFFER_SCALE};
	float4 ClearColor = { 0, 0, 0, 0 };
	float ClearDepth = 1.0;
	string Format = SCREEN_TEXFORMAT;
	bool AntiAlias = true;
	string DefaultEffect = 
		"self = hide;"
		CTRL_NAME " = hide;"
		"* = Refraction.fx;" ;
>;
sampler RefractionSamp = sampler_state {
	texture = <RefractionMap>;
	MinFilter = LINEAR; MagFilter = LINEAR;
	AddressU  = CLAMP; AddressV = CLAMP;
};

#endif
#endif

////////////////////////////////////////////////////////////////////////////////////////////////

float Script : STANDARDSGLOBAL <
	string ScriptOutput = "color";
	string ScriptClass = "scene";
	string ScriptOrder = "postprocess";
> = 0.8;

// �X�N���[���T�C�Y
float2 ViewportSize : VIEWPORTPIXELSIZE;

static float2 ViewportOffset = (float2(0.5,0.5)/ViewportSize);
static float2 RefViewportOffset = (float2(0.5,0.5) * REFLECTION_BUFFER_SCALE / ViewportSize);
static float2 BlurStepFog = (float2(1.0,1.0) * FOG_BUFFER_SCALE / ViewportSize);
static float2 BlurStepDistortion = (float2(1.0,1.0) * DISTORTION_BUFFER_SCALE / ViewportSize);

float4x4 matVP			: VIEWPROJECTION;

float4x4 matInvVP		: VIEWPROJECTIONINVERSE;
#define SKII1	1500

inline float2 Calc2DPos(float3 dir, float4x4 mat)
{
	float4 PPos = mul(float4(dir,1), mat);
	return PPos.xy / PPos.w * float2(0.5, -0.5) + 0.5;
}

static float2 WaveLightPPos = Calc2DPos(WaveLightPosition, matVP);
const float waterIndex = 1.33;
static float IndexOfRefarctin = IsInWater ? waterIndex : (1.0/waterIndex);

// �����_�����O�^�[�Q�b�g�̃N���A�l
float4 ClearColor = {0,0,0,0};
float ClearDepth  = 1.0;


// �ڂ��������̏d�݌W���F
float WT[] = {
	0.0920246,
	0.0902024,
	0.0849494,
	0.0768654,
	0.0668236,
	0.0558158,
	0.0447932,
	0.0345379,
};

static const float WT4[] = {
	0.20799541,
	0.18612246,
	0.13336258,
	0.07651724,
};


float RayMarchOffsets[16] = {
	 6/16.0, 1/16.0,12/16.0,11/16.0,
	 9/16.0,14/16.0, 5/16.0, 2/16.0,
	 0/16.0, 7/16.0,10/16.0,13/16.0,
	15/16.0, 8/16.0, 3/16.0, 4/16.0,
};

texture2D ScnMap : RENDERCOLORTARGET <
	int MipLevels = 1;
	// bool AntiAlias = true;
	string Format = SCREEN_TEXFORMAT;
>;
sampler2D ScnSamp = sampler_state {
	texture = <ScnMap>;
	MinFilter = LINEAR;
	MagFilter = LINEAR;
	MipFilter = LINEAR;
	AddressU  = CLAMP;
	AddressV = CLAMP;
};

texture2D DepthBuffer : RENDERDEPTHSTENCILTARGET <
	string Format = "D24S8";
>;


#if ENABLE_GODRAY > 0
#define FOG_VIEWPORT_RATIO	{1.0/FOG_BUFFER_SCALE, 1.0/FOG_BUFFER_SCALE}
#define FOGTEX_ATTR \
		MinFilter = LINEAR; MagFilter = LINEAR; MipFilter = LINEAR; \
		AddressU = BORDER; AddressV = BORDER; BorderColor = float4(0,0,0,1);

texture2D FogDensityMap : RENDERCOLORTARGET <
	float2 ViewportRatio = FOG_VIEWPORT_RATIO;
	string Format = FOG_TEXFORMAT;
>;
sampler2D FogDensitySamp = sampler_state {
	texture = <FogDensityMap>;
	FOGTEX_ATTR
};

texture2D FogDensityMap2 : RENDERCOLORTARGET <
	float2 ViewportRatio = FOG_VIEWPORT_RATIO;
	string Format = FOG_TEXFORMAT;
>;
sampler2D FogDensitySamp2 = sampler_state {
	texture = <FogDensityMap2>;
	FOGTEX_ATTR
};
#endif

texture CausticsMap: RENDERCOLORTARGET <
	float Width = CAUSTICS_BUFSIZE;
	float Height = CAUSTICS_BUFSIZE;
	string Format = "L8";
>;

texture CausticsMapDepth : RENDERDEPTHSTENCILTARGET <
	float Width = CAUSTICS_BUFSIZE;
	float Height = CAUSTICS_BUFSIZE;
	string Format = "D24S8";
>;

sampler CausticsSamp = sampler_state {
	texture = <CausticsMap>;
	MinFilter = LINEAR; MagFilter = LINEAR; MipFilter = LINEAR;
	AddressU  = CLAMP; AddressV = CLAMP;
};

#if ENABLE_WATERPLANE > 0
#define DISTORTION_VIEWPORT_RATIO	{1.0/DISTORTION_BUFFER_SCALE, 1.0/DISTORTION_BUFFER_SCALE}
texture2D DistortionMap : RENDERCOLORTARGET <
	float2 ViewportRatio = DISTORTION_VIEWPORT_RATIO;
	string Format = "A8R8G8B8";
>;
sampler2D DistortionSamp = sampler_state {
	texture = <DistortionMap>;
	MinFilter = LINEAR; MagFilter = LINEAR; MipFilter = LINEAR;
	AddressU  = CLAMP; AddressV = CLAMP;
};
texture2D DistortionMap2 : RENDERCOLORTARGET <
	float2 ViewportRatio = DISTORTION_VIEWPORT_RATIO;
	string Format = "A8R8G8B8";
>;
sampler2D DistortionSamp2 = sampler_state {
	texture = <DistortionMap2>;
	MinFilter = LINEAR; MagFilter = LINEAR; MipFilter = LINEAR;
	AddressU  = CLAMP; AddressV = CLAMP;
};

#if ENABLE_REFRACTION_EFFECT > 0
texture RefractionMap2 : RENDERCOLORTARGET <
	float2 ViewPortRatio = {1.0/REFLECTION_BUFFER_SCALE,1.0/REFLECTION_BUFFER_SCALE};
	string Format = SCREEN_TEXFORMAT;
>;
sampler RefractionSamp2 = sampler_state {
	texture = <RefractionMap2>;
	MinFilter = LINEAR; MagFilter = LINEAR;
	AddressU  = CLAMP; AddressV = CLAMP;
};
#endif
#endif


//-----------------------------------------------------------------------------
// 

const float gamma = 2.2;
inline float3 Degamma(float3 col) { return pow(max(col,0), gamma); }
inline float3 Gamma(float3 col) { return pow(max(col,0), 1.0/gamma); }
inline float4 Degamma4(float4 col) { return float4(Degamma(col.rgb), col.a); }
inline float4 Gamma4(float4 col) { return float4(Gamma(col.rgb), col.a); }


// ���ʂ̍������v���V�[�W�����Ɍv�Z����
#include "wave.fxsub"

inline float CalcCaustics(float2 pos)
{
	float c = map(float3(pos.x, 0, pos.y));
	return pow(c, CausticsStroke);
}

inline float3 CalcNormal(float3 pos)
{
	float e = 0.01 * (IsInWater ? -1 : 1);
	float y = map(pos);
	float3 n = float3(y - map(pos + float3(e,0,0)), e, y - map(pos + float3(0,0,e)));
	n.xz *= WaveHeight;
	return normalize(n);
}

inline float3 GetWorldV(float2 uv)
{
	float2 PPos = (uv - 0.5) * float2(2.0, -2.0);
	return normalize(mul(float4(PPos.xy, 1, 1), matInvVP).xyz);
}

inline float CalcWaterTichkness(float depth, float3 pos, float3 v)
{
	float t = DistanceToWater(pos, v);
	float thickness = IsInWater
		? (t > 0.0 ? min(depth, t) : depth)		// �J����������
		: (t > 0.0 ? max(depth-t, 0) : 0);	// �J����������

	return thickness;
}

inline float GetDepth(float2 uv)
{
	return tex2D(DepthSamp, uv).x * FAR_Z;
}

// �����Ɖ~���Ƃ̂����悻�̌�_���v�Z
// ���Ȃ炸�~���̒��S��ʂ�Ɖ���B���ۂ��O���𐄒�l�Ƃ��ĕԂ��B
// ���C�}�[�`�͈̔͂����肵�Ȃ��ƁA�S�b�h���C�̐��x���ۂĂȂ��B
float2 EstimateLineConeIntersection(float3 ray)
{
	float4 vpos = mul(float4(CameraPosition, 1), matWaveV);
	float3 vray = mul(ray, (float3x3)matWaveV);

	float2 p = float2(length(vpos.xy), vpos.z);
	float2 v = float2(dot(vpos.xy/p.x, vray.xy), vray.z);
	float2 h = float2(sin(WaveLightRad), cos(WaveLightRad));

	// t00 = cross(h,-p) / cross(h,v);
	float t00 = max((-h.x * p.y + h.y * p.x) / ( h.x * v.y - h.y * v.x), 0);
	float t01 = max(( h.x * p.y + h.y * p.x) / (-h.x * v.y - h.y * v.x), 0);

	// �����̕��̗̈�ƌ������Ă���Ȃ��_�Ȃ�
	t00 *= (p.y + v.y * t00 > 0.0);
	t01 *= (p.y + v.y * t01 > 0.0);

	float t0 = min(t00, t01);
	float t1 = max(t00, t01);

	// �n�_���R�[���̒�?
	bool isInCone = (abs(normalize(p).x) < h.x && vpos.z > 0);
	if (isInCone)
	{
		// ��_����R�[���O�ɏo�� or �R�[��������o�Ȃ��B
		t1 = (t1 > 0.0) ? t1 : MaxRayDistance;
	}
	else if (t0 <= 0.0 && t1 > 0.0)
	{
		// 1�_�̂݌��� = �R�[���O����R�[�����ɐi�����āA�R�[������o�Ȃ��B
		t0 = t1;
		t1 = MaxRayDistance;
	}

	return float2(t0, t1);
}

inline float CalcShadowRate(float2 uv, float depth)
{
	float z = tex2Dlod(LightDepthSamp, float4(uv,0,0)).r;
	return 1 - saturate(max(depth - z, 0.0f) * SKII1 - 0.3f);
}

inline float CalcShadow(float4 zcalc)
{
	zcalc /= zcalc.w;
	float2 TexCoord = float2(1.0f + zcalc.x, 1.0f - zcalc.y) * 0.5;
	float comp = CalcShadowRate(TexCoord, zcalc.z);

	// �ΐ��ɂ��}�X�N
	comp *= tex2Dlod(CausticsSamp, float4(TexCoord,0,0)).r;
		// ��ɃV���h�E�}�b�v�ƌ�������΁A1��̃t�F�b�`�Ŏ擾�ł���?

	// �V���h�E�o�b�t�@�O?
	comp *= ( !any( saturate(TexCoord) != TexCoord ) );

	return comp;
}

// �A���`�G�C���A�X�t���̃V���h�E�}�b�v�ŎՕ��x���v�Z����
inline float CalcShadowDetail(float4 zcalc)
{
	zcalc /= zcalc.w;
	float2 TexCoord = float2(1.0f + zcalc.x, 1.0f - zcalc.y) * 0.5;

	float comp = CalcShadowRate(TexCoord, zcalc.z);

	const float s = 1.0/SHADOW_BUFSIZE;
	comp += CalcShadowRate(TexCoord + float2(-1.5, 0.5) * s, zcalc.z);
	comp += CalcShadowRate(TexCoord + float2( 0.5, 0.5) * s, zcalc.z);
	comp += CalcShadowRate(TexCoord + float2(-1.5,-1.5) * s, zcalc.z);
	comp += CalcShadowRate(TexCoord + float2( 0.5,-1.5) * s, zcalc.z);
	comp *= (1.0 / 5.0);

	// �ΐ��ɂ��}�X�N
	comp *= tex2Dlod(CausticsSamp, float4(TexCoord,0,0)).r;
		// �V���h�E�}�b�v�ƌ�������΁A1��Ŏ擾�ł���?

	// �V���h�E�o�b�t�@�O?
	comp *= ( !any( saturate(TexCoord) != TexCoord ) );

	return comp;
}

inline float GetJitter(float2 uv)
{
	float2 ppos = floor(uv * (ViewportSize / FOG_BUFFER_SCALE));
	int index = (int)(fmod(ppos.x,4)*4 + fmod(ppos.y,4));
	return RayMarchOffsets[index];
}

inline float CalcFresnel(float NV, float F0)
{
	return F0 + (1.0 - F0) * pow(1 - NV, 5);
}

float CalcSpecular(float3 L, float3 N, float3 V)
{
	float3 H = normalize(L + V);

	float a = 0.1;
	float aSq = a * a;
	float NV = saturate(dot(N, V));
	float NH = saturate(dot(N, H));
	float NL = saturate(dot(N, L));
	float LH = saturate(dot(L, H));

	float CosSq = (NH * NH) * (aSq - 1) + 1;
	float D = aSq / (PI * CosSq * CosSq);

	float F = CalcFresnel(NV, 0.05);

	float k = a * 0.5;
	float k2 = k * k;
	float vis = 1.0 / (LH * LH * (1 - k2) + k2);

	return saturate(NL * D * F * vis);
}

float3 CalcCausticsColor(float3 v, float2 depth_light)
{
	float depth = depth_light.x * FAR_Z;
	float light = depth_light.y;

	float4 floorWPos = float4(CameraPosition + v * depth, 1);
	float4 floorPPos = mul(floorWPos, matWaveVP);
//	float caustics = CalcShadow(floorPPos) * light;
	float caustics = CalcShadowDetail(floorPPos) * light;

	caustics *= (WaveObjectPosition.y > floorWPos.y);
		// ����ɉΐ����\�������̂�h��

	return (1.0 - exp(-caustics * LightRate)) * CausticsIntensity;
}


////////////////////////////////////////////////////////////////////////////////////////////////
//

struct VS_OUTPUT
{
	float4 Pos			: POSITION;
	float2 TexCoord		: TEXCOORD0;
};

VS_OUTPUT VS_SetTexCoord( float4 Pos : POSITION, float4 Tex : TEXCOORD0, uniform float level)
{
	VS_OUTPUT Out = (VS_OUTPUT)0; 

	Out.Pos = Pos;
	Out.TexCoord = Tex.xy + level * ViewportOffset.xy;
	return Out;
}


//-----------------------------------------------------------------------------
// ���ʂ̃A�j���[�V������`��B
float4 PS_DrawWaterPlane( float4 Tex: TEXCOORD0 ) : COLOR
{
	float2 PPos = (Tex.xy - 0.5) * float2(2.0, -2.0);
	float3 v = normalize(mul(float4(PPos.xy, 1, 1), matWaveInvVP).xyz);

	float t = DistanceToWater(WaveLightPosition, v);
	float2 uv = WaveLightPosition.xz + v.xz * t;

	float c = CalcCaustics(uv);
	float rim = saturate(10 - length(PPos) * 10);

	return float4(c * rim, 0, 0, 1);
}


//-----------------------------------------------------------------------------
//

#if ENABLE_GODRAY > 0
float4 PS_RayMarch( float4 Tex: TEXCOORD0 ) : COLOR
{
	float3 V = GetWorldV(Tex.xy);

	// ���������f���ƌ������鋗��
	float depth = min(tex2D(DepthSamp, Tex.xy).r * FAR_Z, MaxRayDistance);
	// ���������ʂƌ������鋗��
	float t = DistanceToWater(CameraPosition, V);
	// �����ƃ��C�g�Ƃ̂����悻�̌�_
	float2 intersection = EstimateLineConeIntersection(V);

	// �T���J�n�ʒu�ƏI���ʒu�����߂�
	float t0 = intersection.x;
	float t1 = min(depth, intersection.y);
	if (IsInWater)
	{	// �J����������
		// �r���Ő��ʂƌ�������Ȃ炻���őł��؂�
		t1 = (t > 0 ? min(t1, t) : t1);
	}
	else
	{	// �J����������
		t0 = max(t, t0) * (t > 0);
		t1 *= (t > 0);
	}

	float sampleStep = (t1-t0) * (1.0 / (RayMarchCount + 3.0));

	float4 v = float4(V * sampleStep, 0);
	float4 p = float4(CameraPosition + V * t0 + v.xyz * (GetJitter(Tex.xy)), 1);
	float4 zcalcB = mul(p, matWaveVP);
	float4 zcalcE = mul(p + v * RayMarchCount, matWaveVP);
	float exp0 = t0 * FogAmount;
	float expV = (t1-t0) * FogAmount / RayMarchCount;

	float fog = 0;
	/*[unroll]*/ for(int i = 1; i <= RayMarchCount; i++)
	{
		float4 zcalc = lerp(zcalcB, zcalcE, i * (1.0 / RayMarchCount));
		float outColor = exp(-(exp0 + expV * i));
		fog += CalcShadow(zcalc) * outColor;
	}

	return float4(fog * sampleStep, 0, 0, 1);
}
#endif


#if ENABLE_WATERPLANE > 0
#if ENABLE_REFRACTION_EFFECT > 0
//-----------------------------------------------------------------------------
// ���ォ�猩�������ɃG�t�F�N�g��K�p����
float4 PS_DrawRefractionPlane( float4 Tex: TEXCOORD0 ) : COLOR
{
	#if ENABLE_REFRACTION_MAP > 0
	float4 rfrColor = tex2D(RefractionSamp, Tex.xy);
	clip(rfrColor.a - 1/1024.0);

	float2 uv = ((Tex.xy) * 2.0 - 1.0) * (0.5 / FrameScale) + 0.5;
	#else
	float4 rfrColor = tex2D(ScnSamp, Tex.xy);
	float2 uv = Tex.xy;
	#endif

	float3 Color = Degamma(rfrColor.rgb);

	float3 v = GetWorldV(uv);
	float t = DistanceToWater(CameraPosition, v);

	// �ΐ�
	float2 dn = tex2D(DepthSamp, uv).xy;
	float depth = dn.x * FAR_Z;
	Color += CalcCausticsColor(v, dn);

	// �����t�H�O
	float thickness = CalcWaterTichkness(depth, CameraPosition, v);
	Color = CalcFogColor(Color, thickness);

	#if ENABLE_GODRAY > 0
	// �S�b�h���C
	float godray = tex2D( FogDensitySamp, uv).r;
	float3 GodrayColor = (1.0 - exp(-godray * LightRate));
	Color += GodrayColor * GodrayIntensity * godray;
	#endif

	// �[�x�t�H�O
	Color *= CalcDepthFog(v, thickness);

	return float4(Gamma(Color), rfrColor.a);
}
#endif

//-----------------------------------------------------------------------------
// ���ʂ̂䂪�݂�`��
float4 PS_DrawDistortion( float4 Tex: TEXCOORD0 ) : COLOR
{
	float3 v = GetWorldV(Tex.xy);
	float depth = GetDepth(Tex.xy);
	float t = DistanceToWater(CameraPosition, v);

	float alpha = 1;
	// t<0�Ȃ琅�ʂɌ������Ȃ��̂Ń}�X�N
	alpha *= (t > 0.0);
	// ���ʂ���O�ɉ���������Ȃ�}�X�N + ���ʂƉ��s�����߂��قǘc�ȗ���������
	alpha *= min((depth - t) / 100.0, 1);
	// ���ʂłȂ��Ȃ�ł��؂�
	clip(alpha - 1e-6);

	bool isValid = (alpha > 0.0);

	// �J�������牓���قǔ����Ȃ�
	alpha = alpha * saturate(100.0/(1+t));
	// ���ʂɐ����Ȃقǘc�ȗ���������
	alpha *= saturate(pow(abs(v.y) * 2.0, 2));

	float3 WPos = CameraPosition + v * t;
	float3 N = CalcNormal(WPos);
	// �����قǖ@����^�������ɂ���
	N.y += (pow(t/100.0,3)) * sign(N.y);
	N = normalize(N);
	float3 E = -v;
	float3 L = -WaveLightDirection;

	// ����
	float4 rflPPos = mul(float4(CameraPosition + v * depth + N * alpha, 1), matVP);
	float2 rflUV = (-rflPPos.xy / rflPPos.w) * (0.5 * FrameScale) + 0.5;
	float4 rflColor = tex2D(ReflectionSamp, rflUV);

	// ����
	float3 rfr = refract(E, N, IndexOfRefarctin);
	bool totalReflection = (length(rfr) <= 1e-4);

	float4 rfrPPos = mul(float4(WPos + rfr * alpha, 1), matVP);
	#if ENABLE_REFRACTION_MAP > 0
		float2 rfrUV = float2(rfrPPos.x, -rfrPPos.y) * (0.5 * FrameScale / rfrPPos.w) + 0.5;
		#if ENABLE_REFRACTION_EFFECT > 0
		float4 rfrColor = tex2D(RefractionSamp2, rfrUV);
		#else
		float4 rfrColor = tex2D(RefractionSamp, rfrUV);
		#endif
	#else
		float2 rfrUV = float2(rfrPPos.x, -rfrPPos.y) * (0.5 / rfrPPos.w) + 0.5;
		#if ENABLE_REFRACTION_EFFECT > 0
		float4 rfrColor = tex2D(RefractionSamp2, rfrUV);
		#else
		float4 rfrColor = tex2D(ScnSamp, rfrUV);
		#endif
	#endif

	// �X�y�L����
	float specular = CalcSpecular(L, N * (IsInWater ? -1 : 1), E);
	specular *= SpecularIntensity;

	// ���˗�
	float NV = max(dot(N,E), 0);
	float F = CalcFresnel(NV, 0.05) * WaterTranslucency * isValid;
	float4 Color = lerp(rfrColor, rflColor, max(F, totalReflection));

	return float4(Color.rgb + specular, Color.a * isValid);
}
#endif

//-----------------------------------------------------------------------------
// �u���[
float4 PS_BoxBlur( float4 Tex: TEXCOORD0, uniform sampler2D smp, uniform bool isXBlur) : COLOR
{
	float2 offset = (isXBlur) ? float2(BlurStepFog.x, 0) : float2(0, BlurStepFog.y);

	float fog = tex2D( smp, Tex.xy).x * WT[0];
	[unroll] for(int i = 1; i < 8; i ++)
	{
		fog += (tex2D( smp, Tex.xy + offset * i).x + tex2D( smp, Tex.xy - offset * i).x) * WT[i];
	}

	return float4(fog, 0, 0, 1);
}


float4 PS_BoxBlur4( float4 Tex: TEXCOORD0, uniform sampler2D smp, uniform bool isXBlur) : COLOR
{
	float2 offset = (isXBlur) ? float2(BlurStepDistortion.x, 0) : float2(0, BlurStepDistortion.y);

	float4 fog0 = tex2D( smp, Tex.xy);
	float3 fog = fog0.rgb * WT4[0];
	float weightSum = WT4[0];

	[unroll] for(int i = 1; i < 4; i ++) {
		float t = i;
		float4 fp = tex2D( smp, Tex.xy + offset * t);
		float4 fn = tex2D( smp, Tex.xy - offset * t);
		float weight = WT4[i];
		float wp = fp.w * weight;
		float wn = fn.w * weight;
		fog += fp.rgb * wp + fn.rgb * wn;
		weightSum += wp + wn;
	}

	return float4(fog / weightSum, fog0.w);
}


//-----------------------------------------------------------------------------
// ����
float4 PS_Last( float2 Tex: TEXCOORD0 ) : COLOR
{
	float3 v = GetWorldV(Tex.xy);
	float2 dn = tex2D(DepthSamp, Tex.xy).xy;

	float depth = dn.x * FAR_Z;
	float t = DistanceToWater(CameraPosition, v);

	float3 BaseColor = Degamma(tex2D(ScnSamp, Tex).rgb);
	#if ENABLE_WATERPLANE > 0
		// ���ゾ�Ɣ��˂ɂ���Đ����������ɂ����Ȃ�
		#if ENABLE_REFRACTION_EFFECT > 0
		float transmittance = IsInWater;
		#else
		float F = CalcFresnel(max(-v.y, 0), 0.05) * WaterTranslucency;
		float transmittance = max(1.0 - F, IsInWater);
		#endif
	float4 RefColor = tex2D(DistortionSamp, Tex.xy);
	float3 Color = lerp(BaseColor, Degamma(RefColor.rgb), RefColor.w);
	// �t�`�̃Y�������܂���
	Color = lerp(BaseColor, Color, min(abs(t-depth)*0.5, 1));
	float3 RawColor = Color;
	#else
	float3 Color = BaseColor;
	#endif

	// �ΐ�
	Color += CalcCausticsColor(v, dn);

	// �����t�H�O
	float thickness = CalcWaterTichkness(depth, CameraPosition, v);
	Color = CalcFogColor(Color, thickness);

	// �S�b�h���C
	#if ENABLE_GODRAY > 0
	float godray = tex2D( FogDensitySamp, Tex).r;
	float3 GodrayColor = (1.0 - exp(-godray * LightRate)) * godray;
	Color += GodrayColor * GodrayIntensity;
	#endif

	// �[�x�t�H�O
	Color *= CalcDepthFog(v, thickness);
	#if ENABLE_WATERPLANE > 0
	Color = lerp(RawColor, Color, transmittance);
	#endif

	return float4(Gamma(saturate(Color)), 1);
}


////////////////////////////////////////////////////////////////////////////////////////////////
//�e�N�j�b�N

technique SpotLight <
	string Script = 
		"RenderColorTarget0=ScnMap;"
		"RenderDepthStencilTarget=DepthBuffer;"
		"ClearSetColor=ClearColor; ClearSetDepth=ClearDepth;"
		"Clear=Color; Clear=Depth;"
		"ScriptExternal=Color;"

		// ����ɓ\��t����ΐ����쐬
		"RenderColorTarget0=CausticsMap;"
		"RenderDepthStencilTarget=CausticsMapDepth;"
		"Pass=DrawWaterPlane;"
		"RenderDepthStencilTarget=DepthBuffer;"

		#if ENABLE_GODRAY > 0
		// ���C�g�{�����[���̐���
		"RenderColorTarget0=FogDensityMap;"
		"Pass=RayMarchPass;"
		// �u���[
		"RenderColorTarget0=FogDensityMap2;"
		"Pass=BlurXPass;"
		"RenderColorTarget0=FogDensityMap;"
		"Pass=BlurYPass;"
/*
		// �u���b�N�m�C�Y���ڗ��̂ŁA������x�u���[���|����B
		"RenderColorTarget0=FogDensityMap2;"
		"Pass=BlurXPass;"
		"RenderColorTarget0=FogDensityMap;"
		"Pass=BlurYPass;"
*/
		#endif

		#if ENABLE_WATERPLANE > 0
		#if ENABLE_REFRACTION_EFFECT > 0
		// ���ォ�琅�����݂��Ƃ��̌���
		"RenderColorTarget0=RefractionMap2;"
		"Clear=Color;"
		"Pass=RefractionPlanePass;"
		#endif
		// ���ʗp�̂䂪�݂𐶐�
		"RenderColorTarget0=DistortionMap;"
		"Clear=Color;"
		"Pass=DistortionPass;"
		// �m�C�Y�������̂Ōy���{�J��
		"RenderColorTarget0=DistortionMap2;"
		"Pass=BlurX4Pass;"
		"RenderColorTarget0=DistortionMap;"
		"Pass=BlurY4Pass;"
		#endif

		// �ŏI����
		"RenderColorTarget0=;"
		"RenderDepthStencilTarget=;"
		"Pass=LastPass;"
	;
> {
	pass DrawWaterPlane < string Script= "Draw=Buffer;"; > {
		AlphaBlendEnable = FALSE; AlphaTestEnable = FALSE;
		VertexShader = compile vs_3_0 VS_SetTexCoord(FOG_BUFFER_SCALE);
		PixelShader  = compile ps_3_0 PS_DrawWaterPlane();
	}

	#if ENABLE_GODRAY > 0
	pass RayMarchPass < string Script= "Draw=Buffer;"; > {
		AlphaBlendEnable = FALSE; AlphaTestEnable = FALSE;
		VertexShader = compile vs_3_0 VS_SetTexCoord(FOG_BUFFER_SCALE);
		PixelShader  = compile ps_3_0 PS_RayMarch();
	}
	pass BlurXPass < string Script= "Draw=Buffer;"; > {
		AlphaBlendEnable = FALSE; AlphaTestEnable = FALSE;
		VertexShader = compile vs_3_0 VS_SetTexCoord(FOG_BUFFER_SCALE);
		PixelShader  = compile ps_3_0 PS_BoxBlur(FogDensitySamp, true);
	}
	pass BlurYPass < string Script= "Draw=Buffer;"; > {
		AlphaBlendEnable = FALSE; AlphaTestEnable = FALSE;
		VertexShader = compile vs_3_0 VS_SetTexCoord(FOG_BUFFER_SCALE);
		PixelShader  = compile ps_3_0 PS_BoxBlur(FogDensitySamp2, false);
	}
	#endif

	#if ENABLE_WATERPLANE > 0
	#if ENABLE_REFRACTION_EFFECT > 0
	pass RefractionPlanePass < string Script= "Draw=Buffer;"; > {
		AlphaBlendEnable = FALSE; AlphaTestEnable = FALSE;
		VertexShader = compile vs_3_0 VS_SetTexCoord(REFLECTION_BUFFER_SCALE);
		PixelShader  = compile ps_3_0 PS_DrawRefractionPlane();
	}
	#endif
	pass DistortionPass < string Script= "Draw=Buffer;"; > {
		AlphaBlendEnable = FALSE; AlphaTestEnable = FALSE;
		VertexShader = compile vs_3_0 VS_SetTexCoord(DISTORTION_BUFFER_SCALE);
		PixelShader  = compile ps_3_0 PS_DrawDistortion();
	}
	pass BlurX4Pass < string Script= "Draw=Buffer;"; > {
		AlphaBlendEnable = FALSE; AlphaTestEnable = FALSE;
		VertexShader = compile vs_3_0 VS_SetTexCoord(DISTORTION_BUFFER_SCALE);
		PixelShader  = compile ps_3_0 PS_BoxBlur4(DistortionSamp, true);
	}
	pass BlurY4Pass < string Script= "Draw=Buffer;"; > {
		AlphaBlendEnable = FALSE; AlphaTestEnable = FALSE;
		VertexShader = compile vs_3_0 VS_SetTexCoord(DISTORTION_BUFFER_SCALE);
		PixelShader  = compile ps_3_0 PS_BoxBlur4(DistortionSamp2, false);
	}
	#endif

	pass LastPass < string Script= "Draw=Buffer;"; > {
		AlphaBlendEnable = FALSE; AlphaTestEnable = FALSE;
		VertexShader = compile vs_3_0 VS_SetTexCoord(1);
		PixelShader  = compile ps_3_0 PS_Last();
	}
}
////////////////////////////////////////////////////////////////////////////////////////////////

