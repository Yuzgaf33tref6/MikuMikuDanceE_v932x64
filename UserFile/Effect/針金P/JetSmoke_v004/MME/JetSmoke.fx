////////////////////////////////////////////////////////////////////////////////////////////////
//
//  JetSmoke.fx ver0.0.4 ���ˎ��X���[�N�G�t�F�N�g
//  �쐬: �j��P
//
////////////////////////////////////////////////////////////////////////////////////////////////
// �����̃p�����[�^��ύX���Ă�������

// ���q���ݒ�
#define UNIT_COUNT   2   // �����̐��~1024 ����x�ɕ`��o���闱�q�̐��ɂȂ�(�����l�Ŏw�肷�邱��)

// ���q�p�����[�^�X�C�b�`
#define SMOKE_TYPE  2    // ���̎��(�Ƃ肠����0�`2�őI��,0:�]���ʂ�,1:�m�[�}���}�b�v�g�p����,2:�m�[�}���}�b�v�g�p����)
#define MMD_LIGHT   1    // MMD�̏Ɩ������ 0:�A�����Ȃ�, 1:�A������

// ���q�p�����[�^�ݒ�
float3 ParticleColor = {1.0, 1.0, 1.0}; // �e�N�X�`���̏�Z�F(RBG)
float ParticleSize = 0.3;           // ���q�傫��
float ParticleSpeedMin = 40.0;      // ���q�����ŏ��l
float ParticleSpeedMax = 200.0;     // ���q�����ő�l
float ParticleInitPos = 0.0;        // ���q�������̈ʒu(�傫������Ɨ��q�̔z�u���΂���܂�)
float ParticleLife = 0.8;           // ���q�̎���(�b)
float ParticleDecrement = 0.2;      // ���q���������J�n���鎞��(0.0�`1.0:ParticleLife�Ƃ̔�)
float ParticleContrast = 0.2;       // ���q�A�e�̃R���g���X�g(0.0�`1.0�A�m�[�}���}�b�v�g�p���̂ݗL��)
float ParticleShadeDiffusion = 6.0; // ���q������̉A�e�g�U�x(�傫������ƕ��ˌ����痣���ɂ�A�e���ڂ₯�Ă���A�m�[�}���}�b�v�̂�)
float ParticleOccur = 1.0;         // ���q�����x(�傫������Ɨ��q���o�₷���Ȃ�)
float DiffusionAngle = 5.0;         // ���ˊg�U�p(0.0�`180.0)
float SpeedDampCoef = 10.0;         // ���ˑ��x�̌����W��
float SpeedFixCoef = 0.1;           // ���ˑ��x�̌Œ�W��
float Scale = 1.0;                  // �`��S�̂̏k��


// �K�v�ɉ����ĉ��̃e�N�X�`���������Œ�`
#if SMOKE_TYPE == 0
   #define TEX_FileName  "Smoke.png"     // ���q�ɓ\��t����e�N�X�`���t�@�C����
   #define TEX_TYPE   0             // ���q�e�N�X�`���̎�� 0:�ʏ�e�N�X�`��, 1:�m�[�}���}�b�v
   #define TEX_PARTICLE_XNUM  1     // ���q�e�N�X�`����x�������q��
   #define TEX_PARTICLE_YNUM  1     // ���q�e�N�X�`����y�������q��
   #define TEX_PARTICLE_PXSIZE 128  // 1���q������Ɏg���Ă���e�N�X�`���̃s�N�Z���T�C�Y
#endif

#if SMOKE_TYPE == 1
   #define TEX_FileName  "SmokeNormal1.png" // ���q�ɓ\��t����e�N�X�`���t�@�C����
   #define TEX_TYPE   1             // ���q�e�N�X�`���̎�� 0:�ʏ�e�N�X�`��, 1:�m�[�}���}�b�v
   #define TEX_PARTICLE_XNUM  2     // ���q�e�N�X�`����x�������q��
   #define TEX_PARTICLE_YNUM  2     // ���q�e�N�X�`����y�������q��
   #define TEX_PARTICLE_PXSIZE 128  // 1���q������Ɏg���Ă���e�N�X�`���̃s�N�Z���T�C�Y
#endif

