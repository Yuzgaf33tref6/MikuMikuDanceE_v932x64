

//@@@@@@@@@@@@@@@@@@@@@@
float Ghost1Alpha = 0.4;
float Ghost2Alpha = 0.3;
float Ghost3Alpha = 0.2;



float Script : STANDARDSGLOBAL <
    string ScriptOutput = "color";
    string ScriptClass = "scene";
    string ScriptOrder = "postprocess";
> = 0.8;





float alpha1 : CONTROLOBJECT < string name = "(self)"; string item = "Tr"; >;

// �X�P�[���l�擾
float scaling0 : CONTROLOBJECT < string name = "(self)"; >;
static float scaling = scaling0 * 0.1;



//�t���[�����ԂƃV�X�e�����Ԃ���v������Đ����Ƃ݂Ȃ�
float elapsed_time1 : ELAPSEDTIME<bool SyncInEditMode=true;>;
float elapsed_time2 : ELAPSEDTIME<bool SyncInEditMode=false;>;
static bool IsPlaying = (abs(elapsed_time1 - elapsed_time2) < 0.01);


//�}�E�X
float4 LeftButton : LEFTMOUSEDOWN;
float4 RightButton : RIGHTMOUSEDOWN;

static bool BothClick = (LeftButton.z != 0) && (RightButton.z != 0);

// �X�N���[���T�C�Y
float2 ViewportSize : VIEWPORTPIXELSIZE;
static float Aspect = ViewportSize.x / ViewportSize.y;
static float2 ViewportOffset = (float2(0.5,0.5)/ViewportSize);
static float2 OnePx = (float2(1,1)/ViewportSize);

////////////////////////////////////////////////////////////////////////////////////
// �[�x�o�b�t�@
texture2D DepthBuffer : RENDERDEPTHSTENCILTARGET <
    float2 ViewPortRatio = {1.0,1.0};
    string Format = "D24S8";
>;


///////////////////////////////////////////////////////////////////////////////////////////////
// �����˃I�u�W�F�N�g�`���

texture GhostMotionRT: OFFSCREENRENDERTARGET <
    string Description = "GhostMotionRenderTarget for GhostMotion";
    float2 ViewPortRatio = {1.0,1.0};
    float4 ClearColor = { 0, 0, 0, 0 };
    float ClearDepth = 1.0;
    bool AntiAlias = true;
    int MipLevels = 1;
    string Format = "A8R8G8B8";
    string DefaultEffect = 
        "self = hide;"
        
        "* = hide;"
        
    ;
>;


sampler GhostView = sampler_state {
    texture = <GhostMotionRT>;
    MinFilter = Linear;
    MagFilter = Linear;
    MipFilter = Point;
    AddressU  = Clamp;
    AddressV = Clamp;
};

///////////////////////////////////////////////////////////////////////////////////////////////

texture2D lastGhost : RENDERCOLORTARGET <
    float2 ViewPortRatio = {1.0,1.0};
    int MipLevels = 1;
    string Format = "A8R8G8B8";
    
>;

sampler lastGhostView = sampler_state {
    texture = <lastGhost>;
    AddressU  = CLAMP;
    AddressV = CLAMP;
    Filter = NONE;
};

texture2D Ghost1 : RENDERCOLORTARGET <
    float2 ViewPortRatio = {1.0,1.0};
    int MipLevels = 1;
    string Format = "A8R8G8B8";
    
>;

sampler Ghost1Sampler = sampler_state {
    texture = <Ghost1>;
    AddressU  = CLAMP;
    AddressV = CLAMP;
    Filter = NONE;
};

//@@@@@@@@@@@@@@@@@@@@@@
texture2D Ghost2 : RENDERCOLORTARGET <
    float2 ViewPortRatio = {1.0,1.0};
    int MipLevels = 1;
    string Format = "A8R8G8B8";
    
>;

sampler Ghost2Sampler = sampler_state {
    texture = <Ghost2>;
    AddressU  = CLAMP;
    AddressV = CLAMP;
    Filter = NONE;
};

