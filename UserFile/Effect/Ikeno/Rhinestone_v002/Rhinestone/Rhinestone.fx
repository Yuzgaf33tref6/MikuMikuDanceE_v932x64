////////////////////////////////////////////////////////////////////////////////////////////////
//
//
//////////////////////////////////////////////////////////////////////////////////////////////

// �p�����[�^�錾

// �@���}�b�v�t�@�C����
//#define NORMALMAP__FILENAME "brilliantTops2.png"
//#define NORMALMAP__FILENAME "circles.png"
//#define NORMALMAP__FILENAME "roundedSquares.png"
#define NORMALMAP__FILENAME "hexagons.png"
//#define NORMALMAP__FILENAME "PCCP.png"


// ���˂���ʁB�l���傫���قǖ��邭�Ȃ�
float ReflectionIntensity = 1.0;

float NormalMapLoopNum = 48;			// �J��Ԃ��񐔁B�傫���قǖ͗l���ׂ����Ȃ�
float NormalMapHeightScale = 1.0;		// �����␳�B���ō����Ȃ� 0�ŕ��R (-4�`4���x)

// ���˂̉s�� (0.7�`0.98���x)
float Smoothness = 0.80;

// ���ܗ� (1.3�`2.5���x)
float IoR = 2.0;

// ����������Ȃ������̐F���Â����邩? (0:���邢�A1:�Â�)
float TintRate = 0.5;

// �ǉ��X�t�B�A�}�b�v
// ���X�X�t�B�A�}�b�v���������f���p�B�s�v�ȏꍇ��//�ŃR�����g�A�E�g����B
//#define SPHERE_FILENAME "dummySphere.png"
// �ǉ��X�t�B�A�}�b�v�̋���
float SpehreIntensity = 0.5;

// �񎟔��˂̐F�̋������s��
// �Â��F�ł��񎟔��˂��t��
#define ENABLE_COLOR_EMPHASIZE	1

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
float3   MaterialSpecular  : SPECULAR < string Object = "Geometry"; >;
float    SpecularPower     : SPECULARPOWER < string Object = "Geometry"; >;
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

//////////////////////////////////////////////////////////////////////////////////////////////

static float F0 = saturate(pow((IoR - 1.0) / (IoR + 1.0), 2.0)) + 0.001;
static float Roughness0 = saturate((1 - Smoothness) * (1 - Smoothness)) * 0.98 + 0.01;
static float Roughness = Roughness0 * Roughness0;
static float WaveLengthRate = saturate(IoR - 1.0) / 40.0;


#if defined(SPHERE_FILENAME)
texture2D DummySphereMap <
    string ResourceName = SPHERE_FILENAME;
>;
sampler DummySphereMapSamp = sampler_state {
    texture = <DummySphereMap>;
	FILTER = LINEAR;
	AddressU  = CLAMP; AddressV  = CLAMP;
};
#endif

//���C���@���}�b�v
#define ANISO_NUM 16

texture2D NormalMap <
    string ResourceName = NORMALMAP__FILENAME;
>;
sampler NormalMapSamp = sampler_state {
    texture = <NormalMap>;
	FILTER = LINEAR;
	AddressU  = WRAP;
	AddressV  = WRAP;
};

#define	PI	(3.14159265359)

// �����̏ꍇ�AF0��rgb���ɈقȂ�l������
inline float CalcFresnel(float NV, float F0)
{
	return F0 + (1.0 - F0) * pow(1 - NV, 5);
}

//�X�y�L�����̌v�Z
inline float CalcSpecular(float3 L, float3 N, float3 V, float a)
{
	float3 H = normalize(L + V);

	float NH = saturate(dot(N, H));
	float NL = saturate(dot(N, L));
	float LH = saturate(dot(L, H));

	float CosSq = (NH * NH) * (a - 1) + 1;
	float D = a / (CosSq * CosSq);

	float k2 = a * a * 0.25;	// = (a * 0.5)^2
	float vis = (1.0/4.0) / (LH * LH * (1 - k2) + k2);
	return max(NL * D * vis, 0);
}


