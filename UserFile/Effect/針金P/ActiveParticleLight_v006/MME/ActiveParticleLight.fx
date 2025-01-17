////////////////////////////////////////////////////////////////////////////////////////////////
//
//  ActiveParticleLight.fx ver0.0.6 オブジェクトの移動に応じてキラキラ粒子を放出します
//  作成: 針金P
//
////////////////////////////////////////////////////////////////////////////////////////////////
// ここのパラメータを変更してください

// 粒子数設定
#define UNIT_COUNT   4   // ←この数×1024 が一度に描画出来る粒子の数になる(整数値で指定すること)

// キラキラ描画の方法
#define LIGHT_TYPE   1   // 1：新方式のキラキラ描画, 0：旧バージョン(v0.0.4以前)のキラキラ描画

// 粒子パラメータ設定
float3 ParticleColor = {1.0, 0.8, 0.7}; // 粒子の色(RBG)
float ParticleRandamColor = 0.6;   // 粒子色のばらつき度(0.0〜1.0)
float ParticleSize = 1.8;          // 粒子大きさ
float ParticleRandamSize = 0.5;    // 粒子サイズばらつき度(0.0〜1.0)
float ParticleSpeedMax = 2.5;      // 粒子初期最大スピード
float ParticleSpeedMin = 1.0;      // 粒子初期最小スピード
float ParticleRotSpeed = 0.5;      // 粒子回転速度
float ParticleInitPos = 0.5;       // 粒子発生時の相対位置(大きくすると粒子の配置がばらつきます)
float ParticleLife = 3.0;          // 粒子の寿命(秒)
float ParticleDecrement = 0.5;     // 粒子が消失を開始する時間(ParticleLifeとの比)
float OccurFactor = 1.2;           // オブジェクト移動量に対する粒子発生度(大きくすると粒子が出やすくなる)
float ObjVelocityRate = 1.0;       // オブジェクト移動方向に対する粒子速度依存度

// キラキラ描画パラメータ設定
int GlareCount = 2;                // 主光芒の数(この数の2倍が実際の光芒数, LIGHT_TYPE=0の時は2にする)
float LightCenter = 0.2;           // 光粒子中央部の大きさ(主光芒長さとの比)
float LightPower = 1.0;            // 光粒子の輝き強度
float LightAmp = 1.0;              // 光粒子瞬き振幅
float LightFreq = 1.0;             // 光粒子瞬き周波数
#if LIGHT_TYPE==1  // ↓LIGHT_TYPE=1の時のみ設定する
int SubGlareCount = 8;             // 副光芒の数(主光芒の間の短い光芒の数)
float GlareThick = 1.5;            // 主光芒の太さ
float SubGlareThick = 1.0;         // 副光芒の太さ
float SubGlareLength = 0.3;        // 副光芒の長さ(主光芒長さとの比)
#endif

// 物理パラメータ設定
float3 GravFactor = {0.0, 0.0, 0.0};   // 重力定数
float ResistFactor = 0.0;              // 速度抵抗係数

// (風等の)空間の流速場を定義する関数
// 粒子位置ParticlePosにおける空気の流れを記述します。
// 戻り値が0以外の時はオブジェクトが動かなくても粒子を放出します。
// 速度抵抗係数がResistFactor>0でないと粒子の動きに影響を与えません。
float3 VelocityField(float3 ParticlePos)
{
   float3 vel = float3( 0.0, 0.0, 0.0 );
   return vel;
}

// オプションのコントロールファイル名
#define BackgroundCtrlFileName  "BackgroundControl.x" // 背景座標コントロールファイル名
#define SmoothCtrlFileName      "SmoothControl.x"     // 接地面スムージングコントロールファイル名
#define TimrCtrlFileName        "TimeControl.x"       // 時間制御コントロールファイル名


// 解らない人はここから下はいじらないでね

////////////////////////////////////////////////////////////////////////////////////////////////
// パラメータ宣言
#define ArrangeFileName "Arrange.pfm" // 配置･乱数情報ファイル名
#define TEX_WIDTH_A  4            // 配置･乱数情報テクスチャピクセル幅
#define TEX_WIDTH    UNIT_COUNT   // テクスチャピクセル幅
#define TEX_HEIGHT   1024         // テクスチャピクセル高さ

