////////////////////////////////////////////////////////////////////////////////////////////////
// ikDepthBright.fx
// ik�{�P.fx�̂��߂ɁA���`�̐[�x����(�t�F�C�N��)���邳�����o�͂���B
////////////////////////////////////////////////////////////////////////////////////////////////

// �p�����[�^�錾

// �����e�N�X�`���𖳎����郿�l�̏��
const float AlphaThroughThreshold = 0.2;

// ���邢�������������邩? (0:���Ȃ��A1:����)
#define EMPHASIS_BRIGHTNESS		1

//�V���h�E�}�b�v�T�C�Y
//#define SHADOWMAP_SIZE 1024
#define SHADOWMAP_SIZE 4096

// �Ȃɂ��Ȃ��`�悵�Ȃ��ꍇ�́A�w�i�܂ł̋���
// �����M��ꍇ�Aik�{�P.fx�̓����l���ύX����K�v������B
#define FAR_DEPTH		1000

////////////////////////////////////////////////////////////////////////////////////////////////


// ���@�ϊ��s��
float4x4 WorldViewProjMatrix      : WORLDVIEWPROJECTION;
float4x4 WorldMatrix              : WORLD;
float4x4 ViewMatrix               : VIEW;
float4x4 ProjMatrix				  : PROJECTION;
float4x4 LightWorldViewProjMatrix : WORLDVIEWPROJECTION < string Object = "Light"; >;
float4x4 matWV	: WORLDVIEW;

float3   LightDirection    : DIRECTION < string Object = "Light"; >;
float3   CameraPosition    : POSITION  < string Object = "Camera"; >;

// �}�e���A���F
float4   MaterialDiffuse   : DIFFUSE  < string Object = "Geometry"; >;
float3   MaterialAmbient   : AMBIENT  < string Object = "Geometry"; >;
float3   MaterialEmmisive  : EMISSIVE < string Object = "Geometry"; >;
float3   MaterialSpecular  : SPECULAR < string Object = "Geometry"; >;
float    SpecularPower     : SPECULARPOWER < string Object = "Geometry"; >;
float3   MaterialToon      : TOONCOLOR;
float4   EdgeColor         : EDGECOLOR;
// ���C�g�F
float3   LightDiffuse      : DIFFUSE   < string Object = "Light"; >;
float3   LightAmbient      : AMBIENT   < string Object = "Light"; >;
float3   LightSpecular     : SPECULAR  < string Object = "Light"; >;
static float4 DiffuseColor  = MaterialDiffuse  * float4(LightDiffuse, 1.0f);
static float3 AmbientColor  = saturate(MaterialAmbient  * LightAmbient + MaterialEmmisive);
static float3 SpecularColor = MaterialSpecular * LightSpecular;

bool     parthf;   // �p�[�X�y�N�e�B�u�t���O
bool     transp;   // �������t���O
bool	 spadd;    // �X�t�B�A�}�b�v���Z�����t���O
#define SKII1    1500
#define SKII2    8000

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

// �V���h�E�o�b�t�@�̃T���v���B"register(s0)"�Ȃ̂�MMD��s0���g���Ă��邩��
sampler DefSampler : register(s0);


///////////////////////////////////////////////////////////////////////////////////////////////

struct BufferShadow_OUTPUT {
	float4 Pos		: POSITION;		// �ˉe�ϊ����W
	float4 ZCalcTex	: TEXCOORD0;	// Z�l
	float2 Tex		: TEXCOORD1;	// �e�N�X�`��
	float4 VPos		: TEXCOORD2;	// Position

#if defined(EMPHASIS_BRIGHTNESS) && EMPHASIS_BRIGHTNESS > 0
	float3 Normal	: TEXCOORD3;	// �@��
	float3 Eye		: TEXCOORD4;	// �J�����Ƃ̑��Έʒu
	float4 SpTex	: TEXCOORD5;	// �X�t�B�A�}�b�v�e�N�X�`�����W
#endif
};


///////////////////////////////////////////////////////////////////////////////////////////////
// �f�t���[�Y�̌v�Z
float CalcDiffuse(float3 L, float3 N, float3 V)
{
	const float NL = dot(N,L);
	return saturate(NL);
}

//�X�y�L�����̌v�Z
float CalcSpecular(float3 L, float3 N, float3 V, float2 coef)
{
	float3 H = normalize(L + V);
	float Specular = saturate(dot( H, N ));
	return pow(Specular, coef.y) * coef.x;
}

// �K���ȃO���[�X�P�[����
float gray(float3 color)
{
	return (color.r + color.g + color.b) / 3.0;
}


////////////////////////////////////////////////////////////////////////////////////////////////
// 

float GetShadowDepth(float2 TransTexCoord)
{
	return tex2D(DefSampler,TransTexCoord).r;
}

