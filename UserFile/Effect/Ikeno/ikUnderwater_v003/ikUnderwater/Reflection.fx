////////////////////////////////////////////////////////////////////////////////////////////////
//
// ���˗p�}�b�v���쐬
// ���ʂ̕\��������`�悷��B
//
// �j��P�� WF_Object.fxsub �������B
//
////////////////////////////////////////////////////////////////////////////////////////////////

#include "Settings.fxsub"
#include "Commons.fxsub"

///////////////////////////////////////////////////////////////////////////////////////////////
// ���ʍ��W�ϊ��p�����[�^

// ���[���h���W�n�ɂ����鋾���ʒu�ւ̕ϊ�
#define	WldMirrorPos	WaveObjectPosition
static float3 WldMirrorNormal = float3( 0.0, IsInWater ? -1.0 : 1.0, 0.0 );

// ���W�̋����ϊ�
float4 TransMirrorPos( float4 Pos )
{
//    Pos.xyz -= WldMirrorNormal * 2.0f * dot(WldMirrorNormal, Pos.xyz - WldMirrorPos);
    Pos.y -= (2.0 * (Pos.y - WldMirrorPos.y));
    return Pos;
}

// ���ʕ\������(���W�ƃJ�������������ʂ̕\���ɂ��鎞�����{)
float IsFace( float4 Pos )
{
/*
    return min( dot(Pos.xyz-WldMirrorPos, WldMirrorNormal),
                dot(CameraPosition-WldMirrorPos, WldMirrorNormal) );
*/
    return (Pos.y-WldMirrorPos.y) * WldMirrorNormal.y;
}

const float gamma = 2.2;
inline float3 Degamma(float3 col) { return pow(max(col,0), gamma); }
inline float3 Gamma(float3 col) { return pow(max(col,0), 1.0/gamma); }
inline float4 Degamma4(float4 col) { return float4(Degamma(col.rgb), col.a); }
inline float4 Gamma4(float4 col) { return float4(Gamma(col.rgb), col.a); }


///////////////////////////////////////////////////////////////////////////////////////////////

// ���W�ϊ��s��
float4x4 WorldMatrix              : WORLD;
float4x4 ViewMatrix               : VIEW;
float4x4 ProjMatrix               : PROJECTION;
float4x4 CalcViewProjMatrix(float4x4 v, float4x4 p)
{
	p._11_22 *= FrameScale;
	return mul(v, p);
}
static float4x4 ViewProjMatrix = CalcViewProjMatrix(ViewMatrix, ProjMatrix);

float4x4 LightWorldViewProjMatrix : WORLDVIEWPROJECTION < string Object = "Light"; >;

float3 MMDLightDirection : DIRECTION < string Object = "Light"; >;

// �}�e���A���F
float4 MaterialDiffuse   : DIFFUSE  < string Object = "Geometry"; >;
float3 MaterialAmbient   : AMBIENT  < string Object = "Geometry"; >;
float3 MaterialEmmisive  : EMISSIVE < string Object = "Geometry"; >;
float3 MaterialSpecular  : SPECULAR < string Object = "Geometry"; >;
float SpecularPower      : SPECULARPOWER < string Object = "Geometry"; >;
float3 MaterialToon      : TOONCOLOR;

// ���C�g�F
float3 LightDiffuse   : DIFFUSE   < string Object = "Light"; >;
float3 LightAmbient   : AMBIENT   < string Object = "Light"; >;
float3 LightSpecular  : SPECULAR  < string Object = "Light"; >;
static float4 DiffuseColor  = MaterialDiffuse  * float4(LightDiffuse, 1.0f);
static float3 AmbientColor  = MaterialAmbient  * LightAmbient + MaterialEmmisive;
static float3 SpecularColor = MaterialSpecular * LightSpecular;

// �e�N�X�`���ގ����[�t�l
float4 TextureAddValue  : ADDINGTEXTURE;
float4 TextureMulValue  : MULTIPLYINGTEXTURE;
float4 SphereAddValue   : ADDINGSPHERETEXTURE;
float4 SphereMulValue   : MULTIPLYINGSPHERETEXTURE;

bool parthf;   // �p�[�X�y�N�e�B�u�t���O
bool transp;   // �������t���O
bool spadd;    // �X�t�B�A�}�b�v���Z�����t���O
#define SKII1  1500
#define SKII2  8000
#define Toon   3

// �V���h�E�o�b�t�@�̃T���v���B"register(s0)"�Ȃ̂�MMD��s0���g���Ă��邩��
sampler DefSampler : register(s0);

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

// �X�t�B�A�}�b�v�̃e�N�X�`��
texture ObjectSphereMap: MATERIALSPHEREMAP;
sampler ObjSphareSampler = sampler_state {
    texture = <ObjectSphereMap>;
    MINFILTER = POINT;
    MAGFILTER = POINT;
    MIPFILTER = NONE;
    AddressU  = CLAMP;
    AddressV = CLAMP;
};

