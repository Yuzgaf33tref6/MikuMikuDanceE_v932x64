////////////////////////////////////////////////////////////////////////////////////////////////
//
//  full.fx����M�������̂��A����ɘM�������́B
//	ikPointColor�p�ɍ��R���g���X�g�̊G�����B�P�Ƃł̎g�p�͑z�肵�Ă��Ȃ��B
//
////////////////////////////////////////////////////////////////////////////////////////////////
// �p�����[�^�錾

// �g�D�[���J���[���ɋ����I�ɉe�̐F��Z������B1�Œʏ�ʂ�A�傫�����l�قǉe���Z���Ȃ�B
#define	ToonContrastPower		16

// �������C�g�̋����B�������C�g�ɂ���č����ׂꂽ�����ɔ����֊s�����o��B
#define	RimLightPower		8			// �傫���قǁA�����ׂ��Ȃ�
#define	RimLightIntensity	1.0			// �������C�g�̋����B0�Ŗ����A1�Ő^�����ɂȂ�B




/////////////////////////////////////////////////////////////////////////////////////////
// �� ExcellentShadow�V�X�e���@�������火

float X_SHADOWPOWER = 1.0;   //�A�N�Z�T���e�Z��
float PMD_SHADOWPOWER = 0.2; //���f���e�Z��

//�X�N���[���V���h�E�}�b�v�擾
shared texture2D ScreenShadowMapProcessed : RENDERCOLORTARGET <
    float2 ViewPortRatio = {1.0,1.0};
    int MipLevels = 1;
    string Format = "D3DFMT_R16F";
>;
sampler2D ScreenShadowMapProcessedSamp = sampler_state {
    texture = <ScreenShadowMapProcessed>;
    MinFilter = LINEAR; MagFilter = LINEAR; MipFilter = NONE;
    AddressU  = CLAMP; AddressV = CLAMP;
};

//SSAO�}�b�v�擾
shared texture2D ExShadowSSAOMapOut : RENDERCOLORTARGET <
    float2 ViewPortRatio = {1.0,1.0};
    int MipLevels = 1;
    string Format = "R16F";
>;

sampler2D ExShadowSSAOMapSamp = sampler_state {
    texture = <ExShadowSSAOMapOut>;
    MinFilter = LINEAR; MagFilter = LINEAR; MipFilter = NONE;
    AddressU  = CLAMP; AddressV = CLAMP;
};

// �X�N���[���T�C�Y
float2 ES_ViewportSize : VIEWPORTPIXELSIZE;
static float2 ES_ViewportOffset = (float2(0.5,0.5)/ES_ViewportSize);

bool Exist_ExcellentShadow : CONTROLOBJECT < string name = "ExcellentShadow.x"; >;
bool Exist_ExShadowSSAO : CONTROLOBJECT < string name = "ExShadowSSAO.x"; >;
float ShadowRate : CONTROLOBJECT < string name = "ExcellentShadow.x"; string item = "Tr"; >;
float3   ES_CameraPos1      : POSITION  < string Object = "Camera"; >;
float es_size0 : CONTROLOBJECT < string name = "ExcellentShadow.x"; string item = "Si"; >;
float4x4 es_mat1 : CONTROLOBJECT < string name = "ExcellentShadow.x"; >;

static float3 es_move1 = float3(es_mat1._41, es_mat1._42, es_mat1._43 );
static float CameraDistance1 = length(ES_CameraPos1 - es_move1); //�J�����ƃV���h�E���S�̋���

// �� ExcellentShadow�V�X�e���@�����܂Ł�
/////////////////////////////////////////////////////////////////////////////////////////

// ���@�ϊ��s��
float4x4 WorldViewProjMatrix		: WORLDVIEWPROJECTION;
float4x4 WorldViewMatrix		: WORLDVIEW;
float4x4 WorldMatrix				: WORLD;
float4x4 ViewMatrix				: VIEW;
float4x4 LightWorldViewProjMatrix : WORLDVIEWPROJECTION < string Object = "Light"; >;

