////////////////////////////////////////////////////////////////////////////////////////////////
//
//  AD_Jet.fx ��Ԙc�݃G�t�F�N�g(�W�F�b�g���˂ɂ��c��, �@���E�[�x�}�b�v�쐬)
//  ( ActiveDistortion.fx ����Ăяo����܂��D�I�t�X�N���[���`��p)
//  �쐬: �j��P
//
////////////////////////////////////////////////////////////////////////////////////////////////
// �p�����[�^�錾

#ifndef MIKUMIKUMOVING

#define ControlModel  "(self)"  // �R���g���[�����f���t�@�C����
float4x4 BoneCenter : CONTROLOBJECT < string name = ControlModel; string item = "�Z���^�["; >;
float MorphScaleZ0M : CONTROLOBJECT < string name = ControlModel; string item = "���ˌ��k��"; >;
float MorphScaleZ0P : CONTROLOBJECT < string name = ControlModel; string item = "���ˌ��g��"; >;
float MorphScaleZ1M : CONTROLOBJECT < string name = ControlModel; string item = "���ː�k��"; >;
float MorphScaleZ1P : CONTROLOBJECT < string name = ControlModel; string item = "���ː�g��"; >;
float MorphScaleLM  : CONTROLOBJECT < string name = ControlModel; string item = "�����k��"; >;
float MorphScaleLP  : CONTROLOBJECT < string name = ControlModel; string item = "�����g��"; >;
float MorphUScaleP  : CONTROLOBJECT < string name = ControlModel; string item = "���h�炬�e"; >;
float MorphUScaleM  : CONTROLOBJECT < string name = ControlModel; string item = "���h�炬��"; >;
float MorphVScaleP  : CONTROLOBJECT < string name = ControlModel; string item = "���h�炬�e"; >;
float MorphVScaleM  : CONTROLOBJECT < string name = ControlModel; string item = "���h�炬��"; >;
float MorphVScroll  : CONTROLOBJECT < string name = ControlModel; string item = "�X�N���[��"; >;
float MorphV0Fade   : CONTROLOBJECT < string name = ControlModel; string item = "��t�F�[�h"; >;
float MorphV0FadeW  : CONTROLOBJECT < string name = ControlModel; string item = "��t�F�[�h��"; >;
float MorphDist     : CONTROLOBJECT < string name = ControlModel; string item = "�c�ݓx"; >;
static float ScaleZ0 = 1.0f + MorphScaleZ0P*19.0f - MorphScaleZ0M*19.0f/20.0f;
static float ScaleZ1 = 1.0f + MorphScaleZ1P*19.0f - MorphScaleZ1M*19.0f/20.0f;
static float ScaleL = 1.0f + MorphScaleLP*19.0f - MorphScaleLM*19.0f/20.0f;
static float ScaleU = 1.0f + MorphUScaleM*19.0f - MorphUScaleP*19.0f/20.0f;
static float ScaleV = 1.0f + MorphVScaleM*19.0f - MorphVScaleP*19.0f/20.0f;
static float ScrollSpeedV = -MorphVScroll * MorphVScroll * 10.0f;
static float FadeValue = MorphV0Fade;
static float FadeWidth = MorphV0FadeW;
static float DistFactor = 1.0f - sqrt(MorphDist);

#else

float MMMScaleZ0 < // ���ˌ��T�C�Y
   string UIName = "���ˌ�����";
   string UIWidget = "Slider";
   bool UIVisible =  true;
   float UIMin = -1.0;
   float UIMax = 1.0;
> = float( 0.0 );

float MMMScaleZ1 < // ���ː�T�C�Y
   string UIName = "���ː滲��";
   string UIWidget = "Slider";
   bool UIVisible =  true;
   float UIMin = -1.0;
   float UIMax = 1.0;
> = float( 0.0 );

float MMMScaleL < // ���˒����T�C�Y
   string UIName = "���˒�����";
   string UIWidget = "Slider";
   bool UIVisible =  true;
   float UIMin = -1.0;
   float UIMax = 1.0;
> = float( 0.0 );

float MMMScaleU < // ���h�炬�x
   string UIName = "���h�炬�x";
   string UIHelp = "���˒��p�����̗h�炬�̃T�C�Y";
   string UIWidget = "Slider";
   bool UIVisible =  true;
   float UIMin = -1.0;
   float UIMax = 1.0;
> = float( 0.0 );

float MMMScaleV < // ���h�炬�x
   string UIName = "���h�炬�x";
   string UIHelp = "���ˎ������̗h�炬�̃T�C�Y";
   string UIWidget = "Slider";
   bool UIVisible =  true;
   float UIMin = -1.0;
   float UIMax = 1.0;
