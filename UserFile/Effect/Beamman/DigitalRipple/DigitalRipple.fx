//フレームテクスチャモード
// //#define USE_FRAME とすると無効
#define USE_FRAME

//フレームテクスチャ倍率
float WireScale = 50.0;

//生成用の波の強さ
float WavePow = 100.0;

//波の減衰力
float DownPow = 0.95;

//波の色
float3 LightColor = {0.25,1,0.75};

//発光強度(AutoLuminous用）
float LightPow = 2;

//波の速度
float WaveSpeed = 0.05;
//波のなめらかさ
float PushGauss = 0.25;

//計算用テクスチャサイズ 数値が大きいほど細かい波を出力する
//0〜
//基本的に128,256,512,1024を推奨 それ以外は非常に不安定な動きになります
//また、変更後は波のパラメータが壊れるので、一度再生ボタンを押すと直ります。
#define TEX_SIZE 256
#define HITTEX_SIZE 1024

//バッファテクスチャのアンチエイリアス設定
#define BUFFER_AA true

//--よくわからない人はここから触らない--//
float4   MaterialDiffuse   : DIFFUSE  < string Object = "Geometry"; >;
#define MAX_ANISOTROPY 16

float4x4 WorldMatrix    : WORLD;
float4x4 wvpmat : WORLDVIEWPROJECTION;
float4x4 wvmat          : WORLDVIEW;

float4   CameraPos     : POSITION   < string Object = "Camera"; >;
float3   LightDirection    : DIRECTION < string Object = "Light"; >;
float4   LightAmbient     : AMBIENT   < string Object = "Light"; >;
float4   LightDifuse     : DIFUSE   < string Object = "Light"; >;
float4   LightSpecular     : SPECULAR   < string Object = "Light"; >;

#define TEX_WIDTH TEX_SIZE
#define TEX_HEIGHT TEX_SIZE

//==================================================================================================
// テクスチャーサンプラー
//==================================================================================================

texture HitRT: OFFSCREENRENDERTARGET <
    string Description = "OffScreen RenderTarget for MirrorWater.fx";
    int Width = HITTEX_SIZE;
    int Height = HITTEX_SIZE;
    string Format = "D3DFMT_R16F" ;
    float4 ClearColor = { 0, 0, 0, 1 };
    float ClearDepth = 1.0;
    bool AntiAlias = false;
    string DefaultEffect = 
        "self = hide;"
        "Mirror*.x = hide;"
        "WaterLightController.pmd = hide;"
        "*=HitObject.fx;";
>;
sampler HitView = sampler_state {
    texture = <HitRT>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = NONE;
    AddressU  = WRAP;
    AddressV = WRAP;
};
texture TexMask
<
   string ResourceName = "mask.png";
>;

sampler TexMaskView = sampler_state {
    texture = <TexMask>;
    Filter = LINEAR;
    AddressU  = WRAP;
    AddressV = WRAP;
};
texture ColorPallet
<
   string ResourceName = "ColorPallet.png";
>;

sampler ColorPalletView = sampler_state {
    texture = <ColorPallet>;
    Filter = LINEAR;
    AddressU  = CLAMP;
    AddressV = CLAMP;
};
texture WireTex
<
   string ResourceName = "Frame.png";
>;

sampler WireView = sampler_state {
    texture = <WireTex>;
    Filter = POINT;
    AddressU  = WRAP;
    AddressV = WRAP;
};

//波紋ガウス用X
texture RippleHeightTex_GX : RenderColorTarget
<
   int Width=TEX_SIZE;
   int Height=TEX_SIZE;
   string Format="R32F";
>;

//波紋ガウス用Y及び波紋高さマップ使用テクスチャ
texture RippleHeightTex_GY : RenderColorTarget
<
   int Width=TEX_SIZE;
   int Height=TEX_SIZE;
   string Format="R32F";
>;

sampler RippleHeightSampler_GX = sampler_state
{
	// 利用するテクスチャ
	Texture = <RippleHeightTex_GX>;
    Filter = LINEAR;
    AddressU = CLAMP;
    AddressV = CLAMP;
};
sampler RippleHeightSampler_GY = sampler_state
{
	// 利用するテクスチャ
	Texture = <RippleHeightTex_GY>;
    Filter = LINEAR;
    AddressU = CLAMP;
    AddressV = CLAMP;
};

texture DepthBuffer : RenderDepthStencilTarget <
   int Width=TEX_WIDTH;
   int Height=TEX_HEIGHT;
    string Format = "D24S8";
>;