#define TEX_WORK_SIZE  512 // キラキラ粒子テクスチャ作成の作業レイヤサイズ

#define PAI 3.14159265f   // π

float AcsTr  : CONTROLOBJECT < string name = "(self)"; string item = "Tr"; >;
float AcsSi  : CONTROLOBJECT < string name = "(self)"; string item = "Si"; >;

int RepertCount = UNIT_COUNT;  // シェーダ内描画反復回数
int RepertIndex;               // 複製モデルカウンタ
int GlareIndex;                // 主光芒描画インデックス
int SubGlareIndex;             // 副光芒描画インデックス

// オプションのコントロールパラメータ
bool IsBack : CONTROLOBJECT < string name = BackgroundCtrlFileName; >;
float4x4 BackMat : CONTROLOBJECT < string name = BackgroundCtrlFileName; >;

bool IsSmooth : CONTROLOBJECT < string name = SmoothCtrlFileName; >;
float SmoothSi : CONTROLOBJECT < string name = SmoothCtrlFileName; string item = "Si"; >;
float4x4 SmoothMat : CONTROLOBJECT < string name = SmoothCtrlFileName; >;
static float3 SmoothPos = SmoothMat._41_42_43;
static float3 SmoothNormal = normalize(SmoothMat._21_22_23);

bool IsTimeCtrl : CONTROLOBJECT < string name = TimrCtrlFileName; >;
float TimeSi : CONTROLOBJECT < string name = TimrCtrlFileName; string item = "Si"; >;
float TimeTr : CONTROLOBJECT < string name = TimrCtrlFileName; string item = "Tr"; >;
static bool TimeSync = IsTimeCtrl ? ((TimeSi>0.001f) ? true : false) : true;
static float TimeRate = IsTimeCtrl ? TimeTr : 1.0f;
static float TimeScale = IsTimeCtrl ? 1.0f/max(TimeRate, 0.01) : 1.0f;

// 時間設定
float time1 : TIME;
float time2 : TIME < bool SyncInEditMode = true; >;
static float time = TimeSync ? time1 : time2;
float elapsed_time : ELAPSEDTIME;
float elapsed_time2 : ELAPSEDTIME < bool SyncInEditMode = true; >;
static float Dt = (TimeSync ? clamp(elapsed_time, 0.001f, 0.1f) : clamp(elapsed_time2, 0.0f, 0.1f)) * TimeRate;

// 座標変換行列
float4x4 WorldMatrix          : WORLD;
float4x4 ViewProjMatrix       : VIEWPROJECTION;
float4x4 ViewMatrixInverse    : VIEWINVERSE;

static float3x3 BillboardMatrix = {
    normalize(ViewMatrixInverse[0].xyz),
    normalize(ViewMatrixInverse[1].xyz),
    normalize(ViewMatrixInverse[2].xyz),
};

// オブジェクトに貼り付けるテクスチャ
#if LIGHT_TYPE==1
texture2D ParticleTex1 <
    string ResourceName = "Particle1.png";
>;
sampler ParticleSamp1 = sampler_state {
    texture = <ParticleTex1>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = NONE;
    AddressU  = CLAMP;
    AddressV  = CLAMP;
};

texture2D ParticleTex2 <
    string ResourceName = "Particle2.png";
>;
sampler ParticleSamp2 = sampler_state {
    texture = <ParticleTex2>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = NONE;
    AddressU  = CLAMP;
    AddressV  = CLAMP;
};
#else
texture2D ParticleTex1 <
    string ResourceName = "Particle2.png";
>;
sampler ParticleSamp1 = sampler_state {
    texture = <ParticleTex1>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = NONE;
    AddressU  = CLAMP;
    AddressV  = CLAMP;
};

texture2D ParticleTex2 <
    string ResourceName = "Particle3.png";
>;
sampler ParticleSamp2 = sampler_state {
    texture = <ParticleTex2>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = NONE;
    AddressU  = CLAMP;
    AddressV  = CLAMP;
};
#endif

// 配置･乱数情報テクスチャ
texture2D ArrangeTex <
    string ResourceName = ArrangeFileName;
