//光筋表現
//作成：ビームマンP
//
//ベース：RadialBlur Filter
//ガウスぼかし係数使用
//Furia様
////////////////////////////////////////////////////////////////////////////////////////////////

float3 RayColor <
   string UIName = "RayColor";
   string UIWidget = "Color";
   bool UIVisible =  true;
> = float3(1,1,1);

float Scale <
   string UIName = "Scale";
   string UIWidget = "Slider";
   string UIHelp = "大きさ";
   bool UIVisible =  true;
   float UIMin = 0;
   float UIMax = 1;
> = 0.0;

float Len <
   string UIName = "Len";
   string UIWidget = "Slider";
   string UIHelp = "長さ";
   bool UIVisible =  true;
   float UIMin = 0;
   float UIMax = 1;
> = 0.0;

float Boke <
   string UIName = "Boke";
   string UIWidget = "Slider";
   string UIHelp = "ぼけ";
   bool UIVisible =  true;
   float UIMin = 0;
   float UIMax = 1;
> = 0.0;

//マスク用
shared texture GRay_ObjectMaskRT: OFFSCREENRENDERTARGET <
    string Description = "OffScreen RenderTarget for SunShaft.fx";
    float4 ClearColor = { 1, 1, 1, 1 };
    float ClearDepth = 1.0;
    bool AntiAlias = false;
    string DefaultEffect = 
        "self = hide;"
        "*=BlackObject.fxsub;";
>;

sampler MaskView = sampler_state {
    texture = <GRay_ObjectMaskRT>;
    Filter = NONE;
    AddressU  = CLAMP;
    AddressV = CLAMP;
};


// ぼかし処理の重み係数：
//    ガウス関数 exp( -x^2/(2*d^2) ) を d=5, x=0〜7 について計算したのち、
//    (WT_7 + WT_6 + … + WT_1 + WT_0 + WT_1 + … + WT_7) が 1 になるように正規化したもの
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

float4 MaterialDiffuse  : DIFFUSE  < string Object = "Geometry"; >;      
float3   LightAmbient      : AMBIENT   < string Object = "Light"; >;   

float4x4 WorldMatrix : World;
float4x4 mVP : ViewProjection;
static float3 Offset = WorldMatrix._41_42_43;

//ぼかし強度
static float BlurPower = 5.0;

// スクリーンサイズ
float2 ViewportSize : VIEWPORTPIXELSIZE;
static float2 SampStep = (float2(2,2)/ViewportSize);

// レンダリングターゲットのクリア値
float4 ClearColor = {1,1,1,1};
float ClearDepth  = 1.0;

//ブラー保存用レンダ―ターゲット１
texture2D BlurMap1 : RENDERCOLORTARGET <
    float2 ViewPortRatio = {1.0,1.0};
    int MipLevels = 1;
    string Format = "A8R8G8B8" ;
>;

sampler2D B1Samp = sampler_state {
    texture = <BlurMap1>;
    MinFilter = POINT;
    MagFilter = POINT;
    MipFilter = NONE;
    AddressU  = CLAMP;
    AddressV = CLAMP;
};
//２
texture2D BlurMap2 : RENDERCOLORTARGET <
    float2 ViewPortRatio = {1.0,1.0};
    int MipLevels = 1;
    string Format = "A8R8G8B8" ;
>;

sampler2D B2Samp = sampler_state {
    texture = <BlurMap2>;
    MinFilter = POINT;
    MagFilter = POINT;
    MipFilter = NONE;
    AddressU  = CLAMP;
    AddressV = CLAMP;
};
texture2D DepthBuffer : RENDERDEPTHSTENCILTARGET <
    float2 ViewPortRatio = {1.0,1.0};
    string Format = "D24S8";
>;
 
struct VS_OUTPUT {
    float4 Pos	: POSITION;
    float2 Tex	: TEXCOORD0;
    float2 Center	: TEXCOORD1;
    float Alpha : TEXCOORD2;
};
float3 LightDirection    : DIRECTION < string Object = "Light"; >;

VS_OUTPUT VS_BufferRender( float4 Pos : POSITION, float4 Tex : TEXCOORD0 ){
    VS_OUTPUT Out;
    
    Out.Pos = Pos - float4(0.0001f,-0.0001f,0.0f,0.0f);
    Out.Tex = Tex;
    float4 target = mul(float4(normalize(Offset)*1000,1),mVP);
	Out.Center = 0.5f * (target.xy / target.w) + 0.5f;
	Out.Center.y = 1.0f-Out.Center.y;
	Out.Alpha = target.w;
    return Out;
}


