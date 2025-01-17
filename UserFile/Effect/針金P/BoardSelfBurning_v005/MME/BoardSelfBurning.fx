////////////////////////////////////////////////////////////////////////////////////////////////
//
//  BoardSelfBurning.fx ver0.0.5 モデルの形状に合わせてメラメラ炎を出すエフェクト
//  作成: 針金P
//
////////////////////////////////////////////////////////////////////////////////////////////////
// ここのパラメータを変更してください

#define FireColorTexFile   "palette1.png" // 炎色palletテクスチャファイル名

//メラメラ感を決めるパラメータ,ここを弄れば見た目が結構代わる。
float fireDisFactor = 0.07; 
float fireSizeFactor = 3.7; 
float fireShakeFactor = 0.4f;


float fireRiseFactor = 4.0;      // 炎の上昇度
float fireRadiateFactor = 1.0;   // 炎の拡がり度
float fireWvAmpFactor = 1.0;     // 炎の左右の揺らぎ振幅
float fireWvFreqFactor = 0.33;   // 炎の左右の揺らぎ周波数
float firePowAmpFactor = 0.07;   // 炎の明るさ揺らぎ振幅
float firePowFreqFactor = 5;     // 炎の明るさ揺らぎ周波数

float sourceGaussianStep = 1.5;  // モデル形状の基準ぼかし度(Ryで調整)
float sourceNoiseRate = 0.6;     // モデル形状のノイズ含み度(0〜1)

int FrameCount = 1; // 1フレームの炎テクスチャ更新数(60fpsで1, 30fpsで2ぐらいが多分ベスト)

#define ADD_FLG  1  // 0:半透明合成, 1:加算合成
#define TEX_WORK_SIZE  512 // 炎アニメーションの作業レイヤサイズ


// 解らない人はここから下はいじらないでね

////////////////////////////////////////////////////////////////////////////////////////////////
// パラメータ宣言

float Script : STANDARDSGLOBAL <
    string ScriptOutput = "color";
    string ScriptClass = "object";
    string ScriptOrder = "standard";
> = 0.8;

float4x4 WorldMatrix         : WORLD;
float4x4 ViewMatrix          : VIEW;
float4x4 ViewProjMatrix      : VIEWPROJECTION;
float4x4 WorldViewProjMatrix : WORLDVIEWPROJECTION;

float4x4 WorldViewMatrixInverse : WORLDVIEWINVERSE;
static float3x3 BillboardMatrix = {
    normalize(WorldViewMatrixInverse[0].xyz),
    normalize(WorldViewMatrixInverse[1].xyz),
    normalize(WorldViewMatrixInverse[2].xyz),
};

// カメラZ軸回転行列
float2 ViewportSize : VIEWPORTPIXELSIZE;
static float4 WPos = float4(WorldMatrix._41_42_43, 1);
static float4 pos0 = mul( WPos, ViewProjMatrix);
static float4 posY = mul( float4(WPos.x, WPos.y+1, WPos.z, 1), ViewProjMatrix);
static float2 rotVec0 = posY.xy/posY.w - pos0.xy/pos0.w;
static float2 rotVec = normalize( float2(rotVec0.x*ViewportSize.x/ViewportSize.y, rotVec0.y) );
static float3x3 RotMatrix = float3x3( rotVec.y, -rotVec.x, 0,
                                      rotVec.x,  rotVec.y, 0,
                                             0,         0, 1 );
static float3x3 RotMatrixInv = transpose( RotMatrix );
static float3x3 BillboardZRotMatrix = mul( RotMatrix, BillboardMatrix);

// 上下カメラアングルによる縮尺(適当)
float3 CameraDirection : DIRECTION < string Object = "Camera"; >;
static float absCosD = abs( dot(float3(0,1,0), -CameraDirection) );
static float yScale = 1.0f - 0.5f*smoothstep(0.7f, 1.0f, absCosD);

static float2 ViewportOffset = (float2(0.5,0.5)/ViewportSize);

float time : TIME;
float elapsed_time : ELAPSEDTIME;
static float Dt = clamp(elapsed_time, 0.001f, 0.1f);
static float fireShake = fireShakeFactor * FrameCount / (Dt * 60.0f);

