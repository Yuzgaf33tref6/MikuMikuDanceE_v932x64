//===============================================//
//マズルフラッシュエフェクト
//作った人：ビームマンP（ロベリア）


//--マズルフラッシュアニメーション速度--//
float FlashSpd = 5.0;

//--点滅間隔--//
int FlashRld = 5;




//合成方法の設定
//
//半透明合成：
//BLENDMODE_SRC SRCALPHA
//BLENDMODE_DEST INVSRCALPHA
//
//加算合成：
//
//BLENDMODE_SRC SRCALPHA
//BLENDMODE_DEST ONE

#define BLENDMODE_SRC SRCALPHA
#define BLENDMODE_DEST ONE

//テクスチャ名
texture Line_Tex
<
   string ResourceName = "mzflash_0.png";
   //string ResourceName = "mzflash_1.png";
   //string ResourceName = "mzflash_2.png";
>;
//ラインの太さ（MMD上で設定した太さ×ここで設定した太さ＝表示される太さ）
float lineSize
<
   string UIName = "lineSize";
   string UIWidget = "Numeric";
   bool UIVisible =  true;
   float UIMin = 0.00;
   float UIMax = 20.00;
> = float( 2 );
//ラインの長さ
float lineLength
<
   string UIName = "lineLength";
   string UIWidget = "Numeric";
   bool UIVisible =  true;
   float UIMin = 0.00;
   float UIMax = 20.00;
> = float( 3 );
//UVスクロール速度
float UScroll
<
   string UIName = "UScroll";
   string UIWidget = "Numeric";
   bool UIVisible =  true;
   float UIMin = 0.00;
   float UIMax = 10.00;
> = float(0);
float VScroll
<
   string UIName = "VScroll";
   string UIWidget = "Numeric";
   bool UIVisible =  true;
   float UIMin = 0.00;
   float UIMax = 10.00;
> = float(0);

//UV繰り返し数
float UWrapNum
<
   string UIName = "UWrapNum";
   string UIWidget = "Numeric";
   bool UIVisible =  true;
   int UIMin = 0.0;
   int UIMax = 100.0;
> = float(1);
float VWrapNum
<
   string UIName = "VWrapNum";
   string UIWidget = "Numeric";
   bool UIVisible =  true;
   int UIMin = 0.0;
   int UIMax = 100.0;
> = float(1);
//--よくわからない人はここから下はさわっちゃだめ--//

float time_0_X : Time;
//πの値
#define PI 3.1415
//角度をラジアン値に変換
#define RAD ((ROTATE * PI) / 180.0)

float4x4 world_matrix : World;
float4x4 view_proj_matrix : ViewProjection;
float4x4 view_trans_matrix : ViewTranspose;
float4x4 WorldViewProjMatrix : WORLDVIEWPROJECTION;

float4   MaterialDiffuse   : DIFFUSE  < string Object = "Geometry"; >;
float3   LightDiffuse      : DIFFUSE   < string Object = "Light"; >;
static float4 DiffuseColor  = MaterialDiffuse  * float4(LightDiffuse, 1.0f);

struct VS_OUTPUT {
   float4 Pos: POSITION;
   float2 texCoord: TEXCOORD0;
   float color: TEXCOORD1;
};

VS_OUTPUT lineSystem_Vertex_Shader_main(float4 Pos: POSITION){
   VS_OUTPUT Out;

   //ローカル座標を0点に初期化
   Out.Pos = float4(0,0,0,1);
   
   //ワールド座標
   float3 world_pos = world_matrix[3].xyz;

   //ワールドの進行ベクトル
   float3 vec = normalize(world_matrix[2].xyz);
   
   //カメラの位置
   float3 eyepos = view_trans_matrix[3].xyz;
   
   //カメラからのベクトル
   float3 eyevec = view_trans_matrix[2].xyz;//normalize(world_pos - eyepos);
   
   //進行ベクトルとカメラベクトルの外積で横方向を得る
   float3 side = normalize(cross(vec,eyevec));
   
   float w = cos(time_0_X * 1);
   if(w > 0)
   {
   		w = pow(w,32);
   }else{
   		w = 0;
   }
   int t = (time_0_X * 60.0);
   int par = t % FlashRld;
   if(par == 0)
   {
   		w = 1;
   }else{
   		w = par/((float)FlashRld * (FlashSpd/(float)FlashRld));
   		w = max(0,1-w);
   }
   
   //横幅に合わせて拡大
   side *= lineSize/2/2;
   
   //ワールド拡大率に合わせて拡大（横だけ
   side *= length(world_matrix[0]) * w;
   
   //入力座標のX値でローカルな左右判定
   if(Pos.x > 0)
   {
   		//左側
   		Out.texCoord.y = 0;
   		Out.Pos += float4(side,0);
   }else{
   		//右側
   		Out.texCoord.y = 1 * VWrapNum; 
   		Out.Pos -= float4(side,0);
   }
   
   //長さに合わせて進行ベクトルを伸ばす
   vec *= -lineLength * 5.0 * DiffuseColor.a * (1-w);
   
   //ローカルのZ値が＋の場合、進行ベクトルを加える
   if(Pos.z > 0)
   {
   		Out.texCoord.x = 0; 
   		Out.Pos += float4(vec,0);
   }else{
   		Out.texCoord.x = 1.0 * UWrapNum;
   }
   Out.Pos += float4(world_pos,0);
   
   Out.texCoord += float2(UScroll,VScroll) * time_0_X;
   
   //ワールド拡大率に合わせて拡大
   
   
   Out.Pos = mul(Out.Pos, view_proj_matrix);
   Out.color = 1;

   return Out;
}

//テクスチャの設定
sampler LineTexSampler = sampler_state
{
   //使用するテクスチャ
   Texture = (Line_Tex);
   //テクスチャ範囲0.0〜1.0をオーバーした際の処理
   //WRAP:ループ
   ADDRESSU = WRAP;
   ADDRESSV = WRAP;
   //テクスチャフィルター
   //LINEAR:線形フィルタ
   MAGFILTER = LINEAR;
   MINFILTER = LINEAR;
   MIPFILTER = LINEAR;
};

//ピクセルシェーダ
float4 lineSystem_Pixel_Shader_main(float2 texCoord: TEXCOORD0) : COLOR {
   //入力されたテクスチャ座標に従って色を選択する
   return float4(tex2D(LineTexSampler,texCoord));
}

//テクニックの定義
technique lineSystem <
    string Script = 
		//描画対象をメイン画面に
        "RenderColorTarget0=;"
	    "RenderDepthStencilTarget=;"
	    //パスの選択
	    "Pass=lineSystem;"
    ;
> {
   //メインパス
   pass lineSystem
   {
      //Z値の考慮：する
      ZENABLE = TRUE;
      //Z値の描画：しない
      ZWRITEENABLE = FALSE;
      //カリングオフ（両面描画
      CULLMODE = NONE;
      //αブレンドを使用する
      ALPHABLENDENABLE = TRUE;
      //αブレンドの設定（詳しくは最初の定数を参照）
      SRCBLEND=BLENDMODE_SRC;
      DESTBLEND=BLENDMODE_DEST;
      //使用するシェーダを設定
      VertexShader = compile vs_3_0 lineSystem_Vertex_Shader_main();
      PixelShader = compile ps_3_0 lineSystem_Pixel_Shader_main();
   }
}

