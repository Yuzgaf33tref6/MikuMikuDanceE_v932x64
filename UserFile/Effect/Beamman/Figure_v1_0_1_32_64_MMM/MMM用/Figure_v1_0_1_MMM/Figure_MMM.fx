//Figure�G�t�F�N�gforMMM

//�t�B�M���A���ۂ��������V�F�[�_����^ ver1.1
//�r�[���}��P

//�@���}�b�v�g�p�t���O
//�@//#define�`�@�ƁA//������ƗL����
#define USE_NORMALMAP

//�X�y�L�����X�P�[��
float SpecularScale <
   string UIName = "SpecularScale";
   string UIWidget = "Slider";
   string UIHelp = "�X�y�L�����X�P�[��";
   bool UIVisible =  true;
   float UIMin = 0;
   float UIMax = 2;
> = 0.5;

//�n�[�t�����o�[�g�W�� 0�Ń����o�[�g���� 1�Ńn�[�t�����o�[�g����
float HalfLambParam <
   string UIName = "HalfLambParam";
   string UIWidget = "Slider";
   string UIHelp = "�n�[�t�����o�[�g�W��";
   bool UIVisible =  true;
   float UIMin = -3;
   float UIMax = 3;
> = 1.0;
//�������C�g���x
float RimPow <
   string UIName = "RimPow";
   string UIWidget = "Slider";
   string UIHelp = "�������C�g���x";
   bool UIVisible =  true;
   float UIMin = 0;
   float UIMax = 16;
> = 4.0;
//���Ȕ��F�}���l
float EmmisiveParam <
   string UIName = "EmmisiveParam";
   string UIWidget = "Slider";
   string UIHelp = "���Ȕ��F�}���l";
   bool UIVisible =  true;
   float UIMin = 0;
   float UIMax = 8;
> = 0.0;
//�V���h�E�Z��
float ShadowParam <
   string UIName = "ShadowParam";
   string UIWidget = "Slider";
   string UIHelp = "�V���h�E�Z��";
   bool UIVisible =  true;
   float UIMin = 0;
   float UIMax = 2;
> = 0.5;

//�ǂ��킩��Ȃ��l�͂������炳���Ȃ�
//�t�B�����C�g�F
float3 FillLight
<
   string UIName = "FillLight";
   string UIWidget = "Color";
   bool UIVisible =  true;
> = float3(200,190,180)/255.0;
//�o�b�N���C�g�F
float3 BackLight
<
   string UIName = "BackLight";
   string UIWidget = "Color";
   bool UIVisible =  true;
> = 0.8*float3(100,100,100)/255.0;
//�������C�g�F
float3 RimLight
<
   string UIName = "RimLight";
   string UIWidget = "Color";
   bool UIVisible =  true;
> = float3(150,150,150)/255.0;
//EX���C�g�F
float3 ExLight
<
   string UIName = "RimLight";
   string UIWidget = "Color";
   bool UIVisible =  true;
> = float3(150,150,150)/255.0;

//��F
float3 SkyColor
<
   string UIName = "SkyColor";
   string UIWidget = "Color";
   bool UIVisible =  true;
> = float3(0.9f, 0.9f, 1.0f);
//�n�ʐF
float3 GroundColor
<
   string UIName = "GroundColor";
   string UIWidget = "Color";
   bool UIVisible =  true;
> = float3(0.1f, 0.05f, 0.0f);
//�@���}�b�v���x
float MapParam = 8;

// �I�u�W�F�N�g�̃e�N�X�`��
texture ObjectTexture: MATERIALTEXTURE;
sampler ObjTexSampler = sampler_state {
    texture = <ObjectTexture>;
	MINFILTER = LINEAR;
	MAGFILTER = LINEAR;
	MIPFILTER = LINEAR;
};
// �X�t�B�A�}�b�v�̃e�N�X�`��
texture ObjectSphereMap: MATERIALSPHEREMAP;
sampler ObjSphareSampler = sampler_state {
    texture = <ObjectSphereMap>;
	MINFILTER = LINEAR;
	MAGFILTER = LINEAR;
	MIPFILTER = LINEAR;
};

texture2D NormalMap <
    string ResourceName = "NormalMap.png";
>;
sampler NormalMapSamp = sampler_state {
    texture = <NormalMap>;
	MINFILTER = LINEAR;
	MAGFILTER = LINEAR;
	MIPFILTER = LINEAR;
};


