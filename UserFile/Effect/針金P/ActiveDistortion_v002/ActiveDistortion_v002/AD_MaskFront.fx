////////////////////////////////////////////////////////////////////////////////////////////////
//
//  AD_MaskFront.fx  法線(正面)・深度マップ作成(モデル前面配置用)
//  ( ActiveDistortion.fx から呼び出されます．オフスクリーン描画用)
//  作成: 針金P
//
////////////////////////////////////////////////////////////////////////////////////////////////
// パラメータ宣言

#define DEPTH_FAR  100.0f   // 深度最遠値

// 透過値に対する深度読み取り閾値
float AlphaClipThreshold = 0.5;

// 座標変換行列
float4x4 WorldViewProjMatrix : WORLDVIEWPROJECTION;
float4x4 WorldViewMatrix     : WORLDVIEW;

// マテリアル色
float4 MaterialDiffuse : DIFFUSE  < string Object = "Geometry"; >;
float4 EdgeColor       : EDGECOLOR;

bool opadd; // 加算合成フラグ

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

shared texture2D DepthTexB : RENDERCOLORTARGET;

////////////////////////////////////////////////////////////////////////////////////////////////
// 深度描画

struct VS_OUTPUT {
    float4 Pos  : POSITION;
    float4 VPos : TEXCOORD0;
    float2 Tex  : TEXCOORD1;
};

// 頂点シェーダ
VS_OUTPUT VS_Object(float4 Pos : POSITION, float2 Tex : TEXCOORD0)
{
    VS_OUTPUT Out = (VS_OUTPUT)0; 

    // カメラ視点のワールドビュー射影変換
    Out.Pos = mul( Pos, WorldViewProjMatrix );

    // カメラ視点のワールドビュー変換
    Out.VPos = mul( Pos, WorldViewMatrix );

    // テクスチャ座標
    Out.Tex = Tex;

    return Out;
}

struct PS_OUTPUT {
    float4 Color0 : COLOR0;
    float4 Color1 : COLOR1;
};

//ピクセルシェーダ
PS_OUTPUT PS_Object(VS_OUTPUT IN, uniform bool isObj, uniform bool useTexture)
{
    PS_OUTPUT Out;

    float alpha;
    if( isObj ) {
        alpha = MaterialDiffuse.a * !opadd;
        if ( useTexture ) {
            // テクスチャ透過値適用
            alpha *= tex2D( ObjTexSampler, IN.Tex ).a * !opadd;
        }
    }else{
        alpha = EdgeColor.a * !opadd;
    }
    // α値が閾値以下の箇所は描画しない
    clip(alpha - AlphaClipThreshold);

    // 深度(0〜DEPTH_FARを0.5〜0.0に正規化)
    float dep = length(IN.VPos.xyz / IN.VPos.w);
    float dep1 = saturate(dep / DEPTH_FAR);
    dep = (1.0f - saturate(dep / DEPTH_FAR)) * 0.5f;

    Out.Color0 = float4(0.5f, 0.5f, 0.0f, dep);
    Out.Color1 = float4(1.0f, 0.0f, 0.0f, 1.0f); // AD_Mask.fxsubとはここが違うだけ
    return Out;
}

///////////////////////////////////////////////////////////////////////////////////////
// テクニック

#define SCRIPT_DEPTH(n)  "RenderColorTarget0=;" \
                         "RenderColorTarget1=DepthTexB;" \
                             "RenderDepthStencilTarget=;" \
                             "Pass=" #n ";" \
                         "RenderColorTarget0=;" \
                         "RenderColorTarget1=;" \
                             "RenderDepthStencilTarget=;"

// エッジ描画
technique EdgeDepthTec < string MMDPass = "edge";
    string Script = SCRIPT_DEPTH(DrawEdge);
>{
    pass DrawEdge {
        AlphaBlendEnable = FALSE;
        AlphaTestEnable  = FALSE;
        VertexShader = compile vs_2_0 VS_Object();
        PixelShader  = compile ps_2_0 PS_Object(false, false);
    }
}

// オブジェクト描画(セルフシャドウなし)
technique DepthTec0 < string MMDPass = "object"; bool UseTexture = false;
    string Script = SCRIPT_DEPTH(DrawObject);
>{
    pass DrawObject {
        AlphaBlendEnable = FALSE;
        AlphaTestEnable  = FALSE;
        VertexShader = compile vs_2_0 VS_Object();
        PixelShader  = compile ps_2_0 PS_Object(true, false);
    }
}

technique DepthTec1 < string MMDPass = "object"; bool UseTexture = true;
    string Script = SCRIPT_DEPTH(DrawObject);
>{
    pass DrawObject {
        AlphaBlendEnable = FALSE;
        AlphaTestEnable  = FALSE;
        VertexShader = compile vs_2_0 VS_Object();
        PixelShader  = compile ps_2_0 PS_Object(true, true);
    }
}

// オブジェクト描画(セルフシャドウあり)
technique DepthTecSS0 < string MMDPass = "object_ss"; bool UseTexture = false;
    string Script = SCRIPT_DEPTH(DrawObject);
>{
    pass DrawObject {
        AlphaBlendEnable = FALSE;
        AlphaTestEnable  = FALSE;
        VertexShader = compile vs_2_0 VS_Object();
        PixelShader  = compile ps_2_0 PS_Object(true, false);
    }
}

technique DepthTecSS1 < string MMDPass = "object_ss"; bool UseTexture = true;
    string Script = SCRIPT_DEPTH(DrawObject);
>{
    pass DrawObject {
        AlphaBlendEnable = FALSE;
        AlphaTestEnable  = FALSE;
        VertexShader = compile vs_2_0 VS_Object();
        PixelShader  = compile ps_2_0 PS_Object(true, true);
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////

//地面影は描画しない
technique ShadowTec < string MMDPass = "shadow"; > { }