float3   LightDirection	: DIRECTION < string Object = "Light"; >;
float3   CameraPosition	: POSITION  < string Object = "Camera"; >;

// �}�e���A���F
float4   MaterialDiffuse   : DIFFUSE  < string Object = "Geometry"; >;
float3   MaterialAmbient   : AMBIENT  < string Object = "Geometry"; >;
float3   MaterialEmmisive  : EMISSIVE < string Object = "Geometry"; >;
float3   MaterialSpecular  : SPECULAR < string Object = "Geometry"; >;
float	SpecularPower	 : SPECULARPOWER < string Object = "Geometry"; >;
float3   MaterialToon		: TOONCOLOR;
float4   EdgeColor		 : EDGECOLOR;
float4   EgColor;



// ��̌W���X�y�L�����[�p���[��K���ɃX���[�X�l�X�ɒu��������B(0:�}�b�g�B1:�c���c��)
// �v�Z�͓K���B
float CalcSmoothness(float power)
{
	// 1�ɋ߉߂���ƁA�s�[�L�[�ɂȂ肷���ăn�C���C�g���łȂ��̂ŁA0.2�`0.98�̊Ԃɗ}����
	return saturate((log(power) / log(2) - 1) / 16.0) * 0.96 + 0.02;
}

// �X���[�X�l�X����K���Ƀ��t���N�^���X�ɒu��������B
// ������0.8�ȏ�B�������0.1�O��BUE4�ł͔������0.04(IOR=1.5)�ŌŒ�炵���B
inline float CalcF0(float smoothness)
{
	float a = smoothness * 2.0;
	float f0 = (a <= 1.0) ? pow(a,6) : (pow(abs(a-1), 1/6.0) + 1.0);
	return (f0 * 0.5 * 0.85 + 0.05);
}

static float Smoothness = CalcSmoothness(SpecularPower);
static float F0 = CalcF0(Smoothness);



// �ގ����[�t�Ή�
float4   TextureAddValue   : ADDINGTEXTURE;
float4   TextureMulValue   : MULTIPLYINGTEXTURE;
float4   SphereAddValue    : ADDINGSPHERETEXTURE;
float4   SphereMulValue    : MULTIPLYINGSPHERETEXTURE;

// ���C�g�F
float3   LightDiffuse		: DIFFUSE   < string Object = "Light"; >;
float3   LightAmbient		: AMBIENT   < string Object = "Light"; >;
float3   LightSpecular	 : SPECULAR  < string Object = "Light"; >;
static float4 DiffuseColor  = MaterialDiffuse  * float4(LightDiffuse, 1.0f);
static float3 AmbientColor  = saturate(MaterialAmbient  * LightAmbient + MaterialEmmisive);
static float3 SpecularColor = MaterialSpecular * LightSpecular;

bool	 parthf;   // �p�[�X�y�N�e�B�u�t���O
bool	 transp;   // �������t���O
bool	 spadd;	// �X�t�B�A�}�b�v���Z�����t���O
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


////////////////////////////////////////////////////////////////////////////////////////////////
//

#define	PI	(3.14159265359)

// �K���}�␳
const float gamma = 2.2;
inline float3 Degamma(float3 col) { return pow(col, gamma); }
inline float3 Gamma(float3 col) { return pow(col, 1.0/gamma); }
inline float4 Degamma4(float4 col) { return float4(Degamma(col.rgb), col.a); }
inline float4 Gamma4(float4 col) { return float4(Gamma(col.rgb), col.a); }

float CalcDiffuse(float3 L, float3 N, float3 V, float smoothness, float f0)
{
	const float NL = dot(N,L);
	float result = NL;					// ���ʂ̃����o�[�g
	return saturate(result);
}


// �����̏ꍇ�AF0��rgb���ɈقȂ�l������
inline float CalcFresnel(float NV, float F0)
{
	return F0 + (1.0 - F0) * pow(1 - NV, 5);
}

inline float CalcG1(float NV, float k)
{
	return 1.0 / (NV * (1.0 - k) + k);
}