texture2D Ghost3 : RENDERCOLORTARGET <
    float2 ViewPortRatio = {1.0,1.0};
    int MipLevels = 1;
    string Format = "A8R8G8B8";
    
>;

sampler Ghost3Sampler = sampler_state {
    texture = <Ghost3>;
    AddressU  = CLAMP;
    AddressV = CLAMP;
    Filter = NONE;
};

///////////////////////////////////////////////////////////////////////////////////////////////

//�o�b�t�@�̕�
#define INFOBUFSIZE 4

//�s��̋L�^
texture DepthBufferMB : RenderDepthStencilTarget <
   int Width=INFOBUFSIZE;
   int Height=1;
    string Format = "D24S8";
>;
texture MatrixBufTex : RenderColorTarget
<
    int Width=INFOBUFSIZE;
    int Height=1;
    bool AntiAlias = false;
    int Miplevels = 1;
    string Format="A32B32G32R32F";
>;

float4 MatrixBufArray[INFOBUFSIZE] : TEXTUREVALUE <
    string TextureName = "MatrixBufTex";
>;



////////////////////////////////////////////////////////////////////////////////////////////////

float time1 : TIME<bool SyncInEditMode=true;>;
static float lasttime = MatrixBufArray[0].r;

static bool FlameChanged = abs(lasttime - time1) > 0.01;


////////////////////////////////////////////////////////////////////////////////////////////////
// ���ʒ��_�V�F�[�_
struct VS_OUTPUT {
    float4 Pos            : POSITION;
    float2 Tex            : TEXCOORD0;
};

VS_OUTPUT VS_passDraw( float4 Pos : POSITION, float2 Tex : TEXCOORD0 ) {
    VS_OUTPUT Out = (VS_OUTPUT)0; 
    
    Out.Pos = Pos;
    Out.Tex = Tex + ViewportOffset;
    
    return Out;
}

////////////////////////////////////////////////////////////////////////////////////////////////
// �t���[���ړ����_�V�F�[�_

VS_OUTPUT VS_passFlameMove( float4 Pos : POSITION, float2 Tex : TEXCOORD0 ) {
    VS_OUTPUT Out = (VS_OUTPUT)0; 
    
    Out.Pos = Pos + ((!(FlameChanged || BothClick)) * 100);
    Out.Tex = Tex + ViewportOffset;
    
    return Out;
}

////////////////////////////////////////////////////////////////////////////////////////////////
// �o�b�t�@�̃R�s�[

float4 PS_BufCopy( float2 Tex: TEXCOORD0 , uniform sampler2D samp ) : COLOR {   
    float4 Color = tex2D(samp, Tex);
    
    Color *= !BothClick;
    
    return Color;
}


////////////////////////////////////////////////////////////////////////////////////////////////
// �S�[�X�g����

float4 PS_MixGhost( float2 Tex: TEXCOORD0 ) : COLOR0 {
    float4 Color = (float4)0;
    
    //@@@@@@@@@@@@@@@@@@@@@@
    Color = lerp(Color, tex2D(Ghost3Sampler, Tex), Ghost3Alpha);
    Color = lerp(Color, tex2D(Ghost2Sampler, Tex), Ghost2Alpha);
    Color = lerp(Color, tex2D(Ghost1Sampler, Tex), Ghost1Alpha);
    
    Color.rgb = saturate(Color.rgb / Color.a);
    
    Color.a *= alpha1;
    
    float4 basecolor = tex2D(GhostView, Tex);
    Color = lerp(Color, basecolor, basecolor.a * saturate(1 - scaling));
    
    return Color;
}


////////////////////////////////////////////////////////////////////////////////////////////////
//���o�b�t�@
struct VS_OUTPUT2 {
    float4 Pos: POSITION;
    float2 Tex: TEXCOORD0;
};


VS_OUTPUT2 DrawMatrixBuf_VS(float4 Pos: POSITION, float2 Tex: TEXCOORD) {
    VS_OUTPUT2 Out;
    
    Out.Tex = Tex;
    Out.Pos = Pos;
    
    return Out;
}

