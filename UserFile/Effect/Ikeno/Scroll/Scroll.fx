////////////////////////////////////////////////////////////////////////////////////////////////
//
////////////////////////////////////////////////////////////////////////////////////////////////
// �p�����[�^�錾

// �A�e�v�Z��L���ɂ���
// #define ENABLE_DIFFUSE

// �n�C���C�g��L���ɂ���
// #define ENABLE_SPECULAR
float	SpecularPower = 32;
float	SpecularScale = 0.5;

// ���Z���[�h�F��������Z��������B
// �w�ʏ������L���ȏꍇ�A�w�ʂ̏�ɉ��Z�����̂Œ��ӁB
// ���Z�Ŗ��邭�Ȃ�߂���Ƃ��͋t�ɁA�w�ʂɈÂ��F(0,0,0,0.5)�Ȃǂ��w�肷��ƁA����т��y�������B
//#define ENABLE_ADDITION_MODE

// ����̉��ɒu���摜���w��
// ���̉摜�̓��������ɂ͓��悪�K�p����܂���B
//#define BASE_TEXTURE_NAME		"grad.png"

// �p�^�[���^�C�v�̃x�[�X�摜�B�ʏ��BASE�ƕ��p�\�A
// #define BASEPATTERN_TEXTURE_NAME	"Pattern/dot.png"
// �p�^�[���̌J��Ԃ��T�C�Y�B�l���傫���قǏ������\������܂��B
const float2 BASEPATTERN_LOOP_SIZE = float2(50, 50);


// ����ɏ�悹����摜���w��F�摜�̃��ɉ����ē�����B���܂��B
// �t���[���Ȃǂ̒ǉ��p�B
// #define COVER_TEXTURE_NAME		"back.jpg"

// �w�ʏ����F�D��x�́A�e�N�X�`�� > �F > ���ʕ\�� > ����(�ǂ���w�肵�Ȃ��ꍇ)
// �w�ʂɎw��e�N�X�`����\��
#define BACKFACE_TEXTURE_NAME		"back.jpg"
// �w�ʂ��w��̐F�œh��
#define BACKFACE_COLOR		float4(0,0,0.5,0.75)
// ���ɂ������\������
#define ENABLE_DOUBLE_FACE


// �R���g���[���̖���
#define CONTROLLER_NAME		"ScrollController.pmx"

// ���s�����̏������݂����Ȃ�
// ���Z���[�h�ŗD�揇�ʂ̋������N�������Ƃ��ɉ��P�����\��������B
//#define DISABLE_ZWRITE

// ����̃T�C�Y�F
// 4�������ɗאڂ��铮�悪�܂܂�Ȃ��悤�ɂ��邽�߂ɐݒ�B
// �[���C�ɂȂ�Ȃ��Ȃ�ݒ肵�Ȃ��Ă悢�B
float2 MovieSize = float2(854,480);
// ����̒[�𖳎�����s�N�Z����
float MoveMargin = 2;

////////////////////////////////////////////////////////////////////////////////////////////////


// ���@�ϊ��s��
float4x4 WorldViewProjMatrix	: WORLDVIEWPROJECTION;
float4x4 WorldViewMatrix		: WORLDVIEW;
float4x4 WorldMatrix			: WORLD;
float4x4 ViewMatrix				: VIEW;
float4x4 LightWorldViewProjMatrix : WORLDVIEWPROJECTION < string Object = "Light"; >;

float3   LightDirection	: DIRECTION < string Object = "Light"; >;
float3   CameraPosition	: POSITION  < string Object = "Camera"; >;

// ���C�g�F
float3   LightDiffuse		: DIFFUSE   < string Object = "Light"; >;
float3   LightAmbient		: AMBIENT   < string Object = "Light"; >;
float3   LightSpecular	 : SPECULAR  < string Object = "Light"; >;
static float3 SpecularColor = LightSpecular;
static float4 DiffuseColor  = float4(LightDiffuse, 1.0f);
static float3 AmbientColor  = saturate(LightAmbient);

bool	 parthf;   // �p�[�X�y�N�e�B�u�t���O
bool	 transp;   // �������t���O
bool	 spadd;	// �X�t�B�A�}�b�v���Z�����t���O
#define SKII1	1500
#define SKII2	8000
#define Toon	 3

