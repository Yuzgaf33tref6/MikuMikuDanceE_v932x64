//�p�����[�^

// �ɂ��ݓx�����F�傫���قǂɂ��ށB0�`32���炢�B0�łɂ��݃I�t�B
// �A�N�Z�T����Si�ł������\�B
const float DistortionPower = 16.0;

// ���E�F����������x�����F0.0�`1.0�B
// ��������قǐF�����ς��B
const float EdgeEmphasis = 0.5;

// �F���K�������鐔�F4�`16���炢�B
// �K�������Ȃ��قǁA���̐F���炩�������B
const float PosterizationLevel = 8;

// ���݃}�b�v���쐬���邩? 0:���Ȃ��A1:����
// ���݃}�b�v�����ƃ��f���P�ʁE�ގ��P�ʂş��ݓx�������w��ł���B
#define ENABLE_BLEEDING_MASK	1


// �c�݃e�N�X�`��
// �Ԃ��قǍ��ɘc�ށB�΂قǏ�ɘc�ށB
#define DistortionTexureName	"distortion.png"
//#define DistortionTexureName	"leftdown.png"
//#define DistortionTexureName	"rightdown.png"

// �c�݃e�N�X�`���̌J��Ԃ���
#define DistortionTexureLoopNum	2


// ���n�p�e�N�X�`��
// �e�N�X�`���̍��������قǌ��ʂ������B
// �摜�̐F���Z�������قǉe�����󂯂�B���������⍕�������قǉe�����󂯂Ȃ��B
// Tr�������邱�ƂŌ��ʂ�ጸ�ł���B
#define ColorTexureName		"canvas.png"
//#define ColorTexureName		"flat.png"
#define ColorTexureLoopNum	3


//****************** �ݒ�͂����܂�

// �{�J���T�C�Y
#define MAX_BLUR_NUM	8

// �o�b�t�@�T�C�Y(�傫���l�̂ق����������T�C�Y�ɂȂ�B1/n�ɂȂ�B)
#define BUFFER_SCALE	1
// �G�b�W�����p�o�b�t�@�T�C�Y
#define EDGE_BUFFER_SCALE	4

//�e�N�X�`���t�H�[�}�b�g
#define TEXFORMAT "A16B16G16R16F"
//#define TEXFORMAT "A8B8G8R8"
// �G�b�W�����p�̃e�N�X�`���t�H�[�}�b�g
#define EDGE_TEXFORMAT		"R16F"

float AcsSi : CONTROLOBJECT < string name = "(self)"; string item = "Si"; >;
float AcsTr : CONTROLOBJECT < string name = "(self)"; string item = "Tr"; >;

////////////////////////////////////////////////////////////////////////////////////////////////

#define TEXBUFFRATE {1.0/BUFFER_SCALE, 1.0/BUFFER_SCALE}
#define EDGE_TEXBUFFRATE {1.0/(EDGE_BUFFER_SCALE * BUFFER_SCALE), 1.0/(EDGE_BUFFER_SCALE * BUFFER_SCALE)}

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

#define BlurSize		1
static float2 SampStep = (float2(BlurSize, BlurSize) / (ViewportSize.xx / BUFFER_SCALE));
static float AspectRatio = ViewportSize.y / ViewportSize.x;

// �c�܂����
static float DistortionScale = DistortionPower * (AcsSi / 10.0) / ViewportSize.x;

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
	MinFilter = LINEAR;
	MagFilter = LINEAR;
	MipFilter = LINEAR;
	AddressU  = CLAMP;
	AddressV = CLAMP;
};

texture2D ScnMapWork : RENDERCOLORTARGET <
	int MipLevels = 1;
	float2 ViewportRatio = TEXBUFFRATE;
	string Format = TEXFORMAT;
>;
sampler2D ScnSampWork = sampler_state {
	texture = <ScnMapWork>;
	MinFilter = LINEAR;
	MagFilter = LINEAR;
	MipFilter = LINEAR;
	AddressU  = CLAMP;
	AddressV = CLAMP;
};

// �F�̋��E�����p
texture2D EdgeMap : RENDERCOLORTARGET <
	int MipLevels = 1;
	float2 ViewportRatio = EDGE_TEXBUFFRATE;
	string Format = EDGE_TEXFORMAT;
>;
sampler2D EdgeSamp = sampler_state {
	texture = <EdgeMap>;
	MinFilter = LINEAR;
	MagFilter = LINEAR;
	MipFilter = LINEAR;
	AddressU  = CLAMP;
	AddressV = CLAMP;
};

