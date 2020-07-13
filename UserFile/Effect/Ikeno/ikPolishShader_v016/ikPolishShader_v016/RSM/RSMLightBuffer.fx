////////////////////////////////////////////////////////////////////////////////////////////////
//
//
////////////////////////////////////////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////////////////////////////////////////
// �p�����[�^�錾

#include "../ikPolishShader.fxsub"
#include "../Sources/mmdutil.fxsub"
#include "../Sources/colorutil.fxsub"

//-----------------------------------------------------------------------------
//

float3 TargetPosition : CONTROLOBJECT < string name = "(OffscreenOwner)"; >;
float3 LightDirection	: DIRECTION < string Object = "Light"; >;

#include	"rsm_common.fxsub"


//-----------------------------------------------------------------------------



// ���@�ϊ��s��
float4x4 matW			: WORLD;
static float4x4 lightMatWV = mul(matW, lightMatV);
static float4x4 lightMatWVP = mul(lightMatWV, lightMatP);

shared texture PPPRSMAlbedoMapRT : RENDERCOLORTARGET;

// �}�e���A���F
float4   MaterialDiffuse   : DIFFUSE  < string Object = "Geometry"; >;
static float4 DiffuseColor  = MaterialDiffuse;

////////////////////////////////////////////////////////////////////////////////////////////////

technique EdgeTec < string MMDPass = "edge"; > {}
technique ShadowTec < string MMDPass = "shadow"; > {}
technique ZplotTec < string MMDPass = "zplot"; > {}

///////////////////////////////////////////////////////////////////////////////////////////////
// �I�u�W�F�N�g�`��i�Z���t�V���h�EON�j

struct DrawObject_OUTPUT {
    float4 Pos      : POSITION;     // �ˉe�ϊ����W
    float2 Tex      : TEXCOORD0;    // �e�N�X�`��
	float Distance	: TEXCOORD1;
	float3 Normal	: TEXCOORD2;

    float4 Color    : COLOR0;       // �f�B�t���[�Y�F
};

struct PS_OUT_MRT
{
	float4 Normal		: COLOR0;
	float4 Color		: COLOR1;
};


// ���_�V�F�[�_
DrawObject_OUTPUT DrawObject_VS(float4 Pos : POSITION, float3 Normal : NORMAL, float2 Tex : TEXCOORD0, uniform bool useTexture)
{
    DrawObject_OUTPUT Out = (DrawObject_OUTPUT)0;

    Out.Pos = mul( Pos, lightMatWVP );
	Out.Distance = mul(Pos, lightMatWV).z;
	Out.Normal = mul(Normal, (float3x3)matW);

    Out.Tex = Tex;

    return Out;
}

// �s�N�Z���V�F�[�_
PS_OUT_MRT DrawObject_PS(DrawObject_OUTPUT IN, uniform bool useTexture)
{
	float4 Color = DiffuseColor;
	if ( useTexture ) {
		Color *= GetTextureColor(IN.Tex.xy);
	}

	clip(Color.a - AlphaThreshold);

	float3 N = normalize(IN.Normal.xyz);

	#if defined(ENABLE_DOUBLE_SIDE_SHADOW) && ENABLE_DOUBLE_SIDE_SHADOW > 0
	float diffuse = dot(N,-LightDirection);
	// �������̃|���S����\�ɂ���
	//N = N * ((diffuse >= 0) ? 1 : -1);
	// �������̃|���S�����A�ɂ���
	Color.rgb *= ((diffuse >= 0) ? 1 : 0);
	#endif

	PS_OUT_MRT Out;
	Out.Color = Degamma4(Color);
	Out.Normal = float4(N, IN.Distance);

	return Out;
}

#if defined(ENABLE_DOUBLE_SIDE_SHADOW) && ENABLE_DOUBLE_SIDE_SHADOW > 0
#define	SET_CULL_MODE		CullMode = NONE;
#else
#define	SET_CULL_MODE
#endif

#define OBJECT_TEC(name, mmdpass, tex, selfshadow) \
	technique name < string MMDPass = mmdpass; \
	string Script = \
		"RenderColorTarget0=;" \
		"RenderColorTarget1=PPPRSMAlbedoMapRT;" \
		"RenderDepthStencilTarget=;" \
		"Pass=DrawObject;" \
		"RenderColorTarget1=;" \
	; \
	> { \
		pass DrawObject { \
			AlphaBlendEnable = FALSE;	AlphaTestEnable = FALSE; \
			SET_CULL_MODE \
			VertexShader = compile vs_3_0 DrawObject_VS(tex); \
			PixelShader  = compile ps_3_0 DrawObject_PS(tex); \
		} \
	}

bool use_texture;

OBJECT_TEC(MainTec2, "object", use_texture, false)
OBJECT_TEC(MainTecBS2, "object_ss", use_texture, true)


///////////////////////////////////////////////////////////////////////////////////////////////