// �p�����[�^�錾

//���W�ϊ��s��
float4x4 WorldViewProjMatrix	: WORLDVIEWPROJECTION;
float4x4 WorldMatrix		: WORLD;
float4x4 ViewMatrix		: VIEW;

//���C�g�֘A
bool	 LightEnables[MMM_LightCount]		: LIGHTENABLES;		// �L���t���O
float4x4 LightWVPMatrices[MMM_LightCount]	: LIGHTWVPMATRICES;	// ���W�ϊ��s��
float3   LightDirection[MMM_LightCount]		: LIGHTDIRECTIONS;	// ����
float3   LightPositions[MMM_LightCount]		: LIGHTPOSITIONS;	// ���C�g�ʒu
float    LightZFars[MMM_LightCount]			: LIGHTZFARS;		// ���C�gzFar�l

//�ގ����[�t�֘A
float4	 AddingTexture		  : ADDINGTEXTURE;	// �ގ����[�t���ZTexture�l
float4	 AddingSphere		  : ADDINGSPHERE;	// �ގ����[�t���ZSphereTexture�l
float4	 MultiplyTexture	  : MULTIPLYINGTEXTURE;	// �ގ����[�t��ZTexture�l
float4	 MultiplySphere		  : MULTIPLYINGSPHERE;	// �ގ����[�t��ZSphereTexture�l

//�J�����ʒu
float3	 CameraPosition		: POSITION  < string Object = "Camera"; >;

// �}�e���A���F
float4   MaterialDiffuse	: DIFFUSE  < string Object = "Geometry"; >;
float3   MaterialAmbient	: AMBIENT  < string Object = "Geometry"; >;
float3   MaterialEmmisive	: EMISSIVE < string Object = "Geometry"; >;
float3   MaterialSpecular	: SPECULAR < string Object = "Geometry"; >;
float    SpecularPower		: SPECULARPOWER < string Object = "Geometry"; >;
float4   MaterialToon		: TOONCOLOR;
float4   EdgeColor			: EDGECOLOR;
float    EdgeWidth			: EDGEWIDTH;
float4   GroundShadowColor	: GROUNDSHADOWCOLOR;

bool	 spadd;    			// �X�t�B�A�}�b�v���Z�����t���O
bool     usetoontexturemap;	// Toon�e�N�X�`���t���O

// ���C�g�F
float3   LightDiffuses[MMM_LightCount]      : LIGHTDIFFUSECOLORS;
float3   LightAmbients[MMM_LightCount]      : LIGHTAMBIENTCOLORS;
float3   LightSpeculars[MMM_LightCount]     : LIGHTSPECULARCOLORS;

// ���C�g�F
static float4 DiffuseColor[3]  = { MaterialDiffuse * float4(LightDiffuses[0], 1.0f)
				 , MaterialDiffuse * float4(LightDiffuses[1], 1.0f)
				 , MaterialDiffuse * float4(LightDiffuses[2], 1.0f)};
static float3 AmbientColor[3]  = { saturate(MaterialAmbient * LightAmbients[0])
				 , saturate(MaterialAmbient * LightAmbients[1])
				 , saturate(MaterialAmbient * LightAmbients[2])};
static float3 SpecularColor[3] = { MaterialSpecular * LightSpeculars[0]
				 , MaterialSpecular * LightSpeculars[1]
				 , MaterialSpecular * LightSpeculars[2]};
///////////////////////////////////////////////////////////////////////////////////////////////
// �I�u�W�F�N�g�`��
struct VS_OUTPUT {
	float4 Pos		: POSITION;		// �ˉe�ϊ����W
	float2 Tex		: TEXCOORD0;	// �e�N�X�`��
	float4 SubTex	: TEXCOORD1;	// �T�u�e�N�X�`��/�X�t�B�A�}�b�v�e�N�X�`�����W
	float3 Normal	: TEXCOORD2;	// �@��
	float3 Eye		: TEXCOORD3;	// �J�����Ƃ̑��Έʒu
	float4 SS_UV1   : TEXCOORD4;	// �Z���t�V���h�E�e�N�X�`�����W
	float4 SS_UV2   : TEXCOORD5;	// �Z���t�V���h�E�e�N�X�`�����W
	float4 SS_UV3   : TEXCOORD6;	// �Z���t�V���h�E�e�N�X�`�����W
	float4 Color	: COLOR0;		// ���C�g0�ɂ��F
};