//--波紋計算用
//高さ情報を保存するテクスチャー
texture RippleHeightTex1 : RenderColorTarget
<
   int Width=TEX_SIZE;
   int Height=TEX_SIZE;
   string Format="R32F";
>;
//高さ情報を保存するテクスチャー
texture RippleHeightTex2 : RenderColorTarget
<
   int Width=TEX_SIZE;
   int Height=TEX_SIZE;
   string Format="R32F";
>;
//速度情報を保存するテクスチャー
texture RippleVelocityTex1 : RenderColorTarget
<
   int Width=TEX_SIZE;
   int Height=TEX_SIZE;
   string Format="A32B32G32R32F";
>;
texture RippleVelocityTex2 : RenderColorTarget
<
   int Width=TEX_SIZE;
   int Height=TEX_SIZE;
   string Format="A32B32G32R32F";
>;
texture RippleNormalTex : RenderColorTarget
<
   int Width=TEX_SIZE;
   int Height=TEX_SIZE;
   string Format="A32B32G32R32F";
>;

//---サンプラー
//--波紋用
sampler RippleHeightSampler1 = sampler_state
{
	// 利用するテクスチャ
	Texture = <RippleHeightTex1>;
    Filter = POINT;
    AddressU = CLAMP;
    AddressV = CLAMP;
};
sampler RippleHeightSampler1_Linear = sampler_state
{
	// 利用するテクスチャ
	Texture = <RippleHeightTex1>;
    Filter = LINEAR;
    AddressU = CLAMP;
    AddressV = CLAMP;
};
sampler RippleVelocitySampler1 = sampler_state
{
	// 利用するテクスチャ
	Texture = <RippleVelocityTex1>;
    Filter = POINT;
    AddressU = CLAMP;
    AddressV = CLAMP;
};
sampler RippleHeightSampler2 = sampler_state
{
	// 利用するテクスチャ
	Texture = <RippleHeightTex2>;
    Filter = POINT;
    AddressU = CLAMP;
    AddressV = CLAMP;
};
sampler RippleVelocitySampler2 = sampler_state
{
	// 利用するテクスチャ
	Texture = <RippleVelocityTex2>;
    Filter = POINT;
    AddressU = CLAMP;
    AddressV = CLAMP;
};
sampler RippleNormalSampler = sampler_state
{
	// 利用するテクスチャ
	Texture = <RippleNormalTex>;
    Filter = LINEAR;
    AddressU = CLAMP;
    AddressV = CLAMP;
};

//==================================================================================================
// 頂点フォーマット
//==================================================================================================
struct VS_IN
{
	float4 Pos : POSITION;
};

struct VS_OUTPUT
{
   float4 Pos      : POSITION;  //頂点座標
   float2 Tex      : TEXCOORD0; //テクセル座標
   float3 Normal      : TEXCOORD1; //法線ベクトル
   float3 WorldPos : TEXCOORD2;
   float4 LastPos : TEXCOORD3;
   float4 DefPos	: TEXCOORD4;
};
float time_0_X : Time;
//==================================================================================================
// 頂点シェーダー
//==================================================================================================
VS_OUTPUT VS_SeaMain( float3 Pos      : POSITION,   //頂点座標
              float3 normal   : NORMAL,     //法線ベクトル
              float2 Tex      : TEXCOORD0   //テクセル
              )
{
	Tex = Pos.xy + 0.5;
	Tex.y = 1-Tex.y;
	VS_OUTPUT Out;
	float2 texpos = Tex;

	Pos.z = 0;

    Out.DefPos = float4(Pos,1.0f);
	Out.Pos    = mul( float4( Pos, 1.0f ), wvpmat );
	Out.LastPos = Out.Pos;
	Out.Tex    = Tex;

	Out.Normal =  normalize(mul(  normal, (float3x3)WorldMatrix ));
	
	Out.WorldPos = mul(float4(Pos,1),WorldMatrix);
	    
    // テクスチャ座標
    Out.Tex = Tex;
	
    
	
	return Out;
}
float3x3 compute_tangent_frame(float3 Normal, float3 View, float2 UV)
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
//ビューポートサイズ
float2 Viewport : VIEWPORTPIXELSIZE; 

// シャドウバッファのサンプラ。"register(s0)"なのはMMDがs0を使っているから
sampler DefSampler : register(s0);

