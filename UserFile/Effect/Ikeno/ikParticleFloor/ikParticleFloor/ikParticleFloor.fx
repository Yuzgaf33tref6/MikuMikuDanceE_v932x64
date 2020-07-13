////////////////////////////////////////////////////////////////////////////////////////////////
//
// ikFloorParticle.fx ���ɎU�����Ă���p�[�e�B�N��
//
////////////////////////////////////////////////////////////////////////////////////////////////

// �ݒ�t�@�C��
#include "ikParticleSettings.fxsub"

// 0:�~�`�ɕ��ׂ�A1:�ϓ��ɕ��ׂ�
#define ENABLE_FLAT_PATTERN		0

// �A�N�Z�̒��S����p�[�e�B�N����z�u���Ȃ����a
// �L����������̂ŁA���S���ɂ̓p�[�e�B�N���������ɂ����Ƃ����z��B
// �~�`�z�u���̂ݗL��
#define AvoidanceRadius		(5.0)

// �����I�Ƀp�[�e�B�N������ύX����B0�̏ꍇ�A���p�[�e�B�N���Ɠ�����
// �ő��x1024�̃p�[�e�B�N�����o��B
#define FORCE_UNIT_COUNT		2

// �s�����x�B0:�����`1:�s�����B
#define ParticleAlpha	(1.0)


////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////////
// �p�����[�^�錾
const float AlphaThroughThreshold = 0.5;

// �p�[�e�B�N�����𑝂₷�ꍇ�̐ݒ�
#if defined(FORCE_UNIT_COUNT) && FORCE_UNIT_COUNT > 0
#undef	UNIT_COUNT
#define	UNIT_COUNT	FORCE_UNIT_COUNT
#endif

#define PAI 3.14159265f	// ��

float AcsTr  : CONTROLOBJECT < string name = "(self)"; string item = "Tr"; >;
float AcsSi  : CONTROLOBJECT < string name = "(self)"; string item = "Si"; >;
float3 AcsPosition : CONTROLOBJECT < string name = "(self)"; >;

int RepeatCount = UNIT_COUNT;  // �V�F�[�_���`�攽����
int RepeatIndex;				// �������f���J�E���^

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

// ���W�ϊ��s��
float4x4 matW	: WORLD;
float4x4 matV	 : VIEW;
float4x4 matVP : VIEWPROJECTION;


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
// �z�u��������e�N�X�`������f�[�^�����o��
float3 GetRand(float index)
{
	float u = floor(index);
	float v = fmod(u, RND_TEX_SIZE);
	u = floor(u / RND_TEX_SIZE);
	float3 pos = tex2Dlod(RandomSmp, float4(float2(u,v) / RND_TEX_SIZE, 0,0)).xyz;

	float ang = (pos.y + index / 251.0) * 3.141592 * 2.0;

#if defined(ENABLE_FLAT_PATTERN) && ENABLE_FLAT_PATTERN > 0
	// �ϓ��ɔz�u
	pos.xz += float3(cos(ang), 0, sin(ang)) * (1.0 / 256.0);
	pos.y = 0;
	pos.xz = (pos.xz * 2.0 - 1.0) * ParticleInitPos * AcsSi * 0.1;

#else
	// �~�`�ɔz�u
	float l = pos.x * (ParticleInitPos + 0.5) * AcsSi * 0.1 + AvoidanceRadius;
	l -= pos.z * pos.z * AvoidanceRadius * 0.25; // ���������ɂ����荞��
	pos = float3(cos(ang), 0, sin(ang)) * l;

#endif
	return pos + AcsPosition + float3(0, 0.1, 0);
}


////////////////////////////////////////////////////////////////////////////////////////////////
// ���q�̉�]�s��
float3x3 RoundMatrix(int index, float etime)
{
//	float rotX = ParticleRotSpeed * (1.0f + 0.3f*sin(247*index)) * etime + (float)index * 147.0f;
	float rotY = ParticleRotSpeed * (1.0f + 0.3f*sin(368*index)) * etime + (float)index * 258.0f;
//	float rotZ = ParticleRotSpeed * (1.0f + 0.3f*sin(122*index)) * etime + (float)index * 369.0f;

	float sinx = 1, cosx = 0;
	float siny, cosy;
	float sinz = 0, cosz = 1;

	sincos(rotY, siny, cosy);

	float3x3 rMat = { cosz*cosy+sinx*siny*sinz, cosx*sinz, -siny*cosz+sinx*cosy*sinz,
					-cosy*sinz+sinx*siny*cosz, cosx*cosz,  siny*sinz+sinx*cosy*cosz,
					 cosx*siny,				-sinx,		cosx*cosy,				};
	return rMat;
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
	int Index0 = i * 1024 + j;
	Pos.z = 0.0f;
	Out.TexIndex = float(j);

	// ���q�̍��W
	// Index0�����ӂɌ��߂�
	float4 Pos0 = float4(GetRand(Index0), 1);

	#if( USE_SPHERE==1 )
	// ���q�̖@���x�N�g��(���_�P��)
	float3 Normal = normalize(float3(0.0f, 0.0f, -0.2f) - Pos.xyz);
	#endif

	// ���q�̑傫��
	Pos.xy *= ParticleSize * 10.0f;

	float3x3 matWTmp = RoundMatrix(Index0, 0);

	// ���q�̉�]
	Pos.xyz = mul( Pos.xyz, matWTmp );

	// ���q�̃��[���h���W
	Pos.xyz += Pos0.xyz;
	Pos.w = 1.0f;

	bool isVisible = (Index0 <= AcsTr * UNIT_COUNT * 1024);
	Pos.xyz *= isVisible;

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
	float alpha = isVisible * ParticleAlpha;
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
// �e�N�j�b�N

technique MainTec1 < string MMDPass = "object";
	string Script = 
			"LoopByCount=RepeatCount;"
			"LoopGetIndex=RepeatIndex;"
				"Pass=DrawObject;"
			"LoopEnd=;";
>{
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
			"LoopByCount=RepeatCount;"
			"LoopGetIndex=RepeatIndex;"
				"Pass=DrawObject;"
			"LoopEnd=;";
>{
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