// �I�u�W�F�N�g�̃e�N�X�`��
texture ObjectTexture: MATERIALTEXTURE;
sampler ObjTexSampler = sampler_state {
	texture = <ObjectTexture>;
	MINFILTER = LINEAR;
	MAGFILTER = LINEAR;
};

// �X�t�B�A�}�b�v�̃e�N�X�`��
texture ObjectSphereMap: MATERIALSPHEREMAP;
sampler ObjSphareSampler = sampler_state {
	texture = <ObjectSphereMap>;
	MINFILTER = LINEAR;
	MAGFILTER = LINEAR;
};

// MMD�{����sampler���㏑�����Ȃ����߂̋L�q�ł��B�폜�s�B
sampler MMDSamp0 : register(s0);
sampler MMDSamp1 : register(s1);
sampler MMDSamp2 : register(s2);


#if defined(BACKFACE_TEXTURE_NAME)
texture2D BackfaceTex <
	string ResourceName = BACKFACE_TEXTURE_NAME;
>;
sampler BackfaceSamp = sampler_state{
	texture = <BackfaceTex>;
	MinFilter = LINEAR;
	MagFilter = LINEAR;
	MipFilter = LINEAR;
	AddressU  = CLAMP;
	AddressV = CLAMP;
};
#endif

#if defined(BASE_TEXTURE_NAME)
texture2D BaseTex <
	string ResourceName = BASE_TEXTURE_NAME;
>;
sampler BaseSamp = sampler_state{
	texture = <BaseTex>;
	MinFilter = LINEAR;
	MagFilter = LINEAR;
	MipFilter = LINEAR;
	AddressU  = CLAMP;
	AddressV = CLAMP;
};
#endif

#if defined(BASEPATTERN_TEXTURE_NAME)
texture2D BasePatternTex <
	string ResourceName = BASEPATTERN_TEXTURE_NAME;
>;
sampler BasePatternSamp = sampler_state{
	texture = <BasePatternTex>;
	MinFilter = LINEAR;
	MagFilter = LINEAR;
	MipFilter = LINEAR;
	AddressU  = WRAP;
	AddressV = WRAP;
};
#endif

#if defined(COVER_TEXTURE_NAME)
texture2D CoverTex <
	string ResourceName = COVER_TEXTURE_NAME;
>;
sampler CoverSamp = sampler_state{
	texture = <CoverTex>;
	MinFilter = LINEAR;
	MagFilter = LINEAR;
	MipFilter = LINEAR;
	AddressU  = CLAMP;
	AddressV = CLAMP;
};
#endif




////////////////////////////////////////////////////////////////////////////////////////////////
//

#define	PI	(3.14159265359)

float CalcDiffuse(float3 L, float3 N, float3 V)
{
	return saturate(dot(N,L));
}

float CalcSpecular(float3 L, float3 N, float3 V, float smoothness)
{
	float3 H = normalize(L + V);	// �n�[�t�x�N�g��
	float3 Specular = max(0,dot( H, N ));
	float3 result = pow(Specular, smoothness);
	return result; // *= (2.0 + smoothness) / (2.0 * PI);
}



////////////////////////////////////////////////////////////////////////////////////////////////
bool isExistController : CONTROLOBJECT < string name = CONTROLLER_NAME; >;

float mAllScaleUp : CONTROLOBJECT < string name = CONTROLLER_NAME; string item = "�S�̊g��"; >;
float mAllScaleDown : CONTROLOBJECT < string name = CONTROLLER_NAME; string item = "�S�̏k��"; >;
float mHScaleUp : CONTROLOBJECT < string name = CONTROLLER_NAME; string item = "���g��"; >;
float mHScaleDown : CONTROLOBJECT < string name = CONTROLLER_NAME; string item = "���k��"; >;
float mVScaleUp : CONTROLOBJECT < string name = CONTROLLER_NAME; string item = "�c�g��"; >;
float mVScaleDown : CONTROLOBJECT < string name = CONTROLLER_NAME; string item = "�c�k��"; >;
float mLScaleUp : CONTROLOBJECT < string name = CONTROLLER_NAME; string item = "���g��"; >;
float mRScaleUp : CONTROLOBJECT < string name = CONTROLLER_NAME; string item = "�E�g��"; >;
float mTScaleUp : CONTROLOBJECT < string name = CONTROLLER_NAME; string item = "��g��"; >;
float mBScaleUp : CONTROLOBJECT < string name = CONTROLLER_NAME; string item = "���g��"; >;

