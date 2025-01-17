//--------------------------------------------------------------//
// lineSystem
// つくったひと：ロベリア
// ベースにしたシェーダ―：FireParticleSystemEx
// つくった日：2010/10/7
// こうしんりれき
// 10/10/7:つくった
// 10/10/7:WORLD_ROTATEをちゃんと実装・テクスチャ4個とかぶっちゃけありえない…
// 10/10/9:ついに　ねんがんの　ビルボードを　じっそうしたぞ
//--------------------------------------------------------------//

//ラインの長さ（0〜100の範囲で指定）
#define LINE_LENGTH 100

//角度（0〜360推奨）
#define ROTATE 0

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
#define BLENDMODE_DEST INVSRCALPHA

//テクスチャ名
texture Line_Tex
<
   string ResourceName = "smoke.png";
>;
//ラインの太さ（MMD上で設定した太さ×ここで設定した太さ＝表示される太さ）
float lineSize
<
   string UIName = "lineSize";
   string UIWidget = "Numeric";
   bool UIVisible =  true;
   float UIMin = 0.00;
   float UIMax = 20.00;
> = float( 0.25 );
//UVスクロール速度
float UScroll
<
   string UIName = "UScroll";
   string UIWidget = "Numeric";
   bool UIVisible =  true;
   float UIMin = 0.00;
   float UIMax = 10.00;
> = float(2);
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

//噴射炎の量
float Boost
<
   string UIName = "Boost";
   string UIWidget = "Numeric";
   bool UIVisible =  true;
   int UIMin = 0.0;
   int UIMax = 10.0;
> = float(0.5);

//ラインのスピード
float LineSpd
<
   string UIName = "LineSpd";
   string UIWidget = "Numeric";
   bool UIVisible =  true;
   int UIMin = -100.0;
   int UIMax = 100.0;
> = float(0.25);
//--よくわからない人はここから下はさわっちゃだめ--//

float time_0_X : Time;
// Xファイルと連動しているので、変更不可
#define PARTICLE_COUNT  100
// 位置記録用テクスチャのサイズ  (TEX_WIDTH*TEX_HEIGHT==PARTICLE_COUNT)
#define TEX_WIDTH  10
#define TEX_HEIGHT  10
//πの値
#define PI 3.1415
//角度をラジアン値に変換
#define RAD ((ROTATE * PI) / 180.0)

//彩度計算用定数
const float4 calcY = float4( 0.2989f, 0.5866f, 0.1145f, 0.00f );

float4x4 world_matrix : World;
float4x4 view_proj_matrix : ViewProjection;
float4x4 view_trans_matrix : ViewTranspose;
texture DepthBuffer : RenderDepthStencilTarget <
   int Width=TEX_WIDTH;
   int Height=TEX_HEIGHT;
    string Format = "D24S8";
>;
//ワールド行列を保存するテクスチャー
texture WorldTex1 : RenderColorTarget
<
   int Width=TEX_WIDTH;
   int Height=TEX_HEIGHT;
   string Format="A32B32G32R32F";
>;
texture WorldTex2 : RenderColorTarget
<
   int Width=TEX_WIDTH;
   int Height=TEX_HEIGHT;
   string Format="A32B32G32R32F";
>;
texture WorldTex3 : RenderColorTarget
<
   int Width=TEX_WIDTH;
   int Height=TEX_HEIGHT;
   string Format="A32B32G32R32F";
>;
texture WorldTex4 : RenderColorTarget
<
   int Width=TEX_WIDTH;
   int Height=TEX_HEIGHT;
   string Format="A32B32G32R32F";
