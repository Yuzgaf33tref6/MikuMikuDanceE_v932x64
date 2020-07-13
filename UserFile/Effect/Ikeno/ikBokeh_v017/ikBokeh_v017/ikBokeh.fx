//=============================================================================
// ikBokeh.fx
// �|�X�g�v���Z�X�Ŕ�ʊE�[�x�̃G�~�����[�g���s���B
//=============================================================================


// 32bit�ł�MME���g�p���Ă���B0:64bit�ŁA1:32bit��
#define USE_MME_32BIT		1


// �����I�ɋʃ{�P�̃T�C�Y���X�P�[�����O����B1:���{(�f�t�H���g)�A2:2�{�ɂȂ�B
// �ʓr�ݒ肳��Ă���T�C�Y����𒴂��邱�Ƃ͂Ȃ��B
#define FORCE_COC_SCALE		(1.0)

// �O�{�P�̑傫���B0.1�`1.0�B0�ɋ߂Â��邱�ƂőO�{�P������������
#define FRONT_BOKEH_SCALE		(1.0)

// �O�����琧�䂷��R���g���[���̖��O
#define CONTROLLER_NAME		"ikBokehController.pmx"

// �I�[�g�t�H�[�J�X�̊�ʒu
// �ʏ�̓A�N�Z�T���ɂ̂܂܂ɂ��Ă����A�A�N�Z�T�����s���g�����킹�����{�[���ɂԂ牺����B
//#define	AF_MODEL_NAME	"ikBokeh.x"
#define	AF_MODEL_NAME	"(self)"
//#define	AF_BONE_NAME	"��"

// �e�X�g���[�h�L���ݒ�B
// ENABLE_TEST_MODE��1�̂Ƃ��A���[�t�̃e�X�g���[�h��1�ɂ��邱�ƂŃs���g�\�����s���B
#define	ENABLE_TEST_MODE		1

// ���Ԃ̓����F�ҏW�����Y�[�����Ԃ��l�����邩?
#define	TimeSync		1

// �R���g���[���������ꍇ�̑������[�h�̒l
// 0: �A�N�Z�T���̈ʒu
// 1: ��ʒ���(��)�Ƀs���g�����킹��
// 2: ��ʒ���(�L)�Ƀs���g�����킹��
#define	DEFAULT_MEASURING_MODE	0

// 0:�G�t�F�N�g�����A1:�G�t�F�N�g�L��
#define BOKEH_LEVEL		1

// 1��Ń{�J���T�C�Y (6-8���x�B�������قǍ����B)
#define BULR_SIZE		8

// �ʃ{�P�̋����F�ʃ{�PDOF(Elle/�f�[�^P)����ؗp
#define ENABLE_EMPHASIZE_COLOR	1
// �ő勭���x��
#define EMPHASIZE_RATE	4

// �k���o�b�t�@��ǉ����邩�ǂ����B
#define ENABLE_DEEP_LEVEL	0

//****************** �ݒ�͂����܂�
//****************** �ȉ��́A�M��Ȃ��ق��������ݒ荀��

// �e�N�X�`���t�H�[�}�b�g
//	HDR���g���Ȃ�A���������_�ł���K�v������B
//#define TEXFORMAT "A32B32G32R32F"
#define TEXFORMAT "A16B16G16R16F"
//#define TEXFORMAT "A8R8G8B8"

// �v�Z�p�e�N�X�`���̃t�H�[�}�b�g
//	���������_�łȂ��ƌv�Z���ʂ��ێ��ł��Ȃ��B
#define WORK_TEXFORMAT "A16B16G16R16F"


// �P�ʒ����p�̕ϐ��B
#define		m	(10.0)	// 1MMD�P�� = 10cm�B�{����8cm���x?
#define		cm	(m * 0.01)
#define		mm	(m * 0.001)

// �R���g���[���̃��[�t�Őݒ肵���p�����[�^�̃X�P�[���l
#define AbsoluteFocusScale		100.0			// ��΃s���g����(m)
#define RelativeFocusScale		50.0			// ���΃s���g����(m)
#define FocalLengthScale		100.0			// �œ_����(mm)
#define DefaultFNumber			4.0				// �f�t�H���g�̍i��
#define FNumberScale			4.0				// �i��W��
#define BokehFocalLengthScaleP	1.0				// �{�P�������̏œ_����(�{�P����)
#define BokehFocalLengthScaleM	1.0				// �{�P�������̏œ_����(�{�P����)

// �����I�Ȑ���
const float MinFocusDistance = (0.1 * m);
const float MinFocalLength = (20.0 * mm);
const float MaxFocalLength = (200.0 * mm);
const float MinFNumber = 1.0;
const float MaxFNumber = 16.0;

const float gamma = 2.2;
#define	PI	(3.14159265359)

// �t�B�����T�C�Y�B��ʓI��35mm��70mm���g��(�炵��)
const float FilmSize = 35 * mm;

// �Ȃɂ��`�悵�Ȃ��ꍇ�̔w�i�܂ł̋���
// �����M���蕁�ʂɃX�J�C�h�[���Ȃǂ̔w�i���������ق��������B
// �M��ꍇ�AikDepth.fx�̓����̒l���ύX����K�v������B
#define FAR_DEPTH		1000

//****************** �ݒ�͂����܂�

#define Rad2Deg(x)	((x) * 180 / PI)

float4x4 matV : VIEW;
float4x4 matP : PROJECTION;
float3 CameraPosition	: POSITION  < string Object = "Camera"; >;

float time1 : TIME;
float time2 : TIME < bool SyncInEditMode = true; >;
static float time = TimeSync ? time1 : time2;
float elapsed_time1 : ELAPSEDTIME;
float elapsed_time2 : ELAPSEDTIME < bool SyncInEditMode = true; >;
static float Dt = clamp(TimeSync ? elapsed_time1 : elapsed_time2, 1.0/120.0, 1.0/15.0);

