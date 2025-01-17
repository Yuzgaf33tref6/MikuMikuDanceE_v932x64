////////////////////////////////////////////////////////////////////////////////////////////////
//
//  MangaTears.fx ver0.0.3 漫画風涙パーティクルエフェクト(CannonParticle.fx改変)
//  作成: 針金P
//
////////////////////////////////////////////////////////////////////////////////////////////////
// ここのパラメータを変更してください

// 粒子数設定
#define UNIT_COUNT   2   // ←この数×1024 が一度に描画出来る粒子の数になる(整数値で指定すること)

// テクスチャ設定
#define TexFile  "Particle.png"       // 粒子に貼り付けるテクスチャファイル名

// 粒子パラメータ設定
float3 ParticleColorS = {0.7, 0.9, 1.0}; // 粒子発生時のテクスチャ乗算色(RBG)
float3 ParticleColorE = {1.0, 1.0, 1.0}; // 粒子消失時のテクスチャ乗算色(RBG)
float ParticleSize = 0.07;         // 粒子大きさ
float ParticleSpeedMin = 12.0;     // 粒子初速度最小値
float ParticleSpeedMax = 15.0;     // 粒子初速度最大値
float ParticleInitPos = 0.2;       // 粒子発生時の分散位置(大きくすると粒子の初期配置が広くなります)
float ParticleLife = 3.0;          // 粒子の寿命(秒)
float ParticleDecrement = 0.9;     // 粒子が消失を開始する時間(0.0〜1.0:ParticleLifeとの比)
float ParticleOccur = 1.0;         // 粒子発生度(大きくすると粒子が出やすくなる)
float DiffusionAngle = 5.0;        // 放射拡散角(0.0〜180.0)

// 物理パラメータ設定
float3 GravFactor = {0.0, -25.0, 0.0};   // 重力定数
float ResistFactor = 1.0;          // 速度抵抗力
float CoefRebound = 0.4;           // 地面のはね返り係数
float ReboundNoise = 7.0;          // 地面はね返り後の分散度

float3 OffsetPos = {0.0, 0.0, -1.0};  // 粒子発生位置の補正値(両目に付ける場合はXは0にしてMMDで設定)
float3 StartDirect = {1.0, 0.8, 0.0}; // 粒子放出方向ベクトル

// 解らない人はここから下はいじらないでね

////////////////////////////////////////////////////////////////////////////////////////////////
// パラメータ宣言
#define ArrangeFileName "Arrange.pfm" // 配置･乱数情報ファイル名
#define TEX_WIDTH_A   4           // 配置･乱数情報テクスチャピクセル幅
#define TEX_WIDTH     UNIT_COUNT  // 座標情報テクスチャピクセル幅
#define TEX_HEIGHT    1024        // 配置･乱数情報テクスチャピクセル高さ

#define PAI 3.14159265f   // π

float AcsTr  : CONTROLOBJECT < string name = "(self)"; string item = "Tr"; >;
float AcsSi  : CONTROLOBJECT < string name = "(self)"; string item = "Si"; >;

int RepertCount = UNIT_COUNT;  // シェーダ内描画反復回数
int RepertIndex;               // 複製モデルカウンタ

static float diffD = radians( clamp(90.0f - DiffusionAngle, -90.0f, 90.0f) );
static float3 sDirect = normalize( StartDirect );

float time : TIME;
float elapsed_time : ELAPSEDTIME;
static float Dt = clamp(elapsed_time, 0.001f, 0.1f);

// 1フレーム当たりの粒子発生数
static float P_Count = ParticleOccur * (Dt / ParticleLife) * AcsSi*60;

// 座標変換行列
float4x4 WorldMatrix    : WORLD;
float4x4 ViewProjMatrix : VIEWPROJECTION;
float4x4 ViewMatrixInverse    : VIEWINVERSE;

static float3x3 BillboardMatrix = {
    normalize(ViewMatrixInverse[0].xyz),
    normalize(ViewMatrixInverse[1].xyz),
    normalize(ViewMatrixInverse[2].xyz),
};

// オブジェクトに貼り付けるテクスチャ
texture2D ParticleTex <
    string ResourceName = TexFile;
>;
sampler ParticleSamp = sampler_state {
    texture = <ParticleTex>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = NONE;
    AddressU  = CLAMP;
    AddressV  = CLAMP;
};

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
sampler CoordSmp : register(s3) = sampler_state
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