texture2D EdgeMapWork : RENDERCOLORTARGET <
	int MipLevels = 1;
	float2 ViewportRatio = EDGE_TEXBUFFRATE;
	string Format = EDGE_TEXFORMAT;
>;
sampler2D EdgeSampWork = sampler_state {
	texture = <EdgeMapWork>;
	MinFilter = LINEAR;
	MagFilter = LINEAR;
	MipFilter = LINEAR;
	AddressU  = CLAMP;
	AddressV = CLAMP;
};

#if defined(ENABLE_BLEEDING_MASK) && ENABLE_BLEEDING_MASK > 0
texture ComplexMap: OFFSCREENRENDERTARGET <
	string Description = "OffScreen RenderTarget for ikWaterColor";
	float4 ClearColor = { 1, 0, 0, 1 };
	float2 ViewportRatio = EDGE_TEXBUFFRATE;
	float ClearDepth = 1.0;
	string Format = EDGE_TEXFORMAT;
	bool AntiAlias = false;
	string DefaultEffect = 
		"self = hide;"
		"* = ���݋��x_��.fx";
>;
#else
// ���G�x�}�b�v
texture2D ComplexMap : RENDERCOLORTARGET <
	int MipLevels = 1;
	float2 ViewportRatio = EDGE_TEXBUFFRATE;
	string Format = EDGE_TEXFORMAT;
>;
#endif

sampler2D ComplexSamp = sampler_state {
	texture = <ComplexMap>;
	MinFilter = LINEAR;
	MagFilter = LINEAR;
	MipFilter = LINEAR;
	AddressU  = CLAMP;
	AddressV = CLAMP;
};


// �c�ȗp�}�b�v
#if defined(DistortionTexureName)
texture2D DistortionTex <
	string ResourceName = DistortionTexureName;
>;
sampler DistortionSmp = sampler_state{
	texture = <DistortionTex>;
	MinFilter = LINEAR;
	MagFilter = LINEAR;
	MipFilter = NONE;
	AddressU  = WRAP;
	AddressV = WRAP;
};
#endif

#if defined(ColorTexureName)
texture2D ColorShiftTex <
	string ResourceName = ColorTexureName;
>;
sampler ColorShiftSmp = sampler_state{
	texture = <ColorShiftTex>;
	MinFilter = LINEAR;
	MagFilter = LINEAR;
	MipFilter = NONE;
	AddressU  = WRAP;
	AddressV = WRAP;
};
#endif

//-----------------------------------------------------------------------------
const float Epsilon = 1.0e-4;

// ����hsv: �K�E�X���W�ŐF��������킷�Bh����ɂȂ��Ă��邱�Ƃ��l�������ɍςށB
float4 rgb2hsv( float4 rgb)
{
	float mx = max( rgb.x, max(rgb.y, rgb.z));
	float mn = min( rgb.x, min(rgb.y, rgb.z));
	float v = mx;
	float diff = mx - mn;
	float s = 0;
	float h = 0;
	float2 hue2 = 0;

	if (v > Epsilon && diff > Epsilon)
	{
		s = diff / v;

		float cr = (mx - rgb.x) * (1.0 / diff);
		float cg = (mx - rgb.y) * (1.0 / diff);
		float cb = (mx - rgb.z) * (1.0 / diff);
		if (rgb.x==mx)
		{
			h = cb - cg;
		} else if (rgb.y==mx)
		{
			h = 2.0 + cr - cb;
		} else {
			h = 4.0 + cg - cr;
		}

		h = frac(h * (1.0/6.0) + 1.0);		// h = [0,1)
		float ang = h * 2.0 * PI;
		float l = saturate(diff * 4.0); // �F�̍����傫���ق�hue�̒l�͐M�p�ł���B
		hue2.x = cos(ang) * l;
		hue2.y = sin(ang) * l;
	}

	return float4(hue2.x, s,v, hue2.y);
}

float4 hsv2rgb(float4 hsv)
{
	float h = frac((atan2(hsv.w, hsv.x)) * (0.5 / PI) + 1.0) * 6.0;
	float s = hsv.y * saturate(length(hsv.xw) * 4.0);
	float v = hsv.z;

	float i = floor(h);
	float j = h - i;
	float m = v * (1.0 - s);
	float n = v * (1.0 - s * j);
	float k = v * (1.0 - s * (1.0 - j));

	float3 result = 0;
	result += float3(v,k,m) * max(1.0 - abs(i - 0), 0);
	result += float3(n,v,m) * max(1.0 - abs(i - 1), 0);
	result += float3(m,v,k) * max(1.0 - abs(i - 2), 0);
	result += float3(m,n,v) * max(1.0 - abs(i - 3), 0);
	result += float3(k,m,v) * max(1.0 - abs(i - 4), 0);
	result += float3(v,m,n) * max(1.0 - abs(i - 5), 0);

	return float4(result, 1);
}