> = float( 0.0 );

float MMMScroll < // �X�N���[��
   string UIName = "�X�N���[��";
   string UIWidget = "Slider";
   bool UIVisible =  true;
   float UIMin = 0.0;
   float UIMax = 1.0;
> = float( 0.0 );

float MMMFade < // �t�F�[�h
   string UIName = "�t�F�[�h";
   string UIWidget = "Slider";
   bool UIVisible =  true;
   float UIMin = 0.0;
   float UIMax = 1.0;
> = float( 0.0 );

float MMMFadeW < // �t�F�[�h��
   string UIName = "�t�F�[�h��";
   string UIWidget = "Slider";
   bool UIVisible =  true;
   float UIMin = 0.0;
   float UIMax = 1.0;
> = float( 0.0 );

float MMMDist < // �c�ݓx
   string UIName = "�c�ݓx";
   string UIWidget = "Slider";
   bool UIVisible =  true;
   float UIMin = 0.0;
   float UIMax = 1.0;
> = float( 1.0 );

static float ScaleZ0 = pow(20.0f, MMMScaleZ0);
static float ScaleZ1 = pow(20.0f, MMMScaleZ1);
static float ScaleL = pow(20.0f, MMMScaleL);
static float ScaleU = pow(20.0f, -MMMScaleU);
static float ScaleV = pow(20.0f, -MMMScaleV);
static float ScrollSpeedV = -MMMScroll * MMMScroll * 10.0f;
static float FadeValue = MMMFade;
static float FadeWidth = MMMFadeW;
static float DistFactor = MMMDist * MMMDist;

#endif


#define DEPTH_FAR  5000.0f   // �[�x�ŉ��l

// ���ߒl�ɑ΂���[�x�ǂݎ��臒l
float AlphaClipThreshold = 0.05;

// ���W�ϊ��s��
float4x4 WorldMatrix    : WORLD;
float4x4 ViewMatrix     : VIEW;
float4x4 ProjMatrix     : PROJECTION;
float4x4 ViewProjMatrix : VIEWPROJECTION;

// �J�����ʒu
float3 CameraPosition : POSITION  < string Object = "Camera"; >;

// �m�[�}���}�b�v�e�N�X�`��
texture2D NormalMapTex <
    string ResourceName = "NormalMapSample.png";
    int MipLevels = 0;
>;
sampler NormalMapSamp = sampler_state {
    texture = <NormalMapTex>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = LINEAR;
    AddressU  = WRAP;
    AddressV  = WRAP;
};

////////////////////////////////////////////////////////////////////////////////////////////////
// �X�N���[�������E���ԊԊu�v�Z

float time : TIME;

// �X�V�X�N���[�������E�����L�^�p
texture TimeTex : RENDERCOLORTARGET
<
   int Width=1;
   int Height=1;
   string Format = "D3DFMT_A32B32G32R32F" ;
>;
sampler TimeTexSmp = sampler_state
{
   Texture = <TimeTex>;
    AddressU  = CLAMP;
    AddressV = CLAMP;
    MinFilter = NONE;
    MagFilter = NONE;
    MipFilter = NONE;
};
texture TimeDepthBuffer : RenderDepthStencilTarget <
   int Width=1;
   int Height=1;
    string Format = "D3DFMT_D24S8";
>;
static float Dt = clamp(time - tex2D(TimeTexSmp, float2(0.5f,0.5f)).z, 0.001f, 0.1f);

float4 UpdatePosTime_VS(float4 Pos : POSITION) : POSITION
{
    return Pos;
}

float4 UpdatePosTime_PS() : COLOR
{
    float4 Pos = tex2D(TimeTexSmp, float2(0.5f, 0.5f));
    float2 p = Pos.xy - float2(0.3f*ScrollSpeedV*ScaleU, ScrollSpeedV*ScaleV) * Dt;
    if(time < 0.001f) p = float2(0,0);
    return float4(frac(p), time, 1);
}


////////////////////////////////////////////////////////////////////////////////////////////////
//�ڋ�ԉ�]�s��擾

float3x3 GetTangentFrame(float3 Normal, float3 View, float2 UV)
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


////////////////////////////////////////////////////////////////////////////////////////////////
//MMM�Ή�

#ifndef MIKUMIKUMOVING
    struct VS_INPUT{
        float4 Pos    : POSITION;
        float2 Tex    : TEXCOORD0;
        float4 AddUV1 : TEXCOORD1;
        float4 AddUV2 : TEXCOORD2;
        float3 Normal : NORMAL;
    };
    #define GETPOS        (IN.AddUV1)
    #define GETNORMAL     (IN.AddUV2.xyz)
    #define GET_WMAT      (BoneCenter)
    #define GET_CENTERVEC (BoneCenter._31_32_33)
    #define GET_VPMAT(p)  (ViewProjMatrix)
