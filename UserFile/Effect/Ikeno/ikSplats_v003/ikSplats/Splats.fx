////////////////////////////////////////////////////////////////////////////////////////////////
//
////////////////////////////////////////////////////////////////////////////////////////////////

// �p�^�[���e�N�X�`��
// ���������������ŁA�����ꏊ�ɐF�����B
#define TEX_FileName	"Patterns/splats.png"
//#define TEX_FileName	"Patterns/boxes.png"
//#define TEX_FileName	"Patterns/circles.png"
//#define TEX_FileName	"Patterns/stars.png"

// �p�^�[���e�N�X�`�����̃p�^�[����
#define TEX_X_UNIT		4	// ��
#define TEX_Y_UNIT		4	// �s��


// ���邳���������H�Ώۂɂ���B0���ƐF���͂ݏo��B
#define SYNTH_Y_ONLY	1


// �p�^�[���̕\���T�C�Y
// �f�t�H���g��1�B�傫���قǑ�G�c�A�������قǌ��Ԃ��ł���B
// �A�N�Z�T����Si�ł��S�̃T�C�Y���w��\ 
#define PATTERN_SCALE_MIN	(1.0)
#define PATTERN_SCALE_MAX	(1.2)


// �F���������ω������邩? ����ł̃`�����h�~�B�Î~��ł͕s�v�B
#define ENABLE_FADE		1
// �F���ω����鑬�x�F0.1�`1.0 �������قǂ������ω�����B
// ��ʂ��傫���ς��ꍇ�ɁA1.0�ɋ߂��ƃ`���t���Č�����B
// �����߂���ƁA�u���[���|�������悤�Ɍ�����B
#define COLOR_FADE_SPEED	0.3


// ���ԕω��ɍ��킹�ăp�^�[����ω������邩?
#define ENABLE_MOVEMENT	1
// ���ԕω��Ńp�^�[���̓�����
#define TimeScale	(1.0)
// ���Ԃɂ���ĕω�������Ԋu�B
// 1�Ȃ�1�b�����ɕ\������p�^�[���̈ʒu���ς��B0�Ȃ疈�t���[���ω�����B
#define TimeQuantize	(0.0)
// �ҏW�����ω������邩?
#define ANIM_IN_EDIT		1


// �p�^�[���̕\�����B1�`8���x�B (���ۂɂ͂��̐���x1024�\�������B)
// �� �w��̃p�^�[�����ŉ�ʑS�̂𕢂���悤�ɁA�p�^�[���̃T�C�Y���ω�����B
#define UNIT_COUNT		4

// �e�X�g�p�FVS�ł͂Ȃ�PS�ŐF���E����? 0:VS�ŐF���Ƃ�B1:PS�ŐF���Ƃ�
#define ENABLE_PS_COLOR_FETCH	0

////////////////////////////////////////////////////////////////////////////////////////////////

// �ގ����ɃG�t�F�N�g�̊|���肮�����𒲐��\�ɂ���
#define ADAPTIVE_SIZE		1

#define PARTICLE_COUNT		1024


float AcsTr  : CONTROLOBJECT < string name = "(self)"; string item = "Tr"; >;
float AcsSi  : CONTROLOBJECT < string name = "(self)"; string item = "Si"; >;

int RepeatCount = UNIT_COUNT;  // �V�F�[�_���`�攽����
int RepeatIndex;				// �������f���J�E���^

// ���Ԑݒ�
float timeFrame : TIME < bool SyncInEditMode = true; >;
float timeEditor : TIME < bool SyncInEditMode = false; >;
#if defined(ENABLE_MOVEMENT) && ENABLE_MOVEMENT > 0
inline float GetTime()
{
	#if defined(ANIM_IN_EDIT) && ANIM_IN_EDIT > 0
		return timeEditor;
	#else
		return timeFrame;
	#endif
}
static float time = ((TimeQuantize <= 1.0/30.0)
		 ? GetTime() : (floor(GetTime() * (1.0 / TimeQuantize)) * TimeQuantize)) * TimeScale;
#else
static float time = 0;
#endif
// ����������?
inline bool IsTimeToReset() { return (timeFrame != timeEditor || timeFrame < 1.0/60.0); }


