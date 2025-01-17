

//---複製数---//

//フラッシュ
int FlashNum = 1;
//煙
int SmokeNum = 8;
//爆炎
int FireNum = 64;
//パーティクル
int ParticleNum = 128;


float DefAlpha = 1;

float4x4 world_view_proj_matrix : WorldViewProjection;
float4x4 world_view_trans_matrix : WorldViewTranspose;
float4x4 inv_view_matrix : WORLDVIEWINVERSE;
float4x4 world_matrix : World;
static float3 billboard_vec_x = normalize(world_view_trans_matrix[0].xyz);
static float3 billboard_vec_y = normalize(world_view_trans_matrix[1].xyz);

float time_0_X : Time;
float particleSystemShape = float( 1.00 );
float particleSpread = float( 20.00 );
float particleSpeed = float( 0.48 );
float particleSystemHeight = float( 80.00 );
float particleSize = float( 5 );
//回転速度
float RotateSpd = float(0.15);
//縮小速度（0：縮小しない）
float ScaleSpd = float(0);

float3   CameraPosition    : POSITION  < string Object = "Camera"; >;

// The model for the particle system consists of a hundred quads.
// These quads are simple (-1,-1) to (1,1) quads where each quad
// has a z ranging from 0 to 1. The z will be used to differenciate
// between different particles

//カウント用変数
int index = 0;

texture2D rndtex <
    string ResourceName = "random1024.bmp";
>;
sampler rnd = sampler_state {
    texture = <rndtex>;
};

float4   MaterialDiffuse   : DIFFUSE  < string Object = "Geometry"; >;

struct VS_OUTPUT {
   float4 Pos: POSITION;
   float2 texCoord: TEXCOORD0;
   float color: TEXCOORD1;
};

