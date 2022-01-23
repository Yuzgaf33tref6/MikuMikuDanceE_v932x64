////////////////////////////////////////////////////////////////////////////////////////////////
//
//  MeraFireSmoke.fx ver0.0.2 ���G�t�F�N�g�t���̉��G�t�F�N�g
//  �쐬: �j��P
//
////////////////////////////////////////////////////////////////////////////////////////////////
// �����̃p�����[�^��ύX���Ă�������

#define SMOKE_TYPE  2    // ���̎��(�Ƃ肠����0�`2�őI��,0:�ʏ�e�N�X�`��,1:�m�[�}���}�b�v�g�p����,2:�m�[�}���}�b�v�g�p����)
#define MMD_LIGHT   1    // MMD�̏Ɩ������ 0:�A�����Ȃ�, 1:�A������

float3 ParticleColor = {0.6, 0.6, 0.6}; // �e�N�X�`���̏�Z�F(RBG)
float ParticleSize = 0.3;           // ���q�傫��
float ParticleSpeedMax = 20.0;      // ���q�����ő�l
float ParticleSpeedMin = 5.0;       // ���q�����ŏ��l
float ParticleInitPos = 2.0;        // ���q�������̈ʒu(�傫������Ɨ��q�̔z�u���΂���܂�)
float ParticleLife = 5.0;           // ���q�̎���(�b)
float ParticleDecrement = 0.5;      // ���q���������J�n���鎞��(0.0�`1.0:ParticleLife�Ƃ̔�)
float ParticleContrast = 0.5;       // ���q�A�e�̃R���g���X�g(0.0�`1.0�A�m�[�}���}�b�v�g�p���̂ݗL��)
float ParticleShadeDiffusion = 4.0; // ���q������̉A�e�g�U�x(�傫������ƕ��ˌ����痣���ɂ�A�e���ڂ₯�Ă���A�m�[�}���}�b�v�̂�)
float DiffusionAngle = 5.0;         // ���ˊg�U�p(0.0�`180.0)
float SpeedDampCoef = 2.0;          // ���ˑ��x�̌����W��
float SpeedFixCoef = 0.3;           // ���ˑ��x�̌Œ�W��
float OccurFactor = 1.0;            // ���q�����x(�傫������Ɨ��q���o�₷���Ȃ�)
float FireLightLength = 15.0;       // ���̏Ƃ�Ԃ������
float FireLightPower = 1.5;         // ���̏Ƃ�Ԃ��x(�傫������Ƌ߂��Ƃ���͋����A�����Ƃ���͎キ�Ȃ�)

#define RISE_DIREC  1   // ���̏㏸������ 0:�A�N�Z�T�������, 1:������Œ�
#define FIRE_LIGHT  1   // ���̏Ƃ�Ԃ��� 0:����, 1:�L��
#define FireColorTexFile   "palette1.png" // ���Fpallet�e�N�X�`���t�@�C����


// �K�v�ɉ����ĉ��̃e�N�X�`���������Œ�`
#if SMOKE_TYPE == 0
   #define TexFile  "Smoke.png"     // ���q�ɓ\��t����e�N�X�`���t�@�C����
   #define TEX_TYPE   0             // ���q�e�N�X�`���̎�� 0:�ʏ�e�N�X�`��, 1:�m�[�}���}�b�v
   #define TEX_PARTICLE_XNUM  1     // ���q�e�N�X�`����x�������q��
   #define TEX_PARTICLE_YNUM  1     // ���q�e�N�X�`����y�������q��
   #define TEX_PARTICLE_PXSIZE 128  // 1���q������Ɏg���Ă���e�N�X�`���̃s�N�Z���T�C�Y
#endif

#if SMOKE_TYPE == 1
   #define TexFile  "SmokeNormal1.png" // ���q�ɓ\��t����e�N�X�`���t�@�C����
   #define TEX_TYPE   1             // ���q�e�N�X�`���̎�� 0:�ʏ�e�N�X�`��, 1:�m�[�}���}�b�v
   #define TEX_PARTICLE_XNUM  2     // ���q�e�N�X�`����x�������q��
   #define TEX_PARTICLE_YNUM  2     // ���q�e�N�X�`����y�������q��
   #define TEX_PARTICLE_PXSIZE 128  // 1���q������Ɏg���Ă���e�N�X�`���̃s�N�Z���T�C�Y
