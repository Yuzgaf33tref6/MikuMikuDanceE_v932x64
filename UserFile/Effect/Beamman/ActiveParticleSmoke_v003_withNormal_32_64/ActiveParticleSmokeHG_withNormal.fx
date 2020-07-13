//Beam�ǉ�
//�������̐F
float3 FireColor = {1.0,0.5,0.0};

////////////////////////////////////////////////////////////////////////////////////////////////
//
//  ActiveParticleSmokeHG.fx ver0.0.3 �[���~�T�C�����ۂ��G�t�F�N�gHG��
//  �I�u�W�F�N�g�̈ړ��ɉ����ĉ������������܂�(���q��16384�̃n�C�O���[�h��)  �쐬: �j��P
//
////////////////////////////////////////////////////////////////////////////////////////////////
// �����̃p�����[�^��ύX���Ă�������
float3 ParticleColor = {1.0, 1.0, 1.0}; // �e�N�X�`���̏�Z�F(RBG)
float ParticleSize = 1.0;          // ���q�傫��
float ParticleSpeed = 1.0;         // ���q�X�s�[�h
float ParticleInitPos = 0.5;       // ���q�������̑��Έʒu(�傫������Ɨ��q�̔z�u���΂���܂�)
float ParticleLife = 1.0;          // ���q�̎���(�b)
float ParticleDecrement = 0.3;     // ���q���������J�n���鎞��(0.0�`1.0:ParticleLife�Ƃ̔�)
float ParticleDiffusion = 2.0;     // ���q������̊g�U�x
float CoefProbable = 0.001;       // �I�u�W�F�N�g�ړ��ʂɑ΂��闱�q�����x(�傫������Ɨ��q���o�₷���Ȃ�)
float ObjVelocityRate = -2.0;      // �I�u�W�F�N�g�ړ������ɑ΂��闱�q���x�ˑ��x

float3 GravFactor = {0.0, 0.0, 0.0};   // �d�͒萔
float ResistFactor = 1.0;              // ���x��R�W��

// (������)��Ԃ̗�������`����֐�
// ���q�ʒuParticlePos�ɂ������C�̗�����L�q���܂��B
// �߂�l��0�ȊO�̎��̓I�u�W�F�N�g�������Ȃ��Ă����q����o���܂��B
// ���x��R�W����ResistFactor>0�łȂ��Ɨ��q�̓����ɉe����^���܂���B
float3 VelocityField(float3 ParticlePos)
{
   float3 vel = float3( 0.0, 0.0, 0.0 );
   return vel;
}


// ����Ȃ��l�͂������牺�͂�����Ȃ��ł�

texture Particle_Tex
<
   string ResourceName = "Tex.png";
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

texture NormalBase_Tex
<
   string ResourceName = "NormalBase.png";
>;
sampler NormalBase = sampler_state
{
   Texture = (NormalBase_Tex);
   ADDRESSU = CLAMP;
   ADDRESSV = CLAMP;
   MAGFILTER = LINEAR;
   MINFILTER = LINEAR;
   MIPFILTER = NONE;
};

////////////////////////////////////////////////////////////////////////////////////////////////
// �p�����[�^�錾
#define TexFile  "Smoke.png" // ���q�ɓ\��t����e�N�X�`���t�@�C����
#define ArrangeFileName "ArrangeHG.png" // �z�u��������t�@�C����
#define TEX_WIDTH_A 128   // �z�u��������e�N�X�`���s�N�Z����
#define TEX_WIDTH    16   // ���W���e�N�X�`���s�N�Z����
#define TEX_HEIGHT 1024   // �z�u��������e�N�X�`���s�N�Z������

float AcsTr  : CONTROLOBJECT < string name = "(self)"; string item = "Tr"; >;
float AcsSi  : CONTROLOBJECT < string name = "(self)"; string item = "Si"; >;

float time : TIME;
float elapsed_time : ELAPSEDTIME;
static float Dt = (elapsed_time < 0.2f) ? clamp(elapsed_time, 0.001f, 1.0f/15.0f) : 1.0f/30.0f;

// ���W�ϊ��s��
float4x4 WorldMatrix          : WORLD;
float4x4 ViewProjMatrix       : VIEWPROJECTION;
float4x4 ViewMatrixInverse    : VIEWINVERSE;

float3   LightDirection    : DIRECTION < string Object = "Light"; >;
float3   LightColor      : SPECULAR   < string Object = "Light"; >;
float3   CameraPosition    : POSITION  < string Object = "Camera"; >;


