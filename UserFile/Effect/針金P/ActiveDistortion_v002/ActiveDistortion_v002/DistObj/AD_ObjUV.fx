////////////////////////////////////////////////////////////////////////////////////////////////
//
//  AD_ObjUV.fx 空間歪みエフェクト(モデル形状に合わせて歪ませる,ノーマルマップUV座標貼り付け)
//  ( ActiveDistortion.fx から呼び出されます．オフスクリーン描画用)
//  作成: 針金P
//
////////////////////////////////////////////////////////////////////////////////////////////////
// ここのパラメータを変更してください

#define USE_NORMALMAP  1   // ノーマルマップを 1:使用する, 0:使用しない

#define UV_COORD  0   // ノーマルマップの読み取りUV値
// 0:標準テクスチャ座標, 1:追加UV1, 2:追加UV2, 3:追加UV3, 4:追加UV4

#define TEX_FileName  "NormalMapSample.png" // ノーマルマップテクスチャファイル名


// 解らない人はここから下はいじらないでね

////////////////////////////////////////////////////////////////////////////////////////////////
// パラメータ宣言

#ifndef MIKUMIKUMOVING

#define ControlModel  "DistObjUVControl.pmd"  // コントロールモデルファイル名
float MorphUScaleP  : CONTROLOBJECT < string name = ControlModel; string item = "U拡大"; >;
float MorphUScaleM  : CONTROLOBJECT < string name = ControlModel; string item = "U縮小"; >;
float MorphVScaleP  : CONTROLOBJECT < string name = ControlModel; string item = "V拡大"; >;
float MorphVScaleM  : CONTROLOBJECT < string name = ControlModel; string item = "V縮小"; >;
float MorphUScrollP : CONTROLOBJECT < string name = ControlModel; string item = "Uスクロール＋"; >;
float MorphUScrollM : CONTROLOBJECT < string name = ControlModel; string item = "Uスクロール−"; >;
float MorphVScrollP : CONTROLOBJECT < string name = ControlModel; string item = "Vスクロール＋"; >;
float MorphVScrollM : CONTROLOBJECT < string name = ControlModel; string item = "Vスクロール−"; >;
float MorphU0Fade   : CONTROLOBJECT < string name = ControlModel; string item = "U0フェード"; >;
float MorphU1Fade   : CONTROLOBJECT < string name = ControlModel; string item = "U1フェード"; >;
float MorphV0Fade   : CONTROLOBJECT < string name = ControlModel; string item = "V0フェード"; >;
float MorphV1Fade   : CONTROLOBJECT < string name = ControlModel; string item = "V1フェード"; >;
float MorphU0FadeW  : CONTROLOBJECT < string name = ControlModel; string item = "U0フェード幅"; >;
float MorphU1FadeW  : CONTROLOBJECT < string name = ControlModel; string item = "U1フェード幅"; >;
float MorphV0FadeW  : CONTROLOBJECT < string name = ControlModel; string item = "V0フェード幅"; >;
float MorphV1FadeW  : CONTROLOBJECT < string name = ControlModel; string item = "V1フェード幅"; >;
float MorphDist     : CONTROLOBJECT < string name = ControlModel; string item = "歪み度"; >;
static float ScaleU = 1.0f + MorphUScaleM*19.0f - MorphUScaleP*19.0f/20.0f;
static float ScaleV = 1.0f + MorphVScaleM*19.0f - MorphVScaleP*19.0f/20.0f;
static float ScrollSpeedU = (MorphUScrollP - MorphUScrollM) * abs(MorphUScrollP - MorphUScrollM) * 10.0f;
static float ScrollSpeedV = (MorphVScrollP - MorphVScrollM) * abs(MorphVScrollP - MorphVScrollM) * 10.0f;
static float4 FadeValue = float4(MorphU0Fade, 1.0f-MorphU1Fade, MorphV0Fade, 1.0f-MorphV1Fade);
static float4 FadeWidth = float4(MorphU0FadeW, MorphU1FadeW, MorphV0FadeW, MorphV1FadeW);
static float DistFactor = 1.0f - MorphDist;

#else

float MMMScaleU < // U拡大縮小
   string UIName = "U拡大縮小";
   string UIWidget = "Slider";
   bool UIVisible =  true;
   float UIMin = -1.0;
   float UIMax = 1.0;
> = float( 0.0 );

float MMMScaleV < // V拡大縮小
   string UIName = "V拡大縮小";
   string UIWidget = "Slider";
   bool UIVisible =  true;
   float UIMin = -1.0;
   float UIMax = 1.0;
> = float( 0.0 );

float MMMScrollU < // Uスクロール
   string UIName = "Uスクロール";
   string UIWidget = "Slider";
   bool UIVisible =  true;
   float UIMin = -1.0;
   float UIMax = 1.0;
