

// ���H�̑傫��
static float ParticleSize = 2.0;

// ���H����������܂ł̍ŏ�����
static float LifetimeMin = 5.0;
// ���H����������܂ł̗h�ꕝ
static float LifetimeFluctuation = 20.0;

// ���H�̗������x
static float DropSpeedRate = 0.02;

// �e�N�X�`����ɉ��̉J���p�^�[�������邩?
static int NumRaindropInTextureW = 4;	// ������
static int NumRaindropInTextureH = 1;	// �c����

// �ҏW���[�h�ŉJ���~�߂�
//#define STOP_IN_EDITMODE	1

// �Đ����ɐ��H��������?
#define RESET_AT_START		1

// �J�̋��ܗp�摜����邽�߂̃G�t�F�N�g�t�@�C���B
// �����ŕύX���Ȃ��Ă��AMME�̃^�u���RefractRT�̃G�t�F�N�g�t�@�C����ύX���Ă��悢�B
#define OFFSCREEN_FX_OBJECT  "full_v1.4_1.fx"


///////////////////////////////////////////////////////////////////////////////////////////////

// �p�l���̃T�C�Y(�ɍ��킹�āA���x��p�[�e�B�N���̃T�C�Y��␳����)
float AcsSi  : CONTROLOBJECT < string name = "(self)"; string item = "Si"; >;
// ���H�̎g�p���B
float AcsTr  : CONTROLOBJECT < string name = "(self)"; string item = "Tr"; >;


float4x4 WorldViewProjMatrix	: WORLDVIEWPROJECTION;
float4x4 ViewProjMatrix			: VIEWPROJECTION;
float4x4 WorldMatrix			: WORLD;
float3   LightDirection			: DIRECTION < string Object = "Light"; >;
float3   CameraPosition			: POSITION  < string Object = "Camera"; >;

static float PanelInvScale = 10.0 / AcsSi;


#if defined(STOP_IN_EDITMODE) && STOP_IN_EDITMODE > 1
#define TIME_FLAG		< bool SyncInEditMode = true; >
#else
#define TIME_FLAG
#endif
float time : TIME TIME_FLAG;
float elapseTime : ELAPSEDTIME TIME_FLAG;


///////////////////////////////////////////////////////////////////////////////////////////////
#define TEX_WIDTH		1024
#define TEX_HEIGHT		1

// ���������p
texture2D RandomTex <
	string ResourceName = "rand256.png";
>;
sampler RandomSmp = sampler_state{
	texture = <RandomTex>;
	MinFilter = POINT;
	MagFilter = POINT;
	MipFilter = NONE;
	AddressU  = WRAP;
	AddressV = WRAP;
};

texture CoordTex : RENDERCOLORTARGET
<
   int Width=TEX_WIDTH;
   int Height=TEX_HEIGHT;
   string Format="A32B32G32R32F";
>;

