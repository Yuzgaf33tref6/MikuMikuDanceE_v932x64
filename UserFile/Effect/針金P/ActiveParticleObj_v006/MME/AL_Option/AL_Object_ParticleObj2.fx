////////////////////////////////////////////////////////////////////////////////////////////////
//
// EmittionDraw for AutoLuminous4.fx
//    AutoLuminous対応モデルの発光部を描画します
//    ｢MMEffect｣→｢エフェクト割当｣のAL_EmitterRTタブからモデルを指定して、本エフェクトファイルを適用する
//
////////////////////////////////////////////////////////////////////////////////////////////////

// 以下Particle_Object.fxと同じ値を設定する必要あり
int RepertCount = 1000;  // モデル複製数(最大4096まで)

// 粒子オブジェクトID番号
#define  ObjectNo  2   // 0〜3以外で新たに粒子オブジェクトを増やす場合はファイル名変更とこの値を4,5,6･･と変えていく


//発光部分を少し前面に押し出す
// 0で無効、1で有効
#define POPUP_LIGHT 0

//テクスチャ高輝度識別フラグ
//#define TEXTURE_SELECTLIGHT

//テクスチャ高輝度識別閾値
float LightThreshold = 0.9;


// 解らない人はここから下はいじらないでね

////////////////////////////////////////////////////////////////////////////////////////////////

#define  WorldMatrixTexName(n)  ActiveParticle_WorldMatrixTex##n   // ワールド座標記録用テクスチャ名

#define SPECULAR_BASE 100
#define SYNC false

int RepertIndex;  // 複製モデルカウンタ

#define TEX_WIDTH_W   16  // 粒子ワールド座標テクスチャピクセル幅
#define TEX_HEIGHT  1024  // 粒子ワールド座標テクスチャピクセル高さ

// 座標変換行列
float4x4 WorldMatrix    : WORLD;
float4x4 ViewMatrix      : VIEW;
float4x4 ViewProjMatrix : VIEWPROJECTION;

// マテリアル色
float4   MaterialDiffuse   : DIFFUSE  < string Object = "Geometry"; >;
float3   MaterialAmbient   : AMBIENT  < string Object = "Geometry"; >;
float3   MaterialEmmisive  : EMISSIVE < string Object = "Geometry"; >;
float3   MaterialSpecular  : SPECULAR < string Object = "Geometry"; >;
float    SpecularPower     : SPECULARPOWER < string Object = "Geometry"; >;

bool use_toon;     //トゥーンの有無

#define PI 3.14159

float LightUp : CONTROLOBJECT < string name = "(self)"; string item = "LightUp"; >;
float LightUpE : CONTROLOBJECT < string name = "(self)"; string item = "LightUpE"; >;
float LightOff : CONTROLOBJECT < string name = "(self)"; string item = "LightOff"; >;
float Blink : CONTROLOBJECT < string name = "(self)"; string item = "LightBlink"; >;
float BlinkSq : CONTROLOBJECT < string name = "(self)"; string item = "LightBS"; >;
float BlinkDuty : CONTROLOBJECT < string name = "(self)"; string item = "LightDuty"; >;
float BlinkMin : CONTROLOBJECT < string name = "(self)"; string item = "LightMin"; >;
float LClockUp : CONTROLOBJECT < string name = "(self)"; string item = "LClockUp"; >;
float LClockDown : CONTROLOBJECT < string name = "(self)"; string item = "LClockDown"; >;

//時間
float ftime : TIME <bool SyncInEditMode = SYNC;>;

static float duty = (BlinkDuty <= 0) ? 0.5 : BlinkDuty;
static float timerate = ((Blink > 0) ? ((1 - cos(saturate(frac(ftime / (Blink * 10)) / (duty * 2)) * 2 * PI)) * 0.5) : 1.0)
                      * ((BlinkSq > 0) ? (frac(ftime / (BlinkSq * 10)) < duty) : 1.0);
static float timerate1 = timerate * (1 - BlinkMin) + BlinkMin;

static float ClockShift = (1 + LClockDown * 5) / (1 + LClockUp * 5);