//==================================================================================================
// ピクセルシェーダー 
//==================================================================================================
float4 PS_SeaMain( VS_OUTPUT In,uniform bool Shadow ) : COLOR
{
	float2 temp = In.Tex;
	temp.y = 1 - temp.y;
    float h = tex2D( RippleHeightSampler_GY, temp)*10;

	h = abs(h);
	
	float4 Color = tex2D(ColorPalletView,float2(h,0.5))*2;
	
	#ifdef USE_FRAME
		Color *= tex2D(WireView,temp*WireScale);
	#endif
	Color.rgb *= LightColor;
	Color.rgb *= LightPow;
	Color.a *= MaterialDiffuse.a;
    return Color;
}
struct PS_IN_BUFFER
{
	float4 Pos : POSITION;
	float2 Tex : TEXCOORD0;
};
struct PS_OUT
{
	float4 Height		: COLOR0;
	float4 Velocity		: COLOR1;
};

float4 TextureOffsetTbl[4] = {
	float4(-1.0f,  0.0f, 0.0f, 0.0f) / TEX_WIDTH,
	float4(+1.0f,  0.0f, 0.0f, 0.0f) / TEX_WIDTH,
	float4( 0.0f, -1.0f, 0.0f, 0.0f) / TEX_WIDTH,
	float4( 0.0f, +1.0f, 0.0f, 0.0f) / TEX_WIDTH,
};
//入力された値をそのまま吐く
PS_IN_BUFFER VS_Standard( float4 Pos: POSITION, float2 Tex: TEXCOORD )
{
   PS_IN_BUFFER Out;
   Out.Pos = Pos;
   Out.Tex = Tex + float2(0.5/TEX_WIDTH, 0.5/TEX_HEIGHT);
   return Out;
}

//--波紋用
//--高さマップ計算
PS_OUT PS_RippleHeight1( PS_IN_BUFFER In ) : COLOR
{
	PS_OUT Out;
	float Height;
	float Velocity;
	if(time_0_X == 0)
	{
		Out.Height   = 0;
		Out.Velocity   = 0;
	}else{
		Height   = tex2D( RippleHeightSampler2, In.Tex );
		Velocity = tex2D( RippleVelocitySampler2, In.Tex );
		float4 HeightTbl = {
			tex2D( RippleHeightSampler2, In.Tex + TextureOffsetTbl[0] ).r,
			tex2D( RippleHeightSampler2, In.Tex + TextureOffsetTbl[1] ).r,
			tex2D( RippleHeightSampler2, In.Tex + TextureOffsetTbl[2] ).r,
			tex2D( RippleHeightSampler2, In.Tex + TextureOffsetTbl[3] ).r,
		};
		Out.Velocity = Velocity + ((dot( (HeightTbl - Height), float4( 1.0, 1.0, 1.0, 1.0 ) )) * WaveSpeed);

		Out.Height = Height + Out.Velocity;
		
		
		In.Tex.y = 1-In.Tex.y;
		float HitData = tex2D(HitView,In.Tex.xy).r;
		
		Out.Height += (HitData * WavePow);
		//Out.Velocity *= 1-HitData;
		//Out.Height = max(-1,min(1,Out.Height));
		//Out.Velocity = max(-1,min(1,Out.Velocity));
	
		Out.Height *= DownPow;
	}
	Out.Velocity.a = 1;
	Out.Height.a = 1;
	return Out;
}
//高さマップコピー
PS_OUT PS_RippleHeight2( PS_IN_BUFFER In ) : COLOR
{
	PS_OUT Out;
	
	Out.Height = tex2D( RippleHeightSampler1, In.Tex );
	Out.Velocity = tex2D( RippleVelocitySampler1, In.Tex );
	return Out;
}
//法線マップの作成

struct CPU_TO_VS
{
	float4 Pos		: POSITION;
};
struct VS_TO_PS
{
	float4 Pos		: POSITION;
	float2 Tex[4]		: TEXCOORD;
};
VS_TO_PS VS_Normal( CPU_TO_VS In )
{
	VS_TO_PS Out;

	// 位置そのまま
	Out.Pos = In.Pos;

	float2 Tex = (In.Pos.xy+1)*0.5;

	// テクスチャ座標は中心からの４点
	float2 fInvSize = float2( 1.0, 1.0 ) / (float)TEX_WIDTH;

	Out.Tex[0] = Tex + float2( 0.0, -fInvSize.y );		// 上
	Out.Tex[1] = Tex + float2( 0.0, +fInvSize.y );		// 下
	Out.Tex[2] = Tex + float2( -fInvSize.x, 0.0 );		// 左
	Out.Tex[3] = Tex + float2( +fInvSize.x, 0.0 );		// 右

	return Out;
}
float4 PS_NormalRipple( VS_TO_PS In ) : COLOR
{
	float HeightHx = (tex2D( RippleHeightSampler_GY, In.Tex[3]) - tex2D( RippleHeightSampler_GY, In.Tex[2])) * 3.0;
	float HeightHy = (tex2D( RippleHeightSampler_GY, In.Tex[0]) - tex2D( RippleHeightSampler_GY, In.Tex[1])) * 3.0;

	float3 AxisU = { 1.0, HeightHx, 0.0 };
	float3 AxisV = { 0.0, HeightHy, 1.0 };

	//float3 Out = (normalize( cross( AxisU, AxisV ) ) * 1) + 0.5;
	float3 Out = (normalize( cross( AxisU, AxisV ) )) + 0.5; //PiT mod
	Out.g = -1;
	return float4( Out, 1 );
}