sampler CoordSmp : register(s3) = sampler_state
{
   Texture = <CoordTex>;
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
	string ResourceName = "raindrops.png";
	int MipLevels = 1;
>;
sampler ParticleSamp = sampler_state {
	texture = <ParticleTex>;
	MinFilter = LINEAR;
	MagFilter = LINEAR;
	MipFilter = NONE;
	AddressU  = CLAMP;
	AddressV  = CLAMP;
};


// �J�̋��ܗp
texture RefractRT : OFFSCREENRENDERTARGET <
	string Description = "OffScreen RenderTarget for ikRaindrops.fx";
	// float2 ViewPortRatio = {1.0,1.0};
	float2 ViewPortRatio = {0.25,0.25};
		// �{�J���Ȃ�0.5,0.5�Ƃ��ŏ\��
	float4 ClearColor = { 0, 0, 0, 0 };
	float ClearDepth = 1.0;
	bool AntiAlias = true;
	string DefaultEffect = 
		"self = hide;"
		"*.pmd =" OFFSCREEN_FX_OBJECT ";"
		"*.pmx =" OFFSCREEN_FX_OBJECT ";"
		"*.x=   " OFFSCREEN_FX_OBJECT ";"
		"* = hide;" ;
>;
sampler RefractSamp = sampler_state {
	texture = <RefractRT>;
	MinFilter = LINEAR;
	MagFilter = LINEAR;
	MipFilter = NONE;
	AddressU  = CLAMP;
	AddressV = CLAMP;
};



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




// ���ʂ̒��_�V�F�[�_
VS_OUTPUT Common_VS(float4 Pos: POSITION, float2 Tex: TEXCOORD)
{
	VS_OUTPUT Out;
	Out.Pos = Pos;
	Out.Tex = Tex + float2(0.5f/TEX_WIDTH, 0.5f/TEX_HEIGHT);
	return Out;
}

float4 UpdatePos_PS(float2 Tex: TEXCOORD0) : COLOR
{
	float4 Pos = tex2D(CoordSmp, Tex);

	int index = floor(Tex.x * TEX_WIDTH);

	if (
#if defined(RESET_AT_START) && RESET_AT_START != 0
		time < 1.0 / 120.0 ||
#endif
		Pos.w == 0.0)
	{
		if (index < AcsTr * TEX_WIDTH && Pos.z < 0.5)
		{
			Pos = RAND(index, -1.0, 1.0);
			Pos.z = LifetimeMin + abs(Pos.z) * LifetimeFluctuation;
			Pos.w = (Pos.w * 10.0) + 20.0;		// ����
				// �����鎞�̍��E�̃Y�����ɂ��g�p����B
		} else {
			// �ҋ@���
			Pos.w = 0;

			// Tr���㏸�����Ƃ���A�}���ɉJ�������Ȃ��悤��z�ŃE�F�C�g���|����
			Pos.z -= elapseTime;
			if (Pos.z < 0.0) Pos.xyz = RAND(index, 1.0, 30.0);
		}
	}
	else if (Pos.w > 0.0)
	{
		Pos.z -= elapseTime;
		if (Pos.z < 0.0)
		{
			// ����
			float fallSpeed = saturate(-Pos.z * 0.5) * 2.0 * PanelInvScale;
			Pos.y -= fallSpeed * DropSpeedRate;

			// ���X���E�ɃY����B
			float sign = (Pos.w - 20.0) * 0.001 * PanelInvScale;
			Pos.x += sin(Pos.z * 0.1) * sign;

			Pos.w = (Pos.y < -1.0) ? 0 : Pos.w; // ��ʊO�ɏo���玀�S�B
		}
	}

	return Pos;
}

// �N���A
float4 ClearPos_PS(float2 Tex: TEXCOORD0) : COLOR
{
	return float4(0,0,0,0);
}

///////////////////////////////////////////////////////////////////////////////////////
// �p�[�e�B�N���`��

struct VS_OUTPUT2
{
	float4 Pos			: POSITION;	// �ˉe�ϊ����W
	float2 Tex			: TEXCOORD0;
	float4 Screen		: TEXCOORD1;
	float3 Eye			: TEXCOORD2;
};

// ���_�V�F�[�_
VS_OUTPUT2 Particle_VS(float4 Pos : POSITION, float3 Normal : NORMAL, float2 Tex : TEXCOORD0)
{
	VS_OUTPUT2 Out=(VS_OUTPUT2)0;

	int index = round( Pos.z * 100.0f );
	float2 texCoord = float2((index+0.5f)/TEX_WIDTH, (0.5f)/TEX_HEIGHT);

	// �e�N�X�`��
	int raindropPattern = index % (NumRaindropInTextureW * NumRaindropInTextureH);
	int raindropPatternW = raindropPattern % NumRaindropInTextureW;
	int raindropPatternH = floor(raindropPattern / NumRaindropInTextureW);
	Out.Tex = Pos.xy * 5 + 0.5;
	Out.Tex.x = (Out.Tex.x + raindropPatternW) / NumRaindropInTextureW;
	Out.Tex.y = (Out.Tex.y + raindropPatternH) / NumRaindropInTextureH;
	Out.Tex.y = 1.0 - Out.Tex.y;

	// ���q�̍��W
	float4 particle = tex2Dlod(CoordSmp, float4(texCoord,0,0));
	float2 pos0 = particle.xy;

	float thick = 1;		// ���H�̌���
	if (particle.z < 0.0)
	{
		// �������͐��H���ό`����
		float rate = saturate(-particle.z * 0.25);
		if (Pos.y > 0.0)
		{
			Pos.y *= (1 + 4 * rate);
			Pos.x *= (1 - 0.5 * rate);
			thick = 1.0 - 0.5 * rate;
		}
		thick *= (1.0 - 0.5 * rate);
	}

	Pos.xy *= ParticleSize * 0.1 * PanelInvScale;

	Pos.xy += (particle.xy * 0.1);
	Pos.z = 0;

	float4 result = (particle.w >= 1.0) ? mul( Pos, WorldViewProjMatrix ) : float4(0,0,0,0);
//	float4 result = (Pos.z == 0.0) ? mul( Pos, WorldViewProjMatrix ) : float4(0,0,0,0);

	Out.Pos = result;
	Out.Screen = result;
	Out.Screen.z = thick;

	Out.Eye = CameraPosition - mul( Pos, WorldMatrix );


   return Out;
}


float4 Particle_PS( VS_OUTPUT2 IN ) : COLOR0
{
	float4 Color = 1;

	const float3 V = normalize(IN.Eye);

	float4 N = tex2D(ParticleSamp, IN.Tex) * 2 - 1.0;
	float2 texCoord = IN.Screen.xy / IN.Screen.w;
	float thick = IN.Screen.z * 1.0;
	texCoord = texCoord * 0.5 + 0.5;
	texCoord.y = 1.0 - texCoord.y;
	texCoord.xy += (N.xy * thick);
	float4 c = tex2D(RefractSamp, texCoord);

	float3 HalfVector = normalize( V + -LightDirection );
	c.rgb += pow( max(0,dot( HalfVector, N )), 16);

	Color.rgb = c.rgb;
	Color.a = c.a * N.a;

	return Color;
}



///////////////////////////////////////////////////////////////////////////////////////////////
float4 DrawPanel_VS(float4 Pos : POSITION) : POSITION
{
	// �J�������_�̃��[���h�r���[�ˉe�ϊ�
	float4 result = (Pos.z == 0.0) ? mul( Pos, WorldViewProjMatrix ) : float4(0,0,0,0);
	return result;
}

float4 DrawPanel_PS() : COLOR
{
	return float4(0,0,1,0.25);
}


///////////////////////////////////////////////////////////////////////////////////////////////

technique MainTec1 < string MMDPass = "object";
	string Script = 
		"RenderColorTarget0=CoordTex;"
		"RenderDepthStencilTarget=CoordDepthBuffer;"
		"Pass=UpdatePos;"

		"RenderColorTarget0=;"
		"RenderDepthStencilTarget=;"
		"Pass=DrawObject;";
>{
	pass UpdatePos < string Script= "Draw=Buffer;"; > {
		ALPHABLENDENABLE = FALSE;
		ALPHATESTENABLE = FALSE;
		VertexShader = compile vs_3_0 Common_VS();
		PixelShader  = compile ps_3_0 UpdatePos_PS();
	}

	pass DrawObject {
		VertexShader = compile vs_3_0 Particle_VS();
		PixelShader  = compile ps_3_0 Particle_PS();
	}
}

// �f�o�b�O�p�ɂ����̃p�l���Ƃ��ĕ`�悷��B
technique MainTec2 < string MMDPass = "object_ss";
	string Script = 
		"RenderColorTarget0=CoordTex;"
		"RenderDepthStencilTarget=CoordDepthBuffer;"
		"Pass=ClearPos;"

		"RenderColorTarget0=;"
		"RenderDepthStencilTarget=;"
		"Pass=DrawObject;";
>{
	pass ClearPos < string Script= "Draw=Buffer;"; > {
		ALPHABLENDENABLE = FALSE;
		ALPHATESTENABLE = FALSE;
		VertexShader = compile vs_3_0 Common_VS();
		PixelShader  = compile ps_3_0 ClearPos_PS();
	}

	pass DrawObject {
		VertexShader = compile vs_3_0 DrawPanel_VS();
		PixelShader  = compile ps_3_0 DrawPanel_PS();
	}
}

technique ZplotTec < string MMDPass = "zplot"; > {}
technique ShadowTec < string MMDPass = "shadow"; > {}
technique EdgeTec < string MMDPass = "edge"; > {}


