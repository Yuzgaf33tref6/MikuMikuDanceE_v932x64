////////////////////////////////////////////////////////////////////////////////////////////////
//
//
////////////////////////////////////////////////////////////////////////////////////////////////
// �p�����[�^�錾

// �u���b�N�̃T�C�Y�B0.1�`1.0���x�B
float VoxelGridSize = 0.5;

// �e�N�X�`���̉𑜓x��������B8�`32���x�B
// 8�Ńe�N�X�`����8��������B�������قǑe���Ȃ�B
float VoxelTextureGridSize = 16;

// �������铧���x��臒l
float VoxelAlphaThreshold = 0.05;

// �u���b�N��`�悷��Ƃ����������l������?
// 0:�s�����ŕ`��A1:�������x�𗘗p����B
#define VOXEL_ENBALE_ALPHA_BLOCK	1

// �u���b�N�̃t�`���ۂ߂邩? 0.0�`0.1���x �傫���قǃG�b�W���������������
// �� 0�ɂ��Ă��v�Z�덷�ŃG�b�W��������ꍇ������܂��B
float VoxelBevelOffset = 0.05;

// �`�F�b�N�񐔁B4�`16���x�B�����قǉ����܂Ō������邪�A�d���Ȃ�B
#define VOXEL_ITERATION_NUMBER	6

// �O������u���b�N�T�C�Y���R���g���[������A�N�Z�T����
#define VOXEL_CONTROLLER_NAME	"ikiVoxelSize.x"

// �u���b�N�\�ʂɃe�N�X�`����ǉ�����ꍇ�̃e�N�X�`�����B
// �R�����g�A�E�g(�s����"//"������)����Ɩ����ɂȂ�B
#define VOXEL_TEXTURE	"grid.png"

// �t�������`�F�b�N������? 0:���Ȃ��A1:�`�F�b�N����B
// 1�ɂ��邱�Ƃŏ���������̂�����ł���B����Ɍ����ڂ����������Ȃ�B
#define VOXEL_ENABLE_FALLOFF		0


////////////////////////////////////////////////////////////////////////////////////////////////

// ���@�ϊ��s��
float4x4 matWVP			: WORLDVIEWPROJECTION;
float4x4 matWV			: WORLDVIEW;
float4x4 matVP			: VIEWPROJECTION;
float4x4 matW			: WORLD;
float4x4 matV			: VIEW;
float4x4 matP			: PROJECTION;

float4x4 matLightVP		: VIEWPROJECTION < string Object = "Light"; >;
float3   LightDirection	: DIRECTION < string Object = "Light"; >;

float3   CameraPosition	: POSITION  < string Object = "Camera"; >;
float3   CameraDirection : DIRECTION  < string Object = "Camera"; >;

// �}�e���A���F
float4	MaterialDiffuse		: DIFFUSE  < string Object = "Geometry"; >;
float3	MaterialAmbient		: AMBIENT  < string Object = "Geometry"; >;
float3	MaterialEmissive	: EMISSIVE < string Object = "Geometry"; >;
float3	MaterialSpecular	: SPECULAR < string Object = "Geometry"; >;
float	SpecularPower		: SPECULARPOWER < string Object = "Geometry"; >;
float3	MaterialToon		: TOONCOLOR;
float4	GroundShadowColor	: GROUNDSHADOWCOLOR;

// ���C�g�F
float3   LightDiffuse      : DIFFUSE   < string Object = "Light"; >;
float3   LightAmbient      : AMBIENT   < string Object = "Light"; >;
float3   LightSpecular     : SPECULAR  < string Object = "Light"; >;

// �ގ����[�t�Ή�
float4	TextureAddValue   : ADDINGTEXTURE;
float4	TextureMulValue   : MULTIPLYINGTEXTURE;
float4	SphereAddValue    : ADDINGSPHERETEXTURE;
float4	SphereMulValue    : MULTIPLYINGSPHERETEXTURE;

static float4 DiffuseColor  = MaterialDiffuse * float4(LightDiffuse, 1.0f);
static float3 AmbientColor  = MaterialAmbient * LightAmbient + MaterialEmissive;
static float3 SpecularColor = MaterialSpecular * LightSpecular;

float2 ViewportSize : VIEWPORTPIXELSIZE;

