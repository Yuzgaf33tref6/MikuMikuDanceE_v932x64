////////////////////////////////////////////////////////////////////////////////////////////////
//
// Material Selector for ObjectLuminous & AutoLuminous
//    発光させるオブジェクトを、元の素材の色及び発光色で描画します
//    ｢MMEffect｣→｢エフェクト割当｣のOL_EmitterRT(CL_EmitterRT) or AL_EmitterRTタブから、
//       下の発光させる材質番号を指定してモデルに適用する
//       あるいは、サブセット展開して指定する材質に適用します
//
////////////////////////////////////////////////////////////////////////////////////////////////

// 発光させる材質番号
#define TargetSubset "0-"

// ゲイン(発光強度)
float Gain = 1.0;

// 発光色(RGB各要素,加算されます)
float3 Emittion_Color = { 0.0, 0.0, 0.0 };

// 以下Particle_Object.fxと同じ値を設定する必要あり
int RepertCount = 1000;  // モデル複製数(最大4096まで)

// 粒子オブジェクトID番号
#define  ObjectNo  1   // 0〜3以外で新たに粒子オブジェクトを増やす場合はファイル名変更とこの値を4,5,6･･と変えていく


// 解らない人はここから下はいじらないでね

////////////////////////////////////////////////////////////////////////////////////////////////

#define  WorldMatrixTexName(n)  ActiveParticle_WorldMatrixTex##n   // ワールド座標記録用テクスチャ名

int RepertIndex;  // 複製モデルカウンタ

#define TEX_WIDTH_W   16  // 粒子ワールド座標テクスチャピクセル幅
#define TEX_HEIGHT  1024  // 粒子ワールド座標テクスチャピクセル高さ

// 座標変換行列
float4x4 WorldMatrix    : WORLD;
float4x4 ViewMatrix      : VIEW;
float4x4 ViewProjMatrix : VIEWPROJECTION;

// マテリアル色
float4   MaterialDiffuse   : DIFFUSE  < string Object = "Geometry"; >;
float3   MaterialEmmisive  : EMISSIVE < string Object = "Geometry"; >;

bool use_texture;    //テクスチャの有無
bool use_spheremap;  //テクスチャの有無
bool spadd;    // スフィアマップ加算合成フラグ

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

// オブジェクトのスフィアマップテクスチャ。
texture ObjectSphereMap : MATERIALSPHEREMAP;
sampler ObjSphareSampler = sampler_state
{
    texture = <ObjectSphereMap>;
    MINFILTER = LINEAR;
    MAGFILTER = LINEAR;
    MIPFILTER = LINEAR;
    AddressU  = CLAMP;
    AddressV = CLAMP;
};

// 粒子のワールド変換行列が記録されているテクスチャ
shared texture WorldMatrixTexName(ObjectNo) : RenderColorTarget;
sampler ActiveParticle_SmpWldMat : register(s3) = sampler_state
{
   Texture = <WorldMatrixTexName(ObjectNo)>;
   ADDRESSU = CLAMP;
   ADDRESSV = CLAMP;
   MAGFILTER = NONE;
   MINFILTER = NONE;
   MIPFILTER = NONE;
};


////////////////////////////////////////////////////////////////////////////////////////////////
// モデルの配置変換行列(配置後のワールド変換行列)
float4x4 SetTransMatrix(out float alpha)
{
    int i = (RepertIndex / TEX_HEIGHT) * 4;
    int j = RepertIndex % TEX_HEIGHT;
    float y = (j+0.5f)/TEX_HEIGHT;

    // モデルの配置変換行列
    float4x4 TrMat = float4x4( tex2Dlod(ActiveParticle_SmpWldMat, float4((i+0.5f)/TEX_WIDTH_W, y, 0, 0)), 
                               tex2Dlod(ActiveParticle_SmpWldMat, float4((i+1.5f)/TEX_WIDTH_W, y, 0, 0)), 
                               tex2Dlod(ActiveParticle_SmpWldMat, float4((i+2.5f)/TEX_WIDTH_W, y, 0, 0)), 
                               tex2Dlod(ActiveParticle_SmpWldMat, float4((i+3.5f)/TEX_WIDTH_W, y, 0, 0)) );

    alpha = TrMat._44;
    TrMat._44 = 1.0f;

    return TrMat;
}

///////////////////////////////////////////////////////////////////////////////////////////////
// オブジェクト描画