>;
sampler WorldBase1 = sampler_state
{
   Texture = (WorldTex1);
   ADDRESSU = CLAMP;
   ADDRESSV = CLAMP;
   MAGFILTER = NONE;
   MINFILTER = NONE;
   MIPFILTER = NONE;
};
sampler WorldBase2 = sampler_state
{
   Texture = (WorldTex2);
   ADDRESSU = CLAMP;
   ADDRESSV = CLAMP;
   MAGFILTER = NONE;
   MINFILTER = NONE;
   MIPFILTER = NONE;
};
sampler WorldBase3 = sampler_state
{
   Texture = (WorldTex3);
   ADDRESSU = CLAMP;
   ADDRESSV = CLAMP;
   MAGFILTER = NONE;
   MINFILTER = NONE;
   MIPFILTER = NONE;
};
sampler WorldBase4 = sampler_state
{
   Texture = (WorldTex4);
   ADDRESSU = CLAMP;
   ADDRESSV = CLAMP;
   MAGFILTER = NONE;
   MINFILTER = NONE;
   MIPFILTER = NONE;
};
struct VS_OUTPUT {
   float4 Pos: POSITION;
   float2 texCoord: TEXCOORD0;
   float color: TEXCOORD1;
};

VS_OUTPUT lineSystem_Vertex_Shader_main(float4 Pos: POSITION){
   VS_OUTPUT Out;

   int idx = round(Pos.z*PARTICLE_COUNT);
   //IDが規定の長さより長かったら最大値に固定
   if(idx >= LINE_LENGTH)
   {
		idx = LINE_LENGTH;
   }
   //現在の座標を取得
   float2 base_tex_coord = float2( float(idx%TEX_WIDTH)/TEX_WIDTH + 0.05, float(idx/TEX_WIDTH)/TEX_HEIGHT + 0.05);
   float4x4 base_mat = float4x4(tex2Dlod(WorldBase1, float4(base_tex_coord,0,1)),tex2Dlod(WorldBase2, float4(base_tex_coord,0,1)),tex2Dlod(WorldBase3, float4(base_tex_coord,0,1)),tex2Dlod(WorldBase4, float4(base_tex_coord,0,1)));
   float3 pos = Pos;
   pos.z = 0;      

   float4 rspos = 0;

   //ラインのビルボード化
   float3 vec = 0;
   int end = 0;
   for(int i = 1;i<LINE_LENGTH || !end;i++)
   {
	   //ベクトル計算用目標ＩＤ
	   int tgt = idx+i;
	   //次ＩＤのマトリクスを取得
	   float2 tgt_tex_coord = float2( float(tgt%TEX_WIDTH)/TEX_WIDTH + 0.05, float(tgt/TEX_WIDTH)/TEX_HEIGHT + 0.05);
	   float4x4 tgt_mat = float4x4(tex2Dlod(WorldBase1, float4(tgt_tex_coord,0,1)),tex2Dlod(WorldBase2, float4(tgt_tex_coord,0,1)),tex2Dlod(WorldBase3, float4(tgt_tex_coord,0,1)),tex2Dlod(WorldBase4, float4(tgt_tex_coord,0,1)));
	   
	   //tgtの座標を保存
	   float3 tgt_pos = tgt_mat._41_42_43;
	   
	   //tgtへのベクトルを計算
	   vec = normalize(base_mat._41_42_43 - tgt_pos);
	   
	   //誤差により同一座標を取得、ベクトルが０の場合
	   if((vec.x + vec.y + vec.z) != 0)
	   {
	      //取得成功ループを抜ける
	      end = 1;
	   }
    }	   

	//カメラからのベクトル
	float3 eyevec = normalize(view_trans_matrix[2].xyz);

	//進行ベクトルとカメラベクトルの外積で横方向を得る
	float3 side = normalize(cross(vec,eyevec));

	//横幅に合わせて拡大
	side *= lineSize/16;

	//ワールド拡大率に合わせて拡大（横だけ
	side *= length(world_matrix[0]);

	//入力座標のX値でローカルな左右判定
	if(Pos.x > 0)
	{
	    //左側
	    rspos += float4(side,0);
	}else{
	    //右側
	    rspos -= float4(side,0);
	}
   
   rspos = mul(rspos,length(world_matrix[0]));
   pos.x = rspos.x;
   pos.y = rspos.y;
   pos.z = rspos.z;
   

   pos += base_mat._41_42_43;
   
   
   Out.Pos = mul(float4(pos, 1), view_proj_matrix);
   
   //頂点UV値の計算
   Out.texCoord.x = (Pos.z * ((float)PARTICLE_COUNT/(float)LINE_LENGTH)) * -UWrapNum;
   Out.texCoord.y = ((Pos.x + Pos.y) + 0.5) * -VWrapNum;
   //UVスクロール
   Out.texCoord.x += float2(UScroll,VScroll) * time_0_X;
   Out.color = 1.0 - (Pos.z * ((float)PARTICLE_COUNT/(float)LINE_LENGTH));


   return Out;
}
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
float4 lineSystem_Pixel_Shader_main(VS_OUTPUT IN) : COLOR {

   float4 col = tex2D(LineTexSampler,IN.texCoord);
   float4 col_buf = col;
   //彩度を計算
   float r = calcY * col;
   float c = 1-IN.color;
   c *= 5 * (1-Boost);
   
   if(c > 1.0)
   {
   		c = 1.0;
   }
   col = lerp(col,r,c);
   col.a = col_buf.a * IN.color;
   
   return col;
}

