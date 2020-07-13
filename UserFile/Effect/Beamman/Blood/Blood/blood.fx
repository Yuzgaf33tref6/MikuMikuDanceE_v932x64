

//---������---//

//���Ԃ�
int ParticleNum = 32;


float DefAlpha = 1;

float4x4 world_view_proj_matrix : WorldViewProjection;
float4x4 world_view_trans_matrix : WorldViewTranspose;
float4x4 inv_view_matrix : WORLDVIEWINVERSE;
float4x4 world_matrix : World;
float4x4 inv_world_matrix : WORLDINVERSE;
static float3 billboard_vec_x = normalize(world_view_trans_matrix[0].xyz);
static float3 billboard_vec_y = normalize(world_view_trans_matrix[1].xyz);

float time_0_X : Time;
float particleSystemShape = float( 1.00 );
float particleSpread = float( 20.00 );
float particleSpeed = float( 0.48 );
float particleSystemHeight = float( 80.00 );
float particleSize = float( 5 );
//��]���x
float RotateSpd = float(0.15);
//�k�����x�i0�F�k�����Ȃ��j
float ScaleSpd = float(0);


// The model for the particle system consists of a hundred quads.
// These quads are simple (-1,-1) to (1,1) quads where each quad
// has a z ranging from 0 to 1. The z will be used to differenciate
// between different particles

//�J�E���g�p�ϐ�
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

VS_OUTPUT ParticleFunc(int num,float4 Pos,float deflen,float maxlen,float maxheight,float spd)
{
  VS_OUTPUT Out;
   
   Out.texCoord = Pos.xy*0.5+0.5;

   float fi = index;
   fi = fi/num;
   float r = tex2Dlod(rnd, float4(fi,0,0,1));
   float t = 1 - frac(fi * particleSpeed * 123);
   float s = pow(t, particleSystemShape); 

   float3 pos;
   float len = 1 * (MaterialDiffuse.a);
   len = 1-len * len;
   len *= t*maxlen;
   
   len += deflen;
   
   pos.x = particleSpread * cos(r*8) * len;
   pos.z = particleSpread * sin(r*8) * len;
   
   float m = max(0,MaterialDiffuse.a - spd);
   
   float4x4 rot = inv_world_matrix;
   rot[3].xyz = 0;
   float3 DownVec = normalize(mul(float3(0,1,0),rot));
   
   float work = 1 * (1-MaterialDiffuse.a);
   pos.y = 1+abs(1-(pow(m,8))) * 10*fi*maxheight + 5 * work;   
   pos -= DownVec * pow(work,1) * pow(pos.y,2)*0.015;

   float scl = max(0,MaterialDiffuse.a - t*0.25);
   float3 w = (particleSize * float3(Pos.xy - float2(0,0),0)) * max(0,(1-t * ScaleSpd))*scl;
   //�ʏ��]
   //��]�s��̍쐬
   float rad = t * RotateSpd + cos(62 * fi);
   float4x4 matRot;
   matRot[0] = float4(cos(rad),sin(rad),0,0); 
   matRot[1] = float4(-sin(rad),cos(rad),0,0); 
   matRot[2] = float4(0,0,1,0); 
   matRot[3] = float4(0,0,0,1); 
   w = mul(w,matRot);
   //�r���{�[�h��]
   w = mul(w,inv_view_matrix);
   //�g��
   w = mul(w,length(world_matrix[0])*1);

   // Billboard the quads.
   // The view matrix gives us our right and up vectors.
   //pos += (Pos.x * view_trans_matrix[0] + Pos.y * view_trans_matrix[1]);
   pos += w;
   pos /= 10;
   
   
   Out.Pos = mul(float4(pos, 1), world_view_proj_matrix);

   Out.color = 1;//MaterialDiffuse.a - t*0.25;
   //Out.color = lerp(0,Out.color,min(1,(1-MaterialDiffuse.a)*32));

   return Out;
}

VS_OUTPUT ParticleVS(float4 Pos: POSITION){
   VS_OUTPUT Out = (VS_OUTPUT)0;
   if(MaterialDiffuse.a != 0 && MaterialDiffuse.a != 1)
   {
   		Out = ParticleFunc(ParticleNum,Pos,0,0.25,5,0);
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
   string ResourceName = "blood.png";
>;
sampler Particle = sampler_state
{
   Texture = (Particle_Tex);
   ADDRESSU = CLAMP;
   ADDRESSV = CLAMP;
   MAGFILTER = LINEAR;
   MINFILTER = LINEAR;
   MIPFILTER = LINEAR;
};
float4 AllPS(float2 texCoord: TEXCOORD0, float color: TEXCOORD1) : COLOR {
   float4 col = tex2D(Particle,texCoord-0.005);
   col.a *= color * DefAlpha;
   return col;
}
//�������@�̐ݒ�
//
//�����������F
//BLENDMODE_SRC SRCALPHA
//BLENDMODE_DEST INVSRCALPHA
//
//���Z�����F
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

		"LoopByCount=ParticleNum;"
        "LoopGetIndex=index;"
	    "Pass=ParticlePass;"
        "LoopEnd=;"
    ;
> {
   pass ParticlePass
   {
      ZENABLE = TRUE;
      ZWRITEENABLE = FALSE;
      CULLMODE = NONE;
      ALPHABLENDENABLE = TRUE;
      SRCBLEND = SRCALPHA;
      DESTBLEND = INVSRCALPHA;

      VertexShader = compile vs_3_0 ParticleVS();
      PixelShader = compile ps_3_0 AllPS();
   }
}

