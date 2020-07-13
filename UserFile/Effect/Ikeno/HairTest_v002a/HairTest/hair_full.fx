////////////////////////////////////////////////////////////////////////////////////////////////
//
//  hair_full.fx
//  Tda���~�N�p�̔��V�F�[�_�[
//
////////////////////////////////////////////////////////////////////////////////////////////////


// �X�y�L�����̋��� (0.0�`1.5���x)
const float HairSpecularScale = 1.0;

// �^���W�F���g�}�b�v�t�@�C��
#define TANGENTMAP_FILENAME		"flowmap.png"

// �n�C���C�g�̓�������Y�����B���g�p�̏ꍇ�A�s����//������ăR�����g�A�E�g����B
#define NOISEMAP_FILENAME		"hairnoisemap.png"
// �n�C���C�g�̋��x���Y�����B���g�p�̏ꍇ�A�s����//������ăR�����g�A�E�g����B
#define HAIRMASK_FILENAME		"hairmask.png"

// �}�e���A���̃X�y�L�����J���[���㏑������
// �㏑�����Ȃ��ꍇ�́A�s����//������B
#define	OverrideMaterialSpecular	float3(1.0, 1.0, 1.0)

// �}�e���A���̃X�y�L�����s�[�N�̋������㏑������
// �㏑�����Ȃ��ꍇ�́A�s����//������B
#define	OverrideSpecularPower	32


// ���̖т̒��ɓ����������A���̖тɋz������闦�B���l�������قǋz�������B
// ����ŃZ�J���h�X�y�L�����̐F�����肳���
//const float3 AttenuationColor = float3(0.1, 0.7, 0.99); // �Ԃ��c�� (����)
//const float3 AttenuationColor = float3(0.01, 0.3, 0.5); // �Ԃ��c�� (����)
const float3 AttenuationColor = float3(2.0, 0.6, 0.05);	// �������c��

// �X�t�B�A�}�b�v�𕹗p���邩? (0:���Ȃ��A1:����)
#define ENABLE_SphereMap		0

// �f�o�b�O�p�ɐ����ۂ̕�����\������B
// �ѐ悪�^���������Ɍ������Ă���Ȃ�A�ѐ�͏�(Y����)�Ȃ̂ŗ΂ɂȂ�B
//#define DEBUG_DISP_TANGENT

//#define DEBUG_SPECULAR_ONLY

// �]�@�������o���e�N�X�`���̃X�P�[��
#define BinormalTexScale	1.0



////////////////////////////////////////////////////////////////////////////////////////////////
// �p�����[�^�錾

// ���@�ϊ��s��
float4x4 WorldViewProjMatrix      : WORLDVIEWPROJECTION;
float4x4 WorldMatrix              : WORLD;
float4x4 ViewMatrix               : VIEW;
float4x4 LightWorldViewProjMatrix : WORLDVIEWPROJECTION < string Object = "Light"; >;

float3   LightDirection    : DIRECTION < string Object = "Light"; >;
float3   CameraPosition    : POSITION  < string Object = "Camera"; >;

// �}�e���A���F
float4   MaterialDiffuse   : DIFFUSE  < string Object = "Geometry"; >;
float3   MaterialAmbient   : AMBIENT  < string Object = "Geometry"; >;
float3   MaterialEmmisive  : EMISSIVE < string Object = "Geometry"; >;
#if defined(OverrideMaterialSpecular)
float3   MaterialSpecular = OverrideMaterialSpecular;
#else
float3   MaterialSpecular  : SPECULAR < string Object = "Geometry"; >;
#endif

#if defined(OverrideSpecularPower)
float	SpecularPower = OverrideSpecularPower;
#else
float	SpecularPower	 : SPECULARPOWER < string Object = "Geometry"; >;
#endif
float3   MaterialToon      : TOONCOLOR;
float4   EdgeColor         : EDGECOLOR;
float4   GroundShadowColor : GROUNDSHADOWCOLOR;
// ���C�g�F
float3   LightDiffuse      : DIFFUSE   < string Object = "Light"; >;
float3   LightAmbient      : AMBIENT   < string Object = "Light"; >;
float3   LightSpecular     : SPECULAR  < string Object = "Light"; >;
static float4 DiffuseColor  = MaterialDiffuse  * float4(LightDiffuse, 1.0f);
static float3 AmbientColor  = MaterialAmbient  * LightAmbient + MaterialEmmisive;
static float3 SpecularColor = MaterialSpecular * LightSpecular;

