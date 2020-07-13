////////////////////////////////////////////////////////////////////////////////////////////////
//
// ikFragmentDepth.fx
// ik�{�P��ikFragment�̔�ʊE�[�x�𐳂����������߂̃G�t�F�N�g�t�@�C��
//
////////////////////////////////////////////////////////////////////////////////////////////////

// �ݒ�t�@�C��
#include "ikFragmentSettings.fxsub"

#define ITERATION_NUM	8		// �`�F�b�N�p���[�v��
#define ALPHA_THRESHOLD	0.8
const float AlphaThroughThreshold = 0.5;


////////////////////////////////////////////////////////////////////////////////////////////////
// �p�����[�^�錾

// �Ȃɂ��Ȃ��`�悵�Ȃ��ꍇ�̔w�i�܂ł̋���
#define FAR_DEPTH		1000

#define TEX_WIDTH     UNIT_COUNT  // ���W���e�N�X�`���s�N�Z����
#define TEX_HEIGHT    1024        // �z�u��������e�N�X�`���s�N�Z������

#define PAI 3.14159265f   // ��

float AcsTr  : CONTROLOBJECT < string name = "(self)"; string item = "Tr"; >;

int RepeatCount = UNIT_COUNT;  // �V�F�[�_���`�攽����
int RepeatIndex;               // �������f���J�E���^

static float ParticleSizeMax = max(ParticleSize.x, max(ParticleSize.y, ParticleSize.z)) * 10;

float3   CameraPosition    : POSITION  < string Object = "Camera"; >;

// ���W�ϊ��s��
float4x4 matW		: WORLD;
float4x4 matV		: VIEW;
float4x4 matVP		: VIEWPROJECTION;
float4x4 matVPInv	: VIEWPROJECTIONINVERSE;

float4x4 matVInv	: VIEWINVERSE;
static float3x3 BillboardMatrix = {
	normalize(matVInv[0].xyz),
	normalize(matVInv[1].xyz),
	normalize(matVInv[2].xyz),
};


// MMD�{����sampler���㏑�����Ȃ����߂̋L�q�ł��B�폜�s�B
sampler MMDSamp0 : register(s0);
sampler MMDSamp1 : register(s1);
sampler MMDSamp2 : register(s2);

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

// ���q���W�L�^�p
shared texture COORD_TEX_NAME : RENDERCOLORTARGET;
sampler CoordSmp : register(s3) = sampler_state
{
   Texture = <COORD_TEX_NAME>;
    AddressU  = CLAMP;
    AddressV = CLAMP;
    MinFilter = NONE;
    MagFilter = NONE;
    MipFilter = NONE;
};


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
                     cosx*siny,               -sinx,       cosx*cosy,               };

   return rMat;
}

///////////////////////////////////////////////////////////////////////////////////////
// �p�[�e�B�N���`��

struct VS_OUTPUT2
{
    float4 Pos       : POSITION;    // �ˉe�ϊ����W
	float4 NormalX	: TEXCOORD1;
	float4 NormalY	: TEXCOORD2;
	float4 NormalZ	: TEXCOORD3;
	float4 WPos		: TEXCOORD4;
	float4 PPos		: TEXCOORD5;
	float4 Info		: TEXCOORD6;
	float4 Color	: COLOR0;		// ���q�̏�Z�F
};

// ���_�V�F�[�_
VS_OUTPUT2 Particle_VS(float4 Pos : POSITION, float2 Tex : TEXCOORD0)
{
   VS_OUTPUT2 Out=(VS_OUTPUT2)0;

   int i = RepeatIndex;
   int j = round( Pos.z * 100.0f );
   int Index0 = i * TEX_HEIGHT + j;
   float2 texCoord = float2((i+0.5f)/TEX_WIDTH, (j+0.5f)/TEX_HEIGHT);
   Pos.z = 0.0f;

	Out.Info.x = float(j);
	// �e�N�X�`���p�^�[��
	int texIndex = Out.Info.x % (TEX_PARTICLE_XNUM * TEX_PARTICLE_YNUM);
	Out.Info.yz = float2( texIndex % TEX_PARTICLE_XNUM, texIndex / TEX_PARTICLE_XNUM)
		* float2(1.0 / TEX_PARTICLE_XNUM, 1.0 / TEX_PARTICLE_YNUM);

   // ���q�̍��W
   float4 Pos0 = tex2Dlod(CoordSmp, float4(texCoord, 0, 0));

   // �o�ߎ���
   float etime = Pos0.w - 1.0f;
	// ��]�ƕ��s�ړ�����
	float3x3 matWTmp = RoundMatrix(Index0, etime);
	Out.NormalX.xyz = matWTmp[0];
	Out.NormalY.xyz = matWTmp[1];
	Out.NormalZ.xyz = matWTmp[2];
	Out.WPos = Pos0;

	// ���q�̑傫��
	Pos.xy *= ParticleSizeMax;
	Pos.xyz = mul(Pos.xyz, BillboardMatrix);
	// ���q�̃��[���h���W
	Pos.xyz += Pos0.xyz;
	Pos.xyz *= step(0.001f, etime);
	Pos.w = 1.0f;

	Out.Pos = mul( Pos, matVP );
	Out.PPos = Out.Pos;

	// ���q�̏�Z�F
	float alpha = step(0.001f, etime) * smoothstep(-ParticleLife, -ParticleLife*ParticleDecrement, -etime) * AcsTr;
	// ���t�߂ŏ����Ȃ�
	#if !defined(ENABLE_BOUNCE) || ENABLE_BOUNCE == 0
	alpha *= smoothstep(FloorFadeMin, FloorFadeMax, Pos0.y);
	#endif
	Out.Color = float4(1,1,1, alpha );

   return Out;
}


