//�p�����[�^

// ���C�g�����w�莞�ɃJ�����̉�]�𖳎�����B0:�J�����ɒǏ]�B1:�J�����𖳎��B
#define FIX_LIGHT_DIRECTION		1

// ���C�g�����w�莞�̕�����ݒ肷��ΏہB0:�A�N�Z�T���A1:�R���g���[��
#define USE_CONTROLLER_AS_CENTER	1

// �R���g���[����
#define CTRL_NAME	"ikOverrayController.pmx"

// �f�v�X���ݒ莞�͈̔́B
#define	MIN_DISTANCE	10
#define	MAX_DISTANCE	2000


//****************** ������l�����̐ݒ�

// ���s�������{�J���ʁB0:�{�J���Ȃ��B
float BlurSize = 1.0;

// �o�b�t�@�T�C�Y�B2�ׂ̂���(1,2,4�Ȃ�)�ɂ���B
// �傫�����l�قǃ{�P��B�掿���]���Ɍv�Z�������Ȃ�B
#define BUFFER_SCALE	2

// �[�x�̊�l�BLinearDepth���̓����萔�Ɠ����l�ɂ��邱�ƁB
#define	MAX_DEPTH	2000

// �K���}�␳���s��
//#define ENABLE_GAMMA_CORRECT	1

//�e�N�X�`���t�H�[�}�b�g
#define TEXFORMAT "D3DFMT_R16F"
// #define TEXFORMAT "D3DFMT_R32F"

//******************�ݒ�͂����܂�

//////////////////////////////////////////////////////////////////////////////////////////////
//

#if defined(USE_CONTROLLER_AS_CENTER) && USE_CONTROLLER_AS_CENTER > 0
#define CENTRIC_OBJ	CTRL_NAME
float4x4 ObjectMatrix : CONTROLOBJECT < string name = CENTRIC_OBJ; string item = "�S�Ă̐e"; >;
#else
#define CENTRIC_OBJ	"(self)"
float4x4 ObjectMatrix : CONTROLOBJECT < string name = CENTRIC_OBJ; >;
#endif

float LightColorRate : CONTROLOBJECT < string name = CTRL_NAME; string item = "���C�g�F�w��"; >;
float LightR1 : CONTROLOBJECT < string name = CTRL_NAME; string item = "���C�g�F1R-"; >;
float LightG1 : CONTROLOBJECT < string name = CTRL_NAME; string item = "���C�g�F1G-"; >;
float LightB1 : CONTROLOBJECT < string name = CTRL_NAME; string item = "���C�g�F1B-"; >;
float LightR2 : CONTROLOBJECT < string name = CTRL_NAME; string item = "���C�g�F2R-"; >;
float LightG2 : CONTROLOBJECT < string name = CTRL_NAME; string item = "���C�g�F2G-"; >;
float LightB2 : CONTROLOBJECT < string name = CTRL_NAME; string item = "���C�g�F2B-"; >;

// �G�t�F�N�g�S�̂̋��x
// 0: �G�t�F�N�g�I�t�A1�F�W���A>1�A�����B���x�������Ɣ���т��܂��B
float LightScale0 : CONTROLOBJECT < string name = CTRL_NAME; string item = "���C�g���x"; >;
static float LightScale = LightScale0 + 1.0;
// +��-��t����?

// ���C�g�̌�����(�t�H�[���I�t�̋���)
// 0: �O���f�������Ȃ�A1: �O���f���Z���Ȃ�
float LightWidth0 : CONTROLOBJECT < string name = CTRL_NAME; string item = "���C�g��"; >;
static float LightWidth = LightWidth0;

// ���s���̉e�����ǂ̒��x�󂯂邩?
// 0:�󂯂Ȃ�(���s���𖳎����Ă��ׂĂ����C�g�̉e�����󂯂�)�A
// 1:�󂯂�(���ɂ�����̂قǃ��C�g�̉e�����󂯂�)
float DepthRate : CONTROLOBJECT < string name = CTRL_NAME; string item = "�f�v�X���x"; >;
// �f�v�X��臒l
float DepthWidth : CONTROLOBJECT < string name = CTRL_NAME; string item = "�f�v�X��"; >;
static float DepthScale = 4.0 * MAX_DEPTH / ((MAX_DISTANCE - MIN_DISTANCE) * exp(-DepthWidth * 4.0 - 1e-4) + MIN_DISTANCE);