// 1ステップ前の座標記録用
texture CoordTexOld : RenderColorTarget
<
   int Width=TEX_WIDTH;
   int Height=TEX_HEIGHT;
   string Format="A32B32G32R32F";
>;
sampler CoordSmpOld = sampler_state
{
   Texture = <CoordTexOld>;
   ADDRESSU = CLAMP;
   ADDRESSV = CLAMP;
   MAGFILTER = NONE;
   MINFILTER = NONE;
   MIPFILTER = NONE;
};

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

////////////////////////////////////////////////////////////////////////////////////////////////

// 床判定の位置と向き
bool flagFloorCtrl : CONTROLOBJECT < string name = "FloorControl.x"; >;
float4x4 FloorCtrlWldMat : CONTROLOBJECT < string name = "FloorControl.x"; >;
static float3 FloorPos = flagFloorCtrl ? FloorCtrlWldMat._41_42_43  : float3(0, 0, 0);
static float3 FloorNormal = flagFloorCtrl ? normalize(FloorCtrlWldMat._21_22_23) : float3(0, 1, 0);

// スケーリングなしの床ワールド変換行列
static float4x4 FloorWldMat = flagFloorCtrl ? float4x4( normalize(FloorCtrlWldMat._11_12_13), 0,
                                                        normalize(FloorCtrlWldMat._21_22_23), 0,
                                                        normalize(FloorCtrlWldMat._31_32_33), 0,
                                                        FloorCtrlWldMat[3] )
                                            : float4x4( 1,0,0,0, 0,1,0,0, 0,0,1,0, 0,0,0,1 );

// ワールド変換行列で、スケーリングなしの逆行列を計算する。
float4x4 InverseWorldMatrix(float4x4 mat) {
    float3x3 mat3x3_inv = transpose((float3x3)mat);
    float3x3 mat3x3_inv2 = float3x3( normalize(mat3x3_inv[0]),
                                     normalize(mat3x3_inv[1]),
                                     normalize(mat3x3_inv[2]) );
    return float4x4( mat3x3_inv2[0], 0, 
                     mat3x3_inv2[1], 0, 
                     mat3x3_inv2[2], 0, 
                     -mul(mat._41_42_43, mat3x3_inv2), 1 );
}
// スケーリングなしの床ワールド逆変換行列
static float4x4 InvFloorWldMat = flagFloorCtrl ? InverseWorldMatrix( FloorCtrlWldMat )
                                               : float4x4( 1,0,0,0, 0,1,0,0, 0,0,1,0, 0,0,0,1 );


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

// クォータニオンの積算
float4 MulQuat(float4 q1, float4 q2)
{
   return float4(cross(q1.xyz, q2.xyz)+q1.xyz*q2.w+q2.xyz*q1.w, q1.w*q2.w-dot(q1.xyz, q2.xyz));
}

////////////////////////////////////////////////////////////////////////////////////////////////

struct VS_OUTPUT {
   float4 Pos      : POSITION;
   float2 texCoord : TEXCOORD0;
};

// 共通の頂点シェーダ
VS_OUTPUT Common_VS(float4 Pos: POSITION, float2 Tex: TEXCOORD)
{
   VS_OUTPUT Out;
   Out.Pos = Pos;
   Out.texCoord = Tex + float2(0.5f/TEX_WIDTH, 0.5f/TEX_HEIGHT);
   return Out;
}