#ifdef AF_BONE_NAME
float3 AFPosition : CONTROLOBJECT < string name = AF_MODEL_NAME; string item = AF_BONE_NAME; >;
#else
float3 AFPosition : CONTROLOBJECT < string name = AF_MODEL_NAME; >;
#endif

// �O���R���g���[��
bool isExistController : CONTROLOBJECT < string name = CONTROLLER_NAME; >;
float3 mCtrlPosition : CONTROLOBJECT < string name = CONTROLLER_NAME; string item = "�S�Ă̐e";>;
float mPintDistanceP : CONTROLOBJECT < string name = CONTROLLER_NAME; string item = "�s���g����+"; >;
float mPintDistanceM : CONTROLOBJECT < string name = CONTROLLER_NAME; string item = "�s���g����-"; >;

float mPintDelayParam : CONTROLOBJECT < string name = CONTROLLER_NAME; string item = "�s���g�x��"; >;
float mPintFrictionParam : CONTROLOBJECT < string name = CONTROLLER_NAME; string item = "�s���g����x"; >;
static float mPintDelay = (isExistController || DEFAULT_MEASURING_MODE == 0) ? mPintDelayParam : 0.8;
static float mPintFriction = (isExistController || DEFAULT_MEASURING_MODE == 0) ? mPintFrictionParam : 0.5;

float mMeasuringXP : CONTROLOBJECT < string name = CONTROLLER_NAME; string item = "�����_x+"; >;
float mMeasuringXM : CONTROLOBJECT < string name = CONTROLLER_NAME; string item = "�����_x-"; >;
float mMeasuringYP : CONTROLOBJECT < string name = CONTROLLER_NAME; string item = "�����_y+"; >;
float mMeasuringYM : CONTROLOBJECT < string name = CONTROLLER_NAME; string item = "�����_y-"; >;
static float2 mMeasuringPosition = float2(mMeasuringXP - mMeasuringXM, mMeasuringYP - mMeasuringYM) * 0.5 + 0.5 + mCtrlPosition.xy * float2(1, -1) * 0.1;

//float mFNumber : CONTROLOBJECT < string name = CONTROLLER_NAME; string item = "�i��"; >;
float mBokehP : CONTROLOBJECT < string name = CONTROLLER_NAME; string item = "�{�P+"; >;
float mBokehM : CONTROLOBJECT < string name = CONTROLLER_NAME; string item = "�{�P-"; >;
float mFBokehM : CONTROLOBJECT < string name = CONTROLLER_NAME; string item = "�O�{�P-"; >;
float mCoCSize : CONTROLOBJECT < string name = CONTROLLER_NAME; string item = "CoC�T�C�Y"; >;
float mEmphasize : CONTROLOBJECT < string name = CONTROLLER_NAME; string item = "�ʃ{�P����"; >;
static float mEmphasizeScale = EMPHASIZE_RATE * (0.1 + mEmphasize);

float mTestMode : CONTROLOBJECT < string name = CONTROLLER_NAME; string item = "�e�X�g���[�h"; >;

float mAFModeParam : CONTROLOBJECT < string name = CONTROLLER_NAME; string item = "AF�������[�h"; >;
static int mAFMode = (isExistController) ? (int)(mAFModeParam * 3.0 + 0.1) : DEFAULT_MEASURING_MODE;
float mManualMode : CONTROLOBJECT < string name = CONTROLLER_NAME; string item = "�}�j���A�����[�h"; >;
float mPintDistance : CONTROLOBJECT < string name = CONTROLLER_NAME; string item = "�s���g����"; >;
float mFocalLength : CONTROLOBJECT < string name = CONTROLLER_NAME; string item = "�œ_����"; >;

bool bLinearMode : CONTROLOBJECT < string name = "ikLinearEnd.x"; >;

float AcsSi : CONTROLOBJECT < string name = "(self)"; string item = "Si"; >;
static float ForceCoCSacle = FORCE_COC_SCALE * AcsSi * 0.1 * (mCoCSize + 1.0);


//=============================================================================

float Script : STANDARDSGLOBAL <
	string ScriptOutput = "color";
	string ScriptClass = "scene";
	string ScriptOrder = "postprocess";
> = 0.8;

#define ScreenScale		1
#define MinimumCoCRadius	0.01		// CoC�̍Œ�ۏؒl�B����������Ɣ��U����B

// �{�P�̔��a���
#define MAX_COC_SIZE	((BULR_SIZE) * 8)

// ���[�N�p�e�N�X�`���̐ݒ�
#define FILTER_MODE			MinFilter = POINT; MagFilter = POINT; MipFilter = NONE;
#define LINEAR_FILTER_MODE	MinFilter = LINEAR; MagFilter = LINEAR; MipFilter = NONE;
//#define ADDRESSING_MODE		AddressU = BORDER; AddressV = BORDER; BorderColor = float4(0,0,0,0);
#define ADDRESSING_MODE		AddressU = CLAMP; AddressV = CLAMP;

// �����_�����O�^�[�Q�b�g�̃N���A�l
float4 ClearColor = {0,0,0,0};
float ClearDepth  = 1.0;


// �X�N���[���T�C�Y
float2 ViewportSize : VIEWPORTPIXELSIZE;
static float2 ViewportOffset = (float2(0.5,0.5) /(ScreenScale * ViewportSize.xy));
static float2 SampleStep = (float2(1.0,1.0) / (ScreenScale * ViewportSize.xy));
static float2 AspectRatio = float2(ViewportSize.x / ViewportSize.y, 1);

// �I���W�i���̕`�挋�ʂ��L�^���邽�߂̃����_�[�^�[�Q�b�g
texture2D ScnMap : RENDERCOLORTARGET <
	bool AntiAlias = false;
	float2 ViewportRatio = {ScreenScale, ScreenScale};
	int MipLevels = 1;
	string Format = TEXFORMAT;
>;

