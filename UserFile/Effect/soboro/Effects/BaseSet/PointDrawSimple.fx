////////////////////////////////////////////////////////////////////////////////////////////////
// パラメータ宣言

float4 DrawColor = float4(0, 0.9, 0.5, 0.5);



// 座法変換行列
float4x4 WorldViewProjMatrix      : WORLDVIEWPROJECTION;

///////////////////////////////////////////////////////////////////////////////////////////////
// オブジェクト描画

struct VS_OUTPUT
{
    float4 Pos        : POSITION;    // 射影変換座標
};

// 頂点シェーダ
VS_OUTPUT Basic_VS(float4 Pos : POSITION)
{
    VS_OUTPUT Out;
    Out.Pos = mul( Pos, WorldViewProjMatrix );
    
    return Out;
}

// ピクセルシェーダ
float4 Basic_PS() : COLOR0
{
    return DrawColor;
}

// オブジェクト描画用テクニック
technique MainTec < string MMDPass = "object"; > {
    pass DrawObject {
        FillMode = POINT;
        VertexShader = compile vs_2_0 Basic_VS();
        PixelShader  = compile ps_2_0 Basic_PS();
    }
}

// オブジェクト描画用テクニック
technique MainTecSS < string MMDPass = "object_ss"; > {
    pass DrawObject {
        FillMode = POINT;
        VertexShader = compile vs_2_0 Basic_VS();
        PixelShader  = compile ps_2_0 Basic_PS();
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////
// 輪郭描画

// 輪郭なし
technique EdgeTec < string MMDPass = "edge"; > {
    
}

///////////////////////////////////////////////////////////////////////////////////////////////
// 影（非セルフシャドウ）描画

// 影なし
technique ShadowTec < string MMDPass = "shadow"; > {
    
}

///////////////////////////////////////////////////////////////////////////////////////////////
// セルフシャドウ用Z値プロット

// セルフシャドウなし
technique ZplotTec < string MMDPass = "zplot"; > {
    
}

///////////////////////////////////////////////////////////////////////////////////////////////
