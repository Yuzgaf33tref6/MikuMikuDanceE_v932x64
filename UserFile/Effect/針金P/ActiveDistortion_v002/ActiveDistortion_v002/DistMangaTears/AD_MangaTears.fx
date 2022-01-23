////////////////////////////////////////////////////////////////////////////////////////////////
//
//  DistMangaTears.fx ver0.0.4 ���敗�܃p�[�e�B�N���G�t�F�N�g�c��ver(MangaTears.fx����,�@���E�[�x�}�b�v�쐬)
//  ( ActiveDistortion.fx ����Ăяo����܂��D�I�t�X�N���[���`��p)
//  �쐬: �j��P
//
////////////////////////////////////////////////////////////////////////////////////////////////
// �����̃p�����[�^��ύX���Ă�������

// ���q���ݒ�
#define UNIT_COUNT   2   // �����̐��~1024 ����x�ɕ`��o���闱�q�̐��ɂȂ�(�����l�Ŏw�肷�邱��)

#define NORMAL_TYPE  2    // ���q�e�N�X�`���̎��(�Ƃ肠����1,2�őI��,1:�m�[�}���}�b�v����,2:�m�[�}���}�b�v����)

// ���q�p�����[�^�ݒ�
float ParticleSize = 0.3;       // ���q�傫��
float ParticleScaleUp = 1.0;     // ���q�̎��Ԍo�߂ɂ��g��x
float ParticleReboundSize = 3.0; // �͂˕Ԃ��̗��q�L�k�x
float ParticleSpeed = 12.0;      // ���q�����x
float ParticleLife = 3.0;        // ���q�̎���(�b)

// �����p�����[�^�ݒ�
float3 GravFactor = {0.0, -25.0, 0.0};   // �d�͒萔
float ResistFactor = 1.0;          // ���x��R��
float CoefRebound = 0.2;           // �n�ʂ̂͂˕Ԃ�W��
float ReboundNoise = 5.0;          // �n�ʂ͂˕Ԃ��̕��U�x

float3 OffsetPos = {0.0, 0.0, -1.0};  // ���q�����ʒu�̕␳�l(���ڂɕt����ꍇ��X��0�ɂ���MMD�Őݒ�)
float3 StartDirect = {1.0, 0.8, 0.0}; // ���q���o�����x�N�g��


// �K�v�ɉ����ăm�[�}���}�b�v�e�N�X�`���������Œ�`

#if NORMAL_TYPE == 1
   #define TEX_FileName  "ParticleNormal1.png" // ���q�ɓ\��t����e�N�X�`���t�@�C����
   #define TEX_PARTICLE_XNUM  2     // ���q�e�N�X�`����x�������q��
   #define TEX_PARTICLE_YNUM  2     // ���q�e�N�X�`����y�������q��
   #define TEX_PARTICLE_PXSIZE 128  // 1���q������Ɏg���Ă���e�N�X�`���̃s�N�Z���T�C�Y
#endif

#if NORMAL_TYPE == 2
   #define TEX_FileName  "ParticleNormal2.png" // ���q�ɓ\��t����e�N�X�`���t�@�C����
   #define TEX_PARTICLE_XNUM  2     // ���q�e�N�X�`����x�������q��
   #define TEX_PARTICLE_YNUM  2     // ���q�e�N�X�`����y�������q��
   #define TEX_PARTICLE_PXSIZE 128  // 1���q������Ɏg���Ă���e�N�X�`���̃s�N�Z���T�C�Y
#endif

// ���Ԑ���R���g���[���t�@�C����
#define TimrCtrlFileName  "TimeControl.x"


// ����Ȃ��l�͂������牺�͂�����Ȃ��ł�

////////////////////////////////////////////////////////////////////////////////////////////////
// �p�����[�^�錾
#define ArrangeFileName "Arrange.pfm" // �z�u��������t�@�C����
#define TEX_WIDTH_A   4           // �z�u��������e�N�X�`���s�N�Z����
#define TEX_WIDTH     UNIT_COUNT  // ���W���e�N�X�`���s�N�Z����
#define TEX_HEIGHT    1024        // �z�u��������e�N�X�`���s�N�Z������

#define PAI 3.14159265f   // ��

#define DEPTH_FAR  5000.0f   // �[�x�ŉ��l