float3x3 compute_tangent_frame(float3 Normal, float3 View, float2 UV)
{
	float3 vRx = ddx(View);
	float3 vRy = ddy(View);
	float2 duvdx = ddx(UV);
	float2 duvdy = ddy(UV);

	float3 Tangent = 0;//duvdx.x * vRx + duvdy.x * vRy;
	float3 Binormal = duvdx.y * vRx + duvdy.y * vRy;

	Tangent = normalize(cross(normalize(Binormal), Normal));
	Binormal = normalize(cross(Normal, Tangent));

	return float3x3(Tangent, Binormal, Normal);
}

float3 CalcNormal(float3 normal, float3x3 mat, float s)
{
	normal.xy *= s;
	return mul(normalize(normal.xyz), mat);
}


// ������ۂ��l��Ԃ��K���ȋ��܌v�Z
inline float3 CustomRefract(float3 i, float3 n, float e)
{
	float ni = dot(n, i);
	float ni2 = 1 - ni * ni;
	float k1 = abs(1 - e * e * ni2) + 0.001;	// �{���� k > 0�Ȃ�(0,0,0)��Ԃ�
	float3 v1 = (e * i - (e * ni + sqrt(k1)) * n);
	return v1 * sign(dot(v1,i));		// ���̏������K��
}


