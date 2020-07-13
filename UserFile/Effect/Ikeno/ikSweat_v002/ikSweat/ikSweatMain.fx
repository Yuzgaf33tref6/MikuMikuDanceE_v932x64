////////////////////////////////////////////////////////////////////////////////////////////////
//
////////////////////////////////////////////////////////////////////////////////////////////////

//******************�ݒ�͂����܂�

const float MaxTrailRadius = 4.0; // (�e�N�X�`�����W�ł�)�O�Ղ̍ő唼�a

//�e�N�X�`���t�H�[�}�b�g
//#define TEXFORMAT "D3DFMT_A32B32G32R32F"
#define TEXFORMAT "D3DFMT_A16B16G16R16F"
#define COORD_TEXFORMAT "D3DFMT_A32B32G32R32F"

#define	PI	(3.14159265359)
#define	RAD2DEG(rad)		((rad) * 180.0 / PI)

float AcsX  : CONTROLOBJECT < string name = "(self)"; string item = "X"; >;
float AcsY  : CONTROLOBJECT < string name = "(self)"; string item = "Y"; >;
float AcsZ  : CONTROLOBJECT < string name = "(self)"; string item = "Z"; >;
float AcsRX  : CONTROLOBJECT < string name = "(self)"; string item = "Rx"; >;
float AcsRY  : CONTROLOBJECT < string name = "(self)"; string item = "Ry"; >;
float AcsRZ  : CONTROLOBJECT < string name = "(self)"; string item = "Rz"; >;
float AcsTr  : CONTROLOBJECT < string name = "(self)"; string item = "Tr"; >;
float AcsSi  : CONTROLOBJECT < string name = "(self)"; string item = "Si"; >;

#if !defined(USE_PRESET) || USE_PRESET == 0
static float FallSpeedRate = clamp(AcsX, 0.0, 4.0);			// �������x
static float Thickness = clamp(AcsY, 0.01, 8.0);			// ����
static float DryRate = clamp(AcsZ, 0.0, 1.0);				// �������x
static float LifetimeScale = clamp(RAD2DEG(AcsRX), 0.001, 10.0);	// �������Ԃ̃X�P�[��
static float ParticleSize = clamp(RAD2DEG(AcsRY), 0.1, 10.0);	// �p�[�e�B�N���T�C�Y
static float MaterialAlpha = saturate(AcsTr);				// ���q�̔������x
#endif
static float ActivityRatio = saturate(AcsSi / 10.0);		// ���q�g�p��

////////////////////////////////////////////////////////////////////////////////////////////////

// ���H�̍��W�Ǘ��p�e�N�X�`���T�C�Y�B�����ς���ɂ́A.x�t�@�C���̕ύX���K�v�B
#define UNIT_TEX_WIDTH		1024
#define UNIT_TEX_HEIGHT		1

const float epsilon = 1.0e-6;


// �X�N���[���T�C�Y
float2 ViewportSize : VIEWPORTPIXELSIZE;

static float2 ViewportOffset = (float2(0.5,0.5)/ViewportSize);

float3   CameraPosition	: POSITION  < string Object = "Camera"; >;
float3   CameraDirection	: DIRECTION < string Object = "Camera"; >;
float4x4 matP		: PROJECTION;
float4x4 matV		: VIEW;
float4x4 matVP		: VIEWPROJECTION;
float4x4 matWVP		: WORLDVIEWPROJECTION;
float4x4 matVInv	: VIEWINVERSE;

static float3x3 BillboardMatrix = {
	normalize(matVInv[0].xyz),
	normalize(matVInv[1].xyz),
	normalize(matVInv[2].xyz),
};

// ���@�ϊ��s��
float3   LightDirection	: DIRECTION < string Object = "Light"; >;
static float3 dirLightView = mul(LightDirection, matV);
float4 CalcDirProj(float3 v)
{
	// float4 tmp = mul(float4(v,0), matVP);
	float4 tmp = mul(float4(v,0), matVP);
	tmp.y = -tmp.y;
	tmp.xy = tmp.xy * (5.0 / 100.0 * 0.5);
	return tmp;
}
static float4 dirLightProj = CalcDirProj(LightDirection);

#if defined(STOP_IN_EDITMODE) && STOP_IN_EDITMODE > 0
#define TIME_FLAG		< bool SyncInEditMode = true; >
#else
#define TIME_FLAG
#endif
float time : TIME TIME_FLAG;
float elapseTime : ELAPSEDTIME TIME_FLAG;
float systemTime : TIME < bool SyncInEditMode = true; >;


// ���H�̈ʒu(�e�N�X�`�����W)
texture CoordTex : RENDERCOLORTARGET
<
	int Width=UNIT_TEX_WIDTH;
	int Height=UNIT_TEX_HEIGHT;
	string Format=COORD_TEXFORMAT;
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

texture CoordTexCopy : RENDERCOLORTARGET
<
	int Width=UNIT_TEX_WIDTH;
	int Height=UNIT_TEX_HEIGHT;
	string Format=COORD_TEXFORMAT;
>;

sampler CoordSmpCopy
{
	Texture = <CoordTexCopy>;
	AddressU  = CLAMP;
	AddressV = CLAMP;
	MinFilter = NONE;
	MagFilter = NONE;
	MipFilter = NONE;
};

// ���H�̈ʒu(���[���h���W)
texture WorldPosTex : RENDERCOLORTARGET
<
	int Width=UNIT_TEX_WIDTH;
	int Height=UNIT_TEX_HEIGHT;
	string Format=COORD_TEXFORMAT;
>;

sampler WorldPosSmp
{
	Texture = <WorldPosTex>;
	AddressU  = CLAMP;
	AddressV = CLAMP;
	MinFilter = NONE;
	MagFilter = NONE;
	MipFilter = NONE;
};

