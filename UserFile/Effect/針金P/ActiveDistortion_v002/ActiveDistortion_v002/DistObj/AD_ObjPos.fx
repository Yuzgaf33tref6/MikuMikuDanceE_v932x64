////////////////////////////////////////////////////////////////////////////////////////////////
//
//  AD_ObjPos.fx ��Ԙc�݃G�t�F�N�g(���f���`��ɍ��킹�Ęc�܂���,���_���W�\��t��)
//  ( ActiveDistortion.fx ����Ăяo����܂��D�I�t�X�N���[���`��p)
//  �쐬: �j��P
//
////////////////////////////////////////////////////////////////////////////////////////////////
// �����̃p�����[�^��ύX���Ă�������

#define USE_NORMALMAP  1   // �m�[�}���}�b�v�� 1:�g�p����, 0:�g�p���Ȃ�

#define TEX_FileName  "NormalMapSample.png" // �m�[�}���}�b�v�e�N�X�`���t�@�C����


// ����Ȃ��l�͂������牺�͂�����Ȃ��ł�

////////////////////////////////////////////////////////////////////////////////////////////////
// �p�����[�^�錾

#ifndef MIKUMIKUMOVING

#define ControlModel  "DistObjPosControl.pmd"  // �R���g���[�����f���t�@�C����
float MorphXScaleP  : CONTROLOBJECT < string name = ControlModel; string item = "X�g��"; >;
float MorphXScaleM  : CONTROLOBJECT < string name = ControlModel; string item = "X�k��"; >;
float MorphYScaleP  : CONTROLOBJECT < string name = ControlModel; string item = "Y�g��"; >;
float MorphYScaleM  : CONTROLOBJECT < string name = ControlModel; string item = "Y�k��"; >;
float MorphXScrollP : CONTROLOBJECT < string name = ControlModel; string item = "X�X�N���[���{"; >;
float MorphXScrollM : CONTROLOBJECT < string name = ControlModel; string item = "X�X�N���[���|"; >;
float MorphYScrollP : CONTROLOBJECT < string name = ControlModel; string item = "Y�X�N���[���{"; >;
float MorphYScrollM : CONTROLOBJECT < string name = ControlModel; string item = "Y�X�N���[���|"; >;
float MorphDist     : CONTROLOBJECT < string name = ControlModel; string item = "�c�ݓx"; >;
static float ScaleX = 1.0f + MorphXScaleM*19.0f - MorphXScaleP*19.0f/20.0f;
static float ScaleY = 1.0f + MorphYScaleM*19.0f - MorphYScaleP*19.0f/20.0f;
static float ScrollSpeedX = (MorphXScrollP - MorphXScrollM) * abs(MorphXScrollP - MorphXScrollM) * 10.0f;
static float ScrollSpeedY = (MorphYScrollP - MorphYScrollM) * abs(MorphYScrollP - MorphYScrollM) * 10.0f;
static float DistFactor = 1.0f - MorphDist;

#else

float MMMScaleX < // U�g��k��
   string UIName = "U�g��k��";
   string UIWidget = "Slider";
   bool UIVisible =  true;
   float UIMin = -1.0;
   float UIMax = 1.0;
> = float( 0.0 );

float MMMScaleY < // V�g��k��
   string UIName = "V�g��k��";
   string UIWidget = "Slider";
   bool UIVisible =  true;
   float UIMin = -1.0;
   float UIMax = 1.0;
> = float( 0.0 );

float MMMScrollX < // U�X�N���[��
   string UIName = "U�X�N���[��";
   string UIWidget = "Slider";
   bool UIVisible =  true;
   float UIMin = -1.0;
   float UIMax = 1.0;
> = float( 0.0 );

float MMMScrollY < // V�X�N���[��
   string UIName = "V�X�N���[��";
   string UIWidget = "Slider";
   bool UIVisible =  true;
   float UIMin = -1.0;
   float UIMax = 1.0;
> = float( 0.0 );


float MMMDist < // �c�ݓx
   string UIName = "�c�ݓx";
   string UIWidget = "Slider";
   bool UIVisible =  true;
   float UIMin = 0.0;
   float UIMax = 1.0;
> = float( 1.0 );

static float ScaleX = pow(20.0f, -MMMScaleX);
static float ScaleY = pow(20.0f, -MMMScaleY);
static float ScrollSpeedX = MMMScrollX * abs(MMMScrollX) * 10.0f;
static float ScrollSpeedY = MMMScrollY * abs(MMMScrollY) * 10.0f;
static float DistFactor = MMMDist;

#endif


float3 BoneCenter : CONTROLOBJECT < string name = "(self)"; string item = "�Z���^�["; >;

#define DEPTH_FAR  5000.0f   // �[�x�ŉ��l

// ���[�J�����W�n�ł̃m�[�}���}�b�v�e�N�X�`���X�P�[��
#define TexScale  20.0f

// ���ߒl�ɑ΂���[�x�ǂݎ��臒l
float AlphaClipThreshold = 0.005;

// ���W�ϊ��s��
float4x4 ProjMatrix          : PROJECTION;
float4x4 WorldViewMatrix     : WORLDVIEW;
float4x4 WorldViewProjMatrix : WORLDVIEWPROJECTION;
float4x4 WorldMatrixInverse  : WORLDINVERSE;

