////////////////////////////////////////////////////////////////////////////////////////////////
//
//  PostClip (PostClip_Obj.fx) ver0.0.1
//  �����̃|�X�g�G�t�F�N�g�����̈�ŃN���b�v�i�w�肵�����f���`��ŃN���b�v�j
//  �쐬: �j��P
//
////////////////////////////////////////////////////////////////////////////////////////////////
// �p�����[�^�錾

#include "PostClipHeader.fxh"

float Script : STANDARDSGLOBAL <
    string ScriptOutput = "color";
    string ScriptClass = "scene";
    string ScriptOrder = "postprocess";
> = 0.8;

// �A�N�Z�T���p�����[�^
float AcsTr : CONTROLOBJECT < string name = "(self)"; string item = "Tr"; >;

#ifndef MIKUMIKUMOVING

    float3 AcsXYZ : CONTROLOBJECT < string name = "(self)"; string item = "XYZ"; >;
    static bool ClipFlag = (AcsXYZ.x < 0.999f) ? false : true;   // �N���b�v���s
    static bool MulFlag  = (AcsXYZ.y < 0.999f) ? false : true;   // �_���ύ���
    static bool InvFlag  = (AcsXYZ.z < 0.999f) ? false : true;   // �N���b�v���]

#else

    bool ClipFlag <        // �N���b�v���s
       string UIName = "�N���b�v���s";
       bool UIVisible =  true;
    > = true;

    bool MulFlag <        // �_���ύ���
       string UIName = "�_����";
       bool UIVisible =  true;
    > = false;

    bool InvFlag <        // �N���b�v���]
       string UIName = "���]";
       bool UIVisible =  true;
    > = false;

#endif


// �X�N���[���T�C�Y
float2 ViewportSize : VIEWPORTPIXELSIZE;
static float2 ViewportOffset = (float2(0.5,0.5)/ViewportSize);

// �����_�����O�^�[�Q�b�g�̃N���A�l
float4 ClearColor = {0,0,0,0};
float ClearDepth  = 1.0;

// �|�X�g�G�t�F�N�g��������O�̉摜
shared texture2D ScnMapSrc : RENDERCOLORTARGET;
sampler2D ScnSampSrc = sampler_state {
    texture = <ScnMapSrc>;
    MinFilter = POINT;
    MagFilter = POINT;
    MipFilter = NONE;
    AddressU = CLAMP;
    AddressV = CLAMP;
};

// �N���b�v�̈�̃}�b�s���O�摜
shared texture2D ScnClipMap : RENDERCOLORTARGET;
sampler2D ScnSampClip = sampler_state {
    texture = <ScnClipMap>;
    MinFilter = POINT;
    MagFilter = POINT;
    MipFilter = NONE;
    AddressU = CLAMP;
    AddressV = CLAMP;
};


// �I���W�i���̕`�挋�ʂ��L�^���邽�߂̃����_�[�^�[�Q�b�g
texture2D ScnMap : RENDERCOLORTARGET <
    float2 ViewPortRatio = {1.0,1.0};
    int MipLevels = 1;
    string Format = TEX_FORMAT;
>;
sampler2D ScnSamp = sampler_state {
    texture = <ScnMap>;
    MinFilter = POINT;
    MagFilter = POINT;
    MipFilter = NONE;
    AddressU = CLAMP;
    AddressV = CLAMP;
};

texture2D DepthBuffer : RENDERDEPTHSTENCILTARGET <
    float2 ViewPortRatio = {1.0,1.0};
    string Format = "D24S8";
>;

#ifndef MIKUMIKUMOVING
    #define OFFSCREEN_MASK "PC_ObjMask.fxsub"
#else
    #define OFFSCREEN_MASK "PC_ObjMaskMMM.fxsub"
#endif

// �w�肵�����f���̃}�X�N�͈͂̕`���I�t�X�N���[���o�b�t�@
texture PC_ObjRT: OFFSCREENRENDERTARGET <
    string Description = "PostClip�̃I�u�W�F�N�g�}�X�N�o�b�t�@";
    float2 ViewPortRatio = {1.0,1.0};
    float4 ClearColor = { 0, 0, 0, 1 };
    float ClearDepth = 1.0;
    bool AntiAlias = false;
    string DefaultEffect = 
        "self = hide;"
        "PreClip.x = hide;"
        "* =" OFFSCREEN_MASK ";";
>;
sampler MaskSamp = sampler_state {
    texture = <PC_ObjRT>;
    MinFilter = POINT;
    MagFilter = POINT;
    MipFilter = NONE;
    AddressU = CLAMP;
    AddressV = CLAMP;
};


////////////////////////////////////////////////////////////////////////////////////////////////
// �|�X�g�G�t�F�N�g�̑O�ƌ�̉摜������

struct VS_OUTPUT {
    float4 Pos : POSITION;
    float2 Tex : TEXCOORD0;
};

// ���_�V�F�[�_
VS_OUTPUT VS_Clip( float4 Pos : POSITION, float2 Tex : TEXCOORD0 )
{
    VS_OUTPUT Out = (VS_OUTPUT)0; 
    Out.Pos = Pos;
    Out.Tex = Tex + ViewportOffset;
    return Out;
}

// �s�N�Z���V�F�[�_(�N���b�v�͈͕`��)
float4 PS_Clip( float2 Tex: TEXCOORD0 ) : COLOR
{
    // ���O�܂ł̃N���b�v��������
    float s0 = tex2D( ScnSampClip, Tex ).r;

    // ���̃G�t�F�N�g�̃N���b�v�͈�
    float4 MaskColor = tex2D( MaskSamp, Tex );
    float s = MaskColor.r;

    // �N���b�v����
    if(InvFlag) s = 1.0f - s;
    s *= AcsTr;
    s = MulFlag ? s*s0 : max(s, s0);

    return float4(s, 0, 0, 1);

}

// �s�N�Z���V�F�[�_(�摜�`��)
float4 PS_Draw( float2 Tex: TEXCOORD0 ) : COLOR
{
    // �|�X�g�G�t�F�N�g�����O�̉摜
    float4 Color0 = tex2D( ScnSampSrc, Tex );

    // �|�X�g�G�t�F�N�g������̉摜
    float4 Color = tex2D( ScnSamp, Tex );

    // �N���b�v�͈�
    float4 s = tex2D( ScnSampClip, Tex ).r;

    // ����
    if(ClipFlag) Color = lerp(Color0, Color, s);

    return Color;

}

////////////////////////////////////////////////////////////////////////////////////////////////
// �e�N�j�b�N

technique MainTech <
    string Script = 
        "RenderColorTarget0=ScnMap;"
            "RenderDepthStencilTarget=DepthBuffer;"
            "ClearSetColor=ClearColor;"
            "ClearSetDepth=ClearDepth;"
            "Clear=Color;"
            "Clear=Depth;"
            "ScriptExternal=Color;"
        "RenderColorTarget0=ScnClipMap;"
            "RenderDepthStencilTarget=DepthBuffer;"
            "Pass=PostClip;"
        "RenderColorTarget0=;"
            "RenderDepthStencilTarget=;"
            "Pass=PostDraw;"
    ;
> {
    pass PostClip < string Script= "Draw=Buffer;"; > {
        AlphaBlendEnable = FALSE;
        VertexShader = compile vs_2_0 VS_Clip();
        PixelShader  = compile ps_2_0 PS_Clip();
    }
    pass PostDraw < string Script= "Draw=Buffer;"; > {
        AlphaBlendEnable = FALSE;
        VertexShader = compile vs_2_0 VS_Clip();
        PixelShader  = compile ps_2_0 PS_Draw();
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////