// �s�N�Z���V�F�[�_
float4 Particle_PS( VS_OUTPUT2 IN ) : COLOR0
{
	float4 Color = IN.Color;
	clip(Color.a - AlphaThroughThreshold);

	// ���[���h���W�ł̎���
	float3 v = normalize(mul(IN.PPos, matVPInv).xyz - CameraPosition);

	float3x3 matRot = float3x3( IN.NormalX.xyz, IN.NormalY.xyz, IN.NormalZ.xyz);
	float3x3 matRotInv = transpose((float3x3)matRot);
	float4x4 matLocalInv = float4x4(
		matRotInv[0], 0,
		matRotInv[1], 0,
		matRotInv[2], 0,
		mul(-IN.WPos.xyz, matRotInv), 1);

	float3 localCameraPosition = mul(float4(CameraPosition,1), matLocalInv).xyz;
	float3 localViewDirection = mul(v, (float3x3)matLocalInv).xyz;

	// �q�b�g�|�C���g��T��
	float3 tNear0 = ((ParticleSize * 0.5) - localCameraPosition) * (1.0/localViewDirection);
	float3 tFar0  = ((ParticleSize *-0.5) - localCameraPosition) * (1.0/localViewDirection);
	float3 tNear1 = min(tNear0, tFar0);
	float3 tFar1  = max(tNear0, tFar0);
	float tNear = max(tNear1.x, max(tNear1.y, tNear1.z));
	float tFar  = min(tFar1.x , min(tFar1.y , tFar1.z ));
	// �L���[�u�Ƀq�b�g���Ȃ�?
	clip((tFar > tNear) - 0.1);

	// �L���[�u���Ńe�N�X�`���̂���ꏊ�Ƀq�b�g���邩?
	float2 texOffsetSclae = float2(1.0 / TEX_PARTICLE_XNUM, 1.0 / TEX_PARTICLE_YNUM);
	float2 texOffset = IN.Info.yz;
	float3 hitposB = localCameraPosition + localViewDirection * tNear;
	float3 hitposE = localCameraPosition + localViewDirection * tFar;
	float2 TexB = saturate(hitposB.xy * (2.0 / ParticleSize.xy * 0.5) + 0.5);
	float2 TexE = saturate(hitposE.xy * (2.0 / ParticleSize.xy * 0.5) + 0.5);
	TexB = TexB * texOffsetSclae + texOffset;
	TexE = TexE * texOffsetSclae + texOffset;
	float2 vTex = (TexE - TexB) * (1.0 / ITERATION_NUM);
	float4 color = 0;
	int hitcount = -1;
	for(int i = 0; i < ITERATION_NUM; i++)
	{
		color = tex2D(ParticleTexSamp, i * vTex + TexB);
		if (color.a > ALPHA_THRESHOLD)
		{
			hitcount = i;
			break;
		}
	}
	// �q�b�g���Ȃ�����?
	clip(hitcount);

	float3 hitpos = hitposB + hitcount * (hitposE - hitposB) * (1.0 / ITERATION_NUM);
	float3 wpos = mul(hitpos, matRot) + IN.WPos.xyz;
	float dist = length(mul(float4(wpos,1), matV).xyz);
	return float4(dist / FAR_DEPTH, 0, 0, 1);
}


///////////////////////////////////////////////////////////////////////////////////////
// �e�N�j�b�N

technique MainTec1 < string MMDPass = "object";
   string Script = 
       "RenderColorTarget0=;"
	    "RenderDepthStencilTarget=;"
            "LoopByCount=RepeatCount;"
            "LoopGetIndex=RepeatIndex;"
                "Pass=DrawObject;"
            "LoopEnd=;";
>{
    pass DrawObject {
        ZENABLE = TRUE; ZWRITEENABLE = TRUE;
        CullMode = NONE;
        VertexShader = compile vs_3_0 Particle_VS();
        PixelShader  = compile ps_3_0 Particle_PS();
    }
}

technique MainTec2 < string MMDPass = "object_ss";
   string Script = 
       "RenderColorTarget0=;"
	    "RenderDepthStencilTarget=;"
            "LoopByCount=RepeatCount;"
            "LoopGetIndex=RepeatIndex;"
                "Pass=DrawObject;"
            "LoopEnd=;";
>{
    pass DrawObject {
        ZENABLE = TRUE; ZWRITEENABLE = TRUE;
        CullMode = NONE;
        VertexShader = compile vs_3_0 Particle_VS();
        PixelShader  = compile ps_3_0 Particle_PS();
    }
}

