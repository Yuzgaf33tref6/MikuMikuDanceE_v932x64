////////////////////////////////////////////////////////////////////////////////////////////////
//
//  MeraFireSmoke.fx ver0.0.2 炎エフェクト付属の煙エフェクト
//  作成: 針金P
//
////////////////////////////////////////////////////////////////////////////////////////////////
// ここのパラメータを変更してください

#define SMOKE_TYPE  2    // 煙の種類(とりあえず0〜2で選択,0:通常テクスチャ,1:ノーマルマップ使用粒小,2:ノーマルマップ使用粒大)
#define MMD_LIGHT   1    // MMDの照明操作に 0:連動しない, 1:連動する

float3 ParticleColor = {0.6, 0.6, 0.6}; // テクスチャの乗算色(RBG)
float ParticleSize = 0.3;           // 粒子大きさ
float ParticleSpeedMax = 20.0;      // 粒子初速最大値
float ParticleSpeedMin = 5.0;       // 粒子初速最小値
float ParticleInitPos = 2.0;        // 粒子発生時の位置(大きくすると粒子の配置がばらつきます)
float ParticleLife = 5.0;           // 粒子の寿命(秒)
float ParticleDecrement = 0.5;      // 粒子が消失を開始する時間(0.0〜1.0:ParticleLifeとの比)
float ParticleContrast = 0.5;       // 粒子陰影のコントラスト(0.0〜1.0、ノーマルマップ使用時のみ有効)
float ParticleShadeDiffusion = 4.0; // 粒子発生後の陰影拡散度(大きくすると噴射口から離れるにつれ陰影がぼやけてくる、ノーマルマップのみ)
float DiffusionAngle = 5.0;         // 噴射拡散角(0.0〜180.0)
float SpeedDampCoef = 2.0;          // 噴射速度の減衰係数
float SpeedFixCoef = 0.3;           // 噴射速度の固定係数
float OccurFactor = 1.0;            // 粒子発生度(大きくすると粒子が出やすくなる)
float FireLightLength = 15.0;       // 炎の照り返し基準高さ
float FireLightPower = 1.5;         // 炎の照り返し度(大きくすると近いところは強く、遠いところは弱くなる)

#define RISE_DIREC  1   // 煙の上昇方向を 0:アクセサリ操作可, 1:上方向固定
#define FIRE_LIGHT  1   // 炎の照り返しを 0:無効, 1:有効
#define FireColorTexFile   "palette1.png" // 炎色palletテクスチャファイル名


// 必要に応じて煙のテクスチャをここで定義
#if SMOKE_TYPE == 0
   #define TexFile  "Smoke.png"     // 粒子に貼り付けるテクスチャファイル名
   #define TEX_TYPE   0             // 粒子テクスチャの種類 0:通常テクスチャ, 1:ノーマルマップ
   #define TEX_PARTICLE_XNUM  1     // 粒子テクスチャのx方向粒子数
   #define TEX_PARTICLE_YNUM  1     // 粒子テクスチャのy方向粒子数
   #define TEX_PARTICLE_PXSIZE 128  // 1粒子当たりに使われているテクスチャのピクセルサイズ
#endif

#if SMOKE_TYPE == 1
   #define TexFile  "SmokeNormal1.png" // 粒子に貼り付けるテクスチャファイル名
   #define TEX_TYPE   1             // 粒子テクスチャの種類 0:通常テクスチャ, 1:ノーマルマップ
   #define TEX_PARTICLE_XNUM  2     // 粒子テクスチャのx方向粒子数
   #define TEX_PARTICLE_YNUM  2     // 粒子テクスチャのy方向粒子数
   #define TEX_PARTICLE_PXSIZE 128  // 1粒子当たりに使われているテクスチャのピクセルサイズ
#endif

#if SMOKE_TYPE == 2
   #define TexFile  "SmokeNormal2.png" // 粒子に貼り付けるテクスチャファイル名
   #define TEX_TYPE   1             // 粒子テクスチャの種類 0:通常テクスチャ, 1:ノーマルマップ
   #define TEX_PARTICLE_XNUM  2     // 粒子テクスチャのx方向粒子数
   #define TEX_PARTICLE_YNUM  2     // 粒子テクスチャのy方向粒子数
   #define TEX_PARTICLE_PXSIZE 128  // 1粒子当たりに使われているテクスチャのピクセルサイズ
