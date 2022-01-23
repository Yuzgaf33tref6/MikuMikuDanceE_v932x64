////////////////////////////////////////////////////////////////////////////////////////////////
//
//  AD_Vortex.fx ��Ԙc�݃G�t�F�N�g(�Q������ɘc�܂���G�t�F�N�g,�@���E�[�x�}�b�v�쐬)
//  ( ActiveDistortion.fx ����Ăяo����܂��D�I�t�X�N���[���`��p)
//  �쐬: �j��P
//
////////////////////////////////////////////////////////////////////////////////////////////////
// �p�����[�^�錾

#define MOME_CULL   1   // 0:�Жʂ̂ݘc�܂���, 1:���ʂƂ��c�܂���

#ifndef MIKUMIKUMOVING

#define ControlModel  "(self)"  // �R���g���[�����f���t�@�C����
float4x4 BoneCenter  : CONTROLOBJECT < string name = ControlModel; string item = "�Z���^�["; >;
float MorphScaleM    : CONTROLOBJECT < string name = ControlModel; string item = "�k��"; >;
float MorphScaleP10  : CONTROLOBJECT < string name = ControlModel; string item = "�g��*10"; >;
float MorphScaleP100 : CONTROLOBJECT < string name = ControlModel; string item = "�g��*100"; >;
float MorphDist      : CONTROLOBJECT < string name = ControlModel; string item = "�c�ݓx"; >;
float MorphUScaleP   : CONTROLOBJECT < string name = ControlModel; string item = "�~���c�ݑe"; >;
float MorphUScaleM   : CONTROLOBJECT < string name = ControlModel; string item = "�~���c�ݍ�"; >;
float MorphVScaleP   : CONTROLOBJECT < string name = ControlModel; string item = "���S�c�ݑe"; >;
float MorphVScaleM   : CONTROLOBJECT < string name = ControlModel; string item = "���S�c�ݍ�"; >;
float MorphVScrollM  : CONTROLOBJECT < string name = ControlModel; string item = "�X�N���[����"; >;
float MorphVScrollP  : CONTROLOBJECT < string name = ControlModel; string item = "�X�N���[���O"; >;
float MorphUScrollP  : CONTROLOBJECT < string name = ControlModel; string item = "��] +"; >;
float MorphUScrollM  : CONTROLOBJECT < string name = ControlModel; string item = "��] -"; >;
float MorphVortexP   : CONTROLOBJECT < string name = ControlModel; string item = "�Q�����x +"; >;
float MorphVortexM   : CONTROLOBJECT < string name = ControlModel; string item = "�Q�����x -"; >;
float MorphV0Fade    : CONTROLOBJECT < string name = ControlModel; string item = "�����t�F�[�h"; >;
float MorphV1Fade    : CONTROLOBJECT < string name = ControlModel; string item = "�O���t�F�[�h"; >;
float MorphV0FadeW    : CONTROLOBJECT < string name = ControlModel; string item = "���t�F�[�h��"; >;
float MorphV1FadeW    : CONTROLOBJECT < string name = ControlModel; string item = "�O�t�F�[�h��"; >;
static float Scale = 1.0f - MorphScaleM*0.99f + MorphScaleP10*9.0f + MorphScaleP100*99.0f;
static float DistFactor = 1.0f - MorphDist;
static float ScaleU = 1.0f + MorphUScaleM*9.0f - MorphUScaleP*9.0f/10.0f;
static float ScaleV = 1.0f + MorphVScaleM*9.0f - MorphVScaleP*9.0f/10.0f;
static float ScrollSpeedU = (MorphUScrollP - MorphUScrollM) * abs(MorphUScrollP - MorphUScrollM) * 10.0f;
static float ScrollSpeedV = (MorphVScrollP - MorphVScrollM) * abs(MorphVScrollP - MorphVScrollM) * 10.0f;
static float VortexRot = radians((MorphVortexP - MorphVortexM)*720.0f);
static float2 FadeValue = float2(MorphV0Fade, 1.0f-MorphV1Fade);
static float2 FadeWidth = float2(MorphV0FadeW, MorphV1FadeW);

#else

float MMMDist < // �c�ݓx
   string UIName = "�c�ݓx";
   string UIWidget = "Slider";
   bool UIVisible =  true;
   float UIMin = 0.0;
   float UIMax = 1.0;