bool	use_texture;
bool	use_spheremap;
bool	use_toon;
bool	parthf;		// �p�[�X�y�N�e�B�u�t���O
bool	spadd;		// �X�t�B�A�}�b�v���Z�����t���O
#define SKII1	1500
#define SKII2	8000
#define Toon	 3

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

#define VOXEL_ENABLE_OUPUT_COLOR
#include "vox_commons.fxsub"



////////////////////////////////////////////////////////////////////////////////////////////////
//

// �f�B�t���[�Y�̌v�Z
inline float CalcDiffuse(float3 L, float3 N)
{
	return saturate(dot(N,L));
}

// �X�y�L�����̌v�Z
inline float CalcSpecular(float3 L, float3 N, float3 V)
{
	float3 H = normalize(L + V);
	return pow( max(0,dot( H, N )), SpecularPower );
}


////////////////////////////////////////////////////////////////////////////////////////////////
// �֊s�`��

technique EdgeTec < string MMDPass = "edge"; > {}


///////////////////////////////////////////////////////////////////////////////////////////////
// �e�i��Z���t�V���h�E�j�`��

float4 Shadow_VS(float4 Pos : POSITION) : POSITION
{
	// matW ���␳�� matVP���Ƃ��������Ȃ�̂œK���ɏ���
	// �A�N�Z�T����10�{����Ă���̂ŁAVoxelGridSize��1/10����K�v�����邪���ɂȂɂ����Ă��Ȃ�
	Pos.xyz = AlignPosition(Pos.xyz);
	return mul( Pos, matWVP );
}

float4 Shadow_PS() : COLOR
{
	return GroundShadowColor;
}

technique ShadowTec < string MMDPass = "shadow"; > {
	pass DrawShadow {
		VertexShader = compile vs_2_0 Shadow_VS();
		PixelShader  = compile ps_2_0 Shadow_PS();
	}
}


///////////////////////////////////////////////////////////////////////////////////////////////
// �Z���t�V���h�E�pZ�l�v���b�g

struct VS_ZValuePlot_OUTPUT {
	float4 Pos : POSITION;				// �ˉe�ϊ����W
	float4 ShadowMapTex : TEXCOORD0;	// Z�o�b�t�@�e�N�X�`��
};

VS_ZValuePlot_OUTPUT ZValuePlot_VS( float4 Pos : POSITION, float3 Normal : NORMAL, float2 Tex : TEXCOORD0 )
{
	VS_ZValuePlot_OUTPUT Out = (VS_ZValuePlot_OUTPUT)0;

	Pos = mul( Pos, matW );
	Pos.xyz = AlignPosition(Pos.xyz);
	Out.Pos = mul( Pos, matLightVP );
	Out.ShadowMapTex = Out.Pos;
	return Out;
}

float4 ZValuePlot_PS( float4 ShadowMapTex : TEXCOORD0, float2 Tex : TEXCOORD1 ) : COLOR
{
	return float4(ShadowMapTex.z/ShadowMapTex.w,0,0,1);
}

technique ZplotTec < string MMDPass = "zplot"; > {
	pass ZValuePlot {
		AlphaBlendEnable = FALSE;
		VertexShader = compile vs_2_0 ZValuePlot_VS();
		PixelShader  = compile ps_2_0 ZValuePlot_PS();
	}
}


///////////////////////////////////////////////////////////////////////////////////////////////
// �I�u�W�F�N�g�`��i�Z���t�V���h�EON�j

// �V���h�E�o�b�t�@�̃T���v���B"register(s0)"�Ȃ̂�MMD��s0���g���Ă��邩��
sampler DefSampler : register(s0);

struct BufferShadow_OUTPUT
{
	float4 Pos		: POSITION;	 // �ˉe�ϊ����W
	float2 Tex		: TEXCOORD1;	// �e�N�X�`��
	float3 Normal   : TEXCOORD2;	// �@��
	float4 Distance	: TEXCOORD3;
	float4 WPos		: TEXCOORD4;	// Z�l
};

///////////////////////////////////////////////////////////////////////////////////////////////
// �u���b�N�P�ʂŐF��h�邽�߂̏����o�͂���
BufferShadow_OUTPUT DrawInfo_VS(float4 Pos : POSITION, float3 Normal : NORMAL, float2 Tex : TEXCOORD0)
{
	BufferShadow_OUTPUT Out = (BufferShadow_OUTPUT)0;
	Out.Pos = mul( Pos, matWVP );
	Out.Distance = mul( Pos, matWV );
	Out.Tex = Tex;
	return Out;
}

