///////////////////////////////////////////////////////////////////////////////
//
///////////////////////////////////////////////////////////////////////////////

#include "../settings.fxsub"

///////////////////////////////////////////////////////////////////////////////

// ���W�ϊ��s��
float4x4 matW				: WORLD;
float4x4 matWV				: WORLDVIEW;
float4x4 matP				: PROJECTION;
float4x4 CalcViewProjMatrix(float4x4 v, float4x4 p)
{
	p._11_22 *= GIFrameScale;
	return mul(v, p);
}
static float4x4 matWVP = CalcViewProjMatrix(matWV, matP);


// �}�e���A���F
float4 MaterialDiffuse   : DIFFUSE  < string Object = "Geometry"; >;
float3 MaterialAmbient   : AMBIENT  < string Object = "Geometry"; >;
float3 MaterialEmissive  : EMISSIVE < string Object = "Geometry"; >;
float3 MaterialSpecular  : SPECULAR < string Object = "Geometry"; >;
float3 MaterialToon	  : TOONCOLOR;

// �e�N�X�`���ގ����[�t�l
float4 TextureAddValue  : ADDINGTEXTURE;
float4 TextureMulValue  : MULTIPLYINGTEXTURE;
float4 SphereAddValue   : ADDINGSPHERETEXTURE;
float4 SphereMulValue   : MULTIPLYINGSPHERETEXTURE;

bool use_texture;
bool use_spheremap;
bool use_subtexture;
bool use_toon;
bool	opadd;

bool parthf;   // �p�[�X�y�N�e�B�u�t���O
bool transp;   // �������t���O
bool spadd;	// �X�t�B�A�}�b�v���Z�����t���O
#define SKII1  1500
#define SKII2  8000
#define Toon   3

// �I�u�W�F�N�g�̃e�N�X�`��
texture ObjectTexture: MATERIALTEXTURE;
sampler ObjTexSampler = sampler_state {
	texture = <ObjectTexture>;
	MINFILTER = LINEAR;
	MAGFILTER = LINEAR;
	MIPFILTER = LINEAR;
	ADDRESSU  = WRAP;
	ADDRESSV  = WRAP;
};

////////////////////////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////////////////////
// �I�u�W�F�N�g�`��

struct VS_OUTPUT {
	float4 Pos		: POSITION;	// �ˉe�ϊ����W
	float4 Tex		: TEXCOORD0;   // �e�N�X�`��
	float Distance	: TEXCOORD1;
	float4 Color	: COLOR0;	  // �f�B�t���[�Y�F
};

VS_OUTPUT Basic_VS(float4 Pos : POSITION, float3 Normal : NORMAL, float2 Tex : TEXCOORD0)
{
	VS_OUTPUT Out = (VS_OUTPUT)0;

	Out.Pos = mul( Pos, matWVP );
	Out.Pos.w *= (opadd ? 0 : 1);

	Out.Distance = mul(Pos, matWV).z;

	Out.Tex.xy = Tex;
	Out.Color = saturate( float4(1,1,1, MaterialDiffuse.a) );

	return Out;
}


// �s�N�Z���V�F�[�_
float4 Basic_PS(VS_OUTPUT IN) : COLOR
{
	float4 albed = IN.Color;
	if(use_texture){
		// �e�N�X�`���K�p
		float4 TexColor = tex2D(ObjTexSampler,IN.Tex.xy);
		albed *= TexColor;
	}
	clip(albed.a - AlphaThreshold);

	return float4(IN.Distance, 0,0,1);
}


#define OBJECT_TEC(name, mmdpass) \
	technique name < string MMDPass = mmdpass; > { \
		pass DrawObject { \
			AlphaTestEnable = FALSE; AlphaBlendEnable = FALSE; \
			VertexShader = compile vs_3_0 Basic_VS(); \
			PixelShader  = compile ps_3_0 Basic_PS(); \
		} \
	}


OBJECT_TEC(MainTec0, "object")
OBJECT_TEC(MainTecBS1, "object_ss")

technique EdgeTec < string MMDPass = "edge"; > {}
technique ShadowTec < string MMDPass = "shadow"; > {}
technique ZplotTec < string MMDPass = "zplot"; > {}


///////////////////////////////////////////////////////////////////////////////