> = float( 1.0 );

float MMMVortex < // �Q�����x
   string UIName = "�Q�����x";
   string UIWidget = "Slider";
   bool UIVisible =  true;
   float UIMin = -1.0;
   float UIMax = 1.0;
> = float( 0.0 );

float MMMScaleU < // U�g��k��
   string UIName = "U�g��k��";
   string UIWidget = "Slider";
   bool UIVisible =  true;
   float UIMin = -1.0;
   float UIMax = 1.0;
> = float( 0.0 );

float MMMScaleV < // V�g��k��
   string UIName = "V�g��k��";
   string UIWidget = "Slider";
   bool UIVisible =  true;
   float UIMin = -1.0;
   float UIMax = 1.0;
> = float( 0.0 );

float MMMScrollV < // �X�N���[��
   string UIName = "�X�N���[��";
   string UIWidget = "Slider";
   bool UIVisible =  true;
   float UIMin = -1.0;
   float UIMax = 1.0;
> = float( 0.0 );

float MMMScrollU < // ��]
   string UIName = "��]";
   string UIWidget = "Slider";
   bool UIVisible =  true;
   float UIMin = -1.0;
   float UIMax = 1.0;
> = float( 0.0 );

float MMMFadeV0 < // ���t�F�[�h
   string UIName = "���t�F�[�h";
   string UIWidget = "Slider";
   bool UIVisible =  true;
   float UIMin = 0.0;
   float UIMax = 1.0;
> = float( 0.0 );

float MMMFadeV0W < // ���t�F�[�h��
   string UIName = "���t�F�[�h��";
   string UIWidget = "Slider";
   bool UIVisible =  true;
   float UIMin = 0.0;
   float UIMax = 1.0;
> = float( 0.0 );

float MMMFadeV1 < // �O�t�F�[�h
   string UIName = "�O�t�F�[�h";
   string UIWidget = "Slider";
   bool UIVisible =  true;
   float UIMin = 0.0;
   float UIMax = 1.0;
> = float( 0.0 );

float MMMFadeV1W < // �O�t�F�[�h��
   string UIName = "�O�t�F�[�h��";
   string UIWidget = "Slider";
   bool UIVisible =  true;
   float UIMin = 0.0;
   float UIMax = 1.0;
> = float( 0.0 );

float AcsTr : CONTROLOBJECT < string name = "(self)"; string item = "Tr"; >;
static float DistFactor = MMMDist * AcsTr;
static float VortexRot = radians(MMMVortex*720.0f);
static float ScaleU = pow(10.0f, -MMMScaleU);
static float ScaleV = pow(10.0f, -MMMScaleV);
static float ScrollSpeedU = MMMScrollU * abs(MMMScrollU) * 10.0f;
static float ScrollSpeedV = MMMScrollV * abs(MMMScrollV) * 10.0f;
static float2 FadeValue = float2(MMMFadeV0, 1.0f-MMMFadeV1);
static float2 FadeWidth = float2(MMMFadeV0W, MMMFadeV1W);

#endif


#define DEPTH_FAR  5000.0f   // �[�x�ŉ��l

// ���ߒl�ɑ΂���[�x�ǂݎ��臒l
float AlphaClipThreshold = 0.005;

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
    float2 p = Pos.xy - float2(ScrollSpeedU, ScrollSpeedV) * Dt;
    if(time < 0.001f) p = float2(0,0);
    return float4(p, time, 1);
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
// ���W��2D��]
float2 Rotation2D(float2 pos, float rot)
{
    float x = pos.x * cos(rot) - pos.y * sin(rot);
    float y = pos.x * sin(rot) + pos.y * cos(rot);

    return float2(x,y);
}

////////////////////////////////////////////////////////////////////////////////////////////////
//MMM�Ή�

#ifndef MIKUMIKUMOVING
    struct VS_INPUT{
        float4 Pos    : POSITION;
        float2 Tex    : TEXCOORD0;
        float4 AddUV1 : TEXCOORD1;
        float3 Normal : NORMAL;
    };
    #define MODEL_SCALE  10.0f
    #define GETPOS       (IN.AddUV1)
    #define GETNORMAL    float3(0,0,-1)
    #define GET_WMAT     float4x4(BoneCenter[0]*Scale, BoneCenter[1]*Scale, BoneCenter[2]*Scale, BoneCenter[3])
    #define GET_VPMAT(p) (ViewProjMatrix)
