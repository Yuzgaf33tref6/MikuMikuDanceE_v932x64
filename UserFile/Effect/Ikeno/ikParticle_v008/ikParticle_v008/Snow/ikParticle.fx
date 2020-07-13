////////////////////////////////////////////////////////////////////////////////////////////////
//
// ikParticle.fx �I�u�W�F�N�g�̓����ɉe�����󂯂�p�[�e�B�N���G�t�F�N�g
//
// �x�[�X�F
//  CannonParticle.fx ver0.0.4 �ł��o�����p�[�e�B�N���G�t�F�N�g
//  �쐬: �j��P
//
////////////////////////////////////////////////////////////////////////////////////////////////


// �ݒ�t�@�C��
#include "ikParticleSettings.fxsub"


////////////////////////////////////////////////////////////////////////////////////////////////

// �ő剽�܂Ń{�[����o�^���邩
#define MaxWindNum		8

// �e�N�X�`���̕�
// MaxWindNum <= WIND_TEX_HEIGHT �ł���K�v������B
#define WIND_TEX_HEIGHT	8

#define	DECL_WIND(_suffix, _name)	\
	float3 WindPosition##_suffix : CONTROLOBJECT < string name = _name; >;	\
	float WindScale##_suffix : CONTROLOBJECT < string name = _name; string item = "Si"; >;	\
	float WindPower##_suffix : CONTROLOBJECT < string name = _name; string item = "Tr"; >;	

DECL_WIND( _01, "ikWindMaker01.x")
DECL_WIND( _02, "ikWindMaker02.x")
DECL_WIND( _03, "ikWindMaker03.x")
DECL_WIND( _04, "ikWindMaker04.x")
DECL_WIND( _05, "ikWindMaker05.x")
DECL_WIND( _06, "ikWindMaker06.x")
DECL_WIND( _07, "ikWindMaker07.x")
DECL_WIND( _08, "ikWindMaker08.x")

inline float4 GetWindPos(float3 pos, float scale)
{
	return float4(pos, 0.23 * 10.0 / max(scale, 1e-4));
}

static float4 WindPositionArray[] = {
	GetWindPos(WindPosition_01, WindScale_01),
	GetWindPos(WindPosition_02, WindScale_02),
	GetWindPos(WindPosition_03, WindScale_03),
	GetWindPos(WindPosition_04, WindScale_04),
	GetWindPos(WindPosition_05, WindScale_05),
	GetWindPos(WindPosition_06, WindScale_06),
	GetWindPos(WindPosition_07, WindScale_07),
	GetWindPos(WindPosition_08, WindScale_08),
};

static float WindPowerArray[] = {
	WindPower_01,
	WindPower_02,
	WindPower_03,
	WindPower_04,
	WindPower_05,
	WindPower_06,
	WindPower_07,
	WindPower_08,
};


////////////////////////////////////////////////////////////////////////////////////////////////
// �p�����[�^�錾
const float AlphaThroughThreshold = 0.5;

#define TEX_WIDTH	UNIT_COUNT  // ���W���e�N�X�`���s�N�Z����
#define TEX_HEIGHT	1024		// �z�u��������e�N�X�`���s�N�Z������

#define PAI 3.14159265f	// ��

#define STRGEN(x)	#x
#define	COORD_TEX_NAME_STRING		STRGEN(COORD_TEX_NAME)

float AcsTr  : CONTROLOBJECT < string name = "(self)"; string item = "Tr"; >;
float AcsSi  : CONTROLOBJECT < string name = "(self)"; string item = "Si"; >;

int RepeatCount = UNIT_COUNT;  // �V�F�[�_���`�攽����
int RepeatIndex;				// �������f���J�E���^

static float diffD = radians( clamp(90.0f - DiffusionAngle, -90.0f, 90.0f) );

// ���Ԑݒ�
float time1 : TIME;
float time2 : TIME < bool SyncInEditMode = true; >;
static float time = TimeSync ? time1 : time2;
float elapsed_time1 : ELAPSEDTIME;
float elapsed_time2 : ELAPSEDTIME < bool SyncInEditMode = true; >;
static float Dt = clamp(TimeSync ? elapsed_time1 : elapsed_time2, 0.0f, 0.1f);
float3   CameraPosition    : POSITION  < string Object = "Camera"; >;
float3	LightDirection	: DIRECTION < string Object = "Light"; >;
float4x4 matVPLight : VIEWPROJECTION < string Object = "Light"; >;

#if MMD_LIGHTCOLOR == 1
float3   LightSpecular     : SPECULAR  < string Object = "Light"; >;
static float3 LightColor = LightSpecular * 2.5 / 1.5;
#else
float3 LightSpecular = float3(1, 1, 1);
float3 LightColor = float3(1, 1, 1);
#endif

bool	 parthf;   // �p�[�X�y�N�e�B�u�t���O
#define SKII1	1500
#define SKII2	8000