float4  PS_RadialBlur(float2 Tex: TEXCOORD0 ,float2 Center: TEXCOORD1,float Alpha: TEXCOORD2) : COLOR0
{
	float4 Color;
	Color = tex2D( B2Samp, Tex);
	Tex.y *= ViewportSize.y/ViewportSize.x;
	Tex.y += 0.125;
	Color *= (1-(pow(length(Tex - Center)*((1-Scale)*25.0),1)-1))*Scale;
	Color = saturate(Color);
	Color.rgb *= RayColor;
	if(Alpha < 0)
		Color = 0;
	return Color;
}
//繰り返し用ブラー
float4  PS_Blur(float2 Tex: TEXCOORD0 ,float2 Center: TEXCOORD1,uniform sampler2D Samp,uniform bool Cpy) : COLOR0
{
	float4 Color;
	if(!Cpy)
	{
		//ブラーの中心位置 ← 現在のテクセル位置
		float2 dir = Center - Tex;
		dir *= 0.5+Len*2.0;
		//距離を計算する
		float len = length( dir );
		
		//方向ベクトルの正規化し、１テクセル分の長さとなる方向ベクトルを計算する
		dir = normalize( dir );
		dir *= SampStep;
		float2 BackDir = dir*0.5;
		
		//距離を積算することにより、爆発の中心位置に近いほどブラーの影響が小さくなるようにする
		dir *= BlurPower * len;
		//反対方向は常に1
		
		if(len < 0){
			Color = tex2D( Samp, Tex);
		}else{
			Color  = WT_0 *   tex2D( Samp, Tex );
			Color += WT_1 * ( tex2D( Samp, Tex+dir  ) + tex2D( Samp, Tex-BackDir  ) );
			Color += WT_2 * ( tex2D( Samp, Tex+dir*2) + tex2D( Samp, Tex-BackDir*2) );
			Color += WT_3 * ( tex2D( Samp, Tex+dir*3) + tex2D( Samp, Tex-BackDir*3) );
			Color += WT_4 * ( tex2D( Samp, Tex+dir*4) + tex2D( Samp, Tex-BackDir*4) );
			Color += WT_5 * ( tex2D( Samp, Tex+dir*5) + tex2D( Samp, Tex-BackDir*5) );
			Color += WT_6 * ( tex2D( Samp, Tex+dir*6) + tex2D( Samp, Tex-BackDir*6) );
			Color += WT_7 * ( tex2D( Samp, Tex+dir*7) + tex2D( Samp, Tex-BackDir*7) );
		}
	}else{
		Color = tex2D( Samp, Tex);
	}
	
	return Color;
}

//ガウス処理
static float2 ViewportOffset = (float2(0.5,0.5)/ViewportSize);
static float2 SampStep_G = (float2(Boke*5,Boke*5)/ViewportSize);

texture2D GauseWork : RENDERCOLORTARGET <
    float2 ViewPortRatio = {1.0,1.0};
    int MipLevels = 1;
    string Format = "A8R8G8B8" ;
>;
sampler2D LightSamp = sampler_state {
    texture = <GauseWork>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = NONE;
    AddressU  = CLAMP;
    AddressV = CLAMP;
};

////////////////////////////////////////////////////////////////////////////////////////////////
// X方向ぼかし

struct VS_OUTPUT_G {
    float4 Pos			: POSITION;
	float2 Tex			: TEXCOORD0;
};

VS_OUTPUT_G VS_passX( float4 Pos : POSITION, float4 Tex : TEXCOORD0 ) {
    VS_OUTPUT_G Out = (VS_OUTPUT_G)0; 
    
    Out.Pos = Pos;
    Out.Tex = Tex + float2(0, ViewportOffset.y);
    
    return Out;
}

float4 PS_passX( float2 Tex: TEXCOORD0 ) : COLOR {   
    float4 Color;
	
	Color  = WT_0 *   tex2D( B2Samp, Tex );
	Color += WT_1 * ( tex2D( B2Samp, Tex+float2(SampStep_G.x  ,0) ) + tex2D( B2Samp, Tex-float2(SampStep_G.x  ,0) ) );
	Color += WT_2 * ( tex2D( B2Samp, Tex+float2(SampStep_G.x*2,0) ) + tex2D( B2Samp, Tex-float2(SampStep_G.x*2,0) ) );
	Color += WT_3 * ( tex2D( B2Samp, Tex+float2(SampStep_G.x*3,0) ) + tex2D( B2Samp, Tex-float2(SampStep_G.x*3,0) ) );
	Color += WT_4 * ( tex2D( B2Samp, Tex+float2(SampStep_G.x*4,0) ) + tex2D( B2Samp, Tex-float2(SampStep_G.x*4,0) ) );
	Color += WT_5 * ( tex2D( B2Samp, Tex+float2(SampStep_G.x*5,0) ) + tex2D( B2Samp, Tex-float2(SampStep_G.x*5,0) ) );
	Color += WT_6 * ( tex2D( B2Samp, Tex+float2(SampStep_G.x*6,0) ) + tex2D( B2Samp, Tex-float2(SampStep_G.x*6,0) ) );
	Color += WT_7 * ( tex2D( B2Samp, Tex+float2(SampStep_G.x*7,0) ) + tex2D( B2Samp, Tex-float2(SampStep_G.x*7,0) ) );
	
    return Color;
}

