////////////////////////////////////////////////////////////////////////////////////////////////
// ���[�U�[�p�����[�^

// �ڂ����͈� (�T���v�����O���͌Œ�̂��߁A�傫����������ƎȂ��o�܂�) 
float Extent_S
<
   string UIName = "Extent_S";
   string UIWidget = "Slider";
   bool UIVisible =  true;
   float UIMin = 0.00;
   float UIMax = 0.01;
> = float( 0.00066 ); // �ɂ���

float Extent_G
<
   string UIName = "Extent_G";
   string UIWidget = "Slider";
   bool UIVisible =  true;
   float UIMin = 0.00;
   float UIMax = 0.01;
> = float( 0.0008 ); // �K�E�X

//�������x
float Strength_A
<
   string UIName = "Strength_A";
   string UIWidget = "Slider";
   bool UIVisible =  true;
   float UIMin = 0.0;
   float UIMax = 10.0;
> = float( 1.8 );

float Strength_B
<
   string UIName = "Strength_B";
   string UIWidget = "Slider";
   bool UIVisible =  true;
   float UIMin = 0.0;
   float UIMax = 10.0;
> = float( 1.7 );


//�_�Ŏ����A�P�ʁF�t���[���A0�Œ�~
int Interval
<
   string UIName = "Interval";
   string UIWidget = "Numeric";
   bool UIVisible =  true;
   int UIMin = 0;
   int UIMax = 600;
> = int( 0 );

//�ҏW���̓_�ł��t���[�����ɓ���
#define SYNC false


float Angle
<
   string UIName = "Angle";
   string UIWidget = "Slider";
   bool UIVisible =  true;
   float UIMin = 0.0;
   float UIMax = 10.0;
> = float( 1 );

float Aspect
<
   string UIName = "Aspect";
   string UIWidget = "Slider";
   bool UIVisible =  true;
   float UIMin = 0.0;
   float UIMax = 20.0;
> = float( 10 );


///////////////////////////////////////////////////////////////////////////////////////////////
// �����˃I�u�W�F�N�g�`���

texture CL_EmitterRT: OFFSCREENRENDERTARGET <
    string Description = "EmitterDrawRenderTarget for CrossLuminous.fx";
    float2 ViewPortRatio = {1.0,1.0};
    float4 ClearColor = { 0, 0, 0, 1 };
    float ClearDepth = 1.0;
    bool AntiAlias = true;
    string DefaultEffect = 
        "self = hide;"
        "*Luminous.fx = hide;"
        "stage01.x = OL_Selector_ST.fx;"
        "* = OL_BlackMask.fx;" 
    ;
    
>;

sampler EmitterView = sampler_state {
    texture = <CL_EmitterRT>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = NONE;
    AddressU  = CLAMP;
    AddressV = CLAMP;
};

////////////////////////////////////////////////////////////////////////////////////////////////

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

#define PI 3.14159

const float4 Color_Black = {0,0,0,1};
const float4 Color_White = {1,1,1,1};


float Script : STANDARDSGLOBAL <
    string ScriptOutput = "color";
    string ScriptClass = "scene";
    string ScriptOrder = "postprocess";
> = 0.8;


// �}�e���A���F
float4 MaterialDiffuse : DIFFUSE  < string Object = "Geometry"; >;
static float alpha1 = MaterialDiffuse.a;

//�X�P�[��
float scaling0 : CONTROLOBJECT < string name = "(self)"; >;
static float scaling = scaling0 * 0.1;

//����
float ftime : TIME <bool SyncInEditMode = SYNC;>;
static float timerate = Interval ? ((1 + cos(ftime * 2 * PI * 30 / (float)Interval)) * 0.4 + 0.2) : 1.0;

// �X�N���[���T�C�Y
float2 ViewportSize : VIEWPORTPIXELSIZE;

static float2 ViewportOffset = (float2(0.5,0.5)/ViewportSize);
static float2 OnePx = (float2(1,1)/ViewportSize);

static float2 SampStep = (float2(Extent_G,Extent_G)/ViewportSize*ViewportSize.y);
static float2 SampStep2 = (float2(Extent_S,Extent_S)/ViewportSize*ViewportSize.y);