inline float rgb2gray(float3 rgb)
{
	return dot(float3(0.299, 0.587, 0.114), rgb);
}

// �|�X�^���[�[�V����
float4 posterize(float4 col)
{
	col.xw = (col.xw + floor(col.xw * PosterizationLevel) / PosterizationLevel) * 0.5;
	col.yz = (col.yz + floor(col.yz * PosterizationLevel + 0.5) / PosterizationLevel) * 0.5;
	return col;
}

//-----------------------------------------------------------------------------
// �Œ��`
//
//-----------------------------------------------------------------------------
struct VS_OUTPUT {
	float4 Pos			: POSITION;
	float2 TexCoord		: TEXCOORD0;
};


//-----------------------------------------------------------------------------
// ���ʂ�VS
VS_OUTPUT VS_SetTexCoord( float4 Pos : POSITION, float4 Tex : TEXCOORD0 ) {
	VS_OUTPUT Out = (VS_OUTPUT)0; 
	Out.Pos = Pos;
	Out.TexCoord = Tex + ViewportOffset.xy;
	return Out;
}

VS_OUTPUT VS_SetTexCoordHalf( float4 Pos : POSITION, float4 Tex : TEXCOORD0 ) {
	VS_OUTPUT Out = (VS_OUTPUT)0; 
	Out.Pos = Pos;
	Out.TexCoord = Tex + BUFFER_SCALE * ViewportOffset.xy;
	return Out;
}

VS_OUTPUT VS_SetTexCoordEdge( float4 Pos : POSITION, float4 Tex : TEXCOORD0 ) {
	VS_OUTPUT Out = (VS_OUTPUT)0; 
	Out.Pos = Pos;
	Out.TexCoord = Tex + (BUFFER_SCALE * EDGE_BUFFER_SCALE) * ViewportOffset.xy;
	return Out;
}


//-----------------------------------------------------------------------------
//
float calcWeight(float4 col0, float4 col1)
{
	float d = distance(col0, col1) * (PosterizationLevel * 0.5);
	return saturate(1 - d);
}

float4 Blur(sampler2D Samp, float2 TexCoord, float2 Offset)
{
	float4 Color0 = tex2D( Samp, TexCoord);
	float4 Color = Color0 * WT[0];
	float weightSum = WT[0];

	for(int i = 1; i < MAX_BLUR_NUM; i++) {
		float w = WT[i];
		float4 Color1 = tex2D( Samp, TexCoord+Offset*i);
		float w1 = calcWeight(Color0, Color1) * w;
		Color += Color1 * w1;
		weightSum += w1;

		float4 Color2 = tex2D( Samp, TexCoord-Offset*i);
		float w2 = calcWeight(Color0, Color2) * w;
		Color += Color2 * w2;
		weightSum += w2;
	}

	Color /= weightSum;
	return Color;
}

//-----------------------------------------------------------------------------
// X Blur
//-----------------------------------------------------------------------------
float4 PS_passX( VS_OUTPUT IN) : COLOR
{
	return Blur(ScnSamp1, IN.TexCoord, float2(SampStep.x  ,0));
}

//-----------------------------------------------------------------------------
// Y Blur
//-----------------------------------------------------------------------------
float4 PS_passY( VS_OUTPUT IN) : COLOR
{
	return Blur(ScnSampWork, IN.TexCoord, float2(0 , SampStep.y));
}


//-----------------------------------------------------------------------------
// �F�̍����傫���Ƃ����T��
float4 PS_ComplexMap( VS_OUTPUT IN) : COLOR
{
	float2 TexCoord = IN.TexCoord;
	float2 offset = SampStep * 4;

	float4 center = tex2D( ScnSamp, TexCoord);

	float4 v = abs(center - tex2D( ScnSamp, TexCoord + offset * float2(-1, -1)));
	v += abs(center - tex2D( ScnSamp, TexCoord + offset * float2(-1,  1)));
	v += abs(center - tex2D( ScnSamp, TexCoord + offset * float2( 1, -1)));
	v += abs(center - tex2D( ScnSamp, TexCoord + offset * float2( 1,  1)));
	float d = (v.x + v.y + v.z) / (3 * 2.0);

	return float4(1 - d, 0, 0, 1);
}

//-----------------------------------------------------------------------------
// �G�b�W���o