sampler2D ScnSamp = sampler_state {
	texture = <ScnMap>;
	FILTER_MODE
	ADDRESSING_MODE
};

texture2D DepthBuffer : RENDERDEPTHSTENCILTARGET <
	float2 ViewportRatio = {ScreenScale, ScreenScale};
	string Format = "D24S8";
>;

#define DECL_TEXTURE( _map, _samp, _size) \
	texture2D _map : RENDERCOLORTARGET < \
		bool AntiAlias = false; \
		int MipLevels = 1; \
		float2 ViewportRatio = {ScreenScale * 1.0/(_size), ScreenScale * 1.0/(_size)}; \
		string Format = WORK_TEXFORMAT; \
	>; \
	sampler2D _samp = sampler_state { \
		texture = <_map>; \
		FILTER_MODE	ADDRESSING_MODE \
	}; \
	sampler2D _samp##Linear = sampler_state { \
		texture = <_map>; \
		LINEAR_FILTER_MODE	ADDRESSING_MODE \
	};

DECL_TEXTURE( DownscaleMap0, DownscaleSamp0, 1)
DECL_TEXTURE( DownscaleMap1, DownscaleSamp1, 2)
DECL_TEXTURE( DownscaleMap2, DownscaleSamp2, 4)
DECL_TEXTURE( DownscaleMap3, DownscaleSamp3, 8)

DECL_TEXTURE( BlurMap0, BlurSamp0, 1)
DECL_TEXTURE( BlurMap1, BlurSamp1, 2)
DECL_TEXTURE( BlurMap2, BlurSamp2, 4)
DECL_TEXTURE( BlurMap3, BlurSamp3, 8)

DECL_TEXTURE( BlurMapF0, BlurSampF0, 1)
DECL_TEXTURE( BlurMapF1, BlurSampF1, 2)
DECL_TEXTURE( BlurMapF2, BlurSampF2, 4)
DECL_TEXTURE( BlurMapF3, BlurSampF3, 8)
// F:Front(�O�{�P) / B:Back(��{�P)

#if ENABLE_DEEP_LEVEL > 0
DECL_TEXTURE( DownscaleMap4, DownscaleSamp4,16)
DECL_TEXTURE( BlurMap4, BlurSamp4,16)
DECL_TEXTURE( BlurMapF4, BlurSampF4,16)
#endif

// �����œ_�p�̏��B�t���[���𒴂��ď������Ƃ肷��B
texture2D AutoFocusTex : RENDERCOLORTARGET <
	int2 Dimensions = {1,1};
	string Format="A32B32G32R32F";
>;
sampler2D AutoFocusSmp = sampler_state {
	Texture = <AutoFocusTex>;
	AddressU  = CLAMP;	AddressV = CLAMP;
	FILTER_MODE
};
texture2D AutoFocusTexCopy : RENDERCOLORTARGET <
	int2 Dimensions = {1,1};
	string Format="A32B32G32R32F";
>;
sampler2D AutoFocusSmpCopy = sampler_state {
	Texture = <AutoFocusTexCopy>;
	AddressU  = CLAMP;	AddressV = CLAMP;
	FILTER_MODE
};

texture AutoFocusDepthBuffer : RenderDepthStencilTarget <
	int2 Dimensions = {1,1};
	string Format = "D24S8";
>;



//-----------------------------------------------------------------------------
// �[�x�}�b�v
// �[�x�����i�[
texture LinearDepthMapRT: OFFSCREENRENDERTARGET <
	string Description = "OffScreen RenderTarget for ikBokeh.fx";
	float4 ClearColor = { 1.0, 0, 0, 1 };
	float2 ViewportRatio = {ScreenScale, ScreenScale};
	float ClearDepth = 1.0;
	string Format = "R16F";
	bool AntiAlias = false;
	int MipLevels = 1;
	string DefaultEffect = 
		"self = hide;"
		"ikBokeh*.* = hide;"
		"* = ikDepth.fx";
>;

sampler DepthMap = sampler_state {
	texture = <LinearDepthMapRT>;
	AddressU = CLAMP;
	AddressV = CLAMP;

	MinFilter = POINT;
	MagFilter = POINT;
	MipFilter = NONE;
};


//-----------------------------------------------------------------------------
// �K���}�␳
const float epsilon = 1.0e-6;
inline float3 Degamma(float3 col)
{
	return (!bLinearMode) ? pow(max(col,epsilon), gamma) : col;
}
inline float3 Gamma(float3 col)
{
	return (!bLinearMode) ? pow(max(col,epsilon), 1.0/gamma) : col;
}
inline float4 Degamma4(float4 col) { return float4(Degamma(col.rgb), col.a); }
inline float4 Gamma4(float4 col) { return float4(Gamma(col.rgb), col.a); }

// �F�̋���
inline float3 EmphasizeColor(float3 col, float rate)
{
	#if ENABLE_EMPHASIZE_COLOR > 0
	col = (mEmphasize > 0.0) ? exp(col * rate) : col;
	#endif
	return col;
}

inline float3 DepreciateColor(float3 col, float rate)
{
	#if ENABLE_EMPHASIZE_COLOR > 0
	col = (mEmphasize > 0.0) ? log(col) * rate : col;
	#endif
	return col;
}

//-----------------------------------------------------------------------------
// �ǂꂾ���{�P�邩

inline float CalcAperture()
{
	// float adjustValue = mBokehM * BokehFNumberScaleM - mBokehP * BokehFNumberScaleP;
	// float f = mFNumber * FNumberScale + adjustValue;
	float f = DefaultFNumber + (mBokehM - mBokehP) * FNumberScale;
	f = (isExistController) ? f : DefaultFNumber;
	float aperture = 1.0 / clamp(f, MinFNumber, MaxFNumber);
	return aperture;
}

