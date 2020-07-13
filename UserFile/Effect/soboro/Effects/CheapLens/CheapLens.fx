// �ڂ����͈�(�傫����������ƎȂ��o�܂�)
float Extent
<
   string UIName = "Extent";
   string UIWidget = "Slider";
   bool UIVisible =  true;
   float UIMin = 0.00;
   float UIMax = 0.01;
> = float( 0.003 );

// �t�B���^���x
float Strength
<
   string UIName = "Strength";
   string UIWidget = "Slider";
   bool UIVisible =  true;
   float UIMin = 0.0;
   float UIMax = 1.0;
> = float( 1.0 );

// �F�����
float ColorShift
<
   string UIName = "ColorShift";
   string UIWidget = "Slider";
   bool UIVisible =  true;
   float UIMin = 0.0;
   float UIMax = 0.2;
> = float( 0.03 );


//�w�i�F
float4 ClearColor
<
   string UIName = "ClearColor";
   string UIWidget = "Color";
   bool UIVisible =  true;
> = float4(0,0,0,0);

//�ڂ����̃T���v�����O��
#define SAMP_NUM  7


///////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////
//����ȍ~�̓G�t�F�N�g�̒m���̂���l�ȊO�͐G��Ȃ�����


float Script : STANDARDSGLOBAL <
    string ScriptOutput = "color";
    string ScriptClass = "scene";
    string ScriptOrder = "postprocess";
> = 0.8;


float alpha1 : CONTROLOBJECT < string name = "(self)"; string item = "Tr"; >;

float scaling0 : CONTROLOBJECT < string name = "(self)"; >;
static float scaling = scaling0 * 0.1;

float4x4 matWorld : CONTROLOBJECT < string name = "(self)"; >; 
static float valx = (matWorld._41 + 100) / 100;
static float valy = (matWorld._42 + 100) / 100;
static float valz = (matWorld._43 + 100) / 100;

// �X�N���[���T�C�Y
float2 ViewportSize : VIEWPORTPIXELSIZE;

static const float2 ViewportOffset = (float2(0.5,0.5)/ViewportSize);
static float ViewportAspect = ViewportSize.x / ViewportSize.y;

static const float2 SampStep = (float2(Extent,Extent)/ViewportSize*ViewportSize.y) * scaling;

// �����_�����O�^�[�Q�b�g�̃N���A�l
float ClearDepth  = 1.0;

// �[�x�o�b�t�@
texture2D DepthBuffer : RENDERDEPTHSTENCILTARGET <
    float2 ViewPortRatio = {1.0,1.0};
    string Format = "D24S8";
>;

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

static float distMax = 0.6;
static float distMin = min(distMax * 0.99, 0.3 / scaling);

float PosToRate(float2 Tex){
    
    Tex -= 0.5;
    Tex.y /= ViewportAspect;
    
    float r = length(Tex);
    
    float ret = max(0, (r - distMin) / (distMax - distMin));
    
    ret = ret * ret;
    
    return ret * alpha1;
}

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

float4 PS_passDraw1( float2 Tex: TEXCOORD0 ) : COLOR {   
    
    float4 Color;
    float rate = PosToRate(Tex);
    
    float2 vec_g = Tex - 0.5;
    vec_g.y /= ViewportAspect;
    
    float2 vec_r = vec_g * (1.0 - ColorShift * rate * valy);
    float2 vec_b = vec_g * (1.0 + ColorShift * rate * valy);
    
    vec_r.y *= ViewportAspect;
    vec_b.y *= ViewportAspect;
    
    vec_r += 0.5;
    vec_b += 0.5;
    
    Color = tex2D( ScnSamp, Tex );
    Color.r = tex2D( ScnSamp, vec_r ).r;
    Color.b = tex2D( ScnSamp, vec_b ).b;
    
    Color.rgb = lerp(Color.rgb, float3(0,0,0), rate * 0.8 * valx);
    
    return Color;
}

////////////////////////////////////////////////////////////////////////////////////////////////

float4 PS_Gaussian( VS_OUTPUT IN , uniform bool Horizontal, uniform sampler2D Samp ) : COLOR {   
    float e, n = 0;
    float2 stex;
    float4 Color, sum = 0;
    
    float step = (Horizontal ? SampStep.x : SampStep.y) * valz;
    
    step *= PosToRate(IN.Tex);
    
    [unroll] //���[�v�W�J
    for(int i = -SAMP_NUM; i <= SAMP_NUM; i++){
        e = exp(-pow((float)i / (SAMP_NUM / 2.0), 2) / 2); //���K���z
        stex = IN.Tex + float2(Horizontal, !Horizontal) * (step * (float)i);
        
        sum += tex2D( Samp, stex ) * e;
        n += e;
    }
    
    Color = sum / n;
    
    return Color;
}

////////////////////////////////////////////////////////////////////////////////////////////////


technique CheapLens <
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
        "Pass=Draw1;"
        
        "RenderColorTarget0=ScnMap;"
        "RenderDepthStencilTarget=DepthBuffer;"
        "ClearSetColor=ClearColor;"
        "ClearSetDepth=ClearDepth;"
        "Clear=Color;"
        "Clear=Depth;"
        "Pass=Gaussian_X;"
        
        "RenderColorTarget0=;"
        "RenderDepthStencilTarget=;"
        "ClearSetColor=ClearColor;"
        "ClearSetDepth=ClearDepth;"
        "Clear=Color;"
        "Clear=Depth;"
        "Pass=Gaussian_Y;"
    ;
    
> {
    
    pass Draw1 < string Script= "Draw=Buffer;"; > {
        AlphaBlendEnable = FALSE;
        AlphaTestEnable = FALSE;
        VertexShader = compile vs_3_0 VS_passDraw();
        PixelShader  = compile ps_3_0 PS_passDraw1();
    }
    
    pass Gaussian_X < string Script= "Draw=Buffer;"; > {
        AlphaBlendEnable = FALSE;
        AlphaTestEnable = FALSE;
        VertexShader = compile vs_3_0 VS_passDraw();
        PixelShader  = compile ps_3_0 PS_Gaussian(true, ScnSamp2);
    }
    pass Gaussian_Y < string Script= "Draw=Buffer;"; > {
        AlphaBlendEnable = FALSE;
        AlphaTestEnable = FALSE;
        VertexShader = compile vs_3_0 VS_passDraw();
        PixelShader  = compile ps_3_0 PS_Gaussian(false, ScnSamp);
    }
    
}
////////////////////////////////////////////////////////////////////////////////////////////////