float AcsTr  : CONTROLOBJECT < string name = "(self)"; string item = "Tr"; >;
float AcsSi  : CONTROLOBJECT < string name = "(self)"; string item = "Si"; >;

int RepertCount = UNIT_COUNT;  // �V�F�[�_���`�攽����
int RepertIndex;               // �������f���J�E���^

static float3 sDirect = normalize( StartDirect );

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

//�J�����ʒu
float3 CameraPosition  : POSITION  < string Object = "Camera"; >;

// ���q�e�N�X�`��(�m�[�}���}�b�v)
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
sampler CoordSmp : register(s2) = sampler_state
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
sampler VelocitySmp : register(s3) = sampler_state
{
   Texture = <VelocityTex>;
    AddressU  = CLAMP;
    AddressV = CLAMP;
    MinFilter = NONE;
    MagFilter = NONE;
    MipFilter = NONE;
};

////////////////////////////////////////////////////////////////////////////////////////////////
// ���ԊԊu�ݒ�

// ���Ԑ���R���g���[���p�����[�^
bool IsTimeCtrl : CONTROLOBJECT < string name = TimrCtrlFileName; >;
float TimeSi : CONTROLOBJECT < string name = TimrCtrlFileName; string item = "Si"; >;
float TimeTr : CONTROLOBJECT < string name = TimrCtrlFileName; string item = "Tr"; >;
static bool TimeSync = IsTimeCtrl ? ((TimeSi>0.001f) ? true : false) : true;
static float TimeRate = IsTimeCtrl ? TimeTr : 1.0f;

float time1 : Time;
float time2 : Time < bool SyncInEditMode = true; >;
static float time = TimeSync ? time1 : time2;

#ifndef MIKUMIKUMOVING

float elapsed_time : ELAPSEDTIME;
float elapsed_time2 : ELAPSEDTIME < bool SyncInEditMode = true; >;
static float Dt = (TimeSync ? clamp(elapsed_time, 0.001f, 0.1f) : clamp(elapsed_time2, 0.0f, 0.1f)) * TimeRate;

#else

// �X�V�����L�^�p
texture TimeTex : RENDERCOLORTARGET
<
   int Width=1;
   int Height=1;
   string Format = "D3DFMT_R32F" ;
>;
sampler TimeTexSmp : register(s1) = sampler_state
{
   Texture = <TimeTex>;
   AddressU  = CLAMP;
   AddressV = CLAMP;
   MinFilter = NONE;
   MagFilter = NONE;
   MipFilter = NONE;
};
texture TimeDepthBuffer : RenderDepthStencilTarget <
   int Width=1;
   int Height=1;
   string Format = "D3DFMT_D24S8";
>;
static float Dt = clamp(time - tex2Dlod(TimeTexSmp, float4(0.5f, 0.5f, 0, 0)).r, 0.0f, 0.1f) * TimeRate;

float4 UpdateTime_VS(float4 Pos : POSITION) : POSITION
{
    return Pos;
}

float4 UpdateTime_PS() : COLOR
{
   return float4(time, 0, 0, 1);
}

#endif

// 1�t���[��������̗��q������
static float P_Count = AcsSi*0.1f * Dt *60;


////////////////////////////////////////////////////////////////////////////////////////////////

// ������̈ʒu�ƌ���
bool flagFloorCtrl : CONTROLOBJECT < string name = "FloorControl.x"; >;
float4x4 FloorCtrlWldMat : CONTROLOBJECT < string name = "FloorControl.x"; >;
static float3 FloorPos = flagFloorCtrl ? FloorCtrlWldMat._41_42_43  : float3(0, 0, 0);
static float3 FloorNormal = flagFloorCtrl ? normalize(FloorCtrlWldMat._21_22_23) : float3(0, 1, 0);

// �X�P�[�����O�Ȃ��̏����[���h�ϊ��s��
static float4x4 FloorWldMat = flagFloorCtrl ? float4x4( normalize(FloorCtrlWldMat._11_12_13), 0,
                                                        normalize(FloorCtrlWldMat._21_22_23), 0,
                                                        normalize(FloorCtrlWldMat._31_32_33), 0,
                                                        FloorCtrlWldMat[3] )
                                            : float4x4( 1,0,0,0, 0,1,0,0, 0,0,1,0, 0,0,0,1 );

