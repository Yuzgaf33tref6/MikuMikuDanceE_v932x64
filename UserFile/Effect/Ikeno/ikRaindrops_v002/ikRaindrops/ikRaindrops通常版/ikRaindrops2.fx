

// ���H�̑傫��
static float ParticleSize = 1.0;

// ���H����������܂ł̍ŏ�����
static float LifetimeMin = 60.0;
// ���H����������܂ł̗h�ꕝ
static float LifetimeFluctuation = 60.0;

// ���H�̗������x
static float DropSpeedRate = 0.1;

// �������ɍ��E�Ɏ֍s���鋭��
static float DropSlideRate = 1.0;

// �������̕ό`
// �����s�ׂ̍܂藦(�㑤�Ɖ���)
static float ParticleGrowTopWidthScale = 0.25;
static float ParticleGrowBottomWidthScale = 0.5;

// �O�Ղ��������x(1�����ɂ��邱�ƁB)
static const float DryRate = 0.94;


// ���H�̐F��ς���
static float4 DropletMulColor = float4(1,1,1,1);
static float4 DropletAddColor = float4(0,0,0,0);

// ���H�̃n�C���C�g�̉s��
static const float SpecularPower = 16;
// ���H�̃n�C���C�g�̋���
static const float SpecularScale = 0.1;

// �e�N�X�`����ɉ��̉J���p�^�[�������邩?
static int NumRaindropInTextureW = 4;	// ������
static int NumRaindropInTextureH = 1;	// �c����
// �X�̗������x�� (�������x�������ƕs���R�Ȃ̂Ńo�������邽�߂����̐ݒ�)
// ���ォ��E�と�������E���̏��B
static const float EachDropSpeedRate[] = {
	1.0, 0.6, 0.9, 0.7
};

// �ҏW���[�h�ŉJ���~�߂�
//#define STOP_IN_EDITMODE	1

// 0�t���Đ����ɐ��H��������? (0:�����Ȃ��B1:����)
#define RESET_AT_START		1

// ���H�ďo���܂ł̍ő�x������
const float MaxRespawnWait = 30.0;


// �J�̋��ܗp�摜����邽�߂̃G�t�F�N�g�t�@�C���B
// �����ŕύX���Ȃ��Ă��AMME�̃^�u���RefractRT�̃G�t�F�N�g�t�@�C����ύX���Ă��悢�B
//#define OFFSCREEN_FX_OBJECT  "full_v1.4_1.fx"
#define OFFSCREEN_FX_OBJECT  "none"


// ���[�N�p�e�N�X�`���̑傫��
#define	BUFFER_SIZE		1024


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

// �c�����̐L�ї�
// �����������ƌ����ڂ����������Ȃ�B
static float ParticleGrowHeightScale = 2.0;

///////////////////////////////////////////////////////////////////////////////////////////////
// �J�����j�b�g
#define TEX_WIDTH		1024
#define TEX_HEIGHT		1

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

texture CoordTex : RENDERCOLORTARGET
<
	int Width=TEX_WIDTH;
	int Height=TEX_HEIGHT;
	int MipLevels = 1;
	string Format="A32B32G32R32F";
>;

sampler CoordSmp
{
   Texture = <CoordTex>;
	AddressU  = CLAMP;
	AddressV = CLAMP;
	MinFilter = NONE;
	MagFilter = NONE;
	MipFilter = NONE;
};

texture CoordTex_cpy : RENDERCOLORTARGET
<
	int Width=TEX_WIDTH;
	int Height=TEX_HEIGHT;
	int MipLevels = 1;
	string Format="A32B32G32R32F";
>;