// ���x���擾
float4 PS_EdgeMiniMap( VS_OUTPUT IN) : COLOR
{
	float2 TexCoord = IN.TexCoord;
	float2 offset = SampStep * 2;

	// z�R���|�[�l���g��hsv��v�������Ă���
	float v = tex2D( ScnSamp1, TexCoord + offset * float2(-1, -1)).z;
	v = max(v, tex2D( ScnSamp1, TexCoord + offset * float2(-1,  1)).z);
	v = max(v, tex2D( ScnSamp1, TexCoord + offset * float2( 1, -1)).z);
	v = max(v, tex2D( ScnSamp1, TexCoord + offset * float2( 1,  1)).z);
	return float4(v, 0, 0, 1);
}

// �y���{�J��
float4 PS_EdgeBlur( VS_OUTPUT IN) : COLOR
{
	float2 TexCoord = IN.TexCoord;
	float2 offset = SampStep * (EDGE_BUFFER_SCALE * 1.5);

	float v = 0;
	v += tex2D( EdgeSampWork, TexCoord + offset * float2(-1, -1)).r;
	v += tex2D( EdgeSampWork, TexCoord + offset * float2(-1,  0)).r * 2;
	v += tex2D( EdgeSampWork, TexCoord + offset * float2(-1,  1)).r;

	v += tex2D( EdgeSampWork, TexCoord + offset * float2( 0, -1)).r * 2;
	v += tex2D( EdgeSampWork, TexCoord + offset * float2( 0,  0)).r * 4;
	v += tex2D( EdgeSampWork, TexCoord + offset * float2( 0,  1)).r * 2;

	v += tex2D( EdgeSampWork, TexCoord + offset * float2( 1, -1)).r;
	v += tex2D( EdgeSampWork, TexCoord + offset * float2( 1,  0)).r * 2;
	v += tex2D( EdgeSampWork, TexCoord + offset * float2( 1,  1)).r;

	return float4(v * (1 / 16.0), 0, 0, 1);
}

// �G�b�W������
float4 PS_Edge( VS_OUTPUT IN) : COLOR
{
	float2 TexCoord = IN.TexCoord;

	float4 hsv = tex2D( ScnSamp1, TexCoord );
	hsv = posterize(hsv); // �{�J�������Ƃł�����x�ʎq���B

	float bluredV = tex2D( EdgeSamp, TexCoord ).r;

	float weight = max(bluredV - hsv.z, 0);
	float edgeLevel = (PosterizationLevel + 16) * 0.5;
	weight = saturate(weight * edgeLevel) * EdgeEmphasis;

	hsv.y = lerp(hsv.y, 1, weight * 0.5);
	hsv.z = lerp(hsv.z, hsv.z * bluredV, weight);

	return hsv;
}


//-----------------------------------------------------------------------------
// rgb��hsv�ɕϊ�����
float4 PS_ConvertHSV( VS_OUTPUT IN ) : COLOR
{
	float4 Color = tex2D( ScnSamp, IN.TexCoord);
	Color = posterize(rgb2hsv(Color));
	return Color;
}


