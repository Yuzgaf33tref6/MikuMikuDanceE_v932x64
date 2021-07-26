////////////////////////////////////////////////////////////////////////////////
//
//  M4Layer.fx
//  �쐬: �~�[�t�H��
//
////////////////////////////////////////////////////////////////////////////////

// ���C���[��
#define LAYER_NAME Layer

// ���C���[���[�h
// 0: �ʏ�
// 1: ���Z
// 2: ���Z
// 3: ��Z
// 4: �X�N���[��
// 5: �I�[�o�[���C
// 6: �n�[�h���C�g
// 7: �\�t�g���C�g
// 8: �r�r�b�h���C�g
// 9: ���j�A���C�g
// 10: �s�����C�g
// 11: �����Ă�
// 12: �Ă�����
// 13: ��r (��)
// 14: ��r (��)
// 15: ���̐�Βl
// 16: ���O
// 17: �F��
// 18: �ʓx
// 19: �J���[
// 20: �P�x
#define LAYER_MODE 0

// �}�X�N���g�p���邩
#define LAYER_MASK 0

// �}�X�N�𔽓]���邩
#define LAYER_MASK_INVERT 0

// �����_�����O�^�[�Q�b�g���g�p���邩
// 0 �ɂ���ƕ`�挋�ʂ����̂܂܎g�p����悤�ɂȂ�܂����A
// ���̃����_�����O�^�[�Q�b�g�ɑ΂��Ďg�p�ł���悤�ɂȂ�܂��B
#define LAYER_RT 1

#define ALPHA_ENABLED 1

////////////////////////////////////////////////////////////////

#define MERGE(a, b) a##b
#if LAYER_MODE == 17
#define IS_COMPOSITE_BLENDING
#elif LAYER_MODE == 18
#define IS_COMPOSITE_BLENDING
#elif LAYER_MODE == 19
#define IS_COMPOSITE_BLENDING
#elif LAYER_MODE == 20
#define IS_COMPOSITE_BLENDING
#endif

// �|�X�g�G�t�F�N�g�錾
float Script : STANDARDSGLOBAL
<
    string ScriptOutput = "color";
    string ScriptClass = "scene";
    string ScriptOrder = "postprocess";
> = 0.8;

// MMD�{����sampler���㏑�����Ȃ����߂̋L�q�ł��B�폜�s�B
sampler MMDSamp0 : register(s0);
sampler MMDSamp1 : register(s1);
sampler MMDSamp2 : register(s2);

float Tr : CONTROLOBJECT < string name = "(self)"; string item = "Tr"; >;
float Si : CONTROLOBJECT < string name = "(self)"; string item = "Si"; >;
float2 ViewportSize : VIEWPORTPIXELSIZE;
static const float2 ViewportOffset = float2(0.5, 0.5) / ViewportSize;

////////////////////////////////////////////////////////////////
// ��Ɨp�e�N�X�`��
texture2D DepthBuffer : RENDERDEPTHSTENCILTARGET <
	float2 ViewPortRatio = {1.0,1.0};
	string Format = "D24S8";
>;
texture2D ScreenBuffer : RENDERCOLORTARGET <
	float2 ViewPortRatio = {1.0,1.0};
	int MipLevels = 1;
	string Format = "A8R8G8B8" ;
>;
sampler2D ScreenSampler = sampler_state {
	texture = <ScreenBuffer>;
	MinFilter = NONE;
	MagFilter = NONE;
	MipFilter = NONE;
	AddressU  = CLAMP;
	AddressV = CLAMP;
};

#if LAYER_RT
texture MERGE(LAYER_NAME, RT) : OFFSCREENRENDERTARGET
<
	string Description = "Render Target for M4Layer.fx";
	float4 ClearColor = { 0, 0, 0, 0 };
	float ClearDepth = 1.0;
	bool AntiAlias = true;
	int Miplevels = 1;
	string DefaultEffect = "self = hide; * = none;";
>;
sampler LayerSampler = sampler_state
{
	texture = <MERGE(LAYER_NAME, RT)>;
	MinFilter = POINT;
	MagFilter = POINT;
	AddressU = CLAMP;
	AddressV = CLAMP;
};

#endif