// �J�����ʒu�E����
float3 CameraPosition  : POSITION  < string Object = "Camera"; >;

// �}�e���A���F
float4 MaterialDiffuse : DIFFUSE  < string Object = "Geometry"; >;
float4 EdgeColor       : EDGECOLOR;

bool opadd;       // ���Z�����t���O
bool use_texture; // �e�N�X�`���̗L��
bool use_toon;    // �g�D�[�������_�����O�g�p�t���O�B

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

#if(USE_NORMALMAP==1)
// �m�[�}���}�b�v�e�N�X�`��
texture2D NormalMapTex <
    string ResourceName = TEX_FileName;
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
#endif

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
    float2 p = Pos.xy - float2(ScrollSpeedX, -ScrollSpeedY) * Dt;
    if(time < 0.001f) p = float2(0,0);
    return float4(frac(p), time, 1);
}


////////////////////////////////////////////////////////////////////////////////////////////////
// �e�N�X�`�����W�擾

float2 GetTexCoord(float4 Pos)
{
    float3 camDir = -mul(float4(CameraPosition, 1), WorldMatrixInverse).xyz;
    if(use_toon) camDir -= BoneCenter;
    camDir = any(camDir.xz) ? normalize(float3(camDir.x, 0.0f, camDir.z)) : float3(0,0,1);
    float2 tex = float2( Pos.x * camDir.z - Pos.z * camDir.x, Pos.y );
    float s = use_toon ? TexScale : 0.1f*TexScale;
    return float2( tex.x / s, -tex.y / s);
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
        float3 Normal : NORMAL;
    };
    #define MMM_SKINNING
    #define GETPOS     (IN.Pos)
    #define GETNORMAL  (IN.Normal)
    #define GET_WVPMAT(p) (WorldViewProjMatrix)
#else
    #define VS_INPUT  MMM_SKINNING_INPUT
    #define MMM_SKINNING  MMM_SKINNING_OUTPUT SkinOut = MMM_SkinnedPositionNormal(IN.Pos, IN.Normal, IN.BlendWeight, IN.BlendIndices, IN.SdefC, IN.SdefR0, IN.SdefR1);
    #define GETPOS     (SkinOut.Position)
    #define GETNORMAL  (SkinOut.Normal)
    #define GET_WVPMAT(p) (MMM_IsDinamicProjection ? mul(WorldViewMatrix, MMM_DynamicFov(ProjMatrix, length(CameraPosition-mul(p, WorldMatrix).xyz))) : WorldViewProjMatrix)
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
    MMM_SKINNING

    // �J�������_�̃��[���h�r���[�ˉe�ϊ�
    Out.Pos = mul( GETPOS, GET_WVPMAT(GETPOS) );

    // �J�������_�̃��[���h�r���[�ϊ�
    Out.VPos = mul( GETPOS, WorldViewMatrix );

    // �@���̃J�������_�̃��[���h�r���[�ϊ�
    Out.Normal = normalize( mul(GETNORMAL, (float3x3)WorldViewMatrix) );

    // �e�N�X�`�����W
    Out.Tex = GetTexCoord(GETPOS);

    return Out;
}

//�s�N�Z���V�F�[�_
float4 PS_Object(VS_OUTPUT IN) : COLOR
{
    float alpha = MaterialDiffuse.a * !opadd;
    if ( use_texture ) {
        // �e�N�X�`�����ߒl�K�p
        alpha *= tex2D( ObjTexSampler, IN.Tex ).a * !opadd;
    }
    // ���l��臒l�ȉ��̉ӏ��͕`�悵�Ȃ�
    clip(alpha - AlphaClipThreshold);

    #if(USE_NORMALMAP==1)
    // �m�[�}���}�b�v���܂ޖ@���擾
    float3 eye = -IN.VPos.xyz / IN.VPos.w;
    float2 tex = float2(IN.Tex.x*ScaleX, IN.Tex.y*ScaleY) + tex2D(TimeTexSmp, float2(0.5f,0.5f)).xy;
    float3x3 tangentFrame = GetTangentFrame(IN.Normal, eye, tex);
    float3 Normal = normalize(mul(2.0f * tex2D(NormalMapSamp, tex).rgb - 1.0f, tangentFrame));
    #else
    float3 Normal = normalize( IN.Normal );
    #endif

    // ���ߒl�v�Z
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
        VertexShader = compile vs_3_0 VS_Object();
        PixelShader  = compile ps_3_0 PS_Object();
    }
}

technique DepthTec1 < string MMDPass = "object"; >
{
    pass DrawObject {
        AlphaBlendEnable = FALSE;
        VertexShader = compile vs_3_0 VS_Object();
        PixelShader  = compile ps_3_0 PS_Object();
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
        VertexShader = compile vs_3_0 VS_Object();
        PixelShader  = compile ps_3_0 PS_Object();
    }
}

technique DepthTecSS1 < string MMDPass = "object_ss"; >
{
    pass DrawObject {
        AlphaBlendEnable = FALSE;
        VertexShader = compile vs_3_0 VS_Object();
        PixelShader  = compile ps_3_0 PS_Object();
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////
//�G�b�W�E�n�ʉe�͕`�悵�Ȃ�
technique EdgeTec < string MMDPass = "edge"; > { }
technique ShadowTec < string MMDPass = "shadow"; > { }
technique ZplotTec < string MMDPass = "zplot"; > { }

