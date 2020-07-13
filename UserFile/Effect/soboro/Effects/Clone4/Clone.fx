////////////////////////////////////////////////////////////////////////////////////////////////
//
//  Clone.fx
//  �쐬: ���ڂ�
//  ����: ���͉��P(full.fx)
//
////////////////////////////////////////////////////////////////////////////////////////////////

//�T�|�[�g�֐��錾(�ύX�s��)
float4 rot_x(float4 pos, float deg);
float4 rot_y(float4 pos, float deg);
float4 rot_z(float4 pos, float deg);
float4x4 inverseDir(float4x4 mat);

//�T�|�[�g�ϐ���`
float Scale  : CONTROLOBJECT < string name = "(self)"; >;
float3 Offset : CONTROLOBJECT < string name = "(self)"; >;
float3 MasterPos : CONTROLOBJECT < string name = "(self)"; string item = "�S�Ă̐e"; >;
float4x4 MasterWorldMat : CONTROLOBJECT < string name = "(self)"; string item = "�S�Ă̐e"; >;
float Time1 : TIME <bool SyncInEditMode=true;>;
float Time2 : TIME <bool SyncInEditMode=false;>;

////////////////////////////////////////////////////////////////////////////////////////////////
// �p�����[�^�錾

//������
int CloneCount = 100;

//���[�v�ϐ��i�����l��0�Œ�j
int CloneIndex = 0;

// �~�b�v�}�b�v�����p�e�N�X�`���T�C�Y�E0�Ŗ���
#define CLONE_MIPMAPTEX_SIZE  0 //512


////////////////////////////////////////////////////////////////////////////////////////////////
// �����̈ʒu���R���g���[������֐��E�������������čD�݂̔z�u�ɂ��Ă��������B
// �s�v�ȕω��͍폜�@�s���Ɂu//�v������s�̓R�����g���ł��B

// �T�|�[�g�֐�
//   rot_x�FX������̉�]
//   rot_y�FY������̉�]
//   rot_z�FZ������̉�]

// �� Z��X��Y �̏��ɉ�]�������MMD�̉�]�����ƈ�v���܂��B

// �T�|�[�g�ϐ�
//   CloneIndex�F�����ԍ�
//   Scale�F�g�嗦�B�A�N�Z�T���̃f�t�H���g��10�ł��B
//   Offset�F���A�N�Z�T�����ړ������ʒu�BPMD�ł͏��0�ł��B
//   MasterPos�F�u�S�Ă̐e�v�{�[���̈ʒu�B���݂��Ȃ����0�ł��B
//   Time1 : �t���[�����Ԃł��B�P�ʂ͕b�ł��B
//   Time2 : �t���[�����Ԃł��B�P�ʂ͕b�ł��B�ҏW�����i�ݑ����܂��B


float4 ClonePos(float4 Pos) 
{
    const float row_count = 16; //16��ɔz�u
    float center = (int)(row_count / 2); //�I���W�i���Ɠ����ʒu�ɔz�u����ԍ�
    float cindex = CloneIndex - center;
    
    float column = (int)(CloneIndex / row_count);    //�s�ԍ�
    float row = ((CloneIndex % row_count) - center); //��ԍ�
    
    float scatter = 4.2; //�΂���W��
    
    //�S�Ă̐e�{�[���̈ʒu����]���S�ɂ���
    Pos.xyz = Pos.xyz - MasterPos;
    
    //��]
    //Pos = rot_z(Pos, 10);
    //Pos = rot_x(Pos, 45);
    Pos = rot_y(Pos, cindex * 30);
    
    //�S�Ă̐e�{�[���̈ʒu����]���S�ɂ���(����������������߂�)
    Pos.xyz = Pos.xyz + MasterPos;
    
    //�ړ�
    Pos.x += row * 15;
    Pos.z += column * 15;
    
    //�΂����t��
    Pos.x += (sin(cindex) + sin(cindex * 3)) * scatter;
    Pos.z += (sin(cindex * 3.2) + sin(cindex * 5)) * scatter;
    
    
    return Pos;
}