#endif


// 解らない人はここから下はいじらないでね

////////////////////////////////////////////////////////////////////////////////////////////////
// パラメータ宣言
#define ArrangeFileName "Arrange.pfm" // 配置･乱数情報ファイル名
#define TEX_WIDTH_A   4   // 配置･乱数情報テクスチャピクセル幅
#define TEX_WIDTH     1   // 座標情報テクスチャピクセル幅
#define TEX_HEIGHT 1024   // 配置･乱数情報テクスチャピクセル高さ

#define PAI 3.14159265f   // π

float AcsTr  : CONTROLOBJECT < string name = "(self)"; string item = "Tr"; >;
float AcsSi  : CONTROLOBJECT < string name = "(self)"; string item = "Si"; >;

static float diffD = radians( clamp(90.0f - DiffusionAngle, -90.0f, 90.0f) );

float time : TIME;
float elapsed_time : ELAPSEDTIME;
static float Dt = clamp(elapsed_time, 0.001f, 0.1f);

static float P_Count = OccurFactor * (Dt / ParticleLife) * 500.0f; // 1フレーム当たりの粒子発生数

#if MMD_LIGHT == 1
float3 LightDirection : DIRECTION < string Object = "Light"; >;
float3 LightColor : SPECULAR < string Object = "Light"; >;
static float3 ResColor = ParticleColor * lerp(float3(0.5f, 0.5f, 0.5f), float3(1.33f, 1.33f, 1.33f), LightColor);
#else
float3 LightDirection : DIRECTION < string Object = "Camera"; >;
static float3 ResColor = ParticleColor;
#endif

float3 CameraPosition : POSITION  < string Object = "Camera"; >;
float2 ViewportSize : VIEWPORTPIXELSIZE;

// 座標変換行列
float4x4 WorldMatrix       : WORLD;
float4x4 ViewMatrix        : VIEW;
float4x4 ProjMatrix        : PROJECTION;
float4x4 ViewProjMatrix    : VIEWPROJECTION;
float4x4 ViewMatrixInverse : VIEWINVERSE;

static float4x4 WorldMatrix1 = float4x4(WorldMatrix._11_12_13/AcsSi, 0.0f,
                                        WorldMatrix._21_22_23/AcsSi, 0.0f,
                                        WorldMatrix._31_32_33/AcsSi, 0.0f,
                                        WorldMatrix._41_42_43_44 );

static float3x3 BillboardMatrix = {
    normalize(ViewMatrixInverse[0].xyz),
    normalize(ViewMatrixInverse[1].xyz),
    normalize(ViewMatrixInverse[2].xyz),
};

// オブジェクトに貼り付けるテクスチャ
texture2D ParticleTex <
    string ResourceName = TexFile;
    int MipLevels = 0;