>;
sampler ArrangeSmp : register(s1) = sampler_state{
    texture = <ArrangeTex>;
    MinFilter = POINT;
    MagFilter = POINT;
    MipFilter = NONE;
};

// 粒子座標記録用
texture CoordTex : RENDERCOLORTARGET
<
   int Width=TEX_WIDTH;
   int Height=TEX_HEIGHT;
   string Format="A32B32G32R32F";
>;
sampler CoordSmp : register(s2) = sampler_state
{
   Texture = <CoordTex>;
    AddressU  = CLAMP;
    AddressV = CLAMP;
    MinFilter = NONE;
    MagFilter = NONE;
    MipFilter = NONE;
};
texture CoordDepthBuffer : RenderDepthStencilTarget <
   int Width=TEX_WIDTH;
   int Height=TEX_HEIGHT;
   string Format = "D24S8";
>;

// 粒子速度記録用
texture VelocityTex : RENDERCOLORTARGET
<
   int Width=TEX_WIDTH;
   int Height=TEX_HEIGHT;
   string Format="A32B32G32R32F";
>;
sampler VelocitySmp = sampler_state
{
   Texture = <VelocityTex>;
    AddressU  = CLAMP;
    AddressV = CLAMP;
    MinFilter = NONE;
    MagFilter = NONE;
    MipFilter = NONE;
};

// オブジェクトのワールド座標記録用
texture WorldCoord : RENDERCOLORTARGET
<
   int Width=2;
   int Height=1;
   string Format="A32B32G32R32F";
>;
sampler WorldCoordSmp : register(s3) = sampler_state
{
   Texture = <WorldCoord>;
   AddressU  = CLAMP;
   AddressV = CLAMP;
   MinFilter = NONE;
   MagFilter = NONE;
   MipFilter = NONE;
};
texture WorldCoordDepthBuffer : RenderDepthStencilTarget <
   int Width=2;
   int Height=1;
    string Format = "D24S8";
>;

// 作業レイヤサイズ
#define TEX_WORK_WIDTH  TEX_WORK_SIZE
#define TEX_WORK_HEIGHT TEX_WORK_SIZE

// キラキラ粒子テクスチャ作成の作業レイヤ
texture2D WorkLayer : RENDERCOLORTARGET <
    int Width = TEX_WORK_WIDTH;
    int Height = TEX_WORK_HEIGHT;
    int Miplevels = 0;
    string Format = "A8R8G8B8" ;
>;
sampler2D WorkLayerSamp = sampler_state {
    texture = <WorkLayer>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = LINEAR;
    AddressU  = CLAMP;
    AddressV = CLAMP;
};
texture2D WorkDepthBuffer : RENDERDEPTHSTENCILTARGET <
    int Width = TEX_WORK_WIDTH;
    int Height = TEX_WORK_HEIGHT;
    string Format = "D24S8";
>;

// レンダリングターゲットのクリア値
float4 ClearColor = float4(0.0f, 0.0f, 0.0f, 1.0f);
float ClearDepth  = 1.0f;


////////////////////////////////////////////////////////////////////////////////////////////////
// 配置･乱数情報テクスチャからデータを取り出す
float3 Color2Float(int index, int item)
{
    return tex2D(ArrangeSmp, float2((item+0.5f)/TEX_WIDTH_A, (index+0.5f)/TEX_HEIGHT)).xyz;
}

////////////////////////////////////////////////////////////////////////////////////////////////

// 座標の2D回転
float2 Rotation2D(float2 pos, float rot)
{
    float x = pos.x * cos(rot) - pos.y * sin(rot);
    float y = pos.x * sin(rot) + pos.y * cos(rot);

    return float2(x,y);
}

// 背景アクセ基準のワールド座標→MMDワールド座標
float3 InvBackWorldCoord(float3 pos)
{
    if( IsBack ){
        float scaling = 1.0f / length(BackMat._11_12_13);
        pos = mul( float4(pos, 1), float4x4( BackMat[0]*scaling,
                                             BackMat[1]*scaling,
                                             BackMat[2]*scaling,
                                             BackMat[3] )      ).xyz;
    }
    return pos;
}

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

struct VS_OUTPUT {
   float4 Pos  : POSITION;
   float2 Tex  : TEXCOORD0;
};