#if LAYER_MASK
texture MERGE(LAYER_NAME, MaskRT) : OFFSCREENRENDERTARGET
<
	string Description = "Masking Render Target for M4Layer.fx";
	float4 ClearColor = { 0, 0, 0, 0 };
	float ClearDepth = 1.0;
	bool AntiAlias = true;
	int Miplevels = 1;
	string DefaultEffect = "self = hide; * = VisibleMask.fx;";
>;
sampler LayerMaskSampler = sampler_state
{
	texture = <MERGE(LAYER_NAME, MaskRT)>;
	MinFilter = POINT;
	MagFilter = POINT;
	AddressU = CLAMP;
	AddressV = CLAMP;
};
#endif

struct VS_OUTPUT
{
   float4 Pos: POSITION;
   float2 Tex: TEXCOORD0;
};

VS_OUTPUT BlendVS(float4 Pos : POSITION, float4 Tex : TEXCOORD0)
{ 
	VS_OUTPUT Out;
	
	Out.Pos = Pos;
	Out.Tex = Tex + ViewportOffset;
	
	return Out;
}

#ifdef IS_COMPOSITE_BLENDING

float Lum(float3 rgb)
{
	return rgb.r * 0.3 + rgb.g * 0.59 + rgb.b * 0.11;
}

float3 ClipColor(float3 rgb)
{
	float l = Lum(rgb);
	float n = min(rgb.r, min(rgb.g, rgb.b));
	float x = max(rgb.r, max(rgb.g, rgb.b));
	
	if (n < 0)
	{
		float lMinusN = l - n;
		
		rgb = float3
		(
			l + (rgb.r - l) * l / lMinusN,
			l + (rgb.g - l) * l / lMinusN,
			l + (rgb.b - l) * l / lMinusN
		);
	}
	
	if (x > 1)
	{
		float oneMinusL = 1 - l;
		float xMinusL = x - l;
		
		rgb = float3
		(
			l + (rgb.r - l) * oneMinusL / xMinusL,
			l + (rgb.g - l) * oneMinusL / xMinusL,
			l + (rgb.b - l) * oneMinusL / xMinusL
		);
	}
	
	return rgb;
}

float3 SetLum(float3 rgb, float l)
{
	float d = l - Lum(rgb);
	
	rgb += float3(d, d, d);
	
	return ClipColor(rgb);
}

float Sat(float3 rgb)
{
	return max(rgb.r, max(rgb.g, rgb.b)) - min(rgb.r, min(rgb.g, rgb.b));
}

float3 SetSat(float3 rgb, float s)
{
	float3 rt = rgb;
	float maxValue = max(rgb.r, max(rgb.g, rgb.b));
	float minValue = min(rgb.r, min(rgb.g, rgb.b));
	float midValue =
		rgb.r < maxValue && rgb.r > minValue ? rgb.r :
		rgb.g < maxValue && rgb.g > minValue ? rgb.g :
		rgb.b < maxValue && rgb.b > minValue ? rgb.b : (maxValue + minValue) / 2;
	
	if (maxValue > minValue)
	{
		[unroll]
		for (int i = 0; i < 3; i++)
		{
			if (rgb[i] == midValue)
				rt[i] = (midValue - minValue) * s / (maxValue - minValue);
			else if (rgb[i] == maxValue)
				rt[i] = s;
			else
				rt[i] = 0;
		}
	}
	else
	{
		rt = 0;
	}
	
	return rt;
}

float3 Blend(float3 a, float3 b)
{
#if LAYER_MODE == 17
	return SetLum(SetSat(b, Sat(a)), Lum(a));	// �F��
#elif LAYER_MODE == 18
	return SetLum(SetSat(a, Sat(b)), Lum(a));	// �ʓx
#elif LAYER_MODE == 19
	return SetLum(b, Lum(a));					// �J���[
#elif LAYER_MODE == 20
	return SetLum(a, Lum(b));					// �P�x
#else
	return b;	// �ʏ�
#endif
}

#else