#else
    #define VS_INPUT  MMM_SKINNING_INPUT
    #define MODEL_SCALE  1.0f
    #define GETPOS       (IN.Pos)
    #define GETNORMAL    (IN.Normal)
    #define GET_WMAT     (WorldMatrix)
    #define GET_VPMAT(p) (MMM_IsDinamicProjection ? mul(ViewMatrix, MMM_DynamicFov(ProjMatrix, length(CameraPosition-p.xyz))) : ViewProjMatrix)
#endif


////////////////////////////////////////////////////////////////////////////////////////////////
// �@���E�[�x�`��

struct VS_OUTPUT {
    float4 Pos    : POSITION;   // �ˉe�ϊ����W
    float3 Normal : TEXCOORD0;  // �@��
    float4 VPos   : TEXCOORD1;  // �r���[���W
    float2 Tex    : TEXCOORD2;  // UV���W
};

// ���_�V�F�[�_
VS_OUTPUT VS_Object( VS_INPUT IN )
{
    VS_OUTPUT Out = (VS_OUTPUT)0; 

    // ���[�J�����W
    float4 Pos = GETPOS;

    // �Q������̉�]
    float rot = VortexRot * (1.0f - length(Pos.xy) / MODEL_SCALE);
    Pos.xy = Rotation2D(Pos.xy, rot);

    // ���_�̃��[���h���W�ϊ�
    Pos = mul(Pos, GET_WMAT);

    // �@���̃��[���h���W�ϊ�
    float3 Normal = mul(GETNORMAL, GET_WMAT);

    // �J�������_�̃r���[�ˉe�ϊ�
    Out.Pos = mul( Pos, GET_VPMAT(Pos) );

    // �J�������_�̃r���[�ϊ�
    Out.VPos = mul( Pos, ViewMatrix );

    // �@���̃J�������_�̃r���[�ϊ�
    Out.Normal = normalize( mul(Normal, (float3x3)ViewMatrix) );

    // �e�N�X�`�����W
    Out.Tex = IN.Tex;

    return Out;
}

//�s�N�Z���V�F�[�_
float4 PS_Object(VS_OUTPUT IN) : COLOR
{
    // �m�[�}���}�b�v���܂ޖ@���擾
    float3 eye = -IN.VPos.xyz / IN.VPos.w;
    float2 tex = float2(IN.Tex.x*ScaleU, IN.Tex.y*ScaleV) + tex2D(TimeTexSmp, float2(0.5f,0.5f)).xy;
    float3x3 tangentFrame = GetTangentFrame(IN.Normal, eye, tex);
    float3 Normal = normalize(mul(2.0f * tex2D(NormalMapSamp, tex).rgb - 1.0f, tangentFrame));

    // �t�F�[�h���ߒl�v�Z
    float alpha = 1.0f;
    alpha *= (FadeWidth.x > 0.0f) ? smoothstep(FadeValue.x, FadeValue.x + FadeWidth.x, saturate(IN.Tex.y)) : step(FadeValue.x, saturate(IN.Tex.y));
    alpha *= (FadeWidth.y > 0.0f) ? 1.0f - smoothstep(FadeValue.y - FadeWidth.y, FadeValue.y, saturate(IN.Tex.y)) : step(saturate(IN.Tex.y), FadeValue.y);
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
technique DepthTec0 < string MMDPass = "object";
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
        #if MOME_CULL == 1
        CullMode = NONE;
        #else
        CullMode = CCW;
        #endif
        VertexShader = compile vs_3_0 VS_Object();
        PixelShader  = compile ps_3_0 PS_Object();
    }
}

// �I�u�W�F�N�g�`��(�Z���t�V���h�E����)
technique DepthTecSS0 < string MMDPass = "object_ss";
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
        #if MOME_CULL == 1
        CullMode = NONE;
        #else
        CullMode = CCW;
        #endif
        VertexShader = compile vs_3_0 VS_Object();
        PixelShader  = compile ps_3_0 PS_Object();
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////
//�G�b�W�E�n�ʉe�͕`�悵�Ȃ�
technique EdgeTec < string MMDPass = "edge"; > { }
technique ShadowTec < string MMDPass = "shadow"; > { }
technique ZplotTec < string MMDPass = "zplot"; > { }