static float3x3 BillboardMatrix = {
    normalize(ViewMatrixInverse[0].xyz),
    normalize(ViewMatrixInverse[1].xyz),
    normalize(ViewMatrixInverse[2].xyz),
};

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

// �z�u��������e�N�X�`��
texture2D ArrangeTex <
    string ResourceName = ArrangeFileName;
>;
sampler ArrangeSmp = sampler_state{
    texture = <ArrangeTex>;
    MinFilter = POINT;
    MagFilter = POINT;
    MipFilter = NONE;
};

// ���q���W�L�^�p
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

// 1�X�e�b�v�O�̍��W�L�^�p
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

// ���q���x�L�^�p
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

// �I�u�W�F�N�g�̃��[���h���W�L�^�p
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

////////////////////////////////////////////////////////////////////////////////////////////////
// �z�u��������e�N�X�`������f�[�^�����o��
float Color2Float(int i, int j)
{
    float4 d = tex2Dlod(ArrangeSmp, float4((i+0.5)/TEX_WIDTH_A, (j+0.5)/TEX_HEIGHT, 0, 1));
    float tNum = (65536.0f * d.x + 256.0f * d.y + d.z) * 255.0f;
    int pNum = (int)(d.w * 255);
    int sgn = 1 - 2 * (pNum % 2);
    float data = tNum * pow(10.0f, pNum/2 - 64) * sgn;
    return data;
}

float Color2FloatPS(int i, int j)
{
    float4 d = tex2D(ArrangeSmp, float2((i+0.5)/TEX_WIDTH_A, (j+0.5)/TEX_HEIGHT));
    float tNum = (65536.0f * d.x + 256.0f * d.y + d.z) * 255.0f;
    int pNum = (int)(d.w * 255);
    int sgn = 1 - 2 * (pNum % 2);
    float data = tNum * pow(10.0f, pNum/2 - 64) * sgn;
    return data;
}

////////////////////////////////////////////////////////////////////////////////////////////////
// ���W��2D��]
float2 Rotation2D(float2 pos, float rot)
{
    float x = pos.x * cos(rot) - pos.y * sin(rot);
    float y = pos.x * sin(rot) + pos.y * cos(rot);

    return float2(x,y);
}

////////////////////////////////////////////////////////////////////////////////////////////////

struct VS_OUTPUT {
   float4 Pos      : POSITION;
   float2 texCoord : TEXCOORD0;
};

// ���ʂ̒��_�V�F�[�_
VS_OUTPUT Common_VS(float4 Pos: POSITION, float2 Tex: TEXCOORD) {
   VS_OUTPUT Out = (VS_OUTPUT)0;
   Out.Pos = Pos;
   Out.texCoord = Tex + float2(0.5f/TEX_WIDTH, 0.5f/TEX_HEIGHT);
   return Out;
}

////////////////////////////////////////////////////////////////////////////////////////
// �����W�l��1�X�e�b�v�O�̍��W�ɃR�s�[

float4 PosCopy_PS(float2 texCoord: TEXCOORD0) : COLOR
{
   float4 Pos = tex2D(CoordSmp, texCoord);
   return Pos;
}

////////////////////////////////////////////////////////////////////////////////////////
// ���q�̔����E���W�X�V�v�Z(xyz:���W,w:�o�ߎ���)

float4 UpdatePos_PS(float2 texCoord: TEXCOORD0) : COLOR
{
   // ���q�̍��W
   float4 Pos = tex2D(CoordSmp, texCoord);

   // ���q�̑��x
   float4 Vel = tex2D(VelocitySmp, texCoord);

   if(Pos.w < 0.001f){
   // ���������q�̒�����ړ������ɉ����ĐV���ɗ��q�𔭐�������
      // ���݂̃I�u�W�F�N�g���W
      float3 WPos1 = WorldMatrix._41_42_43;

      // 1�X�e�b�v�O�̃I�u�W�F�N�g���W
      float4 WPos0 = tex2D(WorldCoordSmp, float2(0.5f, 0.5f));
      WPos0.xyz -= VelocityField(WPos1) * Dt; // ���̑��x��ʒu�␳

      // ���q�����m��
      int i = floor( texCoord.x*TEX_WIDTH ) * 8;
      int j = floor( texCoord.y*TEX_HEIGHT );
      float probable = length( WPos1 - WPos0.xyz ) * CoefProbable * AcsSi*0.1f;

      // �V���ɗ��q�𔭐������邩�ǂ����̔���
      float probable0 = Color2FloatPS(i+7, j);
      if(WPos0.w<probable0 && probable0<WPos0.w+probable){
         // ���q�������W
         float s = (probable0 - WPos0.w) / probable;
         Pos.xyz = lerp(WPos0.xyz, WPos1, s) + Vel.xyz * ParticleInitPos;
         Pos.w = 0.0011f;  // Pos.w>0.001�ŗ��q����
      }else{
         Pos.xyz = WPos1;
      }
   }else{
   // ���������q�̍��W���X�V
      // 1�X�e�b�v�O�̈ʒu
      float4 Pos0 = tex2D(CoordSmpOld, texCoord);

      // �����x�v�Z(���x��R��+�d��)
      float3 Accel = ( VelocityField(Pos0.xyz) - Vel.xyz ) * ResistFactor + GravFactor;

      // �V�������W�ɍX�V
      Pos.xyz = Pos0.xyz + Dt * (Vel.xyz + Dt * Accel);

      // ���łɔ������Ă��闱�q�͌o�ߎ��Ԃ�i�߂�
      Pos.w += Dt;
      Pos.w *= step(Pos.w, ParticleLife); // �w�莞�Ԃ𒴂����0(���q����)
   }

   return Pos;
}