sampler CoordSmp_cpy
{
   Texture = <CoordTex_cpy>;
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
	string ResourceName = "raindrops_volume.png";
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
	int MipLevels = 1;
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

// �J���̍���(�p�[�e�B�N�����烌���_�����O)
texture WaterHeightRawTex : RENDERCOLORTARGET
<
	int Width=BUFFER_SIZE;
	int Height=BUFFER_SIZE;
	int MipLevels = 1;
	string Format="R16F";
>;

sampler WaterHeightRawSmp
{
	Texture = <WaterHeightRawTex>;
	AddressU  = CLAMP;
	AddressV = CLAMP;
	MinFilter = LINEAR;
	MagFilter = LINEAR;
};
texture WaterHeightRawTexDepth : RenderDepthStencilTarget <
	int Width=BUFFER_SIZE;
	int Height=BUFFER_SIZE;
   string Format = "D24S8";
>;

// �O�Օt���̉J���̍���
texture WaterHeightBlurTex : RENDERCOLORTARGET
<
	int Width=BUFFER_SIZE;
	int Height=BUFFER_SIZE;
	int MipLevels = 1;
	string Format="R16F";
>;

sampler WaterHeightBlurSmp
{
	Texture = <WaterHeightBlurTex>;
	AddressU  = CLAMP;
	AddressV = CLAMP;
	MinFilter = LINEAR;
	MagFilter = LINEAR;
};

// �␳�����J���̍���
texture WaterHeightSynthTex : RENDERCOLORTARGET
<
	int Width=BUFFER_SIZE;
	int Height=BUFFER_SIZE;
	int MipLevels = 1;
	string Format="R16F";
>;

sampler WaterHeightSynthSmp
{
	Texture = <WaterHeightSynthTex>;
	AddressU  = CLAMP;
	AddressV = CLAMP;
	MinFilter = LINEAR;
	MagFilter = LINEAR;
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
	return tex2D(CoordSmp,Tex);
}

float4 UpdatePos_PS(float2 Tex: TEXCOORD0) : COLOR
{
	float4 Pos = tex2D(CoordSmp_cpy, Tex);

	int index = floor(Tex.x * TEX_WIDTH);

	if (IsTimeToReset() || Pos.w <= 0.0)
	{
		if (index < AcsTr * TEX_WIDTH && Pos.z < 0.5)
		{
			Pos = RAND(index, -1.0, 1.0);
			Pos.z = LifetimeMin + abs(Pos.z) * LifetimeFluctuation;
			Pos.w = 1;		// ����
		} else {
			// �ҋ@���
			Pos.w = 0;

			// Tr���㏸�����Ƃ���A�}���ɉJ�������Ȃ��悤��z�ŃE�F�C�g���|����
			Pos.z -= elapseTime;
			if (Pos.z < 0.0 || Pos.z > MaxRespawnWait) Pos.xyz = RAND(index, 1.0, MaxRespawnWait).xyz;
		}
	}
	else if (Pos.w > 0.0)
	{
		float2 TexCoord = Pos.xy * 0.5 + 0.5;
		TexCoord.y = 1.0 - TexCoord.y;
		float r = (0.1 * ParticleSize * PanelInvScale) * 1.2;
		int dropType = index % (NumRaindropInTextureW * NumRaindropInTextureH);
		float eachDropSpeedRate = EachDropSpeedRate[dropType];

		Pos.z -= (elapseTime * eachDropSpeedRate);
		if (Pos.z < 0.0)
		{
			float dt = min(elapseTime * 30.0, 1.0);

			// ����
			float rate = saturate(-Pos.z * 0.5) * 2.0;
			float fallSpeed = rate * PanelInvScale * eachDropSpeedRate * dt;
			Pos.y -= fallSpeed * DropSpeedRate;

			// ���̂���ق��Ɉړ�����
			float2 rnd = tex2D(RandomSmp, TexCoord).xy;
			float h =	tex2D(WaterHeightSynthSmp, TexCoord + float2(-r,r)).r -
						tex2D(WaterHeightSynthSmp, TexCoord + float2( r,r)).r;
			h = clamp(h,-1,1);
			h += (rnd.x - rnd.y);
			Pos.x -= h * (DropSlideRate * BUFFER_SIZE / 1000.0 / 1000.0) * dt;

			Pos.w = (Pos.y < -1.0) ? 0 : Pos.w; // ��ʊO�ɏo���玀�S�B
		}
		else
		{
			// ������艺�ɉJ��������? ����Ȃ���ė�������B
			float h =	tex2D(WaterHeightSynthSmp, TexCoord + float2(-r*0.25,r)).r +
						tex2D(WaterHeightSynthSmp, TexCoord + float2( 0,r)).r +
						tex2D(WaterHeightSynthSmp, TexCoord + float2( r*0.25,r)).r;
			Pos.z -= (h > 0.1) ? (Pos.z+1.0) : (h * 5);
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
// �ȈՔłł́A���̂܂܉�ʂɕ`�悵�Ă������A��������e�N�X�`���ɏ����o���B
struct VS_OUTPUT2
{
	float4 Pos			: POSITION;
	float4 Tex			: TEXCOORD0;
};

VS_OUTPUT2 DrawDrops_VS(float4 Pos : POSITION, float2 Tex : TEXCOORD0)
{
	VS_OUTPUT2 Out=(VS_OUTPUT2)0;

	int index = round( Pos.z * 100.0f );
	float2 texCoord = float2((index+0.5f)/TEX_WIDTH, (0.5f)/TEX_HEIGHT);

	// �e�N�X�`��
	int raindropPattern = index % (NumRaindropInTextureW * NumRaindropInTextureH);
	int raindropPatternW = raindropPattern % NumRaindropInTextureW;
	int raindropPatternH = floor(raindropPattern / NumRaindropInTextureW);
	Out.Tex.xy = Pos.xy * (10 * 0.5) + 0.5;
	Out.Tex.x = (Out.Tex.x + raindropPatternW) / NumRaindropInTextureW;
	Out.Tex.y = (Out.Tex.y + raindropPatternH) / NumRaindropInTextureH;
	Out.Tex.y = 1.0 - Out.Tex.y;

	// ���q�̍��W
	float4 particle = tex2Dlod(CoordSmp, float4(texCoord,0,0));
	float2 pos0 = particle.xy;

	float thick = 1;
	if (particle.z < 0.0)
	{
		// �������͕ό`����
		float rate = saturate(-particle.z * 0.25);
		if (Pos.y > 0.0)
		{
			Pos.y *= (1 + ParticleGrowHeightScale * rate);
			Pos.x *= (1 - ParticleGrowTopWidthScale * rate);
		}
		else
		{
			Pos.x *= (1 - ParticleGrowBottomWidthScale * rate);
		}

		// �������͔����Ȃ�
		thick = (1 - 0.5 * rate);
	}

	Pos.xy *= ParticleSize * PanelInvScale;
	Pos.xy += particle.xy;
	Pos.z = 0;

	Out.Pos = (particle.w >= 1.0) ? Pos : float4(0,0,0,0);
	Out.Tex.z = thick;

   return Out;
}


float4 DrawDrops_PS( VS_OUTPUT2 IN ) : COLOR0
{
	float a = tex2D(ParticleSamp, IN.Tex.xy).r * IN.Tex.z;
	return float4(1,0,0, a);
}


///////////////////////////////////////////////////////////////////////////////////////////////

VS_OUTPUT2 TexCoord_VS( float4 Pos : POSITION, float4 Tex : TEXCOORD0 )
{
	VS_OUTPUT2 Out = (VS_OUTPUT2)0; 

	Out.Pos = Pos;
	Out.Tex = Tex + 0.5 / BUFFER_SIZE;
	return Out;
}

// �J���̍��������炩�ɂ���B
// ���Ƃ��Ƃ́ASynthDrops_PS�ŁA
// WaterHeightSynthSmp �� WaterHeightRawSmp + WaterHeightSynthSmp �Ƃ������Ȃ������̂ŁA
// �����ŁA��i���܂��āA
// WaterHeightBlurSmp �� WaterHeightSynthSmp
// WaterHeightSynthSmp �� WaterHeightRawSmp + WaterHeightBlurSmp �Ƃ��邽�߂ɍ�����B
float4 BlurDrops_PS( VS_OUTPUT2 IN ) : COLOR0
{
	float2 uv = IN.Tex.xy;
	float v0 = tex2D(WaterHeightSynthSmp, uv).r;
	if (v0 > 1.0/1024.0)
	{
		float s = 1.0 / BUFFER_SIZE;
		float v1 =
			tex2D(WaterHeightSynthSmp, uv + float2( s, 0)).r +
			tex2D(WaterHeightSynthSmp, uv + float2(-s, 0)).r +
			tex2D(WaterHeightSynthSmp, uv + float2( 0, s)).r +
			tex2D(WaterHeightSynthSmp, uv + float2( 0,-s)).r;
		v0 = (v0 + v1) / 5.0;
	}

	return float4(v0,0,0, 1);
}

// ���̍����ƃ{�J���������������B
// �Ƃǂ܂��Ă���J���̏��ׂō������O�a���Ȃ��悤�ɒ������Ă���B
float4 SynthDrops_PS( VS_OUTPUT2 IN ) : COLOR0
{
	float v0 = tex2D(WaterHeightRawSmp, IN.Tex.xy).r;
	float v1 = tex2D(WaterHeightBlurSmp, IN.Tex.xy).r * DryRate;
	return float4(v0 + saturate(v1 - v0),0,0, 1);
}


///////////////////////////////////////////////////////////////////////////////////////////////
// ��ʂɕ`��B
// �J���̍�������@�����Z�o�A���܂������w�i��`��B
struct VS_OUTPUT3
{
	float4 Pos			: POSITION;
	float2 Tex			: TEXCOORD0;
	float4 Screen		: TEXCOORD1;
	float3 Eye			: TEXCOORD2;
};

VS_OUTPUT3 DrawLast_VS(float4 Pos : POSITION, float4 Tex : TEXCOORD0)
{
	VS_OUTPUT3 Out = (VS_OUTPUT3)0;
	Out.Pos = (Pos.z == 0.0) ? mul( Pos, WorldViewProjMatrix ) : float4(0,0,0,0);
	Out.Tex = Tex.xy + (0.5 / BUFFER_SIZE);
	Out.Screen = Out.Pos;
	Out.Eye = CameraPosition - mul( Pos, WorldMatrix ).xyz;

	return Out;
}


float4 DrawLast_PS(VS_OUTPUT3 IN) : COLOR
{
	float v = tex2D(WaterHeightSynthSmp, IN.Tex).r;
	clip(v - 1.0/1024.0);

	float s = 1.0 / BUFFER_SIZE;
	float nx = tex2D(WaterHeightSynthSmp, IN.Tex + float2(s, 0)).r - tex2D(WaterHeightSynthSmp, IN.Tex + float2(-s, 0)).r;
	float ny = tex2D(WaterHeightSynthSmp, IN.Tex + float2(0, s)).r - tex2D(WaterHeightSynthSmp, IN.Tex + float2( 0,-s)).r;
	float nz = 1.0;
	float3 N = normalize(float3(nx,ny,nz));

	float2 texCoord = IN.Screen.xy / IN.Screen.w;
	texCoord = texCoord * 0.5 + 0.5;
	texCoord.y = 1.0 - texCoord.y;
	texCoord.xy += (N.xy);
	float4 Color = tex2D(RefractSamp, texCoord);

	Color = Color * DropletMulColor + DropletAddColor;

	// �X�y�L�����̓K�p
	const float3 V = normalize(IN.Eye);
	float3 HalfVector = normalize( V + -LightDirection );
	Color.rgb += saturate(pow( max(0,dot( HalfVector, mul( N, WorldMatrix ))), SpecularPower)) * SpecularScale;

	Color.a *= v;

	// �e�X�g�p
	// float4 Color = float4(0,1,1,v);

	return Color;
}


///////////////////////////////////////////////////////////////////////////////////////////////
// �f�o�b�O�p
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
float4 ClearColorHeight = {0,0,0,0};

technique MainTec1 < string MMDPass = "object";
	string Script = 
		"RenderColorTarget0=CoordTex_cpy;"
		"RenderDepthStencilTarget=CoordDepthBuffer;"
		"Pass=CpyPos;"
	
		"RenderColorTarget0=CoordTex;"
		"Pass=UpdatePos;"

		"RenderColorTarget0=WaterHeightRawTex;"
		"RenderDepthStencilTarget=WaterHeightRawTexDepth;"
		"ClearSetColor=ClearColorHeight;"
		"Clear=Color;"
		"Pass=DrawDrops;"

		"RenderColorTarget0=WaterHeightBlurTex;"
		"Pass=PassBlur;"
		"RenderColorTarget0=WaterHeightSynthTex;"
		"Pass=PassSynth;"

		"RenderColorTarget0=;"
		"RenderDepthStencilTarget=;"
		"Pass=DrawObject;";
>{

	pass UpdatePos < string Script= "Draw=Buffer;"; > {
		ALPHABLENDENABLE = false;
		ALPHATESTENABLE = false;
		ZENABLE = false;
		ZWRITEENABLE = false;
		VertexShader = compile vs_3_0 Common_VS();
		PixelShader  = compile ps_3_0 UpdatePos_PS();
	}
	pass CpyPos < string Script= "Draw=Buffer;"; > {
		ALPHABLENDENABLE = false;
		ALPHATESTENABLE = false;
		ZENABLE = false;
		ZWRITEENABLE = false;
		VertexShader = compile vs_3_0 Common_VS();
		PixelShader  = compile ps_3_0 Cpy_PS();
	}

	pass DrawDrops {
		ZENABLE = false;
		ZWRITEENABLE = false;
		VertexShader = compile vs_3_0 DrawDrops_VS();
		PixelShader  = compile ps_3_0 DrawDrops_PS();
	}

	pass PassBlur < string Script= "Draw=Buffer;"; > {
		ALPHABLENDENABLE = false;
		ALPHATESTENABLE = false;
		ZENABLE = false;
		ZWRITEENABLE = false;
		VertexShader = compile vs_3_0 TexCoord_VS();
		PixelShader  = compile ps_3_0 BlurDrops_PS();
	}

	pass PassSynth < string Script= "Draw=Buffer;"; > {
		ALPHABLENDENABLE = false;
		ALPHATESTENABLE = false;
		ZENABLE = false;
		ZWRITEENABLE = false;
		VertexShader = compile vs_3_0 TexCoord_VS();
		PixelShader  = compile ps_3_0 SynthDrops_PS();
	}

	pass DrawObject {
		VertexShader = compile vs_3_0 DrawLast_VS();
		PixelShader  = compile ps_3_0 DrawLast_PS();
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