#else
    #define VS_INPUT  MMM_SKINNING_INPUT
    #define GETPOS        (IN.Pos)
    #define GETNORMAL     (IN.Normal)
    #define GET_WMAT      (WorldMatrix)
    #define GET_CENTERVEC (WorldMatrix._31_32_33)
    #define GET_VPMAT(p)  (MMM_IsDinamicProjection ? mul(ViewMatrix, MMM_DynamicFov(ProjMatrix, length(CameraPosition-p.xyz))) : ViewProjMatrix)
#endif


////////////////////////////////////////////////////////////////////////////////////////////////
// �@���E�[�x�`��

struct VS_OUTPUT {
    float4 Pos       : POSITION;   // �ˉe�ϊ����W
    float3 Normal    : TEXCOORD0;  // �@��
    float4 VPos      : TEXCOORD1;  // �r���[���W
    float3 CenterVec : TEXCOORD2;  // ���ˎ�����
    float2 Tex       : TEXCOORD3;  // UV���W
};

// ���_�V�F�[�_
VS_OUTPUT VS_Object( VS_INPUT IN )
{
    VS_OUTPUT Out = (VS_OUTPUT)0; 

    // ���[�J�����W
    float4 Pos = GETPOS;

    float scaleXY = lerp(ScaleZ0, ScaleZ1, 1.0f - IN.Tex.y);
    Pos.xyz *= float3(scaleXY, scaleXY, ScaleL);

    // ���_�̃��[���h���W�ϊ�
    float4 WPos = mul(Pos, GET_WMAT);

    // �J�������_�̃r���[�ˉe�ϊ�
    Out.Pos = mul( WPos, GET_VPMAT(WPos) );

    // �J�������_�̃r���[�ϊ�
    Out.VPos = mul( WPos, ViewMatrix );

    // ���_�ό`�ɔ����@���̕ω�
    float3 Normal = GETNORMAL;
    float3 XZ = float3(5.0f*ScaleZ0, 5.0f*ScaleZ1, 40.0f*ScaleL);
    float  len = sqrt( XZ.z*XZ.z + (XZ.x-XZ.y)*(XZ.x-XZ.y) );
    float2 sc = float2( (XZ.y-XZ.x)/len, XZ.z/len );
    Normal = float3(Normal.xy*sc.y, -sc.x);

    // �@���̃J�������_�̃��[���h�r���[�ϊ�
    Normal = mul(Normal, (float3x3)GET_WMAT);
    Out.Normal = normalize( mul(Normal, (float3x3)ViewMatrix) );

    // ���ˎ������̃J�������_�̃r���[�ϊ�
    Out.CenterVec = normalize( mul(GET_CENTERVEC, (float3x3)ViewMatrix) );

    // �e�N�X�`�����W
    Out.Tex = IN.Tex;

    return Out;
}

//�s�N�Z���V�F�[�_
float4 PS_Object(VS_OUTPUT IN, uniform bool FlagClip) : COLOR
{
    // �m�[�}���}�b�v���܂ޖ@���擾
    float3 eye = normalize(-IN.VPos.xyz / IN.VPos.w);
    float3 normal = normalize(IN.Normal);
    float2 tex0 = tex2D(TimeTexSmp, float2(0.5f,0.5f)).xy;
    float2 tex1 =  float2(IN.Tex.x*ScaleU, IN.Tex.y*ScaleV) + tex0;
    float3x3 tangentFrame1 = GetTangentFrame(normal, eye, tex1);
    float3 Normal1 = mul(2.0f * tex2D(NormalMapSamp, tex1).rgb - 1.0f, tangentFrame1);
    float2 tex2 =  float2(IN.Tex.x*ScaleU, IN.Tex.y*ScaleV) + float2(-tex0.x, tex0.y);
    float3x3 tangentFrame2 = GetTangentFrame(normal, eye, tex2);
    float3 Normal2 = mul(2.0f * tex2D(NormalMapSamp, tex2).rgb - 1.0f, tangentFrame2);
    float3 Normal = normalize( Normal1 + Normal2);

    // �t�F�[�h���ߒl�v�Z
    float alpha = smoothstep(FadeValue, FadeValue + max(FadeWidth, 0.01f), saturate(IN.Tex.y));

    // ���l��臒l�ȉ��̉ӏ��͕`�悵�Ȃ�
    clip(alpha - AlphaClipThreshold);

    // ���ˊO���ʂ̏���
    if( FlagClip ){
        // ���ː�̃N���b�v
        float3 nrml = lerp(float3(0.0, 0.0, -1.0f), Normal, alpha);
        nrml = lerp(float3(1.0, 0.0, 0.0f), nrml, 1-alpha);
        clip(1-dot(normalize(nrml),float3(0.0, 0.0, -1.0f)) - 0.2);
        // ���ˑ��ʃG�b�W���ڂ���
        float s = dot( normalize(cross(-eye, IN.CenterVec)), normal );
        float h = min( abs(ScaleZ0 - ScaleZ1)*0.1f, 0.4f );
        alpha *= 1.0f - smoothstep(0.5f+h, 1.0f, abs(s));
    }
    alpha *= DistFactor;

    // �@��(0�`1�ɂȂ�悤�␳)
    Normal = (Normal + 1.0f) / 2.0f;
    Normal = lerp(float3(0.5, 0.5, 0.0f), Normal, alpha);

    // �[�x(0�`DEPTH_FAR��0.5�`1.0�ɐ��K��)
    float dep = length(IN.VPos.xyz / IN.VPos.w);
    dep = (saturate(dep / DEPTH_FAR) + 1.0f) * 0.5f;

    return float4(Normal, dep);
}