float mHRollUp : CONTROLOBJECT < string name = CONTROLLER_NAME; string item = "����]+"; >;
float mHRollDown : CONTROLOBJECT < string name = CONTROLLER_NAME; string item = "����]-"; >;
float mVRollUp : CONTROLOBJECT < string name = CONTROLLER_NAME; string item = "�c��]+"; >;
float mVRollDown : CONTROLOBJECT < string name = CONTROLLER_NAME; string item = "�c��]-"; >;

float mXOffsetUp : CONTROLOBJECT < string name = CONTROLLER_NAME; string item = "X�I�t�Z�b�g+"; >;
float mXOffsetDown : CONTROLOBJECT < string name = CONTROLLER_NAME; string item = "X�I�t�Z�b�g-"; >;
float mYOffsetUp : CONTROLOBJECT < string name = CONTROLLER_NAME; string item = "Y�I�t�Z�b�g+"; >;
float mYOffsetDown : CONTROLOBJECT < string name = CONTROLLER_NAME; string item = "Y�I�t�Z�b�g-"; >;

float mMovieRange : CONTROLOBJECT < string name = CONTROLLER_NAME; string item = "����͈�"; >;
float mPatternFade : CONTROLOBJECT < string name = CONTROLLER_NAME; string item = "�p�^�[���t�F�[�h"; >;

//---

float AllScaleValue(float u, float d)
{
	float t = u - d;
	return (t >= 0.0) ? lerp(1, 4.0, t) : lerp(1.0, 0.1, -t);
}
float ScaleValue(float u, float d)
{
	float t = u - d;
	return (t >= 0.0) ? lerp(1, 2.0, t) : lerp(1.0, 0.1, -t);
}

float SetHScale()
{
	if (isExistController)
	{
		return AllScaleValue(mAllScaleUp, mAllScaleDown) * ScaleValue(mHScaleUp, mHScaleDown);
	} else {
		return 1;
	}
}

float SetVScale()
{
	if (isExistController)
	{
		return AllScaleValue(mAllScaleUp, mAllScaleDown) * ScaleValue(mVScaleUp, mVScaleDown);
	} else {
		return 1;
	}
}


float2 GetTexCoord(float2 inTexCoord)
{
	float2 result = inTexCoord;

	if (isExistController)
	{
		int mode = (int)floor(mMovieRange * 5.0 + 0.5/5.0);
		if (mode == 0) result = inTexCoord;
		else
		{
			float2 halfSize = (MovieSize - MoveMargin * 2.0) / MovieSize * 0.5;
			float2 offset = (MoveMargin + 0.5) / MovieSize * 0.5;
			result = inTexCoord * halfSize;
			if (mode == 1) ; // ����
			else if (mode == 2) result += float2(0.5, 0); // �E��
			else if (mode == 3) result += float2(0, 0.5); // ����
			else result += float2(0.5, 0.5); // �E��
			result += offset;
		}
	}

	return result;
}

//---

static float kWx = SetHScale(); // �������̊g�嗦 (�b��g�嗦��0.1�`2.0)
static float kWz = SetVScale(); // �c�����̊g�嗦
static float kSvx = (mTScaleUp - mBScaleUp) * 0.999;
static float kSvz = (mRScaleUp - mLScaleUp) * 0.999;
static float kRotX = mVRollUp - mVRollDown;
static float kRotZ = mHRollUp - mHRollDown;
	// �Ђ˂���~����?

// ���_
static float kOffsetX = mXOffsetUp - mXOffsetDown;
static float kOffsetZ = mYOffsetUp - mYOffsetDown;