float Script : STANDARDSGLOBAL <
	string ScriptOutput = "color";
	string ScriptClass = "sceneorobject";
	string ScriptOrder = "postprocess";
> = 0.8;


// �X�N���[���T�C�Y
float2 ViewportSize : VIEWPORTPIXELSIZE;
static float2 ViewportOffset = (float2(0.5,0.5)/ViewportSize.xy);
static float AspectRatio = ViewportSize.x / ViewportSize.y;
static int GridY = sqrt( PARTICLE_COUNT * UNIT_COUNT / AspectRatio);
static int GridX = GridY * AspectRatio;

static float2 SampStep = (float2(1, 1) / (ViewportSize.xx / 2.0));

// �����_�����O�^�[�Q�b�g�̃N���A�l
float4 ClearColor = {1,1,1,1};
float ClearDepth  = 1.0;

//sampler MMDSamp0 : register(s0);

// �I���W�i���̕`�挋�ʂ��L�^���邽�߂̃����_�[�^�[�Q�b�g
texture2D ScnMap : RENDERCOLORTARGET <
	int MipLevels = 1;
	float2 ViewportRatio = {1.0, 1.0};
	string Format = "A8R8G8B8";
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

#if defined(ADAPTIVE_SIZE) && ADAPTIVE_SIZE > 0
texture SplatSizeMap: OFFSCREENRENDERTARGET <
	string Description = "OffScreen RenderTarget for Splats";
	float4 ClearColor = { 1, 0, 0, 1 };
	float2 ViewportRatio = {0.5, 0.5};
	float ClearDepth = 1.0;
	string Format = "L8";
	bool AntiAlias = false;
	int MipLevels = 1;
	string DefaultEffect = 
		"self = hide;"
		"*.pmx = SplatSize/SplatSize_��.fx;"
		"*.pmx = SplatSize/SplatSize_��.fx;"
		"*.x = SplatSize/SplatSize_��.fx;";
>;

sampler2D SplatSizeSamp = sampler_state {
	texture = <SplatSizeMap>;
	MinFilter = LINEAR;
	MagFilter = LINEAR;
	MipFilter = LINEAR;
	AddressU  = CLAMP;
	AddressV = CLAMP;
};

texture2D SplatSizeMapWork : RENDERCOLORTARGET <
	float2 ViewportRatio = {0.5, 0.5};
	int MipLevels = 1;
	string Format = "L8";
>;
sampler2D SplatSizeSampWork = sampler_state {
	texture = <SplatSizeMapWork>;
	MinFilter = LINEAR;	MagFilter = LINEAR;	MipFilter = LINEAR;
	AddressU  = CLAMP;	AddressV = CLAMP;
};

texture2D SplatSizeMapWork2 : RENDERCOLORTARGET <
	float2 ViewportRatio = {0.5, 0.5};
	int MipLevels = 1;
	string Format = "L8";
>;
sampler2D SplatSizeSampWork2 = sampler_state {
	texture = <SplatSizeMapWork2>;
	MinFilter = LINEAR;	MagFilter = LINEAR;	MipFilter = LINEAR;
	AddressU  = CLAMP;	AddressV = CLAMP;
};

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

#endif


#define TEX_WIDTH	UNIT_COUNT		// ���W���e�N�X�`���s�N�Z����
#define TEX_HEIGHT	PARTICLE_COUNT	// �z�u�E�������e�N�X�`���s�N�Z������

#if defined(ENABLE_FADE) && ENABLE_FADE > 0
texture2D ColorMapTex : RENDERCOLORTARGET
<
	int2 Dimensions = {TEX_WIDTH, TEX_HEIGHT};
	string Format = "A8R8G8B8";
>;
sampler2D ColorSamp = sampler_state
{
	Texture = <ColorMapTex>;
	Filter = NONE;
	AddressU  = CLAMP;
	AddressV  = CLAMP;
};

texture CoordDepthBuffer : RenderDepthStencilTarget <
	int2 Dimensions = {TEX_WIDTH, TEX_HEIGHT};
	string Format = "D24S8";
>;
#endif

texture2D ParticleTex <
	string ResourceName = TEX_FileName;
	int MipLevels = 1;
