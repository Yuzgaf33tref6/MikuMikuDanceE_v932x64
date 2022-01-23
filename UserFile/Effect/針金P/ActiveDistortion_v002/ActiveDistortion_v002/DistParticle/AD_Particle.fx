////////////////////////////////////////////////////////////////////////////////////////////////
//
//  AD_Particle.fx ��Ԙc�݃G�t�F�N�g(ActiveParticleSmoke.fx�̉���,�@���E�[�x�}�b�v�쐬)
//  ( ActiveDistortion.fx ����Ăяo����܂��D�I�t�X�N���[���`��p)
//  �쐬: �j��P
//
////////////////////////////////////////////////////////////////////////////////////////////////
// �����̃p�����[�^��ύX���Ă�������

// ���q���ݒ�
#define UNIT_COUNT   2   // �����̐��~1024 ����x�ɕ`��o���闱�q�̐��ɂȂ�(�����l�Ŏw�肷�邱��)

// ���q�p�����[�^�X�C�b�`
#define NORMAL_TYPE  2    // ���q�e�N�X�`���̎��(�Ƃ肠����1,2�őI��,1:�m�[�}���}�b�v����,2:�m�[�}���}�b�v����)

// ���q�p�����[�^�ݒ�
float ParticleSize = 5.0;           // ���q�傫��
float ParticleSpeedMin = 0.1;       // ���q�����ŏ��X�s�[�h
float ParticleSpeedMax = 0.3;       // ���q�����ő�X�s�[�h
float ParticleInitPos = 0.0;        // ���q�������̑��Έʒu(�傫������Ɨ��q�̏����z�u���΂���܂�)
float ParticleLife = 5.0;           // ���q�̎���(�b)
float ParticleDecrement = 0.5;      // ���q���������J�n���鎞��(0.0�`1.0:ParticleLife�Ƃ̔�)
float ParticleScaleUp = 0.1;        // ���q������̊g��x
float ParticleShadeDiffusion = 4.0; // ���q������̉A�e�g�U�x(�傫������Ǝ��Ԃ����ɂ�A�e���ڂ₯�Ă���)
float OccurFactor = 4.0;            // �I�u�W�F�N�g�ړ��ʂɑ΂��闱�q�����x(�傫������Ɨ��q���o�₷���Ȃ�)
float ObjVelocityRate = 0.2;        // �I�u�W�F�N�g�ړ������ɑ΂��闱�q���x�ˑ��x

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

// �I�v�V�����̃R���g���[���t�@�C����
#define BackgroundCtrlFileName  "BackgroundControl.x" // �w�i���W�R���g���[���t�@�C����
#define TimrCtrlFileName        "TimeControl.x"       // ���Ԑ���R���g���[���t�@�C����


// ����Ȃ��l�͂������牺�͂�����Ȃ��ł�

////////////////////////////////////////////////////////////////////////////////////////////////
// �p�����[�^�錾

#define ArrangeFileName "Arrange.pfm" // �z�u��������t�@�C����
#define TEX_WIDTH_A  4            // �z�u��������e�N�X�`���s�N�Z����
#define TEX_WIDTH    UNIT_COUNT   // �e�N�X�`���s�N�Z����
#define TEX_HEIGHT   1024         // �e�N�X�`���s�N�Z������

#define PAI 3.14159265f   // ��

#define DEPTH_FAR  5000.0f   // �[�x�ŉ��l

float AcsTr : CONTROLOBJECT < string name = "(self)"; string item = "Tr"; >;
float AcsSi : CONTROLOBJECT < string name = "(self)"; string item = "Si"; >;

int RepertCount = UNIT_COUNT;  // �V�F�[�_���`�攽����
int RepertIndex;               // �������f���J�E���^

// �I�v�V�����̃R���g���[���p�����[�^
bool IsBack : CONTROLOBJECT < string name = BackgroundCtrlFileName; >;
float4x4 BackMat : CONTROLOBJECT < string name = BackgroundCtrlFileName; >;