// 1�t���[��������̗��q������
static float P_Count = ParticleOccur * (Dt / ParticleLife) * AcsSi*100;


// ���W�ϊ��s��
float4x4 matW	: WORLD;
float4x4 matV	 : VIEW;
float4x4 matVP : VIEWPROJECTION;

#if USE_BILLBOARD == 1
float4x4 matVInv	: VIEWINVERSE;
static float3x3 BillboardMatrix = {
	normalize(matVInv[0].xyz),
	normalize(matVInv[1].xyz),
	normalize(matVInv[2].xyz),
};

float4x4 matLightVInv : VIEWINVERSE < string Object = "Light"; >;
static float3x3 LightBillboardMatrix = {
	normalize(matLightVInv[0].xyz),
	normalize(matLightVInv[1].xyz),
	normalize(matLightVInv[2].xyz),
};
#endif


// �V���h�E�o�b�t�@�̃T���v���B"register(s0)"�Ȃ̂�MMD��s0���g���Ă��邩��
sampler DefSampler : register(s0);

	texture2D ParticleTex <
		string ResourceName = TEX_FileName;
		int MipLevels = 1;
	>;
	sampler ParticleTexSamp = sampler_state {
		texture = <ParticleTex>;
		MinFilter = LINEAR;
		MagFilter = LINEAR;
		MipFilter = NONE;
		AddressU  = CLAMP;
		AddressV  = CLAMP;
	};

	#if(USE_SPHERE == 1)
	texture2D ParticleSphere <
		string ResourceName = SPHERE_FileName;
		int MipLevels = 1;
	>;
	sampler ParticleSphereSamp = sampler_state {
		texture = <ParticleSphere>;
		MinFilter = LINEAR;
		MagFilter = LINEAR;
		MipFilter = NONE;
		AddressU  = CLAMP;
		AddressV  = CLAMP;
	};
	#endif

// ���q���W�L�^�p
texture CoordWorkTex : RENDERCOLORTARGET
<
	int Width=TEX_WIDTH;
	int Height=TEX_HEIGHT;
	string Format="A32B32G32R32F";
>;
sampler CoordWorkSmp = sampler_state
{
	Texture = <CoordWorkTex>;
	AddressU  = CLAMP;
	AddressV = CLAMP;
	MinFilter = NONE;
	MagFilter = NONE;
	MipFilter = NONE;
};

// ���q���W�L�^�p
shared texture COORD_TEX_NAME : RENDERCOLORTARGET
<
	int Width=TEX_WIDTH;
	int Height=TEX_HEIGHT;
	string Format="A32B32G32R32F";