// �����_�����O�^�[�Q�b�g�̃N���A�l
float4 ClearColor = {0,0,0,1};
float4 ClearColorTr = {0,0,0,0};
float ClearDepth  = 1.0;

////////////////////////////////////////////////////////////////////////////////////
// �[�x�o�b�t�@
texture2D DepthBuffer : RENDERDEPTHSTENCILTARGET <
    float2 ViewPortRatio = {1.0,1.0};
    string Format = "D24S8";
>;

///////////////////////////////////////////////////////////////////////////////////////////////

// X�����̂ڂ������ʂ��L�^���邽�߂̃����_�[�^�[�Q�b�g
texture2D ScnMapX : RENDERCOLORTARGET <
    float2 ViewPortRatio = {1,1};
    int MipLevels = 1;
    string Format = "A8R8G8B8" ;
>;
sampler2D ScnSampX = sampler_state {
    texture = <ScnMapX>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = NONE;
    AddressU  = CLAMP;
    AddressV = CLAMP;
};

// X�����̂ڂ������ʂ��L�^���邽�߂̃����_�[�^�[�Q�b�g
texture2D ScnMapY : RENDERCOLORTARGET <
    float2 ViewPortRatio = {1,1};
    int MipLevels = 1;
    string Format = "A8R8G8B8" ;
>;
sampler2D ScnSampY = sampler_state {
    texture = <ScnMapY>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = NONE;
    AddressU  = CLAMP;
    AddressV = CLAMP;
};


////////////////////////////////////////////////////////////////////////////////////////////////
// ���Ƃѕ\���֐�
float4 OverExposure(float4 color){
    float4 newcolor = color;
    
    //����F��1�𒴂���ƁA���̐F�ɂ��ӂ��
    newcolor.gb += saturate(color.r - 1);
    newcolor.rb += saturate(color.g - 1);
    newcolor.rg += saturate(color.b - 1);
    
    return saturate(newcolor);
}


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

//��]���ď㔼���ɕ`��
VS_OUTPUT VS_passRotDraw( float4 Pos : POSITION, float4 Tex : TEXCOORD0 ) {
    VS_OUTPUT Out = (VS_OUTPUT)0; 
    
    float ang = Angle;
    
    float3x3 zrot = {
        {cos(ang), -sin(ang), 0},
        {sin(ang), cos(ang),  0},
        {0,          0,           1},
    }; // 2������]�s��
    
    Out.Pos = Pos;
    
    Out.Pos.xy = mul(Pos.xy, zrot);
    Out.Pos.xy *= 0.65;
    
    Out.Pos.y /= 2;
    Out.Pos.y -= 0.5;
    
    Out.Tex = Tex + float2(ViewportOffset.x, ViewportOffset.y);
    
    return Out;
}

//90�x������]���ĉ������ɕ`��
VS_OUTPUT VS_passRotDraw2( float4 Pos : POSITION, float4 Tex : TEXCOORD0 ) {
    VS_OUTPUT Out = (VS_OUTPUT)0; 
    
    float ang = Angle + (PI / 2);
    
    float3x3 zrot = {
        {cos(ang), -sin(ang), 0},
        {sin(ang), cos(ang),  0},
        {0,        0,         1},
    }; // 2������]�s��
    
    Out.Pos = Pos;
    
    Out.Pos.xy = mul(Pos.xy, zrot);
    Out.Pos.xy *= 0.65;
    
    Out.Pos.y /= 2;
    Out.Pos.y += 0.5;
    
    Out.Tex = Tex + float2(ViewportOffset.x, ViewportOffset.y);
    
    return Out;
}

//��]��߂�
VS_OUTPUT VS_passReRotDraw( float4 Pos : POSITION, float4 Tex : TEXCOORD0 ) {
    VS_OUTPUT Out = (VS_OUTPUT)0; 
    
    float ang = Angle;
    
    float3x3 zrot = {
        {cos(-ang), -sin(-ang), 0},
        {sin(-ang), cos(-ang),  0},
        {0,          0,           1},
    }; // Y����]�s��
    
    Out.Pos = Pos;
    
    Out.Pos.y += 0.5;
    Out.Pos.y *= 2;
    Out.Pos.xy /= 0.65;
    Out.Pos.xy = mul(Out.Pos.xy, zrot);
    
    Out.Tex = Tex + float2(ViewportOffset.x, ViewportOffset.y);
    
    //Out.Tex.xy /= 0.7;
    //Out.Tex.xy = mul(Pos.xy, zrot);
    
    return Out;
}