static bool IsEmittion = (SPECULAR_BASE < SpecularPower)/* && (SpecularPower <= (SPECULAR_BASE + 100))*/ && (length(MaterialSpecular) < 0.01);
static float EmittionPower0 = IsEmittion ? ((SpecularPower - SPECULAR_BASE) / 7.0) : 1;
static float EmittionPower1 = EmittionPower0 * (LightUp * 2 + 1.0) * pow(400, LightUpE) * (1.0 - LightOff);

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

// スフィアマップのテクスチャ
texture ObjectSphereMap: MATERIALSPHEREMAP;
sampler ObjSphareSampler = sampler_state {
    texture = <ObjectSphereMap>;
    MINFILTER = POINT;
    MAGFILTER = POINT;
    MIPFILTER = NONE;
    AddressU  = CLAMP;
    AddressV = CLAMP;
};
sampler ObjSphareSampler2 = sampler_state {
    texture = <ObjectSphereMap>;
    MINFILTER = LINEAR;
    MAGFILTER = LINEAR;
    MIPFILTER = NONE;
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


///////////////////////////////////////////////////////////////////////////////////////////////

float texlight(float3 rgb){
    float val = saturate((length(rgb) - LightThreshold) * 3);
    
    val *= 0.2;
    
    return val;
}

///////////////////////////////////////////////////////////////////////////////////////////////

float3 HSV_to_RGB(float3 hsv){
    float H = frac(hsv.x);
    float S = hsv.y;
    float V = hsv.z;
    
    float3 Color = 0;
    
    float Hp3 = H * 6.0;
    float h = floor(Hp3);
    float P = V * (1 - S);
    float Q = V * (1 - S * (Hp3 - h));
    float T = V * (1 - S * (1 - (Hp3 - h)));
    
    /*if(h <= 0.01)      { Color.rgb = float3(V, T, P); }
    else if(h <= 1.01) { Color.rgb = float3(Q, V, P); }
    else if(h <= 2.01) { Color.rgb = float3(P, V, T); }
    else if(h <= 3.01) { Color.rgb = float3(P, Q, V); }
    else if(h <= 4.01) { Color.rgb = float3(T, P, V); }
    else               { Color.rgb = float3(V, P, Q); }*/
    
    Color.rgb += float3(V, T, P) * max(0, 1 - abs(h - 0));
    Color.rgb += float3(Q, V, P) * max(0, 1 - abs(h - 1));
    Color.rgb += float3(P, V, T) * max(0, 1 - abs(h - 2));
    Color.rgb += float3(P, Q, V) * max(0, 1 - abs(h - 3));
    Color.rgb += float3(T, P, V) * max(0, 1 - abs(h - 4));
    Color.rgb += float3(V, P, Q) * max(0, 1 - abs(h - 5));
    
    return Color;
}

///////////////////////////////////////////////////////////////////////////////////////////////
// 追加UVがAL用データかどうか判別

bool DecisionSystemCode(float4 SystemCode){
    bool val = (0.199 < SystemCode.r) && (SystemCode.r < 0.201)
            && (0.699 < SystemCode.g) && (SystemCode.g < 0.701);
    return val;
}


float4 getFlags(float flagcode){
    float4 val = frac(flagcode * float4(0.1, 0.01, 0.001, 0.0001));
    val = floor(val * 10 + 0.001);
    return val;
}


float2 DecisionSequenceCode(float4 color){
    bool val = (color.r > 0.99) && (abs(color.g - 0.5) < 0.02)
            && ((color.b < 0.01) || (color.g > 0.99));
    
    return float2(val, (color.b < 0.01));
}

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
    float4 Tex   : TEXCOORD0;   // テクスチャ
    float4 Color : COLOR0;      // ディフューズ色
};