>;
sampler CoordSmp = sampler_state
{
	Texture = <COORD_TEX_NAME>;
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

// ���q���x�L�^�p
texture VelocityTex : RENDERCOLORTARGET
<
	int Width=TEX_WIDTH;
	int Height=TEX_HEIGHT;
	string Format="A32B32G32R32F";
>;
sampler VelocitySmp = sampler_state
{
	Texture = <VelocityTex>;
	AddressU  = CLAMP;
	AddressV = CLAMP;
	MinFilter = NONE;
	MagFilter = NONE;
	MipFilter = NONE;
};

texture VelocityTexCopy : RENDERCOLORTARGET
<
	int Width=TEX_WIDTH;
	int Height=TEX_HEIGHT;
	string Format="A32B32G32R32F";
>;
sampler VelocitySmpCopy = sampler_state
{
	Texture = <VelocityTexCopy>;
	AddressU  = CLAMP;
	AddressV = CLAMP;
	MinFilter = NONE;
	MagFilter = NONE;
	MipFilter = NONE;
};


// ���������p
texture2D RandomTex <
	string ResourceName = "../Commons/rand128.png";
>;
sampler RandomSmp = sampler_state{
	texture = <RandomTex>;
	MinFilter = POINT;
	MagFilter = POINT;
	MipFilter = NONE;
	AddressU  = WRAP;
	AddressV = WRAP;
};

#define RND_TEX_SIZE 128

#if defined(PALLET_FileName) && USE_PALLET > 0
texture2D ColorPallet <
	string ResourceName = PALLET_FileName;
>;
sampler ColorPalletSmp = sampler_state{
	texture = <ColorPallet>;
	MinFilter = POINT;
	MagFilter = POINT;
	MipFilter = NONE;
	AddressU  = WRAP;
	AddressV = WRAP;
};
#endif



////////////////////////////////////////////////////////////////////////////////////////////////
// �����蔻��
#if defined(ENABLE_BOUNCE) && ENABLE_BOUNCE > 0

#define AntiAliasMode		false
#define MipMapLevel			1
// �@���}�b�v
#if !defined(DRAW_NORMAL_MAP) || DRAW_NORMAL_MAP > 0
shared texture LPNormalMapRT: OFFSCREENRENDERTARGET <
	string Description = "render Normal and depth for ikParticle";
	float2 ViewPortRatio = {1, 1};
	string Format = "D3DFMT_A32B32G32R32F";		// RGB�ɖ@���BA�ɂ͐[�x���
	int Miplevels = MipMapLevel;
	bool AntiAlias = AntiAliasMode;
	float4 ClearColor = { 0.0, 0.0, 0.0, 0.0};
	float ClearDepth = 1.0;
	string DefaultEffect = 
		"self = hide;"
		"ikParticle*.x = hide;"		// �����ȊO�̓��ނ��r��
		"*.pmd = ikNormalMap.fx;"
		"*.pmx = ikNormalMap.fx;"
		"*.x = ikNormalMap.fx;"
		"* = hide;";
>;
#else
shared texture LPNormalMapRT: OFFSCREENRENDERTARGET;
#endif

sampler NormalMap = sampler_state {
	texture = <LPNormalMapRT>;
	AddressU  = CLAMP;
	AddressV = CLAMP;
	MinFilter = POINT;
	MagFilter = POINT;
	MipFilter = LINEAR;
};

inline void GetND(float2 Tex, out float3 N, out float Depth)
{
	float4 ND = tex2D( NormalMap, Tex );
	N = normalize(ND.xyz);
	Depth = ND.w;
}
#endif


////////////////////////////////////////////////////////////////////////////////////////////////
#define WIND_TEX_WIDTH	1
#define WIND_TEX_FMT	"A32B32G32R32F"

texture WindPositionRT: RENDERCOLORTARGET
<
	int Width = WIND_TEX_WIDTH;
	int Height = WIND_TEX_HEIGHT;
	string Format = WIND_TEX_FMT;
>;

sampler WindPositionMap = sampler_state {
	texture = <WindPositionRT>;
	MinFilter = POINT;
	MagFilter = POINT;
	MipFilter = POINT;
	AddressU  = CLAMP;
	AddressV = CLAMP;
};

texture WindVelocityRT: RENDERCOLORTARGET
<
	int Width = WIND_TEX_WIDTH;
	int Height = WIND_TEX_HEIGHT;
	string Format = WIND_TEX_FMT;
>;

sampler WindVelocityMap = sampler_state {
	texture = <WindVelocityRT>;
	MinFilter = POINT;
	MagFilter = POINT;
	MipFilter = POINT;
	AddressU  = CLAMP;
	AddressV = CLAMP;
};


////////////////////////////////////////////////////////////////////////////////////////////////

// �������|�C���g�̈ʒu
inline float4 GetWindPosition(int index)
{
	return (index < MaxWindNum) ? WindPositionArray[index] : float4(0,0,0,0);
}

// �����̎擾
inline float3 GetWindVelocity(float3 pos)
{
	float3 result = 0;

	for(int i = 0; i < MaxWindNum; i++) {
		float2 coord = float2(0.5 / WIND_TEX_WIDTH, (i + 0.5f) / WIND_TEX_HEIGHT);
		float4 wpos = WindPositionArray[i];
		float3 wvel = tex2D(WindVelocityMap, coord).xyz;
		result += exp(-length(pos - wpos.xyz) * wpos.w - 1e-4) * wvel;
	}

	return result * (50.0 * WindFactor);
}

inline bool IsTimeToReset()
{
	return (time < 0.001f);
}


////////////////////////////////////////////////////////////////////////////////////////////////
// �z�u��������e�N�X�`������f�[�^�����o��
float3 GetRand(float index)
{
	float u = floor(index + time);
	float v = fmod(u, RND_TEX_SIZE);
	u = floor(u / RND_TEX_SIZE);
	return tex2D(RandomSmp, float2(u,v) / RND_TEX_SIZE).xyz * 2.0 - 1.0;
}

float hash(float3 x)
{
	return cos(dot(x, float3(2.31,53.21,16.17))*124.123); 
}

float noise(float3 p)
{
	float3 pm = frac(p);
	float3 pd = p-pm;

	return lerp(hash(pd), hash(pd + 1.0), pm);
}

float3 PositionNoise(float3 pos)
{
	float scalex = (time * TurbulenceTimeScale + 0.136514);
	float scaley = (time * TurbulenceTimeScale + 1.216881);
	float scalez = (time * TurbulenceTimeScale + 2.556412);

	float x = noise(pos.xyz * float3(TurbulenceScale.xx, scalex));
	float y = noise(pos.yzx * float3(TurbulenceScale.xx, scaley));
	float z = noise(pos.zxy * float3(TurbulenceScale.xx, scalez));

	return float3(x,y,z);
}


////////////////////////////////////////////////////////////////////////////////////////////////
// ���q�̉�]�s��
float3x3 RoundMatrix(int index, float etime)
{
	float rotX = ParticleRotSpeed * (1.0f + 0.3f*sin(247*index)) * etime + (float)index * 147.0f;
	float rotY = ParticleRotSpeed * (1.0f + 0.3f*sin(368*index)) * etime + (float)index * 258.0f;
	float rotZ = ParticleRotSpeed * (1.0f + 0.3f*sin(122*index)) * etime + (float)index * 369.0f;

	float sinx, cosx;
	float siny, cosy;
	float sinz, cosz;
	sincos(rotX, sinx, cosx);
	sincos(rotY, siny, cosy);
	sincos(rotZ, sinz, cosz);

	float3x3 rMat = { cosz*cosy+sinx*siny*sinz, cosx*sinz, -siny*cosz+sinx*cosy*sinz,
					-cosy*sinz+sinx*siny*cosz, cosx*cosz,  siny*sinz+sinx*cosy*cosz,
					 cosx*siny,				-sinx,		cosx*cosy,				};
	return rMat;
}

// �ł��邾�����ʂ�������]�s��
float3x3 FacingRoundMatrix(int index, float etime, float4 Pos0)
{
	float3 v = normalize(CameraPosition - Pos0);
	float3x3 rMat = RoundMatrix(index, etime);

	float3 z = normalize(v * 0.5 + rMat[2]);
	float3 x = normalize(cross(rMat[1], z));
	float3 y = normalize(cross(z, x));

	float3x3 rMat2 = {x,y,z};
	return rMat2;
}

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

////////////////////////////////////////////////////////////////////////////////////////////////

struct VS_OUTPUT {
	float4 Pos : POSITION;
	float2 Tex : TEXCOORD0;
};

// ���ʂ̒��_�V�F�[�_
VS_OUTPUT Common_VS(float4 Pos: POSITION, float2 Tex: TEXCOORD)
{
	VS_OUTPUT Out;
	Out.Pos = Pos;
	Out.Tex = Tex + float2(0.5f/TEX_WIDTH, 0.5f/TEX_HEIGHT);
	return Out;
}

///////////////////////////////////////////////////////////////////////////////////////
struct PS_OUT_MRT
{
	float4 Pos		: COLOR0;
	float4 Vel		: COLOR1;
};

PS_OUT_MRT CopyPos_PS(float2 Tex: TEXCOORD0) : COLOR
{
	PS_OUT_MRT Out;
	Out.Pos = tex2D(CoordSmp, Tex);
	Out.Vel = tex2D(VelocitySmp, Tex);
	return Out;
}

// ���q�̔����E���W�X�V�v�Z(xyz:���W,w:�o�ߎ���+1sec,w�͍X�V����1�ɏ���������邽��+1s����X�^�[�g)
PS_OUT_MRT UpdatePos_PS(float2 Tex: TEXCOORD0) : COLOR
{
	// ���q�̍��W
	float4 Pos = tex2D(CoordSmp, Tex);

	// ���q�̑��x
	float4 Vel = tex2D(VelocitySmp, Tex);

	int i = floor( Tex.x*TEX_WIDTH );
	int j = floor( Tex.y*TEX_HEIGHT );
	int p_index = j + i * TEX_HEIGHT;

	if(Pos.w < 1.001f){

		// �V���ɗ��q�𔭐������邩�ǂ����̔���
		if(p_index < Vel.w) p_index += float(TEX_WIDTH*TEX_HEIGHT);
		if(p_index < Vel.w+P_Count){
		 Pos.w = 1.0011f;  // Pos.w>1.001�ŗ��q����

	// ���������q�̒�����V���ɗ��q�𔭐�������
		float3 WPos = GetRand(p_index);
		float3 WPos0 = matW._41_42_43;
		WPos *= ParticleInitPos * 0.1f;
		WPos = mul( float4(WPos,1), matW ).xyz;
		Pos.xyz = (WPos - WPos0) / AcsSi * 10.0f + WPos0;  // �����������W

	// ���������Ă̗��q�ɏ����x�^����
		float3 rand = GetRand(p_index * 17 + RND_TEX_SIZE);
		float time1 = time + 100.0f;
		float ss, cs;
		sincos( lerp(diffD, PAI*0.5f, frac(rand.x*time1)), ss, cs );
		float st, ct;
		sincos( lerp(-PAI, PAI, frac(rand.y*time1)), st, ct );
		float3 vec  = float3( cs*ct, ss, cs*st );
		Vel.xyz = normalize( mul( vec, (float3x3)matW ) )
				* lerp(ParticleSpeedMin, ParticleSpeedMax, frac(rand.z*time1));

		}
	}else{
	// �������q�͋^�������v�Z�ō��W���X�V
		// ���q�̖@���x�N�g��
		float3 normal = mul( float3(0.0f,0.0f,1.0f), RoundMatrix(p_index, Pos.w) );

		// ��R�W���̐ݒ�
		float v = length( Vel.xyz );
		float cosa = dot( normalize(Vel.xyz), normal );
		float coefResist = lerp(ResistFactor, 0.0f, smoothstep(-0.3f*ParticleSpeedMax, -10.0f, -v));
		float coefRotResist = lerp(0.2f, RotResistFactor, smoothstep(-0.3f*ParticleSpeedMax, -10.0f, -v));
		// �����x�v�Z(���x��R��+��]��R��+�d��)
		float3 Accel = -Vel.xyz * coefResist - normal * v * cosa * coefRotResist + GravFactor;

		// �V�������W�ɍX�V
		Pos.xyz += Dt * (Vel.xyz + Dt * Accel);

		// ���łɔ������Ă��闱�q�͌o�ߎ��Ԃ�i�߂�
		Pos.w += Dt;
		Pos.w *= step(Pos.w-1.0f, ParticleLife); // �w�莞�Ԃ𒴂����0

		Vel.xyz -= (Vel.xyz * (0.1 * Dt));
		Vel.xyz += GetWindVelocity(Pos.xyz) * (WindPowerScale * Dt);
		Vel.xyz += PositionNoise(Pos.xyz) * (Dt * TurbulenceFactor);
		Vel.xyz += GravFactor * Dt;

		#if defined(ENABLE_BOUNCE) && ENABLE_BOUNCE > 0
		// �ȒP�Ȍ�������
		float4 ppos = mul(float4(Pos.xyz,1), matVP );
		float dist = length(Pos.xyz - CameraPosition);
		float2 Tex2 = (1.0 + ppos.xy * float2(1, -1) / ppos.w) * 0.5;
		float3 N;
		float Depth;
		GetND(Tex2, N, Depth);
		float dotVN = dot(Vel.xyz, N);
		if (dotVN < 0.0 && Depth < dist && dist < Depth + IgnoreDpethOffset)
		{
			Vel.xyz = (Vel.xyz - N * (dotVN * (1 + BounceFactor))) * FrictionFactor;
		}

		// ����������������
		const float reduce = 0.75;
		Tex2 = Tex2 * reduce + (-0.5 * reduce + 0.5); // ����������
		GetND(Tex2, N, Depth);
		dotVN = dot(Vel.xyz, N);
		if (dotVN < 0.0)
		{
			float d = saturate(1.0 - abs(dist - Depth) * (1.0 / AvoidDistance));
			Vel.xyz -= N * (dotVN * d * d * AvoidFactor);
		}
		#endif
	}

	Vel.w += P_Count;
	if(Vel.w >= float(TEX_WIDTH*TEX_HEIGHT)) Vel.w -= float(TEX_WIDTH*TEX_HEIGHT);

	// 0�t���[���Đ��ŗ��q������
	if(IsTimeToReset())
	{
		Pos = float4(matW._41_42_43, 0.0f);
		Vel = 0.0f;
	}

	PS_OUT_MRT Out;
	Out.Pos = Pos;
	Out.Vel = Vel;
	return Out;
}

///////////////////////////////////////////////////////////////////////////////////////
// �p�[�e�B�N���`��

struct VS_OUTPUT2
{
	float4 Pos		: POSITION;	// �ˉe�ϊ����W
	float2 Tex		: TEXCOORD0;	// �e�N�X�`��
	float  TexIndex	: TEXCOORD1;	// �e�N�X�`�����q�C���f�N�X
	float4 ZCalcTex	: TEXCOORD2;	// Z�l
	float2 SpTex	: TEXCOORD4;	// �X�t�B�A�}�b�v�e�N�X�`�����W
	float4 Color	: COLOR0;		// ���q�̏�Z�F
};

// ���_�V�F�[�_
VS_OUTPUT2 Particle_VS(float4 Pos : POSITION, float2 Tex : TEXCOORD0, uniform bool useShadow)
{
	VS_OUTPUT2 Out=(VS_OUTPUT2)0;

	int i = RepeatIndex;
	int j = round( Pos.z * 100.0f );
	int Index0 = i * TEX_HEIGHT + j;
	float2 texCoord = float2((i+0.5f)/TEX_WIDTH, (j+0.5f)/TEX_HEIGHT);
	Pos.z = 0.0f;
	Out.TexIndex = float(j);

	// ���q�̍��W
	float4 Pos0 = tex2Dlod(CoordWorkSmp, float4(texCoord, 0, 0));

	// �o�ߎ���
	float etime = Pos0.w - 1.0f;

	#if( USE_SPHERE==1 )
	// ���q�̖@���x�N�g��(���_�P��)
	float3 Normal = normalize(float3(0.0f, 0.0f, -0.2f) - Pos.xyz);
	#endif

	// ���q�̑傫��
	Pos.xy *= ParticleSize * 10.0f;

	#if USE_BILLBOARD == 0
	//float3x3 matWTmp = RoundMatrix(Index0, etime);
	float3x3 matWTmp = FacingRoundMatrix(Index0, etime, Pos0);
	#else
	float3x3 matWTmp = RoundMatrixZ(Index0, etime);
	#endif

	// ���q�̉�]
	Pos.xyz = mul( Pos.xyz, matWTmp );
	#if USE_BILLBOARD != 0
	Pos.xyz = mul(Pos.xyz, BillboardMatrix);
	#endif

	// ���q�̃��[���h���W
	Pos.xyz += Pos0.xyz;
	Pos.xyz *= step(0.001f, etime);
	Pos.w = 1.0f;

	// �J�������_�̃r���[�ˉe�ϊ�
	Out.Pos = mul( Pos, matVP );
	if (useShadow) Out.ZCalcTex = mul( Pos, matVPLight );

	// ���C�g�̌v�Z
	#if ENABLE_LIGHT == 1
	float3 N = normalize(matWTmp[2]);
	float dotNL = dot(-LightDirection, N);
	float dotNV = dot(normalize(CameraPosition - Pos.xyz), N);
	dotNL = dotNL * sign(dotNV);
	float diffuse = lerp(max(dotNL,0) + max(-dotNL,0) * Translucency, 1, Translucency);
	#else
	float diffuse = 1;
	#endif

	// ���q�̏�Z�F
	float alpha = step(0.001f, etime) * smoothstep(-ParticleLife, -ParticleLife*ParticleDecrement, -etime) * AcsTr;
	// ���t�߂ŏ����Ȃ�
	#if !defined(ENABLE_BOUNCE) || ENABLE_BOUNCE == 0
	alpha *= smoothstep(FloorFadeMin, FloorFadeMax, Pos0.y);
	#endif
	Out.Color = float4(saturate(LightColor * diffuse + EmissivePower), alpha );

	// �e�N�X�`�����W
	int texIndex = Index0 % (TEX_PARTICLE_XNUM * TEX_PARTICLE_YNUM);
	int tex_i = texIndex % TEX_PARTICLE_XNUM;
	int tex_j = texIndex / TEX_PARTICLE_XNUM;
	Out.Tex = float2((Tex.x + tex_i)/TEX_PARTICLE_XNUM, (Tex.y + tex_j)/TEX_PARTICLE_YNUM);

	#if( USE_SPHERE==1 )
		// �X�t�B�A�}�b�v�e�N�X�`�����W
		Normal = mul( Normal, matWTmp );
		float2 NormalWV = mul( Normal, (float3x3)matV ).xy;
		Out.SpTex.x = NormalWV.x * 0.5f + 0.5f;
		Out.SpTex.y = NormalWV.y * -0.5f + 0.5f;
	#endif

	return Out;
}


// �s�N�Z���V�F�[�_
float4 Particle_PS( VS_OUTPUT2 IN, uniform bool useShadow ) : COLOR0
{
	// ���q�̐F
	float4 Color = IN.Color * tex2D( ParticleTexSamp, IN.Tex );
	#if( TEX_ZBuffWrite==1 )
		clip(Color.a - AlphaThroughThreshold);
	#endif

	#if ENABLE_LIGHT == 1
	if (useShadow)
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
			float light = 1 - saturate(max(d - tex2D(DefSampler,TransTexCoord).r , 0.0f)*a-0.3f);
			light = saturate(light + EmissivePower);
			Color.rgb = min(Color.rgb, light);
		}
	}
	#endif

	#if defined(PALLET_FileName) && USE_PALLET > 0
	// �����_���F�ݒ�
	float4 randColor = tex2D(ColorPalletSmp, float2((IN.TexIndex+0.5f) / PALLET_TEX_SIZE, 0.5));
	Color.rgb *= randColor.rgb;
	#endif

	#if( USE_SPHERE==1 )
		// �X�t�B�A�}�b�v�K�p
		Color.rgb += max(tex2D(ParticleSphereSamp, IN.SpTex).rgb * LightSpecular, 0);
		#if( SPHERE_SATURATE==1 )
			Color = saturate( Color );
		#endif
	#endif

	return Color;
}


