////////////////////////////////////////////////////////////////////////////////////////////////
// �N���X�^��

////////////////////////////////////////////////////////////////////////////////////////////////
// �p�����[�^�錾

// ���ܗ��B���ܗ����傫���قǘc�ށB
// 1.0�`2.5�B��C=1.0�A�X=1.3�A��=1.33�A����=1.55�A�_�C�A�����h=2.41 ���x�B
float IoR = 1.30;		// ���f���̋��ܗ�
float IoRAir = 1.00;	// ���f���̊O���̋��ܗ�(�ʏ�͋�C)

// ���݂ɉ����ĐF�̔Z���Ȃ闦�B0.0�`2.0���x?
float ColorAttenuationScale = 0.2;

// �^���I�Ȍ��݁B���܂���ʂ������I�ɑ��₷
#define DUMMY_TICKNESS	(3.0)

// �F���Â����闦�B(0.0�`1.0)
#define TINT_COLOR	float3(0.95, 0.95, 0.95)

// ���ʂ��l�����邩?
// 0: ���ʂ𖳎�����B1:���ʂ��l������B
// ���ʂ��g���Ƃ䂪�݂����G�ɂȂ�B�v�Z���d���Ȃ�
#define ENABLE_BACKFACE	0

// �f�荞�݂ɐF�Y�����N�������邩?
// 0:�����B1:�L��
#define ENABLE_DISPERSION		0

// �F�Y���v�Z�̉񐔁B(8�`16)
#define DIV_NUM	8


/////////////////////////////////////////////////////////////////////////////////////////////


// ���@�ϊ��s��
float4x4 WorldViewProjMatrix		: WORLDVIEWPROJECTION;
float4x4 WorldViewMatrix			: WORLDVIEW;
float4x4 WorldMatrix				: WORLD;
float4x4 ViewMatrix					: VIEW;
float4x4 LightWorldViewProjMatrix : WORLDVIEWPROJECTION < string Object = "Light"; >;

float3 LightDirection	: DIRECTION < string Object = "Light"; >;
float3 CameraPosition	: POSITION  < string Object = "Camera"; >;

// �}�e���A���F
float4   MaterialDiffuse   : DIFFUSE  < string Object = "Geometry"; >;
float3   MaterialAmbient   : AMBIENT  < string Object = "Geometry"; >;
float3   MaterialEmmisive  : EMISSIVE < string Object = "Geometry"; >;
float3   MaterialSpecular  : SPECULAR < string Object = "Geometry"; >;
float	SpecularPower	 : SPECULARPOWER < string Object = "Geometry"; >;
float3   MaterialToon	  : TOONCOLOR;
float4   EdgeColor		 : EDGECOLOR;
float4   GroundShadowColor : GROUNDSHADOWCOLOR;
// ���C�g�F
float3   LightDiffuse	  : DIFFUSE   < string Object = "Light"; >;
float3   LightAmbient	  : AMBIENT   < string Object = "Light"; >;
float3   LightSpecular	 : SPECULAR  < string Object = "Light"; >;
static float4 DiffuseColor  = MaterialDiffuse  * float4(LightDiffuse, 1.0f);

bool	use_texture;		//	�e�N�X�`���t���O
bool	use_spheremap;		//	�X�t�B�A�t���O
bool	use_toon;			//	�g�D�[���t���O
bool	use_subtexture;		// �T�u�e�N�X�`���t���O

bool	 parthf;	// �p�[�X�y�N�e�B�u�t���O
bool	 transp;	// �������t���O
bool	 spadd;		// �X�t�B�A�}�b�v���Z�����t���O
#define SKII1	1500
#define SKII2	8000
#define Toon	 3

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


#if defined(ENABLE_BACKFACE) && ENABLE_BACKFACE > 0
// �������̖@����`��
float4 ClearColor = {0,0,0,0};
float ClearDepth  = 1.0;
#define BufferSize	float2 ViewPortRatio = {1.0,1.0}