>;
sampler2D ParticleTexSamp = sampler_state {
	texture = <ParticleTex>;
	MinFilter = LINEAR;
	MagFilter = LINEAR;
	MipFilter = NONE;
	AddressU  = CLAMP;
	AddressV  = CLAMP;
};



float3x3 RoundMatrixZ(int index, float etime)
{
	float s = sign((index % 2) * 2.0 - 1.0);
	float rotZ = (1.0f + 0.3f*sin(122.0*index)) * etime * s;

	float sinz, cosz;
	sincos(rotZ, sinz, cosz);

	float3x3 rMat = { cosz, sinz, 0,
					-sinz, cosz,  0,
					 0,		0,		1,};

	return rMat;
}


// YUV�ϊ�
static float3x3 matToYUV = {
	 0.2126,	-0.09991,	 0.615,
	 0.7152,	-0.33609,	-0.55861,
	 0.0722,	 0.436,		-0.05639
/*
	 0.299,		-0.14713,	 0.615,
	 0.587,		-0.28886,	-0.51499,
	 0.114,		 0.436,		-0.10001
*/
};

static float3x3 matToRGB = {
	 1.0,		 1.0,		 1.0,
	 0.0,		-0.21482,	 2.12798,
	 1.28033,	-0.38059,	 0.0
/*
	 1.0,		 1.0,		 1.0,
	 0.0,		-0.39465,	 2.03211,
	 1.13983,	-0.58060,	 0.0
*/
};

inline float3 RGBtoYUV(float3 rgb) { return mul(rgb, matToYUV);}
inline float3 YUVtoRGB(float3 yuv) { return mul(yuv, matToRGB);}



////////////////////////////////////////////////////////////////////////////////////////////////

struct VS_OUTPUT {
	float4 Pos : POSITION;
	float2 Tex : TEXCOORD0;
};

// ���ʂ̒��_�V�F�[�_
VS_OUTPUT Common_VS(float4 Pos: POSITION, float2 Tex: TEXCOORD, uniform int level)
{
	VS_OUTPUT Out;
	Out.Pos = Pos;
	Out.Tex = Tex + ViewportOffset * level;
	return Out;
}

float4 Scene_PS( VS_OUTPUT IN) : COLOR0
{
	return tex2D(ScnSamp, IN.Tex);
}


#if defined(ADAPTIVE_SIZE) && ADAPTIVE_SIZE > 0
float4 Blur(sampler2D Samp, float2 TexCoord, float2 Offset)
{
	float Color0 = tex2D( Samp, TexCoord).r;
	float Color = Color0 * WT[0];

	[unroll] for(int i = 1; i < 8; i++) {
		float w = WT[i];
		Color += tex2D( Samp, TexCoord+Offset*i).r * w;
		Color += tex2D( Samp, TexCoord-Offset*i).r * w;
	}

	return float4(min(Color0, Color), 0,0,1);
}

float4 PS_passX( VS_OUTPUT IN) : COLOR
{
	return Blur(SplatSizeSamp, IN.Tex, float2(SampStep.x  ,0));
}

float4 PS_passY( VS_OUTPUT IN) : COLOR
{
	return Blur(SplatSizeSampWork, IN.Tex, float2(0 , SampStep.y));
}
#endif


///////////////////////////////////////////////////////////////////////////////////////

#if defined(ENABLE_FADE) && ENABLE_FADE > 0
VS_OUTPUT GetColor_VS(float4 Pos: POSITION, float2 Tex: TEXCOORD)
{
	VS_OUTPUT Out;
	Out.Pos = Pos;
	Out.Tex = Tex + float2(0.5f/TEX_WIDTH, 0.5f/TEX_HEIGHT);
	return Out;
}

float4 GetColor_PS( VS_OUTPUT IN) : COLOR
{
	int i = floor( IN.Tex.x * TEX_WIDTH );
	int j = floor( IN.Tex.y * TEX_HEIGHT );
	int Index0 = i * PARTICLE_COUNT + j;
	float posx = (Index0 % GridX) * (1.0 / GridX);
	float posy = (Index0 / GridX) * (1.0 / GridY);
	float2 Pos0 = float2(posx, posy);
	Pos0.y = 1 - Pos0.y;
	float4 Color = tex2D(ScnSamp, Pos0.xy);

	// �ҏW���̓t�F�[�h�I�t
	Color.a = IsTimeToReset() ? 1.0 : COLOR_FADE_SPEED;
	return Color;
}
#endif