//��]��߂�
VS_OUTPUT VS_passReRotDraw2( float4 Pos : POSITION, float4 Tex : TEXCOORD0 ) {
    VS_OUTPUT Out = (VS_OUTPUT)0; 
    
    float ang = Angle + (PI / 2);
    
    float3x3 zrot = {
        {cos(-ang), -sin(-ang), 0},
        {sin(-ang), cos(-ang),  0},
        {0,          0,           1},
    }; // Y����]�s��
    
    Out.Pos = Pos;
    
    Out.Pos.y -= 0.5;
    Out.Pos.y *= 2;
    Out.Pos.xy /= 0.65;
    Out.Pos.xy = mul(Out.Pos.xy, zrot);
    
    Out.Tex = Tex + float2(ViewportOffset.x, ViewportOffset.y);
    
    //Out.Tex.xy /= 0.7;
    //Out.Tex.xy = mul(Pos.xy, zrot);
    
    return Out;
}

////////////////////////////////////////////////////////////////////////////////////////////////
// �t�@�[�X�g�p�X

float4 PS_first( float2 Tex: TEXCOORD0 ) : COLOR {
    float4 Color;
    
    //�I�t�X�N���[���^�[�Q�b�g���ǂݍ��݁A�y���ڂ���
    Color = tex2D( EmitterView, Tex ) * 2;
    Color += tex2D( EmitterView, Tex + float2(0, OnePx.y) );
    Color += tex2D( EmitterView, Tex + float2(0, -OnePx.y) );
    Color += tex2D( EmitterView, Tex + float2(OnePx.x, 0) );
    Color += tex2D( EmitterView, Tex + float2(OnePx.x, OnePx.y) );
    Color += tex2D( EmitterView, Tex + float2(OnePx.x, -OnePx.y) );
    Color += tex2D( EmitterView, Tex + float2(-OnePx.x, 0) );
    Color += tex2D( EmitterView, Tex + float2(-OnePx.x, OnePx.y) );
    Color += tex2D( EmitterView, Tex + float2(-OnePx.x, -OnePx.y) );
    
    Color /= 10;
    
    return Color;
}

////////////////////////////////////////////////////////////////////////////////////////////////
// X�����ɂ���

float4 PS_passSX( float2 Tex: TEXCOORD0 , uniform float aspect) : COLOR {   
    float4 Color;
    float step = SampStep2.x * scaling * timerate * aspect;
    
    Color = tex2D( ScnSampY, Tex );
    
    Color = max(Color, (7.0/8.0) * tex2D( ScnSampY, Tex+float2(step     ,0)));
    Color = max(Color, (6.0/8.0) * tex2D( ScnSampY, Tex+float2(step * 2 ,0)));
    Color = max(Color, (5.0/8.0) * tex2D( ScnSampY, Tex+float2(step * 3 ,0)));
    Color = max(Color, (4.0/8.0) * tex2D( ScnSampY, Tex+float2(step * 4 ,0)));
    Color = max(Color, (3.0/8.0) * tex2D( ScnSampY, Tex+float2(step * 5 ,0)));
    Color = max(Color, (2.0/8.0) * tex2D( ScnSampY, Tex+float2(step * 6 ,0)));
    Color = max(Color, (1.0/8.0) * tex2D( ScnSampY, Tex+float2(step * 7 ,0)));
    
    Color = max(Color, (7.0/8.0) * tex2D( ScnSampY, Tex-float2(step     ,0)));
    Color = max(Color, (6.0/8.0) * tex2D( ScnSampY, Tex-float2(step * 2 ,0)));
    Color = max(Color, (5.0/8.0) * tex2D( ScnSampY, Tex-float2(step * 3 ,0)));
    Color = max(Color, (4.0/8.0) * tex2D( ScnSampY, Tex-float2(step * 4 ,0)));
    Color = max(Color, (3.0/8.0) * tex2D( ScnSampY, Tex-float2(step * 5 ,0)));
    Color = max(Color, (2.0/8.0) * tex2D( ScnSampY, Tex-float2(step * 6 ,0)));
    Color = max(Color, (1.0/8.0) * tex2D( ScnSampY, Tex-float2(step * 7 ,0)));
    
    return Color;
}