// �e�N�X�`���ގ����[�t�l
float4   TextureAddValue   : ADDINGTEXTURE;
float4   TextureMulValue   : MULTIPLYINGTEXTURE;
float4   SphereAddValue    : ADDINGSPHERETEXTURE;
float4   SphereMulValue    : MULTIPLYINGSPHERETEXTURE;

bool	use_texture;		//	�e�N�X�`���t���O
bool	use_spheremap;		//	�X�t�B�A�t���O
bool	use_toon;			//	�g�D�[���t���O
bool	use_subtexture;    // �T�u�e�N�X�`���t���O

bool     parthf;   // �p�[�X�y�N�e�B�u�t���O
bool     transp;   // �������t���O
bool	 spadd;    // �X�t�B�A�}�b�v���Z�����t���O
#define SKII1    1500
#define SKII2    8000
#define Toon     3


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
    MINFILTER = LINEAR;
    MAGFILTER = LINEAR;
    MIPFILTER = LINEAR;
    ADDRESSU  = WRAP;
    ADDRESSV  = WRAP;
};

// �V���h�E�o�b�t�@�̃T���v���B"register(s0)"�Ȃ̂�MMD��s0���g���Ă��邩��
sampler DefSampler : register(s0);

float2 ViewportSize : VIEWPORTPIXELSIZE;

////////////////////////////////////////////////////////////////////////////////////////////////

shared texture2D BinormalTex : RenderColorTarget
<
	float2 ViewPortRatio = {BinormalTexScale,BinormalTexScale};
	bool AntiAlias = false;
	int Miplevels = 1;
	string Format = "D3DFMT_A16B16G16R16F" ;
>;
sampler BinormalSampler = sampler_state {
	texture = <BinormalTex>;
	MINFILTER = LINEAR;
	MAGFILTER = LINEAR;
	MIPFILTER = NONE;
	AddressU  = CLAMP;
	AddressV = CLAMP;
};

texture2D BinormalWorkTex : RenderColorTarget
<
	float2 ViewPortRatio = {BinormalTexScale,BinormalTexScale};
	bool AntiAlias = false;
	int Miplevels = 1;
	string Format = "D3DFMT_A16B16G16R16F" ;
>;
sampler BinormalWorkSampler = sampler_state {
	texture = <BinormalWorkTex>;
	MINFILTER = LINEAR;
	MAGFILTER = LINEAR;
	MIPFILTER = NONE;
	AddressU  = CLAMP;
	AddressV = CLAMP;
};

texture2D DepthBuffer : RENDERDEPTHSTENCILTARGET <
	float2 ViewPortRatio = {BinormalTexScale,BinormalTexScale};
	string Format = "D24S8";
>;

// �^���W�F���g�}�b�v
texture2D TangentMap <
    string ResourceName = TANGENTMAP_FILENAME;
>;
sampler TangentMapSamp = sampler_state {
    texture = <TangentMap>;
	FILTER = LINEAR;
};


#if defined(NOISEMAP_FILENAME)
texture2D NoiseMap <
    string ResourceName = NOISEMAP_FILENAME;
>;
sampler NoiseMapSamp = sampler_state {
    texture = <NoiseMap>;
	FILTER = LINEAR;
};
#endif

#if defined(HAIRMASK_FILENAME)
texture2D HairMaskMap <
    string ResourceName = HAIRMASK_FILENAME;
>;
sampler HairMaskSamp = sampler_state {
    texture = <HairMaskMap>;
	FILTER = LINEAR;
};
#endif


////////////////////////////////////////////////////////////////////////////////////////////////
//

#define	PI	(3.14159265359)
#define DEG2RAD(d)	((d) * PI / 180.0)

// �ڂ��������̏d�݌W���F
//	�K�E�X�֐� exp( -x^2/(2*d^2) ) �� d=5, x=0�`7 �ɂ��Čv�Z�����̂��A
//	(WT_7 + WT_6 + �c + WT_1 + WT_0 + WT_1 + �c + WT_7) �� 1 �ɂȂ�悤�ɐ��K����������
static const float BlurWeight[] = {
	0.0920246,
	0.0902024,
	0.0849494,
	0.0768654,
	0.0668236,
	0.0558158,
	0.0447932,
	0.0345379,
};