float AcsSi : CONTROLOBJECT < string name = "(self)"; string item = "Si"; >;
float AcsTr : CONTROLOBJECT < string name = "(self)"; string item = "Tr"; >;
static float Scaling = AcsSi * 0.1f;

int RepertIndex;

// 作業レイヤサイズ
#define TEX_WORK_WIDTH  TEX_WORK_SIZE
#define TEX_WORK_HEIGHT TEX_WORK_SIZE

// 炎の火種となる範囲の描画先オフスクリーンバッファ
texture BSB_ObjectRT: OFFSCREENRENDERTARGET <
    string Description = "OffScreen RenderTarget for BoardSelfBurning.fx";
    int Width = TEX_WORK_WIDTH;
    int Height = TEX_WORK_HEIGHT;
    float4 ClearColor = { 0, 0, 0, 1 };
    float ClearDepth = 1.0;
    bool AntiAlias = false;
    string DefaultEffect = "*=hide;";
>;
sampler SourceMapSmp = sampler_state {
    texture = <BSB_ObjectRT>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = NONE;
    AddressU  = BORDER;
    AddressV = BORDER;
    BorderColor = 0;
};

// ボード前面でマスクする範囲の描画先オフスクリーンバッファ
texture BSB_MaskRT: OFFSCREENRENDERTARGET <
    string Description = "OffScreen RenderTarget for BoardSelfBurning.fx";
    float2 ViewPortRatio = {1.0,1.0};
    float4 ClearColor = { 1, 1, 1, 1 };
    float ClearDepth = 1.0;
    bool AntiAlias = true;
    string DefaultEffect = 
        "self = hide;"
        "BoardSelfBurning.x = hide;"
        "* = BSB_Mask.fx;" ;
>;
sampler MaskSmp = sampler_state {
    texture = <BSB_MaskRT>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = NONE;
    AddressU  = BORDER;
    AddressV = BORDER;
    BorderColor = 0;
};

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

// レンダリングターゲットのクリア値
float4 ClearColor = float4(1.0f, 1.0f, 1.0f, 0.0f);
float ClearDepth  = 1.0f;

// サンプリング間隔
float AcsRy: CONTROLOBJECT < string Name = "(self)"; string item = "Ry"; >;
static float srcSmpStep = sourceGaussianStep * max(degrees(AcsRy) + 1.0f, 0.0f);
static float2 SampStep = (float2(srcSmpStep, srcSmpStep) / Scaling / TEX_WORK_SIZE);

// X方向のぼかし結果を記録するためのレンダーターゲット
texture2D SourceMap1 : RENDERCOLORTARGET <
    int Width = TEX_WORK_WIDTH;
    int Height = TEX_WORK_HEIGHT;
    int MipLevels = 1;
    string Format = "A8R8G8B8" ;
>;
sampler2D SourceMapSmp1 = sampler_state {
    texture = <SourceMap1>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = NONE;
    AddressU  = CLAMP;
    AddressV = CLAMP;
};

texture2D DepthBuffer : RENDERDEPTHSTENCILTARGET <
    int Width = TEX_WORK_WIDTH;
    int Height = TEX_WORK_HEIGHT;
    string Format = "D24S8";
>;

// Y方向のぼかし結果を記録するためのレンダーターゲット
texture2D SourceMap2 : RENDERCOLORTARGET <
    int Width = TEX_WORK_WIDTH;
    int Height = TEX_WORK_HEIGHT;
    int MipLevels = 1;
    string Format = "A8R8G8B8" ;
>;
sampler2D SourceMapSmp2 = sampler_state {
    texture = <SourceMap2>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = NONE;
    AddressU  = CLAMP;
    AddressV = CLAMP;
};

// 炎色palletテクスチャ
texture2D FireColor <
    string ResourceName = FireColorTexFile; 
    int Miplevels = 1;
>;
sampler2D FireColorSamp = sampler_state {
    texture = <FireColor>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = NONE;
    AddressU  = CLAMP;
    AddressV = CLAMP;
};