texture NormalTex : RenderColorTarget
<
	BufferSize;
	string Format = "A16B16G16R16F" ;
>;
sampler NormalSampler = sampler_state {
	texture = <NormalTex>;
	MINFILTER = POINT; MAGFILTER = POINT;
};
texture2D DepthBuffer : RENDERDEPTHSTENCILTARGET <
	BufferSize;
	string Format = "D24S8";
>;
#endif

// �����̏ꍇ�AF0��rgb���ɈقȂ�l������
inline float CalcFresnel(float NV, float F0)
{
	float fc = pow(max(1 - NV, 1e-5), 5);
	return (1.0 - F0) * fc + F0;
}

//�X�y�L�����̌v�Z
float CalcSpecular(float3 L, float3 N, float3 V, float smoothness, float f0)
{
	float3 H = normalize(L + V);

	float a = max(1 - smoothness, 1e-3);
	a *= a;

	float NH = saturate(dot(N, H));
	float NL = saturate(dot(N, L));
	float LH = saturate(dot(L, H));

	float CosSq = (NH * NH) * (a - 1) + 1;
	float D = a / (CosSq * CosSq);
	float F = CalcFresnel(LH, f0);

	float k2 = a * a * 0.25;
	float vis = (1.0/4.0) / (LH * LH * (1 - k2) + k2);
	return saturate(NL * D * F * vis);
}


// https://www.shadertoy.com/view/Ms2XRt
inline float3 WaveLength2XYZ(float w)
{
	// based on the informations from http://jcgt.org/published/0002/02/01/paper.pdf
	float4 t = float4(log((w + 570.1) / 1014.0), log((1338.0 - w) / 743.5), (w - 556.1) / 46.14, log((w - 265.8) / 180.4));  
	t = float4(0.398, 1.132, 1.011, 2.060) * exp(float4(-1250.0, -234.0, -0.5, -32.0) * (t * t));
	return float3(t.x + t.y, t.zw);
}

// based from the informations from CIE RGB http://www.brucelindbloom.com/index.html?Eqn_RGB_XYZ_Matrix.html 
float3x3 matXYZ2CIERGB = {
	 2.3706743,-0.9000405,-0.4706338,
	-0.5138850, 1.4253036, 0.0885814,
	 0.0052982,-0.0146949, 1.0093968};


////////////////////////////////////////////////////////////////////////////////////////////////

technique EdgeTec < string MMDPass = "edge"; > {}
technique ShadowTec < string MMDPass = "shadow"; > {}
technique ZplotTec < string MMDPass = "zplot"; > {}


///////////////////////////////////////////////////////////////////////////////////////////////
// �I�u�W�F�N�g�`��

struct VS_OUTPUT {
	float4 Pos		: POSITION;		// �ˉe�ϊ����W
	float4 ZCalcTex	: TEXCOORD0;	// Z�l
	float2 Tex		: TEXCOORD1;	// �e�N�X�`��
	float3 Normal	: TEXCOORD2;	// �@��
	float3 Eye		: TEXCOORD3;	// �J�����Ƃ̑��Έʒu
	float2 SpTex	: TEXCOORD4;	// �X�t�B�A�}�b�v�e�N�X�`�����W
	float4 PPos		: TEXCOORD5;
	float4 VPos		: TEXCOORD6;
};



VS_OUTPUT Normal_VS(float4 Pos : POSITION, float3 Normal : NORMAL, float2 Tex : TEXCOORD0, float2 Tex2 : TEXCOORD1)
{
	VS_OUTPUT Out = (VS_OUTPUT)0;
	
	// �J�������_�̃��[���h�r���[�ˉe�ϊ�
	Out.Pos = mul( Pos, WorldViewProjMatrix );
	Out.VPos = mul( Pos, WorldViewMatrix ); // �[�x�o�͗p

	// ���_�@��
	Out.Normal = normalize( mul( Normal, (float3x3)WorldMatrix ) );

	// �e�N�X�`�����W
	Out.Tex = Tex;

	return Out;
}

