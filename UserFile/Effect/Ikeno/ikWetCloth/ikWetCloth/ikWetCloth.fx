//=============================================================================
// �J�ɂ����ݕ\��
//=============================================================================

//****************** �ݒ�͂�������

#define	SPECULAR_INTENSITY	0.5		// �n�C���C�g�̋���

#define RAIN_FADE_SPEED		(0.5)	// �J�̏����鑬�x(�b)
#define BLEEDING_SPEED		(1.0)	// �J�̂ɂ��ޑ��x

#define	DROPPLET_SIZE	(4)			// �J���̃T�C�Y
#define MASK_BUFSIZE	256			// �J�e�N�X�`���̃T�C�Y
// MASK_BUFSIZE��傫������ƏڍׂɂȂ�B

#define		TimeSync		1	// �ҏW�������������ǂ���

// ���������̔G��x���B0:�����Ă�A1:�G��Ă���
#define	INITIAL_VALUE		0

// ���̓����\����L���ɂ���B0:�����A1;�L��
#define USE_TRANSLUCENCE		0
// �������F��ikPolish�̉e�����󂯂�����B
#define USE_POLISH				0


//****************** �ȉ��́A�M��Ȃ��ق��������ݒ荀��


//****************** �ݒ�͂����܂�

#define	PI	(3.14159265358979)

//-----------------------------------------------------------------------------
// �K���}�␳
const float epsilon = 1.0e-6;
const float gamma = 2.2;
inline float3 Degamma(float3 col) { return pow(max(col,epsilon), gamma); }
inline float3 Gamma(float3 col) { return pow(max(col,epsilon), 1.0/gamma); }
inline float4 Degamma4(float4 col) { return float4(Degamma(col.rgb), col.a); }
inline float4 Gamma4(float4 col) { return float4(Gamma(col.rgb), col.a); }

inline float rgb2gray(float3 rgb)
{
	return dot(float3(0.299, 0.587, 0.114), rgb);
}


////////////////////////////////////////////////////////////////////////////////////////////////

float Script : STANDARDSGLOBAL <
	string ScriptOutput = "color";
	string ScriptClass = "scene";
	string ScriptOrder = "postprocess";
> = 0.8;

// �����_�����O�^�[�Q�b�g�̃N���A�l
float4 ClearColor = {0,0,0,0};
float ClearDepth  = 1.0;

#define ScreenScale		(1/1.0)

// �X�N���[���T�C�Y
float2 ViewportSize : VIEWPORTPIXELSIZE;
static float2 ViewportOffset = (float2(0.5,0.5) / (ScreenScale * ViewportSize.xy));
static float2 SampleStep = (float2(1.0,1.0) / (ScreenScale * ViewportSize.xy));

float4x4 matP			: PROJECTION;
float4x4 matV			: VIEW;
float4x4 matInvVP		: VIEWPROJECTIONINVERSE;
float4x4 matInvP		: PROJECTIONINVERSE;
float4x4 matVP			: VIEWPROJECTION;

float3	CameraPosition	: POSITION  < string Object = "Camera"; >;
float3	LightDirection	: DIRECTION < string Object = "Light"; >;
float3	LightSpecular	: SPECULAR  < string Object = "Light"; >;
float4x4 matLightVP : VIEWPROJECTION < string Object = "Light"; >;

float AcsX  : CONTROLOBJECT < string name = "(self)"; string item = "X"; >;
float AcsY  : CONTROLOBJECT < string name = "(self)"; string item = "Y"; >;
float AcsSi  : CONTROLOBJECT < string name = "(self)"; string item = "Si"; >;
float AcsTr  : CONTROLOBJECT < string name = "(self)"; string item = "Tr"; >;

float time1 : TIME;
float time2 : TIME < bool SyncInEditMode = true; >;
static float time = TimeSync ? time1 : time2;
float elapsed_time1 : ELAPSEDTIME;
float elapsed_time2 : ELAPSEDTIME < bool SyncInEditMode = true; >;
static float Dt = clamp(TimeSync ? elapsed_time1 : elapsed_time2, 0.0f, 0.1f);