///////////////////////////////////////////////////////////////////////////////////////
// �e�N�j�b�N

// �I�u�W�F�N�g�`��(�Z���t�V���h�E�Ȃ�)
technique DepthTec0 < string MMDPass = "object";  string Subset = "0";
    string Script = 
        "RenderColorTarget0=TimeTex;"
            "RenderDepthStencilTarget=TimeDepthBuffer;"
            "Pass=UpdatePosTime;"
        "RenderColorTarget0=;"
	    "RenderDepthStencilTarget=;"
            "Pass=DrawObject;" ;
>{
    pass UpdatePosTime < string Script= "Draw=Buffer;"; > {
        ZEnable = FALSE;
        AlphaBlendEnable = FALSE;
        AlphaTestEnable = FALSE;
        VertexShader = compile vs_1_1 UpdatePosTime_VS();
        PixelShader  = compile ps_2_0 UpdatePosTime_PS();
    }
    pass DrawObject {
        ZEnable = TRUE;
        AlphaBlendEnable = FALSE;
        CullMode = CCW;
        VertexShader = compile vs_3_0 VS_Object();
        PixelShader  = compile ps_3_0 PS_Object(false);
    }
}

technique DepthTec1 < string MMDPass = "object"; >
{
    pass DrawObject {
        ZEnable = TRUE;
        AlphaBlendEnable = FALSE;
        CullMode = CCW;
        VertexShader = compile vs_3_0 VS_Object();
        PixelShader  = compile ps_3_0 PS_Object(true);
    }
}

// �I�u�W�F�N�g�`��(�Z���t�V���h�E����)
technique DepthTecSS0 < string MMDPass = "object_ss";  string Subset = "0";
    string Script = 
        "RenderColorTarget0=TimeTex;"
            "RenderDepthStencilTarget=TimeDepthBuffer;"
            "Pass=UpdatePosTime;"
        "RenderColorTarget0=;"
	    "RenderDepthStencilTarget=;"
            "Pass=DrawObject;" ;
>{
    pass UpdatePosTime < string Script= "Draw=Buffer;"; > {
        ZEnable = FALSE;
        AlphaBlendEnable = FALSE;
        AlphaTestEnable = FALSE;
        VertexShader = compile vs_1_1 UpdatePosTime_VS();
        PixelShader  = compile ps_2_0 UpdatePosTime_PS();
    }
    pass DrawObject {
        ZEnable = TRUE;
        AlphaBlendEnable = FALSE;
        CullMode = CCW;
        VertexShader = compile vs_3_0 VS_Object();
        PixelShader  = compile ps_3_0 PS_Object(false);
    }
}

technique DepthTecSS1 < string MMDPass = "object_ss"; >
{
    pass DrawObject {
        ZEnable = TRUE;
        AlphaBlendEnable = FALSE;
        CullMode = CCW;
        VertexShader = compile vs_3_0 VS_Object();
        PixelShader  = compile ps_3_0 PS_Object(true);
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////
//�G�b�W�E�n�ʉe�͕`�悵�Ȃ�
technique EdgeTec < string MMDPass = "edge"; > { }
technique ShadowTec < string MMDPass = "shadow"; > { }
technique ZplotTec < string MMDPass = "zplot"; > { }