#if SMOKE_TYPE == 2
   #define TEX_FileName  "SmokeNormal2.png" // ���q�ɓ\��t����e�N�X�`���t�@�C����
   #define TEX_TYPE   1             // ���q�e�N�X�`���̎�� 0:�ʏ�e�N�X�`��, 1:�m�[�}���}�b�v
   #define TEX_PARTICLE_XNUM  2     // ���q�e�N�X�`����x�������q��
   #define TEX_PARTICLE_YNUM  2     // ���q�e�N�X�`����y�������q��
   #define TEX_PARTICLE_PXSIZE 128  // 1���q������Ɏg���Ă���e�N�X�`���̃s�N�Z���T�C�Y
#endif

// �I�v�V�����̃R���g���[���t�@�C����
#define SmoothCtrlFileName      "SmoothControl.x"     // �ڒn�ʃX���[�W���O�R���g���[���t�@�C����
#define TimrCtrlFileName        "TimeControl.x"       // ���Ԑ���R���g���[���t�@�C����


// ����Ȃ��l�͂������牺�͂�����Ȃ��ł�

////////////////////////////////////////////////////////////////////////////////////////////////
// �p�����[�^�錾

#define ArrangeFileName "Arrange.pfm" // �z�u��������t�@�C����
#define TEX_WIDTH_A   4           // �z�u��������e�N�X�`���s�N�Z����
#define TEX_WIDTH     UNIT_COUNT  // ���W���e�N�X�`���s�N�Z����
#define TEX_HEIGHT    1024        // �z�u��������e�N�X�`���s�N�Z������

#define PAI 3.14159265f   // ��

float AcsTr  : CONTROLOBJECT < string name = "(self)"; string item = "Tr"; >;
float AcsSi  : CONTROLOBJECT < string name = "(self)"; string item = "Si"; >;

int RepertCount = UNIT_COUNT;  // �V�F�[�_���`�攽����
int RepertIndex;               // �������f���J�E���^

static float diffD = radians( clamp(90.0f - DiffusionAngle, -90.0f, 90.0f) );

// �I�v�V�����̃R���g���[���p�����[�^
bool IsSmooth : CONTROLOBJECT < string name = SmoothCtrlFileName; >;
float SmoothSi : CONTROLOBJECT < string name = SmoothCtrlFileName; string item = "Si"; >;
float4x4 SmoothMat : CONTROLOBJECT < string name = SmoothCtrlFileName; >;
static float3 SmoothPos = SmoothMat._41_42_43;
static float3 SmoothNormal = normalize(SmoothMat._21_22_23);

bool IsTimeCtrl : CONTROLOBJECT < string name = TimrCtrlFileName; >;
float TimeSi : CONTROLOBJECT < string name = TimrCtrlFileName; string item = "Si"; >;
float TimeTr : CONTROLOBJECT < string name = TimrCtrlFileName; string item = "Tr"; >;
static bool TimeSync = IsTimeCtrl ? ((TimeSi>0.001f) ? true : false) : true;
static float TimeRate = IsTimeCtrl ? TimeTr : 1.0f;

// ���Ԑݒ�
float time1 : TIME;
float time2 : TIME < bool SyncInEditMode = true; >;
static float time = TimeSync ? time1 : time2;
float elapsed_time : ELAPSEDTIME;
float elapsed_time2 : ELAPSEDTIME < bool SyncInEditMode = true; >;
static float Dt = (TimeSync ? clamp(elapsed_time, 0.001f, 0.1f) : clamp(elapsed_time2, 0.0f, 0.1f)) * TimeRate;

// 1�t���[��������̗��q������
static float P_Count = ParticleOccur * (Dt / ParticleLife) * AcsSi*100;

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

static float3x3 BillboardMatrix = {
    normalize(ViewMatrixInverse[0].xyz),
    normalize(ViewMatrixInverse[1].xyz),
    normalize(ViewMatrixInverse[2].xyz),
};

// �I�u�W�F�N�g�ɓ\��t����e�N�X�`��
texture2D ParticleTex <
    string ResourceName = TEX_FileName;
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
    float x = pos.x * cos(rot) - pos.y * sin(rot);
    float y = pos.x * sin(rot) + pos.y * cos(rot);

    return float2(x,y);
}

////////////////////////////////////////////////////////////////////////////////////////////////

struct VS_OUTPUT {
   float4 Pos : POSITION;
   float2 Tex : TEXCOORD0;
};

// ���ʂ̒��_�V�F�[�_
VS_OUTPUT Common_VS(float4 Pos: POSITION, float2 Tex: TEXCOORD)
{
   VS_OUTPUT Out;
   Out.Pos = Pos;
   Out.Tex = Tex + float2(0.5f/TEX_WIDTH, 0.5f/TEX_HEIGHT);
   return Out;
}