///////////////////////////////////////////////////////////////////////////////////////
//

// ���ʂ̒��_�V�F�[�_
VS_OUTPUT CommonWind_VS(float4 Pos: POSITION, float2 Tex: TEXCOORD)
{
	VS_OUTPUT Out = (VS_OUTPUT)0;
	Out.Pos = Pos;
	Out.Tex = Tex + float2(0.5f/WIND_TEX_WIDTH, 0.5f/WIND_TEX_HEIGHT);
	return Out;
}

// ���݂̈ʒu�ƁA1�t���O�̈ʒu���瑬�x�����߂�
float4 UpdateWindVelocity_PS(float2 Tex: TEXCOORD0) : COLOR
{
	float4 pos = GetWindPosition(floor(Tex.y * WIND_TEX_HEIGHT));

	float3 oldPos = tex2D(WindPositionMap, Tex).xyz;

	// ��葬�x�ȉ��͖�������
	float3 v = (pos.xyz - oldPos) / Dt;
	float len = length(v);
	if (!IsTimeToReset() && len > MinWindSpeed)
	{
		int i = (int)floor(Tex.y * WIND_TEX_HEIGHT);
		v = v * (min(len - MinWindSpeed, MaxWindSpeed) / len) * WindPowerArray[i];
	} else {
		v = 0;
	}

	return float4(v, 1);
}