#if defined(USE_MOTION) && USE_MOTION > 0
// ���H�̈ړ���
texture VelocityTex : RENDERCOLORTARGET
<
	int Width=UNIT_TEX_WIDTH;
	int Height=UNIT_TEX_HEIGHT;
	string Format=COORD_TEXFORMAT;
>;

sampler VelocitySmp
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
	int Width=UNIT_TEX_WIDTH;
	int Height=UNIT_TEX_HEIGHT;
	string Format=COORD_TEXFORMAT;
>;

sampler VelocitySmpCopy
{
	Texture = <VelocityTexCopy>;
	AddressU  = CLAMP;
	AddressV = CLAMP;
	MinFilter = NONE;
	MagFilter = NONE;
	MipFilter = NONE;
};
#endif

texture CoordDepthBuffer : RenderDepthStencilTarget <
	int Width=UNIT_TEX_WIDTH;
	int Height=UNIT_TEX_HEIGHT;
	string Format = "D24S8";
>;

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

// UV���W��ł̃��[���h���W
texture WorldPosOnUV_RT_ : OFFSCREENRENDERTARGET <
	string Description = "OffScreen RenderTarget for ikSweat.fx";
	int Width=TEX_SIZE;
	int Height=TEX_SIZE;
	float4 ClearColor = { 0, 0, 0, 0 };
	float ClearDepth = 1.0;
	int MipLevels = 1;
	string Format=TEXFORMAT;
	string DefaultEffect = 
		"self = hide;"
//		"*.pmd =ikWorldPos.fx;"
//		"*.pmx =ikWorldPos.fx;"
		"* = hide;" ;
>;
sampler WorldPosOnUV_Samp = sampler_state {
	texture = <WorldPosOnUV_RT_>;
	MinFilter = LINEAR;
	MagFilter = LINEAR;
	MipFilter = NONE;
	AddressU  = CLAMP;
	AddressV = CLAMP;
};

// �O�Ճ}�b�v
texture TrailMap_RT : RENDERCOLORTARGET <
	int Width=TRAIL_TEX_SIZE;
	int Height=TRAIL_TEX_SIZE;
	float4 ClearColor = { 0, 0, 0, 0 };
	float ClearDepth = 1.0;
	int MipLevels = 1;
	string Format="R16F";
>;
sampler TrailMap_Samp = sampler_state {
	texture = <TrailMap_RT>;
	MinFilter = LINEAR;
	MagFilter = LINEAR;
	MipFilter = NONE;
	AddressU  = CLAMP;
	AddressV = CLAMP;
};

texture TrailMap_RTCopy : RENDERCOLORTARGET <
	int Width=TRAIL_TEX_SIZE;
	int Height=TRAIL_TEX_SIZE;
	float4 ClearColor = { 0, 0, 0, 0 };
	float ClearDepth = 1.0;
	int MipLevels = 1;
	string Format="R16F";
>;
sampler TrailMap_SampCopy = sampler_state {
	texture = <TrailMap_RTCopy>;
	MinFilter = LINEAR;
	MagFilter = LINEAR;
	MipFilter = NONE;
	AddressU  = CLAMP;
	AddressV = CLAMP;
};


texture TrailDepthBuffer : RenderDepthStencilTarget <
	int Width=TRAIL_TEX_SIZE;
	int Height=TRAIL_TEX_SIZE;
	string Format = "D24S8";
>;

// �����}�b�v
texture WetHightMap_RT : RENDERCOLORTARGET <
	float2 ViewPortRatio = {1.0,1.0};
	float4 ClearColor = { 0, 0, 0, 0 };
	float ClearDepth = 1.0;
	int MipLevels = 1;
	string Format="R16F";
>;
sampler WetHightMap_Samp = sampler_state {
	texture = <WetHightMap_RT>;
	MinFilter = LINEAR;
	MagFilter = LINEAR;
	MipFilter = NONE;
	AddressU  = CLAMP;
	AddressV = CLAMP;
};

texture WetHightDepthBuffer : RenderDepthStencilTarget <
	float2 ViewPortRatio = {1.0,1.0};
	string Format = "D24S8";
>;

// �X�N���[����ł�UV���W
texture UVPosOnScreen_RT_ : OFFSCREENRENDERTARGET <
	string Description = "OffScreen RenderTarget for ikSweat.fx";
	float2 ViewPortRatio = {1.0,1.0};
	float4 ClearColor = { 0, 0, 0, 0 };
	float ClearDepth = 1.0;
	int MipLevels = 1;
	bool AntiAlias = false;
	string Format=TEXFORMAT;	// float4(u,v, lighting, depth) ���i�[�����B
	string DefaultEffect = 
		"self = hide;"
		"* = ikUVMapMask.fx;" ;
>;

sampler UVPosOnScreen_Samp = sampler_state {
	texture = <UVPosOnScreen_RT_>;
	MinFilter = LINEAR;
	MagFilter = LINEAR;
	MipFilter = NONE;
	AddressU  = CLAMP;
	AddressV = CLAMP;
};

sampler UVPosOnScreen_SampPoint = sampler_state {
	texture = <UVPosOnScreen_RT_>;
	MinFilter = POINT;
	MagFilter = POINT;
	MipFilter = NONE;
	AddressU  = CLAMP;
	AddressV = CLAMP;
};

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

sampler DefSampler : register(s0);
sampler MMDSamp0 : register(s0);
sampler MMDSamp1 : register(s1);
sampler MMDSamp2 : register(s2);


//-----------------------------------------------------------------------------
// �K���ȗ���
#define RAND(index, minVal, maxVal)		random(index, __LINE__, minVal, maxVal)
float4 random(float index, int index2, float minVal, float maxVal)
{
	float f = (index * 5531 + index2 + time * 61.0 + systemTime * 1031.0) / 256.0;
	float2 uv = float2(f, f / 256.0);
	float4 tex1 = tex2D(RandomSmp, uv);
	float4 tex2 = tex2D(RandomSmp, uv.yx * 7.1);
	return frac(tex1 + tex2 / 256.0) * (maxVal - minVal) + minVal;
}