// ���q�̔����E���W�v�Z(xyz:���W,w:�o�ߎ���)
float4 UpdatePos_PS(float2 Tex: TEXCOORD0) : COLOR
{
   // ���q�̍��W
   float4 Pos = tex2D(CoordSmp, Tex);

   // ���q�̑��x
   float4 Vel = tex2D(VelocitySmp, Tex);

   if(Pos.w < 1.001f){
      // ���������q�̒�����V���ɗ��q�𔭐�������
      int i = floor( Tex.x*TEX_WIDTH );
      int j = floor( Tex.y*TEX_HEIGHT );
      int p_index = j + i * TEX_HEIGHT;

      float3 WPos = Color2Float(j, 0);
      WPos *= ParticleInitPos * 0.1f;
      WPos = mul( float4(WPos,1), WorldMatrix ).xyz;
      Pos.xyz = WPos;  // �����������W

      // �V���ɗ��q�𔭐������邩�ǂ����̔���
      if(p_index < Vel.w) p_index += float(TEX_WIDTH*TEX_HEIGHT);
      if(p_index < Vel.w+P_Count){
         Pos.w = 1.0011f;  // Pos.w>1.001�ŗ��q����
      }
   }else{
      // ��������̗��q�ʒu����l��(�����x�ɔ����΂���ψꉻ����)
      if(Pos.w < 1.00111f){
          int j = floor( Tex.y*TEX_HEIGHT );
          Pos.xyz = lerp(Pos.xyz, Pos.xyz+Vel.xyz * Dt, Color2Float(j, 1).y);
      }

      // ���q�̍��W�X�V
      Pos.xyz += Vel.xyz * Dt;

      // ���łɔ������Ă��闱�q�͌o�ߎ��Ԃ�i�߂�
      Pos.w += Dt;
      Pos.w *= step(Pos.w-1.0f, ParticleLife); // �w�莞�Ԃ𒴂����0
   }

   return Pos;
}

// ���q�̑��x�v�Z
float4 UpdateVelocity_PS(float2 Tex: TEXCOORD0) : COLOR
{
   // ���q�̍��W
   float4 Pos = tex2D(CoordSmp, Tex);

   // ���q�̑��x
   float4 Vel = tex2D(VelocitySmp, Tex);

   if(Pos.w < 1.00111f){
      // ���������Ă̗��q�ɏ����x�^����
      int j = floor( Tex.y*TEX_HEIGHT );
      float3 rand = Color2Float(j, 2);
      float time1 = time + 100.0f;
      float ss, cs;
      sincos( lerp(diffD, PAI*0.5f, frac(rand.x*time1)), ss, cs );
      float st, ct;
      sincos( lerp(-PAI, PAI, frac(rand.y*time1)), st, ct );
      float3 vec  = float3( cs*ct, ss, cs*st );
      float speed = lerp(ParticleSpeedMin, ParticleSpeedMax, 1.0f-rand.z*rand.z);
      Vel.xyz = normalize( mul( vec, (float3x3)WorldMatrix ) ) * speed;
   }else{
      // ���łɔ������Ă��闱�q�̑��x������������
      Vel.xyz *= (exp(-SpeedDampCoef*(Pos.w-1.0f) ) + SpeedFixCoef) /
                 (exp(-SpeedDampCoef*(Pos.w-1.0f-Dt)) + SpeedFixCoef);
   }

   // ���������q�̋N�_
   Vel.w += P_Count;
   if(Vel.w >= float(TEX_WIDTH*TEX_HEIGHT)) Vel.w -= float(TEX_WIDTH*TEX_HEIGHT);
   if(time < 0.001f) Vel.w = 0.0f;

   return Vel;
}

///////////////////////////////////////////////////////////////////////////////////////
// �p�[�e�B�N���`��
struct VS_OUTPUT2
{
    float4 Pos      : POSITION;    // �ˉe�ϊ����W
    float2 Tex      : TEXCOORD0;   // �e�N�X�`��
    float3 Param    : TEXCOORD1;   // x�o�ߎ���,y�{�[�h�s�N�Z���T�C�Y,z��]
    float  Distance : TEXCOORD2;   // �ǋ���
    float3 LightDir : TEXCOORD3;   // ���C�g����
    float4 Color    : COLOR0;      // ���q�̏�Z�F
};

