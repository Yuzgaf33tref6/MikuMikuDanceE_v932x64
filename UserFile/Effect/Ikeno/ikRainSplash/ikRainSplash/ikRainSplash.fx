

// ���Ԃ��̑傫��
#define ParticleSize	4.0

// ���Ԃ��̐�������(�b)
#define	LifetimeMin		0.05
#define	LifetimeMax		0.1

// ���Ԃ��̕s�����x�B
// ����łׂ͒��̂����z���āA�ő����傫�߂̂ق������������B
#define SPLASH_ALPHA		0.2

// �e�N�X�`���p�^�[��
#define	PATTERN_FILENAME	"splash.png"
// �e�N�X�`����ɉ��̃p�^�[�������邩?
#define	NumSplashInTextureW	4	// ������
#define	NumSplashInTextureH	4	// �c����

// ���Ԃ��̍ő�ʁBUNIT_COUNTx1024�܂ŏo��B1�`4���x
// ���Ԃ��̔����ʂ�Tr�Ő��䂷��B
#define	UNIT_COUNT		1

// �ҏW���[�h�ŉJ���~�߂�B0:�~�߂Ȃ��A1:�~�߂�
#define STOP_IN_EDITMODE	0

// 0�t���Đ����ɐ��H��������? (0:�����Ȃ��B1:����)
#define RESET_AT_START		1


// �J�̍~��͈́B�ʏ��Si�Ő��䂷��B
// heigh.fx�ɂ������ݒ肪����B
#define	LightRange		20


// ikBokeh�p�ɐ[�x���o�͂���ꍇ�Ɏw�肷��B
//#define	CoordTextureName	SplashCoordTex


// ��]���x(����)
#define	ParticleRotSpeed	4.0

///////////////////////////////////////////////////////////////////////////////////////////////

float AcsSi  : CONTROLOBJECT < string name = "(self)"; string item = "Si"; >;
float AcsTr  : CONTROLOBJECT < string name = "(self)"; string item = "Tr"; >;

float4x4 matV		: VIEW;
float4x4 matVP		: VIEWPROJECTION;
float4x4 matWVP		: WORLDVIEWPROJECTION;
float4x4 matVInv	: VIEWINVERSE;

static float3x3 BillboardMatrix = {
	normalize(matVInv[0].xyz),
	normalize(matVInv[1].xyz),
	normalize(matVInv[2].xyz),
};

#if defined(STOP_IN_EDITMODE) && STOP_IN_EDITMODE > 1
#define TIME_FLAG		< bool SyncInEditMode = true; >
#else
#define TIME_FLAG
#endif
float time : TIME TIME_FLAG;
float elapseTime : ELAPSEDTIME TIME_FLAG;

int RepeatCount = UNIT_COUNT;  // �V�F�[�_���`�攽����
int RepeatIndex;				// �������f���J�E���^

///////////////////////////////////////////////////////////////////////////////////////////////
// �J�����j�b�g
#define TEX_WIDTH		1024
#define TEX_HEIGHT		UNIT_COUNT

texture HeightMapRT: OFFSCREENRENDERTARGET <
	string Description = "Height Map for ikParticle";
	int Width=512;
	int Height=512;
	string Format = "A16B16G16R16F";
	int Miplevels = 1;
	bool AntiAlias = false;
	float4 ClearColor = { 0.0, 0.0, 0.0, 0.0};
	float ClearDepth = 1.0;
	string DefaultEffect = 
		"self = hide;"
		"*.pmd = height.fx;"
		"*.pmx = height.fx;"
//		"*.x = height.fx;"
		"* = hide;";
>;
sampler HeightSamp = sampler_state {
	texture = <HeightMapRT>;
	AddressU  = WRAP;
	AddressV = WRAP;
	MinFilter = POINT;
	MagFilter = POINT;
};

// ���������p
texture2D RandomTex <
	string ResourceName = "rand256.png";
	int MipLevels = 1;
>;
sampler RandomSmp = sampler_state{
	texture = <RandomTex>;
	MinFilter = POINT;
	MagFilter = POINT;
	MipFilter = NONE;
	AddressU  = WRAP;
	AddressV = WRAP;
};

#if !defined(CoordTextureName)
#define	CoordTextureName	CoordTex
#define CoordTextureAttribute	
#else
#define CoordTextureAttribute	shared
#endif
CoordTextureAttribute texture CoordTextureName : RENDERCOLORTARGET
<
	int Width=TEX_WIDTH;
	int Height=TEX_HEIGHT;
	string Format = "A16B16G16R16F";
>;
sampler CoordSmp
{
   Texture = <CoordTextureName>;
	AddressU  = CLAMP;
	AddressV = CLAMP;
	MinFilter = NONE;
	MagFilter = NONE;
	MipFilter = NONE;
};

texture CoordTexCpy : RENDERCOLORTARGET
<
	int Width=TEX_WIDTH;
	int Height=TEX_HEIGHT;
	int MipLevels = 1;
	string Format = "A16B16G16R16F";