////////////////////////////////////////////////////////////////////////////////////////
// ���q�̑��x�v�Z

float4 UpdateVelocity_PS(float2 texCoord: TEXCOORD0) : COLOR
{
   // ���q�̍��W
   float4 Pos = tex2D(CoordSmp, texCoord);

   // ���q�̑��x
   float4 Vel = tex2D(VelocitySmp, texCoord);

   if(Pos.w < 0.00111f){
      // ���������Ă̗��q�ɏ����x��^����
      int i = floor( texCoord.x*TEX_WIDTH ) * 8;
      int j = floor( texCoord.y*TEX_HEIGHT );
      float3 pVel = float3(Color2FloatPS(i, j), Color2FloatPS(i+1, j), Color2FloatPS(i+2, j))*ParticleSpeed;
      float4 WPos0 = tex2D(WorldCoordSmp, float2(0.5f, 0.5f));
      float3 WPos1 = WorldMatrix._41_42_43;
      float3 wVel = normalize(WPos1-WPos0.xyz)*ObjVelocityRate; // �I�u�W�F�N�g�ړ�������t������
      Vel = float4( wVel+pVel, 1.0f )  ;
   }else{
      // ���������q�̑��x�v�Z
      float4 Pos0 = tex2D(CoordSmpOld, texCoord);
      Vel.xyz = ( Pos.xyz - Pos0.xyz ) / Dt;
   }

   return Vel;
}

////////////////////////////////////////////////////////////////////////////////////////////////
// �I�u�W�F�N�g�̃��[���h���W�L�^

VS_OUTPUT WorldCoord_VS(float4 Pos : POSITION)
{
    VS_OUTPUT Out = (VS_OUTPUT)0; 

    Out.Pos = Pos;
    Out.texCoord = float2(0.5f, 0.5f);

    return Out;
}

float4 WorldCoord_PS(float2 Tex: TEXCOORD0) : COLOR
{
   // �I�u�W�F�N�g�̃��[���h���W
   float3 Pos1 = WorldMatrix._41_42_43;
   float4 Pos0 = tex2D(WorldCoordSmp, Tex);
   Pos0.xyz -= VelocityField(Pos1) * Dt; // ���̑��x��ʒu�␳

   // ���������q�̋N�_
   float probable = length( Pos1 - Pos0.xyz )*CoefProbable * AcsSi*0.1f;
   float w = Pos0.w + probable;
   w *= step(w, 1.0f);
   if(time < 0.001f) w = 0.0;

   float4 Pos = float4(WorldMatrix._41_42_43, w);

   return Pos;
}


///////////////////////////////////////////////////////////////////////////////////////
// �p�[�e�B�N���`��
struct VS_OUTPUT2
{
    float4 Pos        : POSITION;    // �ˉe�ϊ����W
    float2 Tex        : TEXCOORD0;   // �e�N�X�`��
	float2 NormalTex  : TEXCOORD1;
	float3 Eye		  : TEXCOORD2;
	float  LocalTime  : TEXCOORD3;
    float4 Color      : COLOR0;      // ���q�̏�Z�F
};