//-----------------------------------------------------------------------------

inline float CalcFresnel(float NV, float F0)
{
	return F0 + (1.0 - F0) * exp(-6.0 * NV);
}

//�X�y�L�����̌v�Z
float CalcSpecular(float3 L, float3 N, float3 V, float smoothness)
{
	float3 H = normalize(L + V);
	// return pow( max(0,dot( H, N )), SpecularPower );

	float a = pow(1 - smoothness * 0.7, 6);
	float a2 = a * a;
	float NV = dot(N, V);
	float NH = dot(N, H);
	float VH = dot(V, H);
	float NL = dot(N, L);

	// �t���l����
	float F = CalcFresnel(NV, smoothness * smoothness);

	// Trowbridge-Reitz(GGX) NDF
	float CosSq = (NH * NH) * (a2 - 1) + 1;
	float D = a2 / (PI * CosSq * CosSq);

	// �􉽊w�I�����W��
	float G = min(1, min( (2*NH/VH) * NV, (2*NH/VH) * NL));

	return saturate(F * D * G / (4.0 * NL * NV));
}

// �f�t���[�Y�̌v�Z
float CalcDiffuse(float3 L, float3 N, float3 V, float smoothness)
{
	return saturate(dot( N, L ) * (1.0 - AmbientPower) + AmbientPower);
}

// ���Z�b�g����?
inline bool IsTimeToReset()
{
#if defined(RESET_AT_START) && RESET_AT_START != 0
	return (time < 1.0 / 120.0);
#else
	return false;
#endif
}

//-----------------------------------------------------------------------------
//
struct VS_OUTPUT
{
	float4 Pos			: POSITION;
	float2 Tex			: TEXCOORD0;
};

struct VS_OUTPUT2
{
	float4 Pos			: POSITION;
	float4 Tex			: TEXCOORD0;
	float4 Tex2			: TEXCOORD1;
};

//-----------------------------------------------------------------------------
// �e�N�X�`���𗱎q���̓������z��Ƃ��Ĉ���
VS_OUTPUT UnitArray_VS(float4 Pos: POSITION, float2 Tex: TEXCOORD)
{
	VS_OUTPUT Out = (VS_OUTPUT)0;
	Out.Pos = Pos;
	Out.Tex.xy = Tex + float2(0.5f/UNIT_TEX_WIDTH, 0.5f/UNIT_TEX_HEIGHT);
	return Out;
}

#if defined(USE_MOTION) && USE_MOTION > 0
// ���x�̑ޔ�
float4 CopyVelocity_PS(float2 Tex: TEXCOORD0) : COLOR
{
	return tex2D(VelocitySmp, Tex);
}

// ���x�̍X�V
float4 UpdateVelocity_PS(float2 Tex: TEXCOORD0) : COLOR
{
	float4 Pos = tex2D(CoordSmp, Tex);
	float4 Vel = tex2D(VelocitySmpCopy, Tex);

	if (IsTimeToReset() || Pos.w <= 0.0)
	{
		Vel = 0;
	}
	else
	{
		float2 TexCoord = Pos.xy + 0.5 / TEX_SIZE;
		float4 center = tex2D(WorldPosOnUV_Samp, TexCoord);
		float4 oldCenter = tex2D(WorldPosSmp, Tex);
		center.xyz = center.xyz/center.w;
		oldCenter.xyz = (oldCenter.w > 0.95) ? oldCenter.xyz : center.xyz;
		float3 movement = (center.xyz - oldCenter.xyz);
		Vel.xyz = (Vel.xyz * Friction + movement);
		float len = length(Vel.xyz);
		Vel.xyz *= ((len > MaxMovement) ? MaxMovement/len : 1.0);
	}

	return Vel;
}
#endif

// �ʒu�̑ޔ�
float4 CopyPos_PS(float2 Tex: TEXCOORD0) : COLOR
{
	return tex2D(CoordSmp, Tex);
}