///////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////
//����ȍ~�̓G�t�F�N�g�̒m���̂���l�ȊO�͐G��Ȃ�����


// �T�|�[�g�֐���`

#define PI 3.14159
#define DEG_TO_RAD (PI / 180)

float4 rot_x(float4 pos, float deg){
    deg = DEG_TO_RAD * deg;
    float4x4 rot = {
        {1,         0,        0 , 0},
        {0,  cos(deg), sin(deg) , 0},
        {0, -sin(deg), cos(deg) , 0},
        {0,         0,        0 , 1},
    }; // X����]�s��
    
    return mul(pos, rot);
}

float4 rot_y(float4 pos, float deg){
    deg = DEG_TO_RAD * deg;
    float4x4 rot = {
        {cos(deg), 0, -sin(deg), 0},
        {       0, 1,         0, 0},
        {sin(deg), 0,  cos(deg), 0},
        {       0, 0,         0, 1},
    }; // Y����]�s��
    
    return mul(pos, rot);
}

float4 rot_z(float4 pos, float deg){
    deg = DEG_TO_RAD * deg;
    float4x4 rot = {
        { cos(deg), sin(deg), 0, 0},
        {-sin(deg), cos(deg), 0, 0},
        {        0,        0, 1, 0},
        {        0,        0, 0, 1},
    }; // Z����]�s��
    
    return mul(pos, rot);
}


float4x4 inverseDir(float4x4 mat){
    return float4x4(
        mat._11, mat._21, mat._31, 0,
        mat._12, mat._22, mat._32, 0,
        mat._13, mat._23, mat._33, 0,
        0,0,0,1
    );
}

////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////

//�O���C���N���[�h����Ă���ꍇ�́A����ȍ~�̑S�Ă𖳎�����
#ifndef CLONE_PARAMINCLUDE

////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////
//���[�v�p�X�N���v�g

#define LOOPSCR "LoopByCount=CloneCount;" \
                "LoopGetIndex=CloneIndex;" \
                "Pass=DrawObject;" \
                "LoopEnd=;"


#if CLONE_MIPMAPTEX_SIZE==0
    #define LOOPSCR_TEX LOOPSCR
    
#else
    
    #define LOOPSCR_TEX \
        "RenderColorTarget0=UseMipmapObjectTexture;" \
                "RenderDepthStencilTarget=DepthBuffer;" \
                    "ClearSetColor=ClearColor;" \
                    "ClearSetDepth=ClearDepth;" \
                    "Clear=Color;" \
                    "Clear=Depth;" \
                "Pass=CreateMipmap;" \
            "RenderColorTarget0=;" \
                "RenderDepthStencilTarget=;" \
                    "LoopByCount=CloneCount;" \
                    "LoopGetIndex=CloneIndex;" \
                    "Pass=DrawObject;" \
                    "LoopEnd=;"

#endif


////////////////////////////////////////////////////////////////////////////////////////////////

float Script : STANDARDSGLOBAL <
    string ScriptOutput = "color";
    string ScriptClass = "sceneorobject";
    string ScriptOrder = "standard";
> = 0.8;

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
// ���C�g�F
float3   LightDiffuse      : DIFFUSE   < string Object = "Light"; >;
float3   LightAmbient      : AMBIENT   < string Object = "Light"; >;
float3   LightSpecular     : SPECULAR  < string Object = "Light"; >;
static float4 DiffuseColor  = MaterialDiffuse  * float4(LightDiffuse, 1.0f);
static float3 AmbientColor  = saturate(MaterialAmbient  * LightAmbient + MaterialEmmisive);
static float3 SpecularColor = MaterialSpecular * LightSpecular;

bool     parthf;   // �p�[�X�y�N�e�B�u�t���O
bool     transp;   // �������t���O
bool     spadd;    // �X�t�B�A�}�b�v���Z�����t���O
#define SKII1    1500
#define SKII2    8000
#define Toon     3