//==============================================
// ���_�V�F�[�_
// MikuMikuMoving�Ǝ��̒��_�V�F�[�_����(MMM_SKINNING_INPUT)
//==============================================
VS_OUTPUT Basic_VS(MMM_SKINNING_INPUT IN, uniform bool useTexture, uniform bool useSphereMap, uniform bool useToon, uniform bool useSelfShadow)
{
	VS_OUTPUT Out = (VS_OUTPUT)0;

	//================================================================================
	//MikuMikuMoving�Ǝ��̃X�L�j���O�֐�(MMM_SkinnedPositionNormal)�B���W�Ɩ@�����擾����B
	//================================================================================
	MMM_SKINNING_OUTPUT SkinOut = MMM_SkinnedPositionNormal(IN.Pos, IN.Normal, IN.BlendWeight, IN.BlendIndices, IN.SdefC, IN.SdefR0, IN.SdefR1);

	// ���_���W
	Out.Pos = mul(SkinOut.Position, WorldViewProjMatrix);

	// �J�����Ƃ̑��Έʒu
	Out.Eye = CameraPosition - mul( SkinOut.Position.xyz, WorldMatrix );
	// ���_�@��
	Out.Normal = normalize( mul( SkinOut.Normal, (float3x3)WorldMatrix ) );

	// �f�B�t���[�Y�F�{�A���r�G���g�F �v�Z
	float3 color = float3(0, 0, 0);
	float3 ambient = float3(0, 0, 0);
	float count = 0;
	for (int i = 0; i < 3; i++) {
		if (LightEnables[i]) {
			color += (float3(1,1,1) - color) * (max(0, DiffuseColor[i] * dot(Out.Normal, -LightDirection[i])));
			ambient += AmbientColor[i];
			count = count + 1.0;
		}
	}
	Out.Color.rgb = saturate(ambient / count + color);
	Out.Color.a = MaterialDiffuse.a;

	// �e�N�X�`�����W
	Out.Tex = IN.Tex;
	Out.SubTex.xy = IN.AddUV1.xy;

	if ( useSphereMap ) {
		// �X�t�B�A�}�b�v�e�N�X�`�����W
		float2 NormalWV = mul( Out.Normal, (float3x3)ViewMatrix );
		Out.SubTex.z = NormalWV.x * 0.5f + 0.5f;
		Out.SubTex.w = NormalWV.y * -0.5f + 0.5f;
	}
    
	if (useSelfShadow) {
		float4 dpos = mul(SkinOut.Position, WorldMatrix);
		//�f�v�X�}�b�v�e�N�X�`�����W
		Out.SS_UV1 = mul(dpos, LightWVPMatrices[0]);
		Out.SS_UV2 = mul(dpos, LightWVPMatrices[1]);
		Out.SS_UV3 = mul(dpos, LightWVPMatrices[2]);
		
		Out.SS_UV1.y = -Out.SS_UV1.y;
		Out.SS_UV2.y = -Out.SS_UV2.y;
		Out.SS_UV3.y = -Out.SS_UV3.y;

		Out.SS_UV1.z = (length(LightPositions[0] - SkinOut.Position) / LightZFars[0]);
		Out.SS_UV2.z = (length(LightPositions[1] - SkinOut.Position) / LightZFars[1]);
		Out.SS_UV3.z = (length(LightPositions[2] - SkinOut.Position) / LightZFars[2]);
	}

	return Out;
}


float3x3 compute_tangent_frame(float3 Normal, float3 View, float2 UV)
{
  float3 dp1 = ddx(View);
  float3 dp2 = ddy(View);
  float2 duv1 = ddx(UV);
  float2 duv2 = ddy(UV);

  float3x3 M = float3x3(dp1, dp2, cross(dp1, dp2));
  float2x3 inverseM = float2x3(cross(M[1], M[2]), cross(M[2], M[0]));
  float3 Tangent = mul(float2(duv1.x, duv2.x), inverseM);
  float3 Binormal = mul(float2(duv1.y, duv2.y), inverseM);

  return float3x3(normalize(Tangent), normalize(Binormal), Normal);
}