inline float CalcV(float NV, float a)
{
	return NV * (0.5 - a) + 0.5 * a;
}

//�X�y�L�����̌v�Z
float CalcSpecular(float3 L, float3 N, float3 V, float smoothness, float f0)
{
	float3 H = normalize(L + V);	// �n�[�t�x�N�g��

#if 0
	float3 Specular = max(0,dot( H, N ));
	float power = pow(2,smoothness * 16);
	float3 result = pow(Specular, power);
	return result *= (2.0 + power) / (2.0 * PI);
#else

	float a = 1 - smoothness;
	a *= a;
	float aSq = a * a;
	float NV = saturate(dot(N, V));
	float NH = saturate(dot(N, H));
	float VH = saturate(dot(V, H));
	float NL = saturate(dot(N, L));
	float LH = saturate(dot(L, H));

	// NDF: Trowbridge-Reitz(GGX)
	float CosSq = (NH * NH) * (aSq - 1) + 1;
	float D = aSq / (PI * CosSq * CosSq);

	// �t���l����
	float F = CalcFresnel(LH, f0);

	// �􉽊w�I�����W��(G��)
	// GGX�p��G��
	float k = a * 0.5;
	float k2 = k * k;
	float vis = rcp(LH * LH * (1 - k2) + k2);

	return saturate(NL * D * F * vis / 4.0);
	// return max(0, D * F * G / (4.0 * NL * NV));
#endif
}


////////////////////////////////////////////////////////////////////////////////////////////////
// �֊s�`��

// ���_�V�F�[�_
float4 ColorRender_VS(float4 Pos : POSITION) : POSITION 
{
	// �J�������_�̃��[���h�r���[�ˉe�ϊ�
	return mul( Pos, WorldViewProjMatrix );
}

// �s�N�Z���V�F�[�_
float4 ColorRender_PS() : COLOR
{
	// �֊s�F�œh��Ԃ�
	return EdgeColor;
}

// �֊s�`��p�e�N�j�b�N
technique EdgeTec < string MMDPass = "edge"; > {
	pass DrawEdge {
		AlphaBlendEnable = FALSE;
		AlphaTestEnable  = FALSE;

		VertexShader = compile vs_2_0 ColorRender_VS();
		PixelShader  = compile ps_2_0 ColorRender_PS();
	}
}


///////////////////////////////////////////////////////////////////////////////////////////////
// �e�i��Z���t�V���h�E�j�`��

// ���_�V�F�[�_
float4 Shadow_VS(float4 Pos : POSITION) : POSITION
{
	// �J�������_�̃��[���h�r���[�ˉe�ϊ�
	return mul( Pos, WorldViewProjMatrix );
}

// �s�N�Z���V�F�[�_
float4 Shadow_PS() : COLOR
{
	// �A���r�G���g�F�œh��Ԃ�
	return float4(AmbientColor.rgb, 0.65f);
}

// �e�`��p�e�N�j�b�N
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
//	float2 Tex		: TEXCOORD1;	// �e�N�X�`��
};

// ���_�V�F�[�_
VS_ZValuePlot_OUTPUT ZValuePlot_VS( float4 Pos : POSITION, float2 Tex : TEXCOORD0 )
{
	VS_ZValuePlot_OUTPUT Out = (VS_ZValuePlot_OUTPUT)0;

	// ���C�g�̖ڐ��ɂ�郏�[���h�r���[�ˉe�ϊ�������
	Out.Pos = mul( Pos, LightWorldViewProjMatrix );

	// �e�N�X�`�����W�𒸓_�ɍ��킹��
	Out.ShadowMapTex = Out.Pos;

//	Out.Tex = Tex;

	return Out;
}

// �s�N�Z���V�F�[�_
float4 ZValuePlot_PS( float4 ShadowMapTex : TEXCOORD0, float2 Tex : TEXCOORD1 ) : COLOR
{
/*
	float3 alpha = tex2D( ObjTexSampler, Tex ).a;
	clip(alpha - 0.5);
*/
	// R�F������Z�l���L�^����
	return float4(ShadowMapTex.z/ShadowMapTex.w,0,0,1);
}