struct VS_OUTPUT2 {
   float4 Pos: POSITION;
   float2 texCoord: TEXCOORD0;
};

VS_OUTPUT2 WorldBase_Vertex_Shader_main(float4 Pos: POSITION, float2 Tex: TEXCOORD) {
   VS_OUTPUT2 Out;
  
   Out.Pos = Pos;
   Out.texCoord = Tex ;
   return Out;
}
//座標をテクスチャに保存
float4 WorldBase1_Pixel_Shader_main(float2 texCoord: TEXCOORD0) : COLOR {
   float2 texWork = texCoord;
   
    int idx = round(texWork.x*TEX_WIDTH)+round(texWork.y*TEX_HEIGHT)*TEX_WIDTH;
   
   //IDがLINE_LENGTH(先頭）だったらワールド移動値を保存
   //また、再生されて0.05秒間は初期位置に合わせる
   if(idx == 0 || time_0_X < 0.05)
   {
   		return float4(world_matrix._11_12_13,0);
   }else{
	   
	   //IDからUV座標を計算
	   idx-=1;
	   
	   float4 prev;
	   float2 base_tex_coord = float2( float(idx%TEX_WIDTH)/(float)TEX_WIDTH + 0.05, float(idx/TEX_WIDTH)/(float)TEX_HEIGHT + 0.05);
       prev = tex2D(WorldBase1, base_tex_coord);
	   
   	   return prev;
   }
}
float4 WorldBase2_Pixel_Shader_main(float2 texCoord: TEXCOORD0) : COLOR {
   float2 texWork = texCoord;
   int idx = round(texWork.x*TEX_WIDTH)+round(texWork.y*TEX_HEIGHT)*TEX_WIDTH;
   if(idx == 0 || time_0_X < 0.05)
   {
   		return float4(world_matrix._21_22_23,0);
   }else{
	   idx-=1;
	   float4 prev;
	   float2 base_tex_coord = float2( float(idx%TEX_WIDTH)/(float)TEX_WIDTH + 0.05, float(idx/TEX_WIDTH)/(float)TEX_HEIGHT + 0.05);
       prev = tex2D(WorldBase2, base_tex_coord);
   	   return prev;
   }
}
float4 WorldBase3_Pixel_Shader_main(float2 texCoord: TEXCOORD0) : COLOR {
   float2 texWork = texCoord;
   int idx = round(texWork.x*TEX_WIDTH)+round(texWork.y*TEX_HEIGHT)*TEX_WIDTH;
   if(idx == 0 || time_0_X < 0.05)
   {
   		return float4(world_matrix._31_32_33,0);
   }else{
	   idx-=1;
	   float4 prev;
	   float2 base_tex_coord = float2( float(idx%TEX_WIDTH)/(float)TEX_WIDTH + 0.05, float(idx/TEX_WIDTH)/(float)TEX_HEIGHT + 0.05);
       prev = tex2D(WorldBase3, base_tex_coord);
   	   return prev;
   }
}
float4 WorldBase4_Pixel_Shader_main(float2 texCoord: TEXCOORD0) : COLOR {
   float2 texWork = texCoord;
   int idx = round(texWork.x*TEX_WIDTH)+round(texWork.y*TEX_HEIGHT)*TEX_WIDTH;
   if(idx == 0 || time_0_X < 0.05)
   {
   		return float4(world_matrix._41_42_43,0);
   }else{
	   idx-=1;
	   float4 prev;
	   float2 base_tex_coord = float2( float(idx%TEX_WIDTH)/(float)TEX_WIDTH + 0.05, float(idx/TEX_WIDTH)/(float)TEX_HEIGHT + 0.05);
       prev = tex2D(WorldBase4, base_tex_coord);
       prev += normalize(tex2D(WorldBase2, base_tex_coord)) * LineSpd;
   	   return prev;
   }
}