struct VS_OUTPUT {
    float4 Pos   : POSITION;
    float2 Tex   : TEXCOORD0;   // テクスチャ
    float2 SpTex : TEXCOORD1;   // スフィアマップテクスチャ座標
    float4 Color : COLOR0;      // ディフューズ色
};

// 頂点シェーダ
VS_OUTPUT VS_Selected(float4 Pos : POSITION, float3 Normal : NORMAL, float2 Tex : TEXCOORD0)
{
    VS_OUTPUT Out = (VS_OUTPUT)0;

    // 素材モデルのワールド座標変換
    Pos = mul( Pos, WorldMatrix );

    // 複製モデルの配置座標変換
    float alpha;
    float4x4 TransMatrix = SetTransMatrix(alpha);
    Pos = mul( Pos, TransMatrix );

    // カメラ視点のビュー射影変換
    Out.Pos = mul( Pos, ViewProjMatrix );

    // ディフューズ色＋アンビエント色 計算
    Out.Color = MaterialDiffuse;
    Out.Color.rgb += MaterialEmmisive / 2;
    Out.Color.rgb *= 0.5;
    Out.Color.a *= alpha;

    // テクスチャ座標
    Out.Tex = Tex;

    // スフィアマップテクスチャ座標
    Normal = normalize( mul( Normal, (float3x3)WorldMatrix ) );
    float2 NormalWV = mul( Normal, (float3x3)ViewMatrix );
    Out.SpTex.x = NormalWV.x * 0.5f + 0.5f;
    Out.SpTex.y = NormalWV.y * -0.5f + 0.5f;

    return Out;
}

// ピクセルシェーダ
float4 PS_Selected(VS_OUTPUT IN) : COLOR0
{
    clip(IN.Color.a-0.001f);

    float4 Color = IN.Color;
    if ( use_texture ) {
        // テクスチャ適用
        Color.a *= tex2D( ObjTexSampler, IN.Tex ).a;
    }
    if ( use_spheremap ) {
        // スフィアマップ適用
        if(spadd) Color.rgb += tex2D(ObjSphareSampler,IN.SpTex).rgb;
        else      Color.rgb *= tex2D(ObjSphareSampler,IN.SpTex).rgb;
    }
    //発光色
    Color.rgb += Emittion_Color;
    Color.rgb *= (Gain * Color.a);

    return Color;
}

float4 PS_Black(VS_OUTPUT IN) : COLOR
{
    clip(IN.Color.a-0.001f);

    float alpha = IN.Color.a;
    if ( use_texture ) alpha *= tex2D( ObjTexSampler, IN.Tex ).a;
    return float4(0.0, 0.0, 0.0, alpha);
}


////////////////////////////////////////////////////////////////////////////////////////////////
//テクニック

//セルフシャドウなし
technique Select1 < string MMDPass = "object"; string Subset = TargetSubset;
                    string Script = "LoopByCount=RepertCount;" "LoopGetIndex=RepertIndex;" "Pass=Single_Pass;" "LoopEnd=;"; >
{
    pass Single_Pass {
        CullMode = NONE;
        VertexShader = compile vs_3_0 VS_Selected();
        PixelShader  = compile ps_3_0 PS_Selected();
    }
}

technique Mask < string MMDPass = "object"; >
{
    pass Single_Pass {
        VertexShader = compile vs_3_0 VS_Selected();
        PixelShader  = compile ps_3_0 PS_Black();
    }
}

//セルフシャドウあり
technique Select1SS < string MMDPass = "object_ss"; string Subset = TargetSubset;
                    string Script = "LoopByCount=RepertCount;" "LoopGetIndex=RepertIndex;" "Pass=Single_Pass;" "LoopEnd=;"; >
{
    pass Single_Pass {
        VertexShader = compile vs_3_0 VS_Selected();
        PixelShader  = compile ps_3_0 PS_Selected();
    }
}

technique MaskSS < string MMDPass = "object_ss"; >
{
    pass Single_Pass {
        VertexShader = compile vs_3_0 VS_Selected();
        PixelShader  = compile ps_3_0 PS_Black();
    }
}



//影や輪郭は描画しない
technique EdgeTec < string MMDPass = "edge"; > { }
technique ShadowTec < string MMDPass = "shadow"; > { }
technique ZplotTec < string MMDPass = "zplot"; > { }

