////////////////////////////////////////////////////////////////////////////////////////////////
//
//  PostClip (PostClip_Height.fx) ver0.0.1
//  既存のポストエフェクトを特定領域でクリップ（高さに応じてクリップ）
//  作成: 針金P
//
////////////////////////////////////////////////////////////////////////////////////////////////
// パラメータ宣言

#include "PostClipHeader.fxh"

float InitMin = 0.0f;  // クリップ合成最小の初期高さ
float InitMax = 0.0f;   // クリップ合成最大の初期高さ

float Script : STANDARDSGLOBAL <
    string ScriptOutput = "color";
    string ScriptClass = "scene";
    string ScriptOrder = "postprocess";
> = 0.8;

// アクセサリパラメータ
float AcsTr : CONTROLOBJECT < string name = "(self)"; string item = "Tr"; >;

#ifndef MIKUMIKUMOVING

    float3 AcsXYZ : CONTROLOBJECT < string name = "(self)"; string item = "XYZ"; >;
    static bool ClipFlag = (AcsXYZ.x < 0.999f) ? false : true;   // クリップ実行
    static bool MulFlag  = (AcsXYZ.y < 0.999f) ? false : true;   // 論理積合成
    static bool InvFlag  = (AcsXYZ.z < 0.999f) ? false : true;   // クリップ反転

    float3 AcsRxyz : CONTROLOBJECT < string name = "(self)"; string item = "Rxyz"; >;
    static float hMin = degrees(AcsRxyz.x);
    static float hMax = degrees(AcsRxyz.y);

#else

    bool ClipFlag <        // クリップ実行
       string UIName = "クリップ実行";
       bool UIVisible =  true;
    > = true;

    bool MulFlag <        // 論理積合成
       string UIName = "論理積";
       bool UIVisible =  true;
    > = false;

    bool InvFlag <        // クリップ反転
       string UIName = "反転";
       bool UIVisible =  true;
    > = false;

    float hMin <
        string UIName = "下方";
        string UIHelp = "クリップを開始する下方の高さ";
        //string UIWidget = "Slider";
        string UIWidget = "Numeric";
        bool UIVisible =  true;
        float UIMin = -5000.0;
        float UIMax = 5000.0;
    > = float( 0.0 );

    float hMax <
        string UIName = "上方";
        string UIHelp = "クリップし終わる上方の高さ";
        //string UIWidget = "Slider";
        string UIWidget = "Numeric";
        bool UIVisible =  true;
        float UIMin = -5000.0;
        float UIMax = 5000.0;
    > = float( 10.0 );

#endif


// スクリーンサイズ
float2 ViewportSize : VIEWPORTPIXELSIZE;
static float2 ViewportOffset = (float2(0.5,0.5)/ViewportSize);

// レンダリングターゲットのクリア値
float4 ClearColor = {0,0,0,0};
float ClearDepth  = 1.0;

// ポストエフェクトをかける前の画像
shared texture2D ScnMapSrc : RENDERCOLORTARGET;
sampler2D ScnSampSrc = sampler_state {
    texture = <ScnMapSrc>;
    MinFilter = POINT;
    MagFilter = POINT;
    MipFilter = NONE;
    AddressU = CLAMP;
    AddressV = CLAMP;
};

// クリップ領域のマッピング画像
shared texture2D ScnClipMap : RENDERCOLORTARGET;
sampler2D ScnSampClip = sampler_state {
    texture = <ScnClipMap>;
    MinFilter = POINT;
    MagFilter = POINT;
    MipFilter = NONE;
    AddressU = CLAMP;
    AddressV = CLAMP;
};

// オリジナルの描画結果を記録するためのレンダーターゲット
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
    #define OFFSCREEN_HEIGHT "PC_Height.fxsub"
#else
    #define OFFSCREEN_HEIGHT "PC_HeightMMM.fxsub"
#endif

// 高さマップ描画先オフスクリーンバッファ
texture PC_HeightRT: OFFSCREENRENDERTARGET <
    string Description = "PostClipの高さマップバッファ";
    float2 ViewPortRatio = {1.0,1.0};
    float4 ClearColor = { 1, 1, 1, 1 };
    float ClearDepth = 1.0;
    string Format = "D3DFMT_R32F";
    bool AntiAlias = false;
    string DefaultEffect = 
        "self = hide;"
        "PreClip.x = hide;"
        "* =" OFFSCREEN_HEIGHT ";";
>;
sampler HeightSamp = sampler_state {
    texture = <PC_HeightRT>;
    MinFilter = POINT;
    MagFilter = POINT;
    MipFilter = NONE;
    AddressU = CLAMP;
    AddressV = CLAMP;
};


////////////////////////////////////////////////////////////////////////////////////////////////
// ポストエフェクトの前と後の画像を合成

struct VS_OUTPUT {
    float4 Pos : POSITION;
    float2 Tex : TEXCOORD0;
};

// 頂点シェーダ
VS_OUTPUT VS_Clip( float4 Pos : POSITION, float2 Tex : TEXCOORD0 )
{
    VS_OUTPUT Out = (VS_OUTPUT)0; 
    Out.Pos = Pos;
    Out.Tex = Tex + ViewportOffset;
    return Out;
}

// ピクセルシェーダ
float4 PS_Clip( float2 Tex: TEXCOORD0 ) : COLOR
{
    // 直前までのクリップ合成結果
    float s0 = tex2D( ScnSampClip, Tex ).r;

    // ピクセルの高さ
    float Height = tex2D( HeightSamp, Tex ).r;

    // クリップ範囲
    float s = saturate((hMax - Height) / max(hMax - hMin, 0.001f) );

    // クリップ合成
    if(InvFlag) s = 1.0f - s;
    s *= AcsTr;
    s = MulFlag ? s*s0 : max(s, s0);

    return float4(s, 0, 0, 1);

}

// ピクセルシェーダ(画像描画)
float4 PS_Draw( float2 Tex: TEXCOORD0 ) : COLOR
{
    // ポストエフェクト処理前の画像
    float4 Color0 = tex2D( ScnSampSrc, Tex );

    // ポストエフェクト処理後の画像
    float4 Color = tex2D( ScnSamp, Tex );

    // クリップ範囲
    float4 s = tex2D( ScnSampClip, Tex ).r;

    // 合成
    if(ClipFlag) Color = lerp(Color0, Color, s);

    return Color;

}

////////////////////////////////////////////////////////////////////////////////////////////////
// テクニック

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