//-----------------------------------------------------------------------
// �������Օ�����Ă��邩�ǂ������ׂ�
// @return	0:���S�ɎՕ�����Ă���B1:�Օ�����Ă��Ȃ��B
float CalcShadowRate(float2 TransTexCoord, float depth)
{
	float comp = 1;
	if( any( saturate(TransTexCoord) != TransTexCoord ) ) {
		;	// �V���h�E�o�b�t�@�O
	} else {
		float sum = 0;
		float k = (parthf) ? SKII2 * TransTexCoord.y : SKII1;

		float depthTest = max(depth - GetShadowDepth(TransTexCoord), 0);
		comp = 1 - saturate(depthTest * k - 0.3);
	}

	return comp;
}




////////////////////////////////////////////////////////////////////////////////
// ���_�V�F�[�_
BufferShadow_OUTPUT BufferShadow_VS(float4 Pos : POSITION, float3 Normal : NORMAL, float2 Tex : TEXCOORD0, uniform bool useTexture, uniform bool useSphereMap, uniform bool useSelfshadpw)
{
	BufferShadow_OUTPUT Out = (BufferShadow_OUTPUT)0;

	Out.Pos = mul(Pos,WorldViewProjMatrix);
	Out.VPos = mul(Pos,matWV);

	Out.Tex = Tex;

#if defined(EMPHASIS_BRIGHTNESS) && EMPHASIS_BRIGHTNESS > 0
	Out.Eye = CameraPosition - mul( Pos, WorldMatrix );
	Out.Normal = normalize( mul( Normal, (float3x3)WorldMatrix ) );

	if (useSelfshadpw)
	{
		Out.ZCalcTex = mul(Pos, LightWorldViewProjMatrix);
	}

	if ( useSphereMap ) {
		float2 NormalWV = mul( Out.Normal, (float3x3)ViewMatrix );
		Out.SpTex.x = NormalWV.x * 0.5f + 0.5f;
		Out.SpTex.y = NormalWV.y * -0.5f + 0.5f;
	}

	float smoothness = log2(SpecularPower) / 16.0;
	Out.SpTex.z = smoothness;
	Out.SpTex.w = SpecularPower;
#endif

	return Out;
}


// �s�N�Z���V�F�[�_
float4 BufferShadow_PS(BufferShadow_OUTPUT IN, uniform bool useTexture, uniform bool useSphereMap, uniform bool useSelfshadpw) : COLOR
{
	// ���l��臒l�ȉ��̉ӏ��͕`�悵�Ȃ�
	if ( useTexture ) {
		float4 TexColor = tex2D( ObjTexSampler, IN.Tex ).a;
		float alpha = TexColor.a;
		clip(alpha - AlphaThroughThreshold);
	}

	float distance = length(IN.VPos);

#if defined(EMPHASIS_BRIGHTNESS) && EMPHASIS_BRIGHTNESS > 0
	const float3 N = normalize(IN.Normal);
	const float3 V = normalize(IN.Eye);
	const float3 L = normalize(-LightDirection);

	float bright = CalcDiffuse(L, N, V);

	if (useSelfshadpw)
	{
		IN.ZCalcTex /= IN.ZCalcTex.w;
		float2 TransTexCoord = float2(1.0f + IN.ZCalcTex.x, 1.0f - IN.ZCalcTex.y) * 0.5;
		float shadow = CalcShadowRate(TransTexCoord, IN.ZCalcTex.z);
		bright = bright * shadow;
	}

	float Specular = CalcSpecular(L, N, V, IN.SpTex.zw);
	if ( useSphereMap && spadd) {
		float4 TexColor = tex2D(ObjSphareSampler, IN.SpTex.xy);
		Specular = saturate(Specular + gray(TexColor.rgb));
	}

	bright = (bright * Specular);
#else
	float bright = 0;
#endif

	return float4(distance / FAR_DEPTH, bright, 0, 1);
}



// �I�u�W�F�N�g�`��p�e�N�j�b�N
#define BASICSHADOW_TEC(name, mmdpass, sphere, tex, selfshadow) \
	technique name < string MMDPass = mmdpass; bool UseTexture = tex; bool UseSphereMap = sphere; \
	> { \
		pass DrawObject { \
			VertexShader = compile vs_3_0 BufferShadow_VS(tex, sphere, selfshadow); \
			PixelShader  = compile ps_3_0 BufferShadow_PS(tex, sphere, selfshadow); \
		} \
	}

BASICSHADOW_TEC(BTec0, "object", false, false, false)
BASICSHADOW_TEC(BTec1, "object", true,  false, false)
BASICSHADOW_TEC(BTec2, "object", false, true, false)
BASICSHADOW_TEC(BTec3, "object", true,  true, false)

BASICSHADOW_TEC(BSTec0, "object_ss", false, false, true)
BASICSHADOW_TEC(BSTec1, "object_ss", true,  false, true)
BASICSHADOW_TEC(BSTec2, "object_ss", false, true, true)
BASICSHADOW_TEC(BSTec3, "object_ss", true,  true, true)

///////////////////////////////////////////////////////////////////////////////////////////////