// 1�ɂ���ƃe�X�g���[�h
float TestMode : CONTROLOBJECT < string name = CTRL_NAME; string item = "�e�X�g���[�h"; >;

// ���C�g�����̉e�����ǂꂾ���󂯂邩?
// 0: �t���̂ݖ��邭�Ȃ�
// 1: �����ł����邭�Ȃ�
float AngleSensitivity : CONTROLOBJECT < string name = CTRL_NAME; string item = "�������x"; >;
static float LightRate = 1.0 - saturate(AngleSensitivity);

// �G�t�F�N�g�̋��x
float AcsTr : CONTROLOBJECT < string name = "(self)"; string item = "Tr"; >;
float EffectTr : CONTROLOBJECT < string name = CTRL_NAME; string item = "�����x"; >;
static float EffectIntensity = (1.0 - EffectTr) * AcsTr;

float LightDirectionFlag : CONTROLOBJECT < string name = CTRL_NAME; string item = "���C�g�����w��"; >;

float LightTypeValue : CONTROLOBJECT < string name = CTRL_NAME; string item = "�O���f�^�C�v"; >;
static int LightType = (int)(LightTypeValue * 4.0);
/*
	0:���s�O���f�A
	1:�~�`�O���f�A
	2:����O���f
*/

float ColorModeValue : CONTROLOBJECT < string name = CTRL_NAME; string item = "�������[�h"; >;
static int ColorMode = (int)(ColorModeValue * 4.0);
/*
	0		// ���Z�F���𑫂�����
	1		// ��Z�F�Â��Ȃ�
	2		// �I�[�o�[���C�F���邢�Ƃ��͑����A�Â��Ƃ��͏�Z
	3		// �h��Ԃ��F�t�H�O�ȂǂɎg���B
*/

////////////////////////////////////////////////////////////////////////////////////////////////

#define TEXBUFFRATE {1.0/BUFFER_SCALE, 1.0/BUFFER_SCALE}


////////////////////////////////////////////////////////////////////////////////////////////////

float Script : STANDARDSGLOBAL <
	string ScriptOutput = "color";
	string ScriptClass = "scene";
	string ScriptOrder = "postprocess";
> = 0.8;

#define	PI	(3.14159265359)

// �ڂ��������̏d�݌W���F
#define  WT_0  0.0920246
#define  WT_1  0.0902024
#define  WT_2  0.0849494
#define  WT_3  0.0768654
#define  WT_4  0.0668236
#define  WT_5  0.0558158
#define  WT_6  0.0447932
#define  WT_7  0.0345379

// �X�N���[���T�C�Y
float2 ViewportSize : VIEWPORTPIXELSIZE;
static float2 ViewportOffset = (float2(0.5,0.5)/ViewportSize.xy);

float3	CameraPosition	: POSITION  < string Object = "Camera"; >;
float4x4 matP		: PROJECTION;
float4x4 matV		: VIEW;
float4x4 matVP		: VIEWPROJECTION;
float4x4 matVPInv	: VIEWPROJECTIONINVERSE;

float3	LightPosition	: POSITION  < string Object = "Light"; >;
float3	LightDirection0	: DIRECTION < string Object = "Light"; >;
float3	LightDiffuse	: DIFFUSE   < string Object = "Light"; >;
float3	LightSpecular	: SPECULAR  < string Object = "Light"; >;

static float3 LightColor1 = 1 - float3(LightR1,LightG1,LightB1);
static float3 LightColor2 = 1 - float3(LightR2,LightG2,LightB2);
static float3 LightColorT = lerp(LightSpecular, LightColor1, LightColorRate);
static float3 LightColorB = lerp(LightSpecular, LightColor2, LightColorRate);

static float2 SampStep = (float2(BlurSize, BlurSize) * BUFFER_SCALE / ViewportSize.xx);

static float3 LightDirection = (LightDirectionFlag < 0.5) ? LightDirection0 : normalize(-ObjectMatrix._21_22_23);



