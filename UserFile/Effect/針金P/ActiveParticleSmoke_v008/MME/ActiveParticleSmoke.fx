////////////////////////////////////////////////////////////////////////////////////////////////
//
//  ActiveParticleSmoke.fx ver0.0.8 �[���~�T�C�����ۂ��G�t�F�N�g
//  �I�u�W�F�N�g�̈ړ��ɉ����ĉ������������܂�  �쐬: �j��P
//
////////////////////////////////////////////////////////////////////////////////////////////////
// �����̃p�����[�^��ύX���Ă�������

// ���q���ݒ�
#define UNIT_COUNT   8   // �����̐��~1024 ����x�ɕ`��o���闱�q�̐��ɂȂ�(�����l�Ŏw�肷�邱��)

// ���q�p�����[�^�X�C�b�`
#define SMOKE_TYPE  1    // ���̎��(�Ƃ肠����0�`2�őI��,0:�]���ʂ�,1:�m�[�}���}�b�v�g�p����,2:�m�[�}���}�b�v�g�p����)
#define MMD_LIGHT   1    // MMD�̏Ɩ������ 0:�A�����Ȃ�, 1:�A������

// ���q�p�����[�^�ݒ�
float3 ParticleColor = {1.0, 1.0, 1.0}; // ���q�̐F(RBG)
float ParticleSize = 1.5;           // ���q�傫��
float ParticleSpeedMin = 0.5;       // ���q�����ŏ��X�s�[�h
float ParticleSpeedMax = 1.5;       // ���q�����ő�X�s�[�h
float ParticleInitPos = 0.0;        // ���q�������̑��Έʒu(�傫������Ɨ��q�̏����z�u���΂���܂�)
float ParticleLife = 5.0;           // ���q�̎���(�b)
float ParticleDecrement = 0.3;      // ���q���������J�n���鎞��(0.0�`1.0:ParticleLife�Ƃ̔�)
float ParticleScaleUp = 2.0;        // ���q������̊g��x
float ParticleContrast = 0.4;       // ���q�A�e�̃R���g���X�g(0.0�`1.0�A�m�[�}���}�b�v�g�p���̂ݗL��)
float ParticleShadeDiffusion = 4.0; // ���q������̉A�e�g�U�x(�傫������Ǝ��Ԃ����ɂ�A�e���ڂ₯�Ă���A�m�[�}���}�b�v�̂�)
float OccurFactor = 1.0;            // �I�u�W�F�N�g�ړ��ʂɑ΂��闱�q�����x(�傫������Ɨ��q���o�₷���Ȃ�)
float ObjVelocityRate = -1.5;       // �I�u�W�F�N�g�ړ������ɑ΂��闱�q���x�ˑ��x
float3 StartDirect = {0.0, 1.0, 0.0};   // �������˕����x�N�g��
float DiffusionAngle = 180.0;           // �������ˊg�U�p(0.0�`180.0)


// �ǉ����q�ݒ�
#define UNIT_COUNT0   0   // �����̐��~1024 ����x�ɕ`��o����ǉ����q�̐��ɂȂ�(�����l�Ŏw��,0�ɂ���ƒǉ����q�`��͍s��Ȃ�)
#define TEX_ADD_FLG   1   // 0:����������, 1:���Z����

float3 ParticleColor0 = {1.0, 0.4, 0.0}; // �ǉ����q�̐F(RBG)
float ParticleLightPower0 = 1.0;    // ���Z�������̋P�x
float ParticleLife0 = 0.3;          // �ǉ����q�̎���(�b)
float OccurFactor0 = 2.0;           // �I�u�W�F�N�g�ړ��ʂɑ΂���ǉ����q�����x(�傫������Ɨ��q���o�₷���Ȃ�)


// �����p�����[�^�ݒ�
float3 GravFactor = {0.0, 0.0, 0.0};    // �d�͒萔
float ResistFactor = 0.0;               // ���x��R�W��

// (������)��Ԃ̗�������`����֐�
// ���q�ʒuParticlePos�ɂ������C�̗�����L�q���܂��B
// �߂�l��0�ȊO�̎��̓I�u�W�F�N�g�������Ȃ��Ă����q����o���܂��B
// ���������x��R�W����ResistFactor>0�łȂ��Ɨ�����͗��q�̓����ɉe����^���܂���B
float3 VelocityField(float3 ParticlePos)
{
   float3 vel = float3( 0.0, 0.0, 0.0 );
   return vel;
}


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
#define BackgroundCtrlFileName  "BackgroundControl.x" // �w�i���W�R���g���[���t�@�C����
#define SmoothCtrlFileName      "SmoothControl.x"     // �ڒn�ʃX���[�W���O�R���g���[���t�@�C����
#define TimrCtrlFileName        "TimeControl.x"       // ���Ԑ���R���g���[���t�@�C����


// ����Ȃ��l�͂������牺�͂�����Ȃ��ł�

////////////////////////////////////////////////////////////////////////////////////////////////
// �p�����[�^�錾

#define ArrangeFileName "Arrange.pfm" // �z�u��������t�@�C����
#define TEX_WIDTH_A  4            // �z�u��������e�N�X�`���s�N�Z����
#define TEX_WIDTH    UNIT_COUNT   // �e�N�X�`���s�N�Z����
#define TEX_HEIGHT   1024         // �e�N�X�`���s�N�Z������

#define PAI 3.14159265f   // ��

float AcsTr : CONTROLOBJECT < string name = "(self)"; string item = "Tr"; >;
float AcsSi : CONTROLOBJECT < string name = "(self)"; string item = "Si"; >;

int RepertCount = UNIT_COUNT;  // �V�F�[�_���`�攽����
int RepertIndex;               // �������f���J�E���^

// �I�v�V�����̃R���g���[���p�����[�^
bool IsBack : CONTROLOBJECT < string name = BackgroundCtrlFileName; >;
float4x4 BackMat : CONTROLOBJECT < string name = BackgroundCtrlFileName; >;

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

#if MMD_LIGHT == 1
float3 LightDirection : DIRECTION < string Object = "Light"; >;
float3 LightColor : SPECULAR < string Object = "Light"; >;
static float3 ResColor = ParticleColor * lerp(float3(0.5f, 0.5f, 0.5f), float3(1.33f, 1.33f, 1.33f), LightColor);
static float3 ResColor0 = ParticleColor0 * lerp(float3(0.5f, 0.5f, 0.5f), float3(1.33f, 1.33f, 1.33f), LightColor);
#else
float3 LightDirection : DIRECTION < string Object = "Camera"; >;
static float3 ResColor = ParticleColor;
static float3 ResColor0 = ParticleColor0;
#endif

static float diffD = saturate( 1.0f - DiffusionAngle / 180.0 );
static float3 sDirect = normalize( StartDirect );

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