// ノイズテクスチャ
texture2D NoiseSource <
    string ResourceName = "NoiseFreqSrc.png"; 
    int Miplevels = 1;
>;
sampler2D NoiseSourceSamp = sampler_state {
    texture = <NoiseSource>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = NONE;
    AddressU  = WRAP;
    AddressV = WRAP;
};

texture2D NoiseOne <
    string ResourceName = "NoiseFreq1.png"; 
    int Miplevels = 1;
>;
sampler2D NoiseOneSamp = sampler_state {
    texture = <NoiseOne>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = NONE;
    AddressU  = WRAP;
    AddressV = WRAP;
};

texture2D NoiseTwo <
    string ResourceName = "NoiseFreq2.png"; 
    int Miplevels = 1;
>;
sampler2D NoiseTwoSamp = sampler_state {
    texture = <NoiseTwo>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = NONE;
    AddressU  = WRAP;
    AddressV = WRAP;
};

// 炎アニメーション作業レイヤ
texture2D WorkLayer : RENDERCOLORTARGET <
    int Width = TEX_WORK_WIDTH;
    int Height = TEX_WORK_HEIGHT;
    int Miplevels = 1;
    string Format = "A8R8G8B8" ;
>;
sampler2D WorkLayerSamp = sampler_state {
    texture = <WorkLayer>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = NONE;
    AddressU  = CLAMP;
    AddressV = CLAMP;
};

// 1フレーム前の作業レイヤ
texture2D OldWorkLayer : RENDERCOLORTARGET <
    int Width = TEX_WORK_WIDTH;
    int Height = TEX_WORK_HEIGHT;
    int Miplevels = 1;
    string Format = "A8R8G8B8" ;
>;
sampler2D OldWorkLayerSamp = sampler_state {
    texture = <OldWorkLayer>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = NONE;
    AddressU  = CLAMP;
    AddressV = CLAMP;
};

// オブジェクトのワールド座標記録用
texture WorldCoord : RENDERCOLORTARGET <
    int Width=1;
    int Height=1;
    int Miplevels = 1;
    string Format="A32B32G32R32F";
>;
sampler WorldCoordSmp = sampler_state
{
    Texture = <WorldCoord>;
    MinFilter = NONE;
    MagFilter = NONE;
    MipFilter = NONE;
    AddressU  = CLAMP;
    AddressV  = CLAMP;
};
texture WorldCoordDepthBuffer : RenderDepthStencilTarget <
    int Width=1;
    int Height=1;
    string Format = "D24S8";
>;


struct VS_OUTPUT {
    float4 Pos : POSITION;
    float2 Tex : TEXCOORD0;
};

////////////////////////////////////////////////////////////////////////////////////////////////
// 背景移動アクセ関連

bool IsBack : CONTROLOBJECT < string name = "BackgroundControl.x"; >;
float4x4 BackMat : CONTROLOBJECT < string name = "BackgroundControl.x"; >;

// MMDワールド座標→背景アクセ基準のワールド座標
float3 BackWorldCoord(float3 pos)
{
    if( IsBack ){
        float scaling = 1.0f / length(BackMat._11_12_13);
        float3x3 mat3x3_inv = transpose((float3x3)BackMat) * scaling;
        pos = mul( float4(pos, 1), float4x4( mat3x3_inv[0], 0, 
                                             mat3x3_inv[1], 0, 
                                             mat3x3_inv[2], 0, 
                                            -mul(BackMat._41_42_43,mat3x3_inv), 1 ) ).xyz;
    }
    return pos;
}

////////////////////////////////////////////////////////////////////////////////////////////////
// ソースX方向ぼかし

VS_OUTPUT VS_GaussianX( float4 Pos : POSITION, float4 Tex : TEXCOORD0 )
{
    VS_OUTPUT Out = (VS_OUTPUT)0; 

    Out.Pos = Pos;
    Out.Tex = Tex + float2(0, 0.5f/TEX_WORK_HEIGHT);

    return Out;
}