// �K���}�␳
const float gamma = 2.2;
const float epsilon = 1.0e-6;
inline float3 Degamma(float3 col) { return pow(max(col,epsilon), gamma); }
inline float3 Gamma(float3 col) { return pow(max(col,epsilon), 1.0/gamma); }
inline float4 Degamma4(float4 col) { return float4(Degamma(col.rgb), col.a); }
inline float4 Gamma4(float4 col) { return float4(Gamma(col.rgb), col.a); }

float3 CalcBinormal(float3 Pos, float3 N, float2 uv)
{
	float3 dpdy = ddy(Pos);
	float3 vRx = normalize(cross(dpdy, N));
	float3 vRy = cross(N, vRx);
	float2 duvdx = ddx(uv);
	float2 duvdy = ddy(uv);
	float3 Tangent = duvdx.x * vRx + duvdy.x * vRy;
	float3 Binormal = duvdx.y * vRx + duvdy.y * vRy;

	float2 tex = tex2Dlod(TangentMapSamp, float4(uv,0,0)).xy * 2.0 - 1.0;
	Tangent = normalize(Binormal * -tex.y + Tangent * tex.x);
	Binormal = cross(Tangent, N);
	return normalize(Binormal);
}

// Kajiya-Kay���f��
float KajiyaKayDiff(float3 T, float3 V, float3 L)
{
	// return sin( acos(dot(T,L)) );
	float TL = dot(T, L);
	return sqrt(1 - TL * TL);
}

float KajiyaKaySepc(float3 T, float3 V, float3 L, float specPower)
{
//	return pow( cos( abs( acos(dot(T, L)) - acos(dot(-T,V)) ) ), specPower);
	float TL = dot(T, L);
	float TV = dot(-T, V);
	float TLy = sqrt(1 - TL * TL);
	float TVy = sqrt(1 - TV * TV);
	return pow( abs(-TV * TL - TVy * TLy), specPower);
}

inline float gaussian(float beta, float theta)
{
	float beta2 = 2.0 * beta * beta;
	float theta2 = theta * theta;
	return exp(-theta2 * (1.0 / beta2)) / sqrt(PI * beta2);
}

// Marschner�̃T�u�Z�b�g�BTT���l�����Ȃ��B
float3 SimpleHairSepc(float3 T, float3 V, float3 L, float specPower)
{
	float TL = dot(T, L);
	float thetaI = asin(TL);
	float thetaR = asin(dot(T, V));
	float thetaH = (thetaR + thetaI) * 0.5;
	float thetaD = (thetaR - thetaI) * 0.5;
	float cosThetaD2 = pow(cos(thetaD), 2) * 0.5;

	float alphaR = DEG2RAD(3);		// �L���[�e�B�N���̌X��
	float betaR = DEG2RAD(8);		// �\�ʂ̑e���B
	float alphaTRT = -1.5 * alphaR;
	float betaTRT = 2.0 * betaR;

	float M_R = (gaussian(betaR, thetaH - alphaR));
	// M1(TT)�͏ȗ��B
	float M_TRT = (gaussian(betaTRT, thetaH - alphaTRT));

	// �K���ȐF�̌���
	float3 N_TRT = exp(-((1.0 - TL * TL) + 0.1) * 4.0 * (AttenuationColor + 0.1));

	return (M_R + M_TRT * N_TRT) * cosThetaD2;
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
    // �n�ʉe�F�œh��Ԃ�
    return GroundShadowColor;
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
    float4 Pos : POSITION;              // �ˉe�ϊ����W
    float4 ShadowMapTex : TEXCOORD0;    // Z�o�b�t�@�e�N�X�`��
};

// ���_�V�F�[�_
VS_ZValuePlot_OUTPUT ZValuePlot_VS( float4 Pos : POSITION )
{
    VS_ZValuePlot_OUTPUT Out = (VS_ZValuePlot_OUTPUT)0;

    // ���C�g�̖ڐ��ɂ�郏�[���h�r���[�ˉe�ϊ�������
    Out.Pos = mul( Pos, LightWorldViewProjMatrix );

    // �e�N�X�`�����W�𒸓_�ɍ��킹��
    Out.ShadowMapTex = Out.Pos;

    return Out;
}