// 共通の頂点シェーダ
VS_OUTPUT Common_VS(float4 Pos: POSITION, float2 Tex: TEXCOORD)
{
   VS_OUTPUT Out;
   Out.Pos = Pos;
   Out.Tex = Tex + float2(0.5f/TEX_WIDTH, 0.5f/TEX_HEIGHT);
   return Out;
}


////////////////////////////////////////////////////////////////////////////////////////
// 粒子の発生・座標更新計算(xyz:座標,w:経過時間+1sec,wは更新時に1に初期化されるため+1sからスタート)

float4 UpdatePos_PS(float2 Tex: TEXCOORD0) : COLOR
{
   // 粒子の座標
   float4 Pos = tex2D(CoordSmp, Tex);

   // 粒子の速度
   float3 Vel = tex2D(VelocitySmp, Tex).xyz;

   if(Pos.w < 1.001f){
   // 未発生粒子の中から移動距離に応じて新たに粒子を発生させる
      // 現在のオブジェクト座標
      float3 WPos1 = BackWorldCoord(WorldMatrix._41_42_43);

      // 1フレーム前のオブジェクト座標
      float4 WPos0 = tex2D(WorldCoordSmp, float2(0.25f, 0.5f));
      WPos0.xyz -= VelocityField(WPos1) * Dt; // 流体速度場位置補正

      // 1フレーム間の発生粒子数
      float p_count = length( WPos1 - WPos0.xyz ) * OccurFactor * AcsSi*0.1f;

      // 粒子インデックス
      int i = floor( Tex.x*TEX_WIDTH );
      int j = floor( Tex.y*TEX_HEIGHT );
      float p_index = float( i*TEX_HEIGHT + j );

      // 新たに粒子を発生させるかどうかの判定
      if(p_index < WPos0.w) p_index += float(TEX_WIDTH*TEX_HEIGHT);
      if(p_index < WPos0.w+p_count){
         // 粒子発生座標
         float s = (p_index - WPos0.w) / p_count;
         float aveSpeed = (ParticleSpeedMin + ParticleSpeedMax) * 0.5f;
         Pos.xyz = lerp(WPos0.xyz, WPos1, s) + Vel * ParticleInitPos * Color2Float(j, 1).x / aveSpeed;
         Pos.w = 1.0011f + step(TimeRate, 0.001f) * 0.25f;  // Pos.w>1.001で粒子発生
      }else{
         Pos.xyz = WPos1;
      }
   }else{
   // 発生中粒子の座標を更新
      // 加速度計算(速度抵抗力+重力)
      float3 Accel = ( VelocityField(Pos.xyz) - Vel ) * ResistFactor + GravFactor;

      // 新しい座標に更新
      Pos.xyz += Dt * (Vel + Dt * Accel);

      // すでに発生している粒子は経過時間を進める
      Pos.w += Dt;
      Pos.w *= step(Pos.w-1.0f, ParticleLife); // 指定時間を超えると0(粒子消失)
   }

   // 0フレーム再生で粒子初期化
   if(time < 0.001f) Pos = float4(BackWorldCoord(WorldMatrix._41_42_43), 0.0f);

   return Pos;
}

////////////////////////////////////////////////////////////////////////////////////////
// 粒子の速度計算

float4 UpdateVelocity_PS(float2 Tex: TEXCOORD0) : COLOR
{
   // 粒子の座標
   float4 Pos = tex2D(CoordSmp, Tex);

   // 粒子の速度
   float4 Vel = tex2D(VelocitySmp, Tex);

   if(Pos.w < 1.00111){
      // 発生したての粒子に初速度を与える
      int j = floor( Tex.y*TEX_HEIGHT );
      float speed = lerp( ParticleSpeedMin, ParticleSpeedMax, Color2Float(j, 1).y );
      float3 pVel = Color2Float(j, 0) * speed;
      float4 WPos0 = tex2D(WorldCoordSmp, float2(0.25f, 0.5f));
      float3 WPos1 = BackWorldCoord(WorldMatrix._41_42_43);
      float3 wVel = normalize(WPos1-WPos0.xyz) * ObjVelocityRate; // オブジェクト移動方向を付加する
      Vel = float4( wVel+pVel, 1.0f )  ;
   }else{
      // 発生中粒子の速度計算
      float3 Accel = ( VelocityField(Pos.xyz) - Vel.xyz ) * ResistFactor + GravFactor; // 加速度計算(速度抵抗力+重力)
      Vel.xyz += Dt * Accel; // 新しい速度に更新
   }

   return Vel;
}