inline float CalcFocalLength(float focusDistance)
{
	float focalM = mFocalLength * FocalLengthScale * mm;

	// ��p�����Ƃɏœ_�������v�Z����
	// �J�����ɂ���ĉ�p�Əœ_�����̊֌W�͕ς��?
	float i = FilmSize * matP._22 / 2.0;
	float focalA = i / (1.0 + i / focusDistance);
	float rate = (isExistController) ? (1.0 - mManualMode) : 1.0;

	float focal = lerp(focalM, focalA, rate);
	focal += (mBokehP * BokehFocalLengthScaleP - mBokehM * BokehFocalLengthScaleM);

	return clamp(focal, MinFocalLength, MaxFocalLength);
}

static float aperture = CalcAperture();

// CoC�v�Z�p�̌W�������߂�
inline float2 CalcCoCCoef(float focusDistance)
{
	float focalLength = CalcFocalLength(focusDistance);

	float I = (focusDistance * focalLength) / (focusDistance - focalLength);
	float S = aperture / FilmSize * (2.0 * ViewportSize.y * ScreenScale * 0.5);

	float CoCCoefMul =-(I * S);
	float CoCCoefAdd = (I * S / focalLength) - S;
	return float2(CoCCoefMul / FAR_DEPTH, CoCCoefAdd);
}

inline float CalcBlurLevel(float2 coef, float depth)
{
	float CoC = coef.x / depth + coef.y;
	return clamp(CoC, -MAX_COC_SIZE, MAX_COC_SIZE);
}

inline float MeasuringCircleRadius()
{
	return (mAFMode > 1.5) ? 0.2 : 0.05;
}


//-----------------------------------------------------------------------------
//

inline float rgb2gray(float3 rgb)
{
	return dot(float3(0.299, 0.587, 0.114), rgb);
}

inline float4 TestColor(float3 Color, float level, float2 uv)
{
	// �e�X�g���[�h
	#if ENABLE_TEST_MODE == 1
	if (mTestMode >= 0.5)
	{
		Color = rgb2gray(Color) * 0.98 + 0.02; // �^�����������ɐF���悹�邽�߂ɃQ�^�𗚂�����B

		// �����_�̕\��
		float r = length((uv - mMeasuringPosition) * AspectRatio);
		float mcr = MeasuringCircleRadius();
		if (mAFMode > 0.5 && r > mcr * 0.5 && r < mcr)
		{
			// ���F�ɂ���
			Color.b = 0;
		}
		else
		{
			float radius = abs(level);
			float grad = saturate(Color.g - saturate(radius - 1));
			if (radius < 0.1) Color.rg = saturate(Color.g - (1.0 - radius * 10.0));
			else if (level < 0.0) Color.g = grad;
			else if (level > 0.0) Color.rb = grad;
		}
	}
	#endif

	return float4(Color, 1);
}

//-----------------------------------------------------------------------------
//

struct VS_OUTPUT {
	float4 Pos			: POSITION;
	float4 TexCoord		: TEXCOORD0;

	float4 TexCoord1	: TEXCOORD1;
	float4 TexCoord2	: TEXCOORD2;
};

VS_OUTPUT VS_SetTexCoord( float4 Pos : POSITION, float4 Tex : TEXCOORD0, uniform float level)
{
	VS_OUTPUT Out = (VS_OUTPUT)0; 

	Out.Pos = Pos;
	float2 TexCoord = Tex.xy + ViewportOffset.xy * level;
	float2 Offset = SampleStep * level;

	Out.TexCoord = float4(TexCoord, Offset);
	Out.TexCoord1 = TexCoord.xyxy + Offset.xyxy * 0.25 * float4(-1,-1, -1, 1);
	Out.TexCoord2 = TexCoord.xyxy + Offset.xyxy * 0.25 * float4( 1,-1,  1, 1);
	return Out;
}

VS_OUTPUT VS_SetTexCoord2( float4 Pos : POSITION, float4 Tex : TEXCOORD0, uniform float level)
{
	VS_OUTPUT Out = (VS_OUTPUT)0; 

	Out.Pos = Pos;
	float2 TexCoord = Tex.xy + ViewportOffset.xy * level;
	float2 Offset = SampleStep * level;

	Out.TexCoord = float4(TexCoord, Offset);
	Out.TexCoord1 = TexCoord.xyxy + Offset.xyxy * float4(-1,-1, -1, 1);
	Out.TexCoord2 = TexCoord.xyxy + Offset.xyxy * float4( 1,-1,  1, 1);

	return Out;
}

VS_OUTPUT VS_CalcCoC( float4 Pos : POSITION, float4 Tex : TEXCOORD0)
{
	VS_OUTPUT Out = (VS_OUTPUT)0; 

	Out.Pos = Pos;
	float2 TexCoord = Tex.xy + ViewportOffset.xy;
	float2 Offset = SampleStep;

	Out.TexCoord = float4(TexCoord, Offset);

	// �����v�Z�p�W�������߂�
	Out.TexCoord1.xy = CalcCoCCoef(tex2Dlod(AutoFocusSmp, float4(0.5,0.5, 0,0)).x);
	// CoC�T�C�Y�̒����W��
	Out.TexCoord1.z = ForceCoCSacle;
	Out.TexCoord1.w = FRONT_BOKEH_SCALE * (1 - mFBokehM);
	// �F�����p�̌W��
	Out.TexCoord2.x = mEmphasizeScale;

	return Out;
}

VS_OUTPUT VS_Gather( float4 Pos : POSITION, float4 Tex : TEXCOORD0, uniform float level)
{
	VS_OUTPUT Out = (VS_OUTPUT)0; 

	Out.Pos = Pos;
	float2 TexCoord = Tex.xy + ViewportOffset.xy * level;
	float2 Offset = SampleStep * level;

	Out.TexCoord = float4(TexCoord, Offset);
	Out.TexCoord1.x = (1.0 / mEmphasizeScale);

	return Out;
}

//-----------------------------------------------------------------------------
// ��������

VS_OUTPUT VS_UpdateFocusDistance( float4 Pos : POSITION, float4 Tex : TEXCOORD0)
{
	VS_OUTPUT Out = (VS_OUTPUT)0; 
	Out.Pos = Pos;
	// Out.TexCoord = float4(Tex.xy, 0, 0);
	return Out;
}


// ���ŋ����̎擾
inline float CalcFocusDistance()
{
	// AFPosition�̐[�x
	float depth0 = distance(AFPosition, CameraPosition);

	// �����_�Z���N�g/�����_�I�[�g
	float2 center = mMeasuringPosition;
	float r1 = MeasuringCircleRadius();
	float r2 = r1 * 0.714;
	// MEMO: AspectRatio���l�����Ă��Ȃ�
	float depthA0 = tex2D( DepthMap, float2(-r2,-r2) + center).x;
	float depthA1 = tex2D( DepthMap, float2(-r1,  0) + center).x;
	float depthA2 = tex2D( DepthMap, float2(-r2, r2) + center).x;
	float depthA3 = tex2D( DepthMap, float2(  0,-r1) + center).x;
	float depthA4 = tex2D( DepthMap, float2(  0,  0) + center).x;
	float depthA5 = tex2D( DepthMap, float2(  0, r1) + center).x;
	float depthA6 = tex2D( DepthMap, float2( r2,-r2) + center).x;
	float depthA7 = tex2D( DepthMap, float2( r1,  0) + center).x;
	float depthA8 = tex2D( DepthMap, float2( r2, r2) + center).x;
	if (mAFMode > 0.5)
	{
		float4 depthMin = min(
			float4(depthA0,depthA1,depthA2,depthA3),
			float4(depthA4,depthA5,depthA6,depthA7));
		depthMin.xy = min(depthMin.xy, depthMin.zw);
		depth0 = min(min(depthMin.x, depthMin.y), depthA8) * FAR_DEPTH;
	}

	// �}�j���A���t�H�[�J�X
	float rate = (isExistController) ? (1.0 - mManualMode) : 1.0;
	depth0 = lerp(mPintDistance * AbsoluteFocusScale, depth0, rate);

	// ��������
	float adjuster = (mPintDistanceP - mPintDistanceM) * RelativeFocusScale + mCtrlPosition.z;
	depth0 = max(depth0 + adjuster, MinFocusDistance);

	return depth0;
}


float4 PS_UpdateFocusDistance(float2 Tex: TEXCOORD0) : COLOR
{
	float depth0 = CalcFocusDistance();
	float4 data = tex2Dlod(AutoFocusSmpCopy, float4(0.5,0.5,0,0));
	// float4 data = AutoFocusTexArray[0];
	float depth1 = data.x;
	float Vel = data.y;
	// float prevTime = data.z;
		// ���̒l���啝�Ɉ�����珉��������? abs(time - prevTime) > 10.0 �Ƃ��B

	// 0�t���ڂȂ珉����
	if (time < 1.0 / 120.0)
	{
		depth1 = depth0;
		Vel = 0;
	}

	// *** �s���g���x�̌v�Z�́A�j��P��PowerDOF���Q�l�ɂ��܂����B ***

	// ����
	Vel *= (1.0 - mPintFriction);
	Vel = Vel - Vel * Dt * 0.05;
	float v = depth0 - (depth1 + Vel);
	// ��O�قǋ������킹�͍����ɂȂ�
	float speed = min(abs(v), clamp(35000.0f/depth0, 50.0f, 1000.0f) * 30.0 * Dt);
	Vel += sign(v) * speed * (1.0 - mPintDelay);
	depth1 += Vel;

	depth1 = max(depth1, MinFocusDistance);

	return float4(depth1, Vel, time, 1.0);
}

float4 PS_CopyFocusDistance(float2 Tex: TEXCOORD0) : COLOR
{
	return tex2Dlod(AutoFocusSmp, float4(0.5,0.5,0,0));
}

//-----------------------------------------------------------------------------
// CoC�̌v�Z
float4 PS_CalcCoC( VS_OUTPUT IN ) : COLOR
{
	float2 texCoord = IN.TexCoord.xy;
	float4 Color = Degamma4(tex2D(ScnSamp, texCoord));
	float Depth = tex2D( DepthMap, texCoord).x;

	float level = CalcBlurLevel(IN.TexCoord1.xy, Depth);

	float forceCoCSacle = IN.TexCoord1.z;
	float frontCoCSacle = IN.TexCoord1.w;
	level = (level >= 0.0) ? level : (level * frontCoCSacle);
	level = (abs(level) >= 1.0)
			? sign(level) * ((abs(level) - 1.0) * forceCoCSacle + 1)
			: level;

	float emphasizeScale = IN.TexCoord2.x;
	Color.rgb = EmphasizeColor(Color.rgb, emphasizeScale);

	return float4(Color.rgb, level);
}


//-----------------------------------------------------------------------------
// ��𑜓x�̃o�b�t�@�����

inline float CalcWeight(float4 col) { return abs(col.w); }

float4 PS_DownSampling( VS_OUTPUT IN, uniform sampler2D smp) : COLOR
{
	float4 Color0 = tex2D(smp, IN.TexCoord1.xy);
	float4 Color1 = tex2D(smp, IN.TexCoord1.zw);
	float4 Color2 = tex2D(smp, IN.TexCoord2.xy);
	float4 Color3 = tex2D(smp, IN.TexCoord2.zw);

	float4 Color = 0;
	float w0 = CalcWeight(Color0); Color += Color0 * w0;
	float w1 = CalcWeight(Color1); Color += Color1 * w1;
	float w2 = CalcWeight(Color2); Color += Color2 * w2;
	float w3 = CalcWeight(Color3); Color += Color3 * w3;
	Color = Color / max(w0+w1+w2+w3, epsilon);
	Color.w *= 0.5;

	return Color;
}