// �s�N�Z���V�F�[�_
float4 ZValuePlot_PS( float4 ShadowMapTex : TEXCOORD0 ) : COLOR
{
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
// �]�@���̐����B

struct Binormal_OUTPUT {
	float4 Pos		: POSITION;	 // �ˉe�ϊ����W
	float4 WPos		: TEXCOORD0;
	float2 Tex		: TEXCOORD1;	// �e�N�X�`��
	float3 Normal	: TEXCOORD2;	// �@��
};

Binormal_OUTPUT Binormal_VS(float4 Pos : POSITION, float3 Normal : NORMAL, float2 Tex : TEXCOORD0)
{
	Binormal_OUTPUT Out = (Binormal_OUTPUT)0;

	// �J�������_�̃��[���h�r���[�ˉe�ϊ�
	Out.Pos = mul( Pos, WorldViewProjMatrix );
	Out.WPos = mul( Pos, WorldMatrix );
	Out.Normal = normalize( mul( Normal, (float3x3)WorldMatrix ) );
	Out.Tex = Tex;

	return Out;
}

float4 Binormal_PS(Binormal_OUTPUT IN) : COLOR
{
	// �����e�N�X�`���Ή�
	float4 TexColor = tex2D( ObjTexSampler, IN.Tex);
	clip(TexColor.a - 2.0/255.0);

	float depth = distance(CameraPosition, IN.WPos.xyz);
	float3 N = normalize(IN.Normal);
	float3 Binormal = CalcBinormal(IN.WPos, N, IN.Tex);

	return float4(Binormal, depth * 0.5);
}


///////////////////////////////////////////////////////////////////////////////////////////////
// �u���[

struct VS_OUTPUT_BLUR {
	float4 Pos			: POSITION;
	float2 Tex			: TEXCOORD0;
};

VS_OUTPUT_BLUR Blur_VS( float4 Pos : POSITION, float2 Tex : TEXCOORD0 )
{
	VS_OUTPUT_BLUR Out = (VS_OUTPUT_BLUR)0; 

	Out.Pos = Pos;
	Out.Tex = Tex + (0.5 / (ViewportSize * BinormalTexScale));

	return Out;
}

inline float DepthDistance(float4 c1, float4 c2)
{
	float depth1 = c1.w;
	float depth2 = c2.w;
	depth1 = (depth1 > 0.0) ? depth1 : depth2; // ���S�����O?
	float w = max(dot(c1.xyz, c2.xyz), 0);
	return (depth2 == 0.0) ? 0 : exp(-abs(depth1 - depth2) - 1e-6) * w;
}

float4 Blur_PS( float2 Tex: TEXCOORD0, uniform bool isXBlur, uniform sampler smp) : COLOR
{
	float2 SampStep = 1.0 / (ViewportSize * BinormalTexScale);
	// sampler smp = (isXBlur) ? BinormalSampler : BinormalWorkSampler;
	float2 offset = (isXBlur) ? float2(SampStep.x, 0) : float2(0, SampStep.y);

	float4 Color0 = tex2D( smp, Tex);
	float4 Color = Color0;
	Color.rgb *= BlurWeight[0];

	[unroll]
	for(int i = 1; i < 8; i ++) {
		float w = BlurWeight[i];
		float4 cp = tex2D( smp, Tex + offset * i);
		float wp = w * DepthDistance(Color0, cp);
		float4 cn = tex2D( smp, Tex - offset * i);
		float wn = w * DepthDistance(Color0, cn);
		Color.rgb += (cp.rgb * wp + cn.rgb * wn);
	}

	Color.rgb = Color.rgb / max(length(Color.rgb), 0.01);
	return Color;
}

///////////////////////////////////////////////////////////////////////////////////////////////
// �I�u�W�F�N�g�`��

struct VS_OUTPUT {
    float4 Pos        : POSITION;    // �ˉe�ϊ����W
    float4 ZCalcTex   : TEXCOORD0;   // Z�l
    float2 Tex        : TEXCOORD1;   // �e�N�X�`��
    float3 Normal     : TEXCOORD2;   // �@��
    float3 Eye        : TEXCOORD3;   // �J�����Ƃ̑��Έʒu
    float2 SpTex      : TEXCOORD4;	 // �X�t�B�A�}�b�v�e�N�X�`�����W
	float4 PPos			: TEXCOORD5;
    float4 Color      : COLOR0;      // �f�B�t���[�Y�F
};


// ���_�V�F�[�_
VS_OUTPUT Object_VS(float4 Pos : POSITION, float3 Normal : NORMAL, float2 Tex : TEXCOORD0, float2 Tex2 : TEXCOORD1, uniform bool useTexture, uniform bool useSphereMap, uniform bool useToon, uniform bool useSelfshadow)
{
    VS_OUTPUT Out = (VS_OUTPUT)0;
    
    // �J�������_�̃��[���h�r���[�ˉe�ϊ�
    Out.Pos = mul( Pos, WorldViewProjMatrix );
    Out.PPos = Out.Pos;
    
    // �J�����Ƃ̑��Έʒu
    Out.Eye = CameraPosition - mul( Pos, WorldMatrix );
    // ���_�@��
    Out.Normal = normalize( mul( Normal, (float3x3)WorldMatrix ) );

	if (useSelfshadow)
	{
		// ���C�g���_�ɂ�郏�[���h�r���[�ˉe�ϊ�
	    Out.ZCalcTex = mul( Pos, LightWorldViewProjMatrix );
	}

    // �f�B�t���[�Y�F�{�A���r�G���g�F �v�Z
    Out.Color.rgb = AmbientColor;
    Out.Color.a = DiffuseColor.a;
    Out.Color = saturate( Out.Color );
    
    // �e�N�X�`�����W
    Out.Tex = Tex;
    
    if ( useSphereMap ) {
		if ( use_subtexture ) {
			// PMX�T�u�e�N�X�`�����W
			Out.SpTex = Tex2;
	    } else {
	        // �X�t�B�A�}�b�v�e�N�X�`�����W
	        float2 NormalWV = mul( Out.Normal, (float3x3)ViewMatrix );
	        Out.SpTex.x = NormalWV.x * 0.5f + 0.5f;
	        Out.SpTex.y = NormalWV.y * -0.5f + 0.5f;
	    }
    }
    
    return Out;
}


float4 Object_PS(VS_OUTPUT IN, uniform bool useTexture, uniform bool useSphereMap, uniform bool useToon, uniform bool useSelfshadow) : COLOR
{
	float3 L = -LightDirection;
	float3 V = normalize(IN.Eye);
	float3 N = normalize(IN.Normal);

	float diffuse = dot(N,L);

    // �X�y�L�����F�v�Z
#if 0
    float3 HalfVector = normalize( V + L );
    float3 Specular = pow( max(0,dot( HalfVector, N )), SpecularPower ) * SpecularColor;
#else

	float2 uv = (IN.PPos.xy / IN.PPos.w) * float2(0.5, -0.5) + 0.5;
	float3 Binormal = normalize(tex2D(BinormalSampler, uv.xy).xyz);
	float3 Tangent = normalize(cross(N, Binormal));

	#if defined(NOISEMAP_FILENAME)
	float n = tex2D(NoiseMapSamp, IN.Tex.xy).x;
	Tangent = normalize(Tangent + N * (n * 2.0 - 1.0) * 0.25);
	#endif

	#if defined(DEBUG_DISP_TANGENT)
	//�f�o�b�O�p�ɍ��������̃x�N�g����\������
	float3 c0 = -Tangent * 0.5 + 0.5;
	float3 c1 = tex2D( ObjTexSampler, IN.Tex.xy ).rgb;
	return float4(lerp(c0, c1, 0.25), 1);
	#endif

	// float3 s = KajiyaKaySepc(Tangent, V, L, SpecularPower);
	// diffuse = min(KajiyaKayDiff(Tangent, V, L), saturate(dot(N,L)));
	float3 s = SimpleHairSepc(Tangent, V, L, SpecularPower);
	diffuse = saturate(diffuse);

	float3 Specular = s * min(diffuse * 4.0, 1) * Degamma(SpecularColor) * HairSpecularScale;

	#if defined(HAIRMASK_FILENAME)
	Specular = saturate(Specular * Degamma(tex2D(HairMaskSamp, IN.Tex.xy).rgb));
	#endif

	#if defined(DEBUG_SPECULAR_ONLY)
	return float4(Gamma(Specular), 1);
	#endif
#endif

    float4 Color = IN.Color;
	if ( !useToon )
	{
        Color.rgb += max(0,diffuse) * DiffuseColor.rgb;
    }

    float4 ShadowColor = float4(saturate(AmbientColor), Color.a);  // �e�̐F
    if ( useTexture ) {
        float4 TexColor = tex2D( ObjTexSampler, IN.Tex );
	    TexColor.rgb = lerp(1, TexColor * TextureMulValue + TextureAddValue, TextureMulValue.a + TextureAddValue.a);
        Color *= TexColor;
        ShadowColor *= TexColor;
    }

    if ( useSphereMap ) {
        float4 TexColor = tex2D(ObjSphareSampler,IN.SpTex);
        TexColor.rgb = lerp(spadd?0:1, TexColor * SphereMulValue + SphereAddValue, SphereMulValue.a + SphereAddValue.a);
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

	float comp = 1;
	if (useSelfshadow)
	{
    	// �e�N�X�`�����W�ɕϊ�
    	IN.ZCalcTex /= IN.ZCalcTex.w;
    	float2 TransTexCoord = IN.ZCalcTex.xy * float2(0.5, - 0.5) + 0.5;
    	if( all( saturate(TransTexCoord) == TransTexCoord ) )
		{
			float shadow = max(IN.ZCalcTex.z-tex2D(DefSampler,TransTexCoord).r , 0.0f);
			float k = (parthf) ? SKII2 * TransTexCoord.y : SKII1;
			comp = 1 - saturate(shadow * k - 0.3f);
		}

		Specular *= comp;
	}

	if ( useToon )
	{
		comp = min(saturate(diffuse * Toon), comp);
		ShadowColor.rgb *= MaterialToon;
	}

	float4 ans = lerp(ShadowColor, Color, comp);

    // �X�y�L�����K�p
    // Color.rgb += Specular;
    ans.rgb = Gamma(Degamma(ans.rgb) + Specular);

//	if( transp ) ans.a = 0.5f;
	return ans;
}



///////////////////////////////////////////////////////////////////////////////////////////////

float4 ClearColor = {0,0,0,0};
float ClearDepth  = 1.0;

#define OBJECT_TEC(name, mmdpass, tex, sphere, toon, selfshadow) \
technique name < \
	string MMDPass = mmdpass; \
	string Script = \
		"RenderColorTarget0=BinormalTex;" \
		"RenderDepthStencilTarget=DepthBuffer;" \
		"ClearSetColor=ClearColor;" \
		"ClearSetDepth=ClearDepth;" \
		"Clear=Color; Clear=Depth;" \
		"Pass=DrawBinormal;" \
		"RenderColorTarget0=BinormalWorkTex;	Pass=BlurX;" \
		"RenderColorTarget0=BinormalTex;		Pass=BlurY;" \
	\
		"RenderColorTarget0=;" \
		"RenderDepthStencilTarget=;" \
		"Pass=DrawObject;" \
; \
> { \
	pass DrawBinormal { \
		AlphaBlendEnable = false; AlphaTestEnable = false; \
		VertexShader = compile vs_3_0 Binormal_VS(); \
		PixelShader  = compile ps_3_0 Binormal_PS(); \
	} \
	pass BlurX < string Script= "Draw=Buffer;"; > { \
		AlphaBlendEnable = false; AlphaTestEnable = false; \
		ZEnable = false; ZWriteEnable = false; \
		VertexShader = compile vs_3_0 Blur_VS(); \
		PixelShader  = compile ps_3_0 Blur_PS(true, BinormalSampler); \
	} \
	pass BlurY < string Script= "Draw=Buffer;"; > { \
		AlphaBlendEnable = false; AlphaTestEnable = false; \
		ZEnable = false; ZWriteEnable = false; \
		VertexShader = compile vs_3_0 Blur_VS(); \
		PixelShader  = compile ps_3_0 Blur_PS(false, BinormalWorkSampler); \
	} \
	pass DrawObject { \
		VertexShader = compile vs_3_0 Object_VS(tex, sphere, toon, selfshadow); \
		PixelShader  = compile ps_3_0 Object_PS(tex, sphere, toon, selfshadow); \
	} \
}


#if defined(ENABLE_SphereMap) && ENABLE_SphereMap > 0
OBJECT_TEC(MainTec0, "object", use_texture, use_spheremap, use_toon, false)
OBJECT_TEC(MainTecBS0, "object_ss", use_texture, use_spheremap, use_toon, true)
#else
OBJECT_TEC(MainTec0, "object", use_texture, false, use_toon, false)
OBJECT_TEC(MainTecBS0, "object_ss", use_texture, false, use_toon, true)
#endif

///////////////////////////////////////////////////////////////////////////////////////////////