// 頂点シェーダ
VS_OUTPUT VS_Basic(float4 Pos : POSITION, float3 Normal : NORMAL, float2 Tex : TEXCOORD0, 
                   float4 SystemCode : TEXCOORD1, float4 ColorCode : TEXCOORD2, float4 AppendCode : TEXCOORD3)
{
    VS_OUTPUT Out = (VS_OUTPUT)0;
    bool IsALCode = DecisionSystemCode(SystemCode);
    float4 flags = getFlags(SystemCode.w);

    // 素材モデルのワールド座標変換
    Pos.xyz += IsALCode * AppendCode.z * Normal;
    Pos = mul( Pos, WorldMatrix );

    // 複製モデルの配置座標変換
    float alpha;
    float4x4 TransMatrix = SetTransMatrix(alpha);
    Pos = mul( Pos, TransMatrix );

    // カメラ視点のビュー射影変換
    Out.Pos = mul( Pos, ViewProjMatrix );

    // セレクト色 計算
    Out.Color = MaterialDiffuse;
    Out.Color.rgb += MaterialEmmisive / 2;
    Out.Color.rgb *= 0.5;
    Out.Color.rgb = IsEmittion ? Out.Color.rgb : float3(0,0,0);

    // 頂点発光 ////////////////////////
    
    float3 UVColor = ColorCode.rgb;
    UVColor = lerp(UVColor, HSV_to_RGB(UVColor), flags.y);
    UVColor *= ColorCode.a;
    
    Out.Color.rgb += IsALCode ? UVColor : float3(0,0,0);
    
    float Tv = SystemCode.z * ClockShift;
    float Ph = AppendCode.y * ClockShift;
    float timerate2 = (Tv > 0) ? ((1 - cos(saturate(frac((ftime + Ph) / Tv) / (duty * 2)) * 2 * PI)) * 0.5)
                     : ((Tv < 0) ? (frac((ftime + Ph) / (-Tv / PI * 180)) < duty) : 1.0);
    Out.Color.rgb *= max(timerate2 * (1 - BlinkMin) + BlinkMin, !IsALCode);
    Out.Color.rgb *= max(timerate1, SystemCode.z != 0);
    Out.Color.a *= alpha;

    // テクスチャ座標
    Out.Tex.xy = Tex; //テクスチャUV
    Out.Tex.z = IsALCode * AppendCode.x;
    Out.Tex.w = IsALCode * flags.x;
    
    #if POPUP_LIGHT
        Out.Pos.z -= 0.01 * saturate(length(Out.Color.rgb));
    #endif
    
    return Out;
}

// ピクセルシェーダ
float4 PS_Basic(VS_OUTPUT IN, uniform bool useTexture, uniform bool useSphereMap) : COLOR0
{
    clip(IN.Color.a-0.001f);

    float4 Color = IN.Color;
    float4 texcolor;
    
    // 発光シーケンス ////////////////////////
    
    if(useSphereMap){
        //float4 spcolor1 = tex2Dlod(ObjSphareSampler, float4(1,0,0,0));
        float4 spcolor2 = tex2Dlod(ObjSphareSampler, float4(1,1,0,0));
        
        float4 spcolor3 = tex2Dlod(ObjSphareSampler, float4(0,1,0,0));
        
        float Ts = spcolor3.r * (255 * 60) + spcolor3.g * 255 + spcolor3.b * (255 / 100.0);
        Ts *= ClockShift;
        
        float t1 = frac((ftime/* + Ph * IsALCode*/) / Ts);
        float4 spcolor4 = tex2Dlod(ObjSphareSampler, float4(t1 * 0.25,0,0,0));
        float4 spcolor5 = tex2Dlod(ObjSphareSampler2, float4(t1 * 0.25,0,0,0));
        
        float2 sel = DecisionSequenceCode(spcolor2);
        
        Color.rgb *= lerp(float3(1,1,1), lerp(spcolor5.rgb, spcolor4.rgb, sel.y), sel.x);
        
    }
    
    
    if(useTexture){
        
        texcolor = tex2D(ObjTexSampler,IN.Tex.xy);
        texcolor.rgb = saturate(texcolor.rgb - IN.Tex.z);
        
        #ifdef TEXTURE_SELECTLIGHT
            Color = texcolor;
            Color.rgb *= texlight(Color.rgb);
        #else
            float4 Color2, Color3;
            
            Color2 = Color * texcolor;
            Color3 = Color * texcolor;
            Color3.rgb *= texlight(texcolor.rgb);
            
            Color = (IN.Tex.w < 0.1) ? Color2 : ((IN.Tex.w < 1.1) ? Color : Color3);
            
        #endif
        
    }
    
    Color.rgb *= lerp(EmittionPower0, EmittionPower1, (float)use_toon);
    
    return Color;
}