float4 Normal_PS(VS_OUTPUT IN) : COLOR
{
	return float4(IN.Normal, IN.VPos.z);
}


// ���_�V�F�[�_
VS_OUTPUT Object_VS(float4 Pos : POSITION, float3 Normal : NORMAL, float2 Tex : TEXCOORD0, float2 Tex2 : TEXCOORD1, uniform bool useSphereMap, uniform bool useSelfshadow)
{
	VS_OUTPUT Out = (VS_OUTPUT)0;
	
	// �J�������_�̃��[���h�r���[�ˉe�ϊ�
	Out.Pos = mul( Pos, WorldViewProjMatrix );
	Out.PPos = Out.Pos;
	Out.VPos = mul( Pos, WorldViewMatrix ); // �[�x�o�͗p

	// �J�����Ƃ̑��Έʒu
	Out.Eye = CameraPosition - mul( Pos, WorldMatrix ).xyz;
	// ���_�@��
	Out.Normal = normalize( mul( Normal, (float3x3)WorldMatrix ) );

	if (useSelfshadow)
	{
		// ���C�g���_�ɂ�郏�[���h�r���[�ˉe�ϊ�
		Out.ZCalcTex = mul( Pos, LightWorldViewProjMatrix );
	}

	// �e�N�X�`�����W
	Out.Tex = Tex;

	if ( useSphereMap ) {
		if ( use_subtexture ) {
			// PMX�T�u�e�N�X�`�����W
			Out.SpTex = Tex2;
		} else {
			// �X�t�B�A�}�b�v�e�N�X�`�����W
			float2 NormalWV = mul( Out.Normal, (float3x3)ViewMatrix ).xy;
			Out.SpTex.x = NormalWV.x * 0.5f + 0.5f;
			Out.SpTex.y = NormalWV.y * -0.5f + 0.5f;
		}
	}
	
	return Out;
}


float4 RefractionColor(float2 uv, float3 N, float3 BackN, float3 V, float tickness1, float tickness2)
{
#if defined(ENABLE_DISPERSION) && ENABLE_DISPERSION > 0
	// �F��������
	float3 TexColor = 0;
	float3 Weight = 0;

	for(int i = 0; i < DIV_NUM; i++)
	{
		float t = i / (1.0 * DIV_NUM);
		float wl = lerp(420.0, 630.0, t);
		// �K���ȋ��ܗ�
		float IoR0 = 1.0 + (IoR - 1.0) * (550.0 / wl * 0.25 + 0.75);
		float3 waveCol = mul(WaveLength2XYZ(wl), matXYZ2CIERGB);

		float3 RWorld = refract(V, N, IoRAir / IoR0);
		float3 RWorld2 = refract(RWorld, -BackN, IoR0 / IoRAir);
		float2 R1 = normalize(mul(RWorld, (float3x3)ViewMatrix)).xy;
		float2 R2 = normalize(mul(RWorld2, (float3x3)ViewMatrix)).xy;

		float2 uv0 = uv;
		uv0 += R1 * tickness1;
		uv0 += R2 * tickness2;
		float4 TexColor0 = tex2D( ObjTexSampler, uv0 );
		TexColor += TexColor0.rgb * waveCol;
		Weight += waveCol;
	}

	return float4(TexColor / Weight, 1);
#else
	// �F�����Ȃ�
	float3 RWorld = refract(V, N, IoRAir / IoR);
	float3 RWorld2 = refract(RWorld, -BackN, IoR / IoRAir);
	float2 R1 = normalize(mul(RWorld, (float3x3)ViewMatrix)).xy;
	float2 R2 = normalize(mul(RWorld2, (float3x3)ViewMatrix)).xy;
	uv += R1 * tickness1; // (tickness + DUMMY_TICKNESS) / IN.PPos.w;
	uv += R2 * tickness2; // (1.0 + DUMMY_TICKNESS) / IN.PPos.w;
	float4 TexColor = tex2D( ObjTexSampler, uv );
	return TexColor;
#endif
}