technique lineSystem <
    string Script = 
	    "RenderDepthStencilTarget=DepthBuffer;"
        "RenderColorTarget0=WorldTex1;"
	    "Pass=WorldBase1;"
	    "RenderColorTarget0=WorldTex2;"
	    "Pass=WorldBase1;"
	    "RenderColorTarget0=WorldTex3;"
	    "Pass=WorldBase2;"
	    "RenderColorTarget0=WorldTex4;"
	    "Pass=WorldBase4;"
        "RenderColorTarget0=;"
	    "RenderDepthStencilTarget=;"
	    "Pass=lineSystem;"
    ;
> {
	pass WorldBase1 < string Script = "Draw=Buffer;";>
	{
	    ALPHABLENDENABLE = FALSE;
	    ALPHATESTENABLE=FALSE;
	    VertexShader = compile vs_1_1 WorldBase_Vertex_Shader_main();
	    PixelShader = compile ps_2_0 WorldBase1_Pixel_Shader_main();
	}
	pass WorldBase2 < string Script = "Draw=Buffer;";>
	{
	    ALPHABLENDENABLE = FALSE;
	    ALPHATESTENABLE=FALSE;
	    VertexShader = compile vs_1_1 WorldBase_Vertex_Shader_main();
	    PixelShader = compile ps_2_0 WorldBase2_Pixel_Shader_main();
	}
	pass WorldBase3 < string Script = "Draw=Buffer;";>
	{
	    ALPHABLENDENABLE = FALSE;
	    ALPHATESTENABLE=FALSE;
	    VertexShader = compile vs_1_1 WorldBase_Vertex_Shader_main();
	    PixelShader = compile ps_2_0 WorldBase3_Pixel_Shader_main();
	}
	pass WorldBase4 < string Script = "Draw=Buffer;";>
	{
	    ALPHABLENDENABLE = FALSE;
	    ALPHATESTENABLE=FALSE;
	    VertexShader = compile vs_1_1 WorldBase_Vertex_Shader_main();
	    PixelShader = compile ps_2_0 WorldBase4_Pixel_Shader_main();
	}
   pass lineSystem
   {
      ZENABLE = TRUE;
      ZWRITEENABLE = FALSE;
      CULLMODE = NONE;
      ALPHABLENDENABLE = TRUE;
      SRCBLEND=BLENDMODE_SRC;
      DESTBLEND=BLENDMODE_DEST;
      VertexShader = compile vs_3_0 lineSystem_Vertex_Shader_main();
      PixelShader = compile ps_3_0 lineSystem_Pixel_Shader_main();
   }
}