////////////////////////////////////////////////////////////////////////////////////////////////
// Y�����ɂ���

float4 PS_passSY(float2 Tex: TEXCOORD0 , uniform float aspect) : COLOR
{   
    float4 Color;
    float step = SampStep2.y * scaling * timerate * aspect;
    
    Color = tex2D( ScnSampX, Tex );
    
    Color = max(Color, (7.0/8.0) * tex2D( ScnSampX, Tex+float2(0, step    )));
    Color = max(Color, (6.0/8.0) * tex2D( ScnSampX, Tex+float2(0, step * 2)));
    Color = max(Color, (5.0/8.0) * tex2D( ScnSampX, Tex+float2(0, step * 3)));
    Color = max(Color, (4.0/8.0) * tex2D( ScnSampX, Tex+float2(0, step * 4)));
    Color = max(Color, (3.0/8.0) * tex2D( ScnSampX, Tex+float2(0, step * 5)));
    Color = max(Color, (2.0/8.0) * tex2D( ScnSampX, Tex+float2(0, step * 6)));
    Color = max(Color, (1.0/8.0) * tex2D( ScnSampX, Tex+float2(0, step * 7)));
    
    Color = max(Color, (7.0/8.0) * tex2D( ScnSampX, Tex-float2(0, step    )));
    Color = max(Color, (6.0/8.0) * tex2D( ScnSampX, Tex-float2(0, step * 2)));
    Color = max(Color, (5.0/8.0) * tex2D( ScnSampX, Tex-float2(0, step * 3)));
    Color = max(Color, (4.0/8.0) * tex2D( ScnSampX, Tex-float2(0, step * 4)));
    Color = max(Color, (3.0/8.0) * tex2D( ScnSampX, Tex-float2(0, step * 5)));
    Color = max(Color, (2.0/8.0) * tex2D( ScnSampX, Tex-float2(0, step * 6)));
    Color = max(Color, (1.0/8.0) * tex2D( ScnSampX, Tex-float2(0, step * 7)));
    
    return Color;
}

////////////////////////////////////////////////////////////////////////////////////////////////
// X�����ڂ���

float4 PS_passX( float2 Tex: TEXCOORD0 , uniform float aspect) : COLOR {   
    float4 Color;
    float step = SampStep.x * scaling * timerate * aspect;
    
    Color  = WT_0 *   tex2D( ScnSampY, Tex );
    Color.rgb *= Strength_A;
    Color = OverExposure(Color);
    
    Color += WT_1 * ( tex2D( ScnSampY, Tex+float2(step    ,0) ) + tex2D( ScnSampY, Tex-float2(step    ,0) ) );
    Color += WT_2 * ( tex2D( ScnSampY, Tex+float2(step * 2,0) ) + tex2D( ScnSampY, Tex-float2(step * 2,0) ) );
    Color += WT_3 * ( tex2D( ScnSampY, Tex+float2(step * 3,0) ) + tex2D( ScnSampY, Tex-float2(step * 3,0) ) );
    Color += WT_4 * ( tex2D( ScnSampY, Tex+float2(step * 4,0) ) + tex2D( ScnSampY, Tex-float2(step * 4,0) ) );
    Color += WT_5 * ( tex2D( ScnSampY, Tex+float2(step * 5,0) ) + tex2D( ScnSampY, Tex-float2(step * 5,0) ) );
    Color += WT_6 * ( tex2D( ScnSampY, Tex+float2(step * 6,0) ) + tex2D( ScnSampY, Tex-float2(step * 6,0) ) );
    Color += WT_7 * ( tex2D( ScnSampY, Tex+float2(step * 7,0) ) + tex2D( ScnSampY, Tex-float2(step * 7,0) ) );
    
    return Color;
}


////////////////////////////////////////////////////////////////////////////////////////////////
// Y�����ڂ���

float4 PS_passY(float2 Tex: TEXCOORD0, uniform float aspect) : COLOR
{   
    float4 Color;
    float step = SampStep.y * scaling * timerate * aspect;
    
    
    Color  = WT_0 *   tex2D( ScnSampX, Tex );
    Color += WT_1 * ( tex2D( ScnSampX, Tex+float2(0,step    ) ) + tex2D( ScnSampX, Tex-float2(0,step    ) ) );
    Color += WT_2 * ( tex2D( ScnSampX, Tex+float2(0,step * 2) ) + tex2D( ScnSampX, Tex-float2(0,step * 2) ) );
    Color += WT_3 * ( tex2D( ScnSampX, Tex+float2(0,step * 3) ) + tex2D( ScnSampX, Tex-float2(0,step * 3) ) );
    Color += WT_4 * ( tex2D( ScnSampX, Tex+float2(0,step * 4) ) + tex2D( ScnSampX, Tex-float2(0,step * 4) ) );
    Color += WT_5 * ( tex2D( ScnSampX, Tex+float2(0,step * 5) ) + tex2D( ScnSampX, Tex-float2(0,step * 5) ) );
    Color += WT_6 * ( tex2D( ScnSampX, Tex+float2(0,step * 6) ) + tex2D( ScnSampX, Tex-float2(0,step * 6) ) );
    Color += WT_7 * ( tex2D( ScnSampX, Tex+float2(0,step * 7) ) + tex2D( ScnSampX, Tex-float2(0,step * 7) ) );
    
    return Color;
}

////////////////////////////////////////////////////////////////////////////////////////////////
// ����

float4 PS_passRotMix(float2 Tex: TEXCOORD0) : COLOR
{
    float4 Color = tex2D( ScnSampY, Tex );
    Color.rgb *= 0.5;
    return Color;
}

float4 PS_passMix(float2 Tex: TEXCOORD0) : COLOR
{   
    float4 Color;
    float4 MaskColor;
    float step = SampStep.y * scaling * timerate;
    
    Color  = tex2D( ScnSampX, Tex );
    
    Color.rgb *= (Strength_B * alpha1 * timerate * 1.8);
    Color = OverExposure(Color);
    
    //�u���b�N�̈�̓K�p
    MaskColor = tex2D( EmitterView, Tex );
    Color.rgb *= MaskColor.a;
    Color.a = 1;//MaskColor.a;
    
    return Color;
}

////////////////////////////////////////////////////////////////////////////////////////////////
//�e�N�j�b�N�E12�p�X���K�v�E�E�E

technique CrossLuminous <
    string Script = 
        "RenderColorTarget0=;"
        "RenderDepthStencilTarget=;"
        "ClearSetColor=ClearColor; ClearSetDepth=ClearDepth;"
        "Clear=Color; Clear=Depth;"
        "ScriptExternal=Color;"
        
        "RenderColorTarget0=ScnMapY;"
        "RenderDepthStencilTarget=DepthBuffer;"
        "ClearSetColor=ClearColor; ClearSetDepth=ClearDepth;"
        "Clear=Color; Clear=Depth;"
        "Pass=FirstPass;"
        
        "Pass=FirstPass2;"
        
        "RenderColorTarget0=ScnMapX;"
        "RenderDepthStencilTarget=DepthBuffer;"
        "ClearSetColor=ClearColor; ClearSetDepth=ClearDepth;"
        "Clear=Color; Clear=Depth;"
        "Pass=Spread_X;"
        
        "RenderColorTarget0=ScnMapY;"
        "RenderDepthStencilTarget=DepthBuffer;"
        "ClearSetColor=ClearColor; ClearSetDepth=ClearDepth;"
        "Clear=Color; Clear=Depth;"
        "Pass=Spread_Y;"
        
        
        "RenderColorTarget0=ScnMapX;"
        "RenderDepthStencilTarget=DepthBuffer;"
        "ClearSetColor=ClearColor; ClearSetDepth=ClearDepth;"
        "Clear=Color; Clear=Depth;"
        "Pass=Gaussian_X;"
        
        "RenderColorTarget0=ScnMapY;"
        "RenderDepthStencilTarget=DepthBuffer;"
        "ClearSetColor=ClearColor; ClearSetDepth=ClearDepth;"
        "Clear=Color; Clear=Depth;"
        "Pass=Gaussian_Y;"
        
        
        "RenderColorTarget0=ScnMapX;"
        "RenderDepthStencilTarget=DepthBuffer;"
        "ClearSetColor=ClearColor; ClearSetDepth=ClearDepth;"
        "Clear=Color; Clear=Depth;"
        "Pass=RotMix;"
        
        "Pass=RotMix2;"
        
        
        
        "RenderColorTarget0=ScnMapY;"
        "RenderDepthStencilTarget=DepthBuffer;"
        "ClearSetColor=ClearColor; ClearSetDepth=ClearDepth;"
        "Clear=Color; Clear=Depth;"
        "Pass=Gaussian_Y2;"
        
        "RenderColorTarget0=ScnMapX;"
        "RenderDepthStencilTarget=DepthBuffer;"
        "ClearSetColor=ClearColor; ClearSetDepth=ClearDepth;"
        "Clear=Color; Clear=Depth;"
        "Pass=Gaussian_X2;"
        
        "RenderColorTarget0=;"
        "RenderDepthStencilTarget=;"
        "Pass=Mix;"
        
    ;
    