////////////////////////////////////////////////////////////////////////////////////////////////

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

////////////////////////////////////////////////////////////////////////////////////////////////
// X方向ぼかし
// スクリーンサイズ
static float2 ViewportOffset = (float2(0.5,0.5)/TEX_SIZE);
static float2 SampStep = (float2(PushGauss,PushGauss)/TEX_SIZE);

PS_IN_BUFFER VS_passX( float4 Pos : POSITION, float4 Tex : TEXCOORD0 ) {
    PS_IN_BUFFER Out = (PS_IN_BUFFER)0; 
    
    Out.Pos = Pos;
    Out.Tex = Tex + float2(0, ViewportOffset.y);
    
    return Out;
}

float4 PS_passX( float2 Tex: TEXCOORD0 ) : COLOR {   
    float4 Color;
	
	Color  = WT_0 *   tex2D( RippleHeightSampler1, Tex );
	Color += WT_1 * ( tex2D( RippleHeightSampler1, Tex+float2(SampStep.x  ,0) ) + tex2D( RippleHeightSampler1, Tex-float2(SampStep.x  ,0) ) );
	Color += WT_2 * ( tex2D( RippleHeightSampler1, Tex+float2(SampStep.x*2,0) ) + tex2D( RippleHeightSampler1, Tex-float2(SampStep.x*2,0) ) );
	Color += WT_3 * ( tex2D( RippleHeightSampler1, Tex+float2(SampStep.x*3,0) ) + tex2D( RippleHeightSampler1, Tex-float2(SampStep.x*3,0) ) );
	Color += WT_4 * ( tex2D( RippleHeightSampler1, Tex+float2(SampStep.x*4,0) ) + tex2D( RippleHeightSampler1, Tex-float2(SampStep.x*4,0) ) );
	Color += WT_5 * ( tex2D( RippleHeightSampler1, Tex+float2(SampStep.x*5,0) ) + tex2D( RippleHeightSampler1, Tex-float2(SampStep.x*5,0) ) );
	Color += WT_6 * ( tex2D( RippleHeightSampler1, Tex+float2(SampStep.x*6,0) ) + tex2D( RippleHeightSampler1, Tex-float2(SampStep.x*6,0) ) );
	Color += WT_7 * ( tex2D( RippleHeightSampler1, Tex+float2(SampStep.x*7,0) ) + tex2D( RippleHeightSampler1, Tex-float2(SampStep.x*7,0) ) );
	
    return Color;
}

////////////////////////////////////////////////////////////////////////////////////////////////
// Y方向ぼかし

PS_IN_BUFFER VS_passY( float4 Pos : POSITION, float4 Tex : TEXCOORD0 ){
    PS_IN_BUFFER Out = (PS_IN_BUFFER)0; 
    
    Out.Pos = Pos;
    Out.Tex = Tex + float2(ViewportOffset.x, 0);
    return Out;
}

float4 PS_passY(float2 Tex: TEXCOORD0) : COLOR
{   
    float4 Color;
	Color  = WT_0 *   tex2D( RippleHeightSampler_GX, Tex );
	Color += WT_1 * ( tex2D( RippleHeightSampler_GX, Tex+float2(0,SampStep.y  ) ) + tex2D( RippleHeightSampler_GX, Tex-float2(0,SampStep.y  ) ) );
	Color += WT_2 * ( tex2D( RippleHeightSampler_GX, Tex+float2(0,SampStep.y*2) ) + tex2D( RippleHeightSampler_GX, Tex-float2(0,SampStep.y*2) ) );
	Color += WT_3 * ( tex2D( RippleHeightSampler_GX, Tex+float2(0,SampStep.y*3) ) + tex2D( RippleHeightSampler_GX, Tex-float2(0,SampStep.y*3) ) );
	Color += WT_4 * ( tex2D( RippleHeightSampler_GX, Tex+float2(0,SampStep.y*4) ) + tex2D( RippleHeightSampler_GX, Tex-float2(0,SampStep.y*4) ) );
	Color += WT_5 * ( tex2D( RippleHeightSampler_GX, Tex+float2(0,SampStep.y*5) ) + tex2D( RippleHeightSampler_GX, Tex-float2(0,SampStep.y*5) ) );
	Color += WT_6 * ( tex2D( RippleHeightSampler_GX, Tex+float2(0,SampStep.y*6) ) + tex2D( RippleHeightSampler_GX, Tex-float2(0,SampStep.y*6) ) );
	Color += WT_7 * ( tex2D( RippleHeightSampler_GX, Tex+float2(0,SampStep.y*7) ) + tex2D( RippleHeightSampler_GX, Tex-float2(0,SampStep.y*7) ) );
	
	
    return Color;
}