float4 PS_GaussianX( float2 Tex: TEXCOORD0 ) : COLOR
{
    float4 Color;

    Color  = WT_0 *   tex2D( SourceMapSmp, Tex );
    Color += WT_1 * ( tex2D( SourceMapSmp, Tex+float2(SampStep.x  ,0) ) + tex2D( SourceMapSmp, Tex-float2(SampStep.x  ,0) ) );
    Color += WT_2 * ( tex2D( SourceMapSmp, Tex+float2(SampStep.x*2,0) ) + tex2D( SourceMapSmp, Tex-float2(SampStep.x*2,0) ) );
    Color += WT_3 * ( tex2D( SourceMapSmp, Tex+float2(SampStep.x*3,0) ) + tex2D( SourceMapSmp, Tex-float2(SampStep.x*3,0) ) );
    Color += WT_4 * ( tex2D( SourceMapSmp, Tex+float2(SampStep.x*4,0) ) + tex2D( SourceMapSmp, Tex-float2(SampStep.x*4,0) ) );
    Color += WT_5 * ( tex2D( SourceMapSmp, Tex+float2(SampStep.x*5,0) ) + tex2D( SourceMapSmp, Tex-float2(SampStep.x*5,0) ) );
    Color += WT_6 * ( tex2D( SourceMapSmp, Tex+float2(SampStep.x*6,0) ) + tex2D( SourceMapSmp, Tex-float2(SampStep.x*6,0) ) );
    Color += WT_7 * ( tex2D( SourceMapSmp, Tex+float2(SampStep.x*7,0) ) + tex2D( SourceMapSmp, Tex-float2(SampStep.x*7,0) ) );

    return Color;
}


////////////////////////////////////////////////////////////////////////////////////////////////
// ソースY方向ぼかし

VS_OUTPUT VS_GaussianY( float4 Pos : POSITION, float4 Tex : TEXCOORD0 )
{
    VS_OUTPUT Out = (VS_OUTPUT)0;

    Out.Pos = Pos;
    Out.Tex = Tex + float2(0.5f/TEX_WORK_WIDTH, 0);

    return Out;
}

float4 PS_GaussianY(float2 Tex: TEXCOORD0) : COLOR
{
    float4 Color;

    Color  = WT_0 *   tex2D( SourceMapSmp1, Tex );
    Color += WT_1 * ( tex2D( SourceMapSmp1, Tex+float2(0,SampStep.y  ) ) + tex2D( SourceMapSmp1, Tex-float2(0,SampStep.y  ) ) );
    Color += WT_2 * ( tex2D( SourceMapSmp1, Tex+float2(0,SampStep.y*2) ) + tex2D( SourceMapSmp1, Tex-float2(0,SampStep.y*2) ) );
    Color += WT_3 * ( tex2D( SourceMapSmp1, Tex+float2(0,SampStep.y*3) ) + tex2D( SourceMapSmp1, Tex-float2(0,SampStep.y*3) ) );
    Color += WT_4 * ( tex2D( SourceMapSmp1, Tex+float2(0,SampStep.y*4) ) + tex2D( SourceMapSmp1, Tex-float2(0,SampStep.y*4) ) );
    Color += WT_5 * ( tex2D( SourceMapSmp1, Tex+float2(0,SampStep.y*5) ) + tex2D( SourceMapSmp1, Tex-float2(0,SampStep.y*5) ) );
    Color += WT_6 * ( tex2D( SourceMapSmp1, Tex+float2(0,SampStep.y*6) ) + tex2D( SourceMapSmp1, Tex-float2(0,SampStep.y*6) ) );
    Color += WT_7 * ( tex2D( SourceMapSmp1, Tex+float2(0,SampStep.y*7) ) + tex2D( SourceMapSmp1, Tex-float2(0,SampStep.y*7) ) );

    // ぼかした後にノイズを入れる
    float2 texCoord1 = float2(Tex.x, Tex.y) * Scaling;
    texCoord1.y += time * 0.073f * fireRiseFactor;
    float2 texCoord2 = float2(Tex.x, Tex.y) * Scaling * 1.7f;
    texCoord2.y += time * 0.094f * fireRiseFactor;
    float tmp = tex2D(NoiseSourceSamp, texCoord1).r * tex2D(NoiseSourceSamp, texCoord2).r;
    Color.rgb *= lerp(1.0f, tmp, sourceNoiseRate)
                 * smoothstep(0.0f, 0.7f, tex2D(WorldCoordSmp, float2(0.5f, 0.5f)).w);

    return Color;
}


