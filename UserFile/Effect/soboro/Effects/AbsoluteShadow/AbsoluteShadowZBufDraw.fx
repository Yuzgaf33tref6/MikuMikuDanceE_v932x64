
#include "AbsoluteShadowCommonSystem.fx"

#define CULLING CCW

#define TEXSHADOW 1
const float ShadowAlphaThreshold = 0.7;

float4   MaterialDiffuse   : DIFFUSE  < string Object = "Geometry"; >;

// オブジェクトのテクスチャ
texture ObjectTexture: MATERIALTEXTURE;
sampler ObjTexSampler = sampler_state {
    texture = <ObjectTexture>;
    MINFILTER = LINEAR;
    MAGFILTER = LINEAR;
};

// MMD本来のsamplerを上書きしないための記述です。削除不可。
sampler MMDSamp0 : register(s0);
sampler MMDSamp1 : register(s1);
sampler MMDSamp2 : register(s2);



///////////////////////////////////////////////////////////////////////////////////////////////
// オブジェクト描画

struct VS_OUTPUT {
    float4 Pos : POSITION;              // 射影変換座標
    float4 ShadowMapTex : TEXCOORD1;    // Zバッファテクスチャ
    float2 Tex : TEXCOORD0;
};

// 頂点シェーダ
VS_OUTPUT Basic_VS(float4 Pos : POSITION, float3 Normal : NORMAL, float2 Tex : TEXCOORD0, uniform bool useTexture)
{
    VS_OUTPUT Out = (VS_OUTPUT)0;
    
    // ライトの目線によるワールドビュー射影変換をする
    Out.Pos = mul( Pos, LightWorldViewProjMatrix );
    
    //Out.Pos.z = saturate(Out.Pos.z / ZFar + 0.5);
    
    // テクスチャ座標を頂点に合わせる
    Out.ShadowMapTex = Out.Pos;
    
    Out.Tex = Tex;
    
    return Out;
}

// ピクセルシェーダ
float4 Basic_PS(VS_OUTPUT IN, uniform bool useTexture) : COLOR0
{
    float depth = IN.ShadowMapTex.z / IN.ShadowMapTex.w;
    float4 color;
    
    //r値にz、g値にz^2
    color = float4(depth, depth * depth, 0, 1);
    
    #if TEXSHADOW==1
        float alpha = MaterialDiffuse.a;
        if(useTexture) alpha *= tex2D(ObjTexSampler, IN.Tex).a;
        
        color.a = (alpha > ShadowAlphaThreshold);
        
    #endif
    
    //color = float4(0,0,0,1);
    
    return color;
    
}


// オブジェクト描画用テクニック
technique MainTec0 < string MMDPass = "object"; bool UseTexture = false; > {
    pass DrawObject {
        ALPHABLENDENABLE = false;
        CullMode = CULLING;
        VertexShader = compile vs_2_0 Basic_VS(false);
        PixelShader  = compile ps_2_0 Basic_PS(false);
    }
}

technique MainTec1 < string MMDPass = "object"; bool UseTexture = true; > {
    pass DrawObject {
        ALPHABLENDENABLE = false;
        CullMode = CULLING;
        VertexShader = compile vs_2_0 Basic_VS(true);
        PixelShader  = compile ps_2_0 Basic_PS(true);
    }
}

technique MainTec0SS < string MMDPass = "object_ss"; bool UseTexture = false; > {
    pass DrawObject {
        ALPHABLENDENABLE = false;
        CullMode = CULLING;
        VertexShader = compile vs_2_0 Basic_VS(false);
        PixelShader  = compile ps_2_0 Basic_PS(false);
    }
}

technique MainTec1SS < string MMDPass = "object_ss"; bool UseTexture = true; > {
    pass DrawObject {
        ALPHABLENDENABLE = false;
        CullMode = CULLING;
        VertexShader = compile vs_2_0 Basic_VS(true);
        PixelShader  = compile ps_2_0 Basic_PS(true);
    }
}


////////////////////////////////////////////////////////////////////////////////////////////

// 輪郭は表示しない
technique EdgeTec < string MMDPass = "edge"; > { }
// 地面影は表示しない
technique ShadowTec < string MMDPass = "shadow"; > { }
// MMD標準のセルフシャドウは表示しない
technique ZplotTec < string MMDPass = "zplot"; > { }