> = float( 0.0 );

float MMMScrollV < // Vスクロール
   string UIName = "Vスクロール";
   string UIWidget = "Slider";
   bool UIVisible =  true;
   float UIMin = -1.0;
   float UIMax = 1.0;
> = float( 0.0 );

float MMMFadeU0 < // U0フェード
   string UIName = "U0フェード";
   string UIWidget = "Slider";
   bool UIVisible =  true;
   float UIMin = 0.0;
   float UIMax = 1.0;
> = float( 0.0 );

float MMMFadeU0W < // U0フェード幅
   string UIName = "U0フェード幅";
   string UIWidget = "Slider";
   bool UIVisible =  true;
   float UIMin = 0.0;
   float UIMax = 1.0;
> = float( 0.0 );

float MMMFadeU1 < // U1フェード
   string UIName = "U1フェード";
   string UIWidget = "Slider";
   bool UIVisible =  true;
   float UIMin = 0.0;
   float UIMax = 1.0;
> = float( 0.0 );

float MMMFadeU1W < // U1フェード幅
   string UIName = "U1フェード幅";
   string UIWidget = "Slider";
   bool UIVisible =  true;
   float UIMin = 0.0;
   float UIMax = 1.0;
> = float( 0.0 );

float MMMFadeV0 < // V0フェード
   string UIName = "V0フェード";
   string UIWidget = "Slider";
   bool UIVisible =  true;
   float UIMin = 0.0;
   float UIMax = 1.0;
> = float( 0.0 );

float MMMFadeV0W < // V0フェード幅
   string UIName = "V0フェード幅";
   string UIWidget = "Slider";
   bool UIVisible =  true;
   float UIMin = 0.0;
   float UIMax = 1.0;
> = float( 0.0 );

float MMMFadeV1 < // V1フェード
   string UIName = "V1フェード";
   string UIWidget = "Slider";
   bool UIVisible =  true;
   float UIMin = 0.0;
   float UIMax = 1.0;
> = float( 0.0 );

float MMMFadeV1W < // V1フェード幅
   string UIName = "V1フェード幅";
   string UIWidget = "Slider";
   bool UIVisible =  true;
   float UIMin = 0.0;
   float UIMax = 1.0;
> = float( 0.0 );

float MMMDist < // 歪み度
   string UIName = "歪み度";
   string UIWidget = "Slider";
   bool UIVisible =  true;
   float UIMin = 0.0;
   float UIMax = 1.0;
> = float( 1.0 );

static float ScaleU = pow(20.0f, -MMMScaleU);
static float ScaleV = pow(20.0f, -MMMScaleV);
static float ScrollSpeedU = MMMScrollU * abs(MMMScrollU) * 10.0f;
static float ScrollSpeedV = MMMScrollV * abs(MMMScrollV) * 10.0f;
static float4 FadeValue = float4(MMMFadeU0, 1.0f-MMMFadeU1, MMMFadeV0, 1.0f-MMMFadeV1);
static float4 FadeWidth = float4(MMMFadeU0W, MMMFadeU1W, MMMFadeV0W, MMMFadeV1W);
static float DistFactor = MMMDist;

#endif


#define DEPTH_FAR  5000.0f   // 深度最遠値

// 透過値に対する深度読み取り閾値
float AlphaClipThreshold = 0.005;

// 座標変換行列
float4x4 ProjMatrix          : PROJECTION;
float4x4 WorldViewMatrix     : WORLDVIEW;
float4x4 ViewProjMatrix      : VIEWPROJECTION;
float4x4 WorldViewProjMatrix : WORLDVIEWPROJECTION;

// カメラ位置
float3 CameraPosition : POSITION  < string Object = "Camera"; >;

// マテリアル色
float4 MaterialDiffuse : DIFFUSE  < string Object = "Geometry"; >;
float4 EdgeColor       : EDGECOLOR;

bool opadd;       // 加算合成フラグ
bool use_texture; // テクスチャの有無

// オブジェクトのテクスチャ
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
// ノーマルマップテクスチャ
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
// スクロール距離・時間間隔計算

float time : TIME;

// 更新スクロール距離・時刻記録用
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
    float2 p = Pos.xy - float2(ScrollSpeedU, ScrollSpeedV) * Dt;
    if(time < 0.001f) p = float2(0,0);
    return float4(frac(p), time, 1);
}


////////////////////////////////////////////////////////////////////////////////////////////////
//接空間回転行列取得

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
//MMM対応