> {
    
    pass FirstPass < string Script= "Draw=Buffer;"; > {
        AlphaBlendEnable = FALSE;
        VertexShader = compile vs_2_0 VS_passRotDraw();
        PixelShader  = compile ps_2_0 PS_first();
    }
    pass FirstPass2 < string Script= "Draw=Buffer;"; > {
        AlphaBlendEnable = FALSE;
        VertexShader = compile vs_2_0 VS_passRotDraw2();
        PixelShader  = compile ps_2_0 PS_first();
    }
    pass Spread_X < string Script= "Draw=Buffer;"; > {
        AlphaBlendEnable = FALSE;
        VertexShader = compile vs_2_0 VS_passDraw();
        PixelShader  = compile ps_2_0 PS_passSX(Aspect);
    }
    pass Spread_Y < string Script= "Draw=Buffer;"; > {
        AlphaBlendEnable = FALSE;
        VertexShader = compile vs_2_0 VS_passDraw();
        PixelShader  = compile ps_2_0 PS_passSY(0.5);
    }
    pass Gaussian_X < string Script= "Draw=Buffer;"; > {
        AlphaBlendEnable = FALSE;
        VertexShader = compile vs_2_0 VS_passDraw();
        PixelShader  = compile ps_2_0 PS_passX(Aspect);
    }
    pass Gaussian_Y < string Script= "Draw=Buffer;"; > {
        AlphaBlendEnable = FALSE;
        VertexShader = compile vs_2_0 VS_passDraw();
        PixelShader  = compile ps_2_0 PS_passY(0.5);
    }
    pass RotMix < string Script= "Draw=Buffer;"; > {
        SRCBLEND = ONE;
        DESTBLEND = ONE;
        VertexShader = compile vs_2_0 VS_passReRotDraw();
        //VertexShader = compile vs_2_0 VS_passDraw();
        PixelShader  = compile ps_2_0 PS_passRotMix();
    }
    pass RotMix2 < string Script= "Draw=Buffer;"; > {
        SRCBLEND = ONE;
        DESTBLEND = ONE;
        VertexShader = compile vs_2_0 VS_passReRotDraw2();
        PixelShader  = compile ps_2_0 PS_passRotMix();
    }
    pass Gaussian_X2 < string Script= "Draw=Buffer;"; > {
        AlphaBlendEnable = FALSE;
        VertexShader = compile vs_2_0 VS_passDraw();
        PixelShader  = compile ps_2_0 PS_passX(0.4);
    }
    pass Gaussian_Y2 < string Script= "Draw=Buffer;"; > {
        AlphaBlendEnable = FALSE;
        VertexShader = compile vs_2_0 VS_passDraw();
        PixelShader  = compile ps_2_0 PS_passY(0.4);
    }
    pass Mix < string Script= "Draw=Buffer;"; > {
        SRCBLEND = ONE;
        DESTBLEND = ONE;
        VertexShader = compile vs_2_0 VS_passDraw();
        PixelShader  = compile ps_2_0 PS_passMix();
    }
}
////////////////////////////////////////////////////////////////////////////////////////////////