//-----------------------------------------------------------------------------
// �{�J��

struct PS_OUT_MRT
{
	float4 ColorBack	: COLOR0;
	float4 ColorFront	: COLOR1;
};

float2 CalcWeight(float2 coc, float2 weight, uniform bool bFirst, uniform bool bLast)
{
	if (!bFirst) weight *= saturate(coc * 2.0 - (BULR_SIZE - 1.0));
	if (!bLast) weight *= saturate(BULR_SIZE - coc);
	return weight / max(coc * coc, MinimumCoCRadius);
}
float4 CalcWeight(float4 coc, float4 weight, uniform bool bFirst, uniform bool bLast)
{
	if (!bFirst) weight *= saturate(coc * 2.0 - (BULR_SIZE - 1.0));
	if (!bLast) weight *= saturate(BULR_SIZE - coc);
	return weight / max(coc * coc, MinimumCoCRadius);
}

PS_OUT_MRT PS_Blur( VS_OUTPUT IN, uniform sampler2D smp, 
	uniform bool bFirst, uniform bool bLast)
{
	float2 texCoord = IN.TexCoord.xy;
	float2 offset = IN.TexCoord.zw;
	float2 offset2 = IN.TexCoord.zw * float2(1,-1);

	float depth0 = tex2D(smp, texCoord).w;
//	float2 coc0 = float2(max( depth0, 0), BULR_SIZE);
	float4 coc0 = float2(max( depth0, 0), BULR_SIZE).xyxy;
	float4 sumB = 0;
	float4 sumF = 0;

#if USE_MME_32BIT
	int dither = 0;
	for(int iy = 0; iy <= BULR_SIZE * 2; iy++)
	{
		float vy = iy - BULR_SIZE;
		float dither2 = -BULR_SIZE + dither;
		for(int ix = 0; ix <= BULR_SIZE; ix++)
		{
			float vx = ix * 2 + dither2;
			float2 uv = float2(vx, vy);
			float l = length(uv);
			float4 Color = tex2Dlod(smp, float4(offset * uv + texCoord, 0,0));
			float2 coc = max(float2( Color.w, -Color.w), 0);
			float2 dist = saturate(min(coc, coc0) - l);
			float2 weight = CalcWeight(coc, dist, bFirst, bLast);
			sumB += float4(Color.rgb, 1) * weight.x;
			sumF += float4(Color.rgb, 1) * weight.y;
		}
		dither = 1 - dither;
	}
#else
	{
		float dither2 = -BULR_SIZE + 0;
		for(int ix = 0; ix <= BULR_SIZE; ix++)
		{
			float vx = ix * 2 + dither2;
			float2 uv = float2(vx, 0);
			float l = abs(vx);
			float4 Color = tex2Dlod(smp, float4(offset * uv + texCoord, 0,0));
			float2 coc = max(float2( Color.w, -Color.w), 0);
			float2 dist = saturate(min(coc, coc0.xy) - l);
			float2 weight = CalcWeight(coc, dist, bFirst, bLast);
			sumB += float4(Color.rgb, 1) * weight.x;
			sumF += float4(Color.rgb, 1) * weight.y;
		}
	}

	int dither = 1;
	for(int iy = 1; iy <= BULR_SIZE; iy++)
	{
		float dither2 = -BULR_SIZE + dither;
		for(int ix = 0; ix <= BULR_SIZE; ix++)
		{
			float2 uv = float2(ix * 2 + dither2, iy);
			float l = length(uv.xy);
			float4 Color1 = tex2Dlod(smp, float4(offset * uv + texCoord, 0,0));
			float4 Color2 = tex2Dlod(smp, float4(offset2 * uv + texCoord, 0,0));
			float4 coc = max(float4( Color1.w, -Color1.w, Color2.w, -Color2.w), 0);
			float4 dist = saturate(min(coc, coc0) - l);
			float4 weight = CalcWeight(coc, dist, bFirst, bLast);
			sumB += float4(Color1.rgb, 1) * weight.x;
			sumF += float4(Color1.rgb, 1) * weight.y;
			sumB += float4(Color2.rgb, 1) * weight.z;
			sumF += float4(Color2.rgb, 1) * weight.w;
		}
		dither = 1 - dither;
	}
#endif

	PS_OUT_MRT Out;
	Out.ColorBack = sumB;
	Out.ColorFront = sumF;

	return Out;
}

//-----------------------------------------------------------------------------
// ��𑜓x�}�b�v�����𑜓x�ɕ���
float4 PS_UpSampling( VS_OUTPUT IN, uniform sampler2D smp, uniform sampler2D smp2) : COLOR
{
	float2 texCoord = IN.TexCoord.xy;
	float4 Color0 = tex2D(smp, texCoord);
	float4 Color1 = 
		tex2D(smp2, IN.TexCoord1.xy) + tex2D(smp2, IN.TexCoord1.zw) + 
		tex2D(smp2, IN.TexCoord2.xy) + tex2D(smp2, IN.TexCoord2.zw);
	return Color0 + Color1 * 0.25;
}

//-----------------------------------------------------------------------------
// 
float4 PS_Gather( VS_OUTPUT IN) : COLOR
{
	float2 texCoord = IN.TexCoord.xy;
	float2 offset = IN.TexCoord.zw;

	float4 Color = tex2D(DownscaleSamp0, texCoord);
	float depth = Color.w;
	float2 coc = max(float2(depth, -depth), 0);
	float2 rcoc2 = 1.0 / max(coc * coc, 1.0);
	Color.w = 1;

	// ��{�P�̍���
	float4 ColorB = tex2D(DownscaleSamp1Linear, texCoord);
	ColorB += tex2D(BlurSamp0Linear, texCoord);
	ColorB += Color * epsilon;
	Color.rgb = lerp(ColorB.rgb / ColorB.w, Color.rgb, rcoc2.x);
	Color.w = 1;

	// �O�{�P�̍���
	float4 ColorF = tex2D(BlurSamp1Linear, texCoord);;
	ColorF += tex2D(BlurSampF0Linear, texCoord);
	float alpha = saturate(ColorF.w);
	Color = Color * rcoc2.y + ColorF;
	Color.rgb /= Color.w;
	ColorF.rgb /= max(ColorF.w, epsilon);
	Color.rgb = lerp(Color.rgb, ColorF.rgb, alpha);

	float demphasizeScale = IN.TexCoord1.x;
	Color.rgb = DepreciateColor(Color.rgb, demphasizeScale);
	Color = Gamma4(TestColor( Color.rgb, depth, texCoord));
	Color.a = 1;

	return Color;
}

