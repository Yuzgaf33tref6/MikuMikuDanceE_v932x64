////////////////////////////////////////////////////////////////////////////////////////////////
//
//  Hologram_Mask2.fx  マスク画像作成，適用以外のモデルをを黒に
//  ( Hologram.fx から呼び出されます．オフスクリーン描画用)
//  作成: 針金P( 舞力介入P氏のfull.fx改変 )
//
////////////////////////////////////////////////////////////////////////////////////////////////

// 座標変換行列
float4x4 WorldViewProjMatrix : WORLDVIEWPROJECTION;

// マテリアル色
float4 MaterialDiffuse : DIFFUSE  < string Object = "Geometry"; >;

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


////////////////////////////////////////////////////////////////////////////////////////////////

// 頂点シェーダ
float4 VS_Mask(float4 Pos : POSITION) : POSITION
{
    // カメラ視点のワールドビュー射影変換
    return mul( Pos, WorldViewProjMatrix );
}

////////////////////////////////////////////////////////////////////////////////////////////////
// 輪郭描画

//ピクセルシェーダ
float4 PS_EdgeMask() : COLOR {
    return float4(0.0, 0.0, 0.0, 1.0);
}

//エッジ描画
technique EdgeTec < string MMDPass = "edge"; > {
    pass DrawMask {
        AlphaBlendEnable = FALSE;
        AlphaTestEnable  = FALSE;
        PixelShader = compile ps_2_0 PS_EdgeMask();
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////
// オブジェクト描画

//ピクセルシェーダ(透過も考慮)
float4 PS_ObjectMask(float2 Tex : TEXCOORD0, uniform bool useTexture) : COLOR
{
    float alpha = MaterialDiffuse.a;

    if ( useTexture ) {
        // テクスチャ透過値適用
        alpha *= tex2D( ObjTexSampler, Tex ).a;
    }

    return float4(alpha, alpha, alpha, 0.01); // 反転して積算合成するので
}

//セルフシャドウなし
technique Mask0 < string MMDPass = "object"; bool UseTexture = false; > {
    pass DrawMask {
        AlphaBlendEnable = TRUE;
        SrcBlend = ZERO;
        DestBlend = INVSRCCOLOR;
        VertexShader = compile vs_2_0 VS_Mask();
        PixelShader  = compile ps_2_0 PS_ObjectMask(false);
    }
}

technique Mask1 < string MMDPass = "object"; bool UseTexture = true; > {
    pass DrawMask {
        AlphaBlendEnable = TRUE;
        SrcBlend = ZERO;
        DestBlend = INVSRCCOLOR;
        VertexShader = compile vs_2_0 VS_Mask();
        PixelShader  = compile ps_2_0 PS_ObjectMask(true);
    }
}

//セルフシャドウあり
technique MaskSS0 < string MMDPass = "object_ss"; bool UseTexture = false; > {
    pass DrawMask {
        AlphaBlendEnable = TRUE;
        SrcBlend = ZERO;
        DestBlend = INVSRCCOLOR;
        VertexShader = compile vs_2_0 VS_Mask();
        PixelShader  = compile ps_2_0 PS_ObjectMask(false);
    }
}

technique MaskSS1 < string MMDPass = "object_ss"; bool UseTexture = true; > {
    pass DrawMask {
        AlphaBlendEnable = TRUE;
        SrcBlend = ZERO;
        DestBlend = INVSRCCOLOR;
        VertexShader = compile vs_2_0 VS_Mask();
        PixelShader  = compile ps_2_0 PS_ObjectMask(true);
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////

//地面影は描画しない
technique ShadowTec < string MMDPass = "shadow"; > { }