////////////////////////////////////////////////////////////////////////////////////////////////
//
void CalcRawPosMat(float4 Pos0, out float4 oPos, out float4x4 oMat)
{
	float e = 0.001;

	float sx = (1 + Pos0.z * sign(kSvx) * abs(kSvx)) * kWx;
	float sy = 0;
	float sz = (1 + Pos0.x * sign(kSvz) * abs(kSvz)) * kWz;
	float3 pos = Pos0.xyz * float3(sx,sy,sz);

	// �K���Ȃ䂪�݌v�Z�B�s����Y��ɏ��������ȋC�����邪�c�B
	float angX = Pos0.x * PI * abs(kRotX) * 0.5;
	float angZ = Pos0.z * PI * abs(kRotZ) * 0.5;

	float rx = sx / PI;
	float s = sx * (2.0 / PI) * sin(angX);
	float lx = lerp(pos.x, s, abs(kRotX));
	pos.x = lx * cos(angX);
	pos.y = lx * sin(angX) * sign(kRotX) - rx;

	float rz = sz / PI;
	float t = sz * (2.0 / PI) * sin(angZ);
	float lz = lerp(pos.z, t, abs(kRotZ));
	pos.z = lz * cos(angZ);
	pos.y += lz * sin(angZ) * sign(kRotZ) - rz;

	angX = Pos0.x * PI * kRotX;
	angZ = Pos0.z * PI * kRotZ;

	// �K���ȌX���̌v�Z
	float rateX = abs(kRotX) / (abs(kRotX) + abs(kRotZ) + e);
	float rateZ = abs(kRotZ) / (abs(kRotX) + abs(kRotZ) + e);
	float nx = sin(angX) * rateX;
	float nz = sin(angZ) * rateZ;
	float ny = sign(cos(angX) * rateX + cos(angZ) * rateZ + e);
	ny *= sqrt(1 - (nx*nx + nz*nz));

	float bnx = cos(angX);
	float bny =-sin(angX);
	float bnz = 0;

	float3 normal = normalize(float3(nx,ny,nz));
	float3 binormal = normalize(float3(bnx,bny,bnz));
	float3 tangent = normalize(cross(binormal,normal));
	binormal = normalize(cross(normal,tangent));

	oPos = float4(pos.xyz, Pos0.w);

	oMat[0] = float4(binormal,0);
	oMat[1] = float4(normal,0);
	oMat[2] = float4(tangent,0);
	oMat[3] = float4(0,0,0,1);
	oMat[3].xyz = -mul(float4(pos.xyz, 1), oMat).xyz;
}

float4x4 CalcMat()
{
	float4 offsetPos;
	float4x4 offsetMat;
	CalcRawPosMat(float4(kOffsetX,0,-kOffsetZ,1), offsetPos, offsetMat);
	return offsetMat;
}

static float4x4 WorldMat = CalcMat();

void CalcPosNormal(float4 Pos0, out float4 oPos, out float3 oNormal)
{
	float4x4 mat;
	CalcRawPosMat(Pos0, oPos, mat);

	oPos = mul(oPos, WorldMat);
	oNormal = mul(mat._12_22_32, (float3x3)(WorldMat));
}

float4 CalcPos(float4 Pos0)
{
	float4x4 mat;
	float4 oPos;
	CalcRawPosMat(Pos0, oPos, mat);
	oPos = mul(oPos, WorldMat);
	return oPos;
}


////////////////////////////////////////////////////////////////////////////////////////////////
// �֊s�`��
/*
// ���_�V�F�[�_
float4 ColorRender_VS(float4 Pos : POSITION) : POSITION 
{
	// �J�������_�̃��[���h�r���[�ˉe�ϊ�
	Pos = CalcPos(Pos);
	return mul( Pos, WorldViewProjMatrix );
}

// �s�N�Z���V�F�[�_
float4 ColorRender_PS() : COLOR
{
	// �֊s�F�œh��Ԃ�
	return EdgeColor;
}

// �֊s�`��p�e�N�j�b�N
technique EdgeTec < string MMDPass = "edge"; > {
	pass DrawEdge {
		AlphaBlendEnable = FALSE;
		AlphaTestEnable  = FALSE;

		VertexShader = compile vs_2_0 ColorRender_VS();
		PixelShader  = compile ps_2_0 ColorRender_PS();
	}
}
*/
technique EdgeTec < string MMDPass = "edge"; > {}

///////////////////////////////////////////////////////////////////////////////////////////////
// �e�i��Z���t�V���h�E�j�`��

// ���_�V�F�[�_
float4 Shadow_VS(float4 Pos : POSITION) : POSITION
{
	// �J�������_�̃��[���h�r���[�ˉe�ϊ�
	Pos = CalcPos(Pos);
	return mul( Pos, WorldViewProjMatrix );
}

// �s�N�Z���V�F�[�_
float4 Shadow_PS() : COLOR
{
	// �A���r�G���g�F�œh��Ԃ�
	return float4(AmbientColor.rgb, 0.65f);
}

// �e�`��p�e�N�j�b�N
technique ShadowTec < string MMDPass = "shadow"; > {
	pass DrawShadow {
		VertexShader = compile vs_2_0 Shadow_VS();
		PixelShader  = compile ps_2_0 Shadow_PS();
	}
}



///////////////////////////////////////////////////////////////////////////////////////////////
// �Z���t�V���h�E�pZ�l�v���b�g

struct VS_ZValuePlot_OUTPUT {
	float4 Pos : POSITION;				// �ˉe�ϊ����W
	float4 ShadowMapTex : TEXCOORD0;	// Z�o�b�t�@�e�N�X�`��
};

// ���_�V�F�[�_
VS_ZValuePlot_OUTPUT ZValuePlot_VS( float4 Pos : POSITION, float2 Tex : TEXCOORD0 )
{
	VS_ZValuePlot_OUTPUT Out = (VS_ZValuePlot_OUTPUT)0;

	// ���C�g�̖ڐ��ɂ�郏�[���h�r���[�ˉe�ϊ�������
	Pos = CalcPos(Pos);
	Out.Pos = mul( Pos, LightWorldViewProjMatrix );

	// �e�N�X�`�����W�𒸓_�ɍ��킹��
	Out.ShadowMapTex = Out.Pos;

	return Out;
}

// �s�N�Z���V�F�[�_
float4 ZValuePlot_PS( float4 ShadowMapTex : TEXCOORD0, float2 Tex : TEXCOORD1 ) : COLOR
{
	// R�F������Z�l���L�^����
	return float4(ShadowMapTex.z/ShadowMapTex.w,0,0,1);
}

// Z�l�v���b�g�p�e�N�j�b�N
technique ZplotTec < string MMDPass = "zplot"; > {
	pass ZValuePlot {
		AlphaBlendEnable = FALSE;
		VertexShader = compile vs_2_0 ZValuePlot_VS();
		PixelShader  = compile ps_2_0 ZValuePlot_PS();
	}
}


///////////////////////////////////////////////////////////////////////////////////////////////
// �I�u�W�F�N�g�`��i�Z���t�V���h�EON�j

// �V���h�E�o�b�t�@�̃T���v���B"register(s0)"�Ȃ̂�MMD��s0���g���Ă��邩��
sampler DefSampler : register(s0);

struct BufferShadow_OUTPUT {
	float4 Pos		: POSITION;	 // �ˉe�ϊ����W
	float4 ZCalcTex : TEXCOORD0;	// Z�l
	float2 Tex		: TEXCOORD1;	// �e�N�X�`��
	float3 Normal   : TEXCOORD2;	// �@��
	float3 WPos		: TEXCOORD3;
};

// ���_�V�F�[�_
BufferShadow_OUTPUT DrawObject_VS(float4 Pos : POSITION, // , float3 Normal : NORMAL, 
	float2 Tex : TEXCOORD0,
	uniform bool useTexture, uniform bool useSphereMap, 
	uniform bool useToon, uniform bool useSelfShadow)
{
	BufferShadow_OUTPUT Out = (BufferShadow_OUTPUT)0;

	float3 Normal;
	CalcPosNormal(Pos, Pos, Normal);

	// �J�������_�̃��[���h�r���[�ˉe�ϊ�
	Out.Pos = mul( Pos, WorldViewProjMatrix );
	Out.WPos = mul( Pos, WorldMatrix );
	Out.Normal = normalize( mul( Normal, (float3x3)WorldMatrix ) );

	if (useSelfShadow)
	{
		// ���C�g���_�ɂ�郏�[���h�r���[�ˉe�ϊ�
		Out.ZCalcTex = mul( Pos, LightWorldViewProjMatrix );
	}

	// �e�N�X�`�����W
	Out.Tex = Tex;

	return Out;
}


