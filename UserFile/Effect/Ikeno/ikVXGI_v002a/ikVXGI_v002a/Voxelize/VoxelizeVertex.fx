////////////////////////////////////////////////////////////////////////////////////////////////
// �{�N�Z�����p�̃f�[�^�o�́B
//
// ���_�P�ʂŃ{�N�Z�������� (�񐄏�)
// �኱����? ���x�������B�傫�ȃ|���S�������܂��ϊ��ł��Ȃ��B


////////////////////////////////////////////////////////////////////////////////////////////////
// �p�����[�^�錾

// �ݒ�t�@�C��
#include "../settings.fxsub"

/////////////////////////////////////////////////////////////////////////////////////////

float AcsSi : CONTROLOBJECT < string name = "(OffscreenOwner)"; string item = "Si"; >;
static float GRID_SIZE_ = (AcsSi * 0.1 * GRID_SIZE);

#define		VOXEL_SIZE		(VOXEL_SIZE_SQRT * VOXEL_SIZE_SQRT)
static float FarDepth = (VOXEL_SIZE * GRID_SIZE_);

#define INV_GRID_SIZE	(1.0 / GRID_SIZE_)
#define INV_2D_VOXEL_SIZE	(1.0 / (VOXEL_SIZE * VOXEL_SIZE_SQRT))

#define		TEX_HEIGHT		(VOXEL_SIZE * VOXEL_SIZE_SQRT)

//-----------------------------------------------------------------------------

// ���@�ϊ��s��
float4x4 matW			: WORLD;
float2 ViewportSize : VIEWPORTPIXELSIZE;

float3 CenterPosition : CONTROLOBJECT < string name = "(OffscreenOwner)"; >;
static float3 GridCenterPosition = (floor(CenterPosition * INV_GRID_SIZE + VOXEL_SIZE) - VOXEL_SIZE) * GRID_SIZE_;
static float3 GridOffset = floor(GridCenterPosition * INV_GRID_SIZE + VOXEL_SIZE) % VOXEL_SIZE;

// �}�e���A���F
float4	MaterialDiffuse		: DIFFUSE  < string Object = "Geometry"; >;
float3	MaterialAmbient		: AMBIENT  < string Object = "Geometry"; >;
float3	MaterialEmissive	: EMISSIVE < string Object = "Geometry"; >;
static float3 AmbientColor  = MaterialAmbient + MaterialEmissive;
//static float4 DiffuseColor  = MaterialDiffuse;
static float4 DiffuseColor  = saturate( float4(AmbientColor.rgb, MaterialDiffuse.a));

// �ގ����[�t�Ή�
float4	TextureAddValue   : ADDINGTEXTURE;
float4	TextureMulValue   : MULTIPLYINGTEXTURE;

float3	LightSpecular	 	: SPECULAR  < string Object = "Light"; >;

const float epsilon = 1.0e-6;
const float gamma = 2.2;
inline float3 Degamma(float3 col) { return pow(max(col,epsilon), gamma); }
inline float3 Gamma(float3 col) { return pow(max(col,epsilon), 1.0/gamma); }
inline float4 Degamma4(float4 col) { return float4(Degamma(col.rgb), col.a); }
inline float4 Gamma4(float4 col) { return float4(Gamma(col.rgb), col.a); }
inline float rgb2gray(float3 rgb)
{
	return dot(float3(0.299, 0.587, 0.114), rgb);
}

static float3 LightColor = Degamma(saturate(LightSpecular)) * 2.5 / 1.5;

bool	use_texture;	//	�e�N�X�`���t���O
bool	use_toon;		//	�g�D�[���t���O
bool	parthf;			// �p�[�X�y�N�e�B�u�t���O
bool	transp;			// �������t���O
bool	spadd;			// �X�t�B�A�}�b�v���Z�����t���O
bool	opadd;

#define SKII1	1500
#define SKII2	8000
#define Toon	 3

// �I�u�W�F�N�g�̃e�N�X�`��
texture ObjectTexture: MATERIALTEXTURE;
sampler ObjTexSampler = sampler_state {
	texture = <ObjectTexture>;
	MINFILTER = LINEAR;	MAGFILTER = LINEAR;
	ADDRESSU  = WRAP;	ADDRESSV  = WRAP;
};

// MMD�{����sampler���㏑�����Ȃ����߂̋L�q�ł��B�폜�s�B
sampler MMDSamp0 : register(s0);
sampler MMDSamp1 : register(s1);
sampler MMDSamp2 : register(s2);
//sampler DefSampler : register(s0);

shared texture2D VoxelPackNormal: RENDERCOLORTARGET;


////////////////////////////////////////////////////////////////////////////////////////////////
//

#define	PI	(3.14159265359)


////////////////////////////////////////////////////////////////////////////////////////////////
// 

technique EdgeTec < string MMDPass = "edge"; > {}
technique ShadowTec < string MMDPass = "shadow"; > {}
technique ZplotTec < string MMDPass = "zplot"; > {}


///////////////////////////////////////////////////////////////////////////////////////////////
// �I�u�W�F�N�g�`��i�Z���t�V���h�EON�j

struct BufferShadow_OUTPUT {
	float4 Pos		: POSITION;
	float3 Normal	: TEXCOORD0;
	float2 Tex		: TEXCOORD1;
	float3 GridPos	: TEXCOORD3;
};

struct PS_OUT_MRT
{
	float4 Color	: COLOR0;
	float4 Normal	: COLOR1;
	float Depth		: DEPTH;
};

//-----------------------------------------------------------------------
// �L�����̓{�N�Z���ɔ�ׂď������̂Œ��_�P�ʂŏ�������

BufferShadow_OUTPUT DrawPoint_VS(float4 Pos : POSITION, float3 Normal : NORMAL, float2 Tex : TEXCOORD0, int index: _INDEX, 
	uniform bool useTexture)
{
	BufferShadow_OUTPUT Out = (BufferShadow_OUTPUT)0;

	float3 vpos = floor((mul( Pos, matW ).xyz - GridCenterPosition + FarDepth * 0.5) * INV_GRID_SIZE - 0.5);

	int mode = index % 3;
	int index2 = index / 3;

	float3 coef = 0;
	if (mode == 0)
	{
		coef = float3(vpos.xy, vpos.z + GridOffset.z);
	}
	else if (mode == 1)
	{
		coef = float3(vpos.zy, vpos.x + GridOffset.x);
		coef.x = (VOXEL_SIZE - 1) - coef.x;
	}
	else
	{
		coef = float3(vpos.zx, vpos.y + GridOffset.y);
	}

	float w = coef.z;
	float wl = w % VOXEL_SIZE_SQRT;
	float wh0 = floor(w / VOXEL_SIZE_SQRT) % VOXEL_SIZE_SQRT;
	float wh = VOXEL_SIZE_SQRT - wh0; // - 1;
	// MEMO: index�ɉ����ĈӐ}�I�ɉ��s���ʒu��������?
	float u = coef.x * VOXEL_SIZE_SQRT + wl;
	float v = coef.y * VOXEL_SIZE_SQRT + wh;

	// ��ʊO?
	float isInRange = (clamp(vpos.x, 0, VOXEL_SIZE - 1) == vpos.x)
					* (clamp(vpos.y, 0, VOXEL_SIZE - 1) == vpos.y)
					* (clamp(vpos.z, 0, VOXEL_SIZE - 1) == vpos.z);
	// if (mode!=0) isInRange = 0;

	Out.Pos = float4(float2(u, v) * INV_2D_VOXEL_SIZE * 2 - 1, 1, isInRange);
	// 1�̃e�N�X�`����3�ɕ����B3�ʐ}�̂��ꂼ���`�悷��
	Out.Pos.y = (Out.Pos.y + (3 - mode * 2) * Out.Pos.w) * (1.0 / 4.0);

	// �{�N�Z���O���b�h����p�̏��
	Out.GridPos.x = (wh0 * VOXEL_SIZE_SQRT + wl) * 4 + mode;
	Out.GridPos.y = index2 % 64;
	Out.GridPos.z = floor(index2 / 64);

	Out.Normal = normalize( mul( Normal, (float3x3)matW ) );
	Out.Tex = Tex;

	return Out;
}

// �s�N�Z���V�F�[�_
PS_OUT_MRT DrawPoint_PS(BufferShadow_OUTPUT IN, uniform bool useTexture)
{
	int gridDist = IN.GridPos.y;
	int hit8 = gridDist;
	int hit4 = (gridDist % 4 + (gridDist / 8) % 4);
	int hit2 = (gridDist % 2 + (gridDist / 8) % 2);
	// �O���b�h���ł̈ʒu�ɉ����ėD��x������B
	float priority = (hit8 != 0) + (hit4 != 0) + (hit2 != 0);
	// �D��x�������قǎ�O�ɕ\������B
	float depth = (priority * 256.0 + (IN.GridPos.z % 256)) * (1.0 / (256*4));
	// �����{�N�Z�����ʗp��id
	int patternNo = IN.GridPos.x;

	float4 Color = DiffuseColor;
	if ( useTexture ) {
		// �e�N�X�`���K�p
		float4 TexColor = tex2D( ObjTexSampler, IN.Tex );
		// �ގ����[�t�Ή�
		float4 MorphColor = TexColor * TextureMulValue + TextureAddValue;
		float MorphRate = TextureMulValue.a + TextureAddValue.a;
		TexColor.rgb = lerp(1, MorphColor, MorphRate).rgb;
		Color *= TexColor;
	}

	clip(Color.a - AlphaThreshold);

	float emissiveIntensity = 0;
	#if defined(FORCE_EMISSIVE)
		emissiveIntensity = rgb2gray(Color.rgb);
	#else
		emissiveIntensity = opadd ? rgb2gray(Color.rgb) : emissiveIntensity;
	#endif
	int attribute = floor(saturate(emissiveIntensity) * 127) * 2 + (opadd ? 0 : 1);

	Color.rgb = Degamma(Color.rgb);
	Color.a = attribute * (1.0 / 255.0);

	PS_OUT_MRT Out;
	Out.Color = Color;
	Out.Normal = float4(normalize(IN.Normal), patternNo);
	Out.Depth = 0;

	return Out;
}

#define	RENDER_MODE_SETTINGS	AlphaTestEnable = FALSE; AlphaBlendEnable = FALSE; FillMode = Point;

#define OBJECT_TEC_POINT(name, mmdpass, tex) \
	technique name < string MMDPass = mmdpass; \
	string Script = \
		"RenderColorTarget0=; " \
		"RenderColorTarget1=VoxelPackNormal;" \
		"Pass=DrawObject;" \
		"RenderColorTarget1=;" \
	; \
	> { \
		pass DrawObject { \
			RENDER_MODE_SETTINGS \
			VertexShader = compile vs_3_0 DrawPoint_VS(tex); \
			PixelShader  = compile ps_3_0 DrawPoint_PS(tex); \
		} \
	}

OBJECT_TEC_POINT(PointTec0, "object", use_texture)
OBJECT_TEC_POINT(PointTecBS0, "object_ss", use_texture)


///////////////////////////////////////////////////////////////////////////////////////////////