float4 CalcNormal(float2 Tex,float3 Eye,float3 Normal, bool useTexture)
{
	#ifndef USE_NORMALMAP
		return float4(Normal,1);
	#endif
	float4 Norm = 1;

    float2 tex = Tex* MapParam;
	float4 Color;
	float3 normal;
	
	float4 NormalColor = tex2D( NormalMapSamp, tex)*2;	

	NormalColor = NormalColor.rgba;
	NormalColor.a = 1;
	float3x3 tangentFrame = compute_tangent_frame(Normal, Eye, Tex);
	Norm.rgb = normalize(mul(NormalColor - 1.0f, tangentFrame));

	return Norm;
}

//�׃b�N�}�����z�v�Z�֐�
inline float CalcBeckman(float m, float cosbeta)
{
	return (
		exp(-(1-(cosbeta*cosbeta))/(m*m*cosbeta*cosbeta))
		/(4*m*m*cosbeta*cosbeta*cosbeta*cosbeta)
		);
}

//�t���l���v�Z�֐�
inline float CalcFresnel(float n, float c)
{
	float g = sqrt(n*n + c*c - 1);
	float T1 = ((g-c)*(g-c))/((g+c)*(g+c));
	float T2 = 1 + ( (c*(g+c)-1)*(c*(g+c)-1) )/( (c*(g-c)+1)*(c*(g-c)+1) );
	return 0.5 * T1 * T2;
}

//�X�y�L�����v�Z�֐�
inline float3 CalcSpecular(float3 L,float3 N,float3 V,float3 Col)
{
	float3 H = normalize(L + V);	//�n�[�t�x�N�g��

	float3 Specular = pow( max(0,dot( H, normalize(N) )), (1)) * (Col);
    return Specular;

	//�v�Z�Ɏg���p�x
	float NV = dot(N, V);
	float NH = dot(N, H);
	float VH = dot(V, H);
	float NL = dot(N, L);

	//Beckmann���z�֐�
	float D = CalcBeckman(0.35f, NH);

	//�􉽌�����
	float G = min(1, min(2*NH*NV/VH, 2*NH*NL/VH));

	//�t���l����
	float F = CalcFresnel(20.0f, dot(L, H));
	
	return max(0, F*D*G/NV)*1 * Col;
}


float4x4 HeadMat : CONTROLOBJECT < string name = "(self)"; string item = "��"; >;

