//-----------------------------------------------------------------------------
//
//-----------------------------------------------------------------------------

#define BOLD_AWARE		1	// ���{�̑������l�����邩?
#define DEPTH_AWARE		1	// �[�x���l������ (�ʓr�A�[�x���o�͂���G�t�F�N�g���K�v)
#define FAKE_OVEREXPOSURE	1	// ���邢�����𔒔�т�����

float phase = 0.5;			// ���̕����Ǝ����̊p�x���̉e��
float lightIntensity = 0.5;	// ���C�g�̖��邳

//-----------------------------------------------------------------------------
// ���f���̏���

float MinHeight = -20;		// ������Ԃ̒���
float MaxHeight = -200;		// �ő咷��

float MinRadius = 0.05 * 0.95; // ���f���������������ɂ���
float MaxRadius = 2.5 * 0.95;
float MaxBottomRadius = 19.95 * 0.95;


#define DEPTHMAP_NAME	PostDepthMapRT
#define FAR_DEPTH		1000.0

//-----------------------------------------------------------------------------


#define DECLARE_PARAM(_t,_var,_item)	\
	_t _var : CONTROLOBJECT < string name = "(self)"; string item = _item;>;
#define DECLARE_FUNC(_var, _t,  _varBody, _itemBody) \
	DECLARE_PARAM(_t, _varBody##_var, _itemBody #_var)
#define DECLARE_SET(_t, _varBody, _itemBody)	\
	DECLARE_FUNC(1, _t, _varBody, _itemBody) \
	DECLARE_FUNC(2, _t, _varBody, _itemBody) \
	DECLARE_FUNC(3, _t, _varBody, _itemBody) \
	DECLARE_FUNC(4, _t, _varBody, _itemBody) \
	DECLARE_FUNC(5, _t, _varBody, _itemBody) \
	DECLARE_FUNC(6, _t, _varBody, _itemBody) \
	DECLARE_FUNC(7, _t, _varBody, _itemBody) \
	DECLARE_FUNC(8, _t, _varBody, _itemBody)

DECLARE_PARAM(float, heightScale, "����");
DECLARE_PARAM(float, boldScale, "����");
DECLARE_PARAM(float, radiusScale, "�X�v���b�h");

DECLARE_PARAM(float, brightnessAll, "�S�̖��x");
DECLARE_SET(float, brightness, "���x")

DECLARE_SET(float4x4, mat, "��]")


//-----------------------------------------------------------------------------

// ���@�ϊ��s��
float4x4 matWVP		: WORLDVIEWPROJECTION;
float4x4 matW		: WORLD;

float3	LightDirection	: DIRECTION < string Object = "Light"; >;
float3	CameraPosition	: POSITION  < string Object = "Camera"; >;

float2 ViewportSize : VIEWPORTPIXELSIZE;
static float2 ViewportOffset = (float2(0.5,0.5)/ViewportSize);

// �}�e���A���F
float4	MaterialDiffuse		: DIFFUSE  < string Object = "Geometry"; >;
float3	MaterialAmbient		: AMBIENT  < string Object = "Geometry"; >;
float3	MaterialEmissive	: EMISSIVE < string Object = "Geometry"; >;
float3	MaterialSpecular	: SPECULAR < string Object = "Geometry"; >;
float	SpecularPower		: SPECULARPOWER < string Object = "Geometry"; >;
float3	MaterialToon		: TOONCOLOR;
float4	EdgeColor			: EDGECOLOR;
float4	GroundShadowColor	: GROUNDSHADOWCOLOR;

// �e�N�X�`���ގ����[�t�l
float4	TextureAddValue	: ADDINGTEXTURE;
float4	TextureMulValue	: MULTIPLYINGTEXTURE;
float4	SphereAddValue	: ADDINGSPHERETEXTURE;
float4	SphereMulValue	: MULTIPLYINGSPHERETEXTURE;

bool	use_texture;		// �e�N�X�`���t���O

// �[�x�}�b�v
shared texture DEPTHMAP_NAME : OFFSCREENRENDERTARGET;
sampler DepthMap = sampler_state {
	texture = <DEPTHMAP_NAME>;
	MinFilter = POINT;	MagFilter = POINT;	MipFilter = NONE;
	AddressU  = CLAMP; AddressV  = CLAMP;
};

// �I�u�W�F�N�g�̃e�N�X�`��
texture ObjectTexture: MATERIALTEXTURE;
sampler ObjTexSampler = sampler_state {
	texture = <ObjectTexture>;
	MINFILTER = LINEAR;	MAGFILTER = LINEAR;	MIPFILTER = LINEAR;
	ADDRESSU  = WRAP;	ADDRESSV  = WRAP;
};

float4x4 GetInverseMatrix(float4x4 mat)
{
	float3x3 matRot = transpose((float3x3)mat);
	return float4x4(
		matRot[0], 0,
		matRot[1], 0,
		matRot[2], 0,
		mul(-mat._41_42_43, matRot), 1);
}

// �K���}�␳
const float gamma = 2.2;
const float epsilon = 1.0e-6;

float3 Degamma(float3 col) { return pow(max(col,epsilon), gamma); }
float3 Gamma(float3 col) { return pow(max(col,epsilon), 1.0/gamma); }
float4 Degamma4(float4 col) { return float4(Degamma(col.rgb), col.a); }
float4 Gamma4(float4 col) { return float4(Gamma(col.rgb), col.a); }

float Luminance(float3 rgb)
{
	return dot(float3(0.299, 0.587, 0.114), max(rgb,0));
}


bool bLinearBegin : CONTROLOBJECT < string name = "ikLinearBegin.x"; >;
bool bLinearEnd : CONTROLOBJECT < string name = "ikLinearEnd.x"; >;
static bool bOutputLinear = (bLinearEnd && !bLinearBegin);


//-----------------------------------------------------------------------------
// �I�u�W�F�N�g�`��

struct VS_OUTPUT {
	float4 Pos		: POSITION;		// �ˉe�ϊ����W
	float2 Tex		: TEXCOORD0;	// �e�N�X�`��
	float4 LPos		: TEXCOORD1;
	float4 LCamPos	: TEXCOORD2;
	float4 Coef		: TEXCOORD3;
	float4 PPos		: TEXCOORD4;
	float4 Color	: COLOR0;		// �f�B�t���[�Y�F
};


float4 CalcCoef()
{
	float h = lerp(MinHeight, MaxHeight, heightScale);
	float rMin = lerp(MinRadius, MaxRadius, boldScale);
	float rMax = rMin + MaxBottomRadius * radiusScale;

	#if BOLD_AWARE == 1
	float k = (rMax - rMin) / h;
	#else
	float k = rMax / h;
	#endif

	return float4(h, rMin, rMax, k);
}

float CalcFalloff(float sqrdist, float range)
{
	float d = max(sqrdist, 0.1 * 0.1) / (range * range);
	float d2 = d * d;
	float n = saturate(1.0 - d2);
	return n * n / (d2 + 1.0);
}


float CalcBrightness(float3 lpos, float3 p, float4 coef, float screenDepth)
{
	float h = coef.x;
	float rMin = coef.y;
	float rMax = coef.z;

	// p + d * t �����[�J�����W�n�ł̐���
	float3 d = normalize(lpos - p);

#if BOLD_AWARE == 1
	float k = coef.w;
	float ka = k * k + 1.0;
	float kb = 2.0 * rMin * k;
	float kc = rMin * rMin;

	float A = dot(d, d) - d.y*d.y * ka;
	float B =(dot(d, p) - d.y*p.y * ka) * 2.0 - d.y * kb;
	float C = dot(p, p) - p.y*p.y * ka		  - p.y * kb - kc;

#else
	// NOTE: �l�b�g��ɂ��锻�莮�͂��������Y��ɕό`���Ă��邪�A
	// ���p��e���Ȃ��̂ŁA�G�Ȃ܂܂ɂ���B
	float r = rMax;
	float k = coef.w;
	float k2 = k * k + 1.0;

	float A = dot(d, d) - d.y*d.y * k2;
	float B =(dot(d, p) - d.y*p.y * k2) * 2.0;
	float C = dot(p, p) - p.y*p.y * k2;
#endif

	A = (abs(2.0 * A) > epsilon) ? A : epsilon;
	float D = sqrt(max(B * B - 4.0 * A * C, 0.0));
	float2 t = (-B + float2(-D, D)) / (2 * A);
	t = (t.x < t.y) ? t.xy : t.yx;

	// ����Ɖ����`�F�b�N
	float denom = abs(d.y) > epsilon ? d.y : epsilon;
	float2 tNearFar = (float2(0, h) - p.y) / denom;
	if (denom < 0.0) // ������
	{
		// ���������Ƀq�b�g
		if (t.y < tNearFar.x) t.xy = tNearFar.y;
		// �Б����������Ńq�b�g
		else if (t.x < tNearFar.x) t.xy = float2(t.y, tNearFar.y);
		t.xy = clamp(t.xy, tNearFar.x, tNearFar.y);
	}
	else // �����
	{
		if (t.x > tNearFar.x) t.xy = tNearFar.x;
		else if (t.y > tNearFar.x) t.xy = float2(0, t.x);
		t.xy = clamp(t.xy, tNearFar.y, tNearFar.x);
	}

	// �J��������͖���
	t = max(t, 0);

	#if DEPTH_AWARE
	t = min(t, screenDepth);
	#endif

#if 0
	// �ȈՌv�Z

	float2 yt = p.y + d.y * t.xy;	// ����

	#if BOLD_AWARE == 1
	float2 rt = yt * k + rMin;
	#else
	float2 rt = yt * k;
	#endif
	float l = max((rt.x + rt.y) * 2.0 / 2.0, 1.0);
	float brightness = abs(t.x - t.y) / l;

	// ��[�قǔ�������
	float2 z = yt / h;
	float2 invZ2 = 1.0 / (z * z) * (1.0 - z);
	brightness *= saturate((invZ2.x + invZ2.y) * 0.5);

#else
	// ���C�}�[�`

	#define ITER	8

	float td = (t.y - t.x) * 0.5 / ITER;
	float4 p0 = float4(p + d * (t.x + td), 0);
	float4 p1 = float4(p + d * (t.y - td), 0);
	#if BOLD_AWARE == 1
		p0.w = 1.0 / max(p0.y * k + rMin, epsilon);
		p1.w = 1.0 / max(p1.y * k + rMin, epsilon);
	#else
		p0.w = 1.0 / max(p0.y * k, epsilon);
		p1.w = 1.0 / max(p1.y * k, epsilon);
	#endif

	float dt = abs(t.y - t.x) / ITER; // 1�X�e�b�v�Ői�ދ���

	float brightness = 0;
	for(int i = 0; i < ITER; i++)
	{
		float4 p00 = lerp(p0, p1, i * 1.0 / (ITER - 1));
		float dir = saturate(1 - length(p00.xz) * p00.w);
		float r00 = (dt * p00.w / 2.0);
		float z = length(p00.xyz) * (1.0 / abs(h));
		float invZ2 = 1.0 / (z * z);
		brightness += invZ2 * (1.0 - z) * dir * r00;
	}
#endif

	#if BOLD_AWARE == 1
	// ���{�����B���邳�͉�
	// �[�x�`�F�b�N�̉e�����󂯂�
	float3 pNear = p + d * tNearFar.x;
	float center = pNear.y * k + rMin;
	brightness += (length(pNear.xz) < center) * (p.y < 0) * 5000.0;
	#endif

	// �����ɂ�鋭�x�̕ω�
	brightness *= lerp(1, d.y * 0.5 + 0.5, phase);

	return brightness * lightIntensity;
}



VS_OUTPUT Object_VS(
	float4 Pos : POSITION, float3 Normal : NORMAL, float2 Tex : TEXCOORD0,
	uniform bool useTexture, uniform float4x4 matJointW, uniform float brightness)
{
	VS_OUTPUT Out = (VS_OUTPUT)0;

	float visible = (saturate(1.0 - brightness) * saturate(1.0 - brightnessAll) * MaterialDiffuse.a > 0.0);

	Out.Pos = mul( Pos, matWVP );
	Out.PPos = Out.Pos;
	Out.Pos.w *= visible > 0.0;

	Out.Tex = Tex;
	Out.Color.rgb = MaterialEmissive;
	Out.Color.a = MaterialDiffuse.a;
	Out.Color = saturate( Out.Color );

	float4x4 matWInv = GetInverseMatrix(matJointW);
	Out.LPos = mul(mul(Pos, matW), matWInv);
	Out.LCamPos.xyz = mul(float4(CameraPosition, 1), matWInv).xyz;
	Out.Coef = CalcCoef();

	return Out;
}

float4 Object_PS(VS_OUTPUT IN, uniform bool useTexture) : COLOR
{
	float4 Color = IN.Color;

	#if DEPTH_AWARE
	float2 texCoord = IN.PPos.xy / IN.PPos.w * float2(0.5, -0.5) + 0.5 + ViewportOffset;
	float depth = tex2D(DepthMap, texCoord).x * FAR_DEPTH;
	#else
	float depth = 0;
	#endif

	if ( useTexture )
	{
		float4 TexColor = tex2D( ObjTexSampler, IN.Tex );
		float3 morphColor = TexColor * TextureMulValue + TextureAddValue;
		float morphAlpha = TextureMulValue.a + TextureAddValue.a;
		TexColor.rgb = lerp(1, morphColor, morphAlpha);
		Color *= TexColor;
	}

	float brightness = CalcBrightness(IN.LPos.xyz, IN.LCamPos.xyz, IN.Coef, depth) * Color.a;
	clip(brightness - 1.0/1024.0);

	Color.rgb *= brightness;

	#if FAKE_OVEREXPOSURE
	// ���邢�����𔒂���΂�
	Color.rgb += max(float3(Color.g + Color.b, Color.r + Color.b, Color.r + Color.g) - Color.rgb, 0) * 0.05;
	#endif

	Color.rgb = bOutputLinear ? clamp(Color, 0, 8) : Gamma(saturate(Color.rgb));

	return float4(Color.rgb, 1);
}

#define OBJECT_TEC(name, mmdpass, tex, _subset, _mat, _br) \
	technique name < string MMDPass = mmdpass; string Subset = _subset;> { \
		pass DrawObject { \
			ZENABLE = FALSE;	ZWRITEENABLE = FALSE; \
			SRCBLEND = SRCALPHA;		DESTBLEND = ONE; \
			VertexShader = compile vs_3_0 Object_VS(tex, _mat, _br); \
			PixelShader  = compile ps_3_0 Object_PS(tex); \
		} \
	}

#define DECLARE_TEC(_var, _var2, _mmdpass) \
	OBJECT_TEC(MainTec##_mmdpass##_var, #_mmdpass, use_texture, #_var, mat##_var2, brightness##_var2)

#define DECLARE_TEC_SET(_mmdpass)	\
	DECLARE_TEC(0, 1, _mmdpass) \
	DECLARE_TEC(1, 2, _mmdpass) \
	DECLARE_TEC(2, 3, _mmdpass) \
	DECLARE_TEC(3, 4, _mmdpass) \
	DECLARE_TEC(4, 5, _mmdpass) \
	DECLARE_TEC(5, 6, _mmdpass) \
	DECLARE_TEC(6, 7, _mmdpass) \
	DECLARE_TEC(7, 8, _mmdpass)

DECLARE_TEC_SET(object)
DECLARE_TEC_SET(object_ss)

technique EdgeTec < string MMDPass = "edge"; > {}
technique ShadowTec < string MMDPass = "shadow"; > {}
technique ZplotTec < string MMDPass = "zplot"; > {}

//-----------------------------------------------------------------------------