#define BLENDMODE_SRC SRCALPHA
#define BLENDMODE_DEST ONE

float4 ClearColor = {0,0,0,1};
float ClearDepth  = 1.0;
//==================================================================================================
// テクニック
//==================================================================================================
technique Technique_Sample
<
	string MMDPass = "object";
    string Script = 
        "ClearSetColor=ClearColor; ClearSetDepth=ClearDepth;"
    	//メイン水面計算
		//波紋計算
	    "RenderDepthStencilTarget=DepthBuffer;"
        "RenderColorTarget0=RippleHeightTex1;"
        "RenderColorTarget1=RippleVelocityTex1;"
	    "Pass=ripple_height1;"
        
        "RenderColorTarget0=RippleHeightTex2;"
        "RenderColorTarget1=RippleVelocityTex2;"
	    "Pass=ripple_height2;"
	    
        "RenderColorTarget1=;"
        
		//波紋ガウスX
        "RenderColorTarget0=RippleHeightTex_GX;"
	    "Pass=Gaussian_X;"

		//波紋ガウスY
        "RenderColorTarget0=RippleHeightTex_GY;"
	    "Pass=Gaussian_Y;"
        
        "RenderColorTarget0=RippleNormalTex;"
		"Pass=ripple_normal;"

		//水面描画
        "RenderColorTarget0=;"
        "RenderColorTarget1=;"
	    "RenderDepthStencilTarget=;"
	    "Pass=MainPath;"
    ;
> {
	//--波紋用
	//高さ情報計算
	pass ripple_height1 < string Script = "Draw=Buffer;";>
	{
	    ALPHABLENDENABLE = FALSE;
	    ALPHATESTENABLE=FALSE;
		ZENABLE = FALSE;
		ZWRITEENABLE = FALSE;
	    VertexShader = compile vs_2_0 VS_Standard();
	    PixelShader = compile ps_2_0 PS_RippleHeight1();
	}
	//高さ情報コピーして保存
	pass ripple_height2 < string Script = "Draw=Buffer;";>
	{
	    ALPHABLENDENABLE = FALSE;
	    ALPHATESTENABLE=FALSE;
		ZENABLE = FALSE;
		ZWRITEENABLE = FALSE;
	    VertexShader = compile vs_2_0 VS_Standard();
	    PixelShader = compile ps_2_0 PS_RippleHeight2();
	}
	//法線マップ作製
	pass ripple_normal < string Script = "Draw=Buffer;";>
	{
	    ALPHABLENDENABLE = FALSE;
	    ALPHATESTENABLE=FALSE;
		ZENABLE = FALSE;
		ZWRITEENABLE = FALSE;
	    VertexShader = compile vs_2_0 VS_Normal();
	    PixelShader = compile ps_2_0 PS_NormalRipple();
	}
	//メインパス 
   pass MainPath 
   {
      ZENABLE = TRUE;
      ZWRITEENABLE = FALSE;
      CULLMODE = NONE;
      ALPHABLENDENABLE = TRUE;
      SRCBLEND=BLENDMODE_SRC;
      DESTBLEND=BLENDMODE_DEST;
      //使用するシェーダを設定
      VertexShader = compile vs_3_0 VS_SeaMain();
      PixelShader = compile ps_3_0 PS_SeaMain(false);
   }
    pass Gaussian_X < string Script= "Draw=Buffer;"; > {
        AlphaBlendEnable = FALSE;
        VertexShader = compile vs_2_0 VS_passX();
        PixelShader  = compile ps_2_0 PS_passX();
    }
    pass Gaussian_Y < string Script= "Draw=Buffer;"; > {
        AlphaBlendEnable = FALSE;
        VertexShader = compile vs_2_0 VS_passY();
        PixelShader  = compile ps_2_0 PS_passY();
    }
}