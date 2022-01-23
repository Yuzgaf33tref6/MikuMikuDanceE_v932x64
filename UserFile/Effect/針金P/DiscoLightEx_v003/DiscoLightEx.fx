////////////////////////////////////////////////////////////////////////////////////////////////
//
//  DiscoLightEx.fx v0.0.3
//  �쐬: �j��P( ���͉��P����DiscoLighting���� )
//
////////////////////////////////////////////////////////////////////////////////////////////////
// �����̃p�����[�^��ύX���Ă�������
//(DLEX_Object.fxsub�Ɠ����p�����[�^�͓����l�ɐݒ肵�Ă�������)

// �Z���t�V���h�E�̗L��
#define Use_SelfShadow  1  // 0:�Ȃ�, 1:�L��

// �\�t�g�V���h�E�̗L��
#define UseSoftShadow  1  // 0:�Ȃ�, 1:�L��

// �V���h�E�}�b�v�o�b�t�@�T�C�Y
#define ShadowMapSize  1024   // 512, 1024, 2048, 4096 �̂ǂꂩ�őI��



// ����Ȃ��l�͂������牺�͂�����Ȃ��ł�

///////////////////////////////////////////////////////////////////

float Script : STANDARDSGLOBAL <
    string ScriptOutput = "color";
    string ScriptClass = "sceneorobject";
    string ScriptOrder = "postprocess";
> = 0.8;


// �X�N���[���T�C�Y
float2 ViewportSize : VIEWPORTPIXELSIZE;
static float2 ViewportOffset = (float2(0.5,0.5)/ViewportSize);

#ifdef MIKUMIKUMOVING
// �����_�����O�^�[�Q�b�g�̃N���A�l
float4 ClearColor = {0,0,0,1};
float ClearDepth  = 1.0;

// �e�N�X�`���t�H�[�}�b�g
#define TEX_FORMAT "D3DFMT_A16B16G16R16F"

// �I���W�i���̕`�挋�ʂ��L�^���邽�߂̃����_�[�^�[�Q�b�g
texture2D ScnMap : RENDERCOLORTARGET <
    float2 ViewPortRatio = {1.0,1.0};
    int MipLevels = 1;
    string Format = TEX_FORMAT;
>;
sampler2D ScnSamp = sampler_state {
    texture = <ScnMap>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = NONE;
    AddressU = CLAMP;
    AddressV = CLAMP;
};

texture2D DepthBuffer : RENDERDEPTHSTENCILTARGET <
    float2 ViewPortRatio = {1.0,1.0};
    string Format = "D3DFMT_D24S8";
>;
#endif


////////////////////////////////////////////////////////////////////////////////////////////////
// ���I�o�����ʃV���h�E�}�b�v�`���I�t�X�N���[���o�b�t�@

#if Use_SelfShadow==1

#define SMAPSIZE_WIDTH   ShadowMapSize
#define SMAPSIZE_HEIGHT  ShadowMapSize

shared texture DL_ShadowMap : OFFSCREENRENDERTARGET <
    string Description = "DiscoLightEx.fx�̃V���h�E�}�b�v�o�b�t�@";
    int Width  = SMAPSIZE_WIDTH;
    int Height = SMAPSIZE_HEIGHT;
    float4 ClearColor = { 1, 1, 1, 1 };
    float ClearDepth = 1.0;
    #if UseSoftShadow==1
    string Format = "D3DFMT_G32R32F" ;
    int Miplevels = 0;
    #else
    string Format = "D3DFMT_R32F" ;
    int Miplevels = 1;
    #endif
    bool AntiAlias = false;
    string DefaultEffect = 
        "self = hide;"
        "DiscoLightEx.pmx = hide;"
        "DiscoLightBall.x = hide;"
        "FloorAssist.x = DLEX_ShadowMapFA.fxsub;"
        "* = DLEX_ShadowMap.fxsub;"
    ;
>;

#endif

///////////////////////////////////////////////////////////////////
// DiscoLighting�`���I�t�X�N���[���o�b�t�@

texture DiscoLightingRT: OFFSCREENRENDERTARGET <
    string Description = "DiscoLightEx.fx�̃��f���`��";
    float2 ViewPortRatio = {1.0,1.0};
    float4 ClearColor = { 0, 0, 0, 1 };
    float ClearDepth = 1.0;
    bool AntiAlias = true;
    string DefaultEffect = 
        "self = hide;"
        "DiscoLightEx.pmx = hide;"
        "FloorAssist.x = hide;"
        "DiscoLightBall.x = DiscoLightBallMask.fxsub;"
        "* = DLEX_Object.fxsub;" 
    ;
>;
sampler DiscoLightingView = sampler_state {
    texture = <DiscoLightingRT>;
//    texture = <DL_ShadowMap>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = NONE;
    AddressU  = CLAMP;
    AddressV = CLAMP;
};


////////////////////////////////////////////////////////////////////////////////////////////////

struct VS_OUTPUT {
    float4 Pos : POSITION;
    float2 Tex : TEXCOORD0;
};

// ���_�V�F�[�_
VS_OUTPUT VS_Draw( float4 Pos : POSITION, float4 Tex : TEXCOORD0 )
{
    VS_OUTPUT Out = (VS_OUTPUT)0; 

    Out.Pos = Pos;
    Out.Tex = Tex + ViewportOffset;

    return Out;
}

// �s�N�Z���V�F�[�_
float4 PS_Draw( float2 Tex: TEXCOORD0 ) : COLOR
{
    float4 Color = tex2D( DiscoLightingView, Tex );

    #ifdef MIKUMIKUMOVING
    float4 Color0 = tex2D( ScnSamp, Tex );
    Color.rgb += Color0.rgb;
    Color.a = Color0.a;
    #endif

    return Color;
}


///////////////////////////////////////////////////////////////////////////////////////
// �e�N�j�b�N

technique MainTech1 < string MMDPass = "object";
    string Script = 
        #ifdef MIKUMIKUMOVING
        "RenderColorTarget0=ScnMap;"
            "RenderDepthStencilTarget=DepthBuffer;"
            "ClearSetColor=ClearColor;"
            "ClearSetDepth=ClearDepth;"
            "Clear=Color;"
            "Clear=Depth;"
            "ScriptExternal=Color;"
        #endif
        "RenderColorTarget0=;"
            "RenderDepthStencilTarget=;"
            #ifndef MIKUMIKUMOVING
            "ScriptExternal=Color;"
            #endif
            "Pass=DrawPass;"
        ; >
{
    pass DrawPass < string Script= "Draw=Buffer;"; > {
        #ifndef MIKUMIKUMOVING
        ZEnable = FALSE;
        AlphaBlendEnable = TRUE;
        SrcBlend = ONE;
        DestBlend = ONE;
        #endif
        VertexShader = compile vs_2_0 VS_Draw();
        PixelShader  = compile ps_2_0 PS_Draw();
    }
}