// ���_�V�F�[�_
VS_OUTPUT2 Particle_VS(float4 Pos : POSITION, float2 Tex : TEXCOORD0)
{
   VS_OUTPUT2 Out;

   // �{�[�h�̃C���f�b�N�X
   int i = RepertIndex;
   int j = round( Pos.z * 100.0f );
   int Index0 = i * TEX_HEIGHT + j;

   float2 texCoord = float2((i+0.5f)/TEX_WIDTH, (j+0.5f)/TEX_HEIGHT);
   Pos.z = 0.0f;

   // ���q�̍��W
   float4 Pos0 = tex2Dlod(CoordSmp, float4(texCoord, 0, 0));
   Out.Param.x = length(Pos0.xyz - WorldMatrix._41_42_43);

   // �o�ߎ���
   float etime = Pos0.w - 1.0f;

   // �����ݒ�
   float rand0 = 0.5f * (0.66f * sin(22.1f * Index0) + 0.33f * cos(33.6f * Index0) + 1.0f);
   float rand1 = 0.5f * (0.31f * sin(45.3f * Index0) + 0.69f * cos(73.4f * Index0) + 1.0f);

   // �o�ߎ��Ԃɑ΂��闱�q�g��x
   float scale = 4.0f * sqrt(etime) + 2.0f;

   // ���q�̑傫��
   Pos.xy *= (0.5f + rand0) * ParticleSize * scale * 10.0f;
   Pos.xy *= Scale;

   // �{�[�h�ɓ\��e�N�X�`���̃~�b�v�}�b�v���x��
   float pxLen = length(CameraPosition - Pos0.xyz);
   float4 pxPos = float4(0.0f, abs(Pos.y), pxLen, 1.0f);
   pxPos = mul( pxPos, ProjMatrix );
   float pxSize = ViewportSize.y * pxPos.y/pxPos.w;
   Out.Param.y = max( log2(TEX_PARTICLE_PXSIZE/pxSize), 0.0f );

   // ���q�̉�]
   float rot = 6.18f * ( rand1 - 0.5f );
   Pos.xy = Rotation2D(Pos.xy, rot);
   Out.Param.z = rot;

   // �r���{�[�h
   Pos.xyz = mul( Pos.xyz, BillboardMatrix );

   // ���q�̃��[���h���W
   Pos.xyz += (Pos0.xyz - WorldMatrix._41_42_43) * Scale + WorldMatrix._41_42_43;
   Pos.xyz *= step(0.001f, etime);
   Pos.w = 1.0f;

   // �J�������_�̃r���[�ˉe�ϊ�
   Out.Pos = mul( Pos, ViewProjMatrix );

   // ���q�̎Օ��ʋ���
   Out.Distance = dot(Pos.xyz-SmoothPos, SmoothNormal);

   // �J�������_�̃��C�g����
   Out.LightDir = mul(-LightDirection, (float3x3)ViewMatrix);

   // ���q�̏�Z�F
   float alpha = step(0.002f, etime) * smoothstep(-ParticleLife, -ParticleLife*ParticleDecrement, -etime) * AcsTr;
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
   float3 Normal = float3(2.0f * Color.r - 1.0f, 1.0f - 2.0f * Color.g,  -Color.b);
   Normal.xy = Rotation2D(Normal.xy, IN.Param.z);
   Normal = normalize(Normal);

   // ���q�̐F
   Color.rgb = saturate(IN.Color.rgb * lerp(1.0f-ParticleContrast, 1.0f, max(dot(Normal, IN.LightDir), 0.0f)));
   Color.a *= tex2Dlod( ParticleSamp, float4(IN.Tex, 0, 0) ).a * IN.Color.a;
   #else

   // ���q�e�N�X�`���̐F
   float4 Color = tex2D( ParticleSamp, IN.Tex );

   // ���q�̐F
   Color *= IN.Color;
   Color.rgb = saturate(Color.rgb);
   #endif

   // �Օ��ʏ���
   if( IsSmooth ){
      float pSize = clamp(ParticleSize, 0.5f, 2.0f);
      Color.a *= smoothstep(0.1f * pSize, 0.2f * pSize * SmoothSi, IN.Distance);
   }

   return Color;
}


///////////////////////////////////////////////////////////////////////////////////////
// �e�N�j�b�N
technique MainTec1 < string MMDPass = "object";
   string Script = 
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