// Z�l�v���b�g�p�e�N�j�b�N
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

struct BufferShadow_OUTPUT {
	float4 Pos		: POSITION;	 // �ˉe�ϊ����W
	float4 ZCalcTex : TEXCOORD0;	// Z�l
	float2 Tex		: TEXCOORD1;	// �e�N�X�`��
	float3 Normal   : TEXCOORD2;	// �@��
	float3 Eye		: TEXCOORD3;	// �J�����Ƃ̑��Έʒu
	float2 SpTex	: TEXCOORD4;	 // �X�t�B�A�}�b�v�e�N�X�`�����W

    // �� ExcellentShadow�V�X�e���@�������火
    float4 ScreenTex : TEXCOORD5;   // �X�N���[�����W
    // �� ExcellentShadow�V�X�e���@�����܂Ł�

};

// ���_�V�F�[�_
BufferShadow_OUTPUT DrawObject_VS(float4 Pos : POSITION, float3 Normal : NORMAL, float2 Tex : TEXCOORD0,
	uniform bool useTexture, uniform bool useSphereMap, uniform bool useToon, uniform bool useSelfShadow)
{
	BufferShadow_OUTPUT Out = (BufferShadow_OUTPUT)0;

	// �J�������_�̃��[���h�r���[�ˉe�ϊ�
	Out.Pos = mul( Pos, WorldViewProjMatrix );

	// �J�����Ƃ̑��Έʒu
	Out.Eye = CameraPosition - mul( Pos, WorldMatrix ).xyz;
	// ���_�@��
	Out.Normal = normalize( mul( Normal, (float3x3)WorldMatrix ) );

	if (useSelfShadow)
	{
		// ���C�g���_�ɂ�郏�[���h�r���[�ˉe�ϊ�
		Out.ZCalcTex = mul( Pos, LightWorldViewProjMatrix );

		// �� ExcellentShadow�V�X�e���@�������火
		//�X�N���[�����W�擾
		Out.ScreenTex = Out.Pos;
		//�����i�ɂ����邿����h�~
		Out.Pos.z -= max(0, (int)((CameraDistance1 - 6000) * 0.04));
		// �� ExcellentShadow�V�X�e���@�����܂Ł�
	}

	// �e�N�X�`�����W
	Out.Tex = Tex;
	
	if ( useSphereMap ) {
		// �X�t�B�A�}�b�v�e�N�X�`�����W
		float2 NormalWV = mul( Normal, (float3x3)WorldViewMatrix ).xy;
		Out.SpTex.x = NormalWV.x * 0.5f + 0.5f;
		Out.SpTex.y = NormalWV.y * -0.5f + 0.5f;
	}

	return Out;
}