// ���_�V�F�[�_
VS_OUTPUT2 Particle_VS(float4 Pos : POSITION, float2 Tex : TEXCOORD0)
{
   VS_OUTPUT2 Out;

   int Index0 = round( Pos.z * 100.0f );
   Pos.z = 0.0f;
   int i0 = Index0 / 1024;
   int i = i0 * 8;
   int j = Index0 % 1024;
   float2 texCoord = float2((i0+0.5)/TEX_WIDTH, (j+0.5)/TEX_HEIGHT);

   // ���q�̍��W
   float4 Pos0 = tex2Dlod(CoordSmp, float4(texCoord, 0, 1));

   // �o�ߎ��Ԃɑ΂��闱�q�g��x
   float scale = ParticleDiffusion * sqrt(Pos0.w) + 2.0f;
   // ���q�̑傫��
   Pos.xy *= (0.5f+Color2Float(i+3, j)) * ParticleSize * scale * 10.0f;

   // ���q�̉�]
   float rot = 6.18f * ( Color2Float(i+5, j) - 0.5f );
   Pos.xy = Rotation2D(Pos.xy, rot);
		
	Out.NormalTex =  Rotation2D(Tex*2-1,-rot);
	Out.NormalTex = Out.NormalTex*0.5+0.5;

   // �r���{�[�h
   Pos.xyz = mul( Pos.xyz, BillboardMatrix );

   // ���q�̃��[���h���W
   Pos.xyz += Pos0.xyz;
   Pos.w = 1.0f;
   
   
   Out.Eye = Pos.xyz - CameraPosition;
   

   // �J�������_�̃r���[�ˉe�ϊ�
   Out.Pos = mul( Pos, ViewProjMatrix );

   // ���q�̏�Z�F
   float alpha = step(0.01f, Pos0.w) * smoothstep(-ParticleLife, -ParticleLife*ParticleDecrement, -Pos0.w) * AcsTr;
   Out.Color = float4(ParticleColor, alpha);
   Out.LocalTime = pow(smoothstep(1, 0,Pos0.w),1);

   // �e�N�X�`�����W
   Out.Tex = Tex*0.25;
   	
	Index0 %= 16;
	
	int tw = Index0%4;
	int th = Index0/4;

	Out.Tex.x += tw*0.25;
	Out.Tex.y += th*0.25;

   return Out;
}
float3x3 compute_tangent_frame(float3 Normal, float3 View, float2 UV)
{
  float3 dp1 = ddx(View); 
  float3 dp2 = ddy(View);
  float2 duv1 = ddx(UV);
  float2 duv2 = ddy(UV);

  float3x3 M = float3x3(dp1, dp2, cross(dp1, dp2));
  float2x3 inverseM = float2x3(cross(M[1], M[2]), cross(M[2], M[0]));
  float3 Tangent = mul(float2(duv1.x, duv2.x), inverseM);
  float3 Binormal = mul(float2(duv1.y, duv2.y), inverseM);

  return float3x3(normalize(Tangent), normalize(Binormal), Normal);
}
// �s�N�Z���V�F�[�_
float4 Particle_PS( VS_OUTPUT2 IN ) : COLOR0
{
	float4 col = tex2D(Particle,IN.Tex);
	col *= IN.Color;
	col.rgb = col.rgb * 2.0 - 1.0;
	col.b = 0;
	float4 normal = tex2D(NormalBase,IN.NormalTex);
	normal.rgb  = normal.rgb * 2 - 1;
	normal.rgb += col.rgb*0.5;
	normal.a *= col.a;
	IN.Eye.y = -IN.Eye.y;
	float3x3 tangentFrame = compute_tangent_frame(normalize(IN.Eye), normalize(IN.Eye), IN.NormalTex);
	normal.xyz = normalize(mul(normal.xyz, tangentFrame));
	float d = pow(saturate(dot(-LightDirection,-normal.xyz)*0.5+0.5),1);
	
	col = float4(d,d,d,normal.a);
	col.rgb *= LightColor;
	col.a *= 0.5;
	
	col.rgb += FireColor*IN.LocalTime*2;
	
	return col;
}


///////////////////////////////////////////////////////////////////////////////////////
// �e�N�j�b�N
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
       "RenderColorTarget0=WorldCoord;"
           "RenderDepthStencilTarget=WorldCoordDepthBuffer;"
           "Pass=UpdateWorldCoord;"
       "RenderColorTarget0=;"
	    "RenderDepthStencilTarget=;"
            "Pass=DrawObject;";
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
   pass UpdateWorldCoord < string Script= "Draw=Buffer;"; > {
       ALPHABLENDENABLE = FALSE;
       ALPHATESTENABLE = FALSE;
       VertexShader = compile vs_2_0 WorldCoord_VS();
       PixelShader  = compile ps_2_0 WorldCoord_PS();
   }
   pass DrawObject {
       ZENABLE = TRUE;
       ZWRITEENABLE = FALSE;
       AlphaBlendEnable = TRUE;
       VertexShader = compile vs_3_0 Particle_VS();
       PixelShader  = compile ps_3_0 Particle_PS();
   }
}