////////////////////////////////////////////////////////////////////////////////////////////////
// オブジェクトのワールド座標記録

VS_OUTPUT WorldCoord_VS(float4 Pos : POSITION, float2 Tex : TEXCOORD0)
{
    VS_OUTPUT Out = (VS_OUTPUT)0; 

    Out.Pos = Pos;
    Out.Tex = Tex + float2(0.25f, 0.5f);

    return Out;
}

float4 WorldCoord_PS(float2 Tex : TEXCOORD0) : COLOR
{
   // オブジェクトのワールド座標
   float3 Pos1 = BackWorldCoord(WorldMatrix._41_42_43);
   float4 Pos0 = tex2D(WorldCoordSmp, float2(0.25f, 0.5f));
   Pos0.xyz -= VelocityField(Pos1) * Dt; // 流体速度場位置補正

   // 次発生粒子の起点
   float p_count = length( Pos1 - Pos0.xyz ) * OccurFactor * AcsSi*0.1f;
   float w = Pos0.w + p_count;
   if(w >= float(TEX_WIDTH*TEX_HEIGHT)) w -= float(TEX_WIDTH*TEX_HEIGHT);
   if(time < 0.001f) w = 0.0f;

   // 経過時間
   float etime = tex2D(WorldCoordSmp, float2(0.75f, 0.5f)).x;
   etime += Dt;
   if(time < 0.001f) etime = 0.0f;

   float4 Pos = (Tex.x < 0.5f) ? float4(Pos1, w) : float4(etime, 0, 0, 1);

   return Pos;
}

///////////////////////////////////////////////////////////////////////////////////////
// キラキラ粒子テクスチャ描画
#if LIGHT_TYPE==1

// 頂点シェーダ
VS_OUTPUT LightParticle_VS(float4 Pos : POSITION, float2 Tex : TEXCOORD, uniform bool flag)
{
   VS_OUTPUT Out = (VS_OUTPUT)0; 

   // 光芒インデックス
   int index = int(!flag)*(SubGlareIndex + 1) + GlareIndex*(SubGlareCount + 1);

   // 乱数設定
   float rand0 = 0.5f * (0.31f * sin(45.3f * index) + 0.69f * cos(73.4f * index) + 1.0f);
   float rand1 = 0.5f * (0.38f * sin(55.1f * index) + 0.62f * cos(44.4f * index) + 1.0f);
   float rand2 = 0.5f * (0.66f * sin(22.1f * index) + 0.33f * cos(13.6f * index) + 1.0f);

   // 光芒回転角
   float rot = PAI * float(index) / float( (SubGlareCount+1) * GlareCount );

   // 座標変換
   if(flag){
      Pos.x *= 0.7f + 0.3f * rand0;
      Pos.x *= (1.0f - rand1 * (sin(2.0f*PAI*(LightFreq*time+rand2))+1.0f) * 0.2f);
      Pos.y *= GlareThick / 16.0f;
   }else{
      Pos.x *= 0.3f + 0.7f * rand0;
      Pos.x *= SubGlareLength * (1.0f - rand1 * (sin(2.0f*PAI*(LightFreq*time+rand2))+1.0f) * 0.3f);
      Pos.y *= SubGlareThick / 16.0f;
   }
   Out.Pos.xy = Rotation2D( Pos.xy, rot );
   Out.Pos.zw = float2(0.0f, 1.0f);

   // テクスチャ座標
   Out.Tex = Tex;

   return Out;
}

// ピクセルシェーダ
float4 LightParticle_PS( VS_OUTPUT IN ) : COLOR0
{
   // 粒子の色
   return tex2D( ParticleSamp1, IN.Tex );
}

#endif

///////////////////////////////////////////////////////////////////////////////////////
// パーティクル描画