//==============================================
// �s�N�Z���V�F�[�_
// ���͓͂��ɓƎ��`���Ȃ�
//==============================================
float4 Basic_PS(VS_OUTPUT IN, uniform bool useTexture, uniform bool useSphereMap, uniform bool useToon, uniform bool useSelfShadow) : COLOR0
{
	IN.Normal = CalcNormal(IN.Tex,normalize(IN.Eye),normalize(IN.Normal),useTexture).rgb;
	IN.Normal = normalize(IN.Normal);
	float3 HeadVec = -normalize(HeadMat[2]);


    float3 normal = IN.Normal;
	float3 Eye = normalize(IN.Eye);
	//float2 tex = IN.Tex;
	
	float4 texColor = float4(1,1,1,1);
	float  texAlpha = MultiplyTexture.a + AddingTexture.a;
	

	float comp = 1;
	// �Z���t�V���h�E
	if (useSelfShadow) {
		float3 shadow = MMM_GetToonColor(float4(0,0,0,1), IN.Normal, LightDirection[0], LightDirection[1], LightDirection[2]);
		float3 ss = MMM_GetSelfShadowToonColor(float4(0,0,0,1), IN.Normal, IN.SS_UV1, IN.SS_UV2, IN.SS_UV3, false, useToon);
		
		shadow = min(shadow,ss);
		
		comp *= shadow.x;
		
	    comp = lerp(1,comp,ShadowParam);
	}
    float4 Color = 0;
    Color.a = IN.Color.a;
	float half_mul = lerp(1,0.5,HalfLambParam);
	float half_add = lerp(0,0.5,HalfLambParam);
	
	for (int i = 0; i < 3; i++) {
		if (LightEnables[i]) {
    		AmbientColor[i].rgb = saturate(AmbientColor[i].rgb+MaterialEmmisive*EmmisiveParam);
    		Color.rgb 			+= comp*max(0,dot( normal, -LightDirection[i] )*half_mul+half_add) * AmbientColor[i] * LightAmbients[i] * 2;
		}
    }
	Color.rgb += max(0,dot( normal, normalize(normalize(-Eye) ) )*half_mul+half_add) * AmbientColor[0] * BackLight*2* LightAmbients[0] * 2;
	Color.rgb += max(0,dot( normal, normalize(Eye) )*half_mul+half_add) * AmbientColor[0] * FillLight*0.25* LightAmbients[0] * 2;
	Color.rgb += max(0,dot( normal, HeadVec)*half_mul+half_add) * AmbientColor[0] * LightAmbients[0] * ExLight;
	float3 N = normal;	//�@��
	float3 V = Eye;	//�����x�N�g��
    float amount = (dot( normal, float3(0,1,0) )+1) * 0.5;
    float3 HalfSphereL = lerp( GroundColor, SkyColor, amount );
    Color.rgb += HalfSphereL*0.1;
    Color.rgb += EmmisiveParam*AmbientColor[0];
	
	// �X�y�L�����F�v�Z
    float3 Specular = 
    				pow(CalcSpecular(normalize(-LightDirection[0]),N,V,1),SpecularPower)  * LightAmbients[0]
    ;		 
    float anti_sp = 1;//tex2D( SpMapSamp, tex).r;

    Specular *= anti_sp*SpecularScale;
    
	// �e�N�X�`���K�p
	if (useTexture) {
		texColor = tex2D(ObjTexSampler, IN.Tex);
		texColor.rgb = (texColor.rgb * MultiplyTexture.rgb + AddingTexture.rgb) * texAlpha + (1.0 - texAlpha);
	}
	Color.rgb *= texColor.rgb;

	// �X�t�B�A�}�b�v�K�p
	if ( useSphereMap ) {
		// �X�t�B�A�}�b�v�K�p
		if(spadd) Color.rgb = Color.rgb + (tex2D(ObjSphareSampler,IN.SubTex.zw).rgb * MultiplySphere.rgb + AddingSphere.rgb);
		else      Color.rgb = Color.rgb * (tex2D(ObjSphareSampler,IN.SubTex.zw).rgb * MultiplySphere.rgb + AddingSphere.rgb);
	}
	// �A���t�@�K�p
	Color.a = IN.Color.a * texColor.a;

	// �X�y�L�����K�p
	Color.rgb += Specular;
	
    //�ȈՃ������C�g
    Color.rgb += pow(1-saturate(max(0,dot( normal, normalize(Eye) ) )),RimPow)*RimLight * LightAmbients[0];
    
	/*
	//�X�y�L�����F�v�Z
	float3 HalfVector;
	float3 Specular = 0;
	for (int i = 0; i < 3; i++) {
		if (LightEnables[i]) {
			HalfVector = normalize( normalize(IN.Eye) + -LightDirection[i] );
			Specular += pow( max(0,dot( HalfVector, normalize(IN.Normal) )), SpecularPower ) * SpecularColor[i];
		}
	}

	// �e�N�X�`���K�p
	if (useTexture) {
		texColor = tex2D(ObjTexSampler, IN.Tex);
		texColor.rgb = (texColor.rgb * MultiplyTexture.rgb + AddingTexture.rgb) * texAlpha + (1.0 - texAlpha);
	}
	Color.rgb *= texColor.rgb;

	// �X�t�B�A�}�b�v�K�p
	if ( useSphereMap ) {
		// �X�t�B�A�}�b�v�K�p
		if(spadd) Color.rgb = Color.rgb + (tex2D(ObjSphareSampler,IN.SubTex.zw).rgb * MultiplySphere.rgb + AddingSphere.rgb);
		else      Color.rgb = Color.rgb * (tex2D(ObjSphareSampler,IN.SubTex.zw).rgb * MultiplySphere.rgb + AddingSphere.rgb);
	}
	// �A���t�@�K�p
	Color.a = IN.Color.a * texColor.a;

	// �Z���t�V���h�E�Ȃ��̃g�D�[���K�p
	float3 color;
	if (!useSelfShadow && useToon && usetoontexturemap ) {
		//================================================================================
		// MikuMikuMoving�f�t�H���g�̃g�D�[���F���擾����(MMM_GetToonColor)
		//================================================================================
		color = MMM_GetToonColor(MaterialToon, IN.Normal, LightDirection[0], LightDirection[1], LightDirection[2]);
		Color.rgb *= color;
	}
	// �X�y�L�����K�p
	Color.rgb += Specular;
	*/
	return Color;
}