inline float3 ColorEmphasize(float3 original)
{
#if defined(ENABLE_COLOR_EMPHASIZE) && ENABLE_COLOR_EMPHASIZE > 0
	float3 col = original + 0.01;
	float maxChannel = max(col.r, max(col.g, col.b));
	return pow(saturate(col / maxChannel), 4);
#else
	return original;
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
// �I�u�W�F�N�g�`��

struct VS_OUTPUT {
    float4 Pos        : POSITION;    // �ˉe�ϊ����W
    float4 ZCalcTex   : TEXCOORD0;   // Z�l
    float2 Tex        : TEXCOORD1;   // �e�N�X�`��
    float3 Normal     : TEXCOORD2;   // �@��
    float3 Eye        : TEXCOORD3;   // �J�����Ƃ̑��Έʒu
    float2 SpTex      : TEXCOORD4;	 // �X�t�B�A�}�b�v�e�N�X�`�����W
    float4 Color      : COLOR0;      // �f�B�t���[�Y�F
};


// ���_�V�F�[�_
VS_OUTPUT Object_VS(float4 Pos : POSITION, float3 Normal : NORMAL, float2 Tex : TEXCOORD0, float2 Tex2 : TEXCOORD1, uniform bool useTexture, uniform bool useSphereMap, uniform bool useToon, uniform bool useSelfshadow)
{
    VS_OUTPUT Out = (VS_OUTPUT)0;
    
    // �J�������_�̃��[���h�r���[�ˉe�ϊ�
    Out.Pos = mul( Pos, WorldViewProjMatrix );
    
    // �J�����Ƃ̑��Έʒu
    Out.Eye = CameraPosition - mul( Pos, WorldMatrix ).xyz;
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
	float3 N0 = normalize(IN.Normal);

	//--------------------------------------------------------
	float3x3 tangentFrame = compute_tangent_frame(N0, V, IN.Tex);
	float3x3 invTangentFrame = transpose(tangentFrame);

	float2 uv = IN.Tex * NormalMapLoopNum;
	float4 NormalColor = tex2D( NormalMapSamp, uv);
	NormalColor.xyz = NormalColor.xyz * 2 - 1;
	// �Ȉ�POM�F NormalColor.z�������Ƃ݂Ȃ��ăV�t�g����
	float shift = (1.0 - NormalColor.z) * 0.1 * NormalMapHeightScale;
	uv += mul(-V, invTangentFrame).xy * shift;
	NormalColor = tex2D( NormalMapSamp, uv) * 2 - 1;
	float3 N = CalcNormal(NormalColor.xyz, tangentFrame, NormalMapHeightScale);

	// 2������
	shift = NormalColor.z * 0.1 * NormalMapHeightScale;
	uv += mul(-V, invTangentFrame).xy * shift;
	NormalColor = tex2D( NormalMapSamp, uv);
	NormalColor.xyz = 1 - NormalColor.xyz * 2;
	float3 N2 = CalcNormal(NormalColor.xyz, tangentFrame, NormalMapHeightScale);
	// 3������
	uv += NormalColor.xy * 0.25 * NormalMapHeightScale;
	NormalColor = tex2D( NormalMapSamp, uv);
	NormalColor.xyz = NormalColor.xyz * 2 - 1;
	float3 N3 = CalcNormal(NormalColor.xyz, tangentFrame, NormalMapHeightScale);

	float F1 = CalcFresnel(abs(dot(N, V)), F0);
	float3 F2 = (1 - F1) * 0.5;

	float3 specular = CalcSpecular(L, N, V, Roughness) * F1 * ReflectionIntensity;
	float3 specular2 = CalcSpecular(L, N2, V, Roughness);
	float3 specular3 = CalcSpecular(L, N3, V, Roughness);
	specular2 = (specular2 + specular3) * F2 * ReflectionIntensity;

	float diffuse = max(0,dot(N, L)) * F1 + (max(0,dot(N2, L)) + max(0,dot(N3, L))) * F2;
	//--------------------------------------------------------

    float4 Color = IN.Color;
	if ( !useToon )
	{
        Color.rgb += max(0,diffuse) * DiffuseColor.rgb;
    }

    float4 ShadowColor = float4(saturate(AmbientColor), Color.a);  // �e�̐F
    if ( useTexture ) {
        float4 TexColor = tex2D( ObjTexSampler, IN.Tex );
	    TexColor.rgb = lerp(1, TexColor.rgb * TextureMulValue + TextureAddValue, TextureMulValue.a + TextureAddValue.a);
        Color *= TexColor;
        ShadowColor *= TexColor;
    }

    if ( useSphereMap ) {
        float4 TexColor = tex2D(ObjSphareSampler, IN.SpTex);
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

	// �Ǝ��̃X�t�B�A�}�b�v��K�p����
	#if defined(SPHERE_FILENAME)
	if (true)
	{
		float2 NormalWV = mul( N2, (float3x3)ViewMatrix );
		float2 SpTex = NormalWV.xy * float2(0.5, -0.5) + 0.5;
		float3 TexColor = tex2D(DummySphereMapSamp, SpTex).rgb * LightSpecular * SpehreIntensity;
		Color.rgb += TexColor;
		ShadowColor.rgb += TexColor;
	}
	#endif

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
	}

	//--------------------------------------------------------
	float attenuation = lerp(1, 1.0 - F1, TintRate);

	Color.rgb *= attenuation;
	ShadowColor.rgb *= attenuation;

	// �X�y�L�����K�p
	specular2 *= ColorEmphasize(Color.rgb);
	Color.rgb += specular + specular2;
	ShadowColor.rgb += specular2;
	//--------------------------------------------------------

	if ( useToon )
	{
		comp = min(saturate(diffuse * Toon), comp);
		ShadowColor.rgb *= MaterialToon;
	}

	float4 ans = lerp(ShadowColor, Color, comp);
	return ans;
}


#define OBJECT_TEC(name, mmdpass, tex, sphere, toon, selfshadow) \
	technique name < string MMDPass = mmdpass; > { \
		pass DrawObject { \
			VertexShader = compile vs_3_0 Object_VS(tex, sphere, toon, selfshadow); \
			PixelShader  = compile ps_3_0 Object_PS(tex, sphere, toon, selfshadow); \
		} \
	}


OBJECT_TEC(MainTec0, "object", use_texture, use_spheremap, use_toon, false)
OBJECT_TEC(MainTecBS0, "object_ss", use_texture, use_spheremap, use_toon, true)


///////////////////////////////////////////////////////////////////////////////////////////////