// �ʒu�̍X�V�Ɣ���
float4 UpdatePos_PS(float2 Tex: TEXCOORD0) : COLOR
{
	// �e�N�X�`���̃�������1�����Ȃ�A�͈͊O�̃e�N�X�`�����Q�Ƃ��Ă���B
	// ���邢�͕�Ԃɂ���Ĕ͈͊O�̃f�[�^���������Ă���B
	const float InRangeThreshold = 250.0/256.0;

	int index = floor(Tex.x * UNIT_TEX_WIDTH);
	float4 Pos = tex2D(CoordSmpCopy, Tex);
	Pos.z -= elapseTime * LifetimeScale;

	if (IsTimeToReset() || Pos.w <= 0.0)
	{
		// ���S��
		if (index < ActivityRatio * UNIT_TEX_WIDTH && Pos.z < 0.5)
		{
			// �V���ɔ�������
			Pos = RAND(index, 0.0, 1.0);
			Pos.z = LifetimeMin + Pos.z * LifetimeFluctuation;	// �����܂ł̎���
			Pos.w = DurationMin + Pos.w * DurationFluctuation;	// �������t���O���A���S�������܂ł̎���
			// �������Ă͂����Ȃ��ꏊ?
			float4 center = tex2D(WorldPosOnUV_Samp, Pos.xy + 0.5/TEX_SIZE);
			if (center.a < 1.0) Pos.zw = float2(0, -1);

		} else {
			// �ҋ@���
			// ActivityRatio���㏸�����Ƃ���A�}���ɐ��H�������Ȃ��悤��z�ŃE�F�C�g���|����
			if (Pos.z < 0.0 || Pos.z > 10.0) Pos.xyz = RAND(index, 1.0, 10.0).xyz;
			Pos.w = 0;
		}
	}
	else if (Pos.w > 0.0)
	{
		float2 TexCoord = Pos.xy + 0.5/ TEX_SIZE;
		float r = 1.0 / TEX_SIZE;

		float4 center = tex2D(WorldPosOnUV_Samp, TexCoord);
		center.xyz = center.xyz/center.w;

#if defined(USE_MOTION) && USE_MOTION > 0
		// �����̌v�Z
		float3 movement = tex2D(VelocitySmp, TexCoord).xyz;
		float4 oldCenter = tex2D(WorldPosSmp, Tex);
		oldCenter.xyz = (oldCenter.w > 0.9) ? oldCenter.xyz : center.xyz;
		movement -= (center.xyz - oldCenter.xyz);
		movement *= MovemenScale;

		float potential = length(movement);
		if (potential < (Pos.z > 0.0 ? StaticFriction : 0.0)) return Pos;

		Pos.z = min(Pos.z, 0); // �������Ă��Ȃ��Ȃ�A�����J�n
#else
		if (Pos.z > 0.0) return Pos;
		float3 movement = 0;
#endif
		// �������x�̌v�Z
		float speedRate = 1.1 - ((index % 4) / 4.0 * 0.2); // �ړ����x�ɍ�������
		movement.y -= (Pos.z > 0.0) ? 0 : (FallSpeedRate * elapseTime * speedRate);

		// ���ł܂ł̃J�E���g�_�E���B
		Pos.w -= elapseTime;

		// �e�N�X�`����Ԃł̈ړ����������߂�
		float4 x0 = tex2D(WorldPosOnUV_Samp, TexCoord + float2(-r*0.5,0));
		float4 x1 = tex2D(WorldPosOnUV_Samp, TexCoord + float2( r*0.5,0));
		float4 y0 = tex2D(WorldPosOnUV_Samp, TexCoord + float2(0,-r));
		float4 y1 = tex2D(WorldPosOnUV_Samp, TexCoord + float2(0, r));
		x0.xyz /= x0.w;
		x1.xyz /= x1.w;
		y0.xyz /= y0.w;
		y1.xyz /= y1.w;
		float3 vx = x1.xyz - x0.xyz;
		float3 vy = y1.xyz - y0.xyz;
		// �e�N�X�`�����x���ꏊ�ɂ���ĈႤ�̂Ő��K������
		float2 v = float2(dot(vx/dot(vx,vx), movement), dot(vy/dot(vy,vy), movement)) / TEX_SIZE;
		v.x *= 0.5;

		// ���ʂɈړ��ł���?
		float isValid = tex2D(WorldPosOnUV_Samp, Pos.xy + v + 0.5 / TEX_SIZE).a;
		if (isValid > InRangeThreshold) return float4(Pos.xy + v, Pos.zw);

		// �������ł̍��E�ւ̈ڍs�𖳂����̂Ƃ݂Ȃ��΁A�ǂ���ɑ������͂��炩���ߐ����\�B
		bool isRight = (Pos.x >= 0.5);

		// UV�̒[�ɂ���̂ňړ��ł��Ȃ��B
		Pos.w -= 1; // �������k��

		// �X�N���[�����W�Ń��[�v�\���`�F�b�N����
		float4 targetPos = float4(center.xyz + movement, 1);
		float4 ppos = mul(targetPos, matVP);
		ppos.xy = (ppos.xy / ppos.w) * 0.5 + 0.5;
		ppos.y = 1 - ppos.y;
		// ��ʊO�Ȃ瑦����
		if( any( saturate(ppos.xy) != ppos.xy ) ) return float4(Pos.xyz, -1);

		const int iteration = 4;
		const float ToleranceRange = 0.5;
		float len = 1.0 + 0.5 / length(movement);
		float4 newPpos = mul(float4(center.xyz + movement * len, 1), matVP);
		newPpos.xy = (newPpos.xy / newPpos.w) * 0.5 + 0.5;
		newPpos.y = 1 - newPpos.y;
		float2 vppos = (newPpos.xy - ppos.xy) / iteration;

		for(int i = 0; i < iteration; i++)
		{
			float2 uv = tex2D( UVPosOnScreen_SampPoint, ppos.xy).xy;
			uv.x = uv.x * 0.5 + 0.5;
			float2 uv0 = ((isRight) ? uv : float2(1.0 - uv.x, uv.y)) + 0.5 / TEX_SIZE;
			if (distance(uv0, Pos.xy + v) > 4.0 / TEX_SIZE)
			{
				float4 warpPos0 = tex2D(WorldPosOnUV_Samp, uv0);
				if (warpPos0.w >= InRangeThreshold)
				{
					// ���[�v���e�͈͓���?
					float d0 = distance(warpPos0.xyz / warpPos0.w, targetPos.xyz);
					return (d0 < ToleranceRange)
						? float4(uv0, Pos.zw)
						: float4(Pos.xyz, Pos.w - Pos.w * 0.5 + 1);
				}
			}

			ppos.xy += vppos.xy;
		}

		Pos.w -= (Pos.w * 0.5 + 1); // �ړ��ł��Ȃ��̂ŁA����ɏ��ł𑣂��B
	}

	return Pos;
}


// �p�[�e�B�N���̍��W��uv���W���烏�[���h���W�ɕϊ�����
float4 ConvertUVToWPos_PS(float2 Tex: TEXCOORD0) : COLOR
{
	float4 Pos = tex2D(CoordSmp, Tex);
	float2 TexCoord = Pos.xy + 0.5 / TEX_SIZE;
	float4 center = tex2D(WorldPosOnUV_Samp, TexCoord);
	center.xyz /= center.w;

	float alpha = (center.w > 0.9 && Pos.w > 0.5) ? 1 : 0;
	return float4(center.xyz, alpha);
}