// ���݂̈ʒu��ۑ�
float4 UpdateWindPosition_PS(float2 Tex: TEXCOORD0) : COLOR
{
	float3 pos = GetWindPosition(floor(Tex.y * WIND_TEX_HEIGHT)).xyz;
	return float4(pos, 1);
}



///////////////////////////////////////////////////////////////////////////////////////////////
// �Z���t�V���h�E�pZ�l�v���b�g

struct VS_ZValuePlot_OUTPUT {
	float4 Pos : POSITION;				// �ˉe�ϊ����W
	float4 ShadowMapTex : TEXCOORD1;	// Z�o�b�t�@�e�N�X�`��

	float2 Tex		: TEXCOORD0;	// �e�N�X�`��
	float4 Color	 : COLOR0;		// ���q�̏�Z�F
};

// ���_�V�F�[�_
VS_ZValuePlot_OUTPUT ZValuePlot_VS( float4 Pos : POSITION, float2 Tex : TEXCOORD0 )
{
	VS_ZValuePlot_OUTPUT Out = (VS_ZValuePlot_OUTPUT)0;

	int i = RepeatIndex;
	int j = round( Pos.z * 100.0f );
	int Index0 = i * TEX_HEIGHT + j;
	float2 texCoord = float2((i+0.5f)/TEX_WIDTH, (j+0.5f)/TEX_HEIGHT);
	Pos.z = 0.0f;

	// ���q�̍��W
	float4 Pos0 = tex2Dlod(CoordWorkSmp, float4(texCoord, 0, 0));

	// �o�ߎ���
	float etime = Pos0.w - 1.0f;

	// ���q�̑傫��
	Pos.xy *= ParticleSize * 10.0f;

	// ���q�̉�]
	Pos.xyz = mul( Pos.xyz, RoundMatrix(Index0, etime) );

	// ���q�̃��[���h���W
	Pos.xyz += Pos0.xyz;
	Pos.xyz *= step(0.001f, etime);
	Pos.w = 1.0f;

	// ���C�g�̖ڐ��ɂ�郏�[���h�r���[�ˉe�ϊ�������
	Out.Pos = mul( Pos, matVPLight );

	// �e�N�X�`�����W�𒸓_�ɍ��킹��
	Out.ShadowMapTex = Out.Pos;

	// ���q�̏�Z�F
	float alpha = step(0.001f, etime) * smoothstep(-ParticleLife, -ParticleLife*ParticleDecrement, -etime) * AcsTr;
	#if !defined(ENABLE_BOUNCE) || ENABLE_BOUNCE == 0
	alpha *= smoothstep(FloorFadeMin, FloorFadeMax, Pos0.y);
	#endif
	Out.Color = float4( 1,1,1, alpha );

	// �e�N�X�`�����W
	int texIndex = Index0 % (TEX_PARTICLE_XNUM * TEX_PARTICLE_YNUM);
	int tex_i = texIndex % TEX_PARTICLE_XNUM;
	int tex_j = texIndex / TEX_PARTICLE_XNUM;
	Out.Tex = float2((Tex.x + tex_i)/TEX_PARTICLE_XNUM, (Tex.y + tex_j)/TEX_PARTICLE_YNUM);

	return Out;
}

