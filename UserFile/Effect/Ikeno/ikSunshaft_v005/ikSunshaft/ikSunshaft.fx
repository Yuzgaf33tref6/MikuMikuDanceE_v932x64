//�p�����[�^

// �������鉜�s���̍ő勗��
// �����܂Ń`�F�b�N����قǐ��x�������Ȃ�B1�P�ʂ�8cm���x�B
const float MaxDistance = 200.0;

// 1�s�N�Z��������̒�����(4�`64���x)�B�����قǐ��m�ɂȂ����ɏd���Ȃ�B
const int MaxDiv = 64;		// �f�t�H���g��16��


//****************** �ȉ��͘M��Ȃ��ق��������ݒ�

// �o�b�t�@�T�C�Y�B2�ׂ̂���(1,2,4�Ȃ�)�ɂ���B
// �傫�����l�قǃ{�P��̂Ńm�C�Y���y����������ɁA�f�B�e�B�[����������B
// �傫�����l�قǌv�Z�������Ȃ�B
#define BUFFER_SCALE	2

// ��O�̒����𖳎����鐔�B
// �J�����t�߂̓`�F�b�N���邾�����ʂȂ̂ŁB
// (��ʉ��܂ł̋��� / (MaxDiv + StepOffset) ���A���������邩�`�F�b�N����)
const int StepOffset = 2;

#define CTRL_NAME		"ikSunshaft_Ctrl.pmx"

//�e�N�X�`���t�H�[�}�b�g
#define TEXFORMAT "A16B16G16R16F"

// �����`�悵�Ȃ��Ƃ��̉��s���B
#define FAR_Z	1000


//******************�ݒ�͂����܂�

float mLightColor : CONTROLOBJECT < string name = CTRL_NAME; string item = "�J�X�^�����C�g�F"; >;
float mLightR : CONTROLOBJECT < string name = CTRL_NAME; string item = "���C�g�FR"; >;
float mLightG : CONTROLOBJECT < string name = CTRL_NAME; string item = "���C�g�FG"; >;
float mLightB : CONTROLOBJECT < string name = CTRL_NAME; string item = "���C�g�FB"; >;
// ���C�g�̋��x
float mLightA : CONTROLOBJECT < string name = CTRL_NAME; string item = "���C�g���x"; >;
float acsLightScale : CONTROLOBJECT < string name = "(self)"; string item = "Si"; >;
static float LightScale = acsLightScale * 0.1 * (1.0 - mLightA);

// �w�����F���������Ǝ����̍��łǂꂾ���������邩
float mDirectivity : CONTROLOBJECT < string name = CTRL_NAME; string item = "�w����"; >;

// �p�x�ɂ���Č��̐F���ω�����x����
float mColorShift : CONTROLOBJECT < string name = CTRL_NAME; string item = "�J���[�V�t�g"; >;

float mFogR : CONTROLOBJECT < string name = CTRL_NAME; string item = "�t�H�O�FR"; >;
float mFogG : CONTROLOBJECT < string name = CTRL_NAME; string item = "�t�H�O�FG"; >;
float mFogB : CONTROLOBJECT < string name = CTRL_NAME; string item = "�t�H�O�FB"; >;
float mFogA : CONTROLOBJECT < string name = CTRL_NAME; string item = "�t�H�O���x"; >;

// �t�H�O�̌���
float mFogDensP : CONTROLOBJECT < string name = CTRL_NAME; string item = "�t�H�O�Z�x+"; >;
float mFogDensN : CONTROLOBJECT < string name = CTRL_NAME; string item = "�t�H�O�Z�x-"; >;
static float FogDensity = pow(10, 2.0 + (mFogDensN - mFogDensP)) * 2.0;

// �G�t�F�N�g�S�̂̋��x
float mEffectAmplitude : CONTROLOBJECT < string name = CTRL_NAME; string item = "�G�t�F�N�g���x"; >;
float AcsTr : CONTROLOBJECT < string name = "(self)"; string item = "Tr"; >;
static float EffectAmplitude = saturate(AcsTr * (1.0 - mEffectAmplitude));

float TestMode : CONTROLOBJECT < string name = CTRL_NAME; string item = "�e�X�g���[�h"; >;



////////////////////////////////////////////////////////////////////////////////////////////////