// ����
#if defined(BACKFACE_TEXTURE_NAME) || defined(BACKFACE_COLOR)
float4 DrawBack_PS(BufferShadow_OUTPUT IN,
	uniform bool useTexture, uniform bool useSphereMap, 
	uniform bool useToon, uniform bool useSelfShadow) : COLOR
{
	float4 Color = float4(1,1,1, DiffuseColor.a);
	float4 ShadowColor = float4(AmbientColor, Color.a);  // �e�̐F

	#if defined(ENABLE_SPECULAR) || defined(ENABLE_DIFFUSE)
	float3 L = -LightDirection;
	float3 V = normalize(CameraPosition - IN.WPos);
	float3 N = normalize(IN.Normal);
	#endif

	#ifdef ENABLE_SPECULAR
	float specular = CalcSpecular(L, N, V, SpecularPower) * SpecularScale;
	#else
	float specular = 0;
	#endif

	#ifdef ENABLE_DIFFUSE
	float diffuse = CalcDiffuse(L, N, V);
	Color.rgb = AmbientColor + DiffuseColor.rgb;
	#else
	float diffuse = 1;
	#endif

	#if defined(BACKFACE_TEXTURE_NAME)
	float4 BackColor = tex2D(BackfaceSamp, IN.Tex);
	#else
	float4 BackColor = BACKFACE_COLOR;
	#endif
	Color *= BackColor;
	ShadowColor *= BackColor;

	float comp = 1;

	#ifdef ENABLE_DIFFUSE
	if (useSelfShadow)
	{
		// �e�N�X�`�����W�ɕϊ�
		IN.ZCalcTex /= IN.ZCalcTex.w;
		float2 TransTexCoord;
		TransTexCoord.x = (1.0f + IN.ZCalcTex.x)*0.5f;
		TransTexCoord.y = (1.0f - IN.ZCalcTex.y)*0.5f;
		if( any( saturate(TransTexCoord) != TransTexCoord ) ) {
			// �V���h�E�o�b�t�@�O
			;
		} else {
			float a = (parthf) ? SKII2*TransTexCoord.y : SKII1;
			float d = IN.ZCalcTex.z;
			float z = tex2D(DefSampler,TransTexCoord).r;
			comp = 1 - saturate(max(d - z, 0.0f)*a-0.3f);
		}

		specular *= comp;
	}

	comp = saturate(min(comp, diffuse));
	#endif

	#ifdef ENABLE_SPECULAR
	Color.rgb += specular * (SpecularColor);
	#endif

	Color.rgb = lerp(ShadowColor.rgb, Color.rgb, comp);

	#if defined(ENABLE_ADDITION_MODE)
	Color.rgb *= Color.a;
	#endif

	return Color;
}
#endif

