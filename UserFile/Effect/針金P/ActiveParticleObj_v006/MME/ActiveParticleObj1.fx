////////////////////////////////////////////////////////////////////////////////////////////////
//
//  ActiveParticleObj.fx ver0.0.6 オブジェクトが移動に応じて複製モデルを粒子にして放出します
//  作成: 針金P
//
////////////////////////////////////////////////////////////////////////////////////////////////
// ここのパラメータを変更してください

// 粒子オブジェクトID番号
#define  ObjectNo  1   // 0〜3以外で新たに粒子オブジェクトを増やす場合はファイル名変更とこの値を4,5,6･･と変えていく

float ParticleSize = 1.0;          // 粒子大きさ
float ParticleSizeRandam = 0.0;    // 粒子サイズばらつき度(0.0〜1.0)
float ParticleSpeedMax = 3.5;      // 粒子初期最大スピード
float ParticleSpeedMin = 2.0;      // 粒子初期最小スピード
float ParticleRotSpeed = 2.0;      // 粒子回転スピード
float ParticleRotRandam = 1.0;     // 粒子回転位相ばらつき度(0.0〜1.0)
float ParticleInitPos = 0.5;       // 粒子発生時の相対位置(大きくすると粒子の配置がばらつきます)
float ParticleLife = 5.0;          // 粒子の寿命(秒)
float ParticleDecrement = 0.5;     // 粒子が消失を開始する時間(ParticleLifeとの比)
float OccurFactor = 1.0;           // オブジェクト移動量に対する粒子発生度(大きくすると粒子が出やすくなる)
float ObjVelocityRate = 3.0;       // オブジェクト移動方向に対する粒子速度依存度

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

// 粒子元モデル実際の位置(または回転中心点の座標),
// 元モデルを剛体の物理干渉回避で移動させる場合や,回転中心位置を変えたい場合はこの値で調整
float3 ObjOffset = {0.0, 0.0, 0.0};


// オプションのコントロールファイル名
#define BackgroundCtrlFileName  "BackgroundControl.x" // 背景座標コントロールファイル名
#define TimrCtrlFileName        "TimeControl.x"       // 時間制御コントロールファイル名


// 解らない人はここから下はいじらないでね

////////////////////////////////////////////////////////////////////////////////////////////////
// パラメータ宣言

#define ArrangeFileName "Arrange.png" // 配置･乱数情報ファイル名
#define TEX_WIDTH_A  32   // 配置･乱数情報テクスチャピクセル幅
#define TEX_WIDTH_W  16   // 粒子ワールド座標テクスチャピクセル幅
#define TEX_WIDTH     4   // 座標情報テクスチャピクセル幅
#define TEX_HEIGHT 1024   // 配置･乱数情報テクスチャピクセル高さ

float AcsTr  : CONTROLOBJECT < string name = "(self)"; string item = "Tr"; >;
float AcsSi  : CONTROLOBJECT < string name = "(self)"; string item = "Si"; >;

// オプションのコントロールパラメータ
bool IsBack : CONTROLOBJECT < string name = BackgroundCtrlFileName; >;
float4x4 BackMat : CONTROLOBJECT < string name = BackgroundCtrlFileName; >;

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
float4x4 WorldMatrix     : WORLD;
float4x4 ViewProjMatrix  : VIEWPROJECTION;

// 配置･乱数情報テクスチャ
texture2D ArrangeTex <
    string ResourceName = ArrangeFileName;