#define TEXBUFFRATE {1.0/BUFFER_SCALE, 1.0/BUFFER_SCALE}

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


#define	PI	(3.14159265359)

float Script : STANDARDSGLOBAL <
	string ScriptOutput = "color";
	string ScriptClass = "scene";
	string ScriptOrder = "postprocess";
> = 0.8;

// �X�N���[���T�C�Y
float2 ViewportSize : VIEWPORTPIXELSIZE;
static float2 ViewportOffset = (float2(0.5,0.5)/ViewportSize.xy);

float4x4 matP		: PROJECTION;
float4x4 matV		: VIEW;
float4x4 matVP		: VIEWPROJECTION;
float4x4 matVPInv	: VIEWPROJECTIONINVERSE;
float4x4 matWInv	: WORLDINVERSE;
float4x4 matLightVP : VIEWPROJECTION < string Object = "Light"; >;

float3	LightDirection	: DIRECTION < string Object = "Light"; >;
float3	LightSpecular    : SPECULAR  < string Object = "Light"; >;

float3	CameraPosition	: POSITION  < string Object = "Camera"; >;
float3	CameraDirection : DIRECTION < string Object = "Camera"; >;

float ftime : TIME <bool SyncInEditMode=false;>;

bool	 parthf;   // �p�[�X�y�N�e�B�u�t���O
#define SKII1	1500
#define SKII2	8000

sampler DefSampler : register(s0);
sampler MMDSamp0 : register(s0);
sampler MMDSamp1 : register(s1);
sampler MMDSamp2 : register(s2);

float BlurSize = 1.0;
static float2 SampStep = (float2(BlurSize, BlurSize) / (ViewportSize.xx / BUFFER_SCALE));

static float3 ViewLightDir = normalize(mul(-LightDirection, (float3x3)matV));


// �����_�����O�^�[�Q�b�g�̃N���A�l
float4 ClearColor = {1,1,1,1};
float ClearDepth  = 1.0;


//-----------------------------------------------------------------------------
// �[�x�}�b�v
texture LinearDepthMapRT: OFFSCREENRENDERTARGET <
	string Description = "OffScreen RenderTarget for ikSunshaft";
	float4 ClearColor = { 1, 0, 0, 1 };
	float2 ViewportRatio = {1,1};
	float ClearDepth = 1.0;
	string Format = "R16F";
	bool AntiAlias = false;
	string DefaultEffect = 
		"self = hide;"
		"* = ikLinearDepth.fx";
>;

sampler DepthMap = sampler_state {
	texture = <LinearDepthMapRT>;
	AddressU = CLAMP;
	AddressV = CLAMP;
	MinFilter = LINEAR;
	MagFilter = LINEAR;
	MipFilter = LINEAR;
};

// �I���W�i���̕`�挋�ʂ��L�^���邽�߂̃����_�[�^�[�Q�b�g
texture2D ScnMap : RENDERCOLORTARGET <
	int MipLevels = 1;
	string Format = "A16B16G16R16F";
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
	Filter = LINEAR;
	AddressU  = CLAMP; AddressV = CLAMP;
};

texture2D ScnMap2 : RENDERCOLORTARGET <
	int MipLevels = 1;
	float2 ViewportRatio = TEXBUFFRATE;
	string Format = TEXFORMAT;
>;
sampler2D ScnSamp2 = sampler_state {
	texture = <ScnMap2>;
	Filter = LINEAR;
	AddressU  = CLAMP; AddressV = CLAMP;
};


//-----------------------------------------------------------------------------
// �K���}�␳
const float gamma = 2.2333;
const float epsilon = 1.0e-6;
inline float3 Degamma(float3 col) { return pow(max(col,epsilon), gamma); }
inline float3 Gamma(float3 col) { return pow(max(col,epsilon), 1.0/gamma); }
inline float4 Degamma4(float4 col) { return float4(Degamma(col.rgb), col.a); }
inline float4 Gamma4(float4 col) { return float4(Gamma(col.rgb), col.a); }
inline float rgb2gray(float3 rgb)
{
	return dot(float3(0.299, 0.587, 0.114), max(rgb,0));
}

inline float3 ColorEmphasize(float3 src, float rate)
{
	const float e = 1.0e-4;
	float3 col = pow(src, rate);
	float gray = saturate(rgb2gray(src));
	float gray0 = rgb2gray(col);
	float scale = gray / max(gray0, e);

	col = col * scale;
	return col;
}