////////////////////////////////////////////////////////////////////////////////////////////////
// Y方向ぼかし

VS_OUTPUT_G VS_passY( float4 Pos : POSITION, float4 Tex : TEXCOORD0 ){
    VS_OUTPUT_G Out = (VS_OUTPUT_G)0; 
    
    Out.Pos = Pos;
    Out.Tex = Tex + float2(ViewportOffset.x, 0);
    
    return Out;
}

float4 PS_passY(float2 Tex: TEXCOORD0) : COLOR
{   
    float4 Color;
	
	Color  = WT_0 *   tex2D( LightSamp, Tex );
	Color += WT_1 * ( tex2D( LightSamp, Tex+float2(0,SampStep_G.y  ) ) + tex2D( LightSamp, Tex-float2(0,SampStep_G.y  ) ) );
	Color += WT_2 * ( tex2D( LightSamp, Tex+float2(0,SampStep_G.y*2) ) + tex2D( LightSamp, Tex-float2(0,SampStep_G.y*2) ) );
	Color += WT_3 * ( tex2D( LightSamp, Tex+float2(0,SampStep_G.y*3) ) + tex2D( LightSamp, Tex-float2(0,SampStep_G.y*3) ) );
	Color += WT_4 * ( tex2D( LightSamp, Tex+float2(0,SampStep_G.y*4) ) + tex2D( LightSamp, Tex-float2(0,SampStep_G.y*4) ) );
	Color += WT_5 * ( tex2D( LightSamp, Tex+float2(0,SampStep_G.y*5) ) + tex2D( LightSamp, Tex-float2(0,SampStep_G.y*5) ) );
	Color += WT_6 * ( tex2D( LightSamp, Tex+float2(0,SampStep_G.y*6) ) + tex2D( LightSamp, Tex-float2(0,SampStep_G.y*6) ) );
	Color += WT_7 * ( tex2D( LightSamp, Tex+float2(0,SampStep_G.y*7) ) + tex2D( LightSamp, Tex-float2(0,SampStep_G.y*7) ) );
	
    return Color;
}

int loop = 3;

technique PostEffect <
    string Script = 
		"RenderColorTarget0=;"
		"RenderDepthStencilTarget=;"
			"ScriptExternal=Color;"

		"RenderDepthStencilTarget=DepthBuffer;"			
		"RenderColorTarget0=BlurMap1;"
			"Clear=Color;"
			"Clear=Depth;"
			"Pass=Cpy;"
					
		"RenderColorTarget0=BlurMap2;"
			"Clear=Color;"
			"Clear=Depth;"
			"Pass=Blur2;"
		"LoopByCount=loop;"
		
		"RenderColorTarget0=BlurMap1;"
			"Clear=Color;"
			"Clear=Depth;"
			"Pass=Blur1;"
			
		"RenderColorTarget0=BlurMap2;"
			"Clear=Color;"
			"Clear=Depth;"
			"Pass=Blur2;"			
		"LoopEnd=;"
		
		//ガウス処理
		"RenderColorTarget0=GauseWork;"
			"Clear=Color;"
			"Clear=Depth;"
			"Pass=Gause_X;"
			
		"RenderColorTarget0=BlurMap2;"
			"Clear=Color;"
			"Clear=Depth;"
			"Pass=Gause_Y;"	
		
		"RenderColorTarget0=;"
			"RenderDepthStencilTarget=;"
			"Pass=DrawRadialBlur;"

    ;
> {
    pass DrawRadialBlur < string Script= "Draw=Buffer;"; > {
        SRCBLEND = ONE;
        DESTBLEND = ONE;
        VertexShader = compile vs_2_0 VS_BufferRender();
        PixelShader  = compile ps_2_0 PS_RadialBlur();
    }
    pass Cpy < string Script= "Draw=Buffer;"; > {
        AlphaBlendEnable = FALSE;
        VertexShader = compile vs_2_0 VS_BufferRender();
        PixelShader  = compile ps_2_0 PS_Blur(MaskView,true);
    }
    pass Blur1 < string Script= "Draw=Buffer;"; > {
        AlphaBlendEnable = FALSE;
        VertexShader = compile vs_2_0 VS_BufferRender();
        PixelShader  = compile ps_2_0 PS_Blur(B2Samp,false);
    }
    pass Blur2 < string Script= "Draw=Buffer;"; > {
        AlphaBlendEnable = FALSE;
        VertexShader = compile vs_2_0 VS_BufferRender();
        PixelShader  = compile ps_2_0 PS_Blur(B1Samp,false);
    }
    pass Gause_X < string Script= "Draw=Buffer;"; > {
        AlphaBlendEnable = FALSE;
        VertexShader = compile vs_2_0 VS_passX();
        PixelShader  = compile ps_2_0 PS_passX();
    }
    pass Gause_Y < string Script= "Draw=Buffer;"; > {
        AlphaBlendEnable = FALSE;
        VertexShader = compile vs_2_0 VS_passY();
        PixelShader  = compile ps_2_0 PS_passY();
    }
}