struct VS_OUTPUT2
{
    float4 Pos       : POSITION;    // 射影変換座標
    float3 Tex       : TEXCOORD0;   // テクスチャ
    float  TexIndex  : TEXCOORD1;   // テクスチャ粒子インデクス
    float  Distance  : TEXCOORD2;   // 壁距離
    float4 Color     : COLOR0;      // alpha値
};

// 頂点シェーダ
VS_OUTPUT2 Particle_VS(float4 Pos : POSITION, float2 Tex : TEXCOORD0)
{
   VS_OUTPUT2 Out;

   int i = RepertIndex;
   int j = round( Pos.z * 100.0f );
   int Index0 = i * TEX_HEIGHT + j;
   float2 texCoord = float2((i+0.5f)/TEX_WIDTH, (j+0.5f)/TEX_HEIGHT);
   Pos.z = 0.0f;
   Out.TexIndex = float(j);

   // 粒子の座標
   float4 Pos0 = tex2Dlod(CoordSmp, float4(texCoord, 0, 0));
   Pos0.xyz = InvBackWorldCoord(Pos0.xyz);

   // 経過時間
   float etime = Pos0.w - 1.0f;

   // 乱数設定
   float3 rand = tex2Dlod(ArrangeSmp, float4(2.5f/TEX_WIDTH_A, (j+0.5f)/TEX_HEIGHT, 0, 0)).xyz;

   // 経過時間に対する粒子透過度
   float stAlpha = 10.0f * etime * TimeScale;
   float alpha = min( stAlpha, smoothstep(-ParticleLife, -ParticleLife*ParticleDecrement, -etime) );

   // 粒子の大きさ
   float size = ParticleSize * (1.0f + (2.0f * rand.x - 1.0f) * ParticleRandamSize);
   Pos.xy *= (size + LightAmp*sin(2.0f*PAI*(LightFreq*etime+rand.y))) * alpha * 10.0f;

   // 粒子の回転
   float rtime = tex2Dlod(WorldCoordSmp, float4(0.75f, 0.5f, 0, 0)).x;
   float rot = rtime * ParticleRotSpeed + PAI*float(Index0)/max(float(GlareCount), 1.0f);
   Pos.xy = Rotation2D(Pos.xy, rot);

   // ビルボード
   Pos.xyz = mul( Pos.xyz, BillboardMatrix );

   // 粒子のワールド座標
   Pos.xyz += Pos0.xyz;
   Pos.xyz *= step(0.001f, etime);
   Pos.w = 1.0f;

   // カメラ視点のビュー射影変換
   Out.Pos = mul( Pos, ViewProjMatrix );

   // 粒子の遮蔽面距離
   Out.Distance = dot(Pos.xyz-SmoothPos, SmoothNormal);

   // 粒子の色
   alpha *= step(0.001f, etime) * AcsTr;
   Out.Color = float4( ParticleColor * alpha, alpha );

   // テクスチャ座標
   Out.Tex = float3(Tex, 1.0f / (LightCenter * lerp(0.5f, 1.0f, rand.z)));

   return Out;
}

// ピクセルシェーダ
float4 Particle_PS( VS_OUTPUT2 IN ) : COLOR0
{
#if LIGHT_TYPE==1
   // 粒子の形状
   float4 Color = tex2D( WorkLayerSamp, IN.Tex.xy );
   float2 Tex1 = (IN.Tex.xy - 0.5f) * IN.Tex.z + 0.5f;
   float4 Color1 = tex2D( ParticleSamp2, Tex1 );
   // 粒子の色
   Color.rgb *= IN.Color.rgb;
   Color.rgb += Color1.rgb * IN.Color.a * 1.2f;
   Color.rgb *= LightPower;
#else
   // 粒子の色
   float4 Color = tex2D( ParticleSamp2, IN.Tex.xy );
   float2 Tex1 = (IN.Tex.xy - 0.5f) * IN.Tex.z * 0.3f + 0.5f;
   float4 Color1 = tex2D( ParticleSamp1, Tex1 );
   Color.rgb += Color1.rgb * 1.5f;
   Color.rgb *= IN.Color.rgb * LightPower * 0.5f;
#endif

   // ランダム色設定
   float4 randColor = tex2D(ArrangeSmp, float2(3.5f/TEX_WIDTH_A, (IN.TexIndex+0.5f)/TEX_HEIGHT));
   Color.rgb *= lerp(float3(1.0f,1.0f,1.0f), randColor.rgb, ParticleRandamColor);

   // 遮蔽面処理
   if( IsSmooth ){
      float pSize = clamp(ParticleSize, 0.5f, 2.0f);
      Color.rgb *= smoothstep(0.1f * pSize, 0.2f * pSize * SmoothSi, IN.Distance);
   }

   return Color;
}