////////////////////////////////////////////////////////////////////////////////////////////////
//テクニック

//セルフシャドウなし
technique Select1 < string MMDPass = "object"; bool UseTexture = false; bool UseSphereMap = false; 
      string Script = "LoopByCount=RepertCount;" "LoopGetIndex=RepertIndex;" "Pass=DrawObject;" "LoopEnd=;"; >
{
    pass DrawObject {
        VertexShader = compile vs_3_0 VS_Basic();
        PixelShader  = compile ps_3_0 PS_Basic(false, false);
    }
}

technique Select2 < string MMDPass = "object"; bool UseTexture = true; bool UseSphereMap = false; 
      string Script = "LoopByCount=RepertCount;" "LoopGetIndex=RepertIndex;" "Pass=DrawObject;" "LoopEnd=;"; >
{
    pass DrawObject {
        VertexShader = compile vs_3_0 VS_Basic();
        PixelShader  = compile ps_3_0 PS_Basic(true, false);
    }
}

technique Select3 < string MMDPass = "object"; bool UseTexture = false; bool UseSphereMap = true; 
      string Script = "LoopByCount=RepertCount;" "LoopGetIndex=RepertIndex;" "Pass=DrawObject;" "LoopEnd=;"; >
{
    pass DrawObject {
        VertexShader = compile vs_3_0 VS_Basic();
        PixelShader  = compile ps_3_0 PS_Basic(false, true);
    }
}

technique Select4 < string MMDPass = "object"; bool UseTexture = true; bool UseSphereMap = true; 
      string Script = "LoopByCount=RepertCount;" "LoopGetIndex=RepertIndex;" "Pass=DrawObject;" "LoopEnd=;"; >
{
    pass DrawObject {
        VertexShader = compile vs_3_0 VS_Basic();
        PixelShader  = compile ps_3_0 PS_Basic(true, true);
    }
}

//セルフシャドウあり
technique Select1SS < string MMDPass = "object_ss"; bool UseTexture = false; bool UseSphereMap = false; 
      string Script = "LoopByCount=RepertCount;" "LoopGetIndex=RepertIndex;" "Pass=DrawObject;" "LoopEnd=;"; >
{
    pass DrawObject {
        VertexShader = compile vs_3_0 VS_Basic();
        PixelShader  = compile ps_3_0 PS_Basic(false, false);
    }
}

technique Select2SS < string MMDPass = "object_ss"; bool UseTexture = true; bool UseSphereMap = false; 
      string Script = "LoopByCount=RepertCount;" "LoopGetIndex=RepertIndex;" "Pass=DrawObject;" "LoopEnd=;"; >
{
    pass DrawObject {
        VertexShader = compile vs_3_0 VS_Basic();
        PixelShader  = compile ps_3_0 PS_Basic(true, false);
    }
}

technique Select3SS < string MMDPass = "object_ss"; bool UseTexture = false; bool UseSphereMap = true; 
      string Script = "LoopByCount=RepertCount;" "LoopGetIndex=RepertIndex;" "Pass=DrawObject;" "LoopEnd=;"; >
{
    pass DrawObject {
        VertexShader = compile vs_3_0 VS_Basic();
        PixelShader  = compile ps_3_0 PS_Basic(false, true);
    }
}

technique Select4SS < string MMDPass = "object_ss"; bool UseTexture = true; bool UseSphereMap = true; 
      string Script = "LoopByCount=RepertCount;" "LoopGetIndex=RepertIndex;" "Pass=DrawObject;" "LoopEnd=;"; >
{
    pass DrawObject {
        VertexShader = compile vs_3_0 VS_Basic();
        PixelShader  = compile ps_3_0 PS_Basic(true, true);
    }
}



//影や輪郭は描画しない
technique EdgeTec < string MMDPass = "edge"; > { }
technique ShadowTec < string MMDPass = "shadow"; > { }
technique ZplotTec < string MMDPass = "zplot"; > { }

