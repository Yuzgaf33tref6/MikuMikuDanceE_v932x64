// 

// �p�����[�^
#define	LightDistance	500
#define	LightZMax		1000
#define	LightRange		20

float AlphaThroughThreshold = 0.1;


/////////////////////////////////////////////////////////////////////
// �p�����[�^�錾

// ���@�ϊ��s��
//float4x4 matWVP	: WORLDVIEWPROJECTION;
//float4x4 matWV	: WORLDVIEW;
float4x4 matW	: WORLD;

float3 CameraPosition : CONTROLOBJECT < string name = "(OffscreenOwner)"; >;
float AcsSi  : CONTROLOBJECT < string name = "(OffscreenOwner)"; string item = "Si"; >;

float4x4 CreateLightViewMatrix(float3 foward)
{
	const float3 up = float3(0,0,1);
	float3 right = cross(up, foward);

	float3x3 mat;
	mat[2].xyz = foward;
	mat[0].xyz = right;
	mat[1].xyz = normalize(cross(foward, right));
	float3x3 matRot = transpose((float3x3)mat);

	float3 pos = floor(CameraPosition) - foward * LightDistance;

	return float4x4(
		matRot[0], 0,
		matRot[1], 0,
		matRot[2], 0,
		mul(-pos, matRot), 1);
}

static float CameraRange = 1.0 / (LightRange * AcsSi * 0.1);
static float4x4 matP = {
	CameraRange,	0,	0,	0,
	0,	CameraRange,	0,	0,
	0,	0,	1.0 / LightZMax,	0,
	0,	0,	0,	1
};

static float4x4 matV = CreateLightViewMatrix(float3(0,-1,0));
static float4x4 matWVP = mul(matW, mul(matV, matP));


bool opadd;

// �I�u�W�F�N�g�̃e�N�X�`��
texture ObjectTexture: MATERIALTEXTURE;
sampler ObjTexSampler = sampler_state {
    texture = <ObjectTexture>;
    MINFILTER = LINEAR;
    MAGFILTER = LINEAR;
};

float3	LightDirection	: DIRECTION < string Object = "Light"; >;

float4   MaterialDiffuse   : DIFFUSE  < string Object = "Geometry"; >;
float3   MaterialAmbient   : AMBIENT  < string Object = "Geometry"; >;
float3   MaterialEmisive  : EMISSIVE < string Object = "Geometry"; >;
float3   LightDiffuse      : DIFFUSE   < string Object = "Light"; >;
float3   LightAmbient      : AMBIENT   < string Object = "Light"; >;
static float4 DiffuseColor  = MaterialDiffuse  * float4(LightDiffuse, 1.0f);
static float3 AmbientColor  = MaterialAmbient  * LightAmbient + MaterialEmisive;

bool	use_toon;
bool	use_texture;		//	�e�N�X�`���t���O

bool     parthf;   // �p�[�X�y�N�e�B�u�t���O
bool     transp;   // �������t���O
bool	 spadd;    // �X�t�B�A�}�b�v���Z�����t���O

///////////////////////////////////////////////////////////////////////////////////////////////
// �I�u�W�F�N�g�`��i�Z���t�V���h�EOFF�j

struct VS_OUTPUT
{
	float4 Pos		: POSITION;    // �ˉe�ϊ����W
	float2 Tex		: TEXCOORD0;
	float4 WPos		: TEXCOORD1;
};

// ���_�V�F�[�_
VS_OUTPUT Basic_VS(float4 Pos : POSITION, float3 Normal : NORMAL,float2 Tex: TEXCOORD0)
{
	VS_OUTPUT Out = (VS_OUTPUT)0;
	Out.Pos = mul( Pos, matWVP );
	Out.Pos.w = opadd ? 0 : Out.Pos.w;

	Out.WPos = mul(Pos, matW);

	Out.Tex = Tex;
	return Out;
}


// �s�N�Z���V�F�[�_
float4 Basic_PS( VS_OUTPUT IN ) : COLOR
{
	// ���l��臒l�ȉ��̉ӏ��͕`�悵�Ȃ�
	float4 albedo = saturate(float4(AmbientColor, DiffuseColor.a));
	if (use_texture)
	{
		albedo *= tex2D( ObjTexSampler, IN.Tex );
	}

	float alpha = albedo.w;
	clip(alpha - AlphaThroughThreshold);

	return float4(IN.WPos.xyz, 1);
}

// �I�u�W�F�N�g�`��p�e�N�j�b�N
technique MainTec < string MMDPass = "object"; >
{
    pass DrawObject
    {
		AlphaTestEnable = FALSE; AlphaBlendEnable = FALSE;
       VertexShader = compile vs_3_0 Basic_VS();
        PixelShader  = compile ps_3_0 Basic_PS();
    }
}

technique MainTecBS  < string MMDPass = "object_ss"; >
{
    pass DrawObject {
		AlphaTestEnable = FALSE; AlphaBlendEnable = FALSE;
        VertexShader = compile vs_3_0 Basic_VS();
        PixelShader  = compile ps_3_0 Basic_PS();
    }
}

technique EdgeTec < string MMDPass = "edge"; > {}
technique ShadowTech < string MMDPass = "shadow";  > {}

///////////////////////////////////////////////////////////////////////////////////////////////