//-----------------------------------------------------------------------------
// �O�Ճ}�b�v��`��
// �p�[�e�B�N�����O�Ճ}�b�v�ɒǉ�
VS_OUTPUT2 AddTrailMap_VS(float4 Pos : POSITION, float2 Tex : TEXCOORD0)
{
	VS_OUTPUT2 Out = (VS_OUTPUT2)0;

	int index = round( Pos.z * 100.0f );
	float2 texCoord = float2((index+0.5f)/UNIT_TEX_WIDTH, (0.5f)/UNIT_TEX_HEIGHT);

	float2 uv = Pos.xy * (MaxTrailRadius * 10.0);
	Out.Tex.xy = uv;
	uv.x *= 0.5;

	// ���q�̍��W
	float4 tpos = tex2Dlod(CoordSmp, float4(texCoord,0,0));
	tpos.xy += uv / TRAIL_TEX_SIZE;
	float2 ppos = tpos.xy * 2.0 - 1;
	Out.Pos = (tpos.w > 0.0) ? float4(ppos.x, -ppos.y, 0,1) : float4(0,0,0,0);

	Out.Tex2 = float4(tpos.xy,0,0);

	return Out;
}

float4 AddTrailMap_PS( VS_OUTPUT2 IN ) : COLOR0
{
	// �p�[�e�B�N���̔��a(���[���h���W�BMMD�P��)
	float particleRadius = 0.1 * ParticleSize / 2.0;

	// 1�e�N�Z���̑傫��(MMD�P��))
	float r = 1.0 / TEX_SIZE;
	float2 uv2 = IN.Tex2.xy;
	float4 c = tex2D(WorldPosOnUV_Samp, uv2);
	float4 x0 = tex2D(WorldPosOnUV_Samp, uv2 + float2(-r,0));
	float4 x1 = tex2D(WorldPosOnUV_Samp, uv2 + float2( r,0));
	float4 y0 = tex2D(WorldPosOnUV_Samp, uv2 + float2(0,-r));
	float4 y1 = tex2D(WorldPosOnUV_Samp, uv2 + float2(0, r));
	float2 density = float2(distance(x0.xyz/x0.w, x1.xyz/x1.w), distance(y0.xyz/y0.w, y1.xyz/y1.w)) / 2.0;
		// NOTE: �G�b�W�t�߂ł͖��x�v�Z�������B

	// �p�[�e�B�N���̔��a(�e�N�Z���P��)
	float2 texelRadius = particleRadius / density;
	texelRadius = clamp(texelRadius.xy, 1.0, MaxTrailRadius);

	float a = saturate(texelRadius + 0.5 - length(IN.Tex.xy));
	return float4(1.0,0,0, a);
}


//-----------------------------------------------------------------------------
// �O�Ճ}�b�v��������
VS_OUTPUT DryTrailMap_VS( float4 Pos : POSITION, float4 Tex : TEXCOORD0 )
{
	VS_OUTPUT Out = (VS_OUTPUT)0; 
	Out.Pos = Pos;
	Out.Tex.xy = Tex.xy + 0.5 / TRAIL_TEX_SIZE;
	return Out;
}

float4 DryTrailMap_PS( VS_OUTPUT IN ) : COLOR0
{
	float a = IsTimeToReset() ? 0 : tex2D(TrailMap_SampCopy, IN.Tex.xy).r;
	return float4(a * DryRate,0,0, 1);
}

float4 CopyTrailMap_PS( VS_OUTPUT IN ) : COLOR0
{
	return float4(tex2D(TrailMap_Samp, IN.Tex.xy).r, 0,0, 1);
}

//-----------------------------------------------------------------------------
// �O�Ճ}�b�v��`��
VS_OUTPUT2 DrawTrailMap_VS( float4 Pos : POSITION, float4 Tex : TEXCOORD0 )
{
	VS_OUTPUT2 Out = (VS_OUTPUT2)0; 
	Out.Pos = Pos;
	Out.Tex.xy = Tex.xy + 0.5 / TRAIL_TEX_SIZE;

	// �X�N���[�����W
	Out.Tex2.xy = Pos.xy * 0.5 + 0.5;
	Out.Tex2.y = 1.0 - Out.Tex2.y;
	Out.Tex2.xy += ViewportOffset.xy;
	return Out;
}


#define STRICT_CHECK