#endif

#if SMOKE_TYPE == 2
   #define TexFile  "SmokeNormal2.png" // ���q�ɓ\��t����e�N�X�`���t�@�C����
   #define TEX_TYPE   1             // ���q�e�N�X�`���̎�� 0:�ʏ�e�N�X�`��, 1:�m�[�}���}�b�v
   #define TEX_PARTICLE_XNUM  2     // ���q�e�N�X�`����x�������q��
   #define TEX_PARTICLE_YNUM  2     // ���q�e�N�X�`����y�������q��
   #define TEX_PARTICLE_PXSIZE 128  // 1���q������Ɏg���Ă���e�N�X�`���̃s�N�Z���T�C�Y
#endif


// ����Ȃ��l�͂������牺�͂�����Ȃ��ł�

////////////////////////////////////////////////////////////////////////////////////////////////
// �p�����[�^�錾
#define ArrangeFileName "Arrange.pfm" // �z�u��������t�@�C����
#define TEX_WIDTH_A   4   // �z�u��������e�N�X�`���s�N�Z����
#define TEX_WIDTH     1   // ���W���e�N�X�`���s�N�Z����
#define TEX_HEIGHT 1024   // �z�u��������e�N�X�`���s�N�Z������

#define PAI 3.14159265f   // ��

float AcsTr  : CONTROLOBJECT < string name = "(self)"; string item = "Tr"; >;
float AcsSi  : CONTROLOBJECT < string name = "(self)"; string item = "Si"; >;

static float diffD = radians( clamp(90.0f - DiffusionAngle, -90.0f, 90.0f) );

float time : TIME;
float elapsed_time : ELAPSEDTIME;
static float Dt = clamp(elapsed_time, 0.001f, 0.1f);

static float P_Count = OccurFactor * (Dt / ParticleLife) * 500.0f; // 1�t���[��������̗��q������

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

// ���W�ϊ��s��
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

// �I�u�W�F�N�g�ɓ\��t����e�N�X�`��
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

// ���Fpallet�e�N�X�`��
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


////////////////////////////////////////////////////////////////////////////////////////////////
// �z�u��������e�N�X�`������f�[�^�����o��

float3 Color2Float(int index, int item)
{
    return tex2D(ArrangeSmp, float2((item+0.5f)/TEX_WIDTH_A, (index+0.5f)/TEX_HEIGHT)).xyz;
}

////////////////////////////////////////////////////////////////////////////////////////////////
// ���W��2D��]

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

// ���ʂ̒��_�V�F�[�_
VS_OUTPUT Common_VS(float4 Pos: POSITION, float2 Tex: TEXCOORD)
{
   VS_OUTPUT Out;
   Out.Pos = Pos;
   Out.texCoord = Tex + float2(0.5f/TEX_WIDTH, 0.5f/TEX_HEIGHT);
   return Out;
}

// ���q�̔����E���W�v�Z(xyz:���W,w:�o�ߎ���)
float4 UpdatePos_PS(float2 texCoord: TEXCOORD0, uniform bool flag) : COLOR
{
   float p_count;
   if( flag ){
      p_count = P_Count;
   }else{
      p_count = 0.0f;
   }

   // ���q�̍��W
   float4 Pos = tex2D(CoordSmp, texCoord);

   // ���q�̑��x
   float4 Vel = tex2D(VelocitySmp, texCoord);

   if(Pos.w < 1.001f){
      // ���������q�̒�����V���ɗ��q�𔭐�������
      int j = floor( texCoord.y*TEX_HEIGHT );
      float3 pos = Color2Float(j, 0);
      float4 WPos = float4(pos.x, 1.0f-abs(pos.y), pos.z, 1.0f);
      WPos.xyz *= ParticleInitPos;
      WPos = mul( WPos, WorldMatrix1 );
      Pos.xyz = WPos.xyz / WPos.w;  // �����������W

      // �V���ɗ��q�𔭐������邩�ǂ����̔���
      float p_index = float(j);
      if(p_index < Vel.w) p_index += float(TEX_WIDTH*TEX_HEIGHT);
      if(p_index < Vel.w+p_count){
         Pos.w = 1.0011f;  // Pos.w>1.001�ŗ��q����
      }
   }else{
      // ���q�̍��W�X�V
      Pos.xyz += Vel.xyz * Dt;

      // ���łɔ������Ă��闱�q�͌o�ߎ��Ԃ�i�߂�
      Pos.w += Dt;
      Pos.w *= step(Pos.w-1.0f, ParticleLife); // �w�莞�Ԃ𒴂����0
   }

   return Pos;
}