// �s�N�Z���V�F�[�_
float4 ZValuePlot_PS(
		float4 ShadowMapTex	: TEXCOORD1,
		float2 Tex			: TEXCOORD0,
		float4 Color		: COLOR0
	) : COLOR
{
	float alpha = Color.a * tex2D( ParticleTexSamp, Tex ).a;
	clip(alpha - AlphaThroughThreshold);

	// R�F������Z�l���L�^����
	return float4(ShadowMapTex.z/ShadowMapTex.w,0,0,1);
}

// Z�l�v���b�g�p�e�N�j�b�N
technique ZplotTec <
	string MMDPass = "zplot";
	string Script = 
		"RenderColorTarget0=;"
		"RenderDepthStencilTarget=;"
			"LoopByCount=RepeatCount;"
			"LoopGetIndex=RepeatIndex;"
				"Pass=ZValuePlot;"
			"LoopEnd=;";
>{
	pass ZValuePlot {
		AlphaBlendEnable = FALSE;
		VertexShader = compile vs_3_0 ZValuePlot_VS();
		PixelShader  = compile ps_3_0 ZValuePlot_PS();
	}
}


///////////////////////////////////////////////////////////////////////////////////////
// �e�N�j�b�N

technique MainTec1 < string MMDPass = "object";
	string Script = 
		"RenderColorTarget0=WindVelocityRT;"
		"RenderDepthStencilTarget=CoordDepthBuffer;"
		"Pass=UpdateWindVelocity;"

		"RenderColorTarget0=WindPositionRT;"
		"Pass=UpdateWindPosition;"

		"RenderColorTarget0=CoordWorkTex;"
		"RenderColorTarget1=VelocityTexCopy;"
		"Pass=CopyPos;"

		"RenderColorTarget0=" COORD_TEX_NAME_STRING ";"
		"RenderColorTarget1=VelocityTex;"
		"Pass=UpdatePos;"
		"RenderColorTarget1=;"

		"RenderColorTarget0=;"
		"RenderDepthStencilTarget=;"
			"LoopByCount=RepeatCount;"
			"LoopGetIndex=RepeatIndex;"
				"Pass=DrawObject;"
			"LoopEnd=;";