// �O�Ճ}�b�v����ʃT�C�Y�̃��[�N�ɃR�s�[
float4 DrawTrailMap_PS( VS_OUTPUT2 IN ) : COLOR0
{
	// �ǂ����UV�ɑ����Ă��邩?
	float2 uv = tex2D( UVPosOnScreen_SampPoint, IN.Tex2.xy ).xy;
#ifdef STRICT_CHECK
	// ���f���̍ۂ�uv�����Ȃ����Ƃ�����B�A���`�G�C���A�X�ŕ����Ă���?
	float2 offset = 1.0 / ViewportSize;
	float2 uv00 = tex2D( UVPosOnScreen_SampPoint, IN.Tex2.xy + float2( offset.x, offset.y) ).xy;
	float2 uv01 = tex2D( UVPosOnScreen_SampPoint, IN.Tex2.xy + float2(-offset.x, offset.y) ).xy;
	float2 uv02 = tex2D( UVPosOnScreen_SampPoint, IN.Tex2.xy + float2( offset.x,-offset.y) ).xy;
	float2 uv03 = tex2D( UVPosOnScreen_SampPoint, IN.Tex2.xy + float2(-offset.x,-offset.y) ).xy;
	float w = (uv.x + uv.y != 0.0) +
				(uv00.x + uv00.y != 0.0) + (uv01.x + uv01.y != 0.0) + 
				(uv02.x + uv02.y != 0.0) + (uv03.x + uv03.y != 0.0);
	clip(w - 1.0/65536.0);
	if (uv.x + uv.y == 0.0)
	{
		uv = (uv00 + uv01 + uv02 + uv03) / w;
	}
#else
	clip(uv.x+uv.y - 1.0/65536.0);
#endif

	float2 screenPos = IN.Tex2.xy;
	screenPos.y = 1 - screenPos.y;
	screenPos = screenPos * 2.0 - 1.0;

	float offset2 = 1.0/TEX_SIZE;
	uv.x = uv.x * 0.5 + 0.5;
	float2 uv0 = uv + 0.5/TEX_SIZE;
	float4 wpos = tex2D(WorldPosOnUV_Samp, uv0);
#ifdef STRICT_CHECK
	if (wpos.w < 0.9)
	{
		// ��x�AWorldPosOnUV�e�N�X�`���S�̂Ƀt�B���^���|���ĕ␳�����ق�������?
		float4 wpos00 = tex2D(WorldPosOnUV_Samp, float2(uv0.x + offset2, uv0.y));
		float4 wpos01 = tex2D(WorldPosOnUV_Samp, float2(uv0.x - offset2, uv0.y));
		wpos = (wpos.w > wpos00.w) ? wpos : wpos00;
		wpos = (wpos.w > wpos01.w) ? wpos : wpos01;
	}
#endif
	float4 ppos0 = mul(float4(wpos.xyz / wpos.w, 1), matVP);

	float2 uv1 = float2(1.0 - uv.x, uv.y) + 0.5/TEX_SIZE;
	wpos = tex2D(WorldPosOnUV_Samp, uv1);
#ifdef STRICT_CHECK
	if (wpos.w < 0.9)
	{
		float4 wpos00 = tex2D(WorldPosOnUV_Samp, float2(uv1.x + offset2, uv1.y));
		float4 wpos01 = tex2D(WorldPosOnUV_Samp, float2(uv1.x - offset2, uv1.y));
		wpos = (wpos.w > wpos00.w) ? wpos : wpos00;
		wpos = (wpos.w > wpos01.w) ? wpos : wpos01;
	}
#endif
	float4 ppos1 = mul(float4(wpos.xyz / wpos.w, 1), matVP);

	// �X�N���[�����W�ŋ߂��ق����̗p
	float d0 = distance(ppos0.xy / ppos0.w, screenPos);
	float d1 = distance(ppos1.xy / ppos1.w, screenPos);
	uv = (d0 < d1) ? uv0 : uv1;
	float r = 1.0/TRAIL_TEX_SIZE;
	float wet = tex2D(TrailMap_Samp, uv).r * 4 +
				tex2D(TrailMap_Samp, uv + float2(-r*0.5, 0)).r +
				tex2D(TrailMap_Samp, uv + float2( r*0.5, 0)).r +
				tex2D(TrailMap_Samp, uv + float2(0, -r)).r +
				tex2D(TrailMap_Samp, uv + float2(0,  r)).r;
	wet = wet / 8.0;

	// ���E�Ώ̂ȃp�[�c?
	const float ShortDistance = 16.0 / ViewportSize.x;
	if (max(d0,d1) < ShortDistance)
	{
		uv = (d0 < d1) ? uv1 : uv0;
		float wet2 = tex2D(TrailMap_Samp, uv).r * (1.0 - max(d0,d1) / ShortDistance);
		wet = max(wet, wet2);
	}

	return float4(1, 0,0, wet);
}


//-----------------------------------------------------------------------------
// ���q�̕`��
VS_OUTPUT2 DrawDroplets_VS(float4 Pos : POSITION, float2 Tex : TEXCOORD0)
{
	VS_OUTPUT2 Out = (VS_OUTPUT2)0;

	int index = round( Pos.z * 100.0f );
	float2 texCoord = float2((index+0.5f)/UNIT_TEX_WIDTH, (0.5f)/UNIT_TEX_HEIGHT);

	// �e�N�X�`��
	int raindropPattern = index % (NumRaindropInTextureW * NumRaindropInTextureH);
	int raindropPatternW = raindropPattern % NumRaindropInTextureW;
	int raindropPatternH = floor(raindropPattern / NumRaindropInTextureW);
	Out.Tex.xy = Pos.xy * (10 * 0.5) + 0.5;
	Out.Tex.x = (Out.Tex.x + raindropPatternW) / NumRaindropInTextureW;
	Out.Tex.y = (Out.Tex.y + raindropPatternH) / NumRaindropInTextureH;
	Out.Tex.y = 1.0 - Out.Tex.y;

	// ���q�̍��W
	float4 wpos = tex2Dlod(WorldPosSmp, float4(texCoord,0,0));
	bool bLiving = (wpos.w > 0.0);
	float zOffset = (1.0 - sqrt(dot(Pos.xy,Pos.xy)) * 10.0 + 1.0) / 1000.0;

	Pos.zw = 0;
	Pos.x *= 0.5; // TODO: ���������ǂ����Ō`���ό`������?
	wpos.xyz += mul(Pos.xyz * (ParticleSize / 2.0), BillboardMatrix);
	wpos.w = 1.0f;
	float4 ppos = mul(wpos, matVP);
	ppos.z -= zOffset;

	Out.Pos = bLiving ? ppos : float4(0,0,0,0);

	// �X�N���[�����W
	Out.Tex2.xy = (Out.Pos.xy / Out.Pos.w) * 0.5 + 0.5;
	Out.Tex2.y = 1.0 - Out.Tex2.y;
	Out.Tex2.xy += ViewportOffset.xy;
	Out.Tex2.z = ppos.z;

	return Out;
}


float4 DrawDroplets_PS( VS_OUTPUT2 IN ) : COLOR0
{
	// �\�t�g�p�[�e�B�N������
	const float SoftParticleThreshold = 0.04;

	float depth = tex2D( UVPosOnScreen_Samp, IN.Tex2.xy ).w;
	float depthDiff = depth - IN.Tex2.z;
	float a = tex2D(ParticleSamp, IN.Tex.xy).r;
	a = a * (1.0 - saturate(-depthDiff / SoftParticleThreshold));

	return float4(1,0,0, a);
}