float4x4 view_trans_matrix : ViewTranspose;
VS_OUTPUT AllFunc(int num,float4 Pos,float Scale,float ParticleLen,float AlphaSpd,float rndadd,float up)
{
  VS_OUTPUT Out;
   
   Out.texCoord = Pos.xy*0.5+0.5;
   Out.texCoord *= 0.5;

   float fi = index;
   fi = fi/num;

   float t = 1 - frac(fi + particleSpeed);
   float s = pow(t, particleSystemShape);

   float4 rand_col = tex2Dlod(rnd, float4(fi+rndadd+num*0.123,0,0,1));
   float r = rand_col.r;
   float3 pos;
   float len = (MaterialDiffuse.a);
   len = 1-len * len;
   len *= (2 + t);

   len *= ParticleLen;
   
   len *= rand_col.b;
   
   float4 rand_col_2 = tex2Dlod(rnd, float4(fi+rndadd+num*0.345,0,0,1));
   
   pos.x = cos(r*2*3.1415)*len*25;
   pos.z = sin(r*2*3.1415)*len*25;
   pos.y = up*40*len;
   
   pos.xyz *= rand_col_2.rgb*0.5;

   float3 w = (particleSize * float3(Pos.xy - float2(0,0),0)) * max(0,(1-t * ScaleSpd));
   //通常回転
   //回転行列の作成
   if(up == 0)
   {
	   float3 Eye = normalize(CameraPosition - Pos.xyz);
	   float rad = dot(float3(1,0,0),world_matrix[1]);
	   float4x4 matRot;
	   matRot[0] = float4(cos(rad),sin(rad),0,0); 
	   matRot[1] = float4(-sin(rad),cos(rad),0,0); 
	   matRot[2] = float4(0,0,1,0); 
	   matRot[3] = float4(0,0,0,1); 
	   //w = mul(w,matRot);
	   
	   //拡大
	   w = mul(w,length(world_matrix[0])*0.5*Scale);
   }else{
	   float rad = time_0_X * RotateSpd*(0.5-r) + t + cos(62 * r);
	   float4x4 matRot;
	   matRot[0] = float4(cos(rad),sin(rad),0,0); 
	   matRot[1] = float4(-sin(rad),cos(rad),0,0); 
	   matRot[2] = float4(0,0,1,0); 
	   matRot[3] = float4(0,0,0,1); 
	   w = mul(w,matRot);
	   //ビルボード回転
	   w = mul(w,inv_view_matrix);
   //拡大
   w = mul(w,length(world_matrix[0])*1*Scale);
	}

   // Billboard the quads.
   // The view matrix gives us our right and up vectors.
   //pos += (Pos.x * view_trans_matrix[0] + Pos.y * view_trans_matrix[1]);
   pos += w;
   pos /= 10;
   
   
   Out.Pos = mul(float4(pos, 1), world_view_proj_matrix);

   Out.color = MaterialDiffuse.a*(1-AlphaSpd);
   Out.color = lerp(0,1,Out.color);
	
	
	if(AlphaSpd == 0)
	{
		Out.color = 1-pow((1-MaterialDiffuse.a),2);
	}
   return Out;
}
VS_OUTPUT ParticleFunc(int num,float4 Pos,float Scale,float ParticleLen,float AlphaSpd,float rndadd)
{
  VS_OUTPUT Out;
   
   Out.texCoord = Pos.xy*0.48+0.5;
   Out.texCoord *= 0.5;
   Out.texCoord+=0.01;
   float fi = index;
   fi = fi/num;
	float r = tex2Dlod(rnd, float4(fi+rndadd,0,0,1));
   float t = 1 - frac(fi + particleSpeed);
   float s = pow(t, particleSystemShape);

   float3 pos;
   float len = 1 * (MaterialDiffuse.a);
   len = 1-len * len;
   len *= (2 + t);

   len *= ParticleLen;
   
   pos.x = particleSpread * cos(48 * r) * len;
   pos.z = particleSpread * cos(68 * r) * len;
   pos.y = particleSpread * cos(12 * r) * len;

   float3 w = (particleSize * float3(Pos.xy - float2(0,0),0)) * max(0,(1-t * ScaleSpd));
   //通常回転
   //回転行列の作成
   float rad = t * RotateSpd + cos(62 * fi);
   float4x4 matRot;
   matRot[0] = float4(cos(rad),sin(rad),0,0); 
   matRot[1] = float4(-sin(rad),cos(rad),0,0); 
   matRot[2] = float4(0,0,1,0); 
   matRot[3] = float4(0,0,0,1); 
   w = mul(w,matRot);
   //ビルボード回転
   w = mul(w,inv_view_matrix);
   //拡大
   w = mul(w,length(world_matrix[0])*2*Scale) * (MaterialDiffuse.a*(1-AlphaSpd)*0.25 - t*0.25);

   // Billboard the quads.
   // The view matrix gives us our right and up vectors.
   //pos += (Pos.x * view_trans_matrix[0] + Pos.y * view_trans_matrix[1]);
   pos += w;
   pos /= 10;
   
   
   Out.Pos = mul(float4(pos, 1), world_view_proj_matrix);

   Out.color = 1;	

   return Out;
}
VS_OUTPUT FlashVS(float4 Pos: POSITION){
   VS_OUTPUT Out = (VS_OUTPUT)0;
   if(MaterialDiffuse.a != 0 && MaterialDiffuse.a != 1)
   {
   		Out = AllFunc(FlashNum,Pos,5,0,0.75,0,0);
   		Out.color = pow(Out.color,2)*16;
	    if(Out.texCoord.y > 0.25)
		    Out.texCoord.y -= 0.05;
	    else
	    	Out.texCoord.y += 0.05;
	    Out.texCoord.y += 0.5;
   }
   return Out;
}
VS_OUTPUT SmokeVS(float4 Pos: POSITION){
   VS_OUTPUT Out = (VS_OUTPUT)0;
   if(MaterialDiffuse.a != 0 && MaterialDiffuse.a != 1)
   {
   		Out = AllFunc(SmokeNum,Pos,2,2,0,0.25,1);
   }
   return Out;
}
VS_OUTPUT FireVS(float4 Pos: POSITION){
   VS_OUTPUT Out = (VS_OUTPUT)0;
   if(MaterialDiffuse.a != 0 && MaterialDiffuse.a != 1)
   {
   		Out = AllFunc(FireNum,Pos,0.75,5,0,0.25,1);
	    Out.texCoord.x += 0.5;
   }
   return Out;
}