inline float3 CalcLightColor()
{
	float3 light = float3(mLightR,mLightG,mLightB);
	float3 col = lerp(max(LightSpecular, 0), light, mLightColor);
	return ColorEmphasize(col, 2.0);
}

static float3 EmphasizedLightColor = CalcLightColor();

//-----------------------------------------------------------------------------
// �Œ��`
//
//-----------------------------------------------------------------------------
struct VS_OUTPUT {
	float4 Pos			: POSITION;
	float4 TexCoord		: TEXCOORD0;
	float4 TexCoord1	: TEXCOORD1;
	float4 TexCoord2	: TEXCOORD2;
};


//-----------------------------------------------------------------------------
// ���ʂ�VS
VS_OUTPUT VS_SetTexCoord( float4 Pos : POSITION, float4 Tex : TEXCOORD0 ) {
	VS_OUTPUT Out = (VS_OUTPUT)0; 

	Out.Pos = Pos;
	Out.TexCoord.xy = Tex + ViewportOffset.xy;
	Out.TexCoord2.xy = Tex + BUFFER_SCALE * ViewportOffset.xy;

	return Out;
}

VS_OUTPUT VS_SetTexCoord1( float4 Pos : POSITION, float4 Tex : TEXCOORD0, uniform float level)
{
	VS_OUTPUT Out = (VS_OUTPUT)0; 

	Out.Pos = Pos;
	float2 TexCoord = Tex.xy + ViewportOffset.xy * (BUFFER_SCALE * level);
	float2 Offset = ViewportOffset * (2.0 * BUFFER_SCALE * level);

	Out.TexCoord = float4(TexCoord, Offset);
	Out.TexCoord1 = TexCoord.xyxy + Offset.xyxy * 0.25 * float4(-1,-1, -1, 1);
	Out.TexCoord2 = TexCoord.xyxy + Offset.xyxy * 0.25 * float4( 1,-1,  1, 1);
	return Out;
}

VS_OUTPUT VS_SetTexCoord2( float4 Pos : POSITION, float4 Tex : TEXCOORD0, uniform float level)
{
	VS_OUTPUT Out = (VS_OUTPUT)0; 

	Out.Pos = Pos;
	float2 TexCoord = Tex.xy + ViewportOffset.xy * (BUFFER_SCALE * level);
	float2 Offset = ViewportOffset * (2.0 * BUFFER_SCALE * level);

	Out.TexCoord = float4(TexCoord, Offset);
	Out.TexCoord1 = TexCoord.xyxy + Offset.xyxy * float4(-1,-1, -1, 1);
	Out.TexCoord2 = TexCoord.xyxy + Offset.xyxy * float4( 1,-1,  1, 1);

	return Out;
}

//-----------------------------------------------------------------------------
//
// �W�b�^�[�p
static float JitterOffsets[16] = {
	 6/16.0, 1/16.0,12/16.0,11/16.0,
	 9/16.0,14/16.0, 5/16.0, 2/16.0,
	 0/16.0, 7/16.0,10/16.0,13/16.0,
	15/16.0, 8/16.0, 3/16.0, 4/16.0,
};

inline float CalcShadow(float4 zcalc)
{
	zcalc /= zcalc.w;
	float2 TexCoord = float2(1.0f + zcalc.x, 1.0f - zcalc.y) * 0.5;

	float k = (parthf) ? SKII2 * TexCoord.y : SKII1;
	float z = tex2Dlod(DefSampler, float4(TexCoord,0,0)).r;
	float comp = saturate(max(zcalc.z - z, 0) * k - 0.3);

	// �V���h�E�o�b�t�@�O?
	// �V���h�E�o�b�t�@�O�Ȃ�����������Ă��邱�Ƃɂ���
	float2 clipedDif = TexCoord - saturate(TexCoord);
	comp *= (dot(clipedDif, clipedDif) == 0.0);

	return 1.0 - comp;
}