>;
sampler ArrangeSmp = sampler_state{
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
sampler CoordSmp = sampler_state
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
   int Width=1;
   int Height=1;
   string Format="A32B32G32R32F";
>;
sampler WorldCoordSmp = sampler_state
{
   Texture = <WorldCoord>;
   AddressU  = CLAMP;
   AddressV = CLAMP;
   MinFilter = NONE;
   MagFilter = NONE;
   MipFilter = NONE;
};
texture WorldCoordDepthBuffer : RenderDepthStencilTarget <
   int Width=1;
   int Height=1;
    string Format = "D24S8";
>;

// 粒子のワールド変換行列記録用
#define  WorldMatrixTexName(n)  ActiveParticle_WorldMatrixTex##n   // ワールド座標記録用テクスチャ名
shared texture WorldMatrixTexName(ObjectNo) : RENDERCOLORTARGET
<
   int Width=TEX_WIDTH_W;
   int Height=TEX_HEIGHT;
   string Format="A32B32G32R32F";
>;
sampler ObjWorldCoordSmp = sampler_state
{
   Texture = <WorldMatrixTexName(ObjectNo)>;
   AddressU  = CLAMP;
   AddressV = CLAMP;
   MinFilter = NONE;
   MagFilter = NONE;
   MipFilter = NONE;
};
texture ObjWorldMatrixDepthBuffer : RenderDepthStencilTarget <
   int Width=TEX_WIDTH_W;
   int Height=TEX_HEIGHT;
   string Format = "D24S8";
>;


////////////////////////////////////////////////////////////////////////////////////////////////
// 配置･乱数情報テクスチャからデータを取り出す
float Color2Float(int i, int j)
{
    float4 d = tex2D(ArrangeSmp, float2((i+0.5)/TEX_WIDTH_A, (j+0.5)/TEX_HEIGHT));
    float tNum = (65536.0f * d.x + 256.0f * d.y + d.z) * 255.0f;
    int pNum = round(d.w * 255.0f);
    int sgn = 1 - 2 * (pNum % 2);
    float data = tNum * pow(10.0f, pNum/2 - 64) * sgn;
    return data;
}

////////////////////////////////////////////////////////////////////////////////////////////////

// 粒子の回転行列
float4x4 RoundMatrix(int index, float etime)
{
   float rotX = 0.8*ParticleRotSpeed * etime + (float)index * 37.0f;
   float rotY = ParticleRotSpeed * etime + (float)index * 28.0f;
   float rotZ = 1.2*ParticleRotSpeed * etime + (float)index * 19.0f;

   float sinx, cosx;
   float siny, cosy;
   float sinz, cosz;
   sincos(rotX, sinx, cosx);
   sincos(rotY, siny, cosy);
   sincos(rotZ, sinz, cosz);

   float4x4 rMat = { cosz*cosy+sinx*siny*sinz, cosx*sinz, -siny*cosz+sinx*cosy*sinz, 0.0f,
                    -cosy*sinz+sinx*siny*cosz, cosx*cosz,  siny*sinz+sinx*cosy*cosz, 0.0f,
                     cosx*siny,               -sinx,       cosx*cosy,                0.0f,
                     0.0f,                     0.0f,       0.0f,                     1.0f };

   return rMat;
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
   float4 Pos : POSITION;
   float2 Tex : TEXCOORD0;
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
   float4 Vel = tex2D(VelocitySmp, Tex);

   if(Pos.w < 1.001f){
   // 未発生粒子の中から移動距離に応じて新たに粒子を発生させる
      // 現在のオブジェクト座標
      float3 WPos1 = BackWorldCoord(WorldMatrix._41_42_43);

      // 1フレーム前のオブジェクト座標
      float4 WPos0 = tex2D(WorldCoordSmp, float2(0.5f, 0.5f));
      WPos0.xyz -= VelocityField(WPos1) * Dt; // 流体速度場位置補正

      // 粒子発生確率
      int i = floor( Tex.x*TEX_WIDTH ) * 8;
      int j = floor( Tex.y*TEX_HEIGHT );
      float probable = length( WPos1 - WPos0.xyz ) * OccurFactor * AcsSi * 0.00004f;

      // 新たに粒子を発生させるかどうかの判定
      float probable0 = Color2Float(i+7, j);
      if(probable0 < WPos0.w) probable0 += 1.0f;
      if(probable0 < WPos0.w+probable){
         // 粒子発生座標
         float s = (probable0 - WPos0.w) / probable;
         float aveSpeed = (ParticleSpeedMin + ParticleSpeedMax) * 0.5f;
         Pos.xyz = lerp(WPos0.xyz, WPos1, s) + Vel.xyz * ParticleInitPos * Color2Float(i+5, j) / aveSpeed;
         Pos.w = 1.0011f + step(TimeRate, 0.001f) * 0.33f;  // Pos.w>1.001で粒子発生
      }else{
         Pos.xyz = WPos1;
      }
   }else{
   // 発生中粒子の座標を更新
      // 加速度計算(速度抵抗力+重力)
      float3 Accel = ( VelocityField(Pos.xyz) - Vel.xyz ) * ResistFactor + GravFactor;

      // 新しい座標に更新
      Pos.xyz += Dt * (Vel.xyz + Dt * Accel);

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

   if(Pos.w < 1.00111f){
      // 発生したての粒子に初速度を与える
      int i = floor( Tex.x*TEX_WIDTH ) * 8;
      int j = floor( Tex.y*TEX_HEIGHT );
      float speed = lerp( ParticleSpeedMin, ParticleSpeedMax, Color2Float(i+6, j) );
      float3 pVel = float3(Color2Float(i, j), Color2Float(i+1, j), Color2Float(i+2, j)) * speed;
      float4 WPos0 = tex2D(WorldCoordSmp, float2(0.5f, 0.5f));
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

VS_OUTPUT WorldCoord_VS(float4 Pos : POSITION)
{
    VS_OUTPUT Out = (VS_OUTPUT)0; 

    Out.Pos = Pos;
    Out.Tex = float2(0.5f, 0.5f);

    return Out;
}

float4 WorldCoord_PS(float2 Tex: TEXCOORD0) : COLOR
{
   // オブジェクトのワールド座標
   float3 Pos1 = BackWorldCoord(WorldMatrix._41_42_43);
   float4 Pos0 = tex2D(WorldCoordSmp, Tex);
   Pos0.xyz -= VelocityField(Pos1) * Dt; // 流体速度場位置補正

   // 次発生粒子の起点
   float probable = length( Pos1 - Pos0.xyz ) * OccurFactor * AcsSi * 0.00004f;
   float w = Pos0.w + probable;
   if(w >= 1.0f) w -= 1.0f;
   if(time < 0.001f) w = 0.0;

   return float4(Pos1, w);
}


///////////////////////////////////////////////////////////////////////////////////////
// パーティクルのワールド変換行列計算
struct VS_OUTPUT2
{
    float4 Pos    : POSITION;    // 射影変換座標
    float2 Tex    : TEXCOORD0;   // テクスチャ
    float4 Color  : COLOR0;      // 粒子の乗算色
};

// 頂点シェーダ
VS_OUTPUT Particle_VS(float4 Pos : POSITION, float2 Tex : TEXCOORD0)
{
   VS_OUTPUT Out;
   Out.Pos = Pos;
   Out.Tex = Tex + float2(0.5f/TEX_WIDTH_W, 0.5f/TEX_HEIGHT);
   return Out;
}

// ピクセルシェーダ
float4 Particle_PS(float2 Tex: TEXCOORD0) : COLOR0
{
   int i0 = floor( Tex.x * TEX_WIDTH_W );
   int i = i0 / 4;
   int i1 = i * 8;
   int j = floor( Tex.y * TEX_HEIGHT );
   int Index = i * TEX_HEIGHT + j;
   float2 texCoord = float2((i+0.5)/TEX_WIDTH, (j+0.5)/TEX_HEIGHT);

   // 粒子の座標
   float4 Pos0 = tex2Dlod(CoordSmp, float4(texCoord, 0, 0));
   Pos0.xyz = InvBackWorldCoord(Pos0.xyz);

   // 経過時間
   float etime = Pos0.w - 1.0f;

   // 粒子の回転
   float4x4 WldMat = RoundMatrix( Index, etime );

   // 粒子の大きさ
   WldMat *= (1.0f + ParticleSizeRandam * (2.0f*Color2Float(i1+4, j)-1.0f)) * ParticleSize;

   // 粒子のワールド変換行列
   WldMat._41_42_43 = Pos0.xyz;
   WldMat._41_42_43 -= mul( ObjOffset, (float3x3)WldMat );

   // 経過時間に対する粒子透過度
   float stAlpha = 3.0f * etime * TimeScale;
   float alpha = min( stAlpha, smoothstep(-ParticleLife, -ParticleLife*ParticleDecrement, -etime) );
   alpha *= step(0.001f, etime) * AcsTr;
   WldMat._44 = alpha;

   return WldMat[i0 % 4];
}


///////////////////////////////////////////////////////////////////////////////////////
// テクニック
// ここの計算結果を基にAP_Objecj.fxでオブジェクトの複製・描画を行う

#define  WorldMatrixTexNameRT(n)  "RenderColorTarget0=ActiveParticle_WorldMatrixTex"#n";"   //  ワールド座標記録用レンダターゲット

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
       WorldMatrixTexNameRT(ObjectNo)
            "RenderDepthStencilTarget=ObjWorldMatrixDepthBuffer;"
            "Pass=CalcParticleWldMat;"
        "RenderColorTarget0=;"
	    "RenderDepthStencilTarget=;";
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
   pass CalcParticleWldMat < string Script = "Draw=Buffer;";>
   {
       ALPHABLENDENABLE = FALSE;
       ALPHATESTENABLE = FALSE;
       VertexShader = compile vs_3_0 Particle_VS();
       PixelShader  = compile ps_3_0 Particle_PS();
   }
}