>{
	pass UpdateWindVelocity < string Script= "Draw=Buffer;"; > {
		ALPHABLENDENABLE = FALSE;
		ALPHATESTENABLE = FALSE;
		VertexShader = compile vs_3_0 CommonWind_VS();
		PixelShader  = compile ps_3_0 UpdateWindVelocity_PS();
	}

	pass UpdateWindPosition < string Script= "Draw=Buffer;"; > {
		ALPHABLENDENABLE = FALSE;
		ALPHATESTENABLE = FALSE;
		VertexShader = compile vs_3_0 CommonWind_VS();
		PixelShader  = compile ps_3_0 UpdateWindPosition_PS();
	}

	pass CopyPos < string Script= "Draw=Buffer;"; > {
		ALPHABLENDENABLE = FALSE;
		ALPHATESTENABLE = FALSE;
		VertexShader = compile vs_3_0 Common_VS();
		PixelShader  = compile ps_3_0 CopyPos_PS();
	}

	pass UpdatePos < string Script= "Draw=Buffer;"; > {
		ALPHABLENDENABLE = FALSE;
		ALPHATESTENABLE = FALSE;
		VertexShader = compile vs_3_0 Common_VS();
		PixelShader  = compile ps_3_0 UpdatePos_PS();
	}

	pass DrawObject {
		ZENABLE = TRUE;
		ZWRITEENABLE = FALSE;
		AlphaBlendEnable = TRUE;
		CullMode = NONE;
		VertexShader = compile vs_3_0 Particle_VS(false);
		PixelShader  = compile ps_3_0 Particle_PS(false);
	}
}