float4 PS_DrawFog( VS_OUTPUT IN ) : COLOR
{
	float depth0 = tex2D( DepthMap, IN.TexCoord2.xy).r * FAR_Z;
	float2 PPos = (IN.TexCoord2.xy - 0.5) * float2(2.0, -2.0);
	float3 v = normalize(mul(float4(PPos.xy, 1, 1), matVPInv).xyz);
	float3 vv = normalize(mul(v, (float3x3)matV).xyz);

	float invdepth = exp(-depth0 / FogDensity);
	float depth = min(depth0, MaxDistance);
	float div = MaxDiv + StepOffset + 2;
			// �W�b�^�[��+1�A���s�����̂��̂�����Ӗ����Ȃ��̂�+1
	float sampleStep = depth / div;
	v *= sampleStep;

	float2 pos = floor(IN.TexCoord2.xy * (ViewportSize / BUFFER_SCALE));
	int index = (int)(fmod(pos.x,4)*4 + fmod(pos.y,4));
	float offset = JitterOffsets[index] + StepOffset;
	float4 p = float4(CameraPosition + v * offset, 1);

	float4 zcalcB = mul(p, matLightVP);
	float4 zcalcE = mul(p + float4(v * MaxDiv, 0), matLightVP);

	float sum = 0;
	float depthScale = depth / (FogDensity * MaxDiv) * 3.0; // exp(-3) = 0.05
	float lastDensity = 1;
	for(int i = 0; i < MaxDiv; i++) {
		float4 zcalc = lerp(zcalcB, zcalcE, i * (1.0 / (MaxDiv - 1.0)));
		float shadow = CalcShadow(zcalc);

		// �����قǔ����Ȃ�
		// �� ���C�g�v���W�F�N�V�����X�y�[�X�Ō��Ă���̂Ő������Ȃ��B
		float density = exp(-i * depthScale);
		sum += shadow * (lastDensity - density);
		lastDensity = density;
	}

	// �����ƌ��������ɂ����̓��˗�
	float LV = dot(vv, ViewLightDir);

	// ���ʌ����قǐԂ������A�������قǐ������B
	// �[�x�ɂ���ĕς���H
	float scatter = max(LV * LV * LV * 2 - 1.0, -1) * 0.5 * mColorShift;
	float3 scatterColor = float3(0.5 + scatter, 0.5, 0.5 - scatter);
	scatterColor *= (1.0 / rgb2gray(scatterColor));

	// Heyney-Greenstein
	float g = (1.0 - mDirectivity) * 0.8; // 0.1�`0.8
	float dm = (1.0 - g*g) / pow(1.0 + g*g - 2*g * LV, 3.0/2.0);
	// �K���Ȑ��K��
	float d = dm / (g*g*g*5.3+1.0) * LightScale * 2.0;

	float intensity = max(sum * d, 0);
	float3 color = EmphasizedLightColor * scatterColor * intensity;

	return float4(color, invdepth);
}

//-----------------------------------------------------------------------------
// Blur

inline float CalcBlurWeight(float d0, float d1)
{
	// return exp(-abs(d0 - d1) * 100.0);
	// ���͑O�ɉe�����邪�A�O�͉��ɉe�����Ȃ�
	return (d0 < d1) ? exp(-abs(d0 - d1) * 100.0) : 1;
}

inline float4 CalcWeight(float4 col, float d1)
{
	return float4(col.rgb, 1) * (exp(-abs(col.w-d1)*100.0) + epsilon);
}

float4 PS_BoxBlur( float4 Tex: TEXCOORD2, uniform sampler2D smp, uniform bool isXBlur) : COLOR
{
	float2 offset = (isXBlur) ? float2(SampStep.x, 0) : float2(0, SampStep.y);

	float4 fog0 = tex2D( smp, Tex.xy);
	float3 fog = fog0.rgb * WT[0];
	float weightSum = WT[0];
	float depth = fog0.w;

	[unroll] for(int i = 1; i < 8; i ++) {
		float t = i;
		float4 fp = tex2D( smp, Tex.xy + offset * t);
		float4 fn = tex2D( smp, Tex.xy - offset * t);
		float wp = CalcBlurWeight(depth, fp.w) * WT[i];
		float wn = CalcBlurWeight(depth, fn.w) * WT[i];
		fog += fp.rgb * wp + fn.rgb * wn;
		weightSum += wp + wn;
	}

	return float4(fog / weightSum, depth);
}