// �I�u�W�F�N�g�̃e�N�X�`��
texture ObjectTexture: MATERIALTEXTURE;

#if CLONE_MIPMAPTEX_SIZE==0
    sampler ObjTexSampler = sampler_state {
        texture = <ObjectTexture>;
        MINFILTER = LINEAR;
        MAGFILTER = LINEAR;
    };
    
#else
    sampler DefObjTexSampler = sampler_state {
        texture = <ObjectTexture>;
        MINFILTER = LINEAR;
        MAGFILTER = LINEAR;
    };
    
    texture UseMipmapObjectTexture : RENDERCOLORTARGET <
        int Width = CLONE_MIPMAPTEX_SIZE;
        int Height = CLONE_MIPMAPTEX_SIZE;
        int MipLevels = 0;
        string Format = "A8R8G8B8" ;
    >;
    sampler ObjTexSampler = sampler_state {
        texture = <UseMipmapObjectTexture>;
        MINFILTER = ANISOTROPIC;
        MAGFILTER = ANISOTROPIC;
        MIPFILTER = LINEAR;
        MAXANISOTROPY = 16;
    };
    
    
    texture2D DepthBuffer : RenderDepthStencilTarget <
        int Width = CLONE_MIPMAPTEX_SIZE;
        int Height = CLONE_MIPMAPTEX_SIZE;
        string Format = "D24S8";
    >;
    
    
    // �I�t�Z�b�g
    static float2 ViewportOffset = (float2(0.5,0.5)/CLONE_MIPMAPTEX_SIZE);
    
#endif

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


// �����_�����O�^�[�Q�b�g�̃N���A�l
float4 ClearColor = {0,0,0,0};
float ClearDepth  = 1.0;


////////////////////////////////////////////////////////////////////////////////////////////////
// �~�b�v�}�b�v�쐬

#if CLONE_MIPMAPTEX_SIZE!=0
    
    struct VS_OUTPUT_MIPMAPCREATER {
        float4 Pos    : POSITION;
        float2 Tex    : TEXCOORD0;
    };

    VS_OUTPUT_MIPMAPCREATER VS_MipMapCreater( float4 Pos : POSITION, float4 Tex : TEXCOORD0 ){
        VS_OUTPUT_MIPMAPCREATER Out;
        Out.Pos = Pos;
        Out.Tex = Tex.xy;
        Out.Tex += ViewportOffset;
        return Out;
    }
    
    float4  PS_MipMapCreater(float2 Tex: TEXCOORD0) : COLOR0
    {
        return tex2D(DefObjTexSampler,Tex);
    }
    
#endif

////////////////////////////////////////////////////////////////////////////////////////////////
// �֊s�`��

// ���_�V�F�[�_
float4 ColorRender_VS(float4 Pos : POSITION) : POSITION 
{
    
    float4 pos = Pos;
    
    // �J�������_�̃��[���h�r���[�ˉe�ϊ�
    return mul( ClonePos(pos), WorldViewProjMatrix );
}

// �s�N�Z���V�F�[�_
float4 ColorRender_PS() : COLOR
{
    // ���œh��Ԃ�
    return float4(0,0,0,1);
}

// �֊s�`��p�e�N�j�b�N
technique EdgeTec <
    string MMDPass = "edge";
    string Script = LOOPSCR;