>;
sampler ParticleSamp = sampler_state {
    texture = <ParticleTex>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = LINEAR;
    AddressU  = CLAMP;
    AddressV  = CLAMP;
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
// 配置･乱数情報テクスチャからデータを取り出す

float3 Color2Float(int index, int item)
{
    return tex2D(ArrangeSmp, float2((item+0.5f)/TEX_WIDTH_A, (index+0.5f)/TEX_HEIGHT)).xyz;
}

////////////////////////////////////////////////////////////////////////////////////////////////
// 座標の2D回転

float2 Rotation2D(float2 pos, float rot)
{
    float sinR, cosR;
    sincos(rot, sinR, cosR);

    float x = pos.x * cosR - pos.y * sinR;
    float y = pos.x * sinR + pos.y * cosR;

    return float2(x,y);
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

// 粒子の発生・座標計算(xyz:座標,w:経過時間)
float4 UpdatePos_PS(float2 texCoord: TEXCOORD0, uniform bool flag) : COLOR
{
   float p_count;
   if( flag ){
      p_count = P_Count;
   }else{
      p_count = 0.0f;
   }

   // 粒子の座標
   float4 Pos = tex2D(CoordSmp, texCoord);

   // 粒子の速度
   float4 Vel = tex2D(VelocitySmp, texCoord);

   if(Pos.w < 1.001f){
      // 未発生粒子の中から新たに粒子を発生させる
      int j = floor( texCoord.y*TEX_HEIGHT );
      float3 pos = Color2Float(j, 0);
      float4 WPos = float4(pos.x, 1.0f-abs(pos.y), pos.z, 1.0f);
      WPos.xyz *= ParticleInitPos;
      WPos = mul( WPos, WorldMatrix1 );
      Pos.xyz = WPos.xyz / WPos.w;  // 発生初期座標

      // 新たに粒子を発生させるかどうかの判定
      float p_index = float(j);
      if(p_index < Vel.w) p_index += float(TEX_WIDTH*TEX_HEIGHT);
      if(p_index < Vel.w+p_count){
         Pos.w = 1.0011f;  // Pos.w>1.001で粒子発生
      }
   }else{
      // 粒子の座標更新
      Pos.xyz += Vel.xyz * Dt;

      // すでに発生している粒子は経過時間を進める
      Pos.w += Dt;
      Pos.w *= step(Pos.w-1.0f, ParticleLife); // 指定時間を超えると0
   }

   return Pos;
}

// 粒子の速度計算
float4 UpdateVelocity_PS(float2 texCoord: TEXCOORD0, uniform bool flag) : COLOR
{
   float p_count;
   if( flag ){
      p_count = P_Count;
   }else{
      p_count = 0.0f;
   }

   // 粒子の座標
   float4 Pos = tex2D(CoordSmp, texCoord);

   // 粒子の速度
   float4 Vel = tex2D(VelocitySmp, texCoord);

   if(Pos.w < 1.00111f){
      // 発生したての粒子に初速度与える
      int j = floor( texCoord.y*TEX_HEIGHT );
      float3 rand = Color2Float(j, 2);
      float time1 = time + 100.0f;
      float ss, cs;
      sincos( lerp(diffD, PAI*0.5f, frac(rand.x*time1)), ss, cs );
      float st, ct;
      sincos( lerp(-PAI, PAI, frac(rand.y*time1)), st, ct );
      float3 vec  = float3( cs*ct, ss, cs*st );
      float speed = lerp(ParticleSpeedMin, ParticleSpeedMax, 1.0f-rand.z*rand.z);
      #if RISE_DIREC==0
          Vel.xyz = normalize( mul( vec, (float3x3)WorldMatrix ) ) * speed;
      #else
          Vel.xyz = normalize( vec ) * speed;
      #endif
   }else{
      // すでに発生している粒子の速度を減衰させる
      float speedRate = (exp(-SpeedDampCoef*Pos.w ) + SpeedFixCoef) /
                        (exp(-SpeedDampCoef*(Pos.w-Dt)) + SpeedFixCoef);
      Vel.xyz *= speedRate;
      //Vel.xyz *= mul(float3(speedRate, pow(speedRate, 0.3), speedRate), (float3x3)WorldMatrix )*0.1;
   }

   // 次発生粒子の起点
   Vel.w += p_count;
   if(Vel.w >= float(TEX_WIDTH*TEX_HEIGHT)) Vel.w -= float(TEX_WIDTH*TEX_HEIGHT);
   if(time < 0.001f) Vel.w = 0.0f;

   return Vel;
}


///////////////////////////////////////////////////////////////////////////////////////
// パーティクル描画
struct VS_OUTPUT2
{
    float4 Pos        : POSITION;    // 射影変換座標
    float2 Tex        : TEXCOORD0;   // テクスチャ
    float3 Param      : TEXCOORD1;   // x経過時間,yボードピクセルサイズ,z回転
    float3 LightDir   : TEXCOORD2;   // ライト方向
    float3 FireDir    : TEXCOORD3;   // 炎光源方向
    float  FireLen    : TEXCOORD4;   // 炎光源からの距離
    float4 Color      : COLOR0;      // 粒子の乗算色
};

// 頂点シェーダ
VS_OUTPUT2 Particle_VS(float4 Pos : POSITION, float2 Tex : TEXCOORD0)
{
   VS_OUTPUT2 Out;

   int Index0 = round( Pos.z * 100.0f );
   Pos.x = 2.0f * (Tex.x - 0.5f);
   Pos.y = 2.0f * (0.5f - Tex.y);
   Pos.z = 0.0f;
   int i0 = Index0 / 1024;
   int i = i0 * 8;
   int j = Index0 % 1024;
   float2 texCoord = float2((i0+0.5)/TEX_WIDTH, (j+0.5)/TEX_HEIGHT);

   // 粒子の座標
   float4 Pos0 = tex2Dlod(CoordSmp, float4(texCoord, 0, 1));
   Out.Param.x = length(Pos0.xyz - WorldMatrix._41_42_43);

   // 経過時間
   float etime = Pos0.w - 1.0f;

   // 経過時間に対する粒子拡大度
   float scale = 6.0f * sqrt(etime) + 2.0f;
   scale *= 1.0f + 0.5f * (0.66f * sin(2.0f * Index0) + 0.33f * cos(3.0f * Index0));

   // 粒子の大きさ
   Pos.xy *= ParticleSize * scale * AcsSi * 0.1f;

   // ボードに貼るテクスチャのミップマップレベル
   float pxLen = length(CameraPosition - Pos0.xyz);
   float4 pxPos = float4(0.0f, abs(Pos.y), pxLen, 1.0f);
   pxPos = mul( pxPos, ProjMatrix );
   float pxSize = ViewportSize.y * pxPos.y/pxPos.w;
   Out.Param.y = max( log2(TEX_PARTICLE_PXSIZE/pxSize), 0.0f );

   // 粒子の回転
   float rot = 6.18f *  0.5f * (0.3f * sin(4.0f * Index0) + 0.7f * cos(7.0f * Index0));
   Pos.xy = Rotation2D(Pos.xy, rot);
   Out.Param.z = rot;

   // ビルボード
   Pos.xyz = mul( Pos.xyz, BillboardMatrix );

   // 粒子のワールド座標
   Pos.xyz += (Pos0.xyz - WorldMatrix._41_42_43) * AcsSi * 0.1f + WorldMatrix._41_42_43;
   Pos.xyz *= step(0.001f, etime);
   Pos.w = 1.0f;

   // カメラ視点のビュー射影変換
   Out.Pos = mul( Pos, ViewProjMatrix );

   // カメラ視点のライト方向
   Out.LightDir = mul(-LightDirection, (float3x3)ViewMatrix);
   #if RISE_DIREC==0
      Out.FireDir = normalize(mul(-WorldMatrix._21_22_23, (float3x3)ViewMatrix));
   #else
      Out.FireDir = normalize(mul(float3(0,-1,0), (float3x3)ViewMatrix));
   #endif
   Out.FireLen = length(WorldMatrix._41_42_43 - Pos);

   // 粒子の乗算色
   float alpha = step(0.001f, etime) * smoothstep(0.0f, min(0.5f, ParticleLife*ParticleDecrement), etime)
                   * smoothstep(-ParticleLife, -ParticleLife*ParticleDecrement, -etime) * AcsTr * 0.5f;
   Out.Color = float4(ResColor, alpha);

   // テクスチャ座標
   int texIndex = Index0 % (TEX_PARTICLE_XNUM * TEX_PARTICLE_YNUM);
   int tex_i = texIndex % TEX_PARTICLE_XNUM;
   int tex_j = texIndex / TEX_PARTICLE_XNUM;
   Out.Tex = float2((Tex.x + tex_i)/TEX_PARTICLE_XNUM, (Tex.y + tex_j)/TEX_PARTICLE_YNUM);

   return Out;
}

// ピクセルシェーダ
float4 Particle_PS( VS_OUTPUT2 IN ) : COLOR0
{
#if TEX_TYPE == 1
   // 粒子テクスチャ(ノーマルマップ)から法線計算
   float shadeDiffuse = max( IN.Param.y, lerp(0, ParticleShadeDiffusion, max(IN.Param.x/30.0f, 0.0f)) );
   float4 Color = tex2Dlod( ParticleSamp, float4(IN.Tex, 0, shadeDiffuse) );
   float3 Normal = float3(2.0f * Color.r - 1.0f, 1.0f - 2.0f * Color.g, -Color.b);
   Normal.xy = Rotation2D(Normal.xy, IN.Param.z);
   Normal = normalize(Normal);

   // 粒子の色
   Color.rgb = saturate(IN.Color.rgb * lerp(1.0f-ParticleContrast, 1.0f, max(dot(Normal, IN.LightDir), 0.0f)));
   Color.a *= tex2Dlod( ParticleSamp, float4(IN.Tex, 0, 0) ).a * IN.Color.a;

   #if FIRE_LIGHT == 1
      // 炎の照り返し
      Normal.z = -lerp(-1.5f, 1.0f, -Normal.z);
      Normal = normalize(Normal);
      float4 FireCol = tex2D(FireColorSamp, saturate(float2(0.5f, 0.5f)));
      float fireLight = FireLightLength * AcsSi * 0.1f / IN.FireLen;
      Color.rgb += saturate(FireCol.rgb * lerp(0.0f, 0.8f, max(dot(Normal, IN.FireDir), 0.0f))) * pow(fireLight, FireLightPower);
   #endif
#else
   // 粒子テクスチャの色
   float4 Color = tex2D( ParticleSamp, IN.Tex );

   // 粒子の色
   Color *= IN.Color;
   Color.rgb = saturate(Color.rgb);
#endif

   return Color;
}


///////////////////////////////////////////////////////////////////////////////////////
// テクニック
technique MainTec0 < string MMDPass = "object";
   string Script = 
       "RenderColorTarget0=CoordTex;"
	    "RenderDepthStencilTarget=CoordDepthBuffer;"
	    "Pass=UpdatePos;"
       "RenderColorTarget0=VelocityTex;"
	    "RenderDepthStencilTarget=CoordDepthBuffer;"
	    "Pass=UpdateVelocity;"
       "RenderColorTarget0=;"
	    "RenderDepthStencilTarget=;"
           "Pass=DrawObject;";
>{
   pass UpdatePos < string Script= "Draw=Buffer;"; > {
       ALPHABLENDENABLE = FALSE;
       ALPHATESTENABLE = FALSE;
       VertexShader = compile vs_3_0 Common_VS();
       PixelShader  = compile ps_3_0 UpdatePos_PS(true);
   }
   pass UpdateVelocity < string Script= "Draw=Buffer;"; > {
       ALPHABLENDENABLE = FALSE;
       ALPHATESTENABLE = FALSE;
       VertexShader = compile vs_3_0 Common_VS();
       PixelShader  = compile ps_3_0 UpdateVelocity_PS(true);
   }
   pass DrawObject {
       ZENABLE = TRUE;
       ZWRITEENABLE = FALSE;
       AlphaBlendEnable = TRUE;
       VertexShader = compile vs_3_0 Particle_VS();
       PixelShader  = compile ps_3_0 Particle_PS();
   }
}


technique MainTec1 < string MMDPass = "object_ss";
   string Script = 
       "RenderColorTarget0=CoordTex;"
	    "RenderDepthStencilTarget=CoordDepthBuffer;"
	    "Pass=UpdatePos;"
       "RenderColorTarget0=VelocityTex;"
	    "RenderDepthStencilTarget=CoordDepthBuffer;"
	    "Pass=UpdateVelocity;"
       "RenderColorTarget0=;"
	    "RenderDepthStencilTarget=;"
           "Pass=DrawObject;";
>{
   pass UpdatePos < string Script= "Draw=Buffer;"; > {
       ALPHABLENDENABLE = FALSE;
       ALPHATESTENABLE = FALSE;
       VertexShader = compile vs_3_0 Common_VS();
       PixelShader  = compile ps_3_0 UpdatePos_PS(false);
   }
   pass UpdateVelocity < string Script= "Draw=Buffer;"; > {
       ALPHABLENDENABLE = FALSE;
       ALPHATESTENABLE = FALSE;
       VertexShader = compile vs_3_0 Common_VS();
       PixelShader  = compile ps_3_0 UpdateVelocity_PS(false);
   }
   pass DrawObject {
       ZENABLE = TRUE;
       ZWRITEENABLE = FALSE;
       AlphaBlendEnable = TRUE;
       VertexShader = compile vs_3_0 Particle_VS();
       PixelShader  = compile ps_3_0 Particle_PS();
   }
}



///////////////////////////////////////////////////////////////////////////////////////////////
// 地面影は表示しない
technique ShadowTec < string MMDPass = "shadow"; > { }
// MMD標準のセルフシャドウは表示しない
technique ZplotTec < string MMDPass = "zplot"; > { }