static float RainSpeed = 50.0 / max(AcsX, 1e-3) * pow(AcsTr, 6);
static float DrySpeed = pow(AcsY, 1.5) * (1.0 / 1000.0);
	// 1/1��1�b�ŏ�����
	// 1/10.0 �� 10�b�ŏ�����


bool     parthf;   // �p�[�X�y�N�e�B�u�t���O
#define SKII1    1500
#define SKII2    8000
sampler DefSampler : register(s0);

float3 CenterPosition : CONTROLOBJECT < string name = "(self)"; >;

// �I���W�i���̕`�挋�ʂ��L�^���邽�߂̃����_�[�^�[�Q�b�g
texture2D ScnMap : RENDERCOLORTARGET <
	bool AntiAlias = false;
	float2 ViewportRatio = {ScreenScale, ScreenScale};
	int MipLevels = 1;
	string Format = "A8R8G8B8";
>;

sampler2D ScnSamp = sampler_state {
	texture = <ScnMap>;
	AddressU = CLAMP;
	AddressV = CLAMP;
	MinFilter = POINT;
	MagFilter = POINT;
	MipFilter = NONE;
};
texture2D DepthBuffer : RENDERDEPTHSTENCILTARGET <
	string Format = "D24S8";
>;

shared texture WetClothMaskMap: RENDERCOLORTARGET <
	float Width = MASK_BUFSIZE;
	float Height = MASK_BUFSIZE;
	string Format = "G16R16F";
>;
sampler WetMaskSamp = sampler_state {
	texture = <WetClothMaskMap>;
	Filter = LINEAR;
	AddressU = WRAP; AddressV = WRAP;
};
sampler WetMaskSampPoint = sampler_state {
	texture = <WetClothMaskMap>;
	Filter = POINT;
	AddressU = WRAP; AddressV = WRAP;
};
texture WetMaskMapWork: RENDERCOLORTARGET <
	float Width = MASK_BUFSIZE;
	float Height = MASK_BUFSIZE;
	string Format = "G16R16F";
>;
sampler WetMaskSampWorkPoint = sampler_state {
	texture = <WetMaskMapWork>;
	Filter = POINT;
	AddressU = WRAP; AddressV = WRAP;
};

texture WetMaskDepth : RENDERDEPTHSTENCILTARGET <
	float Width = MASK_BUFSIZE;
	float Height = MASK_BUFSIZE;
	string Format = "D24S8";
>;





texture RandMap < string ResourceName = "rand128.png"; >;
sampler RandSamp = sampler_state {
	texture = <RandMap>;
	ADDRESSU = WRAP; ADDRESSV = WRAP;
	FILTER = NONE;
};

#define RND_TEX_SIZE 128
float3 GetRand(float index)
{
	float u = floor(index + time * 1021);
	float2 uv = float2(floor(u / RND_TEX_SIZE), fmod(u, RND_TEX_SIZE)) * (1.0 / RND_TEX_SIZE);
	return tex2Dlod(RandSamp, float4(uv,0,0)).xyz * 2.0 - 1.0;
}


//-----------------------------------------------------------------------------
// 

texture2D WetMapRT: OFFSCREENRENDERTARGET <
	string Description = "WetMap for ikWetCloth";
	float2 ViewportRatio = {1, 1};
	string Format = "A8R8G8B8";
	int MipLevels = 1;
	bool AntiAlias = false;
	float4 ClearColor = { 0, 0, 0, 0 };
	float ClearDepth = 1.0;
	string DefaultEffect = 
		"self = hide;"
		"*.pmx = WetMap.fx;"
		"*.pmd = WetMap.fx;"
		"*.x = WetMapMask.fx;"
		"* = hide;";
>;

sampler2D WetSamp = sampler_state {
	texture = <WetMapRT>;
	Filter = LINEAR;
	AddressU = CLAMP; AddressV = CLAMP;
};


#if defined(USE_TRANSLUCENCE) && USE_TRANSLUCENCE > 0

#if defined(USE_POLISH) && USE_POLISH > 0
#define	OPAQUE_EFFECT_FILE	"full_custom_polish.fx"
#else
#define	OPAQUE_EFFECT_FILE	"full_custom.fx"
#endif