// ���q�̑��x�v�Z
float4 UpdateVelocity_PS(float2 texCoord: TEXCOORD0, uniform bool flag) : COLOR
{
   float p_count;
   if( flag ){
      p_count = P_Count;
   }else{
      p_count = 0.0f;
   }

   // ���q�̍��W
   float4 Pos = tex2D(CoordSmp, texCoord);

   // ���q�̑��x
   float4 Vel = tex2D(VelocitySmp, texCoord);

   if(Pos.w < 1.00111f){
      // ���������Ă̗��q�ɏ����x�^����
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
      // ���łɔ������Ă��闱�q�̑��x������������
      float speedRate = (exp(-SpeedDampCoef*Pos.w ) + SpeedFixCoef) /
                        (exp(-SpeedDampCoef*(Pos.w-Dt)) + SpeedFixCoef);
      Vel.xyz *= speedRate;
      //Vel.xyz *= mul(float3(speedRate, pow(speedRate, 0.3), speedRate), (float3x3)WorldMatrix )*0.1;
   }

   // ���������q�̋N�_
   Vel.w += p_count;
   if(Vel.w >= float(TEX_WIDTH*TEX_HEIGHT)) Vel.w -= float(TEX_WIDTH*TEX_HEIGHT);
   if(time < 0.001f) Vel.w = 0.0f;

   return Vel;
}


///////////////////////////////////////////////////////////////////////////////////////
// �p�[�e�B�N���`��
struct VS_OUTPUT2
{
    float4 Pos        : POSITION;    // �ˉe�ϊ����W
    float2 Tex        : TEXCOORD0;   // �e�N�X�`��
    float3 Param      : TEXCOORD1;   // x�o�ߎ���,y�{�[�h�s�N�Z���T�C�Y,z��]
    float3 LightDir   : TEXCOORD2;   // ���C�g����
    float3 FireDir    : TEXCOORD3;   // ����������
    float  FireLen    : TEXCOORD4;   // ����������̋���
    float4 Color      : COLOR0;      // ���q�̏�Z�F
};