///////////////////////////////////////////////////////////////////////////////////////
// 炎アニメーションの描画

// 頂点シェーダ
VS_OUTPUT VS_FireAnimation( float4 Pos : POSITION, float4 Tex : TEXCOORD0 )
{
    VS_OUTPUT Out;

    Out.Pos = Pos;
    Out.Tex = Tex + float2(0.5f/TEX_WORK_WIDTH, 0.5f/TEX_WORK_HEIGHT);

    return Out;
}

// ピクセルシェーダ(作業レイヤのコピー)
float4 PS_CopyWorkLayer(float2 Tex: TEXCOORD0) : COLOR0
{
    return tex2D(WorkLayerSamp, Tex);
}


// ピクセルシェーダ
float4 PS_FireAnimation(float2 Tex: TEXCOORD0, uniform bool flag) : COLOR0
{
    float2 oldTex = Tex;

    // オブジェクト移動に伴うずらし
    float3 wPosNew = BackWorldCoord(WorldMatrix._41_42_43);
    float3 wPosOld = tex2D(WorldCoordSmp, float2(0.5f, 0.5f)).xyz;
    wPosNew = mul( wPosNew, (float3x3)ViewMatrix );
    wPosOld = mul( wPosOld, (float3x3)ViewMatrix );
    wPosNew = mul( wPosNew, RotMatrixInv );
    wPosOld = mul( wPosOld, RotMatrixInv );
    float2 moveVec = (wPosNew.xy - wPosOld.xy)/(60.0f * FrameCount * Scaling);
    moveVec.y = -moveVec.y;
    if(moveVec.y < 0) moveVec.y *= 0.5f;
    oldTex += moveVec;

    // 放射状に炎をずらす
    moveVec = float2(0.5f, 0.667f) - Tex;
    float radLen = length(moveVec) * 10000.0f;
    moveVec = normalize(moveVec) * fireRadiateFactor / max(radLen, 750.0f) / Scaling;
    oldTex += moveVec;

    // 上に炎をずらす ※参照位置を下にずらすと絵は上にずれる
    moveVec = float2( 0.5f/TEX_WORK_WIDTH * fireWvAmpFactor * (abs(frac(fireWvFreqFactor*time)*2.0f - 1.0f) - 0.5f) / Scaling,
                      0.5f/TEX_WORK_HEIGHT * fireRiseFactor / Scaling );
    moveVec.y *= yScale;
    oldTex += moveVec;

    float4 oldCol = tex2D(OldWorkLayerSamp, oldTex);

    float4 tmp = oldCol;
    if( flag ){
        // 作業レイヤに燃焼物を描画 ※前回の炎をずらした後に描画する事で燃焼物自体は、同じ位置に描画できる。
        tmp = max(oldCol, tex2D(SourceMapSmp2, Tex));
    }

    // ノイズの追加
    float2 noiseTex = Tex;
    noiseTex.y += time * fireShake / Scaling;
    tmp = saturate(tmp - fireDisFactor * tex2D(NoiseOneSamp, noiseTex * fireSizeFactor * Scaling));

    noiseTex = Tex;
    noiseTex.x += time * fireShake / Scaling;
    tmp = saturate(tmp - fireDisFactor * 0.5f * tex2D(NoiseTwoSamp, noiseTex * fireSizeFactor * Scaling));

    return float4(tmp.rgb, 1.0f);
}


////////////////////////////////////////////////////////////////////////////////////////////////
// オブジェクトのワールド座標記録

float4 VS_WorldCoord(float4 Pos : POSITION) : POSITION
{
   return Pos;
}

float4 PS_WorldCoord1() : COLOR
{
    float timer = max(tex2D(WorldCoordSmp, float2(0.5f, 0.5f)).w, 0.0f) + Dt;
    return float4(BackWorldCoord(WorldMatrix._41_42_43), timer);
}