// ���q�e�N�X�`��
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
sampler ArrangeSmp : register(s2) = sampler_state{
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
// ���ˌ��ǉ����q�e�N�X�`����`

#if (UNIT_COUNT0 > 0)

#define TEX_WIDTH0  UNIT_COUNT0  // �e�N�X�`���s�N�Z����

int RepertCount0 = UNIT_COUNT0;  // �V�F�[�_���`�攽����

// ���q���W�L�^�p
texture CoordTex0 : RENDERCOLORTARGET
<
   int Width=TEX_WIDTH0;
   int Height=TEX_HEIGHT;
   string Format="A32B32G32R32F";
>;
sampler CoordSmp0 : register(s3) = sampler_state
{
   Texture = <CoordTex0>;
    AddressU  = CLAMP;
    AddressV = CLAMP;
    MinFilter = NONE;
    MagFilter = NONE;
    MipFilter = NONE;
};
texture CoordDepthBuffer0 : RenderDepthStencilTarget <
   int Width=TEX_WIDTH0;
   int Height=TEX_HEIGHT;
   string Format = "D24S8";
>;

// ���q���x�L�^�p
texture VelocityTex0 : RENDERCOLORTARGET
<
   int Width=TEX_WIDTH0;
   int Height=TEX_HEIGHT;
   string Format="A32B32G32R32F";
>;
sampler VelocitySmp0 = sampler_state
{
   Texture = <VelocityTex0>;
    AddressU  = CLAMP;
    AddressV = CLAMP;
    MinFilter = NONE;
    MagFilter = NONE;
    MipFilter = NONE;
};

// �I�u�W�F�N�g�̃��[���h���W�L�^�p
texture WorldCoord0 : RENDERCOLORTARGET
<
   int Width=1;
   int Height=1;
   string Format="A32B32G32R32F";
>;
sampler WorldCoordSmp0 = sampler_state
{
   Texture = <WorldCoord0>;
   AddressU  = CLAMP;
   AddressV = CLAMP;
   MinFilter = NONE;
   MagFilter = NONE;
   MipFilter = NONE;
};

#endif


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

// �N�H�[�^�j�I���̐ώZ
float4 MulQuat(float4 q1, float4 q2)
{
   return float4(cross(q1.xyz, q2.xyz)+q1.xyz*q2.w+q2.xyz*q1.w, q1.w*q2.w-dot(q1.xyz, q2.xyz));
}

// �w�i�A�N�Z��̃��[���h���W��MMD���[���h���W
float3 InvBackWorldCoord(float3 pos)
{
    if( IsBack ){
        float scaling = 1.0f / length(BackMat._11_12_13);
        pos = mul( float4(pos, 1), float4x4( BackMat[0]*scaling,
                                             BackMat[1]*scaling,
                                             BackMat[2]*scaling,
                                             BackMat[3] )      ).xyz;
    }
    return pos;
}

// MMD���[���h���W���w�i�A�N�Z��̃��[���h���W
float3 BackWorldCoord(float3 pos)
{
    if( IsBack ){
        float scaling = 1.0f / length(BackMat._11_12_13);
        float3x3 mat3x3_inv = transpose((float3x3)BackMat) * scaling;
        pos = mul( float4(pos, 1), float4x4( mat3x3_inv[0], 0, 
                                             mat3x3_inv[1], 0, 
                                             mat3x3_inv[2], 0, 
                                            -mul(BackMat._41_42_43,mat3x3_inv), 1 ) ).xyz;
    }
    return pos;
}

// MMD���[���h�ϊ��s�񁨔w�i�A�N�Z��̃��[���h�ϊ��s��
float4x4 BackWorldMatrix(float4x4 mat)
{
    if( IsBack ){
        float scaling = 1.0f / length(BackMat._11_12_13);
        float3x3 mat3x3_inv = transpose((float3x3)BackMat) * scaling;
        mat = mul( mat, float4x4( mat3x3_inv[0], 0, 
                                  mat3x3_inv[1], 0, 
                                  mat3x3_inv[2], 0, 
                                 -mul(BackMat._41_42_43,mat3x3_inv), 1 ) );
    }
    return mat;
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


////////////////////////////////////////////////////////////////////////////////////////
// ���q�̔����E���W�X�V�v�Z(xyz:���W,w:�o�ߎ���+1sec,w�͍X�V����1�ɏ���������邽��+1s����X�^�[�g)

float4 UpdatePos_PS(float2 Tex: TEXCOORD0, uniform bool calcMain, uniform int texWidth, 
                    uniform sampler smpCoord, uniform sampler smpVelocity, uniform sampler smpWorldCoord) : COLOR
{
   // ���q�̍��W
   float4 Pos = tex2D(smpCoord, Tex);

   // ���q�̑��x
   float3 Vel = tex2D(smpVelocity, Tex).xyz;

   if(Pos.w < 1.001f){
   // ���������q�̒�����ړ������ɉ����ĐV���ɗ��q�𔭐�������
      // ���݂̃I�u�W�F�N�g���W
      float3 WPos1 = BackWorldCoord(WorldMatrix._41_42_43);

      // 1�t���[���O�̃I�u�W�F�N�g���W
      float4 WPos0 = tex2D(smpWorldCoord, float2(0.5f, 0.5f));
      WPos0.xyz -= VelocityField(WPos1) * Dt; // ���̑��x��ʒu�␳

      // 1�t���[���Ԃ̔������q��
      float occurFact = calcMain ? OccurFactor : OccurFactor0;
      float p_count = length( WPos1 - WPos0.xyz ) * occurFact * AcsSi*0.1f;

      // ���q�C���f�b�N�X
      int i = floor( Tex.x*texWidth );
      int j = floor( Tex.y*TEX_HEIGHT );
      float p_index = float( i*TEX_HEIGHT + j );

      // �V���ɗ��q�𔭐������邩�ǂ����̔���
      if(p_index < WPos0.w) p_index += float(texWidth*TEX_HEIGHT);
      if(p_index < WPos0.w+p_count){
         // ���q�������W
         float s = (p_index - WPos0.w) / p_count;
         float aveSpeed = (ParticleSpeedMin + ParticleSpeedMax) * 0.5f;
         Pos.xyz = lerp(WPos0.xyz, WPos1, s) + Vel * ParticleInitPos * Color2Float(j, 1).x / aveSpeed;
         Pos.w = 1.0011f;  // Pos.w>1.001�ŗ��q����
      }else{
         Pos.xyz = WPos1;
      }
   }else{
   // ���������q�̍��W���X�V
      // �����x�v�Z(���x��R��+�d��)
      float3 Accel = ( VelocityField(Pos.xyz) - Vel ) * ResistFactor + GravFactor;

      // ���W�ړ���
      float3 dPos = Dt * (Vel + Dt * Accel);

      // ��������̗��q�ʒu����l��(�����x�ɔ����΂���ψꉻ����)
      if(Pos.w < 1.00111f){
          int j = floor( Tex.y*TEX_HEIGHT );
          dPos = lerp(float3(0,0,0), dPos, Color2Float(j, 1).y);
      }

      // ���W�E�o�ߎ��Ԃ̍X�V
      Pos += float4(dPos, Dt);

      // �w�莞�Ԃ𒴂����0(���q����)
      if( calcMain ){
          Pos.w *= step(Pos.w-1.0f, ParticleLife);
      }else{
          Pos.w *= step(Pos.w-1.0f, ParticleLife0);
      }
   }

   // 0�t���[���Đ��ŗ��q������
   if(time < 0.001f) Pos = float4(BackWorldCoord(WorldMatrix._41_42_43), 0.0f);

   return Pos;
}

////////////////////////////////////////////////////////////////////////////////////////
// ���q�̑��x�v�Z

float4 UpdateVelocity_PS(float2 Tex: TEXCOORD0, uniform sampler smpCoord,
                         uniform sampler smpVelocity, uniform sampler smpWorldCoord) : COLOR
{
   // ���q�̍��W
   float4 Pos = tex2D(smpCoord, Tex);

   // ���q�̑��x
   float4 Vel = tex2D(smpVelocity, Tex);

   if(Pos.w < 1.00111f){
      // ���������Ă̗��q�ɏ����x�^����
      int j = floor( Tex.y*TEX_HEIGHT );
      float3 vec = Color2Float(j, 0);
      float3 v = cross( sDirect, vec ); // ���o�����ւ̉�]��
      v = any(v) ? normalize(v) : float3(0,0,1);
      float rot = acos( dot( vec, sDirect) ) * diffD; // ���o�����ւ̉�]�p
      float sinHD = sin(0.5f * rot);
      float cosHD = cos(0.5f * rot);
      float4 q1 = float4(v*sinHD, cosHD);
      float4 q2 = float4(-v*sinHD, cosHD);
      vec = MulQuat( MulQuat(q2, float4(vec, 1.0f)), q1).xyz; // ���o�����ւ̉�](�N�H�[�^�j�I��)
      float speed = lerp( ParticleSpeedMin, ParticleSpeedMax, Color2Float(j, 1).y );
      Vel = float4( normalize( mul( vec, (float3x3)BackWorldMatrix(WorldMatrix) ) ) * speed, 1.0f );
      float4 WPos0 = tex2D(smpWorldCoord, float2(0.5f, 0.5f));
      float3 WPos1 = BackWorldCoord(WorldMatrix._41_42_43);
      Vel.xyz += normalize(WPos1-WPos0.xyz)*ObjVelocityRate; // �I�u�W�F�N�g�ړ�������t������
   }else{
      // ���������q�̑��x�v�Z
      float3 Accel = ( VelocityField(Pos.xyz) - Vel.xyz ) * ResistFactor + GravFactor; // �����x�v�Z(���x��R��+�d��)
      Vel.xyz += Dt * Accel; // �V�������x�ɍX�V
   }

   return Vel;
}

////////////////////////////////////////////////////////////////////////////////////////////////
// �I�u�W�F�N�g�̃��[���h���W�L�^

VS_OUTPUT WorldCoord_VS(float4 Pos : POSITION)
{
    VS_OUTPUT Out = (VS_OUTPUT)0; 

    Out.Pos = Pos;
    Out.Tex = float2(0.5f, 0.5f);

    return Out;
}

float4 WorldCoord_PS(float2 Tex: TEXCOORD0, uniform bool calcMain, uniform int texWidth, uniform sampler smpWorldCoord) : COLOR
{
   // �I�u�W�F�N�g�̃��[���h���W
   float3 Pos1 = BackWorldCoord(WorldMatrix._41_42_43);
   float4 Pos0 = tex2D(smpWorldCoord, Tex);
   Pos0.xyz -= VelocityField(Pos1) * Dt; // ���̑��x��ʒu�␳

   // ���������q�̋N�_
   float occurFact = calcMain ? OccurFactor : OccurFactor0;
   float p_count = length( Pos1 - Pos0.xyz ) * occurFact * AcsSi*0.1f;
   float w = Pos0.w + p_count;
   if(w >= float(texWidth*TEX_HEIGHT)) w -= float(texWidth*TEX_HEIGHT);
   if(time < 0.001f) w = 0.0f;

   return float4(Pos1, w);
}


///////////////////////////////////////////////////////////////////////////////////////
// �p�[�e�B�N���`��

struct VS_OUTPUT2
{
    float4 Pos       : POSITION;    // �ˉe�ϊ����W
    float2 Tex       : TEXCOORD0;   // �e�N�X�`��
    float3 Param     : TEXCOORD1;   // x�o�ߎ���,y�{�[�h�s�N�Z���T�C�Y,z��]
    float  Distance  : TEXCOORD2;   // �ǋ���
    float3 LightDir  : TEXCOORD3;   // ���C�g����
    float4 Color     : COLOR0;      // ���q�̏�Z�F
};

// ���_�V�F�[�_
VS_OUTPUT2 Particle_VS(float4 Pos : POSITION, float2 Tex : TEXCOORD0, uniform bool calcMain, uniform int texWidth, uniform sampler smpCoord)
{
   VS_OUTPUT2 Out = (VS_OUTPUT2)0;

   int i = RepertIndex;
   int j = round( Pos.z * 100.0f );
   int Index0 = i * TEX_HEIGHT + j;
   float2 texCoord = float2((i+0.5f)/texWidth, (j+0.5f)/TEX_HEIGHT);
   Pos.z = 0.0f;

   // ���q�̍��W
   float4 Pos0 = tex2Dlod(smpCoord, float4(texCoord, 0, 0));
   Pos0.xyz = InvBackWorldCoord(Pos0.xyz);

   // �o�ߎ���
   float etime = Pos0.w - 1.0f;
   Out.Param.x = etime;

   // �����ݒ�
   float3 rand = tex2Dlod(ArrangeSmp, float4(3.5f/TEX_WIDTH_A, (j+0.5f)/TEX_HEIGHT, 0, 0)).xyz;

   // �o�ߎ��Ԃɑ΂��闱�q�g��x
   float scale = ParticleScaleUp * sqrt(etime) + 2.0f;

   // ���q�̑傫��
   scale *= 0.5f + rand.x;
   Pos.xy *= ParticleSize * scale * 10.0f;

   // �{�[�h�ɓ\��e�N�X�`���̃~�b�v�}�b�v���x��
   float pxLen = length(CameraPosition - Pos0.xyz);
   float4 pxPos = float4(0.0f, abs(Pos.y), pxLen, 1.0f);
   pxPos = mul( pxPos, ProjMatrix );
   float pxSize = ViewportSize.y * pxPos.y/pxPos.w;
   Out.Param.y = max( log2(TEX_PARTICLE_PXSIZE/pxSize), 0.0f );

   // ���q�̉�]
   float rot = 2.0f * PAI * rand.y;
   Pos.xy = Rotation2D(Pos.xy, rot);
   Out.Param.z = rot;

   // �r���{�[�h
   Pos.xyz = mul( Pos.xyz, BillboardMatrix );

   // ���q�̃��[���h���W
   Pos.xyz += Pos0.xyz;
   Pos.xyz *= step(0.001f, etime);
   Pos.w = 1.0f;

   // �J�������_�̃r���[�ˉe�ϊ�
   Out.Pos = mul( Pos, ViewProjMatrix );

   // ���q�̎Օ��ʋ���
   Out.Distance = dot(Pos.xyz-SmoothPos, SmoothNormal);

   // �J�������_�̃��C�g����
   Out.LightDir = mul(-LightDirection, (float3x3)ViewMatrix);

   // ���q�̏�Z�F
   float pLife = calcMain ? ParticleLife : ParticleLife0;
   float alpha = step(0.001f, etime) * smoothstep(-pLife, -pLife*ParticleDecrement, -etime) * AcsTr;
   Out.Color = calcMain ? float4(ResColor, alpha) : float4(ResColor0, alpha);

   // �e�N�X�`�����W
   int texIndex = Index0 % (TEX_PARTICLE_XNUM * TEX_PARTICLE_YNUM);
   int tex_i = texIndex % TEX_PARTICLE_XNUM;
   int tex_j = texIndex / TEX_PARTICLE_XNUM;
   Out.Tex = float2((Tex.x + tex_i)/TEX_PARTICLE_XNUM, (Tex.y + tex_j)/TEX_PARTICLE_YNUM);

   return Out;
}

// �s�N�Z���V�F�[�_
float4 Particle_PS( VS_OUTPUT2 IN, uniform bool calcMain ) : COLOR0
{
   #if TEX_TYPE == 1
   // ���q�e�N�X�`��(�m�[�}���}�b�v)����@���v�Z
   float shadeDiffuse = max( IN.Param.y, lerp(0, ParticleShadeDiffusion, IN.Param.x/ParticleLife) );
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
      if( calcMain ){
         Color.a *= smoothstep(0.1f * pSize, 0.2f * pSize * SmoothSi, IN.Distance);
      }else{
         #if TEX_ADD_FLG == 1
         Color.rgb *= smoothstep(0.1f * pSize, 0.2f * pSize * SmoothSi, IN.Distance);
         #else
         Color.a *= smoothstep(0.1f * pSize, 0.2f * pSize * SmoothSi, IN.Distance);
         #endif
      }
   }

   // �����ߕ��͕`�悵�Ȃ�
   clip(Color.a - 0.005f);

   #if TEX_ADD_FLG == 1
   if( !calcMain ) Color.rgb *= Color.a * ParticleLightPower0;
   #endif

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
       "RenderColorTarget0=WorldCoord;"
           "RenderDepthStencilTarget=WorldCoordDepthBuffer;"
           "Pass=UpdateWorldCoord;"
       "RenderColorTarget0=;"
	    "RenderDepthStencilTarget=;"
            "LoopByCount=RepertCount;"
            "LoopGetIndex=RepertIndex;"
                "Pass=DrawObject;"
            "LoopEnd=;"
       #if (UNIT_COUNT0 > 0)
       "RenderColorTarget0=CoordTex0;"
	    "RenderDepthStencilTarget=CoordDepthBuffer0;"
	    "Pass=UpdatePos0;"
       "RenderColorTarget0=VelocityTex0;"
	    "RenderDepthStencilTarget=CoordDepthBuffer0;"
	    "Pass=UpdateVelocity0;"
       "RenderColorTarget0=WorldCoord0;"
           "RenderDepthStencilTarget=WorldCoordDepthBuffer;"
           "Pass=UpdateWorldCoord0;"
       "RenderColorTarget0=;"
	    "RenderDepthStencilTarget=;"
            "LoopByCount=RepertCount0;"
            "LoopGetIndex=RepertIndex;"
                "Pass=DrawObject0;"
            "LoopEnd=;"
       #endif
       ;
>{
   pass UpdatePos < string Script= "Draw=Buffer;"; > {
       ALPHABLENDENABLE = FALSE;
       ALPHATESTENABLE = FALSE;
       VertexShader = compile vs_3_0 Common_VS();
       PixelShader  = compile ps_3_0 UpdatePos_PS( true, TEX_WIDTH, CoordSmp, VelocitySmp, WorldCoordSmp );
   }
   pass UpdateVelocity < string Script= "Draw=Buffer;"; > {
       ALPHABLENDENABLE = FALSE;
       ALPHATESTENABLE = FALSE;
       VertexShader = compile vs_3_0 Common_VS();
       PixelShader  = compile ps_3_0 UpdateVelocity_PS( CoordSmp, VelocitySmp, WorldCoordSmp );
   }
   pass UpdateWorldCoord < string Script= "Draw=Buffer;"; > {
       ALPHABLENDENABLE = FALSE;
       ALPHATESTENABLE = FALSE;
       VertexShader = compile vs_2_0 WorldCoord_VS();
       PixelShader  = compile ps_2_0 WorldCoord_PS( true, TEX_WIDTH, WorldCoordSmp );
   }
   pass DrawObject {
       ZENABLE = TRUE;
       ZWRITEENABLE = FALSE;
       AlphaBlendEnable = TRUE;
       VertexShader = compile vs_3_0 Particle_VS( true, TEX_WIDTH, CoordSmp );
       PixelShader  = compile ps_3_0 Particle_PS( true );
   }
   #if (UNIT_COUNT0 > 0)
   pass UpdatePos0 < string Script= "Draw=Buffer;"; > {
       ALPHABLENDENABLE = FALSE;
       ALPHATESTENABLE = FALSE;
       VertexShader = compile vs_3_0 Common_VS();
       PixelShader  = compile ps_3_0 UpdatePos_PS( false, TEX_WIDTH0, CoordSmp0, VelocitySmp0, WorldCoordSmp0 );
   }
   pass UpdateVelocity0 < string Script= "Draw=Buffer;"; > {
       ALPHABLENDENABLE = FALSE;
       ALPHATESTENABLE = FALSE;
       VertexShader = compile vs_3_0 Common_VS();
       PixelShader  = compile ps_3_0 UpdateVelocity_PS( CoordSmp0, VelocitySmp0, WorldCoordSmp0 );
   }
   pass UpdateWorldCoord0 < string Script= "Draw=Buffer;"; > {
       ALPHABLENDENABLE = FALSE;
       ALPHATESTENABLE = FALSE;
       VertexShader = compile vs_2_0 WorldCoord_VS();
       PixelShader  = compile ps_2_0 WorldCoord_PS( false, TEX_WIDTH0, WorldCoordSmp0 );
   }
   pass DrawObject0 {
       ZENABLE = TRUE;
       ZWRITEENABLE = FALSE;
       AlphaBlendEnable = TRUE;
       #if TEX_ADD_FLG == 1
         DestBlend = ONE;
         SrcBlend = ONE;
       #else
         DestBlend = INVSRCALPHA;
         SrcBlend = SRCALPHA;
       #endif
       VertexShader = compile vs_3_0 Particle_VS( false, TEX_WIDTH0, CoordSmp0 );
       PixelShader  = compile ps_3_0 Particle_PS( false );
   }
   #endif
}


// �e�N�j�b�N(MMDPass = "object"�Ɠ���, �eON�ɂ��Ȃ���ZPlot�`�悪�s���Ȃ��̂�)
technique MainTecSS1 < string MMDPass = "object_ss";
   string Script = 
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
            "LoopByCount=RepertCount;"
            "LoopGetIndex=RepertIndex;"
                "Pass=DrawObject;"
            "LoopEnd=;"
       #if (UNIT_COUNT0 > 0)
       "RenderColorTarget0=CoordTex0;"
	    "RenderDepthStencilTarget=CoordDepthBuffer0;"
	    "Pass=UpdatePos0;"
       "RenderColorTarget0=VelocityTex0;"
	    "RenderDepthStencilTarget=CoordDepthBuffer0;"
	    "Pass=UpdateVelocity0;"
       "RenderColorTarget0=WorldCoord0;"
           "RenderDepthStencilTarget=WorldCoordDepthBuffer;"
           "Pass=UpdateWorldCoord0;"
       "RenderColorTarget0=;"
	    "RenderDepthStencilTarget=;"
            "LoopByCount=RepertCount0;"
            "LoopGetIndex=RepertIndex;"
                "Pass=DrawObject0;"
            "LoopEnd=;"
       #endif
       ;
>{
   pass UpdatePos < string Script= "Draw=Buffer;"; > {
       ALPHABLENDENABLE = FALSE;
       ALPHATESTENABLE = FALSE;
       VertexShader = compile vs_3_0 Common_VS();
       PixelShader  = compile ps_3_0 UpdatePos_PS( true, TEX_WIDTH, CoordSmp, VelocitySmp, WorldCoordSmp );
   }
   pass UpdateVelocity < string Script= "Draw=Buffer;"; > {
       ALPHABLENDENABLE = FALSE;
       ALPHATESTENABLE = FALSE;
       VertexShader = compile vs_3_0 Common_VS();
       PixelShader  = compile ps_3_0 UpdateVelocity_PS( CoordSmp, VelocitySmp, WorldCoordSmp );
   }
   pass UpdateWorldCoord < string Script= "Draw=Buffer;"; > {
       ALPHABLENDENABLE = FALSE;
       ALPHATESTENABLE = FALSE;
       VertexShader = compile vs_2_0 WorldCoord_VS();
       PixelShader  = compile ps_2_0 WorldCoord_PS( true, TEX_WIDTH, WorldCoordSmp );
   }
   pass DrawObject {
       ZENABLE = TRUE;
       ZWRITEENABLE = FALSE;
       AlphaBlendEnable = TRUE;
       VertexShader = compile vs_3_0 Particle_VS( true, TEX_WIDTH, CoordSmp );
       PixelShader  = compile ps_3_0 Particle_PS( true );
   }
   #if (UNIT_COUNT0 > 0)
   pass UpdatePos0 < string Script= "Draw=Buffer;"; > {
       ALPHABLENDENABLE = FALSE;
       ALPHATESTENABLE = FALSE;
       VertexShader = compile vs_3_0 Common_VS();
       PixelShader  = compile ps_3_0 UpdatePos_PS( false, TEX_WIDTH0, CoordSmp0, VelocitySmp0, WorldCoordSmp0 );
   }
   pass UpdateVelocity0 < string Script= "Draw=Buffer;"; > {
       ALPHABLENDENABLE = FALSE;
       ALPHATESTENABLE = FALSE;
       VertexShader = compile vs_3_0 Common_VS();
       PixelShader  = compile ps_3_0 UpdateVelocity_PS( CoordSmp0, VelocitySmp0, WorldCoordSmp0 );
   }
   pass UpdateWorldCoord0 < string Script= "Draw=Buffer;"; > {
       ALPHABLENDENABLE = FALSE;
       ALPHATESTENABLE = FALSE;
       VertexShader = compile vs_2_0 WorldCoord_VS();
       PixelShader  = compile ps_2_0 WorldCoord_PS( false, TEX_WIDTH0, WorldCoordSmp0 );
   }
   pass DrawObject0 {
       ZENABLE = TRUE;
       ZWRITEENABLE = FALSE;
       AlphaBlendEnable = TRUE;
       #if TEX_ADD_FLG == 1
         DestBlend = ONE;
         SrcBlend = ONE;
       #else
         DestBlend = INVSRCALPHA;
         SrcBlend = SRCALPHA;
       #endif
       VertexShader = compile vs_3_0 Particle_VS( false, TEX_WIDTH0, CoordSmp0 );
       PixelShader  = compile ps_3_0 Particle_PS( false );
   }
   #endif
}


///////////////////////////////////////////////////////////////////////////////////////
// ZPlot�p�[�e�B�N���`��

// ���ߒl�ɑ΂���[�x�ǂݎ��臒l
#define AlphaClipThreshold  0.2f

// ���W�ϊ��s��
float4x4 LightViewProjMatrix : VIEWPROJECTION < string Object = "Light"; >;
float4x4 LightViewMatrixInverse : VIEWINVERSE < string Object = "Light"; >;

static float3x3 LightBillboardMatrix = {
    normalize(LightViewMatrixInverse[0].xyz),
    normalize(LightViewMatrixInverse[1].xyz),
    normalize(LightViewMatrixInverse[2].xyz),
};

struct VS_OUTPUT3
{
    float4 Pos          : POSITION;    // �ˉe�ϊ����W
    float2 Tex          : TEXCOORD0;   // �e�N�X�`��
    float4 ShadowMapTex : TEXCOORD1;    // Z�o�b�t�@�e�N�X�`��
    float2 Param        : TEXCOORD2;   // alpha,����
};

// ���_�V�F�[�_
VS_OUTPUT3 ParticleZPlot_VS(float4 Pos : POSITION, float2 Tex : TEXCOORD0)
{
   VS_OUTPUT3 Out = (VS_OUTPUT3)0;

   int i = RepertIndex;
   int j = round( Pos.z * 100.0f );
   int Index0 = i * TEX_HEIGHT + j;
   float2 texCoord = float2((i+0.5f)/TEX_WIDTH, (j+0.5f)/TEX_HEIGHT);
   Pos.z = 0.0f;

   // ���q�̍��W
   float4 Pos0 = tex2Dlod(CoordSmp, float4(texCoord, 0, 0));
   Pos0.xyz = InvBackWorldCoord(Pos0.xyz);

   // �o�ߎ���
   float etime = Pos0.w - 1.0f;
   Out.Param.x = etime;

   // �����ݒ�
   float3 rand = tex2Dlod(ArrangeSmp, float4(3.5f/TEX_WIDTH_A, (j+0.5f)/TEX_HEIGHT, 0, 0)).xyz;

   // �o�ߎ��Ԃɑ΂��闱�q�g��x
   float scale = ParticleScaleUp * sqrt(etime) + 2.0f;

   // ���q�̑傫��
   scale *= 0.5f + rand.x;
   Pos.xy *= ParticleSize * scale * 10.0f;

   // ���q�̉�]
   float rot = 2.0f * PAI * rand.y;
   Pos.xy = Rotation2D(Pos.xy, rot);

   // �r���{�[�h
   Pos.xyz = mul( Pos.xyz, LightBillboardMatrix );

   // ���q�̃��[���h���W
   Pos.xyz += Pos0.xyz;
   Pos.xyz *= step(0.001f, etime);
   Pos.w = 1.0f;

   // ���C�g���_�̃r���[�ˉe�ϊ�
   Out.Pos = mul( Pos, LightViewProjMatrix );

   // �e�N�X�`�����W�𒸓_�ɍ��킹��
   Out.ShadowMapTex = Out.Pos;

   // ���q�̎Օ��ʍ���
   Out.Param.y = dot(Pos.xyz-SmoothPos, SmoothNormal);

   // ���l
   float alpha = step(0.001f, etime) * smoothstep(-ParticleLife, -ParticleLife*ParticleDecrement, -etime) * AcsTr;
   Out.Param.x = alpha;

   // �e�N�X�`�����W
   int texIndex = Index0 % (TEX_PARTICLE_XNUM * TEX_PARTICLE_YNUM);
   int tex_i = texIndex % TEX_PARTICLE_XNUM;
   int tex_j = texIndex / TEX_PARTICLE_XNUM;
   Out.Tex = float2((Tex.x + tex_i)/TEX_PARTICLE_XNUM, (Tex.y + tex_j)/TEX_PARTICLE_YNUM);

   return Out;
}

// �s�N�Z���V�F�[�_
float4 ParticleZPlot_PS( VS_OUTPUT3 IN ) : COLOR0
{
   // ���l
   float alpha = tex2D( ParticleSamp, IN.Tex ).a * IN.Param.x;

   // �Օ��ʏ���
   if( IsSmooth ){
      float pSize = clamp(ParticleSize, 0.5f, 2.0f);
      alpha *= smoothstep(0.1f * pSize, 0.2f * pSize * SmoothSi, IN.Param.y);
   }

   // �����ߕ��͕`�悵�Ȃ�
   clip(alpha - AlphaClipThreshold);

   // R�F������Z�l���L�^����
   return float4(IN.ShadowMapTex.z/IN.ShadowMapTex.w, 0, 0, 1);
}


///////////////////////////////////////////////////////////////////////////////////////
// ZPlot�e�N�j�b�N
technique ZplotTec < string MMDPass = "zplot";
   string Script = "LoopByCount=RepertCount;"
                   "LoopGetIndex=RepertIndex;"
                      "Pass=ZValuePlot;"
                   "LoopEnd=;" ;
>{
    pass ZValuePlot {
       AlphaBlendEnable = TRUE;
       VertexShader = compile vs_3_0 ParticleZPlot_VS();
       PixelShader  = compile ps_3_0 ParticleZPlot_PS();
   }
}

// �G�b�W�E�n�ʉe�͕\�����Ȃ�
technique EdgeTec < string MMDPass = "edge"; > { }
technique ShadowTec < string MMDPass = "shadow"; > { }