float4 Object_PS(VS_OUTPUT IN, uniform bool useSphereMap, uniform bool useSelfshadow) : COLOR
{
	float3 N = normalize(IN.Normal);
	float3 V = normalize(IN.Eye);

	float4 Color = MaterialDiffuse;

	float2 uv = IN.PPos.xy / IN.PPos.w * float2(0.5, -0.5) + 0.5;

	#if defined(ENABLE_BACKFACE) && ENABLE_BACKFACE > 0
	float4 BackfaceNormal = tex2D( NormalSampler, uv);
	float tickness = max(BackfaceNormal.w - IN.VPos.z, 0);
	float3 BackN = normalize(BackfaceNormal.xyz - N * 0.001);
	#else
	// �K���Ȍ��݂Ɨ��̖@��
	float tickness = 5.0;
	float3 BackN = -N;
	#endif

	// ���݂ɉ����ĐF����ς���
	//Color.rgb = pow(Color.rgb * 0.99, tickness * ColorAttenuationScale + 1.0);
	Color.rgb = exp(-(1 - Color.rgb * 0.99) * tickness * ColorAttenuationScale);

	// �X�y�L����(�K��)
	float3 Specular = CalcSpecular(-LightDirection, N, V, 0.8, 0.2);
	Specular += CalcSpecular( LightDirection, N, V, 0.8, 0.2) * 0.5;
	Specular += CalcSpecular(-LightDirection, -BackN, V, 0.8, 0.2) * 0.5 * Color.rgb;
	Specular = Specular * 0.9 * LightSpecular + 0.1;

	float ticknessInside = (tickness + DUMMY_TICKNESS) / IN.PPos.w;
	float ticknessOutside = (1.0 + DUMMY_TICKNESS) / IN.PPos.w;
	Color *= RefractionColor(uv, N, BackN, V, ticknessInside, ticknessOutside);

	Color.rgb *= TINT_COLOR; // �����Â�����

	if ( useSphereMap ) {
		if(spadd) {
			float4 TexColor = tex2D(ObjSphareSampler,IN.SpTex);
			Color.rgb += TexColor.rgb;
		}
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

	// �X�y�L�����K�p
	Color.rgb += Specular / max(Color.a, 0.01);

	return Color;
}

#if defined(ENABLE_BACKFACE) && ENABLE_BACKFACE > 0
#define SCRIPT_STRING	\
		string Script = \
			"RenderColorTarget0=NormalTex;" \
			"RenderDepthStencilTarget=DepthBuffer;" \
			"ClearSetColor=ClearColor;	Clear=Color;" \
			"ClearSetDepth=ClearDepth;	Clear=Depth;" \
			"Pass=DrawNormal;" \
		\
			"RenderColorTarget0=;" \
			"RenderDepthStencilTarget=;" \
			"Pass=DrawObject;"; \

#else
#define SCRIPT_STRING	\
		string Script = \
			"Pass=DrawObject;"; \

#endif

#define OBJECT_TEC(name, mmdpass, sphere, selfshadow) \
	technique name < string MMDPass = mmdpass; SCRIPT_STRING > { \
		pass DrawNormal { \
			CullMode = CW; /*ZFunc = Greater;*/ \
			VertexShader = compile vs_3_0 Normal_VS(); \
			PixelShader  = compile ps_3_0 Normal_PS(); \
		} \
		pass DrawObject { \
			VertexShader = compile vs_3_0 Object_VS(sphere, selfshadow); \
			PixelShader  = compile ps_3_0 Object_PS(sphere, selfshadow); \
		} \
	}

OBJECT_TEC(MainTec0, "object", use_spheremap, false)
OBJECT_TEC(MainTecBS0, "object_ss", use_spheremap, true)


///////////////////////////////////////////////////////////////////////////////////////////////