//=============================================================================

technique DepthOfField <
	string Script = 
		// ���ʂ̉�ʂ������_�����O
		"RenderColorTarget0=ScnMap;"
		"RenderDepthStencilTarget=DepthBuffer;"
		"ClearSetColor=ClearColor;"
		"ClearSetDepth=ClearDepth;"
		"Clear=Color; Clear=Depth;"
		"ScriptExternal=Color;"

		// �I�[�g�t�H�[�J�X�̌v�Z
		"RenderDepthStencilTarget=AutoFocusDepthBuffer;"
		"RenderColorTarget0=AutoFocusTex;		Pass=UpdateFocusPass;"
		"RenderColorTarget0=AutoFocusTexCopy;	Pass=CopyFocusPass;"

		// CoC�̃T�C�Y�v�Z
		"RenderDepthStencilTarget=DepthBuffer;"
		"RenderColorTarget0=DownscaleMap0;"
		// "Clear=Color; Clear=Depth;"
		"Pass=CalcCoCPass;"

		// �摜�̃_�E���X�P�[��
		"RenderColorTarget0=DownscaleMap1; Pass=ScalePass1;"
		"RenderColorTarget0=DownscaleMap2; Pass=ScalePass2;"
		"RenderColorTarget0=DownscaleMap3; Pass=ScalePass3;"
		#if ENABLE_DEEP_LEVEL > 0
		"RenderColorTarget0=DownscaleMap4; Pass=ScalePass4;"
		#endif

		// �{�J��
		"RenderColorTarget0=BlurMap0; RenderColorTarget1=BlurMapF0; Pass=BlurPass0;"
		"RenderColorTarget0=BlurMap1; RenderColorTarget1=BlurMapF1; Pass=BlurPass1;"
		"RenderColorTarget0=BlurMap2; RenderColorTarget1=BlurMapF2; Pass=BlurPass2;"
		"RenderColorTarget0=BlurMap3; RenderColorTarget1=BlurMapF3; Pass=BlurPass3;"
		#if ENABLE_DEEP_LEVEL > 0
		"RenderColorTarget0=BlurMap4; RenderColorTarget1=BlurMapF4; Pass=BlurPass4;"
		#endif
		"RenderColorTarget1=;"

		// �A�b�v�T���v�����O
		#if ENABLE_DEEP_LEVEL > 0
		"RenderColorTarget0=DownscaleMap3; Pass=UpScale3;"
		#endif
		"RenderColorTarget0=DownscaleMap2; Pass=UpScale2;"
		"RenderColorTarget0=DownscaleMap1; Pass=UpScale1;"
		// (�������̏I�������{�P�p�o�b�t�@�ɑO�{�P�̍������ʂ��i�[)
		#if ENABLE_DEEP_LEVEL > 0
		"RenderColorTarget0=BlurMap3; Pass=UpScaleF3;"
		#endif
		"RenderColorTarget0=BlurMap2; Pass=UpScaleF2;"
		"RenderColorTarget0=BlurMap1; Pass=UpScaleF1;"

		// ����
		"RenderColorTarget0=;"
		"RenderDepthStencilTarget=;"
		"Pass=GatherPass;"
	;