float4 DrawInfo_PS(BufferShadow_OUTPUT IN) : COLOR
{
	float4 Color = float4(1,1,1, DiffuseColor.a);
	if ( use_texture ) {
		// �e�N�X�`���K�p
		float4 TexColor = tex2D( ObjTexSampler, AlignTexture(IN.Tex) );
		if (use_toon)
		{	// �ގ����[�t�Ή�
			float4 MorphColor = TexColor * TextureMulValue + TextureAddValue;
			float MorphRate = TextureMulValue.a + TextureAddValue.a;
			TexColor.rgb = lerp(1, MorphColor.rgb, MorphRate);
		}

		Color *= TexColor;
	}

	clip(Color.w - VoxelAlphaThreshold);
	Color.a = IN.Distance.z;

	return Color;
}


///////////////////////////////////////////////////////////////////////////////////////////////
// �u���b�N�Ƀq�b�g���邩���ׂȂ���`�悷��

BufferShadow_OUTPUT DrawObject_VS(float4 Pos : POSITION, float3 Normal : NORMAL, float2 Tex : TEXCOORD0,
	uniform bool bExpand)
{
	BufferShadow_OUTPUT Out = (BufferShadow_OUTPUT)0;

	Out.WPos = mul( Pos, matW );
	Out.Normal = normalize( mul( Normal, (float3x3)matW ) );

	if (bExpand)
	{
		// �@�������Ɋg��
		float3 vNormal = normalize(Out.Normal - dot(Out.Normal, CameraDirection));
		Out.WPos.xyz += vNormal * VoxelScaledGridSize;
	}

	Out.Pos = mul( Out.WPos, matVP );

	Out.Distance.x = mul(Out.WPos, matV).z;
	Out.Distance.yz = mul(float4(0,VoxelScaledGridSize,Out.Distance.x,1), matP).yw;
	Out.Distance.y *= ViewportSize.y * 0.5 / 2.0;

	Out.Tex = Tex;

	return Out;
}