// ���_�V�F�[�_
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

   // ���q�̍��W
   float4 Pos0 = tex2Dlod(CoordSmp, float4(texCoord, 0, 1));
   Out.Param.x = length(Pos0.xyz - WorldMatrix._41_42_43);

   // �o�ߎ���
   float etime = Pos0.w - 1.0f;

   // �o�ߎ��Ԃɑ΂��闱�q�g��x
   float scale = 6.0f * sqrt(etime) + 2.0f;
   scale *= 1.0f + 0.5f * (0.66f * sin(2.0f * Index0) + 0.33f * cos(3.0f * Index0));

   // ���q�̑傫��
   Pos.xy *= ParticleSize * scale * AcsSi * 0.1f;

   // �{�[�h�ɓ\��e�N�X�`���̃~�b�v�}�b�v���x��
   float pxLen = length(CameraPosition - Pos0.xyz);
   float4 pxPos = float4(0.0f, abs(Pos.y), pxLen, 1.0f);
   pxPos = mul( pxPos, ProjMatrix );
   float pxSize = ViewportSize.y * pxPos.y/pxPos.w;
   Out.Param.y = max( log2(TEX_PARTICLE_PXSIZE/pxSize), 0.0f );

   // ���q�̉�]
   float rot = 6.18f *  0.5f * (0.3f * sin(4.0f * Index0) + 0.7f * cos(7.0f * Index0));
   Pos.xy = Rotation2D(Pos.xy, rot);
   Out.Param.z = rot;

   // �r���{�[�h
   Pos.xyz = mul( Pos.xyz, BillboardMatrix );

   // ���q�̃��[���h���W
   Pos.xyz += (Pos0.xyz - WorldMatrix._41_42_43) * AcsSi * 0.1f + WorldMatrix._41_42_43;
   Pos.xyz *= step(0.001f, etime);
   Pos.w = 1.0f;

   // �J�������_�̃r���[�ˉe�ϊ�
   Out.Pos = mul( Pos, ViewProjMatrix );

   // �J�������_�̃��C�g����
   Out.LightDir = mul(-LightDirection, (float3x3)ViewMatrix);
   #if RISE_DIREC==0
      Out.FireDir = normalize(mul(-WorldMatrix._21_22_23, (float3x3)ViewMatrix));
   #else
      Out.FireDir = normalize(mul(float3(0,-1,0), (float3x3)ViewMatrix));
   #endif
   Out.FireLen = length(WorldMatrix._41_42_43 - Pos);

   // ���q�̏�Z�F
   float alpha = step(0.001f, etime) * smoothstep(0.0f, min(0.5f, ParticleLife*ParticleDecrement), etime)
                   * smoothstep(-ParticleLife, -ParticleLife*ParticleDecrement, -etime) * AcsTr * 0.5f;
   Out.Color = float4(ResColor, alpha);

   // �e�N�X�`�����W
   int texIndex = Index0 % (TEX_PARTICLE_XNUM * TEX_PARTICLE_YNUM);
   int tex_i = texIndex % TEX_PARTICLE_XNUM;
   int tex_j = texIndex / TEX_PARTICLE_XNUM;
   Out.Tex = float2((Tex.x + tex_i)/TEX_PARTICLE_XNUM, (Tex.y + tex_j)/TEX_PARTICLE_YNUM);

   return Out;
}

// �s�N�Z���V�F�[�_
float4 Particle_PS( VS_OUTPUT2 IN ) : COLOR0
{
#if TEX_TYPE == 1
   // ���q�e�N�X�`��(�m�[�}���}�b�v)����@���v�Z
   float shadeDiffuse = max( IN.Param.y, lerp(0, ParticleShadeDiffusion, max(IN.Param.x/30.0f, 0.0f)) );
   float4 Color = tex2Dlod( ParticleSamp, float4(IN.Tex, 0, shadeDiffuse) );
   float3 Normal = float3(2.0f * Color.r - 1.0f, 1.0f - 2.0f * Color.g, -Color.b);
   Normal.xy = Rotation2D(Normal.xy, IN.Param.z);
   Normal = normalize(Normal);

   // ���q�̐F
   Color.rgb = saturate(IN.Color.rgb * lerp(1.0f-ParticleContrast, 1.0f, max(dot(Normal, IN.LightDir), 0.0f)));
   Color.a *= tex2Dlod( ParticleSamp, float4(IN.Tex, 0, 0) ).a * IN.Color.a;

   #if FIRE_LIGHT == 1
      // ���̏Ƃ�Ԃ�
      Normal.z = -lerp(-1.5f, 1.0f, -Normal.z);
      Normal = normalize(Normal);
      float4 FireCol = tex2D(FireColorSamp, saturate(float2(0.5f, 0.5f)));
      float fireLight = FireLightLength * AcsSi * 0.1f / IN.FireLen;
      Color.rgb += saturate(FireCol.rgb * lerp(0.0f, 0.8f, max(dot(Normal, IN.FireDir), 0.0f))) * pow(fireLight, FireLightPower);
   #endif
#else
   // ���q�e�N�X�`���̐F
   float4 Color = tex2D( ParticleSamp, IN.Tex );

   // ���q�̐F
   Color *= IN.Color;
   Color.rgb = saturate(Color.rgb);
#endif

   return Color;
}


///////////////////////////////////////////////////////////////////////////////////////
// �e�N�j�b�N
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
// �n�ʉe�͕\�����Ȃ�
technique ShadowTec < string MMDPass = "shadow"; > { }
// MMD�W���̃Z���t�V���h�E�͕\�����Ȃ�
technique ZplotTec < string MMDPass = "zplot"; > { }