>;
sampler CoordSmpCpy
{
   Texture = <CoordTexCpy>;
	AddressU  = CLAMP;
	AddressV = CLAMP;
	MinFilter = NONE;
	MagFilter = NONE;
	MipFilter = NONE;
};

texture CoordDepthBuffer : RenderDepthStencilTarget <
   int Width=TEX_WIDTH;
   int Height=TEX_HEIGHT;
   string Format = "D24S8";
>;

texture2D ParticleTex <
	string ResourceName = PATTERN_FILENAME;
	int MipLevels = 0;
>;
sampler ParticleSamp = sampler_state {
	texture = <ParticleTex>;
	MinFilter = LINEAR;
	MagFilter = LINEAR;
	MipFilter = LINEAR;
	AddressU  = CLAMP;
	AddressV  = CLAMP;
};



//////////////////////////////////////////////////////////////////////////////////////////
//

float3x3 RoundMatrixZ(int index, float etime)
{
	float rotZ = ParticleRotSpeed * (1.0f + 0.3f*sin(122*index)) * etime + (float)index * 369.0f;

	float sinz, cosz;
	sincos(rotZ, sinz, cosz);

	float3x3 rMat = { cosz*1+0*0*sinz, 1*sinz, -0*cosz+0*1*sinz,
					-1*sinz+0*0*cosz, 1*cosz,  0*sinz+0*1*cosz,
					 1*0,				-0,		1*1,				};

	return rMat;
}

///////////////////////////////////////////////////////////////////////////////////////////////

struct VS_OUTPUT {
	float4 Pos : POSITION;
	float2 Tex : TEXCOORD0;
};

// �K���ȗ���
#define RAND(index, minVal, maxVal)		random(index, __LINE__, minVal, maxVal)
float4 random(float index, int index2, float minVal, float maxVal)
{
	float f = (index * 5531 + index2 + time * 61.0 + time * 1031.0) / 256.0;
	float2 uv = float2(f, f / 256.0);
	float4 tex1 = tex2D(RandomSmp, uv);
	float4 tex2 = tex2D(RandomSmp, uv.yx * 7.1);
	return frac(tex1 + tex2) * (maxVal - minVal) + minVal;
}


// �J�n�t���[���Ń��Z�b�g����?
inline bool IsTimeToReset()
{
#if defined(RESET_AT_START) && RESET_AT_START != 0
	return (time < 1.0 / 120.0);
#else
	return false;
#endif
}



// ���ʂ̒��_�V�F�[�_
VS_OUTPUT Common_VS(float4 Pos: POSITION, float2 Tex: TEXCOORD)
{
	VS_OUTPUT Out;
	Out.Pos = Pos;
	Out.Tex = Tex + float2(0.5f/TEX_WIDTH, 0.5f/TEX_HEIGHT);
	return Out;
}

float4 Cpy_PS(float2 Tex: TEXCOORD0) : COLOR
{
	return IsTimeToReset() ? float4(0,0,0,0) : tex2D(CoordSmp,Tex);
}

float2 Directions[] = {
	float2(-1,-1),
	float2( 1,-1),
	float2(-1, 1),
	float2( 1, 1),
};

float4 UpdatePos_PS(float2 Tex: TEXCOORD0) : COLOR
{
	float4 Pos = tex2D(CoordSmpCpy, Tex);

	int ix = floor( Tex.x * TEX_WIDTH );
	int iy = floor( Tex.y * TEX_HEIGHT );
	int index = ix * TEX_HEIGHT + iy;

	Pos.w -= elapseTime;

	if (Pos.w <= 0.0)
	{
		float4 tmp = RAND(index, 0.0, 1.0);
		float t = frac(abs(dot(tmp, 1)));
		int type = index % 4;

		if (index < AcsTr * (TEX_WIDTH * TEX_HEIGHT) /*&& Pos.w < -0.5*/)
		{
			// ����
			float2 v = Directions[type] * (31.0/512.0);
			for(int i = 0; i < 8; i++)
			{
				// �s�K���ȏꏊ�Ȃ�ă`�F�b�N
				float4 pos0 = tex2D(HeightSamp, tmp.xy + i * v);
				Pos = (Pos.w > 0.0) ? Pos : pos0;
			}

			// Pos.xyz += (tmp.xyz * 2.0 - 1.0) * 0.1;

			float lifetime = LifetimeMin + t * (LifetimeMax - LifetimeMin);
			Pos.w = (Pos.w > 0.0) ? lifetime : -1;
		}
	}

	return Pos;
}


///////////////////////////////////////////////////////////////////////////////////////
// �p�[�e�B�N���`��
struct VS_OUTPUT2
{
	float4 Pos			: POSITION;
	float4 Tex			: TEXCOORD0;
};