// �����_�����O�^�[�Q�b�g�̃N���A�l
float4 ClearColor = {1,1,1,1};
float ClearDepth  = 1.0;


// �I���W�i���̕`�挋�ʂ��L�^���邽�߂̃����_�[�^�[�Q�b�g
texture2D ScnMap : RENDERCOLORTARGET <
	int MipLevels = 1;
	string Format = "A8B8G8R8";
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

//
texture2D ScnMap1 : RENDERCOLORTARGET <
	int MipLevels = 1;
	float2 ViewportRatio = TEXBUFFRATE;
	string Format = TEXFORMAT;
>;
sampler2D ScnSamp1 = sampler_state {
	texture = <ScnMap1>;
	MinFilter = LINEAR;	MagFilter = LINEAR;
	AddressU  = CLAMP;	AddressV = CLAMP;
};

// X�����̂ڂ������ʂ��L�^���邽�߂̃����_�[�^�[�Q�b�g
texture2D ScnMap2 : RENDERCOLORTARGET <
	int MipLevels = 1;
	float2 ViewportRatio = TEXBUFFRATE;
	string Format = TEXFORMAT;
>;
sampler2D ScnSamp2 = sampler_state {
	texture = <ScnMap2>;
	MinFilter = LINEAR;	MagFilter = LINEAR;
	AddressU  = CLAMP;	AddressV = CLAMP;
};

// Y�����̂ڂ������ʂ��L�^���邽�߂̃����_�[�^�[�Q�b�g
texture2D ScnMap3 : RENDERCOLORTARGET <
	int MipLevels = 1;
	float2 ViewportRatio = TEXBUFFRATE;
	string Format = TEXFORMAT;
>;
sampler2D ScnSamp3 = sampler_state {
	texture = <ScnMap3>;
	MinFilter = LINEAR;	MagFilter = LINEAR;
	AddressU  = CLAMP;	AddressV = CLAMP;
};

//-----------------------------------------------------------------------------
#if defined(ENABLE_GAMMA_CORRECT) && ENABLE_GAMMA_CORRECT > 0
const float gamma = 2.2;
inline float3 Degamma(float3 col) { return pow(max(col,0), gamma); }
inline float3 Gamma(float3 col) { return pow(max(col,0), 1.0/gamma); }
inline float4 Degamma4(float4 col) { return float4(Degamma(col.rgb), col.a); }
inline float4 Gamma4(float4 col) { return float4(Gamma(col.rgb), col.a); }
#else
inline float3 Degamma(float3 col) { return col; }
inline float3 Gamma(float3 col) { return col; }
inline float4 Degamma4(float4 col) { return col; }
inline float4 Gamma4(float4 col) { return col; }
#endif

inline float rgb2gray(float3 rgb)
{
	return dot(float3(0.299, 0.587, 0.114), rgb);
}

//-----------------------------------------------------------------------------
// �[�x�}�b�v
//-----------------------------------------------------------------------------
texture LinearDepthMapRT: OFFSCREENRENDERTARGET <
	string Description = "DepthMap for ikOverray";
	float4 ClearColor = { 1, 0, 0, 1 };
	float2 ViewportRatio = TEXBUFFRATE;
	float ClearDepth = 1.0;
	string Format = TEXFORMAT;
	bool AntiAlias = true;
	string DefaultEffect = 
		"self = hide;"
		CTRL_NAME " = hide;"
		"* = LinearDepth.fx";
>;

sampler DepthMap = sampler_state {
	texture = <LinearDepthMapRT>;
	AddressU = CLAMP; AddressV = CLAMP;
	MinFilter = LINEAR; MagFilter = LINEAR;
};


//-----------------------------------------------------------------------------
// �Œ��`
//-----------------------------------------------------------------------------
struct VS_OUTPUT {
	float4 Pos			: POSITION;
	float4 TexCoord		: TEXCOORD0;
	float4 LPos			: TEXCOORD1;
};


//-----------------------------------------------------------------------------
// VS
VS_OUTPUT VS_SetTexCoord( float4 Pos : POSITION, float4 Tex : TEXCOORD0 )
{
	VS_OUTPUT Out = (VS_OUTPUT)0; 
	Out.Pos = Pos;
	Out.TexCoord.xy = Tex.xy + ViewportOffset.xy;
	Out.TexCoord.zw = Tex.xy + ViewportOffset.xy * BUFFER_SCALE;
	return Out;
}

