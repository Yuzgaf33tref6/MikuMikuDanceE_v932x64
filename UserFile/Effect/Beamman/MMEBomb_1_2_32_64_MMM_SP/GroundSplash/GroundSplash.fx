

//---������---//

//���Ԃ�
int ParticleNum = 512;
int Particle2Num = 128;


float DefAlpha = 0.5;


//�[�x�}�b�v�ۑ��e�N�X�`��
shared texture2D SPE_DepthTex : RENDERCOLORTARGET;
sampler2D SPE_DepthSamp = sampler_state {
    texture = <SPE_DepthTex>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = NONE;
    AddressU  = CLAMP;
    AddressV = CLAMP;
};
//�\�t�g�p�[�e�B�N���G���W���g�p�t���O
bool use_spe : CONTROLOBJECT < string name = "SoftParticleEngine.x"; >;
float4x4 world_view_proj_matrix : WorldViewProjection;
float4x4 world_view_trans_matrix : WorldViewTranspose;
float4x4 inv_view_matrix : WORLDVIEWINVERSE;
float4x4 world_matrix : World;
float3   CameraPosition    : POSITION  < string Object = "Camera"; >;
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
   float2 Tex: TEXCOORD0;
   float color: TEXCOORD1;
   float3 Eye	: TEXCOORD2;
   float3 WPos: TEXCOORD3;
   float4 LastPos: TEXCOORD4;
};

VS_OUTPUT ParticleFunc(int num,float4 Pos,float deflen,float maxlen,float maxheight,float spd)
{
  VS_OUTPUT Out;
   
   Out.Tex = Pos.xy*0.5+0.5;

   float fi = index;
   fi = fi/num;
   float r = tex2Dlod(rnd, float4(fi,0,0,1));
   float t = 1 - frac(fi + particleSpeed);
   float s = pow(t, particleSystemShape); 

   float3 pos;
   float len = 1 * (MaterialDiffuse.a);
   len = 1-len * len;
   len *= t*maxlen;
   
   len += deflen;
   
   pos.x = particleSpread * cos(r*8) * len;
   pos.z = particleSpread * sin(r*8) * len;
   
   float m = max(0,MaterialDiffuse.a - spd);
   
   pos.y = 1+abs(sin((1-m)*3.1415*1)) * 10*fi*maxheight;

   float3 w = (particleSize * float3(Pos.xy - float2(0,0),0)) * max(0,(1-t * ScaleSpd));
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

   Out.color = MaterialDiffuse.a - t*0.25;
   Out.color = lerp(0,Out.color,min(1,(1-MaterialDiffuse.a)*32));

	pos = mul(float4(pos,1),world_matrix);

	Out.LastPos = Out.Pos;
	Out.WPos = pos;
	Out.Eye = pos - CameraPosition;

   return Out;
}

VS_OUTPUT ParticleVS(float4 Pos: POSITION){
   VS_OUTPUT Out = (VS_OUTPUT)0;
   if(MaterialDiffuse.a != 0 && MaterialDiffuse.a != 1)
   {
   		Out = ParticleFunc(ParticleNum,Pos,0.5,1,1,0.2);
   }
   return Out;
}
VS_OUTPUT Particle2VS(float4 Pos: POSITION){
   VS_OUTPUT Out = (VS_OUTPUT)0;
   if(MaterialDiffuse.a != 0 && MaterialDiffuse.a != 1)
   {
   		Out = ParticleFunc(Particle2Num,Pos,0,1,5,0);
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
   string ResourceName = "Splash.png";
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
float4 AllPS(VS_OUTPUT IN) : COLOR {
   float4 col = tex2D(Particle,IN.Tex-0.005);
   col.a *= IN.color * DefAlpha;
   
	if(use_spe)
	{
		float2 ScTex = IN.LastPos.xyz/IN.LastPos.w;
		ScTex.y *= -1;
		ScTex.xy += 1;
		ScTex.xy *= 0.5;
	    // �[�x
	    float dep = length(CameraPosition - IN.WPos);
	    float scrdep = tex2D(SPE_DepthSamp,ScTex).r;

	    //return float4(smoothstep(0,59,scrdep),0,0,1);
	    //return float4(smoothstep(0,59,dep),0,0,1);
	    
	    float adddep = 1-saturate(length(abs(frac(IN.Tex*4)-0.5)));
	    dep = length(dep-scrdep);
	    dep = smoothstep(0,10,dep);
	    col.a *= dep;
    }
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
        
		"LoopByCount=Particle2Num;"
        "LoopGetIndex=index;"
	    "Pass=Particle2Pass;"
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
   pass Particle2Pass
   {
      ZENABLE = TRUE;
      ZWRITEENABLE = FALSE;
      CULLMODE = NONE;
      ALPHABLENDENABLE = TRUE;
      SRCBLEND = SRCALPHA;
      DESTBLEND = INVSRCALPHA;

      VertexShader = compile vs_3_0 Particle2VS();
      PixelShader = compile ps_3_0 AllPS();
   }
}