VS_OUTPUT2 DrawDrops_VS(float4 Pos : POSITION, float2 Tex : TEXCOORD0)
{
	VS_OUTPUT2 Out=(VS_OUTPUT2)0;

	int i = RepeatIndex;
	int j = round( Pos.z * 100.0f );
	int index = i * TEX_WIDTH + j;
	float2 texCoord = float2((j+0.5f)/TEX_WIDTH, (i+0.5f)/TEX_HEIGHT);

	// �e�N�X�`��
	int splashPattern = index % (NumSplashInTextureW * NumSplashInTextureH);
	int splashPatternW = splashPattern % NumSplashInTextureW;
	int splashPatternH = floor(splashPattern / NumSplashInTextureW);
	Out.Tex.xy = Pos.xy * (10 * 0.5) + 0.5;
	Out.Tex.x = (Out.Tex.x + splashPatternW) / NumSplashInTextureW;
	Out.Tex.y = (Out.Tex.y + splashPatternH) / NumSplashInTextureH;
	Out.Tex.y = 1.0 - Out.Tex.y;

	// ���q�̍��W
	float4 Pos0 = tex2Dlod(CoordSmpCpy, float4(texCoord,0,0));

	Pos.xy *= ParticleSize;
	Pos.z = 0;
	//float3x3 matWTmp = RoundMatrixZ(index, time);
	//Pos.xyz = mul(Pos.xyz, matWTmp );
	Pos.xyz = mul(Pos.xyz, BillboardMatrix);

	Pos.xyz += Pos0.xyz;
	Pos.w = 1.0f;
	Out.Pos = (Pos0.w > 0.0) ? mul( Pos, matVP ) : float4(0,0,0,0);
	// ������O�ɏo��
	Out.Pos.z -= 1 / max(Out.Pos.w, 1.0);

	// �[�x�ɉ����Ĕ�������
	float depth = mul( Pos, matV ).z;
	Out.Tex.w = 1.0 / (depth/100.0 + 1);

   return Out;
}


float4 DrawDrops_PS( VS_OUTPUT2 IN ) : COLOR0
{
	float alpha = SPLASH_ALPHA * (AcsTr * 0.5 + 0.5) * IN.Tex.w;
	alpha *= tex2D(ParticleSamp, IN.Tex.xy).r;

//return float4(tex2D(HeightSamp, IN.Tex.xy).rgb, 1);

	return float4(1,1,1, alpha);
}


///////////////////////////////////////////////////////////////////////////////////////////////
VS_OUTPUT2 DrawArea_VS(float4 Pos : POSITION, float2 Tex : TEXCOORD0)
{
	VS_OUTPUT2 Out=(VS_OUTPUT2)0;

	int i = 0;
	int j = round( Pos.z * 100.0f );
	int index = i * TEX_WIDTH + j;

	Out.Tex.xy = Pos.xy * (10 * 0.5) + 0.5;
	Out.Tex.y = 1.0 - Out.Tex.y;

	Pos.xy *= LightRange;
	Pos.z = 0;
	Pos.xyz = Pos.xzy;
	Pos.w = 1.0f;

	Out.Pos = (index == 0) ? mul( Pos, matWVP ) : float4(0,0,0,0);

   return Out;
}


float4 DrawArea_PS( VS_OUTPUT2 IN ) : COLOR0
{
	float4 col = tex2D(HeightSamp, IN.Tex.xy);

	col = (col.w > 0.0) ? float4(0,0,1,1) : float4(0,0,1,0.5);

	return col;
}


///////////////////////////////////////////////////////////////////////////////////////////////
float4 ClearColorHeight = {0,0,0,0};

#define STRGEN(x)	#x
#define	COORD_TEX_NAME_STRING		STRGEN(CoordTextureName)

technique MainTec1 < string MMDPass = "object";
	string Script = 
		"RenderDepthStencilTarget=CoordDepthBuffer;"
		"RenderColorTarget0=CoordTexCpy;	Pass=CpyPos;"
		"RenderColorTarget0=" COORD_TEX_NAME_STRING ";	Pass=UpdatePos;"

		"RenderColorTarget0=;"
		"RenderDepthStencilTarget=;"
		"LoopByCount=RepeatCount;"
		"LoopGetIndex=RepeatIndex;"
			"Pass=DrawObject;"
		"LoopEnd=;";
>{
	pass UpdatePos < string Script= "Draw=Buffer;"; > {
		ALPHABLENDENABLE = false;	ALPHATESTENABLE = false;
		VertexShader = compile vs_3_0 Common_VS();
		PixelShader  = compile ps_3_0 UpdatePos_PS();
	}
	pass CpyPos < string Script= "Draw=Buffer;"; > {
		ALPHABLENDENABLE = false;	ALPHATESTENABLE = false;
		VertexShader = compile vs_3_0 Common_VS();
		PixelShader  = compile ps_3_0 Cpy_PS();
	}

	pass DrawObject {
		ZENABLE = TRUE; ZWRITEENABLE = FALSE;
		VertexShader = compile vs_3_0 DrawDrops_VS();
		PixelShader  = compile ps_3_0 DrawDrops_PS();
	}
}


// �e�X�g�p�̃G���A�\��
technique MainTec2 < string MMDPass = "object_ss";>{
	pass DrawArea {
		VertexShader = compile vs_3_0 DrawArea_VS();
		PixelShader  = compile ps_3_0 DrawArea_PS();
	}
}


technique ZplotTec < string MMDPass = "zplot"; > {}
technique ShadowTec < string MMDPass = "shadow"; > {}
technique EdgeTec < string MMDPass = "edge"; > {}