VS_OUTPUT VS_SetLightPos( float4 Pos : POSITION, float4 Tex : TEXCOORD0 )
{
	VS_OUTPUT Out = (VS_OUTPUT)0; 
	Out.Pos = Pos;
	Out.TexCoord.xy = Tex.xy + ViewportOffset.xy * BUFFER_SCALE;
	Out.TexCoord.zw = Tex.xy + ViewportOffset.xy * BUFFER_SCALE;

#if defined(FIX_LIGHT_DIRECTION) && FIX_LIGHT_DIRECTION > 0
	if (LightDirectionFlag < 0.5)
	{
		Out.LPos = mul( float4(CameraPosition - LightDirection * 100, 1), matVP);
	}
	else
	{
		Out.LPos = mul( float4(- LightDirection * 100, 1), matP);
	}
#else
	Out.LPos = mul( float4(CameraPosition - LightDirection * 100, 1), matVP);
#endif
	return Out;
}


//-----------------------------------------------------------------------------
//

//-----------------------------------------------------------------------------
//
float4 PS_DrawFog( VS_OUTPUT IN ) : COLOR
{
	float2 PPos = (IN.TexCoord.zw - 0.5) * (1.0 / float2(0.5, -0.5));
	float lightPower = 0;

	float2 LPos = IN.LPos.xy / IN.LPos.w;
	PPos.x *= (ViewportSize.x / ViewportSize.y);
	LPos.x *= (ViewportSize.x / ViewportSize.y);

	if (LightType == 0)
	{
		// ���s�O���f
		float2 L = normalize(LPos.xy);
		float rot = PPos.x * L.x + PPos.y * L.y;
		// ��ʒ��S��0.5�ɂȂ�悤�ɒ���
		lightPower = rot * 0.25 + 0.5;
		// �����̔��Ε���
		lightPower *= saturate(IN.LPos.z / 100.0);
	}
	else if (LightType == 1)
	{
		// �~�`�O���f
		float dist = distance(PPos.xy, LPos.xy);
		lightPower = max(1.0 - dist / 5.1, 0);
		// lightPower = (lightPower > 0.5) ? 1 : 0;
		// �����̔��Ε���
		lightPower *= saturate(IN.LPos.z / 100.0);
	}
	else
	{
		// ���`�O���f
		// ���z�̌����Ǝ����̓���
		float4 ProjPos = float4(PPos.xy, 1, 1);
		float3 V = normalize(mul(ProjPos, matVPInv).xyz);
		lightPower = saturate(dot(V, -LightDirection));
	}

	lightPower = lightPower * LightRate + (1.0 - LightRate);
	lightPower = max(lightPower - (1.0 - lightPower) * LightWidth, 0);

	// ���s���ɂ��e��
	float depth = exp(-tex2D( DepthMap, IN.TexCoord.zw).r * DepthScale);
	depth = saturate(1.0 - depth) * DepthRate + (1.0 - DepthRate);
	lightPower *= depth;

	float4 Color = float4(saturate(lightPower * LightScale), 0, 0, 1);
	return Color;
}


//-----------------------------------------------------------------------------
// Blur
float4 PS_Blur( VS_OUTPUT IN, uniform bool isXBlur, uniform sampler2D smp) : COLOR
{
	float2 Tex = IN.TexCoord.zw;
	float2 Offset = isXBlur ? float2(SampStep.x, 0) : float2(0, SampStep.y);

	float Color;
	Color  = WT_0 *  tex2D( smp, Tex ).r;
	Color += WT_1 * (tex2D( smp, Tex+Offset  ).r + tex2D( smp, Tex-Offset  ).r);
	Color += WT_2 * (tex2D( smp, Tex+Offset*2).r + tex2D( smp, Tex-Offset*2).r);
	Color += WT_3 * (tex2D( smp, Tex+Offset*3).r + tex2D( smp, Tex-Offset*3).r);
	Color += WT_4 * (tex2D( smp, Tex+Offset*4).r + tex2D( smp, Tex-Offset*4).r);
	Color += WT_5 * (tex2D( smp, Tex+Offset*5).r + tex2D( smp, Tex-Offset*5).r);
	Color += WT_6 * (tex2D( smp, Tex+Offset*6).r + tex2D( smp, Tex-Offset*6).r);
	Color += WT_7 * (tex2D( smp, Tex+Offset*7).r + tex2D( smp, Tex-Offset*7).r);

	return float4(Color.xxx,1);
}