float4 DrawMatrixBuf_PS(float2 Tex: TEXCOORD0) : COLOR {
    
    //���Ԃ��L�^
    float4 Color = float4((float3)time1, 1);
    
    return Color;
}


/////////////////////////////////////////////////////////////////////////////////////

// �I�u�W�F�N�g�`��p�e�N�j�b�N

float4 ClearColor = {0,0,0,0};
float ClearDepth  = 1.0;

technique MainTec1 < 
    string MMDPass = "object"; 
    string Script =
        
        "RenderColorTarget=MatrixBufTex;"
        "RenderDepthStencilTarget=DepthBufferMB;"
        "Pass=DrawMatrixBuf;"
        
        "RenderColorTarget0=;"
        "RenderDepthStencilTarget=;"
        "ClearSetColor=ClearColor; ClearSetDepth=ClearDepth;"
        "Clear=Color; Clear=Depth;"
        "ScriptExternal=Color;"
        
        //@@@@@@@@@@@@@@@@@@@@@@
        "RenderColorTarget=Ghost3;"
        "RenderDepthStencilTarget=DepthBuffer;"
        "Clear=Depth;"
        "Pass=DrawCopy3;"
        
        "RenderColorTarget=Ghost2;"
        "RenderDepthStencilTarget=DepthBuffer;"
        "Clear=Depth;"
        "Pass=DrawCopy2;"
        
        
        
        "RenderColorTarget=Ghost1;"
        "RenderDepthStencilTarget=DepthBuffer;"
        "Clear=Depth;"
        "Pass=DrawCopy1;"
        
        "RenderColorTarget0=;"
        "RenderDepthStencilTarget=;"
        "Clear=Depth;"
        "Pass=DrawGhost;"
        
        "RenderColorTarget=lastGhost;"
        "RenderDepthStencilTarget=DepthBuffer;"
        "Clear=Depth;"
        "Pass=DrawlastGhost;"
        
    ;
> {
    
    pass DrawMatrixBuf  < string Script = "Draw=Buffer;";>   { 
        AlphaBlendEnable = false;
        AlphaTestEnable = false;
        VertexShader = compile vs_2_0 DrawMatrixBuf_VS();
        PixelShader  = compile ps_2_0 DrawMatrixBuf_PS(); 
    }
    
    pass DrawCopy1 < string Script = "Draw=Buffer;";> { 
        AlphaBlendEnable = false;
        AlphaTestEnable = false;
        VertexShader = compile vs_2_0 VS_passFlameMove();
        PixelShader  = compile ps_2_0 PS_BufCopy(lastGhostView); 
    }
    
    //@@@@@@@@@@@@@@@@@@@@@@
    pass DrawCopy2 < string Script = "Draw=Buffer;";> { 
        AlphaBlendEnable = false;
        AlphaTestEnable = false;
        VertexShader = compile vs_2_0 VS_passFlameMove();
        PixelShader  = compile ps_2_0 PS_BufCopy(Ghost1Sampler); 
    }
    pass DrawCopy3 < string Script = "Draw=Buffer;";> { 
        AlphaBlendEnable = false;
        AlphaTestEnable = false;
        VertexShader = compile vs_2_0 VS_passFlameMove();
        PixelShader  = compile ps_2_0 PS_BufCopy(Ghost2Sampler); 
    }
    
    
    
    pass DrawGhost < string Script = "Draw=Buffer;";> { 
        AlphaBlendEnable = true;
        AlphaTestEnable = true;
        VertexShader = compile vs_2_0 VS_passDraw();
        PixelShader  = compile ps_2_0 PS_MixGhost(); 
    }
    
    pass DrawlastGhost < string Script = "Draw=Buffer;";> { 
        AlphaBlendEnable = false;
        AlphaTestEnable = false;
        VertexShader = compile vs_2_0 VS_passDraw();
        PixelShader  = compile ps_2_0 PS_BufCopy(GhostView); 
    }
    
}