//-----------------------------------------------------------------------------
// �ŏI����
VS_OUTPUT2 DrawSynth_VS( float4 Pos : POSITION, float4 Tex : TEXCOORD0 )
{
	VS_OUTPUT2 Out = (VS_OUTPUT2)0; 
	Out.Pos = Pos;
	Out.Tex.xy = Tex.xy + ViewportOffset.xy;

	// �K���Ȏ����x�N�g���F�X�y�L�����v�Z�p
	Out.Tex2.xy = -Pos.xy;
	Out.Tex2.y *= ViewportSize.y / ViewportSize.x;
	Out.Tex2.z = -matP._11 * 0.5;

	return Out;
}

float4 DrawSynth_PS(VS_OUTPUT2 IN) : COLOR0
{
	float4 uvlz = tex2D( UVPosOnScreen_Samp, IN.Tex.xy );
	float depth = uvlz.w;
	float thick = tex2D(WetHightMap_Samp, IN.Tex.xy).r;

	// �X�N���[�����W�ł̋[���I�ȃZ���t�V���h�E
	float shadow = tex2D(WetHightMap_Samp, IN.Tex.xy - dirLightProj.xy / (depth + dirLightProj.w)).r;
	// ���݈ʒu���Ώۃ��f���O�Ȃ�e�͂��Ȃ�
	shadow *= (length(tex2D( UVPosOnScreen_Samp, IN.Tex.xy).xy) != 0);

	// �e�����H���Ȃ��Ȃ�`��ΏۊO
	clip(shadow + thick - 1.0/(256.0*256.0));

	// �K���Ȗ@���x�N�g��
	float2 uv = 1.5 / ViewportSize.xy;
	float x0 = tex2D(WetHightMap_Samp, IN.Tex.xy + float2(-uv.x , 0)).r;
	float x1 = tex2D(WetHightMap_Samp, IN.Tex.xy + float2( uv.x , 0)).r;
	float y0 = tex2D(WetHightMap_Samp, IN.Tex.xy + float2( 0, -uv.y)).r;
	float y1 = tex2D(WetHightMap_Samp, IN.Tex.xy + float2( 0,  uv.y)).r;
	thick = saturate((thick * 4.0 + x0 + x1 + y0 + y1) / 8.0);
	thick = saturate(thick * Thickness);
	float nx = (x0 - x1);
	float ny = -(y0 - y1);
	float nz = -saturate(1.0 - sqrt(nx * nx + ny * ny)) * (0.5 + Thickness * 0.5);
	float3 N = normalize(float3(nx,ny,nz));

	float3 V = normalize(float3(IN.Tex2.xyz));

	float light = uvlz.z;	// ���f���̌����v�Z�̌���
		// TODO: light�̈����𓝈ꂷ��?

	float specular = CalcSpecular(-dirLightView, N, V, Smoothness) * SpecularScale;
	float diffuse = CalcDiffuse(-dirLightView, N, V, Smoothness) * saturate(light + 0.75);
	float alpha = thick * thick * MaterialAlpha;
	shadow *= saturate((1-light)*0.5+0.5);	// ���f�����e�̒��Ȃ���A�e�����Z������B
	shadow = saturate(shadow - thick * 0.7) * ShadowPower;
	specular = saturate((specular + saturate(diffuse - 0.8)) * thick);

	float3 Color = MaterialColor.rgb * saturate(1.0 - alpha + diffuse * alpha);
		// TODO: �g�[���J�[�u���ɏ�������?

	// �e�F�Ɩ{�̐F�̍���
	float alpha2 = 1 - (1.0-shadow) * (1.0-alpha);
	Color = MaterialShadowColor * ((shadow - shadow * alpha) / alpha2)
			 + Color * (alpha / alpha2);
	// �X�y�L�����̒ǉ�
	float alpha3 = 1 - (1.0-alpha2) * (1.0-specular);
	Color = Color * ((alpha2 - alpha2 * specular) / alpha3) + 1.0 * (specular / alpha3);

	return float4(Color, alpha3);
}


//-----------------------------------------------------------------------------
// �Ώۗ̈����h��B
VS_OUTPUT DrawArea_VS( float4 Pos : POSITION, float4 Tex : TEXCOORD0 )
{
	VS_OUTPUT Out = (VS_OUTPUT)0; 
	Out.Pos = Pos;
	Out.Tex.xy = Tex.xy + ViewportOffset.xy;

	return Out;
}

float4 DrawArea_PS(VS_OUTPUT IN) : COLOR0
{
	float4 uvlz = tex2D( UVPosOnScreen_Samp, IN.Tex.xy );
	clip(length(uvlz.xy) - 1.0/65536.0);
	return float4(0,0,1,0.5);
}


////////////////////////////////////////////////////////////////////////////////////////////////
float4 ClearColor = {0,0,0,1};

technique Droplet <
	string MMDPass = "object";
	string Script = 
		// ���x�̍X�V
		"RenderDepthStencilTarget=CoordDepthBuffer;"
#if defined(USE_MOTION) && USE_MOTION > 0
		"RenderColorTarget0=VelocityTexCopy;"
		"Pass=CopyVelocity;"
		"RenderColorTarget0=VelocityTex;"
		"Pass=UpdateVelocity;"