technique MainTec2 < string MMDPass = "object_ss";
	string Script = 
		"RenderColorTarget0=WindVelocityRT;"
		"RenderDepthStencilTarget=CoordDepthBuffer;"
		"Pass=UpdateWindVelocity;"

		"RenderColorTarget0=WindPositionRT;"
		"Pass=UpdateWindPosition;"

		"RenderColorTarget0=CoordWorkTex;"
		"RenderColorTarget1=VelocityTexCopy;"
		"Pass=CopyPos;"

		"RenderColorTarget0=" COORD_TEX_NAME_STRING ";"
		"RenderColorTarget1=VelocityTex;"
		"Pass=UpdatePos;"
		"RenderColorTarget1=;"

		"RenderColorTarget0=;"
		"RenderDepthStencilTarget=;"
			"LoopByCount=RepeatCount;"
			"LoopGetIndex=RepeatIndex;"
				"Pass=DrawObject;"
			"LoopEnd=;";
>{
	pass UpdateWindVelocity < string Script= "Draw=Buffer;"; > {
		ALPHABLENDENABLE = FALSE;
		ALPHATESTENABLE = FALSE;
		VertexShader = compile vs_3_0 CommonWind_VS();
		PixelShader  = compile ps_3_0 UpdateWindVelocity_PS();
	}

	pass UpdateWindPosition < string Script= "Draw=Buffer;"; > {
		ALPHABLENDENABLE = FALSE;
		ALPHATESTENABLE = FALSE;
		VertexShader = compile vs_3_0 CommonWind_VS();
		PixelShader  = compile ps_3_0 UpdateWindPosition_PS();
	}

	pass CopyPos < string Script= "Draw=Buffer;"; > {
		ALPHABLENDENABLE = FALSE;
		ALPHATESTENABLE = FALSE;
		VertexShader = compile vs_3_0 Common_VS();
		PixelShader  = compile ps_3_0 CopyPos_PS();
	}

	pass UpdatePos < string Script= "Draw=Buffer;"; > {
		ALPHABLENDENABLE = FALSE;
		ALPHATESTENABLE = FALSE;
		VertexShader = compile vs_3_0 Common_VS();
		PixelShader  = compile ps_3_0 UpdatePos_PS();
	}

	pass DrawObject {
		ZENABLE = TRUE;
		#if TEX_ZBuffWrite==0
		ZWRITEENABLE = FALSE;
		#endif
		AlphaBlendEnable = TRUE;
		CullMode = NONE;
		VertexShader = compile vs_3_0 Particle_VS(true);
		PixelShader  = compile ps_3_0 Particle_PS(true);
	}
}