float3 LightDirection : DIRECTION < string Object = "Camera"; >;
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
static float Dt = clamp(time - tex2D(TimeTexSmp, float2(0.5f, 0.5f)).r, 0.0f, 0.1f) * TimeRate;

float4 UpdateTime_VS(float4 Pos : POSITION) : POSITION
{
    return Pos;
}

float4 UpdateTime_PS() : COLOR
{
   return float4(time, 0, 0, 1);
}

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

float4 UpdatePos_PS(float2 Tex: TEXCOORD0) : COLOR
{
   // ���q�̍��W
   float4 Pos = tex2D(CoordSmp, Tex);

   // ���q�̑��x
   float3 Vel = tex2D(VelocitySmp, Tex).xyz;

   if(Pos.w < 1.001f){
   // ���������q�̒�����ړ������ɉ����ĐV���ɗ��q�𔭐�������
      // ���݂̃I�u�W�F�N�g���W
      float3 WPos1 = BackWorldCoord(WorldMatrix._41_42_43);

      // 1�t���[���O�̃I�u�W�F�N�g���W
      float4 WPos0 = tex2D(WorldCoordSmp, float2(0.5f, 0.5f));
      WPos0.xyz -= VelocityField(WPos1) * Dt; // ���̑��x��ʒu�␳

      // 1�t���[���Ԃ̔������q��
      float p_count = length( WPos1 - WPos0.xyz ) * OccurFactor * AcsSi*0.1f;

      // ���q�C���f�b�N�X
      int i = floor( Tex.x*TEX_WIDTH );
      int j = floor( Tex.y*TEX_HEIGHT );
      float p_index = float( i*TEX_HEIGHT + j );

      // �V���ɗ��q�𔭐������邩�ǂ����̔���
      if(p_index < WPos0.w) p_index += float(TEX_WIDTH*TEX_HEIGHT);
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

      // �V�������W�ɍX�V
      Pos.xyz += Dt * (Vel + Dt * Accel);

      // ���łɔ������Ă��闱�q�͌o�ߎ��Ԃ�i�߂�
      Pos.w += Dt;
      Pos.w *= step(Pos.w-1.0f, ParticleLife); // �w�莞�Ԃ𒴂����0(���q����)
   }

   // 0�t���[���Đ��ŗ��q������
   if(time < 0.001f) Pos = float4(WorldMatrix._41_42_43, 0.0f);

   return Pos;
}

////////////////////////////////////////////////////////////////////////////////////////
// ���q�̑��x�v�Z