VS_OUTPUT ParticleVS(float4 Pos: POSITION){
   VS_OUTPUT Out = (VS_OUTPUT)0;
   if(MaterialDiffuse.a != 0 && MaterialDiffuse.a != 1)
   {
   		Out = ParticleFunc(ParticleNum,Pos,0.25,1,-1,0);
   		Out.texCoord.xy += 0.5;
   }
   return Out;
}
float particleShape
<
   string UIName = "particleShape";
   string UIWidget = "Numeric";
   bool UIVisible =  true;
   float UIMin = 0.00;
   float UIMax = 1.00;
> = float( 0.37 );
texture Particle_Tex
<
   string ResourceName = "particle.png";
>;
sampler Particle = sampler_state
{
   Texture = (Particle_Tex);
   ADDRESSU = CLAMP;
   ADDRESSV = CLAMP;
   MAGFILTER = LINEAR;
   MINFILTER = LINEAR;
   MIPFILTER = NONE;
};
float4 AllPS(float2 texCoord: TEXCOORD0, float color: TEXCOORD1) : COLOR {
   float4 col = tex2D(Particle,texCoord-0.005);
   col.a *= color * DefAlpha;

   return col;
}
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
//--------------------------------------------------------------//
// Technique Section for Effect Workspace.Particle Effects.FireParticleSystem
//--------------------------------------------------------------//
technique FireParticleSystem <
    string Script = 
    
		"LoopByCount=SmokeNum;"
        "LoopGetIndex=index;"
	    "Pass=SmokePass;"
        "LoopEnd=;"

		"LoopByCount=FlashNum;"
        "LoopGetIndex=index;"
	    "Pass=FlashPass;"
        "LoopEnd=;"
        
		"LoopByCount=FireNum;"
        "LoopGetIndex=index;"
	    "Pass=FirePass;"
        "LoopEnd=;"
        
		"LoopByCount=ParticleNum;"
        "LoopGetIndex=index;"
	    "Pass=ParticlePass;"
        "LoopEnd=;"
        
    ;
> {
   pass FlashPass
   {
      ZENABLE = TRUE;
      ZWRITEENABLE = FALSE;
      CULLMODE = NONE;
      ALPHABLENDENABLE = TRUE;
      SRCBLEND = SRCALPHA;
      DESTBLEND = ONE;

      VertexShader = compile vs_3_0 FlashVS();
      PixelShader = compile ps_3_0 AllPS();
   }
   pass SmokePass
   {
      ZENABLE = TRUE;
      ZWRITEENABLE = FALSE;
      CULLMODE = NONE;
      ALPHABLENDENABLE = TRUE;
      SRCBLEND = SRCALPHA;
      DESTBLEND = INVSRCALPHA;

      VertexShader = compile vs_3_0 SmokeVS();
      PixelShader = compile ps_3_0 AllPS();
   }
   pass FirePass
   {
      ZENABLE = TRUE;
      ZWRITEENABLE = FALSE;
      CULLMODE = NONE;
      ALPHABLENDENABLE = TRUE;
      SRCBLEND = SRCALPHA;
      DESTBLEND = INVSRCALPHA;

      VertexShader = compile vs_3_0 FireVS();
      PixelShader = compile ps_3_0 AllPS();
   }
   
   pass ParticlePass
   {
      ZENABLE = TRUE;
      ZWRITEENABLE = FALSE;
      CULLMODE = NONE;
      ALPHABLENDENABLE = TRUE;
      SRCBLEND = SRCALPHA;
      DESTBLEND = ONE;

      VertexShader = compile vs_3_0 ParticleVS();
      PixelShader = compile ps_3_0 AllPS();
   }
}