> {
	pass UpdateFocusPass < string Script= "Draw=Buffer;"; > {
		AlphaBlendEnable = FALSE;	AlphaTestEnable = FALSE;
		VertexShader = compile vs_3_0 VS_UpdateFocusDistance();
		PixelShader  = compile ps_3_0 PS_UpdateFocusDistance();
	}
	pass CopyFocusPass < string Script= "Draw=Buffer;"; > {
		AlphaBlendEnable = FALSE;	AlphaTestEnable = FALSE;
		VertexShader = compile vs_3_0 VS_UpdateFocusDistance();
		PixelShader  = compile ps_3_0 PS_CopyFocusDistance();
	}

	pass CalcCoCPass < string Script= "Draw=Buffer;"; > {
		AlphaBlendEnable = FALSE;	AlphaTestEnable = FALSE;
		VertexShader = compile vs_3_0 VS_CalcCoC();
		PixelShader  = compile ps_3_0 PS_CalcCoC();
	}

	// �_�E���T���v�����O
	pass ScalePass1 < string Script= "Draw=Buffer;"; > {
		AlphaBlendEnable = FALSE;	AlphaTestEnable = FALSE;
		VertexShader = compile vs_3_0 VS_SetTexCoord(2);
		PixelShader  = compile ps_3_0 PS_DownSampling(DownscaleSamp0);
	}
	pass ScalePass2 < string Script= "Draw=Buffer;"; > {
		AlphaBlendEnable = FALSE;	AlphaTestEnable = FALSE;
		VertexShader = compile vs_3_0 VS_SetTexCoord(4);
		PixelShader  = compile ps_3_0 PS_DownSampling(DownscaleSamp1);
	}
	pass ScalePass3 < string Script= "Draw=Buffer;"; > {
		AlphaBlendEnable = FALSE;	AlphaTestEnable = FALSE;
		VertexShader = compile vs_3_0 VS_SetTexCoord(8);
		PixelShader  = compile ps_3_0 PS_DownSampling(DownscaleSamp2);
	}
#if ENABLE_DEEP_LEVEL > 0
	pass ScalePass4 < string Script= "Draw=Buffer;"; > {
		AlphaBlendEnable = FALSE;	AlphaTestEnable = FALSE;
		VertexShader = compile vs_3_0 VS_SetTexCoord(16);
		PixelShader  = compile ps_3_0 PS_DownSampling(DownscaleSamp3);
	}
#endif

	// �{�J��
	pass BlurPass0 < string Script= "Draw=Buffer;"; > {
		AlphaBlendEnable = FALSE;	AlphaTestEnable = FALSE;
		VertexShader = compile vs_3_0 VS_SetTexCoord(1);
		PixelShader  = compile ps_3_0 PS_Blur(DownscaleSamp0, true, false);
	}
	pass BlurPass1 < string Script= "Draw=Buffer;"; > {
		AlphaBlendEnable = FALSE;	AlphaTestEnable = FALSE;
		VertexShader = compile vs_3_0 VS_SetTexCoord(2);
		PixelShader  = compile ps_3_0 PS_Blur(DownscaleSamp1, false, false);
	}
	pass BlurPass2 < string Script= "Draw=Buffer;"; > {
		AlphaBlendEnable = FALSE;	AlphaTestEnable = FALSE;
		VertexShader = compile vs_3_0 VS_SetTexCoord(4);
		PixelShader  = compile ps_3_0 PS_Blur(DownscaleSamp2, false, false);
	}
#if ENABLE_DEEP_LEVEL > 0
	pass BlurPass3 < string Script= "Draw=Buffer;"; > {
		AlphaBlendEnable = FALSE;	AlphaTestEnable = FALSE;
		VertexShader = compile vs_3_0 VS_SetTexCoord(8);
		PixelShader  = compile ps_3_0 PS_Blur(DownscaleSamp3, false, false);
	}
	pass BlurPass4 < string Script= "Draw=Buffer;"; > {
		AlphaBlendEnable = FALSE;	AlphaTestEnable = FALSE;
		VertexShader = compile vs_3_0 VS_SetTexCoord(16);
		PixelShader  = compile ps_3_0 PS_Blur(DownscaleSamp4, false, true);
	}
#else
	pass BlurPass3 < string Script= "Draw=Buffer;"; > {
		AlphaBlendEnable = FALSE;	AlphaTestEnable = FALSE;
		VertexShader = compile vs_3_0 VS_SetTexCoord(8);
		PixelShader  = compile ps_3_0 PS_Blur(DownscaleSamp3, false, true);
	}
#endif

	// �A�b�v�T���v�����O
#if ENABLE_DEEP_LEVEL > 0
	pass UpScale3 < string Script= "Draw=Buffer;"; > {
		AlphaBlendEnable = FALSE;	AlphaTestEnable = FALSE;
		VertexShader = compile vs_3_0 VS_SetTexCoord2(8);
		PixelShader  = compile ps_3_0 PS_UpSampling(BlurSamp3, BlurSamp4Linear);
	}
	pass UpScale2 < string Script= "Draw=Buffer;"; > {
		AlphaBlendEnable = FALSE;	AlphaTestEnable = FALSE;
		VertexShader = compile vs_3_0 VS_SetTexCoord2(4);
		PixelShader  = compile ps_3_0 PS_UpSampling(BlurSamp2, DownscaleSamp3Linear);
	}
#else
	pass UpScale2 < string Script= "Draw=Buffer;"; > {
		AlphaBlendEnable = FALSE;	AlphaTestEnable = FALSE;
		VertexShader = compile vs_3_0 VS_SetTexCoord2(4);
		PixelShader  = compile ps_3_0 PS_UpSampling(BlurSamp2, BlurSamp3Linear);
	}
#endif
	pass UpScale1 < string Script= "Draw=Buffer;"; > {
		AlphaBlendEnable = FALSE;	AlphaTestEnable = FALSE;
		VertexShader = compile vs_3_0 VS_SetTexCoord2(2);
		PixelShader  = compile ps_3_0 PS_UpSampling(BlurSamp1, DownscaleSamp2Linear);
	}

#if ENABLE_DEEP_LEVEL > 0
	pass UpScaleF3 < string Script= "Draw=Buffer;"; > {
		AlphaBlendEnable = FALSE;	AlphaTestEnable = FALSE;
		VertexShader = compile vs_3_0 VS_SetTexCoord2(8);
		PixelShader  = compile ps_3_0 PS_UpSampling(BlurSampF3, BlurSampF4Linear);
	}
	pass UpScaleF2 < string Script= "Draw=Buffer;"; > {
		AlphaBlendEnable = FALSE;	AlphaTestEnable = FALSE;
		VertexShader = compile vs_3_0 VS_SetTexCoord2(4);
		PixelShader  = compile ps_3_0 PS_UpSampling(BlurSampF2, BlurSamp3Linear);
	}
#else
	pass UpScaleF2 < string Script= "Draw=Buffer;"; > {
		AlphaBlendEnable = FALSE;	AlphaTestEnable = FALSE;
		VertexShader = compile vs_3_0 VS_SetTexCoord2(4);
		PixelShader  = compile ps_3_0 PS_UpSampling(BlurSampF2, BlurSampF3Linear);
	}
#endif
	pass UpScaleF1 < string Script= "Draw=Buffer;"; > {
		AlphaBlendEnable = FALSE;	AlphaTestEnable = FALSE;
		VertexShader = compile vs_3_0 VS_SetTexCoord2(2);
		PixelShader  = compile ps_3_0 PS_UpSampling(BlurSampF1, BlurSamp2Linear);
	}

	// ����
	pass GatherPass < string Script= "Draw=Buffer;"; > {
		AlphaBlendEnable = FALSE;	AlphaTestEnable = FALSE;
		VertexShader = compile vs_3_0 VS_Gather(1);
		PixelShader  = compile ps_3_0 PS_Gather();
	}
}

//=============================================================================