// �s�N�Z���V�F�[�_
float4 DrawObject_PS(BufferShadow_OUTPUT IN,
	uniform bool useTexture, uniform bool useSphereMap, 
	uniform bool useToon, uniform bool useSelfShadow) : COLOR
{
	float4 Color = float4(1,1,1, DiffuseColor.a);

	#if defined(ENABLE_SPECULAR) || defined(ENABLE_DIFFUSE)
	float3 L = -LightDirection;
	float3 V = normalize(CameraPosition - IN.WPos);
	float3 N = normalize(IN.Normal);
	#endif

	#ifdef ENABLE_SPECULAR
	float specular = CalcSpecular(L, N, V, SpecularPower) * SpecularScale;
	#else
	float specular = 0;
	#endif

	#ifdef ENABLE_DIFFUSE
	float diffuse = CalcDiffuse(L, N, V);
	Color.rgb = AmbientColor + DiffuseColor.rgb;
	#else
	float diffuse = 1;
	#endif

	float4 ShadowColor = float4(AmbientColor, Color.a);  // �e�̐F

	#if defined(BASE_TEXTURE_NAME)
	float4 BaseColor = tex2D(BaseSamp, IN.Tex);
	Color *= BaseColor;
	ShadowColor *= BaseColor;
	#endif
	#if defined(BASEPATTERN_TEXTURE_NAME)
	float4 BasePatternColor = tex2D(BasePatternSamp, IN.Tex * BASEPATTERN_LOOP_SIZE);
	BasePatternColor.rgb = lerp(BasePatternColor.rgb, 1, mPatternFade); // ���͈ێ�
	Color *= BasePatternColor;
	ShadowColor *= BasePatternColor;
	#endif

	// ����
	float4 TexColor = tex2D( ObjTexSampler, GetTexCoord(IN.Tex));
	Color *= TexColor;
	ShadowColor *= TexColor;

	#if defined(COVER_TEXTURE_NAME)
	float4 CoverColor = tex2D(CoverSamp, IN.Tex);
	Color.rgb = lerp(Color, CoverColor, CoverColor.a).rgb;
	ShadowColor.rgb = lerp(ShadowColor, CoverColor, CoverColor.a).rgb;
	#endif

	float comp = 1;

	#ifdef ENABLE_DIFFUSE
	if (useSelfShadow)
	{
		// �e�N�X�`�����W�ɕϊ�
		IN.ZCalcTex /= IN.ZCalcTex.w;
		float2 TransTexCoord;
		TransTexCoord.x = (1.0f + IN.ZCalcTex.x)*0.5f;
		TransTexCoord.y = (1.0f - IN.ZCalcTex.y)*0.5f;
		if( any( saturate(TransTexCoord) != TransTexCoord ) ) {
			// �V���h�E�o�b�t�@�O
			;
		} else {
			float a = (parthf) ? SKII2*TransTexCoord.y : SKII1;
			float d = IN.ZCalcTex.z;
			float z = tex2D(DefSampler,TransTexCoord).r;
			comp = 1 - saturate(max(d - z, 0.0f)*a-0.3f);
		}

		specular *= comp;
	}

	comp = saturate(min(comp, diffuse));
	#endif

	#ifdef ENABLE_SPECULAR
	// �X�y�L�����K�p
	Color.rgb += specular * (SpecularColor);
	#endif

	Color.rgb = lerp(ShadowColor.rgb, Color.rgb, comp);

	#if defined(ENABLE_ADDITION_MODE)
	Color.rgb *= Color.a;
	#endif

	return Color;
}


// �������[�h
#if defined(ENABLE_ADDITION_MODE)
#define ARPHA_MODE	\
        SRCBLEND=ONE;\
        DESTBLEND=ONE;
#else
#define ARPHA_MODE	
#endif

// �w�ʏ���
#if defined(BACKFACE_TEXTURE_NAME) || defined(BACKFACE_COLOR)
#define BACKFACE_PASS(tex, sphere, toon, selfshadow)	\
		pass DrawBack { \
			cullmode = none; \
			VertexShader = compile vs_3_0 DrawObject_VS(tex, sphere, toon, selfshadow); \
			PixelShader  = compile ps_3_0 DrawBack_PS(tex, sphere, toon, selfshadow); \
		}
#define CULLING_MODE
#else
#define BACKFACE_PASS(tex, sphere, toon, selfshadow)
#if defined(ENABLE_DOUBLE_FACE)
#define CULLING_MODE		CullMode = none;
#else
#define CULLING_MODE
#endif
#endif

#if defined(DISABLE_ZWRITE)
#define ZWRITE_MODE				ZWriteEnable = false;
#else
#define ZWRITE_MODE
#endif

#define OBJECT_TEC(name, mmdpass, tex, sphere, toon, selfshadow) \
	technique name < string MMDPass = mmdpass; bool UseSelfShadow = selfshadow;\
	> { \
		BACKFACE_PASS(tex, sphere, toon, selfshadow) \
		pass DrawObject { \
			CULLING_MODE \
			ARPHA_MODE \
			ZWRITE_MODE \
			VertexShader = compile vs_3_0 DrawObject_VS(tex, sphere, toon, selfshadow); \
			PixelShader  = compile ps_3_0 DrawObject_PS(tex, sphere, toon, selfshadow); \
		} \
	}

OBJECT_TEC(MainTec0, "object", true, false, false, false)
OBJECT_TEC(MainTecBS7, "object_ss", true, false, false, true)



///////////////////////////////////////////////////////////////////////////////////////////////