// ���[���h�ϊ��s��ŁA�X�P�[�����O�Ȃ��̋t�s����v�Z����B
float4x4 InverseWorldMatrix(float4x4 mat) {
    float3x3 mat3x3_inv = transpose((float3x3)mat);
    float3x3 mat3x3_inv2 = float3x3( normalize(mat3x3_inv[0]),
                                     normalize(mat3x3_inv[1]),
                                     normalize(mat3x3_inv[2]) );
    return float4x4( mat3x3_inv2[0], 0, 
                     mat3x3_inv2[1], 0, 
                     mat3x3_inv2[2], 0, 
                     -mul(mat._41_42_43, mat3x3_inv2), 1 );
}
// �X�P�[�����O�Ȃ��̏����[���h�t�ϊ��s��
static float4x4 InvFloorWldMat = flagFloorCtrl ? InverseWorldMatrix( FloorCtrlWldMat )
                                               : float4x4( 1,0,0,0, 0,1,0,0, 0,0,1,0, 0,0,0,1 );


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


////////////////////////////////////////////////////////////////////////////////////////////////
// ���C���r���{�[�h�s��(���[���h�ϊ��s��ɂȂ�)
float4x4 GetLineBillboardMatrix(float3 Point1, float3 Point2, float Scale)
{
    float3 xAxis = normalize( cross( Point2 - Point1, Point1 - CameraPosition ) ) * Scale;
    float3 yAxis = normalize( Point2 - Point1 ) * (length( Point2 - Point1 )/Scale*10 + Scale);
    float3 zAxis = normalize( cross( xAxis, yAxis ) );
    return float4x4( xAxis,                0.0f,
                     yAxis,                0.0f,
                     zAxis,                0.0f,
                     (Point2+Point1)*0.5f, 1.0f );
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


///////////////////////////////////////////////////////////////////////////////////////
// ���q�̔����E���W�X�V�v�Z(xyz:���W,w:�o�ߎ���+1sec,w�͍X�V����1�ɏ���������邽��+1s����X�^�[�g)
float4 UpdatePos_PS(float2 Tex: TEXCOORD0) : COLOR
{
   // ���q�̍��W
   float4 Pos = tex2D(CoordSmp, Tex);

   // ���q�̑��x
   float4 Vel = tex2D(VelocitySmp, Tex);

   int i = floor( Tex.x*TEX_WIDTH );
   int j = floor( Tex.y*TEX_HEIGHT );
   int p_index = j + i * TEX_HEIGHT;

   if(Pos.w < 1.001f){
   // ���������q�̒�����V���ɗ��q�𔭐�������
      Pos.xyz = WorldMatrix._41_42_43 + OffsetPos;  // �����������W

      // �V���ɗ��q�𔭐������邩�ǂ����̔���
      if(p_index < Vel.w) p_index += float(TEX_WIDTH*TEX_HEIGHT);
      if(p_index < Vel.w+P_Count){
         Pos.w = 1.0011f;  // Pos.w>1.001�ŗ��q����
      }
   }else{
   // �������q�͋^�������v�Z�ō��W���X�V
      // �����x�v�Z(���x��R��+�d��)
      float3 Accel = -Vel.xyz * ResistFactor + GravFactor;

      // �V�������W�ɍX�V
      Pos.xyz += Dt * (Vel.xyz + Dt * Accel);

      // ���łɔ������Ă��闱�q�͌o�ߎ��Ԃ�i�߂�
      Pos.w += Dt;

      if(Pos.w-1.0f >  ParticleLife){
          Pos.w *= step(Pos.w-1.0f, ParticleLife); // �w�莞�Ԃ𒴂����0
      }else{
         // ���˕Ԃ���������ԋ߂ɂ���
         if( Pos.w <= ParticleLife - 10.0f*Dt/max(TimeRate, 0.01f) + 1.0f){
            if(dot(Pos.xyz-FloorPos, FloorNormal) < 0.0f){
               Pos.w = ParticleLife - 10.0f*Dt/max(TimeRate, 0.01f) + 1.0f;
            }
         }
      }
   }

   // 0�t���[���Đ��ŗ��q������
   if(time < 0.001f) Pos = float4(WorldMatrix._41_42_43 + OffsetPos, 0.0f);

   return Pos;
}

///////////////////////////////////////////////////////////////////////////////////////
// ���q�̑��x�v�Z(xyz:���x,w:�����N�_)
float4 UpdateVelocity_PS(float2 Tex: TEXCOORD0) : COLOR
{
   // ���q�̍��W
   float4 Pos = tex2D(CoordSmp, Tex);

   // ���q�̑��x
   float4 Vel = tex2D(VelocitySmp, Tex);

   int j = floor( Tex.y*TEX_HEIGHT );

   if(Pos.w < 1.001111f){
      // ���������Ă̗��q�ɏ����x�^����
      float3 vec  = float3( 0.0f, PAI*0.5f, 0.0f );
      float3 v = cross( sDirect, float3(0.0f, 1.0f, 0.0f) ); // ���o�����ւ̉�]��
      v = any(v) ? normalize(v) : float3(0,0,1);
      float rot = acos( dot(float3(0.0f, 1.0f, 0.0f), sDirect) ); // ���o�����ւ̉�]�p
      float sinHD = sin(0.5f * rot);
      float cosHD = cos(0.5f * rot);
      float4 q1 = float4(v*sinHD, cosHD);
      float4 q2 = float4(-v*sinHD, cosHD);
      vec = MulQuat( MulQuat(q2, float4(vec, 0.0f)), q1).xyz; // ���o�����ւ̉�](�N�H�[�^�j�I��)
      Vel.xyz = normalize( mul( vec, (float3x3)WorldMatrix ) ) * ParticleSpeed;
   }else{
      // ���q�̑��x�v�Z
      float3 rand = Color2Float(j, 3);

      // �����x�v�Z(���x��R��+�d��)
      float3 Accel = -Vel.xyz * ResistFactor + GravFactor;

      // �V�������W�ɍX�V
      Vel.xyz += Dt * Accel;

      // ���̗����ɓ��������̏���
      if(dot(Pos.xyz-FloorPos, FloorNormal) < 0.0f){
         float3 reboundVel = mul(Vel.xyz, (float3x3)InvFloorWldMat);
         reboundVel.x = ReboundNoise * (rand.x - 0.5f);
         reboundVel.y = CoefRebound * abs(reboundVel.y) * (rand.y + 0.1f);
         reboundVel.z = ReboundNoise * (rand.z - 0.5f);
         Vel.xyz = mul(reboundVel, (float3x3)FloorWldMat);
         // ���̌X�����̕␳(�K��)
         float3 flrGrvDir = cross( cross(normalize(GravFactor), FloorNormal), FloorNormal);
         if(dot(flrGrvDir, GravFactor) < 0.0f) flrGrvDir = -flrGrvDir;
         Vel.xyz += flrGrvDir * ReboundNoise * 0.7f;
      }
   }

   // ���������q�̋N�_
   Vel.w += P_Count;
   if(Vel.w >= float(TEX_WIDTH*TEX_HEIGHT)) Vel.w -= float(TEX_WIDTH*TEX_HEIGHT);
   if(time < 0.001f) Vel.w = 0.0f;

   return Vel;
}

///////////////////////////////////////////////////////////////////////////////////////////////
//MMM�Ή�
#ifndef MIKUMIKUMOVING
    #define GET_VPMAT(p) (ViewProjMatrix)
#else
    #define GET_VPMAT(p) (MMM_IsDinamicProjection ? mul(ViewMatrix, MMM_DynamicFov(ProjMatrix, length(CameraPosition-p.xyz))) : ViewProjMatrix)
#endif


///////////////////////////////////////////////////////////////////////////////////////
// �p�[�e�B�N���`��
struct VS_OUTPUT2
{
    float4 Pos       : POSITION;    // �ˉe�ϊ����W
    float2 Tex       : TEXCOORD0;   // �e�N�X�`��
    float4 VPos      : TEXCOORD1;   // �r���[���W
    float2 Param     : TEXCOORD2;   // alpha�l,z��]
    float4 Color     : COLOR0;      // ���q�̏�Z�F
};

// ���_�V�F�[�_
VS_OUTPUT2 Particle_VS(float4 Pos : POSITION, float2 Tex : TEXCOORD0)
{
   VS_OUTPUT2 Out = (VS_OUTPUT2)0;

   int i = RepertIndex;
   int j = round( Pos.z * 100.0f );
   int Index0 = i * TEX_HEIGHT + j;
   float2 texCoord = float2((i+0.5f)/TEX_WIDTH, (j+0.5f)/TEX_HEIGHT);
   Pos.z = 0.0f;

   // ���q�̍��W
   float4 Pos0 = tex2Dlod(CoordSmp, float4(texCoord, 0, 0));
   float4 Pos1 = Pos0 + tex2Dlod(VelocitySmp, float4(texCoord, 0, 0)) * max(Dt, 0.001f);

   // �o�ߎ���
   float etime = Pos0.w - 1.0f;

   // �����ݒ�
   float rand0 = 0.5f * (0.66f * sin(22.1f * Index0) + 0.33f * cos(33.6f * Index0) + 1.0f);
   float rand1 = 0.5f * (0.31f * sin(45.3f * Index0) + 0.69f * cos(73.4f * Index0) + 1.0f);

   // �o�ߎ��Ԃɑ΂��闱�q�g��x
   float scale = ParticleScaleUp * etime + 1.0f;

   // ���q�̑傫��
   scale = (0.2f+rand0) * ParticleSize * scale * 10.0f;

   // �͂˕Ԃ藱�q�̑傫��
   if(dot(Pos0.xyz-FloorPos, FloorNormal) < 0.0f){
       Pos.x /= ParticleReboundSize;
       Pos.y *= ParticleReboundSize;
   }

   // ���q�̉�]
   float rot = 6.18f * ( rand1 - 0.5f )*0.0;
   Pos.xy = Rotation2D(Pos.xy, rot);

   // ���C���r���{�[�h(���[���h���W)
   if(etime > 0.0001f){
       Pos = mul( Pos, GetLineBillboardMatrix(Pos0.xyz, Pos1.xyz, scale) );
       Out.Param.y = rot - atan2(Pos1.y - Pos0.y, Pos1.x - Pos0.x);
   }else{
       Pos.xyz = float4(Pos0.xyz, 1.0f);
       Out.Param.y = rot;
   }

   // �J�������_�̃r���[�ϊ�
   Out.VPos = mul( Pos, ViewMatrix );

   // �J�������_�̃r���[�ˉe�ϊ�
   Out.Pos = mul( Pos, GET_VPMAT(Pos) );

   // ���q�̃��l
   Out.Param.x = step(0.01f, etime);

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
    // �m�[�}���}�b�v�Q��
    float4 Color = tex2D( ParticleSamp, IN.Tex );
    Color.a *= IN.Param.x;

    // �������ʂ͕`�悵�Ȃ�
    clip( Color.a - 0.5f );

    // �@��(0�`1�ɂȂ�悤�␳)
    float3 Normal = float3(2.0f * Color.r - 1.0f, 1.0f - 2.0f * Color.g,  -Color.b);
    Normal.xy = Rotation2D(Normal.xy, IN.Param.y);
    Normal = normalize(Normal);
    Normal = (Normal + 1.0f) / 2.0f;
    Normal = lerp(float3(0.5, 0.5, 0.0f), Normal, IN.Param.x*AcsTr);

    // �[�x(0�`DEPTH_FAR��0.5�`1.0�ɐ��K��)
    float dep = length(IN.VPos.xyz / IN.VPos.w);
    dep = (saturate(dep / DEPTH_FAR) + 1.0f) * 0.5f;

    return float4(Normal, dep);
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
            "LoopEnd=;"
       #ifdef MIKUMIKUMOVING
       "RenderColorTarget0=TimeTex;"
            "RenderDepthStencilTarget=TimeDepthBuffer;"
            "Pass=UpdateTime;"
       "RenderColorTarget0=;"
	    "RenderDepthStencilTarget=;"
       #endif
       ;
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
        AlphaBlendEnable = FALSE;
        VertexShader = compile vs_3_0 Particle_VS();
        PixelShader  = compile ps_3_0 Particle_PS();
    }
    #ifdef MIKUMIKUMOVING
    pass UpdateTime < string Script= "Draw=Buffer;"; > {
        ZEnable = FALSE;
        AlphaBlendEnable = FALSE;
        AlphaTestEnable = FALSE;
        VertexShader = compile vs_1_1 UpdateTime_VS();
        PixelShader  = compile ps_2_0 UpdateTime_PS();
    }
    #endif
}