//-----------------------------------------------------------------------------
// �Ō�Ɍ���ʂƌv�Z���ʂ���������
float4 PS_Last( float4 Tex : TEXCOORD0 ) : COLOR
{
	float4 color = Degamma4(tex2D( ScnSamp, Tex ));
	float3 baseColor = color.rgb;
	// �e�X�g���[�h
	if (TestMode > 0.5) { color = 0; baseColor = 0; }

	float depth0 = tex2D( DepthMap, Tex).r * FAR_Z;
	float invdepth = exp(-depth0 / FogDensity);

#if 1
	// �𑜓x�𗎂Ƃ��Ă���̂ŁA�[�x�t�B���^�ŕ␳���|����B
	float4 fog0 = tex2D( ScnSamp1, Tex + float2(-1,-1) * ViewportOffset.xy);
	float4 fog1 = tex2D( ScnSamp1, Tex + float2( 1,-1) * ViewportOffset.xy);
	float4 fog2 = tex2D( ScnSamp1, Tex + float2(-1, 1) * ViewportOffset.xy);
	float4 fog3 = tex2D( ScnSamp1, Tex + float2( 1, 1) * ViewportOffset.xy);
	float4 fog = CalcWeight(fog0, invdepth) + CalcWeight(fog1, invdepth)
				+ CalcWeight(fog2, invdepth) + CalcWeight(fog3, invdepth);
	fog.rgb /= max(fog.w, epsilon);
#else
	float4 fog = tex2D( ScnSamp1, Tex);
#endif

	// ��C���߁F�����ɂ��t�H�O
	float3 skyColor = float3(mFogR, mFogG, mFogB);
	color.rgb = lerp(color.rgb, skyColor, (1.0 - invdepth) * mFogA);
	// color.rgb = 0;

	// ���̒ǉ�
	float3 addColor = fog.rgb;
	color.rgb += addColor;
	// ���̐F�ɂ����z����
	color.rgb += rgb2gray(color.rgb) * 0.1;

	// �g�[���J�[�u��K�p����?

	// �G�t�F�N�g�K�p�x��߂�
	color.rgb = lerp(baseColor.rgb, color.rgb, EffectAmplitude);
	// color.rgb = tex2D(BlurSamp0, Tex).rgb;

	color.a = 1;
	return Gamma4(color);
}

////////////////////////////////////////////////////////////////////////////////////////////////

technique Gaussian <
	string Script = 
		"RenderColorTarget0=ScnMap;"
		"RenderDepthStencilTarget=DepthBuffer;"
		"ClearSetColor=ClearColor;"
		"ClearSetDepth=ClearDepth;"
		"Clear=Color;"
		"Clear=Depth;"
		"ScriptExternal=Color;"

		"RenderColorTarget0=ScnMap1;"
		"Pass=DrawFog;"

		"RenderColorTarget0=ScnMap2;"
		"Pass=Gaussian_X;"
		"RenderColorTarget0=ScnMap1;"
		"Pass=Gaussian_Y;"

		"RenderColorTarget0=;"
		"RenderDepthStencilTarget=;"
		"Pass=LastPass;"
	;
> {
	pass DrawFog < string Script= "Draw=Buffer;"; > {
		AlphaBlendEnable = FALSE; AlphaTestEnable = FALSE;
		VertexShader = compile vs_3_0 VS_SetTexCoord();
		PixelShader  = compile ps_3_0 PS_DrawFog();
	}

	pass Gaussian_X < string Script= "Draw=Buffer;"; > {
		AlphaBlendEnable = FALSE; AlphaTestEnable = FALSE;
		VertexShader = compile vs_3_0 VS_SetTexCoord();
		PixelShader  = compile ps_3_0 PS_BoxBlur(ScnSamp1, true);
	}
	pass Gaussian_Y < string Script= "Draw=Buffer;"; > {
		AlphaBlendEnable = FALSE; AlphaTestEnable = FALSE;
		VertexShader = compile vs_3_0 VS_SetTexCoord();
		PixelShader  = compile ps_3_0 PS_BoxBlur(ScnSamp2, false);
	}

	pass LastPass < string Script= "Draw=Buffer;"; > {
		AlphaBlendEnable = FALSE; AlphaTestEnable = FALSE;
		VertexShader = compile vs_3_0 VS_SetTexCoord();
		PixelShader  = compile ps_3_0 PS_Last();
	}
}

//////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////