///////////////////////////////////////////////////////////////////////////////////////
// 粒子の発生・座標更新計算(xyz:座標,w:経過時間+1sec,wは更新時に1に初期化されるため+1sからスタート)
float4 UpdatePos_PS(float2 texCoord: TEXCOORD0) : COLOR
{
   // 粒子の座標
   float4 Pos = tex2D(CoordSmp, texCoord);

   // 粒子の速度
   float4 Vel = tex2D(VelocitySmp, texCoord);

   int i = floor( texCoord.x*TEX_WIDTH );
   int j = floor( texCoord.y*TEX_HEIGHT );
   int p_index = j + i * TEX_HEIGHT;

   if(Pos.w < 1.001f){
      // 未発生粒子の中から新たに粒子を発生させる
      float3 WPos = Color2Float(j, 0);
      float3 WPos0 = WorldMatrix._41_42_43;
      WPos *= ParticleInitPos * 0.1f;
      WPos = mul( float4(WPos,1), WorldMatrix ).xyz;
      Pos.xyz = (WPos - WPos0) / AcsSi * 10.0f + WPos0 + OffsetPos;  // 発生初期座標

      // 新たに粒子を発生させるかどうかの判定
      if(p_index < Vel.w) p_index += float(TEX_WIDTH*TEX_HEIGHT);
      if(p_index < Vel.w+P_Count){
         Pos.w = 1.0011f;  // Pos.w>1.001で粒子発生
      }
   }else{
      // 発生粒子は疑似物理計算で座標を更新
      // 1ステップ前の位置
      float4 Pos0 = tex2D(CoordSmpOld, texCoord);

      // 加速度計算(速度抵抗力+重力)
      float3 Accel = -Vel.xyz * ResistFactor + GravFactor;

      // 新しい座標に更新
      Pos.xyz = Pos0.xyz + Dt * (Vel.xyz + Dt * Accel);

      // すでに発生している粒子は経過時間を進める
      Pos.w += Dt;
      Pos.w *= step(Pos.w-1.0f, ParticleLife); // 指定時間を超えると0
   }

   return Pos;
}

///////////////////////////////////////////////////////////////////////////////////////
// 粒子の速度計算(xyz:速度,w:発生起点)
float4 UpdateVelocity_PS(float2 texCoord: TEXCOORD0) : COLOR
{
   // 粒子の座標
   float4 Pos = tex2D(CoordSmp, texCoord);

   // 粒子の速度
   float4 Vel = tex2D(VelocitySmp, texCoord);

   int j = floor( texCoord.y*TEX_HEIGHT );

   if(Pos.w < 1.001111f){
      // 発生したての粒子に初速度与える
      float3 rand = Color2Float(j, 2);
      float time1 = time + 100.0f;
      float ss, cs;
      sincos( lerp(diffD, PAI*0.5f, frac(rand.x*time1)), ss, cs );
      float st, ct;
      sincos( lerp(-PAI, PAI, frac(rand.y*time1)), st, ct );
      float3 vec  = float3( cs*ct, ss, cs*st );
      float3 v = cross( sDirect, float3(0.0f, 1.0f, 0.0f) ); // 放出方向への回転軸
      v = any(v) ? normalize(v) : float3(0,0,1);
      float rot = acos( dot(float3(0.0f, 1.0f, 0.0f), sDirect) ); // 放出方向への回転角
      float sinHD = sin(0.5f * rot);
      float cosHD = cos(0.5f * rot);
      float4 q1 = float4(v*sinHD, cosHD);
      float4 q2 = float4(-v*sinHD, cosHD);
      vec = MulQuat( MulQuat(q2, float4(vec, 0.0f)), q1).xyz; // 放出方向への回転(クォータニオン)
      float speed = lerp(ParticleSpeedMin, ParticleSpeedMax, frac(rand.z*time1));
      Vel.xyz = normalize( mul( vec, (float3x3)WorldMatrix ) ) * speed;
   }else{
      // 粒子の速度計算
      float3 rand = Color2Float(j, 3);
      float4 Pos0 = tex2D(CoordSmpOld, texCoord);
      Vel.xyz = ( Pos.xyz - Pos0.xyz ) / Dt;
      // 床の裏側に入った時の処理
      if(dot(Pos.xyz-FloorPos, FloorNormal) < 0.0f){
         float3 reboundVel = mul(Vel.xyz, (float3x3)InvFloorWldMat);
         reboundVel.x = ReboundNoise * (rand.x - 0.5f);
         reboundVel.y = CoefRebound * abs(reboundVel.y) * (rand.y + 0.5f);
         reboundVel.z = ReboundNoise * (rand.z - 0.5f);
         Vel.xyz = mul(reboundVel, (float3x3)FloorWldMat);
         // 床の傾き分の補正(適当)
         float3 flrGrvDir = cross( cross(normalize(GravFactor), FloorNormal), FloorNormal);
         if(dot(flrGrvDir, GravFactor) < 0.0f) flrGrvDir = -flrGrvDir;
         Vel.xyz += flrGrvDir * ReboundNoise * 0.7f;
      }
   }

   // 次発生粒子の起点
   Vel.w += P_Count;
   if(Vel.w >= float(TEX_WIDTH*TEX_HEIGHT)) Vel.w -= float(TEX_WIDTH*TEX_HEIGHT);
   if(time < 0.001f) Vel.w = 0.0f;

   return Vel;
}

