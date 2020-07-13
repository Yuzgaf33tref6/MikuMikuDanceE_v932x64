// �Z���t�V���h�E�����A�A�e����


// �p�����[�^�錾
float4   MaterialDiffuse   : DIFFUSE  < string Object = "Geometry"; >;

// ���@�ϊ��s��
float4x4 matWVP	: WORLDVIEWPROJECTION;
float4x4 matWV	: WORLDVIEW;
float4x4 matW	: WORLD;

float4x4 matWVPLight : WORLDVIEWPROJECTION < string Object = "Light"; >;

float3   LightDirection	: DIRECTION < string Object = "Light"; >;
float3   LightSpecular	 : SPECULAR  < string Object = "Light"; >;

float rgb2gray(float3 rgb)
{
	return dot(float3(0.299, 0.587, 0.114), rgb);
}

static float LightVolume = rgb2gray(LightSpecular);


// MMD�{����sampler���㏑�����Ȃ����߂̋L�q�ł��B�폜�s�B
sampler DefSampler : register(s0);
sampler MMDSamp0 : register(s0);
sampler MMDSamp1 : register(s1);
sampler MMDSamp2 : register(s2);

bool	use_texture;		// �e�N�X�`���g�p

bool	 parthf;   // �p�[�X�y�N�e�B�u�t���O
#define SKII1	1500
#define SKII2	8000

// �I�u�W�F�N�g�̃e�N�X�`��
texture ObjectTexture: MATERIALTEXTURE;
sampler ObjTexSampler = sampler_state {
    texture = <ObjectTexture>;
    MINFILTER = LINEAR;
    MAGFILTER = LINEAR;
};

float3   CameraPosition	: POSITION  < string Object = "Camera"; >;


///////////////////////////////////////////////////////////////////////////////////////////////
// �I�u�W�F�N�g�`��i�Z���t�V���h�EOFF�j

struct VS_OUTPUT
{
	float4 Pos		: POSITION;    // �ˉe�ϊ����W
	float4 ZCalcTex : TEXCOORD0;	// Z�l
	float2 Tex		: TEXCOORD1;
	float3 Normal   : TEXCOORD2;	// �@��
};

// ���_�V�F�[�_
VS_OUTPUT Basic_VS(float4 Pos : POSITION, float3 Normal : NORMAL, float2 Tex : TEXCOORD0)
{
	VS_OUTPUT Out = (VS_OUTPUT)0;

	Out.Pos = mul( Pos, matWVP );
	Out.Tex = Tex;

	// ���_�@��
	Out.Normal = normalize( mul( Normal, (float3x3)matW ) );

	// ���C�g���_�ɂ�郏�[���h�r���[�ˉe�ϊ�
	Out.ZCalcTex = mul( Pos, matWVPLight );

	return Out;
}

// �s�N�Z���V�F�[�_
float4 Basic_PS( VS_OUTPUT IN, uniform bool bSahdow ) : COLOR
{
	float alpha = MaterialDiffuse.a;
	if (use_texture)
	{
		alpha *= tex2D( ObjTexSampler, IN.Tex ).a;
	}

	float3 L = -LightDirection;
	float3 N = normalize(IN.Normal);
	float shadow = saturate(dot(N,L));

	return float4(shadow * LightVolume, 0,0, alpha);
}

// �I�u�W�F�N�g�`��p�e�N�j�b�N
technique MainTec < string MMDPass = "object"; > {
    pass DrawObject
    {
        VertexShader = compile vs_2_0 Basic_VS();
        PixelShader  = compile ps_2_0 Basic_PS(false);
    }
}

// �I�u�W�F�N�g�`��p�e�N�j�b�N
technique MainTecBS  < string MMDPass = "object_ss"; > {
    pass DrawObject {
        VertexShader = compile vs_2_0 Basic_VS();
        PixelShader  = compile ps_2_0 Basic_PS(true);
    }
}

technique EdgeTec < string MMDPass = "edge"; > {}
technique ShadowTech < string MMDPass = "shadow";  > {}

///////////////////////////////////////////////////////////////////////////////////////////////