// �s�N�Z���V�F�[�_
float4 DrawObject_PS(BufferShadow_OUTPUT IN,
	uniform bool useTexture, uniform bool useSphereMap, uniform bool useToon, uniform bool useSelfShadow) : COLOR
{
	float3 L = -LightDirection;
	float3 V = normalize(IN.Eye);
	float3 N = normalize(IN.Normal);
	if (dot(N,V) < 0.0) N = -N; // ���ʃ|���S���𗠂��猩�Ă���

	float rimLight = pow(1.0 - saturate(dot(N,V)), RimLightPower) * RimLightIntensity;

	float specular = CalcSpecular(L, N, V, Smoothness, F0);
	float diffuse = CalcDiffuse(L, N, V, Smoothness, F0);

	float4 Color = float4(1,1,1, DiffuseColor.a);
	if ( !useToon ) {
		Color.rgb = (Degamma(AmbientColor) + Degamma(DiffuseColor.rgb));
	}

	float4 ShadowColor = float4(Degamma(AmbientColor), Color.a);  // �e�̐F
	if ( useTexture ) {
		// �e�N�X�`���K�p
		float4 TexColor = Degamma4(tex2D( ObjTexSampler, IN.Tex ));
		Color *= TexColor;
		ShadowColor *= TexColor;
	}
	if ( useSphereMap ) {
		// �X�t�B�A�}�b�v�K�p
		// �����n�C���C�g�̓K���}�␳���|����ƌ����Ȃ��Ȃ�...
		// float3 TexColor = Degamma(tex2D(ObjSphareSampler,IN.SpTex).rgb);
		float3 TexColor = tex2D(ObjSphareSampler,IN.SpTex).rgb;
		if(spadd) {
			Color.rgb += TexColor;
			ShadowColor.rgb += TexColor;
		} else {
			Color.rgb *= TexColor;
			ShadowColor.rgb *= TexColor;
		}
	}
	
	float comp = 1;

	if (useSelfShadow)
	{
		// �� ExcellentShadow�V�X�e���@�������火
		if(Exist_ExcellentShadow)
		{
			IN.ScreenTex.xyz /= IN.ScreenTex.w;
			float2 TransScreenTex;
			TransScreenTex.x = (1.0f + IN.ScreenTex.x) * 0.5f;
			TransScreenTex.y = (1.0f - IN.ScreenTex.y) * 0.5f;
			TransScreenTex += ES_ViewportOffset;
			comp = tex2D(ScreenShadowMapProcessedSamp, TransScreenTex).r;

			float SSAOMapVal = 0;
			if(Exist_ExShadowSSAO){
				SSAOMapVal = tex2D(ExShadowSSAOMapSamp , TransScreenTex).r; //�A�x�擾
			}

			if ( useToon ) {
				ShadowColor.rgb *= lerp(1, Degamma(MaterialToon), SSAOMapVal);
			} else {
				ShadowColor.rgb *= (1 - SSAOMapVal);
			}
		}
		else
		// �� ExcellentShadow�V�X�e���@�����܂Ł�
		{
			// �e�N�X�`�����W�ɕϊ�
			IN.ZCalcTex.xy /= IN.ZCalcTex.w;
			float2 TransTexCoord;
			TransTexCoord.x = (1.0f + IN.ZCalcTex.x)*0.5f;
			TransTexCoord.y = (1.0f - IN.ZCalcTex.y)*0.5f;
			if( any( saturate(TransTexCoord) != TransTexCoord ) ) {
				// �V���h�E�o�b�t�@�O
				;
			} else {
				float a = (parthf) ? SKII2*TransTexCoord.y : SKII1;

				// ���������ɉ����ăf�v�X��␳����
				float nl = dot(N,L);
				float d = (IN.ZCalcTex.z - (saturate(-nl) * 0.5)) / IN.ZCalcTex.w;

				comp = 1 - saturate(max(d - tex2D(DefSampler,TransTexCoord).r , 0.0f)*a-0.3f);
			}
		}

		specular *= comp;
	}

	comp = min(comp, diffuse);

	// �X�y�L�����K�p
	Color.rgb += specular * Degamma(SpecularColor);

	if ( useToon ) {
		// �g�D�[���K�p
		comp = saturate(comp * Toon);
		ShadowColor.rgb *= pow(Degamma(MaterialToon), ToonContrastPower);
	}

	Color.rgb = lerp(ShadowColor.rgb, Color.rgb, comp);
	Color.rgb += rimLight;

	return Gamma4(Color);
}



#define OBJECT_TEC(name, mmdpass, tex, sphere, toon, selfshadow) \
	technique name < string MMDPass = mmdpass; bool UseTexture = tex; bool UseSphereMap = sphere; bool UseToon = toon;  bool UseSelfShadow = selfshadow;\
	> { \
		pass DrawObject { \
			VertexShader = compile vs_3_0 DrawObject_VS(tex, sphere, toon, selfshadow); \
			PixelShader  = compile ps_3_0 DrawObject_PS(tex, sphere, toon, selfshadow); \
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



///////////////////////////////////////////////////////////////////////////////////////////////