float4 PS_WorldCoord2() : COLOR
{
    return float4(BackWorldCoord(WorldMatrix._41_42_43), 0.0f);
}


///////////////////////////////////////////////////////////////////////////////////////
// オブジェクト描画

struct VS_OUTPUT2 {
    float4 Pos  : POSITION;
    float2 Tex  : TEXCOORD0;
    float4 VPos : TEXCOORD1;
};

// 頂点シェーダ
VS_OUTPUT2 VS_Object( float4 Pos : POSITION, float4 Tex : TEXCOORD0 )
{
    VS_OUTPUT2 Out;

    // ビルボード+z軸回転
    Pos.xyz = mul( Pos.xyz, BillboardZRotMatrix );

    // ワールドビュー射影変換
    Out.Pos = mul( Pos, WorldViewProjMatrix );
    Out.VPos = Out.Pos;

    // テクスチャ座標
    Out.Tex = Tex;

    return Out;
}


// ピクセルシェーダ
float4  PS_Object(VS_OUTPUT2 IN) : COLOR0
{
    // スクリーンの座標
    IN.VPos.x = ( IN.VPos.x/IN.VPos.w + 1.0f ) * 0.5f + ViewportOffset.x;
    IN.VPos.y = 1.0f - (IN.VPos.y/IN.VPos.w + 1.0f ) * 0.5f + ViewportOffset.y;

    //float4 color = tex2D(SourceMapSmp, IN.Tex);
    //float4 color = tex2D(MaskSmp, IN.VPos.xy);
    //color.a = 0.8;
    //return color;

    // 炎の色
    float tmp = tex2D(WorkLayerSamp, IN.Tex).r;
    float4 FireCol = tex2D(FireColorSamp, saturate(float2(tmp, 0.5f)));

    // 炎の明るさの揺らぎ
    float s = 1.0f + firePowAmpFactor * (0.66f * sin(2.1f * time * firePowFreqFactor)
                                       + 0.33f * cos(3.3f * time * firePowFreqFactor) );
    // マスク処理
    #if ADD_FLG == 1
        FireCol.rgb *= 0.8f * s * AcsTr * tex2D(MaskSmp, IN.VPos.xy).r;
    #else
        FireCol.a *= tmp * 0.8f * s * AcsTr * tex2D(MaskSmp, IN.VPos.xy).r;
    #endif

    return FireCol;
}

///////////////////////////////////////////////////////////////////////////////////////
// テクニック

technique MainTec < string MMDPass = "object";
    string Script = 
        "RenderColorTarget0=SourceMap1;"
	    "RenderDepthStencilTarget=DepthBuffer;"
		"ClearSetColor=ClearColor;"
		"ClearSetDepth=ClearDepth;"
		"Clear=Color;"
		"Clear=Depth;"
	    "Pass=Gaussian_X;"
        "RenderColorTarget0=SourceMap2;"
	    "RenderDepthStencilTarget=DepthBuffer;"
		"ClearSetColor=ClearColor;"
		"ClearSetDepth=ClearDepth;"
		"Clear=Color;"
		"Clear=Depth;"
	    "Pass=Gaussian_Y;"

        "RenderColorTarget0=OldWorkLayer;"
            "RenderDepthStencilTarget=DepthBuffer;"
            "Pass=CopyWorkLayer;"
        "RenderColorTarget0=WorkLayer;"
            "RenderDepthStencilTarget=DepthBuffer;"
            "LoopByCount=FrameCount;"
                "LoopGetIndex=RepertIndex;"
                "Pass=FireAnimation;"
            "LoopEnd=;"
        "RenderColorTarget0=WorldCoord;"
            "RenderDepthStencilTarget=WorldCoordDepthBuffer;"
            "Pass=UpdateWorldCoord;"
        "RenderColorTarget0=;"
            "RenderDepthStencilTarget=;"
            "Pass=DrawObject;"
    ;