//==============================================
// �I�u�W�F�N�g�`��e�N�j�b�N
// UseSelfShadow���Ǝ��ɒǉ�����Ă��܂��B
//==============================================
technique MainTec0 < string MMDPass = "object"; bool UseTexture = false; bool UseSphereMap = false; bool UseToon = false; bool UseSelfShadow = false; > {
    pass DrawObject {
        VertexShader = compile vs_3_0 Basic_VS(false, false, false, false);
        PixelShader  = compile ps_3_0 Basic_PS(false, false, false, false);
    }
}

technique MainTec1 < string MMDPass = "object"; bool UseTexture = true; bool UseSphereMap = false; bool UseToon = false; bool UseSelfShadow = false; > {
    pass DrawObject {
        VertexShader = compile vs_3_0 Basic_VS(true, false, false, false);
        PixelShader  = compile ps_3_0 Basic_PS(true, false, false, false);
    }
}

technique MainTec2 < string MMDPass = "object"; bool UseTexture = false; bool UseSphereMap = true; bool UseToon = false; bool UseSelfShadow = false; > {
    pass DrawObject {
        VertexShader = compile vs_3_0 Basic_VS(false, true, false, false);
        PixelShader  = compile ps_3_0 Basic_PS(false, true, false, false);
    }
}

technique MainTec3 < string MMDPass = "object"; bool UseTexture = true; bool UseSphereMap = true; bool UseToon = false; bool UseSelfShadow = false; > {
    pass DrawObject {
        VertexShader = compile vs_3_0 Basic_VS(true, true, false, false);
        PixelShader  = compile ps_3_0 Basic_PS(true, true, false, false);
    }
}

technique MainTec4 < string MMDPass = "object"; bool UseTexture = false; bool UseSphereMap = false; bool UseToon = true; bool UseSelfShadow = false; > {
    pass DrawObject {
        VertexShader = compile vs_3_0 Basic_VS(false, false, true, false);
        PixelShader  = compile ps_3_0 Basic_PS(false, false, true, false);
    }
}

technique MainTec5 < string MMDPass = "object"; bool UseTexture = true; bool UseSphereMap = false; bool UseToon = true; bool UseSelfShadow = false; > {
    pass DrawObject {
        VertexShader = compile vs_3_0 Basic_VS(true, false, true, false);
        PixelShader  = compile ps_3_0 Basic_PS(true, false, true, false);
    }
}

technique MainTec6 < string MMDPass = "object"; bool UseTexture = false; bool UseSphereMap = true; bool UseToon = true; bool UseSelfShadow = false; > {
    pass DrawObject {
        VertexShader = compile vs_3_0 Basic_VS(false, true, true, false);
        PixelShader  = compile ps_3_0 Basic_PS(false, true, true, false);
    }
}

technique MainTec7 < string MMDPass = "object"; bool UseTexture = true; bool UseSphereMap = true; bool UseToon = true; bool UseSelfShadow = false; > {
    pass DrawObject {
        VertexShader = compile vs_3_0 Basic_VS(true, true, true, false);
        PixelShader  = compile ps_3_0 Basic_PS(true, true, true, false);
    }
}
technique MainTec8 < string MMDPass = "object"; bool UseTexture = false; bool UseSphereMap = false; bool UseToon = false; bool UseSelfShadow = true; > {
    pass DrawObject {
        VertexShader = compile vs_3_0 Basic_VS(false, false, false, true);
        PixelShader  = compile ps_3_0 Basic_PS(false, false, false, true);
    }
}

technique MainTec9 < string MMDPass = "object"; bool UseTexture = true; bool UseSphereMap = false; bool UseToon = false; bool UseSelfShadow = true; > {
    pass DrawObject {
        VertexShader = compile vs_3_0 Basic_VS(true, false, false, true);
        PixelShader  = compile ps_3_0 Basic_PS(true, false, false, true);
    }
}

technique MainTec10 < string MMDPass = "object"; bool UseTexture = false; bool UseSphereMap = true; bool UseToon = false; bool UseSelfShadow = true; > {
    pass DrawObject {
        VertexShader = compile vs_3_0 Basic_VS(false, true, false, true);
        PixelShader  = compile ps_3_0 Basic_PS(false, true, false, true);
    }
}

technique MainTec11 < string MMDPass = "object"; bool UseTexture = true; bool UseSphereMap = true; bool UseToon = false; bool UseSelfShadow = true; > {
    pass DrawObject {
        VertexShader = compile vs_3_0 Basic_VS(true, true, false, true);
        PixelShader  = compile ps_3_0 Basic_PS(true, true, false, true);
    }
}