///////////////////////////////////////////////////////////////////////////////////////////////
// �I�u�W�F�N�g�`��i�Z���t�V���h�EOFF�j

struct VS_OUTPUT {
    float4 Pos       : POSITION;    // �ˉe�ϊ����W
    float4 ZCalcTex  : TEXCOORD0;   // Z�l
    float4 Tex       : TEXCOORD1;   // �e�N�X�`��
    float3 Normal    : TEXCOORD2;   // �@��
    float3 Eye       : TEXCOORD3;   // �J�����Ƃ̑��Έʒu
    float2 SpTex     : TEXCOORD4;   // �X�t�B�A�}�b�v�e�N�X�`�����W
    float4 WPos      : TEXCOORD5;   // ���������f���̃��[���h���W
    float4 MWPos     : TEXCOORD6;   // ��������̃��[���h���W
    float4 Color     : COLOR0;      // �f�B�t���[�Y�F
};

// ���_�V�F�[�_(�������])
VS_OUTPUT BasicMirror_VS(float4 pos : POSITION, float3 Normal : NORMAL, float2 Tex : TEXCOORD0,
	uniform bool useTexture, uniform bool useSphereMap, uniform bool useToon)
{
    VS_OUTPUT Out = (VS_OUTPUT)0;

    // ���C�g���_�ɂ�郏�[���h�r���[�ˉe�ϊ�(����������������Ă��邱�Ƃ��l��)
    Out.ZCalcTex = mul( pos, LightWorldViewProjMatrix );

    // ���[���h���W�ϊ�
    pos = mul( pos, WorldMatrix );
    Out.WPos = pos; // ���[���h���W

    // �J�����Ƃ̑��Έʒu(����������������Ă��邱�Ƃ��l��)
    Out.Eye = CameraPosition - pos.xyz;

    // �����ʒu�ւ̍��W�ϊ�
    pos = TransMirrorPos( pos ); // �����ϊ�
	Out.MWPos = pos;

    // �J�������_�̃r���[�ˉe�ϊ�
    Out.Pos = mul( pos, ViewProjMatrix );
    Out.Pos.x = -Out.Pos.x; // �|���S�������Ԃ�Ȃ��悤�ɍ��E���]�ɂ��ĕ`��

    // ���_�@��(����������������Ă��邱�Ƃ��l��)
    Out.Normal = normalize( mul( Normal, (float3x3)WorldMatrix ) );
    
    Out.Tex.xy = Tex; //�e�N�X�`��UV
 
   // �f�B�t���[�Y�F�{�A���r�G���g�F �v�Z
    Out.Color.rgb = AmbientColor;
    if ( !useToon ) {
        Out.Color.rgb += max(0, dot( Out.Normal, -MMDLightDirection )) * DiffuseColor.rgb;
    }
    Out.Color.a = DiffuseColor.a;
    Out.Color = saturate( Out.Color );

    if ( useSphereMap ) {
            // �X�t�B�A�}�b�v�e�N�X�`�����W(�O���������₷���Ȃ�̂ŏ����␳)
            float2 NormalWV = mul( Out.Normal, (float3x3)ViewMatrix ).xy * 0.99f;
            Out.SpTex.x = NormalWV.x * 0.5f + 0.5f;
            Out.SpTex.y = NormalWV.y * -0.5f + 0.5f;
    }

    return Out;
}


float CalcShdow(float4 ZCalcTex)
{
	float comp = 1;

    // �e�N�X�`�����W�ɕϊ�
    ZCalcTex /= ZCalcTex.w;
    float2 TransTexCoord;
    TransTexCoord.x = (1.0f + ZCalcTex.x)*0.5f;
    TransTexCoord.y = (1.0f - ZCalcTex.y)*0.5f;
    if( any( saturate(TransTexCoord) - TransTexCoord ) ) {
        // �V���h�E�o�b�t�@�O
        ;
    } else {
        if(parthf) {
            // �Z���t�V���h�E mode2
            comp=1-saturate(max(ZCalcTex.z-tex2D(DefSampler,TransTexCoord).r , 0.0f)*SKII2*TransTexCoord.y-0.3f);
        } else {
            // �Z���t�V���h�E mode1
            comp=1-saturate(max(ZCalcTex.z-tex2D(DefSampler,TransTexCoord).r , 0.0f)*SKII1-0.3f);
        }
    }

	return comp;
}