float Blend(float a, float b)
{
#if LAYER_MODE == 1
	return a + b;	// ���Z
#elif LAYER_MODE == 2
	return a - b;	// ���Z
#elif LAYER_MODE == 3
	return a * b;	// ��Z
#elif LAYER_MODE == 4
	return 1 - (1 - a) * (1 - b);	// �X�N���[��
#elif LAYER_MODE == 5
	return a < 0.5
		? a * b * 2
		: 1 - (1 - a) * (1 - b) * 2;	// �I�[�o�[���C
#elif LAYER_MODE == 6
	return b < 0.5
		? a * b * 2
		: 1 - (1 - a) * (1 - b) * 2;	// �n�[�h���C�g
#elif LAYER_MODE == 7
	return (1 - b) * pow(a, 2) + b * (1 - pow(1 - b, 2));	// �\�t�g���C�g
#elif LAYER_MODE == 8
	return b < 0.5
		? (a >= 1 - b * 2 ? 0 : (a - (1 - b * 2)) / (b * 2))
		: (a < 2 - b * 2 ? a / (2 - b * 2) : 1);	// �r�r�b�h���C�g
#elif LAYER_MODE == 9
	return b < 0.5
		? (a < 1 - b * 2 ? 0 : b * 2 + a - 1)
		: (a < 2 - b * 2 ? b * 2 + a - 1 : 1);	// ���j�A���C�g
#elif LAYER_MODE == 10
	return b < 0.5
		? (b * 2 < a ? b * 2 : a)
		: (b * 2 - 1 < a ? a : b * 2 - 1);	// �s�����C�g
#elif LAYER_MODE == 11
	return a > 0 ? a / (1 - b) : 0;	// �����Ă�
#elif LAYER_MODE == 12
	return b > 0 ? 1 - (1 - a) / b : 0;	// �Ă�����
#elif LAYER_MODE == 13
	return min(a, b);	// ��r (��)
#elif LAYER_MODE == 14
	return max(a, b);	// ��r (��)
#elif LAYER_MODE == 15
	return abs(a - b);	// ���̐�Βl
#elif LAYER_MODE == 16
	return a + b - 2 * a * b;	// ���O
#else
	return b;		// �ʏ�
#endif
}

#endif

float4 BlendPS(float2 Tex: TEXCOORD0) : COLOR
{
	float4 background = tex2D(ScreenSampler, Tex);
	
#if LAYER_RT
	float4 foreground = tex2D(LayerSampler, Tex);
#else
	float4 foreground = background;
#endif
	
#if LAYER_MASK
	float4 m = tex2D(LayerMaskSampler, Tex);
	
	#if LAYER_MASK_INVERT
	foreground.a *= m.r * m.a;
	#else
	foreground.a *= 1 - m.r * m.a;
	#endif
#endif
	
#ifdef IS_COMPOSITE_BLENDING
	foreground.rgb = Blend(background.rgb, foreground.rgb);
#else
	[unroll]
	for (int i = 0; i < 3; i++)
		foreground[i] = Blend(background[i], foreground[i]);
#endif
	
	float a = Tr * (Si / 10) * foreground.a;
	
	background.a = min(1, background.a + a);
	background.rgb = lerp(background.rgb, foreground.rgb, a);
	
	return background;
}

////////////////////////////////////////////////////////////////
// �G�t�F�N�g�e�N�j�b�N
//
float4 ClearColor = { 0, 0, 0, 0 };
float ClearDepth = 1;

technique PostEffectTec
<
	string Script =
		"RenderColorTarget0=ScreenBuffer;"
		"RenderDepthStencilTarget=DepthBuffer;"
#if ALPHA_ENABLED
		"ClearSetColor=ClearColor;"
		"ClearSetDepth=ClearDepth;"
#endif
		"Clear=Color;"
		"Clear=Depth;"
		"ScriptExternal=Color;"
		"RenderColorTarget0=;"
		"RenderDepthStencilTarget=;"
#if ALPHA_ENABLED
		"ClearSetColor=ClearColor;"
		"ClearSetDepth=ClearDepth;"
#endif
		"Clear=Color;"
		"Clear=Depth;"
		"Pass=PassBlend;";
>
{
	pass PassBlend < string Script = "Draw=Buffer;"; >
	{
		AlphaBlendEnable = true;
		VertexShader = compile vs_3_0 BlendVS();
		PixelShader  = compile ps_3_0 BlendPS();
	}
};