technique MainTec12 < string MMDPass = "object"; bool UseTexture = false; bool UseSphereMap = false; bool UseToon = true; bool UseSelfShadow = true; > {
    pass DrawObject {
        VertexShader = compile vs_3_0 Basic_VS(false, false, true, true);
        PixelShader  = compile ps_3_0 Basic_PS(false, false, true, true);
    }
}

technique MainTec13 < string MMDPass = "object"; bool UseTexture = true; bool UseSphereMap = false; bool UseToon = true; bool UseSelfShadow = true; > {
    pass DrawObject {
        VertexShader = compile vs_3_0 Basic_VS(true, false, true, true);
        PixelShader  = compile ps_3_0 Basic_PS(true, false, true, true);
    }
}

technique MainTec14 < string MMDPass = "object"; bool UseTexture = false; bool UseSphereMap = true; bool UseToon = true; bool UseSelfShadow = true; > {
    pass DrawObject {
        VertexShader = compile vs_3_0 Basic_VS(false, true, true, true);
        PixelShader  = compile ps_3_0 Basic_PS(false, true, true, true);
    }
}

technique MainTec15 < string MMDPass = "object"; bool UseTexture = true; bool UseSphereMap = true; bool UseToon = true; bool UseSelfShadow = true; > {
    pass DrawObject {
        VertexShader = compile vs_3_0 Basic_VS(true, true, true, true);
        PixelShader  = compile ps_3_0 Basic_PS(true, true, true, true);
    }
}


////////////////////////////////////////////////////////////////////////////////////////////////
// �֊s�`��

//==============================================
// ���_�V�F�[�_
//==============================================
float4 Edge_VS(MMM_SKINNING_INPUT IN) : POSITION 
{
	//================================================================================
	//MikuMikuMoving�Ǝ��̃X�L�j���O�֐�(MMM_SkinnedPosition)�B���W���擾����B
	//================================================================================
	MMM_SKINNING_OUTPUT SkinOut = MMM_SkinnedPositionNormal(IN.Pos, IN.Normal, IN.BlendWeight, IN.BlendIndices, IN.SdefC, IN.SdefR0, IN.SdefR1);

	float4 position = SkinOut.Position + float4(SkinOut.Normal, 0) * IN.EdgeWeight * EdgeWidth * distance(SkinOut.Position.xyz, CameraPosition);

	return mul( position, WorldViewProjMatrix );
}

//==============================================
// �s�N�Z���V�F�[�_
//==============================================
float4 Edge_PS() : COLOR
{
	// �֊s�F�œh��Ԃ�
	return EdgeColor;
}

//==============================================
// �֊s�`��e�N�j�b�N
//==============================================
technique EdgeTec < string MMDPass = "edge"; > {
	pass DrawEdge {
		AlphaBlendEnable = FALSE;
		AlphaTestEnable  = FALSE;

		VertexShader = compile vs_2_0 Edge_VS();
		PixelShader  = compile ps_2_0 Edge_PS();
	}
}


///////////////////////////////////////////////////////////////////////////////////////////////
// �e�i��Z���t�V���h�E�j�`��

//==============================================
// ���_�V�F�[�_
//==============================================
float4 Shadow_VS(MMM_SKINNING_INPUT IN) : POSITION
{
	//================================================================================
	//MikuMikuMoving�Ǝ��̃X�L�j���O�֐�(MMM_SkinnedPosition)�B���W���擾����B
	//================================================================================
	float4 position = MMM_SkinnedPosition(IN.Pos, IN.BlendWeight, IN.BlendIndices, IN.SdefC, IN.SdefR0, IN.SdefR1);

    // �J�������_�̃��[���h�r���[�ˉe�ϊ�
    return mul( position, WorldViewProjMatrix );
}

//==============================================
// �s�N�Z���V�F�[�_
//==============================================
float4 Shadow_PS() : COLOR
{
    return GroundShadowColor;
}

//==============================================
// �n�ʉe�`��e�N�j�b�N
//==============================================
technique ShadowTec < string MMDPass = "shadow"; > {
    pass DrawShadow {
        VertexShader = compile vs_2_0 Shadow_VS();
        PixelShader  = compile ps_2_0 Shadow_PS();
    }
}
///////////////////////////////////////////////////////////////////////////////////////////////