> {
    pass Gaussian_X < string Script= "Draw=Buffer;"; > {
        AlphaBlendEnable = FALSE;
        VertexShader = compile vs_2_0 VS_GaussianX();
        PixelShader  = compile ps_2_0 PS_GaussianX();
    }
    pass Gaussian_Y < string Script= "Draw=Buffer;"; > {
        AlphaBlendEnable = FALSE;
        VertexShader = compile vs_3_0 VS_GaussianY();
        PixelShader  = compile ps_3_0 PS_GaussianY();
    }

    pass CopyWorkLayer < string Script= "Draw=Buffer;"; > {
        ZWriteEnable = FALSE;
        ALPHABLENDENABLE = FALSE;
        VertexShader = compile vs_2_0 VS_FireAnimation();
        PixelShader  = compile ps_2_0 PS_CopyWorkLayer();
    }
    pass FireAnimation < string Script= "Draw=Buffer;"; > {
        ZWriteEnable = FALSE;
        ALPHABLENDENABLE = FALSE;
        VertexShader = compile vs_2_0 VS_FireAnimation();
        PixelShader  = compile ps_2_0 PS_FireAnimation(true);
    }
    pass UpdateWorldCoord < string Script= "Draw=Buffer;"; > {
        ALPHABLENDENABLE = FALSE;
        ALPHATESTENABLE = FALSE;
        VertexShader = compile vs_2_0 VS_WorldCoord();
        PixelShader  = compile ps_2_0 PS_WorldCoord1();
    }
    pass DrawObject {
        ZEnable = FALSE;
        #if ADD_FLG == 1
          DestBlend = ONE;
          SrcBlend = ONE;
        #else
          DestBlend = INVSRCALPHA;
          SrcBlend = SRCALPHA;
        #endif
        VertexShader = compile vs_2_0 VS_Object();
        PixelShader  = compile ps_2_0 PS_Object();
    }
}

technique MainTecSS < string MMDPass = "object_ss";
    string Script = 
        "RenderColorTarget0=OldWorkLayer;"
            "RenderDepthStencilTarget=DepthBuffer;"
            "Pass=CopyWorkLayer;"
        "RenderColorTarget0=WorkLayer;"
            "RenderDepthStencilTarget=DepthBuffer;"
            "LoopByCount=FrameCount;"
                "LoopGetIndex=RepertIndex;"
                "Pass=FireAnimation;"
            "LoopEnd=;"
        "RenderColorTarget0=WorldCoord;"
            "RenderDepthStencilTarget=WorldCoordDepthBuffer;"
            "Pass=UpdateWorldCoord;"
        "RenderColorTarget0=;"
            "RenderDepthStencilTarget=;"
            "Pass=DrawObject;"
    ;
> {
    pass CopyWorkLayer < string Script= "Draw=Buffer;"; > {
        ZWriteEnable = FALSE;
        ALPHABLENDENABLE = FALSE;
        VertexShader = compile vs_2_0 VS_FireAnimation();
        PixelShader  = compile ps_2_0 PS_CopyWorkLayer();
    }
    pass FireAnimation < string Script= "Draw=Buffer;"; > {
        ZWriteEnable = FALSE;
        VertexShader = compile vs_2_0 VS_FireAnimation();
        PixelShader  = compile ps_2_0 PS_FireAnimation(false);
    }
    pass UpdateWorldCoord < string Script= "Draw=Buffer;"; > {
        ALPHABLENDENABLE = FALSE;
        ALPHATESTENABLE = FALSE;
        VertexShader = compile vs_2_0 VS_WorldCoord();
        PixelShader  = compile ps_2_0 PS_WorldCoord2();
    }
    pass DrawObject {
        ZEnable = FALSE;
        #if ADD_FLG == 1
          DestBlend = ONE;
          SrcBlend = ONE;
        #else
          DestBlend = INVSRCALPHA;
          SrcBlend = SRCALPHA;
        #endif
        VertexShader = compile vs_2_0 VS_Object();
        PixelShader  = compile ps_2_0 PS_Object();
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////

// 地面影は表示しない
technique ShadowTec < string MMDPass = "shadow"; > { }
// MMD標準のセルフシャドウは表示しない
technique ZplotTec < string MMDPass = "zplot"; > { }