///////////////////////////////////////////////////////////////////////////////////////
// �p�[�e�B�N���`��

struct VS_OUTPUT2
{
	float4 Pos		: POSITION;	// �ˉe�ϊ����W
	float2 Tex		: TEXCOORD0;	// �e�N�X�`��
	float4 WPos		: TEXCOORD1;	// 
	float4 Tex2		: TEXCOORD2;	// 
	float4 Color	: COLOR0;		// ���q�̏�Z�F
};

inline float4 GetColor(float4 uv)
{
	float4 Color = 1;

	#if defined(ENABLE_FADE) && ENABLE_FADE > 0
		Color.rgb = tex2Dlod(ColorSamp, uv);
	#else
		Color.rgb = tex2Dlod(ScnSamp, uv);
	#endif

	#if defined(SYNTH_Y_ONLY) && SYNTH_Y_ONLY > 0
	Color.xyz = RGBtoYUV(Color.rgb);
	#endif

	return Color;
}

// ���_�V�F�[�_
VS_OUTPUT2 Particle_VS(float4 Pos : POSITION, float2 Tex : TEXCOORD0)
{
	VS_OUTPUT2 Out=(VS_OUTPUT2)0;

	int i = RepeatIndex;
	int j = round( Pos.z * 100.0f );
	int Index0 = i * PARTICLE_COUNT + j;

	// ���q�̍��W
	float posx = (Index0 % GridX) * (1.0 / GridX);
	float posy = (Index0 / GridX) * (1.0 / GridY);
	float2 Pos0 = float2(posx, posy);
	float4 TexPos = float4(Pos0.xy, 0,0);
	TexPos.y = 1 - TexPos.y;

	float depth = frac(abs(sin(Index0)));
	float scale = frac(abs(sin(Index0 + time)));

	Pos.x += sin(posx * 3.0 + posy * 5.0 + 2) * 0.01;
	Pos.y += sin(posx * 5.0 + posy * 3.0 + 1) * 0.01 * AspectRatio;

	// ���q�̑傫��
	scale = (lerp(PATTERN_SCALE_MIN, PATTERN_SCALE_MAX, scale) * (1.0 / GridX) * 10.0 * 4.0);
	scale *= (AcsSi * 0.1);
	#if defined(ADAPTIVE_SIZE) && ADAPTIVE_SIZE > 0
	scale *= tex2Dlod(SplatSizeSampWork2, TexPos).r;
	#endif
	Pos.xy *= scale;

	// ���q�̉�]
	float3x3 matWTmp = RoundMatrixZ(Index0, time);
	Pos.xy = mul( Pos.xy, (float2x2)matWTmp );
	Pos.y *= AspectRatio;

	// ���q�̃��[���h���W
	Pos.xy += (Pos0.xy * 2.0 - 1.0);
	Pos.z = 1.0f;
	Pos.w = 1.0f + depth;
	Pos.xyz *= Pos.w;
	Out.Pos = Pos;
	Out.WPos = Pos;

	// �e�N�X�`��
	int tindex = floor(abs(sin(Index0) * 1024)) % (TEX_X_UNIT * TEX_Y_UNIT);
	int tex_i = tindex % TEX_X_UNIT;
	int tex_j = tindex / TEX_X_UNIT;
	Out.Tex = float2((Tex.x + tex_i) * (1.0 / TEX_X_UNIT), (Tex.y + tex_j) * (1.0 / TEX_Y_UNIT));

	// �F
	#if defined(ENABLE_FADE) && ENABLE_FADE > 0
	float4 coluv = float4((i * 1.0 + 0.5) / TEX_WIDTH, (j * 1.0 + 0.5) / TEX_HEIGHT, 0,0);
	#else
	float4 coluv = TexPos;
	#endif
	#if defined(ENABLE_PS_COLOR_FETCH) && ENABLE_PS_COLOR_FETCH > 0
	Out.Tex2 = coluv;
	Out.Color = 1;
	#else
	Out.Color = GetColor(coluv);
	#endif

	// �p�[�e�B�N���̃I���I�t
	Out.Color.a *= ((frac(sin(posx * GridX * 7.2 + posy * GridY * 11.4) * 48.06636759855)) < AcsTr);

	return Out;
}