////////////////////////////////////////////////////////////////////////////////////////
// 現座標値を1ステップ前の座標にコピー

float4 PosCopy_PS(float2 texCoord: TEXCOORD0) : COLOR
{
   float4 Pos = tex2D(CoordSmp, texCoord);
   return Pos;
}


///////////////////////////////////////////////////////////////////////////////////////
// パーティクル描画
struct VS_OUTPUT2
{
    float4 Pos        : POSITION;    // 射影変換座標
    float2 Tex        : TEXCOORD0;   // テクスチャ
    float4 Color      : COLOR0;      // 粒子の乗算色
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

   // 粒子の座標
   float4 Pos0 = tex2Dlod(CoordSmp, float4(texCoord, 0, 0));

   // 経過時間
   float etime = Pos0.w - 1.0f;

   // 乱数設定
   float rand0 = 0.5f * (0.66f * sin(22.1f * Index0) + 0.33f * cos(33.6f * Index0) + 1.0f);
   float rand1 = 0.5f * (0.31f * sin(45.3f * Index0) + 0.69f * cos(73.4f * Index0) + 1.0f);

   // 経過時間に対する粒子拡大度
   float scale = 1.5f * sqrt(etime) + 1.0f;

   // 粒子の大きさ
   Pos.xy *= (0.5f+rand0) * ParticleSize * scale * 10.0f;

   // 粒子の回転
   float rot = 6.18f * ( rand1 - 0.5f );
   Pos.xy = Rotation2D(Pos.xy, rot);

   // ビルボード
   Pos.xyz = mul( Pos.xyz, BillboardMatrix );

   // 粒子のワールド座標
   Pos.xyz += Pos0.xyz;
   Pos.w = 1.0f;

   // カメラ視点のビュー射影変換
   Out.Pos = mul( Pos, ViewProjMatrix );

   // 粒子の乗算色
   float alpha = step(0.01f, etime) * smoothstep(-ParticleLife, -ParticleLife*ParticleDecrement, -etime) * AcsTr;
   float3 Color = lerp(ParticleColorS, ParticleColorE, etime/ParticleLife);
   Out.Color = float4(Color, alpha);

   // テクスチャ座標
   Out.Tex = Tex;

   return Out;
}

// ピクセルシェーダ
float4 Particle_PS( VS_OUTPUT2 IN ) : COLOR0
{
   float4 Color = tex2D( ParticleSamp, IN.Tex );
   Color *= IN.Color;
   return Color;
}


///////////////////////////////////////////////////////////////////////////////////////
// テクニック
technique MainTec1 < string MMDPass = "object";
   string Script = 
       "RenderColorTarget0=CoordTexOld;"
	    "RenderDepthStencilTarget=CoordDepthBuffer;"
	    "Pass=PosCopy;"
       "RenderColorTarget0=CoordTex;"
	    "RenderDepthStencilTarget=CoordDepthBuffer;"
	    "Pass=UpdatePos;"
       "RenderColorTarget0=VelocityTex;"
	    "RenderDepthStencilTarget=CoordDepthBuffer;"
	    "Pass=UpdateVelocity;"
       "RenderColorTarget0=;"
	    "RenderDepthStencilTarget=;"
            "LoopByCount=RepertCount;"
            "LoopGetIndex=RepertIndex;"
                "Pass=DrawObject;"
            "LoopEnd=;";
>{
    pass PosCopy < string Script = "Draw=Buffer;";>{
        ALPHABLENDENABLE = FALSE;
        ALPHATESTENABLE = FALSE;
        VertexShader = compile vs_1_1 Common_VS();
        PixelShader  = compile ps_2_0 PosCopy_PS();
    }
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
   pass DrawObject {
       ZENABLE = TRUE;
       ZWRITEENABLE = FALSE;
       AlphaBlendEnable = TRUE;
       VertexShader = compile vs_3_0 Particle_VS();
       PixelShader  = compile ps_3_0 Particle_PS();
   }
}