texture2D OpaqueMapRT: OFFSCREENRENDERTARGET <
	string Description = "OpaqueMap for ikWetCloth";
	float2 ViewportRatio = {1, 1};
	string Format = "A16B16G16R16F";
	int MipLevels = 1;
	bool AntiAlias = false;
	float4 ClearColor = { 1, 1, 1, 0 };
	float ClearDepth = 1.0;
	string DefaultEffect = 
		"self = hide;"
		"*.pmx = " OPAQUE_EFFECT_FILE ";"
		"*.pmd = " OPAQUE_EFFECT_FILE ";"
		"*.x = " OPAQUE_EFFECT_FILE ";"
		"* = hide;";
>;

sampler2D OpaqueSamp = sampler_state {
	texture = <OpaqueMapRT>;
	Filter = LINEAR;
	AddressU = CLAMP; AddressV = CLAMP;
};

#if defined(USE_POLISH) && USE_POLISH > 0
bool ExistPolish : CONTROLOBJECT < string name = "ikPolishShader.x"; >;
// �A���r�G���g�}�b�v
shared texture2D PPPReflectionMap : RENDERCOLORTARGET;
sampler ReflectionMapSamp = sampler_state {
	texture = <PPPReflectionMap>;
	Filter = NONE;	AddressU  = CLAMP;	AddressV = CLAMP;
};
#endif

#endif

//-----------------------------------------------------------------------------

struct VS_OUTPUT {
	float4 Pos			: POSITION;
	float4 Tex			: TEXCOORD0;
	float4 TexCoord1	: TEXCOORD1;
	float4 TexCoord2	: TEXCOORD2;
};


//-----------------------------------------------------------------------------
//
VS_OUTPUT VS_SetTexCoordBuff( float4 Pos : POSITION, float4 Tex : TEXCOORD0)
{
	VS_OUTPUT Out = (VS_OUTPUT)0; 

	Out.Pos = Pos;
	float2 TexCoord = Tex.xy + 0.5 / MASK_BUFSIZE;
	float2 Offset = 1.0 / MASK_BUFSIZE;

	Out.Tex = float4(TexCoord, Offset);
	return Out;
}

float4 PS_CopyWet( VS_OUTPUT IN) : COLOR
{
	const float scale = (1.0 / MASK_BUFSIZE);
	float2 texCoord = IN.Tex.xy;

	float2 info = tex2D(WetMaskSampPoint, texCoord).xy;

	float info1 = 0;
	#define	ADD_WET(u,v)	info1+= tex2D(WetMaskSampPoint, texCoord + float2(u,v) * scale).y
	ADD_WET(-1,-1);
	ADD_WET( 0,-1);
	ADD_WET( 1,-1);
	ADD_WET(-1, 0);
	ADD_WET( 1, 0);
	ADD_WET(-1, 1);
	ADD_WET( 0, 1);
	ADD_WET( 1, 1);

	float dry = 1.0 - saturate(AcsY / 10.0);
	info1 = info1 * (1.0 / 16.0) * Dt * (1.0 / BLEEDING_SPEED) * dry;
	info.y = saturate(info.y + info1);

	return float4(info, 0, 1);
}

float4 PS_UpdateWet( VS_OUTPUT IN) : COLOR
{
	float2 texCoord = IN.Tex.xy;
	float2 info = tex2D(WetMaskSampWorkPoint, texCoord).xy;
	info.x = max(info.x - Dt * (1.0 / max(RAIN_FADE_SPEED,1e-4)), 0);
	info.y = max(info.y - Dt * DrySpeed, 0);

	#define RAINDROP_NUM	8
	float t = frac(time * RAINDROP_NUM * RainSpeed);
	for(int i = 0 ; i < RAINDROP_NUM; i++)
	{
		t += RainSpeed * Dt;
		float isFallen = (t >= 1.0);
		t = frac(t);

		float3 rnd = GetRand(i*3);
		float2 center = rnd * 0.5 + 0.5;
		float2 dif = abs(texCoord - center);
		float l = length(min(dif, 1 - dif));

		float alpha = saturate(1.0 - l * (MASK_BUFSIZE * 1.0 / DROPPLET_SIZE)) * isFallen;
		info = saturate(info + float2(1,1) * alpha);
	}

	if (AcsSi == 0) info = float2(0, INITIAL_VALUE);
	return float4(info, 0, 1);
}