//-----------------------------------------------------------------------------
// �c�܂���
float4 PS_Last( VS_OUTPUT IN ) : COLOR
{
	float complex = tex2D( ComplexSamp, IN.TexCoord);
	#if defined(DistortionTexureName)
	float2 texCoordD = IN.TexCoord * DistortionTexureLoopNum;
	texCoordD.y *= AspectRatio;
	float2 shift = tex2D(DistortionSmp, texCoordD).xy * 2.0 - 1.0;
	float shiftLen = saturate(length(shift) * complex);
	shift = shift * DistortionScale * complex;
	#else
	float2 shift = 0;
	float shiftLen = 0;
	#endif

	float3 ColorMul = 1;

	float4 Color = tex2D( ScnSampWork, IN.TexCoord + shift);
	float4 ColorOrig = tex2D( ScnSampWork, IN.TexCoord);

	float2 hue = normalize(Color.xw);
	float2 hueOrig = normalize(ColorOrig.xw);
	float dotH = dot(hue, hueOrig);
	if (dotH < -0.3)
	{
		// �ʂ̌n���̐F �� �F���d�Ȃ�
		ColorMul = lerp(1, hsv2rgb(ColorOrig).rgb, Color.y * Color.z);
	}
	else if (dotH > 0.7 && (Color.y < ColorOrig.y && Color.z > ColorOrig.z))
	{
		// �����n���̐F �� �F������
		// �{�������Ȃ�͂��̕�����Z������
		Color = lerp(Color, ColorOrig, shiftLen);
	}

	#if defined(ColorTexureName)
	float2 texCoord = IN.TexCoord * ColorTexureLoopNum;
	texCoord.y *= AspectRatio;
	float d = tex2D(ColorShiftSmp, texCoord);
	d = lerp(1.0, d, AcsTr);
	float mask = (Color.y * Color.z); // �����قǃe�N�X�`���̉e�����󂯂Ȃ��B
	Color.y = lerp(Color.y, Color.y * d, mask);
	Color.z = lerp(1 - (1 - Color.z) * d, Color.z, mask);
	#endif

	Color = hsv2rgb(Color);
	Color.rgb *= ColorMul;

	return Color;
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

		// HSV�ɕϊ�+�|�X�^���[�[�V����
		"RenderColorTarget0=ScnMap1;"
		"Pass=ConvertHSVPass;"

		// �{�J�����|����
		"RenderColorTarget0=ScnMapWork;"
		"Pass=Gaussian_X;"
		"RenderColorTarget0=ScnMap1;"
		"Pass=Gaussian_Y;"

		#if !defined(ENABLE_BLEEDING_MASK) || ENABLE_BLEEDING_MASK == 0
			// ���G�x�}�b�v�F�G���ׂ��������͟��ݗʂ����炷�B
			"RenderColorTarget0=ComplexMap;"
			"Pass=ComplexMapPass;"
		#endif

		// �G�b�W�����p�̃~�j�}�b�v�̍쐬
		"RenderColorTarget0=EdgeMapWork;"
		"Pass=EdgeMiniMapPass;"

		"RenderColorTarget0=EdgeMap;"
		"Pass=EdgeBlurPass;"

		// �G�b�W�̋���
		"RenderColorTarget0=ScnMapWork;"
		"Pass=EdgePass;"

		// �c�܂���
		"RenderColorTarget0=;"
		"RenderDepthStencilTarget=;"
		"Pass=LastPass;"
	;
> {
	pass ComplexMapPass < string Script= "Draw=Buffer;"; > {
		AlphaBlendEnable = FALSE;
		AlphaTestEnable = FALSE;
		VertexShader = compile vs_3_0 VS_SetTexCoordEdge();
		PixelShader  = compile ps_3_0 PS_ComplexMap();
	}

	pass EdgeMiniMapPass < string Script= "Draw=Buffer;"; > {
		AlphaBlendEnable = FALSE;
		AlphaTestEnable = FALSE;
		VertexShader = compile vs_3_0 VS_SetTexCoordEdge();
		PixelShader  = compile ps_3_0 PS_EdgeMiniMap();
	}

	pass EdgeBlurPass < string Script= "Draw=Buffer;"; > {
		AlphaBlendEnable = FALSE;
		AlphaTestEnable = FALSE;
		VertexShader = compile vs_3_0 VS_SetTexCoordEdge();
		PixelShader  = compile ps_3_0 PS_EdgeBlur();
	}

	pass EdgePass < string Script= "Draw=Buffer;"; > {
		AlphaBlendEnable = FALSE;
		AlphaTestEnable = FALSE;
		VertexShader = compile vs_3_0 VS_SetTexCoordEdge();
		PixelShader  = compile ps_3_0 PS_Edge();
	}


	pass ConvertHSVPass < string Script= "Draw=Buffer;"; > {
		AlphaBlendEnable = FALSE;
		AlphaTestEnable = FALSE;
		VertexShader = compile vs_3_0 VS_SetTexCoordHalf();
		PixelShader  = compile ps_3_0 PS_ConvertHSV();
	}

	pass Gaussian_X < string Script= "Draw=Buffer;"; > {
		AlphaBlendEnable = FALSE;
		AlphaTestEnable = FALSE;
		VertexShader = compile vs_3_0 VS_SetTexCoordHalf();
		PixelShader  = compile ps_3_0 PS_passX();
	}

	pass Gaussian_Y < string Script= "Draw=Buffer;"; > {
		AlphaBlendEnable = FALSE;
		AlphaTestEnable = FALSE;
		VertexShader = compile vs_3_0 VS_SetTexCoordHalf();
		PixelShader  = compile ps_3_0 PS_passY();
	}

	pass LastPass < string Script= "Draw=Buffer;"; > {
		AlphaBlendEnable = FALSE;
		AlphaTestEnable = FALSE;
		VertexShader = compile vs_3_0 VS_SetTexCoord();
		PixelShader  = compile ps_3_0 PS_Last();
	}
}
////////////////////////////////////////////////////////////////////////////////////////////////