// �s�N�Z���V�F�[�_
float4 DrawObject_PS(BufferShadow_OUTPUT IN, uniform bool useSelfShadow) : COLOR
{
	#if defined(VOXEL_ENBALE_ALPHA_BLOCK) && VOXEL_ENBALE_ALPHA_BLOCK > 0
	// �����Ȃ�j��
	float alpha = DiffuseColor.a;
	if ( use_texture ) alpha *= tex2D( ObjTexSampler, AlignTexture(IN.Tex)).a;
	clip(alpha - VoxelAlphaThreshold);
	#endif

	float3 V = AdjustVector(normalize(CameraPosition - IN.WPos.xyz));
	float3 N = IN.Normal;

	//-----------------------------------------------------------
	// �ǂ̃u���b�N�Ƀq�b�g���邩�T��
	float3 hitblock = 0;
	float4 albedo = Raytrace(IN.WPos, -V, hitblock);

	clip(albedo.w - 1e-3); // �q�b�g���Ȃ�����

	float3 hitpos = CalcPositionAndNormal(hitblock, N, V, IN.Distance.z / IN.Distance.y);

	#if defined(VOXEL_TEXTURE)
	float2 griduv = CalcUV(N, hitpos * (1.0 / VoxelScaledGridSize));
	float3 gridPattern = tex2D( VoxelPatternSmp, griduv).rgb;
	albedo.rgb *= gridPattern;
	#endif

/*
return float4(frac((hitpos+10)*0.5),1);
return float4(frac((hitblock+10)*0.5),1);
*/

	// �������[�x���o�͂���ƁA�v�Z�덷����]�v��z�t�@�C�g��������
	// float4 hitPPos = mul(float4(hitpos,1), matVP);
	// float depth = hitPPos.z / hitPPos.w;

	//-----------------------------------------------------------
	// �����v�Z
	float3 L = -LightDirection;
	float diffuse = CalcDiffuse(L, N);
	if (use_toon) diffuse = saturate(diffuse * Toon);
	float3 specular = CalcSpecular(L, N, V) * SpecularColor;

	float4 Color = float4(AmbientColor.rgb, 1);
	if ( !use_toon ) Color.rgb += DiffuseColor.rgb;
	float3 ShadowColor = saturate(AmbientColor);
	Color.rgb = Color.rgb * albedo.rgb + specular;
	ShadowColor = ShadowColor * albedo.rgb + specular;

	// �V���h�E�}�b�v
	float comp = 1;
	if (useSelfShadow)
	{
		// �e�N�X�`�����W�ɕϊ�
		float4 ZCalcTex = mul( float4(hitpos,1), matLightVP );
		ZCalcTex /= ZCalcTex.w;
		float2 TransTexCoord;
		TransTexCoord.x = (1.0f + ZCalcTex.x)*0.5f;
		TransTexCoord.y = (1.0f - ZCalcTex.y)*0.5f;
		if( any( saturate(TransTexCoord) != TransTexCoord ) ) {
			// �V���h�E�o�b�t�@�O
			;
		} else {
			float a = (parthf) ? SKII2*TransTexCoord.y : SKII1;
			float d = ZCalcTex.z;
			comp = 1 - saturate(max(d - tex2D(DefSampler,TransTexCoord).r , 0.0f)*a-0.3f);
		}
	}

	comp = min(diffuse, comp);

	if ( use_spheremap ) {
		// �X�t�B�A�}�b�v�K�p
		// N���̂܂܂��Ɠ�������̖ʑS�Ă������F�ɂȂ�̂œK���ɕ␳
		float2 NormalWV = normalize(mul( reflect(N,V), (float3x3)matV)).xy;
		float2 SpTex = NormalWV * float2(0.5,-0.5) + 0.5;

		float3 TexColor = tex2D(ObjSphareSampler,SpTex).rgb;
		if (useSelfShadow && use_toon)
		{	// �ގ����[�t�Ή�
			float3 MorphColor = TexColor * SphereMulValue.rgb + SphereAddValue.rgb;
			float MorphRate = saturate(SphereMulValue.a + SphereAddValue.a);
			TexColor.rgb = lerp(spadd?0:1, MorphColor, MorphRate);
		}

		if(spadd) {
			Color.rgb += TexColor;
			ShadowColor.rgb += TexColor;
		} else {
			Color.rgb *= TexColor;
			ShadowColor.rgb *= TexColor;
		}
	}

	if ( use_toon ) ShadowColor.rgb *= MaterialToon;
	Color.rgb = lerp(ShadowColor, Color.rgb, comp);

	#if defined(VOXEL_ENBALE_ALPHA_BLOCK) && VOXEL_ENBALE_ALPHA_BLOCK > 0
	Color.a = alpha;
	#else
	Color.a = 1;
	#endif

	return Color;
}

#define OBJECT_TEC(name, mmdpass, selfshadow) \
	technique name < string MMDPass = mmdpass; bool UseSelfShadow = selfshadow;\
	string Script = \
		"RenderColorTarget0=VoxelInfoTex; RenderDepthStencilTarget=VoxelDepthBuffer;" \
		"ClearSetColor=VoxelClearColor; ClearSetDepth=VoxelClearDepth; Clear=Color; Clear=Depth;" \
		"Pass=DrawInfo;" \
		"RenderColorTarget0=; RenderDepthStencilTarget=;" \
		"Pass=DrawFalloff; Pass=DrawObject;" \
; \
	> { \
		pass DrawInfo { \
			AlphaBlendEnable = false; AlphaTestEnable = false; \
			VertexShader = compile vs_3_0 DrawInfo_VS(); \
			PixelShader  = compile ps_3_0 DrawInfo_PS(); \
		} \
		pass DrawFalloff { /* �g�傷��ƌ����J�����Ƃ�����̂ŔO�̂��߂� */ \
			VertexShader = compile vs_3_0 DrawObject_VS(false); \
			PixelShader  = compile ps_3_0 DrawObject_PS(selfshadow); \
		} \
		pass DrawObject { \
			CullMode = none; \
			VertexShader = compile vs_3_0 DrawObject_VS(true); \
			PixelShader  = compile ps_3_0 DrawObject_PS(selfshadow); \
		} \
	}

OBJECT_TEC(MainTec0, "object", false)
OBJECT_TEC(MainTecBS0, "object_ss", true)

////////////////////////////////////////////////////////////////////////////////////////////////