//-----------------------------------------------------------------------------
//
VS_OUTPUT VS_SetTexCoord( float4 Pos : POSITION, float4 Tex : TEXCOORD0, uniform float level)
{
	VS_OUTPUT Out = (VS_OUTPUT)0; 

	Out.Pos = Pos;
	float2 TexCoord = Tex.xy + ViewportOffset.xy * level;
	float2 Offset = SampleStep * level;

	Out.Tex = float4(TexCoord, Offset);
	return Out;
}

float4 PS_Last( VS_OUTPUT IN) : COLOR
{
	float2 texCoord = IN.Tex.xy;

	#if 0
	float2 texCoordMini = texCoord * 4;
	if (texCoordMini.x < 1.0 && texCoordMini.y < 1.0)
	{
		return float4(tex2D(WetMaskSamp, texCoordMini).rg, 0, 1);
	}
	#endif

	float3 baseCol = Degamma4(tex2D(ScnSamp, texCoord)).rgb;
	#if defined(USE_TRANSLUCENCE) && USE_TRANSLUCENCE > 0
	float4 underCol = Degamma4(tex2D(OpaqueSamp, texCoord));
	underCol.rgb /= max(underCol.a, 1e-4);
	#if defined(USE_POLISH) && USE_POLISH > 0
	if (ExistPolish) underCol.rgb *= tex2D(ReflectionMapSamp, texCoord).rgb;
	#endif
	#endif
	float4 wetinfo = tex2D(WetSamp, texCoord);

	float specular = wetinfo.r * SPECULAR_INTENSITY;
	float prosity = wetinfo.g;
	float translucence = wetinfo.b;

	float4 col = float4(baseCol.rgb, 1);
	#if defined(USE_TRANSLUCENCE) && USE_TRANSLUCENCE > 0
	// underCol.a���Ⴂ�ꍇ�A�������݂��Ȃ��B
	col.rgb = lerp(col.rgb, underCol, translucence * underCol.a);
	#endif
	col.rgb *= prosity;
	col.rgb += (LightSpecular * specular * 2.0 + specular * 0.3);

	return Gamma4(col);
}


////////////////////////////////////////////////////////////////////////////////////////////////

technique DepthOfField <
	string Script = 
		// ���ʂ̉�ʂ������_�����O
		"RenderColorTarget0=ScnMap;"
		"RenderDepthStencilTarget=DepthBuffer;"
		"ClearSetColor=ClearColor;"
		"ClearSetDepth=ClearDepth;"
		"Clear=Color; Clear=Depth;"
		"ScriptExternal=Color;"

		"RenderDepthStencilTarget=WetMaskDepth; Clear=Depth;"
		"RenderColorTarget0=WetMaskMapWork;	Pass=CopyWetPass;"
		"RenderColorTarget0=WetClothMaskMap;Pass=UpdateWetPass;"

		// ����
		"RenderColorTarget0=;"
		"RenderDepthStencilTarget=;"
		"Pass=LastPass;"
	;
> {
	pass CopyWetPass < string Script= "Draw=Buffer;"; > {
		VertexShader = compile vs_3_0 VS_SetTexCoordBuff();
		PixelShader  = compile ps_3_0 PS_CopyWet();
	}
	pass UpdateWetPass < string Script= "Draw=Buffer;"; > {
		VertexShader = compile vs_3_0 VS_SetTexCoordBuff();
		PixelShader  = compile ps_3_0 PS_UpdateWet();
	}

	pass LastPass < string Script= "Draw=Buffer;"; > {
		AlphaBlendEnable = FALSE;	AlphaTestEnable = FALSE;
		VertexShader = compile vs_3_0 VS_SetTexCoord(1);
		PixelShader  = compile ps_3_0 PS_Last();
	}
}

////////////////////////////////////////////////////////////////////////////////////////////////