#ifndef MIKUMIKUMOVING
    struct VS_INPUT{
        float4 Pos    : POSITION;
        float2 Tex    : TEXCOORD0;
        float4 AddUV1 : TEXCOORD1;
        float4 AddUV2 : TEXCOORD2;
        float4 AddUV3 : TEXCOORD3;
        float4 AddUV4 : TEXCOORD4;
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
// 法線・深度描画

struct VS_OUTPUT {
    float4 Pos    : POSITION;   // 射影変換座標
    float3 Normal : TEXCOORD0;  // 法線
    float4 VPos   : TEXCOORD1;  // ビュー座標
    float2 Tex    : TEXCOORD2;  // UV座標
};

// 頂点シェーダ
VS_OUTPUT VS_Object( VS_INPUT IN )
{
    VS_OUTPUT Out = (VS_OUTPUT)0; 
    MMM_SKINNING

    // カメラ視点のワールドビュー射影変換
    Out.Pos = mul( GETPOS, GET_WVPMAT(GETPOS) );

    // カメラ視点のワールドビュー変換
    Out.VPos = mul( GETPOS, WorldViewMatrix );

    // 法線のカメラ視点のワールドビュー変換
    Out.Normal = normalize( mul(GETNORMAL, (float3x3)WorldViewMatrix) );

    // テクスチャ座標
    #if (UV_COORD==0)
    Out.Tex = IN.Tex;
    #endif
    #if (UV_COORD==1)
    Out.Tex = IN.AddUV1;
    #endif
    #if (UV_COORD==2)
    Out.Tex = IN.AddUV2;
    #endif
    #if (UV_COORD==3)
    Out.Tex = IN.AddUV3;
    #endif
    #if (UV_COORD==4)
    Out.Tex = IN.AddUV4;
    #endif

    return Out;
}

//ピクセルシェーダ
float4 PS_Object(VS_OUTPUT IN) : COLOR
{
    float alpha = MaterialDiffuse.a * !opadd;
    if ( use_texture ) {
        // テクスチャ透過値適用
        alpha *= tex2D( ObjTexSampler, IN.Tex ).a * !opadd;
    }
    // α値が閾値以下の箇所は描画しない
    clip(alpha - AlphaClipThreshold);

    #if(USE_NORMALMAP==1)
    // ノーマルマップを含む法線取得
    float3 eye = -IN.VPos.xyz / IN.VPos.w;
    float2 tex = float2(IN.Tex.x*ScaleU, IN.Tex.y*ScaleV) + tex2D(TimeTexSmp, float2(0.5f,0.5f)).xy;
    float3x3 tangentFrame = GetTangentFrame(IN.Normal, eye, tex);
    float3 Normal = normalize(mul(2.0f * tex2D(NormalMapSamp, tex).rgb - 1.0f, tangentFrame));
    #else
    float3 Normal = normalize( IN.Normal );
    #endif

    // フェード透過値計算
    float4 a = lerp( -0.5f*FadeWidth, 1.0f+0.5f*FadeWidth, FadeValue );
    float4 minLen = a - 0.5f * FadeWidth;
    float4 maxLen = a + 0.5f * FadeWidth;
    alpha *= (FadeWidth.x > 0.0f) ? saturate( (frac(IN.Tex.x) - minLen.x)/(maxLen.x - minLen.x) ) : step(FadeValue.x, frac(IN.Tex.x));
    alpha *= (FadeWidth.y > 0.0f) ? 1.0f - saturate( (frac(IN.Tex.x) - minLen.y)/(maxLen.y - minLen.y) ) : step(frac(IN.Tex.x), FadeValue.y);
    alpha *= (FadeWidth.z > 0.0f) ? saturate( (frac(IN.Tex.y) - minLen.z)/(maxLen.z - minLen.z) ) : step(FadeValue.z, frac(IN.Tex.y));
    alpha *= (FadeWidth.w > 0.0f) ? 1.0f - saturate( (frac(IN.Tex.y) - minLen.w)/(maxLen.w - minLen.w) ) : step(frac(IN.Tex.y), FadeValue.w);
    alpha *= DistFactor;

    // 法線(0〜1になるよう補正)
    Normal = (Normal + 1.0f) / 2.0f;
    Normal = lerp(float3(0.5, 0.5, 0.0f), Normal, alpha);

    // 深度(0〜DEPTH_FARを0.5〜1.0に正規化)
    float dep = length(IN.VPos.xyz / IN.VPos.w);
    dep = (saturate(dep / DEPTH_FAR) + 1.0f) * 0.5f;

    return float4(Normal, dep);
}

///////////////////////////////////////////////////////////////////////////////////////
// テクニック

// オブジェクト描画(セルフシャドウなし)
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

// オブジェクト描画(セルフシャドウあり)
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
//エッジ・地面影は描画しない
technique EdgeTec < string MMDPass = "edge"; > { }
technique ShadowTec < string MMDPass = "shadow"; > { }
technique ZplotTec < string MMDPass = "zplot"; > { }

