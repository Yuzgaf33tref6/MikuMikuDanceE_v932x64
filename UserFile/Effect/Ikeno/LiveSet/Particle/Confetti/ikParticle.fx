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

// �{��
#include "../Commons/Sources/_body.fxsub"


///////////////////////////////////////////////////////////////////////////////////////
// �p�[�e�B�N���`��

float4x4 matV	: VIEW;
float4x4 matVP	: VIEWPROJECTION;
float4x4 matVPLight : VIEWPROJECTION < string Object = "Light"; >;

float3	CameraPosition    : POSITION  < string Object = "Camera"; >;
float3	LightDirection	: DIRECTION < string Object = "Light"; >;

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

// �V���h�E�o�b�t�@�̃T���v���B"register(s0)"�Ȃ̂�MMD��s0���g���Ă��邩��
sampler DefSampler : register(s0);


struct VS_OUTPUT2
{
	float4 Pos		: POSITION;	// �ˉe�ϊ����W
	float4 Tex		: TEXCOORD0;	// �e�N�X�`��
	float4 ZCalcTex	: TEXCOORD2;	// Z�l
	float2 SpTex	: TEXCOORD4;	// �X�t�B�A�}�b�v�e�N�X�`�����W
	float4 Color	: COLOR0;		// ���q�̏�Z�F
};

// ���_�V�F�[�_
VS_OUTPUT2 Particle_VS(float4 Pos : POSITION, float2 Tex : TEXCOORD0, uniform bool useShadow)
{
	VS_OUTPUT2 Out=(VS_OUTPUT2)0;

	POSITION_INFO posInfo = CalcPosition(Pos, Tex);
	float4 WPos = posInfo.WPos;

	Out.Pos = mul( WPos, matVP );
	if (useShadow) Out.ZCalcTex = mul( WPos, matVPLight );

	// ���C�g�̌v�Z
	#if ENABLE_LIGHT == 1
	float3 N = posInfo.Normal;
	float dotNL = dot(-LightDirection, N);
	float dotNV = dot(normalize(CameraPosition - Pos.xyz), N);
	dotNL = dotNL * sign(dotNV);
	float diffuse = lerp(max(dotNL,0) + max(-dotNL,0) * Translucency, 1, Translucency);
	#else
	float diffuse = 1;
	#endif

	Out.Color = posInfo.Color * float4(diffuse.xxx, 1);
	Out.Tex = posInfo.Tex;
	Out.SpTex = posInfo.SpTex;

	return Out;
}


// �s�N�Z���V�F�[�_
float4 Particle_PS( VS_OUTPUT2 IN, uniform bool useShadow ) : COLOR0
{
	// ���q�̐F
	float4 Color = CalcColor(IN.Color, IN.Tex);

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

	#if( USE_SPHERE==1 )
		// �X�t�B�A�}�b�v�K�p
		Color.rgb += max(tex2D(ParticleSphereSamp, IN.SpTex).rgb * LightSpecular, 0);
		#if( SPHERE_SATURATE==1 )
			Color = saturate( Color );
		#endif
	#endif

	return Color;
}


///////////////////////////////////////////////////////////////////////////////////////////////
// �Z���t�V���h�E�pZ�l�v���b�g

struct VS_ZValuePlot_OUTPUT {
	float4 Pos		: POSITION;				// �ˉe�ϊ����W
	float4 Tex		: TEXCOORD0;	// �e�N�X�`��
	float4 ShadowMapTex : TEXCOORD1;	// Z�o�b�t�@�e�N�X�`��
	float4 Color	 : COLOR0;		// ���q�̏�Z�F
};

// ���_�V�F�[�_
VS_ZValuePlot_OUTPUT ZValuePlot_VS( float4 Pos : POSITION, float2 Tex : TEXCOORD0 )
{
	VS_ZValuePlot_OUTPUT Out = (VS_ZValuePlot_OUTPUT)0;

	POSITION_INFO posInfo = CalcPosition(Pos, Tex);
	float4 WPos = posInfo.WPos;

	Out.Pos = mul( WPos, matVPLight );
	Out.ShadowMapTex = Out.Pos;

	Out.Color = posInfo.Color;
	Out.Tex = posInfo.Tex;

	return Out;
}

// �s�N�Z���V�F�[�_
float4 ZValuePlot_PS(
		float4 ShadowMapTex	: TEXCOORD1,
		float4 Tex			: TEXCOORD0,
		float4 Color		: COLOR0
	) : COLOR
{
	float alpha = CalcColor(Color, Tex).a;
	clip(alpha - AlphaThroughThreshold);

	// R�F������Z�l���L�^����
	return float4(ShadowMapTex.z/ShadowMapTex.w,0,0,1);
}

// Z�l�v���b�g�p�e�N�j�b�N
technique ZplotTec <
	string MMDPass = "zplot";
	string Script = PARTICLE_LOOPSCRIPT_OBJECT;
>{
	pass DrawObject {
		AlphaBlendEnable = FALSE;
		VertexShader = compile vs_3_0 ZValuePlot_VS();
		PixelShader  = compile ps_3_0 ZValuePlot_PS();
	}
}


technique MainTec1 < string MMDPass = "object";
	string Script = 
		PARTICLE_UPDATE_POSITION
		PARTICLE_LOOPSCRIPT_OBJECT;
>{
	UPDATE_PASS_STATES

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
		PARTICLE_UPDATE_POSITION
		PARTICLE_LOOPSCRIPT_OBJECT;
>{
	UPDATE_PASS_STATES

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