///////////////////////////////////////////////////////////////////////////////////////
// テクニック

technique MainTec1 < string MMDPass = "object";
   string Script = 
       "RenderColorTarget0=CoordTex;"
	    "RenderDepthStencilTarget=CoordDepthBuffer;"
	    "Pass=UpdatePos;"
       "RenderColorTarget0=VelocityTex;"
	    "RenderDepthStencilTarget=CoordDepthBuffer;"
	    "Pass=UpdateVelocity;"
       "RenderColorTarget0=WorldCoord;"
            "RenderDepthStencilTarget=WorldCoordDepthBuffer;"
            "Pass=UpdateWorldCoord;"
       #if LIGHT_TYPE==1
       "RenderColorTarget0=WorkLayer;"
            "RenderDepthStencilTarget=WorkDepthBuffer;"
            "ClearSetColor=ClearColor;"
            "ClearSetDepth=ClearDepth;"
            "Clear=Color;"
            "Clear=Depth;"
            "LoopByCount=GlareCount;"
            "LoopGetIndex=GlareIndex;"
                "Pass=DrawLightParticle1;"
                "LoopByCount=SubGlareCount;"
                "LoopGetIndex=SubGlareIndex;"
                    "Pass=DrawLightParticle2;"
                "LoopEnd=;"
            "LoopEnd=;"
       #endif
       "RenderColorTarget0=;"
	    "RenderDepthStencilTarget=;"
            "LoopByCount=RepertCount;"
            "LoopGetIndex=RepertIndex;"
                "Pass=DrawObject;"
            "LoopEnd=;";
>{
   pass UpdatePos < string Script= "Draw=Buffer;"; > {
       ALPHABLENDENABLE = FALSE;
       ALPHATESTENABLE = FALSE;
       VertexShader = compile vs_3_0 Common_VS();
       PixelShader  = compile ps_3_0 UpdatePos_PS();
   }
   pass UpdateVelocity < string Script= "Draw=Buffer;"; > {
       ALPHABLENDENABLE = FALSE;
       ALPHATESTENABLE = FALSE;
       VertexShader = compile vs_3_0 Common_VS();
       PixelShader  = compile ps_3_0 UpdateVelocity_PS();
   }
   pass UpdateWorldCoord < string Script= "Draw=Buffer;"; > {
       ALPHABLENDENABLE = FALSE;
       ALPHATESTENABLE = FALSE;
       VertexShader = compile vs_2_0 WorldCoord_VS();
       PixelShader  = compile ps_2_0 WorldCoord_PS();
   }
   #if LIGHT_TYPE==1
   pass DrawLightParticle1 < string Script= "Draw=Buffer;"; > {
       ZENABLE = FALSE;
       ALPHABLENDENABLE = TRUE;
       SrcBlend = ONE;
       DestBlend = ONE;
       VertexShader = compile vs_2_0 LightParticle_VS(true);
       PixelShader  = compile ps_2_0 LightParticle_PS();
   }
   pass DrawLightParticle2 < string Script= "Draw=Buffer;"; > {
       ZENABLE = FALSE;
       ALPHABLENDENABLE = TRUE;
       SrcBlend = ONE;
       DestBlend = ONE;
       VertexShader = compile vs_2_0 LightParticle_VS(false);
       PixelShader  = compile ps_2_0 LightParticle_PS();
   }
   #endif
   pass DrawObject {
       ZENABLE = TRUE;
       ZWRITEENABLE = FALSE;
       AlphaBlendEnable = TRUE;
       SrcBlend = ONE;
       DestBlend = ONE;
       VertexShader = compile vs_3_0 Particle_VS();
       PixelShader  = compile ps_3_0 Particle_PS();
   }
}