//-----------------------------------------------------------------------------
// �Ō�Ɍ���ʂƌv�Z���ʂ���������
float4 PS_Last( VS_OUTPUT IN ) : COLOR
{
	float4 BaseColor = Degamma4(max(tex2D( ScnSamp, IN.TexCoord.xy ), 0));
	float4 Color = BaseColor;

	// �e�X�g���[�h
	if (TestMode > 0.5)
	{
		LightColorT = float3(0,0,1);
		LightColorB = float3(0,1,0);
		BaseColor.rgb = Color.rgb = rgb2gray(Color.rgb);
	}

	float fogBlur = tex2D( ScnSamp3, IN.TexCoord.zw).r;
	float fog = tex2D( ScnSamp1, IN.TexCoord.zw).r;
	fog = max(fog, fogBlur);

	float3 light = lerp(LightColorB, LightColorT, fog);

	if (ColorMode == 0)
	{	// ���Z
		Color.rgb = Color.rgb + light * fog;
	}
	else if (ColorMode == 1)
	{	// ��Z
		Color.rgb = lerp(Color.rgb, Color.rgb * light, 1.0 - fog);
	}
	else if (ColorMode == 2)
	{	// �I�[�o�[���C
		Color.rgb = (fog < 0.5)
			? lerp(Color.rgb * light, Color.rgb, fog * 2.0)
			: (Color.rgb + light * ((fog - 0.5) * 2.0));
	}
	else
	{	// �h��Ԃ�
		Color.rgb = lerp(Color.rgb, light, fog);
	}

	// �����x
	Color.rgb = lerp(BaseColor.rgb, Color.rgb, EffectIntensity);

	return float4(Gamma(Color.rgb), 1);

}
////////////////////////////////////////////////////////////////////////////////////////////////

technique Gaussian <
	string Script = 
		"ClearSetColor=ClearColor;"
		"ClearSetDepth=ClearDepth;"

		"RenderColorTarget0=ScnMap;"
		"RenderDepthStencilTarget=DepthBuffer;"
		"Clear=Color;"
		"Clear=Depth;"
		"ScriptExternal=Color;"

		"RenderColorTarget0=ScnMap1;	Pass=DrawFog;"
		"RenderColorTarget0=ScnMap2;	Pass=Gaussian_X;"
		"RenderColorTarget0=ScnMap3;	Pass=Gaussian_Y;"

		"RenderDepthStencilTarget=;"
		"RenderColorTarget0=;			Pass=LastPass;"
	;
> {
	pass DrawFog < string Script= "Draw=Buffer;"; > {
		AlphaBlendEnable = FALSE;
		AlphaTestEnable = FALSE;
		VertexShader = compile vs_3_0 VS_SetLightPos();
		PixelShader  = compile ps_3_0 PS_DrawFog();
	}

	pass Gaussian_X < string Script= "Draw=Buffer;"; > {
		AlphaBlendEnable = FALSE;
		VertexShader = compile vs_3_0 VS_SetTexCoord();
		PixelShader  = compile ps_3_0 PS_Blur(true, ScnSamp1);
	}
	pass Gaussian_Y < string Script= "Draw=Buffer;"; > {
		AlphaBlendEnable = FALSE;
		VertexShader = compile vs_3_0 VS_SetTexCoord();
		PixelShader  = compile ps_3_0 PS_Blur(false, ScnSamp2);
	}

	pass LastPass < string Script= "Draw=Buffer;"; > {
		AlphaBlendEnable = FALSE;
		AlphaTestEnable = FALSE;
		VertexShader = compile vs_3_0 VS_SetTexCoord();
		PixelShader  = compile ps_3_0 PS_Last();
	}
}
////////////////////////////////////////////////////////////////////////////////////////////////