float4 Particle_PS( VS_OUTPUT2 IN) : COLOR0
{
	float4 Color = IN.Color;
	#if defined(ENABLE_PS_COLOR_FETCH) && ENABLE_PS_COLOR_FETCH > 0
	Color.rgb = GetColor(IN.Tex2).rgb;
	#endif

	float alpha = 1.0 - tex2D( ParticleTexSamp, IN.Tex ).r;
	Color.a *= alpha;

	float2 uv = IN.WPos.xy / IN.WPos.w;
	uv.y = -uv.y;
	uv = uv * 0.5 + 0.5 + ViewportOffset;

	#if defined(ADAPTIVE_SIZE) && ADAPTIVE_SIZE > 0
	float size = tex2D(SplatSizeSampWork2, uv + ViewportOffset).r;
	Color.a *= size;
	#endif

	#if defined(SYNTH_Y_ONLY) && SYNTH_Y_ONLY > 0
	float3 YUVOrig = RGBtoYUV(tex2D(ScnSamp, uv).rgb);
	Color.rgb = YUVtoRGB(float3(Color.x, YUVOrig.yz));
	#endif

	return Color;
}


///////////////////////////////////////////////////////////////////////////////////////
// �e�N�j�b�N
technique MainTec <
	string MMDPass = "object";
	string Script = 
		"RenderColorTarget0=ScnMap;"
		"RenderDepthStencilTarget=DepthBuffer;"
		"ScriptExternal=Color;"

		#if defined(ADAPTIVE_SIZE) && ADAPTIVE_SIZE > 0
		"RenderColorTarget0=SplatSizeMapWork;"
		"Pass=Gaussian_X;"
		"RenderColorTarget0=SplatSizeMapWork2;"
		"Pass=Gaussian_Y;"
		#endif

		#if defined(ENABLE_FADE) && ENABLE_FADE > 0
		"RenderColorTarget0=ColorMapTex;"
		"RenderDepthStencilTarget=CoordDepthBuffer;"
		"Pass=GetColorPass;"
		#endif

		"RenderColorTarget0=;"
		"RenderDepthStencilTarget=;"
		"ClearSetColor=ClearColor;"
		"ClearSetDepth=ClearDepth;"
		"Clear=Color;"
		"Clear=Depth;"
		"Pass=DrawScene;"

		"LoopByCount=RepeatCount;"
		"LoopGetIndex=RepeatIndex;"
			"Pass=DrawObject;"
		"LoopEnd=;"
		;
>{
	#if defined(ADAPTIVE_SIZE) && ADAPTIVE_SIZE > 0
	pass Gaussian_X < string Script= "Draw=Buffer;"; > {
		AlphaBlendEnable = FALSE;		AlphaTestEnable = FALSE;
		VertexShader = compile vs_3_0 Common_VS(2);
		PixelShader  = compile ps_3_0 PS_passX();
	}

	pass Gaussian_Y < string Script= "Draw=Buffer;"; > {
		AlphaBlendEnable = FALSE;		AlphaTestEnable = FALSE;
		VertexShader = compile vs_3_0 Common_VS(2);
		PixelShader  = compile ps_3_0 PS_passY();
	}
	#endif

	#if defined(ENABLE_FADE) && ENABLE_FADE > 0
	pass GetColorPass < string Script= "Draw=Buffer;"; > {
		AlphaBlendEnable = TRUE;
		VertexShader = compile vs_3_0 GetColor_VS();
		PixelShader  = compile ps_3_0 GetColor_PS();
	}
	#endif

	pass DrawScene < string Script= "Draw=Buffer;"; > {
		VertexShader = compile vs_3_0 Common_VS(1);
		PixelShader  = compile ps_3_0 Scene_PS();
	}

	pass DrawObject {
		ZEnable = FALSE;
		VertexShader = compile vs_3_0 Particle_VS();
		PixelShader  = compile ps_3_0 Particle_PS();
	}
}