float4 UpdateVelocity_PS(float2 Tex: TEXCOORD0) : COLOR
{
   // ���q�̍��W
   float4 Pos = tex2D(CoordSmp, Tex);

   // ���q�̑��x
   float4 Vel = tex2D(VelocitySmp, Tex);

   if(Pos.w < 1.00111f){
      // ���������Ă̗��q�ɏ����x��^����
      int j = floor( Tex.y*TEX_HEIGHT );
      float speed = lerp( ParticleSpeedMin, ParticleSpeedMax, Color2Float(j, 1).y );
      float3 pVel = Color2Float(j, 0) * speed;
      float4 WPos0 = tex2D(WorldCoordSmp, float2(0.5f, 0.5f));
      float3 WPos1 = BackWorldCoord(WorldMatrix._41_42_43);
      float3 wVel = normalize(WPos1-WPos0.xyz) * ObjVelocityRate; // �I�u�W�F�N�g�ړ�������t������
      Vel = float4( wVel+pVel, 1.0f )  ;
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

float4 WorldCoord_PS(float2 Tex: TEXCOORD0) : COLOR
{
   // �I�u�W�F�N�g�̃��[���h���W
   float3 Pos1 = BackWorldCoord(WorldMatrix._41_42_43);
   float4 Pos0 = tex2D(WorldCoordSmp, Tex);
   Pos0.xyz -= VelocityField(Pos1) * Dt; // ���̑��x��ʒu�␳

   // ���������q�̋N�_
   float p_count = length( Pos1 - Pos0.xyz ) * OccurFactor * AcsSi*0.1f;
   float w = Pos0.w + p_count;
   if(w >= float(TEX_WIDTH*TEX_HEIGHT)) w -= float(TEX_WIDTH*TEX_HEIGHT);
   if(time < 0.001f) w = 0.0f;

   return float4(Pos1, w);
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
    float3 Param     : TEXCOORD1;   // x�o�ߎ���,y�{�[�h�s�N�Z���T�C�Y,z��]
    float4 VPos      : TEXCOORD4;   // �r���[���W
    float4 Color     : COLOR0;      // ���q�̐F
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
   Pos0.xyz = InvBackWorldCoord(Pos0.xyz);

   // �o�ߎ���
   float etime = Pos0.w - 1.0f;
   Out.Param.x = etime;

   // �����ݒ�
   float3 rand = tex2Dlod(ArrangeSmp, float4(3.5f/TEX_WIDTH_A, (j+0.5f)/TEX_HEIGHT, 0, 0)).xyz;

   // �o�ߎ��Ԃɑ΂��闱�q�g��x
   float scale = ParticleScaleUp * sqrt(etime) + 0.1f;

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

    // �J�������_�̃r���[�ϊ�
    Out.VPos = mul( Pos, ViewMatrix );

   // �J�������_�̃r���[�ˉe�ϊ�
    Out.Pos = mul( Pos, GET_VPMAT(Pos) );

   // ���q�̏�Z�F
   float alpha = step(0.001f, etime) * smoothstep(-ParticleLife, -ParticleLife*ParticleDecrement, -etime) * AcsTr;
   Out.Color = float4(0, 0, 0, alpha);

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
    // ���q�e�N�X�`��(�m�[�}���}�b�v)����@���v�Z
    float shadeDiffuse = max( IN.Param.y, lerp(0, ParticleShadeDiffusion, IN.Param.x/ParticleLife) );
    float4 Color = tex2Dlod( ParticleSamp, float4(IN.Tex, 0, shadeDiffuse) );

    // �������ʂ͕`�悵�Ȃ�
    clip( Color.a - 0.5f );

    // �@��(0�`1�ɂȂ�悤�␳)
    float3 Normal = float3(2.0f * Color.r - 1.0f, 1.0f - 2.0f * Color.g,  -Color.b);
    Normal.xy = Rotation2D(Normal.xy, IN.Param.z);
    Normal = normalize(Normal);
    Normal = (Normal + 1.0f) / 2.0f;
    Normal = lerp(float3(0.5, 0.5, 0.0f), Normal, IN.Color.a);

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
        "RenderColorTarget0=WorldCoord;"
            "RenderDepthStencilTarget=WorldCoordDepthBuffer;"
            "Pass=UpdateWorldCoord;"
       #ifdef MIKUMIKUMOVING
       "RenderColorTarget0=TimeTex;"
            "RenderDepthStencilTarget=TimeDepthBuffer;"
            "Pass=UpdateTime;"
       #endif
        "RenderColorTarget0=;"
            "RenderDepthStencilTarget=;"
            "LoopByCount=RepertCount;"
            "LoopGetIndex=RepertIndex;"
                "Pass=DrawObject;"
            "LoopEnd=;"
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
    pass UpdateWorldCoord < string Script= "Draw=Buffer;"; > {
        ALPHABLENDENABLE = FALSE;
        ALPHATESTENABLE = FALSE;
        VertexShader = compile vs_2_0 WorldCoord_VS();
        PixelShader  = compile ps_2_0 WorldCoord_PS();
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
    pass DrawObject {
        ZENABLE = TRUE;
        ZWRITEENABLE = FALSE;
        ALPHABLENDENABLE = FALSE;
        VertexShader = compile vs_3_0 Particle_VS();
        PixelShader  = compile ps_3_0 Particle_PS();
    }
}




///////////////////////////////////////////////////////////////////////////////////////
// �G�b�W�E�n�ʉe�EZPlot�͕\�����Ȃ�
technique EdgeTec < string MMDPass = "edge"; > { }
technique ShadowTec < string MMDPass = "shadow"; > { }
technique ZplotTec < string MMDPass = "zplot";> { }