> {
    pass DrawObject {
        AlphaBlendEnable = FALSE;
        AlphaTestEnable  = FALSE;

        VertexShader = compile vs_3_0 ColorRender_VS();
        PixelShader  = compile ps_3_0 ColorRender_PS();
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////
// �e�i��Z���t�V���h�E�j�`��

// ���_�V�F�[�_
float4 Shadow_VS(float4 Pos : POSITION) : POSITION
{
    float4 pos = Pos;
    
    // �J�������_�̃��[���h�r���[�ˉe�ϊ�
    return mul( ClonePos(pos), WorldViewProjMatrix );
}

// �s�N�Z���V�F�[�_
float4 Shadow_PS() : COLOR
{
    // �A���r�G���g�F�œh��Ԃ�
    return float4(AmbientColor.rgb, 0.65f);
}

// �e�`��p�e�N�j�b�N
technique ShadowTec < 
    string MMDPass = "shadow";
    string Script = LOOPSCR;
> {
    pass DrawObject {
        VertexShader = compile vs_2_0 Shadow_VS();
        PixelShader  = compile ps_2_0 Shadow_PS();
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////
// �I�u�W�F�N�g�`��i�Z���t�V���h�EOFF�j

struct VS_OUTPUT {
    float4 Pos        : POSITION;    // �ˉe�ϊ����W
    float2 Tex        : TEXCOORD1;   // �e�N�X�`��
    float3 Normal     : TEXCOORD2;   // �@��
    float3 Eye        : TEXCOORD3;   // �J�����Ƃ̑��Έʒu
    float2 SpTex      : TEXCOORD4;     // �X�t�B�A�}�b�v�e�N�X�`�����W
    float4 Color      : COLOR0;      // �f�B�t���[�Y�F
};

// ���_�V�F�[�_
VS_OUTPUT Basic_VS(float4 Pos : POSITION, float3 Normal : NORMAL, float2 Tex : TEXCOORD0, uniform bool useTexture, uniform bool useSphereMap, uniform bool useToon)
{
    VS_OUTPUT Out = (VS_OUTPUT)0;
    
    float4 pos = Pos;
    float4 pos_norm = pos + float4(Normal, 0);
    
    //���_����і@���̈ړ�
    pos = ClonePos(pos);
    pos_norm = ClonePos(pos_norm);
    Normal = normalize(pos_norm - pos).xyz;
    
    // �J�������_�̃��[���h�r���[�ˉe�ϊ�
    Out.Pos = mul( pos, WorldViewProjMatrix );
    
    // �J�����Ƃ̑��Έʒu
    Out.Eye = CameraPosition - mul( pos, WorldMatrix ).xyz;
    
    // ���_�@��
    Out.Normal = normalize( mul( Normal, (float3x3)WorldMatrix ) );
    
    // �f�B�t���[�Y�F�{�A���r�G���g�F �v�Z
    Out.Color.rgb = AmbientColor;
    if ( !useToon ) {
        Out.Color.rgb += max(0,dot( Out.Normal, -LightDirection )) * DiffuseColor.rgb;
    }
    Out.Color.a = DiffuseColor.a;
    Out.Color = saturate( Out.Color );
    
    // �e�N�X�`�����W
    Out.Tex = Tex;
    
    if ( useSphereMap ) {
        // �X�t�B�A�}�b�v�e�N�X�`�����W
        float3 NormalWV = mul( Out.Normal, (float3x3)ViewMatrix );
        Out.SpTex.x = NormalWV.x * 0.5f + 0.5f;
        Out.SpTex.y = NormalWV.y * -0.5f + 0.5f;
    }
    
    return Out;
}

// �s�N�Z���V�F�[�_
float4 Basic_PS(VS_OUTPUT IN, uniform bool useTexture, uniform bool useSphereMap, uniform bool useToon) : COLOR0
{
    // �X�y�L�����F�v�Z
    float3 HalfVector = normalize( normalize(IN.Eye) + -LightDirection );
    float3 Specular = pow( max(0,dot( HalfVector, normalize(IN.Normal) )), SpecularPower ) * SpecularColor;
    //float3 Specular = (float3)0;
    
    float4 Color = IN.Color;
    if ( useTexture ) {
        // �e�N�X�`���K�p
        Color *= tex2D( ObjTexSampler, IN.Tex );
    }
    if ( useSphereMap ) {
        // �X�t�B�A�}�b�v�K�p
        if(spadd) Color += tex2D(ObjSphareSampler,IN.SpTex);
        else      Color *= tex2D(ObjSphareSampler,IN.SpTex);
    }
    
    if ( useToon ) {
        // �g�D�[���K�p
        float LightNormal = dot( IN.Normal, -LightDirection );
        Color.rgb *= lerp(MaterialToon, float3(1,1,1), saturate(LightNormal * 16 + 0.5));
    }
    
    // �X�y�L�����K�p
    Color.rgb += Specular;
    
    return Color;
}


// �I�u�W�F�N�g�`��p�e�N�j�b�N�i�A�N�Z�T���p�j
// �s�v�Ȃ��͍̂폜��
technique MainTec0 < string MMDPass = "object"; bool UseTexture = false; bool UseSphereMap = false; bool UseToon = false;
    string Script = LOOPSCR;
> {
    pass DrawObject {
        VertexShader = compile vs_2_0 Basic_VS(false, false, false);
        PixelShader  = compile ps_2_0 Basic_PS(false, false, false);
    }
}

technique MainTec1 < string MMDPass = "object"; bool UseTexture = true; bool UseSphereMap = false; bool UseToon = false;
    string Script = LOOPSCR_TEX;
> {
    pass DrawObject {
        VertexShader = compile vs_2_0 Basic_VS(true, false, false);
        PixelShader  = compile ps_2_0 Basic_PS(true, false, false);
    }
    
    #if CLONE_MIPMAPTEX_SIZE!=0
    pass CreateMipmap < string Script= "Draw=Buffer;"; > {
        AlphaBlendEnable = FALSE;
        ZEnable = FALSE;
        VertexShader = compile vs_2_0 VS_MipMapCreater();
        PixelShader  = compile ps_2_0 PS_MipMapCreater();
    }
    #endif
}

technique MainTec2 < string MMDPass = "object"; bool UseTexture = false; bool UseSphereMap = true; bool UseToon = false;
    string Script = LOOPSCR;
> {
    pass DrawObject {
        VertexShader = compile vs_2_0 Basic_VS(false, true, false);
        PixelShader  = compile ps_2_0 Basic_PS(false, true, false);
    }
}

technique MainTec3 < string MMDPass = "object"; bool UseTexture = true; bool UseSphereMap = true; bool UseToon = false;
    string Script = LOOPSCR_TEX;
> {
    pass DrawObject {
        VertexShader = compile vs_2_0 Basic_VS(true, true, false);
        PixelShader  = compile ps_2_0 Basic_PS(true, true, false);
    }
    #if CLONE_MIPMAPTEX_SIZE!=0
    pass CreateMipmap < string Script= "Draw=Buffer;"; > {
        AlphaBlendEnable = FALSE;
        ZEnable = FALSE;
        VertexShader = compile vs_2_0 VS_MipMapCreater();
        PixelShader  = compile ps_2_0 PS_MipMapCreater();
    }
    #endif
}

// �I�u�W�F�N�g�`��p�e�N�j�b�N�iPMD���f���p�j
technique MainTec4 < string MMDPass = "object"; bool UseTexture = false; bool UseSphereMap = false; bool UseToon = true; 
    string Script = LOOPSCR;
> {
    pass DrawObject {
        VertexShader = compile vs_2_0 Basic_VS(false, false, true);
        PixelShader  = compile ps_2_0 Basic_PS(false, false, true);
    }
}

technique MainTec5 < string MMDPass = "object"; bool UseTexture = true; bool UseSphereMap = false; bool UseToon = true;
    string Script = LOOPSCR_TEX;
> {
    pass DrawObject {
        VertexShader = compile vs_2_0 Basic_VS(true, false, true);
        PixelShader  = compile ps_2_0 Basic_PS(true, false, true);
    }
    #if CLONE_MIPMAPTEX_SIZE!=0
    pass CreateMipmap < string Script= "Draw=Buffer;"; > {
        AlphaBlendEnable = FALSE;
        ZEnable = FALSE;
        VertexShader = compile vs_2_0 VS_MipMapCreater();
        PixelShader  = compile ps_2_0 PS_MipMapCreater();
    }
    #endif
}

technique MainTec6 < string MMDPass = "object"; bool UseTexture = false; bool UseSphereMap = true; bool UseToon = true;
    string Script = LOOPSCR;
> {
    pass DrawObject {
        VertexShader = compile vs_2_0 Basic_VS(false, true, true);
        PixelShader  = compile ps_2_0 Basic_PS(false, true, true);
    }
}

technique MainTec7 < string MMDPass = "object"; bool UseTexture = true; bool UseSphereMap = true; bool UseToon = true;
    string Script = LOOPSCR_TEX;
> {
    pass DrawObject {
        VertexShader = compile vs_2_0 Basic_VS(true, true, true);
        PixelShader  = compile ps_2_0 Basic_PS(true, true, true);
    }
    #if CLONE_MIPMAPTEX_SIZE!=0
    pass CreateMipmap < string Script= "Draw=Buffer;"; > {
        AlphaBlendEnable = FALSE;
        ZEnable = FALSE;
        VertexShader = compile vs_2_0 VS_MipMapCreater();
        PixelShader  = compile ps_2_0 PS_MipMapCreater();
    }
    #endif
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
    
    float4 pos = Pos;
    
    pos = ClonePos(pos);
    
    // ���C�g�̖ڐ��ɂ�郏�[���h�r���[�ˉe�ϊ�������
    Out.Pos = mul( pos, LightWorldViewProjMatrix );

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
technique ZplotTec < string MMDPass = "zplot";
    string Script = LOOPSCR;
> {
    pass DrawObject {
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
    float4 Pos      : POSITION;     // �ˉe�ϊ����W
    float4 ZCalcTex : TEXCOORD0;    // Z�l
    float2 Tex      : TEXCOORD1;    // �e�N�X�`��
    float3 Normal   : TEXCOORD2;    // �@��
    float3 Eye      : TEXCOORD3;    // �J�����Ƃ̑��Έʒu
    float2 SpTex    : TEXCOORD4;     // �X�t�B�A�}�b�v�e�N�X�`�����W
    float4 Color    : COLOR0;       // �f�B�t���[�Y�F
};

// ���_�V�F�[�_
BufferShadow_OUTPUT BufferShadow_VS(float4 Pos : POSITION, float3 Normal : NORMAL, float2 Tex : TEXCOORD0, uniform bool useTexture, uniform bool useSphereMap, uniform bool useToon)
{
    BufferShadow_OUTPUT Out = (BufferShadow_OUTPUT)0;
    
    float4 pos = Pos;
    float4 pos_norm = pos + float4(Normal, 0);
    
    //���_����і@���̈ړ�
    pos = ClonePos(pos);
    pos_norm = ClonePos(pos_norm);
    Normal = normalize(pos_norm - pos).xyz;
    
    
    // �J�������_�̃��[���h�r���[�ˉe�ϊ�
    Out.Pos = mul( pos, WorldViewProjMatrix );
    
    // �J�����Ƃ̑��Έʒu
    Out.Eye = CameraPosition - mul( pos, WorldMatrix );
    // ���_�@��
    Out.Normal = normalize( mul( Normal, (float3x3)WorldMatrix ) );
    // ���C�g���_�ɂ�郏�[���h�r���[�ˉe�ϊ�
    Out.ZCalcTex = mul( pos, LightWorldViewProjMatrix );
    
    // �f�B�t���[�Y�F�{�A���r�G���g�F �v�Z
    Out.Color.rgb = AmbientColor;
    if ( !useToon ) {
        Out.Color.rgb += max(0,dot( Out.Normal, -LightDirection )) * DiffuseColor.rgb;
    }
    Out.Color.a = DiffuseColor.a;
    Out.Color = saturate( Out.Color );
    
    // �e�N�X�`�����W
    Out.Tex = Tex;
    
    if ( useSphereMap ) {
        // �X�t�B�A�}�b�v�e�N�X�`�����W
        float2 NormalWV = mul( Out.Normal, (float3x3)ViewMatrix );
        Out.SpTex.x = NormalWV.x * 0.5f + 0.5f;
        Out.SpTex.y = NormalWV.y * -0.5f + 0.5f;
    }
    
    return Out;
}

// �s�N�Z���V�F�[�_
float4 BufferShadow_PS(BufferShadow_OUTPUT IN, uniform bool useTexture, uniform bool useSphereMap, uniform bool useToon) : COLOR
{
    // �X�y�L�����F�v�Z
    float3 HalfVector = normalize( normalize(IN.Eye) + -LightDirection );
    float3 Specular = pow( max(0,dot( HalfVector, normalize(IN.Normal) )), SpecularPower ) * SpecularColor;
    
    float4 Color = IN.Color;
    float4 ShadowColor = float4(AmbientColor, Color.a);  // �e�̐F
    if ( useTexture ) {
        // �e�N�X�`���K�p
        float4 TexColor = tex2D( ObjTexSampler, IN.Tex );
        Color *= TexColor;
        ShadowColor *= TexColor;
    }
    if ( useSphereMap ) {
        // �X�t�B�A�}�b�v�K�p
        float4 TexColor = tex2D(ObjSphareSampler,IN.SpTex);
        if(spadd) {
            Color += TexColor;
            ShadowColor += TexColor;
        } else {
            Color *= TexColor;
            ShadowColor *= TexColor;
        }
    }
    // �X�y�L�����K�p
    Color.rgb += Specular;
    
    // �e�N�X�`�����W�ɕϊ�
    IN.ZCalcTex /= IN.ZCalcTex.w;
    float2 TransTexCoord;
    TransTexCoord.x = (1.0f + IN.ZCalcTex.x)*0.5f;
    TransTexCoord.y = (1.0f - IN.ZCalcTex.y)*0.5f;
    
    if( any( saturate(TransTexCoord) != TransTexCoord ) ) {
        // �V���h�E�o�b�t�@�O
        return Color;
    } else {
        float comp;
        if(parthf) {
            // �Z���t�V���h�E mode2
            comp=1-saturate(max(IN.ZCalcTex.z-tex2D(DefSampler,TransTexCoord).r , 0.0f)*SKII2*TransTexCoord.y-0.3f);
        } else {
            // �Z���t�V���h�E mode1
            comp=1-saturate(max(IN.ZCalcTex.z-tex2D(DefSampler,TransTexCoord).r , 0.0f)*SKII1-0.3f);
        }
        if ( useToon ) {
            // �g�D�[���K�p
            comp = min(saturate(dot(IN.Normal,-LightDirection)*Toon),comp);
            ShadowColor.rgb *= MaterialToon;
        }
        
        float4 ans = lerp(ShadowColor, Color, comp);
        if( transp ) ans.a = 0.5f;
        return ans;
    }
}

// �I�u�W�F�N�g�`��p�e�N�j�b�N�i�A�N�Z�T���p�j
technique MainTecBS0  < string MMDPass = "object_ss"; bool UseTexture = false; bool UseSphereMap = false; bool UseToon = false;
    string Script = LOOPSCR;
> {
    pass DrawObject {
        VertexShader = compile vs_3_0 BufferShadow_VS(false, false, false);
        PixelShader  = compile ps_3_0 BufferShadow_PS(false, false, false);
    }
}

technique MainTecBS1  < string MMDPass = "object_ss"; bool UseTexture = true; bool UseSphereMap = false; bool UseToon = false;
    string Script = LOOPSCR_TEX;
> {
    pass DrawObject {
        VertexShader = compile vs_3_0 BufferShadow_VS(true, false, false);
        PixelShader  = compile ps_3_0 BufferShadow_PS(true, false, false);
    }
    #if CLONE_MIPMAPTEX_SIZE!=0
    pass CreateMipmap < string Script= "Draw=Buffer;"; > {
        AlphaBlendEnable = FALSE;
        ZEnable = FALSE;
        VertexShader = compile vs_2_0 VS_MipMapCreater();
        PixelShader  = compile ps_2_0 PS_MipMapCreater();
    }
    #endif
}

technique MainTecBS2  < string MMDPass = "object_ss"; bool UseTexture = false; bool UseSphereMap = true; bool UseToon = false;
    string Script = LOOPSCR;
> {
    pass DrawObject {
        VertexShader = compile vs_3_0 BufferShadow_VS(false, true, false);
        PixelShader  = compile ps_3_0 BufferShadow_PS(false, true, false);
    }
}

technique MainTecBS3  < string MMDPass = "object_ss"; bool UseTexture = true; bool UseSphereMap = true; bool UseToon = false;
    string Script = LOOPSCR_TEX;
> {
    pass DrawObject {
        VertexShader = compile vs_3_0 BufferShadow_VS(true, true, false);
        PixelShader  = compile ps_3_0 BufferShadow_PS(true, true, false);
    }
    #if CLONE_MIPMAPTEX_SIZE!=0
    pass CreateMipmap < string Script= "Draw=Buffer;"; > {
        AlphaBlendEnable = FALSE;
        ZEnable = FALSE;
        VertexShader = compile vs_2_0 VS_MipMapCreater();
        PixelShader  = compile ps_2_0 PS_MipMapCreater();
    }
    #endif
}

// �I�u�W�F�N�g�`��p�e�N�j�b�N�iPMD���f���p�j
technique MainTecBS4  < string MMDPass = "object_ss"; bool UseTexture = false; bool UseSphereMap = false; bool UseToon = true;
    string Script = LOOPSCR;
> {
    pass DrawObject {
        VertexShader = compile vs_3_0 BufferShadow_VS(false, false, true);
        PixelShader  = compile ps_3_0 BufferShadow_PS(false, false, true);
    }
}

technique MainTecBS5  < string MMDPass = "object_ss"; bool UseTexture = true; bool UseSphereMap = false; bool UseToon = true;
    string Script = LOOPSCR_TEX;
> {
    pass DrawObject {
        VertexShader = compile vs_3_0 BufferShadow_VS(true, false, true);
        PixelShader  = compile ps_3_0 BufferShadow_PS(true, false, true);
    }
    #if CLONE_MIPMAPTEX_SIZE!=0
    pass CreateMipmap < string Script= "Draw=Buffer;"; > {
        AlphaBlendEnable = FALSE;
        ZEnable = FALSE;
        VertexShader = compile vs_2_0 VS_MipMapCreater();
        PixelShader  = compile ps_2_0 PS_MipMapCreater();
    }
    #endif
}

technique MainTecBS6  < string MMDPass = "object_ss"; bool UseTexture = false; bool UseSphereMap = true; bool UseToon = true;
    string Script = LOOPSCR;
> {
    pass DrawObject {
        VertexShader = compile vs_3_0 BufferShadow_VS(false, true, true);
        PixelShader  = compile ps_3_0 BufferShadow_PS(false, true, true);
    }
}

technique MainTecBS7  < string MMDPass = "object_ss"; bool UseTexture = true; bool UseSphereMap = true; bool UseToon = true;
    string Script = LOOPSCR_TEX;
> {
    pass DrawObject {
        VertexShader = compile vs_3_0 BufferShadow_VS(true, true, true);
        PixelShader  = compile ps_3_0 BufferShadow_PS(true, true, true);
    }
    #if CLONE_MIPMAPTEX_SIZE!=0
    pass CreateMipmap < string Script= "Draw=Buffer;"; > {
        AlphaBlendEnable = FALSE;
        ZEnable = FALSE;
        VertexShader = compile vs_2_0 VS_MipMapCreater();
        PixelShader  = compile ps_2_0 PS_MipMapCreater();
    }
    #endif
}


///////////////////////////////////////////////////////////////////////////////////////////////


#endif //CLONE_PARAMINCLUDE