#endif
		// �ʒu�̍X�V
		"RenderColorTarget0=CoordTexCopy;"
		"Pass=CopyPos;"
		"RenderColorTarget0=CoordTex;"
		"Pass=UpdatePos;"
		// ���[���h���W�ւ̕ϊ�
		"RenderColorTarget0=WorldPosTex;"
		"Pass=ConvertUVToWPos;"

		// �O�Ճ}�b�v�̍X�V
		"RenderColorTarget0=TrailMap_RTCopy;"
		"RenderDepthStencilTarget=TrailDepthBuffer;"
		"Pass=CopyTrailMap;"
		"RenderColorTarget0=TrailMap_RT;"
		"Pass=DryTrailMap;"
		"Pass=AddTrailMap;"

		// �`��p���H�̐���
		"RenderColorTarget0=WetHightMap_RT;"
		"RenderDepthStencilTarget=WetHightDepthBuffer;"
		"ClearSetColor=ClearColor;"
		"Clear=Color;"
		"Pass=DrawTrailMap;"
		"Pass=DrawDroplets;"

		// �ŏI�`��
		"RenderColorTarget0=;"
		"RenderDepthStencilTarget=;"
		"Pass=DrawSynth;"
	;
> {
#if defined(USE_MOTION) && USE_MOTION > 0
	pass CopyVelocity < string Script= "Draw=Buffer;"; > {
		AlphaBlendEnable = FALSE;
		AlphaTestEnable = FALSE;
		VertexShader = compile vs_3_0 UnitArray_VS();
		PixelShader  = compile ps_3_0 CopyVelocity_PS();
	}
	pass UpdateVelocity < string Script= "Draw=Buffer;"; > {
		AlphaBlendEnable = FALSE;
		AlphaTestEnable = FALSE;
		VertexShader = compile vs_3_0 UnitArray_VS();
		PixelShader  = compile ps_3_0 UpdateVelocity_PS();
	}
#endif

	pass CopyPos < string Script= "Draw=Buffer;"; > {
		AlphaBlendEnable = FALSE;
		AlphaTestEnable = FALSE;
		VertexShader = compile vs_3_0 UnitArray_VS();
		PixelShader  = compile ps_3_0 CopyPos_PS();
	}
	pass UpdatePos < string Script= "Draw=Buffer;"; > {
		AlphaBlendEnable = FALSE;
		AlphaTestEnable = FALSE;
		VertexShader = compile vs_3_0 UnitArray_VS();
		PixelShader  = compile ps_3_0 UpdatePos_PS();
	}

	pass ConvertUVToWPos < string Script= "Draw=Buffer;"; > {
		AlphaBlendEnable = FALSE;
		AlphaTestEnable = FALSE;
		VertexShader = compile vs_3_0 UnitArray_VS();
		PixelShader  = compile ps_3_0 ConvertUVToWPos_PS();
	}

	pass CopyTrailMap < string Script= "Draw=Buffer;"; > {
		AlphaBlendEnable = FALSE;
		AlphaTestEnable = FALSE;
		ZEnable = FALSE;
		ZWriteEnable = FALSE;
		VertexShader = compile vs_3_0 DryTrailMap_VS();
		PixelShader  = compile ps_3_0 CopyTrailMap_PS();
	}

	pass DryTrailMap < string Script= "Draw=Buffer;"; > {
		AlphaBlendEnable = FALSE;
		AlphaTestEnable = FALSE;
		ZEnable = FALSE;
		ZWriteEnable = FALSE;
		VertexShader = compile vs_3_0 DryTrailMap_VS();
		PixelShader  = compile ps_3_0 DryTrailMap_PS();
	}

	pass AddTrailMap {
		CULLMODE = NONE;
		ZEnable = FALSE;
		ZWriteEnable = FALSE;
		VertexShader = compile vs_3_0 AddTrailMap_VS();
		PixelShader  = compile ps_3_0 AddTrailMap_PS();
	}

	pass DrawTrailMap < string Script= "Draw=Buffer;"; > {
		ZEnable = FALSE;
		ZWriteEnable = FALSE;
		VertexShader = compile vs_3_0 DrawTrailMap_VS();
		PixelShader  = compile ps_3_0 DrawTrailMap_PS();
	}

	pass DrawDroplets {
		ZEnable = FALSE;
		ZWriteEnable = FALSE;
		VertexShader = compile vs_3_0 DrawDroplets_VS();
		PixelShader  = compile ps_3_0 DrawDroplets_PS();
	}

	pass DrawSynth  < string Script= "Draw=Buffer;"; > {
		ZEnable = FALSE;
		ZWriteEnable = FALSE;
		VertexShader = compile vs_3_0 DrawSynth_VS();
		PixelShader  = compile ps_3_0 DrawSynth_PS();
	}
}

float4 ClearColorZero = {0,0,0,0};
technique DropletSS <
	string MMDPass = "object_ss";
	string Script = 
		"ClearSetColor=ClearColorZero;"
#if defined(USE_MOTION) && USE_MOTION > 0
		"RenderColorTarget0=VelocityTex;"
		"Clear=Color;"
#endif
		"RenderColorTarget0=CoordTex;"
		"Clear=Color;"
		"RenderColorTarget0=WorldPosTex;"
		"Clear=Color;"
		"RenderColorTarget0=TrailMap_RT;"
		"Clear=Color;"
		"RenderColorTarget0=WetHightMap_RT;"
		"Clear=Color;"
#if defined(DISPLAY_TARGET_AREA) && DISPLAY_TARGET_AREA != 0
		"RenderColorTarget0=;"
		"RenderDepthStencilTarget=;"
		"Pass=DrawArea;"
#endif
	;
> {
	pass DrawArea  < string Script= "Draw=Buffer;"; > {
		ZEnable = FALSE;
		ZWriteEnable = FALSE;
		VertexShader = compile vs_3_0 DrawArea_VS();
		PixelShader  = compile ps_3_0 DrawArea_PS();
	}
}


technique EdgeTec < string MMDPass = "edge"; > { }
technique ShadowTec < string MMDPass = "shadow"; > { }
technique ZplotTec < string MMDPass = "zplot"; > { }

////////////////////////////////////////////////////////////////////////////////////////////////
