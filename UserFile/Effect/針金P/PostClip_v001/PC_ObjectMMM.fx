////////////////////////////////////////////////////////////////////////////////////////////////
//
//  PC_ObjectMMM.fx モデルの形状をマスクするエフェクト
//  ( PostClip_Obj.fx から呼び出されます．オフスクリーン描画用)
//  (MikuMikuMoving対応版)
//  作成: 針金P
//
////////////////////////////////////////////////////////////////////////////////////////////////

// 座標変換パラメータ
float4x4 WorldMatrix    : WORLD;
float4x4 ViewMatrix     : VIEW;
float4x4 ProjMatrix     : PROJECTION;
float4x4 WorldViewMatrix : WORLDVIEW;
float4x4 ViewProjMatrix : VIEWPROJECTION;

//カメラ位置
float3 CameraPosition : POSITION  < string Object = "Camera"; >;

float4 EdgeColor : EDGECOLOR;
float  EdgeWidth : EDGEWIDTH;

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
// オブジェクト描画

struct VS_OUTPUT {
    float4 Pos  : POSITION;
    float2 Tex  : TEXCOORD0;
};

// 頂点シェーダ
VS_OUTPUT Object_VS(MMM_SKINNING_INPUT IN, uniform bool isObj)
{
    VS_OUTPUT Out = (VS_OUTPUT)0; 

    //================================================================================
    //MikuMikuMoving独自のスキニング関数(MMM_SkinnedPosition)。座標を取得する。
    //================================================================================
    MMM_SKINNING_OUTPUT SkinOut = MMM_SkinnedPositionNormal(IN.Pos, IN.Normal, IN.BlendWeight, IN.BlendIndices, IN.SdefC, IN.SdefR0, IN.SdefR1);

    float4 Pos = SkinOut.Position;

    // カメラ視点のワールドビュー射影変換
    if (MMM_IsDinamicProjection)
    {
        //if( !isObj ) {
        if( isObj ) {    // MMDPass="edge" が何故か呼び出されないのでobject側で描画
            float dist = length(CameraPosition - Pos.xyz);
            Pos += float4(SkinOut.Normal, 0) * IN.EdgeWeight * EdgeWidth * distance(Pos.xyz, CameraPosition) * MMM_GetDynamicFovEdgeRate(dist);
        }
        float4x4 wvpmat = mul(mul(WorldMatrix, ViewMatrix), MMM_DynamicFov(ProjMatrix, length(CameraPosition - Pos.xyz)));
        Out.Pos = mul( Pos, wvpmat );
    }
    else
    {
        //if( !isObj ) {
        if( isObj ) {    // MMDPass="edge" が何故か呼び出されないのでobject側で描画
            Pos += float4(SkinOut.Normal, 0) * IN.EdgeWeight * EdgeWidth * distance(Pos.xyz, CameraPosition);
        }
        float4x4 wvpmat = mul(WorldViewMatrix, ProjMatrix);
        Out.Pos = mul( Pos, wvpmat );
    }

    // テクスチャ座標
    Out.Tex = IN.Tex;

    return Out;
}

//ピクセルシェーダ(オブジェクト描画)
float4 PS_ObjectMask(VS_OUTPUT IN, uniform bool isObj, uniform bool useTexture) : COLOR
{
    float alpha;
    if( isObj ) {
        alpha = MaterialDiffuse.a;
        if ( useTexture ) {
            // テクスチャ透過値適用
            alpha *= tex2D( ObjTexSampler, IN.Tex ).a;
        }
    }else{
        alpha = EdgeColor.a;
    }

    clip(alpha - 0.005f);

    // クリップするところを白で塗り潰し
    return float4(1, 1, 1, 1);
}


///////////////////////////////////////////////////////////////////////////////////////
// テクニック

// エッジ描画
technique EdgeTec < string MMDPass = "edge"; > {
    pass DrawMask {
        AlphaBlendEnable = FALSE;
        AlphaTestEnable  = FALSE;
        VertexShader = compile vs_2_0 Object_VS(false);
        PixelShader = compile ps_2_0 PS_ObjectMask(false, false);
    }
}

// オブジェクト描画
technique Mask0 < string MMDPass = "object"; bool UseTexture = false; bool UseSelfShadow = false; > {
    pass DrawMask {
        AlphaBlendEnable = FALSE;
        AlphaTestEnable  = FALSE;
        VertexShader = compile vs_2_0 Object_VS(true);
        PixelShader = compile ps_2_0 PS_ObjectMask(true, false);
    }
}

technique Mask1 < string MMDPass = "object"; bool UseTexture = true; bool UseSelfShadow = false; > {
    pass DrawMask {
        AlphaBlendEnable = FALSE;
        AlphaTestEnable  = FALSE;
        VertexShader = compile vs_2_0 Object_VS(true);
        PixelShader = compile ps_2_0 PS_ObjectMask(true, true);
    }
}

technique MaskSS0 < string MMDPass = "object"; bool UseTexture = false; bool UseSelfShadow = true; > {
    pass DrawMask {
        AlphaBlendEnable = FALSE;
        AlphaTestEnable  = FALSE;
        VertexShader = compile vs_2_0 Object_VS(true);
        PixelShader = compile ps_2_0 PS_ObjectMask(true, false);
    }
}

technique MaskSS1 < string MMDPass = "object"; bool UseTexture = true; bool UseSelfShadow = true; > {
    pass DrawMask {
        AlphaBlendEnable = FALSE;
        AlphaTestEnable  = FALSE;
        VertexShader = compile vs_2_0 Object_VS(true);
        PixelShader = compile ps_2_0 PS_ObjectMask(true, true);
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////

// 地面影は描画しない
technique ShadowTec < string MMDPass = "shadow"; > { }

