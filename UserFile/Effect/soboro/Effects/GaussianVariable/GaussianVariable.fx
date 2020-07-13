////////////////////////////////////////////////////////////////////////////////////////////////

// �ڂ����͈� (�T���v�����O���͌Œ�̂��߁A�傫����������ƎȂ��o�܂�)
#define EXTENT  0.004


// �ڂ��������̏d�݌W���F
//    �K�E�X�֐� exp( -x^2/(2*d^2) ) �� d=5, x=0�`7 �ɂ��Čv�Z�����̂��A
//    (WT_7 + WT_6 + �c + WT_1 + WT_0 + WT_1 + �c + WT_7) �� 1 �ɂȂ�悤�ɐ��K����������
#define  WT_0  0.0920246
#define  WT_1  0.0902024
#define  WT_2  0.0849494
#define  WT_3  0.0768654
#define  WT_4  0.0668236
#define  WT_5  0.0558158
#define  WT_6  0.0447932
#define  WT_7  0.0345379


float Script : STANDARDSGLOBAL <
    string ScriptOutput = "color";
    string ScriptClass = "scene";
    string ScriptOrder = "postprocess";
> = 0.8;


// �}�e���A���F
float4   MaterialDiffuse   : DIFFUSE  < string Object = "Geometry"; >;


// �X�N���[���T�C�Y
float2 ViewportSize : VIEWPORTPIXELSIZE;

static float2 ViewportOffset = (float2(0.5,0.5)/ViewportSize);

static float2 SampStep = (float2(EXTENT,EXTENT)/ViewportSize*ViewportSize.y);


// �����_�����O�^�[�Q�b�g�̃N���A�l
float4 ClearColor = {1,1,1,1};
float ClearDepth  = 1.0;

// �I���W�i���̕`�挋�ʂ��L�^���邽�߂̃����_�[�^�[�Q�b�g
texture2D ScnMap : RENDERCOLORTARGET <
    float2 ViewPortRatio = {1.0,1.0};
    int MipLevels = 1;
    string Format = "A8R8G8B8" ;
>;
sampler2D ScnSamp = sampler_state {
    texture = <ScnMap>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = NONE;
    AddressU  = CLAMP;
    AddressV = CLAMP;
};

texture2D DepthBuffer : RENDERDEPTHSTENCILTARGET <
    float2 ViewPortRatio = {1.0,1.0};
    string Format = "D24S8";
>;

// X�����̂ڂ������ʂ��L�^���邽�߂̃����_�[�^�[�Q�b�g
texture2D ScnMap2 : RENDERCOLORTARGET <
    float2 ViewPortRatio = {1.0,1.0};
    int MipLevels = 1;
    string Format = "A8R8G8B8" ;
>;
sampler2D ScnSamp2 = sampler_state {
    texture = <ScnMap2>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = NONE;
    AddressU  = CLAMP;
    AddressV = CLAMP;
};


////////////////////////////////////////////////////////////////////////////////////////////////
//���ʒ��_�V�F�[�_
struct VS_OUTPUT {
    float4 Pos            : POSITION;
    float2 Tex            : TEXCOORD0;
};

VS_OUTPUT VS_passDraw( float4 Pos : POSITION, float4 Tex : TEXCOORD0 ) {
    VS_OUTPUT Out = (VS_OUTPUT)0; 
    
    Out.Pos = Pos;
    Out.Tex = Tex + float2(ViewportOffset.x, ViewportOffset.y);
    
    return Out;
}

////////////////////////////////////////////////////////////////////////////////////////////////
// X�����ڂ���

float4 PS_passX( float2 Tex: TEXCOORD0 ) : COLOR {   
    float4 Color;
    float step = SampStep.x * MaterialDiffuse.a;

    Color  = WT_0 *   tex2D( ScnSamp, Tex );
    Color += WT_1 * ( tex2D( ScnSamp, Tex+float2(step  ,0) ) + tex2D( ScnSamp, Tex-float2(step  ,0) ) );
    Color += WT_2 * ( tex2D( ScnSamp, Tex+float2(step*2,0) ) + tex2D( ScnSamp, Tex-float2(step*2,0) ) );
    Color += WT_3 * ( tex2D( ScnSamp, Tex+float2(step*3,0) ) + tex2D( ScnSamp, Tex-float2(step*3,0) ) );
    Color += WT_4 * ( tex2D( ScnSamp, Tex+float2(step*4,0) ) + tex2D( ScnSamp, Tex-float2(step*4,0) ) );
    Color += WT_5 * ( tex2D( ScnSamp, Tex+float2(step*5,0) ) + tex2D( ScnSamp, Tex-float2(step*5,0) ) );
    Color += WT_6 * ( tex2D( ScnSamp, Tex+float2(step*6,0) ) + tex2D( ScnSamp, Tex-float2(step*6,0) ) );
    Color += WT_7 * ( tex2D( ScnSamp, Tex+float2(step*7,0) ) + tex2D( ScnSamp, Tex-float2(step*7,0) ) );
    
    return Color;
}

////////////////////////////////////////////////////////////////////////////////////////////////
// Y�����ڂ���

float4 PS_passY(float2 Tex: TEXCOORD0) : COLOR
{   
    float4 Color;
    float step = SampStep.y * MaterialDiffuse.a;
    
    Color  = WT_0 *   tex2D( ScnSamp2, Tex );
    Color += WT_1 * ( tex2D( ScnSamp2, Tex+float2(0,step  ) ) + tex2D( ScnSamp2, Tex-float2(0,step  ) ) );
    Color += WT_2 * ( tex2D( ScnSamp2, Tex+float2(0,step*2) ) + tex2D( ScnSamp2, Tex-float2(0,step*2) ) );
    Color += WT_3 * ( tex2D( ScnSamp2, Tex+float2(0,step*3) ) + tex2D( ScnSamp2, Tex-float2(0,step*3) ) );
    Color += WT_4 * ( tex2D( ScnSamp2, Tex+float2(0,step*4) ) + tex2D( ScnSamp2, Tex-float2(0,step*4) ) );
    Color += WT_5 * ( tex2D( ScnSamp2, Tex+float2(0,step*5) ) + tex2D( ScnSamp2, Tex-float2(0,step*5) ) );
    Color += WT_6 * ( tex2D( ScnSamp2, Tex+float2(0,step*6) ) + tex2D( ScnSamp2, Tex-float2(0,step*6) ) );
    Color += WT_7 * ( tex2D( ScnSamp2, Tex+float2(0,step*7) ) + tex2D( ScnSamp2, Tex-float2(0,step*7) ) );
    
    return Color;
}

////////////////////////////////////////////////////////////////////////////////////////////////

technique Gaussian <
    string Script = 
        "RenderColorTarget0=ScnMap;"
        "RenderDepthStencilTarget=DepthBuffer;"
        "ClearSetColor=ClearColor;"
        "ClearSetDepth=ClearDepth;"
        "Clear=Color;"
        "Clear=Depth;"
        "ScriptExternal=Color;"
        "RenderColorTarget0=ScnMap2;"
        "RenderDepthStencilTarget=DepthBuffer;"
        "ClearSetColor=ClearColor;"
        "ClearSetDepth=ClearDepth;"
        "Clear=Color;"
        "Clear=Depth;"
        "Pass=Gaussian_X;"
        "RenderColorTarget0=;"
        "RenderDepthStencilTarget=;"
        "Pass=Gaussian_Y;"
    ;
> {
    pass Gaussian_X < string Script= "Draw=Buffer;"; > {
        AlphaBlendEnable = FALSE;
        VertexShader = compile vs_2_0 VS_passDraw();
        PixelShader  = compile ps_2_0 PS_passX();
    }
    pass Gaussian_Y < string Script= "Draw=Buffer;"; > {
        AlphaBlendEnable = FALSE;
        VertexShader = compile vs_2_0 VS_passDraw();
        PixelShader  = compile ps_2_0 PS_passY();
    }
}
////////////////////////////////////////////////////////////////////////////////////////////////