// �s�N�Z���V�F�[�_
float4 Basic_PS(VS_OUTPUT IN, uniform bool useTexture, uniform bool useSphereMap, uniform bool useToon, uniform bool useSelfshadow) : COLOR0
{
    // ���ʂ̗����ɂ��镔�ʂ͋����\�����Ȃ�
    clip( IsFace( IN.WPos ) );

    float4 Color = IN.Color;
    float4 ShadowColor = float4(saturate(AmbientColor), Color.a);  // �e�̐F
    
    if(useTexture){
        // �e�N�X�`���K�p
        float4 TexColor = tex2D(ObjTexSampler,IN.Tex.xy);
        // �e�N�X�`���ގ����[�t��
        TexColor.rgb = lerp(1, TexColor * TextureMulValue + TextureAddValue, TextureMulValue.a + TextureAddValue.a).rgb;
        Color *= TexColor;
        ShadowColor *= TexColor;
    }

	// �X�y�L�����F�v�Z
	float3 HalfVector = normalize( normalize(IN.Eye) + -MMDLightDirection );
	float3 Specular = pow( max(0,dot( HalfVector, normalize(IN.Normal) )), SpecularPower ) * SpecularColor;

    if ( useSphereMap ) {
        // �X�t�B�A�}�b�v�K�p
        float4 TexColor = tex2D(ObjSphareSampler,IN.SpTex);
        // �X�t�B�A�e�N�X�`���ގ����[�t��
        TexColor.rgb = lerp(spadd?0:1, TexColor * SphereMulValue + SphereAddValue, SphereMulValue.a + SphereAddValue.a).rgb;
        if(spadd) {
            Color.rgb += TexColor.rgb;
            ShadowColor.rgb += TexColor.rgb;
        } else {
            Color.rgb *= TexColor.rgb;
            ShadowColor.rgb *= TexColor.rgb;
        }
        Color.a *= TexColor.a;
        ShadowColor.a *= TexColor.a;
    }

	// �X�y�L�����K�p
	Color.rgb += Specular;

	float comp = (useSelfshadow) ? CalcShdow(IN.ZCalcTex) : 1.0;

	if ( useToon ) {
		// �g�D�[���K�p
		comp = min(saturate(dot(IN.Normal,-MMDLightDirection)*Toon),comp);
		ShadowColor.rgb *= MaterialToon;
	}

	Color = lerp(ShadowColor, Color, comp);

	// �����t�H�O
	if (IsInWater)
	{
		// �J�����`���ʂ܂ł̃t�H�O�̓��C�����Œǉ�����̂ŁA
		// ���ʁ`���f���܂ł̃t�H�O���v�Z����B
		float3 mpos = IN.MWPos.xyz;
		float3 mv = normalize(mpos-CameraPosition);
		float t = max(DistanceToWater(CameraPosition, mv),0);
		float thickness = max(distance(mpos, CameraPosition) - t, 0);
		Color.rgb = CalcFogColor(Degamma(Color.rgb), thickness);
		Color *= CalcDepthFog(mv, thickness);
		Color.rgb = Gamma(Color.rgb);
	}

	return float4(Color.rgb, Color.a);
}



#define OBJECT_TEC(name, mmdpass, tex, sphere, toon, selfshadow) \
	technique name < string MMDPass = mmdpass; bool UseTexture = tex; bool UseSphereMap = sphere; bool UseToon = toon;  bool UseSelfShadow = selfshadow;\
	> { \
		pass DrawObject { \
			VertexShader = compile vs_3_0 BasicMirror_VS(tex, sphere, toon); \
			PixelShader  = compile ps_3_0 Basic_PS(tex, sphere, toon, selfshadow); \
		} \
	}

OBJECT_TEC(MainTec0, "object", false, false, false, false)
OBJECT_TEC(MainTec1, "object", true, false, false, false)
OBJECT_TEC(MainTec2, "object", false, true, false, false)
OBJECT_TEC(MainTec3, "object", true, true, false, false)
OBJECT_TEC(MainTec4, "object", false, false, true, false)
OBJECT_TEC(MainTec5, "object", true, false, true, false)
OBJECT_TEC(MainTec6, "object", false, true, true, false)
OBJECT_TEC(MainTec7, "object", true, true, true, false)

OBJECT_TEC(MainTecBS0, "object_ss", false, false, false, true)
OBJECT_TEC(MainTecBS1, "object_ss", true, false, false, true)
OBJECT_TEC(MainTecBS2, "object_ss", false, true, false, true)
OBJECT_TEC(MainTecBS3, "object_ss", true, true, false, true)
OBJECT_TEC(MainTecBS4, "object_ss", false, false, true, true)
OBJECT_TEC(MainTecBS5, "object_ss", true, false, true, true)
OBJECT_TEC(MainTecBS6, "object_ss", false, true, true, true)
OBJECT_TEC(MainTecBS7, "object_ss", true, true, true, true)


technique EdgeTec < string MMDPass = "edge"; > {}
technique ShadowTec < string MMDPass = "shadow"; > {}
technique ZplotTec < string MMDPass = "zplot"; > {}


///////////////////////////////////////////////////////////////////////////////////////////////
