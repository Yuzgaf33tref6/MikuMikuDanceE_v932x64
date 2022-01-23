////////////////////////////////////////////////////////////////////////////////////////////////
//
//  Butterfly.fx ver0.0.3  ���̌Q��p�[�e�B�N���G�t�F�N�g
//  �쐬: �j��P
//
////////////////////////////////////////////////////////////////////////////////////////////////
// �����̃p�����[�^��ύX���Ă�������

// ���p�����[�^�X�C�b�`
#define TEX_TYPE    1    // ���̎��(�Ƃ肠����1�`4�Ńe�N�X�`���I��)
#define MMD_LIGHT   1    // MMD�̏Ɩ������ 0:�A�����Ȃ�, 1:�A������

int Count = 200;  // ���̐�(�ő�512�܂�)

// ���p�����[�^�ݒ�
float ButterflySize = 0.7;       // ���̃T�C�Y
float RandamMove = 8.0;          // �����_���ȓ����x����
float FlapAmp = 1.8;             // �H�΂����U��
float FlapFreq = 14.0;           // �H�΂������g��

float DrivingForceFactor = 8.0;  // ���i��(�傫������ƈړ��X�s�[�h�������Ȃ�)
float ResistanceFactor = 2.0;    // ��R��(�傫������ƈړ��X�s�[�h���������₷���Ȃ�)
float VerticalAngleLimit = 30.0; // �����ړ������p(0�`90)(�傫������Ə㉺�����̈ړ��������ɂȂ�)
float PotentialOutside = 35.0;   // �ړ������O������(�傫������ƈړ��͈͂��L���Ȃ�)
float PotentialFloor = 2.0;      // �ړ��������ʍ���(�傫������Ə��ɋ߂Â������ɍ����ʒu�ŉ���s�����Ƃ�)
float PotentialCiel = 30.0;      // �ړ������V�䍂��(�傫������Ƃ�荂���ʒu�܂ňړ�����悤�ɂȂ�)

#define UnitHitAvoid  0    // ���j�b�g���m�̏Փˉ�𔻒������ꍇ��1�ɂ���(�d���Ȃ�\���L��)
float WideViewRadius = 30.0;     // ���F�G���A���a(�傫������Ƒ��̃��j�b�g��������₷���Ȃ�)
float WideViewAngle = 45.0;      // ���F�G���A�p�x(0�`180)(�傫������Ƒ��̃��j�b�g��������₷���Ȃ�)
float SeparationFactor = 30.0;   // �����x(�傫������Ɨאڃ��j�b�g�Ƃ̏Փˉ��x���傫���Ȃ�)
float SeparationLength = 10.0;   // �������苗��(�傫������Ɨאڃ��j�b�g�Ƃ̏Փˉ���s�����Ƃ�₷���Ȃ�)

#define WriteZBuffer  0    // ���j�b�g�`�掞��Z�o�b�t�@������������ꍇ��1�ɂ���


// �K�v�ɉ����Ē��e�N�X�`���������Œ�`
#if TEX_TYPE == 1
   #define TEX_FileName  "��1.png"  // �I�u�W�F�N�g�ɓ\��t����e�N�X�`���t�@�C����
   #define TEX_PARTICLE_XNUM  2     // �e�N�X�`��x�������̐�
   #define TEX_PARTICLE_YNUM  1     // �e�N�X�`��y�������̐�
   #define TEX_ADD_FLG     0        // 0:����������, 1:���Z����
#endif

#if TEX_TYPE == 2
   #define TEX_FileName  "��2.png"  // �I�u�W�F�N�g�ɓ\��t����e�N�X�`���t�@�C����
   #define TEX_PARTICLE_XNUM  5     // �e�N�X�`��x�������̐�
   #define TEX_PARTICLE_YNUM  1     // �e�N�X�`��y�������̐�
   #define TEX_ADD_FLG     0        // 0:����������, 1:���Z����
#endif

#if TEX_TYPE == 3
   #define TEX_FileName  "��3.png"  // �I�u�W�F�N�g�ɓ\��t����e�N�X�`���t�@�C����
   #define TEX_PARTICLE_XNUM  4     // �e�N�X�`��x�������̐�
   #define TEX_PARTICLE_YNUM  1     // �e�N�X�`��y�������̐�
   #define TEX_ADD_FLG     0        // 0:����������, 1:���Z����
#endif

#if TEX_TYPE == 4
   #define TEX_FileName  "��3(���Z�����p).png"  // �I�u�W�F�N�g�ɓ\��t����e�N�X�`���t�@�C����
   #define TEX_PARTICLE_XNUM  4     // �e�N�X�`��x�������̐�
   #define TEX_PARTICLE_YNUM  1     // �e�N�X�`��y�������̐�
   #define TEX_ADD_FLG     1        // 0:����������, 1:���Z����
#endif


// ����Ȃ��l�͂������牺�͂�����Ȃ��ł�
////////////////////////////////////////////////////////////////////////////////////////////////

float AcsY  : CONTROLOBJECT < string name = "(self)"; string item = "Y"; >;
float AcsTr : CONTROLOBJECT < string name = "(self)"; string item = "Tr"; >;
float AcsSi : CONTROLOBJECT < string name = "(self)"; string item = "Si"; >;
static float OutsideLength = PotentialOutside * AcsSi * 0.1f;
static float CielHeight = PotentialCiel + AcsY;

static float WideViewCosA = cos( radians(WideViewAngle) );
static float VAngLimit = radians(VerticalAngleLimit);

#define ArrangeFileName "ArrangeData.png" // �����z�u���摜�t�@�C����
#define ARRANGE_TEX_WIDTH  8       // �����z�u�e�N�X�`���s�N�Z����
#define ARRANGE_TEX_HEIGHT 512     // �����z�u�e�N�X�`���s�N�Z������
#define TEX_WIDTH  1               // ���j�b�g�f�[�^�i�[�e�N�X�`���s�N�Z����
#define TEX_HEIGHT 512             // ���j�b�g�f�[�^�i�[�e�N�X�`���s�N�Z������

float time1 : Time;
float elapsed_time : ELAPSEDTIME;
static float Dt = clamp(elapsed_time, 0.001f, 0.1f);

// ���W�ϊ��s��
float4x4 ViewProjMatrix       : VIEWPROJECTION;

float3 LightDirection    : DIRECTION < string Object = "Light"; >;
float3 CameraPosition    : POSITION  < string Object = "Camera"; >;
float4x4 LightViewProjMatrix  : VIEWPROJECTION < string Object = "Light"; >;

// �}�e���A���F
float4 MaterialDiffuse   : DIFFUSE  < string Object = "Geometry"; >;
float3 MaterialAmbient   : AMBIENT  < string Object = "Geometry"; >;
float3 MaterialEmmisive  : EMISSIVE < string Object = "Geometry"; >;
float3 MaterialSpecular  : SPECULAR < string Object = "Geometry"; >;
float  SpecularPower     : SPECULARPOWER < string Object = "Geometry"; >;
// ���C�g�F
float3 LightDiffuse      : DIFFUSE  < string Object = "Light"; >;
float3 LightAmbient      : AMBIENT  < string Object = "Light"; >;
float3 LightSpecular     : SPECULAR < string Object = "Light"; >;
static float4 DiffuseColor  = float4(MaterialDiffuse.rgb  * LightDiffuse, 1.0f);
static float3 AmbientColor  = MaterialAmbient  * LightAmbient + MaterialEmmisive;
static float3 SpecularColor = MaterialSpecular * LightSpecular;

bool parthf;   // �p�[�X�y�N�e�B�u�t���O
bool transp;   // �������t���O
#define SKII1    1500
#define SKII2    8000

// �z�u���e�N�X�`��
texture2D ArrangeTex <
    string ResourceName = ArrangeFileName;
>;
sampler ArrangeSmp = sampler_state{
    texture = <ArrangeTex>;
    MinFilter = POINT;
    MagFilter = POINT;
    MipFilter = NONE;
};

// �I�u�W�F�N�g�ɓ\��t����e�N�X�`��(�~�b�v�}�b�v������)
texture2D ParticleTex <
    string ResourceName = TEX_FileName;
    int MipLevels = 0;
>;
sampler ParticleSamp = sampler_state {
    texture = <ParticleTex>;
    MinFilter = ANISOTROPIC;
    MagFilter = ANISOTROPIC;
    MipFilter = LINEAR;
    AddressU  = CLAMP;
    AddressV  = CLAMP;
};

// 1�t���[���O�̍��W�L�^�p
texture CoordTexOld : RenderColorTarget
<
   int Width=TEX_WIDTH;
   int Height=TEX_HEIGHT;
   string Format="A32B32G32R32F";
>;
sampler SmpCoordOld = sampler_state
{
   Texture = <CoordTexOld>;
   ADDRESSU = CLAMP;
   ADDRESSV = CLAMP;
   MAGFILTER = NONE;
   MINFILTER = NONE;
   MIPFILTER = NONE;
};

// ���݂̍��W�L�^�p
shared texture Butterfly_CoordTex : RenderColorTarget
<
   int Width=TEX_WIDTH;
   int Height=TEX_HEIGHT;
   string Format="A32B32G32R32F";
>;
sampler Butterfly_SmpCoord : register(s2) = sampler_state
{
   Texture = <Butterfly_CoordTex>;
   ADDRESSU = CLAMP;
   ADDRESSV = CLAMP;
   MAGFILTER = NONE;
   MINFILTER = NONE;
   MIPFILTER = NONE;
};

// ���x�L�^�p
shared texture Butterfly_VelocityTex : RenderColorTarget
<
   int Width=TEX_WIDTH;
   int Height=TEX_HEIGHT;
   string Format="A32B32G32R32F";
>;
sampler Butterfly_SmpVelocity : register(s3) = sampler_state
{
   Texture = <Butterfly_VelocityTex>;
   ADDRESSU = CLAMP;
   ADDRESSV = CLAMP;
   MAGFILTER = NONE;
   MINFILTER = NONE;
   MIPFILTER = NONE;
};

// �|�e���V�����L�^�p
shared texture Butterfly_PotentialTex : RenderColorTarget
<
   int Width=TEX_WIDTH;
   int Height=TEX_HEIGHT;
   string Format="A32B32G32R32F";
>;
sampler Butterfly_SmpPotential = sampler_state
{
   Texture = <Butterfly_PotentialTex>;
   ADDRESSU = CLAMP;
   ADDRESSV = CLAMP;
   MAGFILTER = NONE;
   MINFILTER = NONE;
   MIPFILTER = NONE;
};

// ���ʂ̐[�x�X�e���V���o�b�t�@
texture DepthBuffer : RenderDepthStencilTarget <
   int Width=TEX_WIDTH;
   int Height=TEX_HEIGHT;
    string Format = "D24S8";
>;


////////////////////////////////////////////////////////////////////////////////////////////////
// �z�u���e�N�X�`������f�[�^�����o��
float Color2Float(int i, int j)
{
    float4 d = tex2D(ArrangeSmp, float2((i+0.5)/ARRANGE_TEX_WIDTH, (j+0.5)/ARRANGE_TEX_HEIGHT));
    float tNum = (65536.0f * d.x + 256.0f * d.y + d.z) * 255.0f;
    int pNum = round(d.w * 255.0f);
    int sgn = 1 - 2 * (pNum % 2);
    float data = tNum * pow(10.0f, pNum/2 - 64) * sgn;
    return data;
}

////////////////////////////////////////////////////////////////////////////////////////////////
// ���f���̉�]�s��
float4x4 RoundMatrix(float3 Angle)
{
   float3 AngleY = normalize( float3(Angle.x, 0.0f, Angle.z) );
   float cosy = -AngleY.z;
   float siny = sign(AngleY.x) * sqrt(1.0f - cosy*cosy);
   float3 AngleXY = normalize( float3(Angle.x, 0.0f, Angle.z) );
   float cosx = dot( AngleXY, Angle );
   float sinx = sign(Angle.y) * sqrt(1.0f - cosx*cosx);

   float4x4 rMat = { cosy,       0.0f,  siny,      0.0f,
                    -sinx*siny,  cosx,  sinx*cosy, 0.0f,
                    -cosx*siny, -sinx,  cosx*cosy, 0.0f,
                     0.0f,       0.0f,  0.0f,      1.0f };

   return rMat;
}

////////////////////////////////////////////////////////////////////////////////////////////////
// ���f���̉�]�t�s��
float4x4 InvRoundMatrix(float3 Angle)
{
   float3 AngleY = normalize( float3(Angle.x, 0.0f, Angle.z) );
   float cosy = -Angle.z;
   float siny = sign(Angle.x) * sqrt(1.0f - cosy*cosy);
   float3 AngleXY = normalize( float3(Angle.x, 0.0f, Angle.z) );
   float cosx = dot( Angle, AngleXY );
   float sinx = sign(Angle.y) * sqrt(1.0f - cosx*cosx);

   float4x4 rMat = { cosy, -sinx*siny, -cosx*siny, 0.0f,
                     0.0f,  cosx,      -sinx,      0.0f,
                     siny,  sinx*cosy,  cosx*cosy, 0.0f,
                     0.0f,  0.0f,       0.0f,      1.0f };

   return rMat;
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
// ���ʂ̒��_�V�F�[�_

struct VS_OUTPUT2 {
   float4 Pos      : POSITION;
   float2 texCoord : TEXCOORD0;
};

VS_OUTPUT2 Common_VS(float4 Pos: POSITION, float2 Tex: TEXCOORD)
{
   VS_OUTPUT2 Out;
   Out.Pos = Pos;
   Out.texCoord = Tex + float2(0.5f/TEX_WIDTH, 0.5f/TEX_HEIGHT);
   return Out;
}

////////////////////////////////////////////////////////////////////////////////////////////////
// 0�t���[���Đ��Ń��j�b�g���W��������

float4 PosInit_PS(float2 texCoord: TEXCOORD0) : COLOR
{
   float4 Pos;
   if( time1 < 0.001f ){
      // 0�t���[���Đ��Ń��Z�b�g
      int i = floor( texCoord.y*TEX_HEIGHT );
      float y = lerp(PotentialFloor, PotentialCiel, Color2Float(1, i));
      float3 pos = float3(Color2Float(0, i), y, Color2Float(2, i));
      Pos = float4( pos, 0.0f );
   }else{
      Pos = tex2D(Butterfly_SmpCoord, texCoord);
   }

   return Pos;
}

////////////////////////////////////////////////////////////////////////////////////////////////
// �����E���x�̌v�Z(xyz:���K�����ꂽ�����x�N�g���Cw:����)

float4 Velocity_PS(float2 texCoord: TEXCOORD0) : COLOR
{
   float4 vel;
   if( time1 < 0.001f ){
      // 0�t���[���Đ��ŕ���������
      int i = floor( texCoord.y*TEX_HEIGHT );
      float rx = Color2Float(3, i);
      float ry = Color2Float(4, i);
      float sinx = sin(rx);
      float cosx = cos(rx);
      float siny = sin(ry);
      float cosy = cos(ry);
      float3x3 rMat = { cosy,       0.0f,  siny,
                       -sinx*siny,  cosx,  sinx*cosy,
                       -cosx*siny, -sinx,  cosx*cosy};
      float3 ang = mul( float3(0.0f, 0.0f, -1.0f), rMat );
      vel = float4(ang, 0.0f);
   }else{
      float4 vel0 = tex2D(Butterfly_SmpVelocity, texCoord);
      float3 Pos1 = (float3)tex2D(SmpCoordOld, texCoord);
      float3 Pos2 = (float3)tex2D(Butterfly_SmpCoord, texCoord);
      float3 v = ( Pos2 - Pos1 )/Dt;
      float len = length( v );
      vel = (len > 0.0001f) ? float4( normalize(v), len ) : float4( vel0.xyz, len );
   }

   return vel;
}

////////////////////////////////////////////////////////////////////////////////////////////////
// �|�e���V�����̏�����(�|�e���V�����ɂ�鑀�Ǘ͂�1�t���[���O�̌��ʂ��g���邽��
// 0�t���[���Đ����͏������̕K�v�L��)

float4 PotentialInit_PS(float2 texCoord: TEXCOORD0) : COLOR
{
   // �|�e���V�����ɂ�郆�j�b�g�̑��Ǘ�
   float4 SteerForce = tex2D(Butterfly_SmpPotential, texCoord);
   if( time1 < 0.001f ){
      // 0�t���[���Đ��Ń��Z�b�g
      SteerForce = float4(0.0f, 0.0f, 0.0f, 0.0f);
   }

   return SteerForce;
}

////////////////////////////////////////////////////////////////////////////////////////////////
// �����j�b�g���W�l��1�t���[���O�̍��W�ɃR�s�[

float4 PosCopy_PS(float2 texCoord: TEXCOORD0) : COLOR
{
   float4 Pos = tex2D(Butterfly_SmpCoord, texCoord);
   return Pos;
}


////////////////////////////////////////////////////////////////////////////////////////////////
// �����j�b�g���W�l���X�V

float4 PosButterfly_PS(float2 texCoord: TEXCOORD0) : COLOR
{
    // 1�t���[���O�̈ʒu
    float3 Pos0 = tex2D(SmpCoordOld, texCoord).xyz;
    float lenP0 = length( Pos0 );

    // �����E���x
    float4 v = tex2D(Butterfly_SmpVelocity, texCoord);
    float3 Angle = v.xyz;
    float3 Vel = Angle * v.w;

    // ��]�t�s��
    float3x3 invRMat = (float3x3)InvRoundMatrix(Angle);

    // ���Ǘ͏�����
    float3 SteerForce = 0.0f;

    // ���j�b�g�C���f�b�N�X
    int index = floor( texCoord.y*TEX_HEIGHT );

#if(UnitHitAvoid==1)
    // ���j�b�g���m�̏Փˉ��
    for(int i=0; i<Count; i++){
       if( i != index ){
          float y = (float(i) + 0.5f)/TEX_HEIGHT;
          float3 pos_i = tex2D(SmpCoordOld, float2(texCoord.x, y)).xyz;
          float3 ang_i = tex2D(Butterfly_SmpVelocity, float2(texCoord.x, y)).xyz;
          float len = length( pos_i - Pos0 );
          float cosa = dot( normalize(pos_i - Pos0), Angle );
          if(len < WideViewRadius && cosa > WideViewCosA){ // ���F���j�b�g���ǂ���
             if(len < SeparationLength){
                float3 pos_local = mul( pos_i-Pos0, invRMat );
                SteerForce += normalize( -pos_local ) * SeparationFactor / len * min(1.0f, time1/5.0f);
             }
          }
       }
    }
#endif

    // �|�e���V�����ɂ�鑀�Ǘ͂�t��
    SteerForce += tex2D(Butterfly_SmpPotential, texCoord).xyz;

    // �C�܂���ȓ���
    SteerForce.x += RandamMove*(Color2Float(5, index)+0.5f)*sin(Color2Float(6, index)*time1+Color2Float(3, index));

    // ���Ǘ͂̕��������[���h���W�n�ɕϊ�
    SteerForce = mul( SteerForce, (float3x3)RoundMatrix(Angle) );

    // �����x�v�Z(���i��+��R��+���Ǘ�)
    float3 Accel = DrivingForceFactor * Angle - ResistanceFactor * Vel + SteerForce;

    // ���̉H�΂����p�����[�^
    float flap = 0.5f*(1.0f-cos(FlapFreq*(1.0f+0.3f*(Color2Float(7, index)-0.5f))*time1+Color2Float(4, index)));
    flap = 1.0f - pow(flap, 1.5f);

    // �V�������W�ɍX�V
    float4 Pos = float4( Pos0 + Dt * (Vel + Dt * Accel), flap );

    // ���������p�x����
    if( (PotentialFloor <= Pos.y && Pos.y <= CielHeight) ||
        (Pos.y < PotentialFloor && Pos.y < Pos0.y) ||
        (CielHeight < Pos.y && Pos.y > Pos0.y) ){
       float3 pos2 = Pos.xyz - Pos0;
       float3 pos3 = float3(pos2.x, 0.0f, pos2.z );
       float a = acos( min(dot( normalize(pos2), normalize(pos3) ), 1.0f) );
       if(a > VAngLimit){
          pos3.y = sign(pos2.y) * length(pos3) * tan(VAngLimit);
          Pos = float4( Pos0 + pos3, flap );
       }
    }

    return Pos;
}


////////////////////////////////////////////////////////////////////////////////////////////////
// ���j�b�g���w��͈͓��ɗ��߂邽�߂̃|�e���V�����ɂ�鑀�Ǘ͂����߂�

float4 Potential_PS(float2 texCoord: TEXCOORD0) : COLOR
{
    // ���j�b�g�̈ʒu
    float3 Pos0 = (float3)tex2D(Butterfly_SmpCoord, texCoord);
    float lenP0 = length( Pos0 );

    // ���j�b�g�̕����E���x
    float4 v = tex2D(Butterfly_SmpVelocity, texCoord);
    float3 Angle = v.xyz;
    float3 Vel = Angle * v.w;

    // ��]�t�s��
    float3x3 invRMat = (float3x3)InvRoundMatrix(Angle);

    // �|�e���V�����ɂ�鑀�Ǘ͏�����
    float3 SteerForce = float3(0.0f, 0.0f, 0.0f);

    // �O���|�e���V����(�����ɍs�������Ȃ��悤��)
    float limit = (lenP0 < 2.0f*OutsideLength) ? -abs(cos(time1)) : -0.9999f;
    float p = clamp(-OutsideLength-Pos0.x, 0.0f, 20.0f);
    if( p > 0.0f && dot( Angle, float3(-1.0f, 0.0f, 0.0f) ) > limit ){
       float3 pa = mul( float3(-Pos0.x, 0.0f, -Pos0.z), invRMat );
       pa.z = 0.0f;
       SteerForce += normalize(pa)*p*p;
    }
    p = clamp(Pos0.x-OutsideLength, 0.0f, 20.0f);
    if( p > 0.0f && dot( Angle, float3(1.0f, 0.0f, 0.0f) ) > limit ){
       float3 pa = mul( float3(-Pos0.x, 0.0f, -Pos0.z), invRMat );
       pa.z = 0.0f;
       SteerForce += normalize(pa)*p*p;
    }
    p = clamp(-OutsideLength-Pos0.z, 0.0f, 20.0f);
    if( p > 0.0f && dot( Angle, float3(0.0f, 0.0f, -1.0f) ) > limit ){
       float3 pa = mul( float3(-Pos0.x, 0.0f, -Pos0.z), invRMat );
       pa.z = 0.0f;
       SteerForce += normalize(pa)*p*p;
    }
    p = clamp(Pos0.z-OutsideLength, 0.0f, 20.0f);
    if( p > 0.0f && dot( Angle, float3(0.0f, 0.0f, 1.0f) ) > limit ){
       float3 pa = mul( float3(-Pos0.x, 0.0f, -Pos0.z), invRMat );
       pa.z = 0.0f;
       SteerForce += normalize(pa)*p*p;
    }

    // ���ʃ|�e���V����(�����ɐ���Ȃ��悤��)
    p = max( PotentialFloor - Pos0.y, 0.0f);
    SteerForce.y += p*p;

    // �V��|�e���V����(����߂��Ȃ��悤��)
    p = max( Pos0.y - CielHeight, 0.0f);
    SteerForce.y -= p*p;

   return float4(SteerForce, 0.0f);
}

/////////////////////////////////////////////////////////////////////////////////
// �I�u�W�F�N�g�`��i�Z���t�V���h�EOFF�j

struct VS_OUTPUT
{
    float4 Pos    : POSITION;    // �ˉe�ϊ����W
    float2 Tex    : TEXCOORD0;   // �e�N�X�`��
    float3 Normal : TEXCOORD1;   // �@��
    float3 Eye    : TEXCOORD2;   // �J�����Ƃ̑��Έʒu
    float4 Color  : COLOR0;      // ���q�̏�Z�F
};

// ���_�V�F�[�_
VS_OUTPUT Particle_VS(float4 Pos : POSITION, float3 Normal : NORMAL, float2 Tex : TEXCOORD0, int index: _INDEX)
{
   VS_OUTPUT Out;

   int Index = round( -Pos.y * 100.0f );
   int Index2 = round( fmod(index, 8.0f) );
   Pos.y = 0.0f;
   float2 texCoord = float2(0.5f/TEX_WIDTH, (Index+0.5f)/TEX_HEIGHT);

   // ���̊�_���W
   float4 Pos0 = tex2Dlod(Butterfly_SmpCoord, float4(texCoord, 0, 0));

   // ���̕����x�N�g��
   float3 Angle = tex2Dlod(Butterfly_SmpVelocity, float4(texCoord, 0, 0)).xyz;

   // ���̉H�΂���
   float rot = 0.0f;
   if(Index2 < 4){
      rot = lerp(radians(30.0f), radians(-85.0f), Pos0.w);
   }else{
      rot = lerp(radians(-30.0f), radians(85.0f), Pos0.w);
   }
   Pos.xy = Rotation2D(Pos.xy, rot);
   Pos.y -= FlapAmp * (Pos0.w-0.5f) * 0.1f;
   Normal.xy = Rotation2D(Normal.xy, rot);

   // ���̑傫��
   Pos.xyz *= ButterflySize * 10.0f;

   // ���̉�]
   float4x4 rotMat = RoundMatrix(Angle);
   Pos = mul( Pos, rotMat );
   Out.Normal = normalize( mul( Normal, (float3x3)rotMat ) );

   // ���̃��[���h���W
   Pos.xyz += Pos0.xyz;
   Pos.xyz *= step(Index, Count);
   Pos.w = 1.0f;

   // �J�������_�̃r���[�ˉe�ϊ�
   Out.Pos = mul( Pos, ViewProjMatrix );

   // �J�����Ƃ̑��Έʒu
   Out.Eye = CameraPosition - Pos.xyz;

   // �f�B�t���[�Y�F�{�A���r�G���g�F �v�Z
   Out.Color.rgb = AmbientColor;
   Out.Color.rgb += max(0.0f, dot( Out.Normal, -LightDirection )) * DiffuseColor.rgb;
   Out.Color.a = AcsTr*step(Index, Count);
   Out.Color = saturate( Out.Color );

   // �e�N�X�`�����W
   int texIndex = Index % (TEX_PARTICLE_XNUM * TEX_PARTICLE_YNUM);
   int tex_i = texIndex % TEX_PARTICLE_XNUM;
   int tex_j = texIndex / TEX_PARTICLE_XNUM;
   Out.Tex = float2((Tex.x + tex_i)/TEX_PARTICLE_XNUM, (Tex.y + tex_j)/TEX_PARTICLE_YNUM);

   return Out;
}

// �s�N�Z���V�F�[�_
float4 Particle_PS( VS_OUTPUT IN ) : COLOR0
{
#if(MMD_LIGHT==1)
   // �X�y�L�����F�v�Z
   float3 HalfVector = normalize( normalize(IN.Eye) + -LightDirection );
   float3 Specular = pow( max(0,dot( HalfVector, normalize(IN.Normal) )), SpecularPower ) * SpecularColor;

   float4 Color = IN.Color;

   // �e�N�X�`���K�p
   Color *= tex2D( ParticleSamp, float2(IN.Tex.x, 1.0f-IN.Tex.y) );

   // �X�y�L�����K�p
   Color.rgb += Specular;
#else
   // �e�N�X�`���K�p
   float4 Color = tex2D( ParticleSamp, float2(IN.Tex.x, 1.0f-IN.Tex.y) );
#endif
   return Color;
}


/////////////////////////////////////////////////////////////////////////////////
// �e�N�j�b�N�i�Z���t�V���h�EOFF�j

technique MainTec0 < string MMDPass = "object";
    string Script = 
        "RenderColorTarget0=Butterfly_CoordTex;"
	    "RenderDepthStencilTarget=DepthBuffer;"
	    "Pass=PosInit;"
        "RenderColorTarget0=Butterfly_VelocityTex;"
	    "RenderDepthStencilTarget=DepthBuffer;"
	    "Pass=CalcVelocity;"
        "RenderColorTarget0=Butterfly_PotentialTex;"
	    "RenderDepthStencilTarget=DepthBuffer;"
	    "Pass=PotentialInit;"
        "RenderColorTarget0=CoordTexOld;"
	    "RenderDepthStencilTarget=DepthBuffer;"
	    "Pass=PosCopy;"
        "RenderColorTarget0=Butterfly_CoordTex;"
	    "RenderDepthStencilTarget=DepthBuffer;"
	    "Pass=PosUpdate;"
        "RenderColorTarget0=Butterfly_PotentialTex;"
	    "RenderDepthStencilTarget=DepthBuffer;"
	    "Pass=CalcPotential;"
        "RenderColorTarget0=;"
	    "RenderDepthStencilTarget=;"
            "Pass=DrawObject;";
>{
    pass PosInit < string Script = "Draw=Buffer;";>
    {
        ALPHABLENDENABLE = FALSE;
        ALPHATESTENABLE = FALSE;
        VertexShader = compile vs_3_0 Common_VS();
        PixelShader  = compile ps_3_0 PosInit_PS();
    }
    pass CalcVelocity < string Script = "Draw=Buffer;";>
    {
        ALPHABLENDENABLE = FALSE;
        ALPHATESTENABLE = FALSE;
        VertexShader = compile vs_3_0 Common_VS();
        PixelShader  = compile ps_3_0 Velocity_PS();
    }
    pass PotentialInit < string Script = "Draw=Buffer;";>
    {
        ALPHABLENDENABLE = FALSE;
        ALPHATESTENABLE = FALSE;
        VertexShader = compile vs_1_1 Common_VS();
        PixelShader  = compile ps_2_0 PotentialInit_PS();
    }
    pass PosCopy < string Script = "Draw=Buffer;";>
    {
        ALPHABLENDENABLE = FALSE;
        ALPHATESTENABLE = FALSE;
        VertexShader = compile vs_1_1 Common_VS();
        PixelShader  = compile ps_2_0 PosCopy_PS();
    }
    pass PosUpdate < string Script = "Draw=Buffer;";>
    {
        ALPHABLENDENABLE = FALSE;
        ALPHATESTENABLE = FALSE;
        VertexShader = compile vs_3_0 Common_VS();
        PixelShader  = compile ps_3_0 PosButterfly_PS();
    }
    pass CalcPotential < string Script = "Draw=Buffer;";>
    {
        ALPHABLENDENABLE = FALSE;
        ALPHATESTENABLE = FALSE;
        VertexShader = compile vs_3_0 Common_VS();
        PixelShader  = compile ps_3_0 Potential_PS();
    }
    pass DrawObject {
        ZENABLE = TRUE;
        #if(WriteZBuffer == 0)
        ZWRITEENABLE = FALSE;
        #endif
        #if(TEX_ADD_FLG == 1)
        DestBlend = ONE;
        SrcBlend = ONE;
        #else
        DestBlend = INVSRCALPHA;
        SrcBlend = SRCALPHA;
        #endif
        AlphaBlendEnable = TRUE;
        CullMode = NONE;
        VertexShader = compile vs_3_0 Particle_VS();
        PixelShader  = compile ps_3_0 Particle_PS();
   }
}

///////////////////////////////////////////////////////////////////////////////////////////////
// �Z���t�V���h�E�pZ�l�v���b�g

struct VS_ZValuePlot_OUTPUT {
    float4 Pos : POSITION;            // �ˉe�ϊ����W
    float4 ShadowMapTex : TEXCOORD0;  // Z�o�b�t�@�e�N�X�`��
    float2 Tex : TEXCOORD1;           // �e�N�X�`��
};

// ���_�V�F�[�_
VS_ZValuePlot_OUTPUT ZValuePlot_VS( float4 Pos : POSITION, float2 Tex : TEXCOORD0, int index: _INDEX )
{
   VS_ZValuePlot_OUTPUT Out = (VS_ZValuePlot_OUTPUT)0;

   int Index = round( -Pos.y * 100.0f );
   int Index2 = round( fmod(index, 8.0f) );
   Pos.y = 0.0f;
   float2 texCoord = float2(0.5f/TEX_WIDTH, (Index+0.5f)/TEX_HEIGHT);

   // ���̊�_���W
   float4 Pos0 = tex2Dlod(Butterfly_SmpCoord, float4(texCoord, 0, 0));

   // ���̕����x�N�g��
   float3 Angle = tex2Dlod(Butterfly_SmpVelocity, float4(texCoord, 0, 0)).xyz;

   // ���̉H�΂���
   float rot = 0.0f;
   if(Index2 < 4){
      rot = lerp(radians(30.0f), radians(-85.0f), Pos0.w);
   }else{
      rot = lerp(radians(-30.0f), radians(85.0f), Pos0.w);
   }
   Pos.xy = Rotation2D(Pos.xy, rot);
   Pos.y -= FlapAmp * (Pos0.w-0.5f) * 0.1f;

   // ���̑傫��
   Pos.xyz *= ButterflySize * 10.0f;

   // ���̉�]
   float4x4 rotMat = RoundMatrix(Angle);
   Pos = mul( Pos, rotMat );

   // ���̃��[���h���W
   Pos.xyz += Pos0.xyz;
   Pos.xyz *= step(Index, Count);
   Pos.w = 1.0f;

   // ���C�g�̖ڐ��ɂ��r���[�ˉe�ϊ�
   Out.Pos = mul( Pos, LightViewProjMatrix );

   // �e�N�X�`�����W�𒸓_�ɍ��킹��
   Out.ShadowMapTex = Out.Pos;

   // �e�N�X�`�����W
   int texIndex = Index % (TEX_PARTICLE_XNUM * TEX_PARTICLE_YNUM);
   int tex_i = texIndex % TEX_PARTICLE_XNUM;
   int tex_j = texIndex / TEX_PARTICLE_XNUM;
   Out.Tex = float2((Tex.x + tex_i)/TEX_PARTICLE_XNUM, (Tex.y + tex_j)/TEX_PARTICLE_YNUM);

   return Out;
}

// �s�N�Z���V�F�[�_
float4 ZValuePlot_PS( VS_ZValuePlot_OUTPUT IN ) : COLOR
{
   // �e�N�X�`���K�p
   float4 Color = tex2D( ParticleSamp, float2(IN.Tex.x, 1.0f-IN.Tex.y) );
   float alpha = Color.a * AcsTr;
   float s = (alpha >= 0.01f) ? IN.ShadowMapTex.z/IN.ShadowMapTex.w : 1.0f;
   float a = (alpha >= 0.01f) ? 1.0f : 0.0f;

   // R�F������Z�l���L�^����
   return float4(s, 0.0f, 0.0f, a);
}

// Z�l�v���b�g�p�e�N�j�b�N
technique ZplotTec < string MMDPass = "zplot"; >
{
    pass ZValuePlot {
        VertexShader = compile vs_3_0 ZValuePlot_VS();
        PixelShader  = compile ps_3_0 ZValuePlot_PS();
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////
// �I�u�W�F�N�g�`��i�Z���t�V���h�EON�j

// �V���h�E�o�b�t�@�̃T���v���B"register(s0)"�Ȃ̂�MMD��s0���g���Ă��邩��
sampler DefSampler : register(s0);

struct BufferShadow_OUTPUT {
    float4 Pos      : POSITION;     // �ˉe�ϊ����W
    float4 ZCalcTex : TEXCOORD0;    // Z�l
    float2 Tex      : TEXCOORD1;    // �e�N�X�`��
    float3 Normal   : TEXCOORD2;    // �@��
    float3 Eye      : TEXCOORD3;    // �J�����Ƃ̑��Έʒu
    float4 Color    : COLOR0;       // �f�B�t���[�Y�F
};

// ���_�V�F�[�_
BufferShadow_OUTPUT ParticleSS_VS(float4 Pos : POSITION, float3 Normal : NORMAL, float2 Tex : TEXCOORD0, int index: _INDEX)
{
    BufferShadow_OUTPUT Out = (BufferShadow_OUTPUT)0;

   int Index = round( -Pos.y * 100.0f );
   int Index2 = round( fmod(index, 8.0f) );
   Pos.y = 0.0f;
   float2 texCoord = float2(0.5f/TEX_WIDTH, (Index+0.5f)/TEX_HEIGHT);

   // ���̊�_���W
   float4 Pos0 = tex2Dlod(Butterfly_SmpCoord, float4(texCoord, 0, 0));

   // ���̕����x�N�g��
   float3 Angle = tex2Dlod(Butterfly_SmpVelocity, float4(texCoord, 0, 0)).xyz;

   // ���̉H�΂���
   float rot = 0.0f;
   if(Index2 < 4){
      rot = lerp(radians(30.0f), radians(-85.0f), Pos0.w);
   }else{
      rot = lerp(radians(-30.0f), radians(85.0f), Pos0.w);
   }
   Pos.xy = Rotation2D(Pos.xy, rot);
   Pos.y -= FlapAmp * (Pos0.w-0.5f) * 0.1f;
   Normal.xy = Rotation2D(Normal.xy, rot);

   // ���̑傫��
   Pos.xyz *= ButterflySize * 10.0f;

   // ���̉�]
   float4x4 rotMat = RoundMatrix(Angle);
   Pos = mul( Pos, rotMat );
   Out.Normal = normalize( mul( Normal, (float3x3)rotMat ) );

   // ���̃��[���h���W
   Pos.xyz += Pos0.xyz;
   Pos.xyz *= step(Index, Count);
   Pos.w = 1.0f;

   // �J�������_�̃r���[�ˉe�ϊ�
   Out.Pos = mul( Pos, ViewProjMatrix );

   // �J�����Ƃ̑��Έʒu
   Out.Eye = CameraPosition - Pos.xyz;

   // ���C�g���_�ɂ��r���[�ˉe�ϊ�
   Out.ZCalcTex = mul( Pos, LightViewProjMatrix );

   // �f�B�t���[�Y�F�{�A���r�G���g�F �v�Z
   Out.Color.rgb = AmbientColor;
   Out.Color.rgb += max(0.0f, dot( Out.Normal, -LightDirection )) * DiffuseColor.rgb;
   Out.Color.a = AcsTr*step(Index, Count);
   Out.Color = saturate( Out.Color );

   // �e�N�X�`�����W
   int texIndex = Index % (TEX_PARTICLE_XNUM * TEX_PARTICLE_YNUM);
   int tex_i = texIndex % TEX_PARTICLE_XNUM;
   int tex_j = texIndex / TEX_PARTICLE_XNUM;
   Out.Tex = float2((Tex.x + tex_i)/TEX_PARTICLE_XNUM, (Tex.y + tex_j)/TEX_PARTICLE_YNUM);

   return Out;
}

// �s�N�Z���V�F�[�_
float4 ParticleSS_PS(BufferShadow_OUTPUT IN) : COLOR
{
#if(MMD_LIGHT==1)
   // �X�y�L�����F�v�Z
   float3 HalfVector = normalize( normalize(IN.Eye) + -LightDirection );
   float3 Specular = pow( max(0,dot( HalfVector, normalize(IN.Normal) )), SpecularPower ) * SpecularColor;

   float4 Color = IN.Color;
   float4 ShadowColor = float4(AmbientColor, Color.a);  // �e�̐F

   // �e�N�X�`���K�p
   float4 TexColor = tex2D( ParticleSamp, float2(IN.Tex.x, 1.0f-IN.Tex.y) );
   Color *= TexColor;
   ShadowColor *= TexColor;

   // �X�y�L�����K�p
   Color.rgb += Specular;

   // �e�N�X�`�����W�ɕϊ�
   IN.ZCalcTex /= IN.ZCalcTex.w;
   float2 TransTexCoord;
   TransTexCoord.x = (1.0f + IN.ZCalcTex.x)*0.5f;
   TransTexCoord.y = (1.0f - IN.ZCalcTex.y)*0.5f;

   if( any( saturate(TransTexCoord) - TransTexCoord ) ) {
       // �V���h�E�o�b�t�@�O
       return Color;
   } else {
       float comp;
       if(parthf) {
           // �Z���t�V���h�E mode2
           comp=1-saturate(max(IN.ZCalcTex.z-tex2D(DefSampler,TransTexCoord).r , 0.0f)*SKII2*TransTexCoord.y-0.3f);
       } else {
           // �Z���t�V���h�E mode1
           comp=1-saturate(max(IN.ZCalcTex.z-tex2D(DefSampler,TransTexCoord).r , 0.0f)*SKII1-0.3f);
       }
       float4 ans = lerp(ShadowColor, Color, comp);
       if( transp ) ans.a = 0.5f;
       return ans;
   }
#else
   // �e�N�X�`���K�p
   float4 Color = tex2D( ParticleSamp, float2(IN.Tex.x, 1.0f-IN.Tex.y) );
   return Color;
#endif
}

/////////////////////////////////////////////////////////////////////////////////
// �e�N�j�b�N�i�Z���t�V���h�EON�j

technique MainTec1 < string MMDPass = "object_ss";
    string Script = 
        "RenderColorTarget0=Butterfly_CoordTex;"
	    "RenderDepthStencilTarget=DepthBuffer;"
	    "Pass=PosInit;"
        "RenderColorTarget0=Butterfly_VelocityTex;"
	    "RenderDepthStencilTarget=DepthBuffer;"
	    "Pass=CalcVelocity;"
        "RenderColorTarget0=Butterfly_PotentialTex;"
	    "RenderDepthStencilTarget=DepthBuffer;"
	    "Pass=PotentialInit;"
        "RenderColorTarget0=CoordTexOld;"
	    "RenderDepthStencilTarget=DepthBuffer;"
	    "Pass=PosCopy;"
        "RenderColorTarget0=Butterfly_CoordTex;"
	    "RenderDepthStencilTarget=DepthBuffer;"
	    "Pass=PosUpdate;"
        "RenderColorTarget0=Butterfly_PotentialTex;"
	    "RenderDepthStencilTarget=DepthBuffer;"
	    "Pass=CalcPotential;"
        "RenderColorTarget0=;"
	    "RenderDepthStencilTarget=;"
            "Pass=DrawObject;";
>{
    pass PosInit < string Script = "Draw=Buffer;";>
    {
        ALPHABLENDENABLE = FALSE;
        ALPHATESTENABLE = FALSE;
        VertexShader = compile vs_3_0 Common_VS();
        PixelShader  = compile ps_3_0 PosInit_PS();
    }
    pass CalcVelocity < string Script = "Draw=Buffer;";>
    {
        ALPHABLENDENABLE = FALSE;
        ALPHATESTENABLE = FALSE;
        VertexShader = compile vs_3_0 Common_VS();
        PixelShader  = compile ps_3_0 Velocity_PS();
    }
    pass PotentialInit < string Script = "Draw=Buffer;";>
    {
        ALPHABLENDENABLE = FALSE;
        ALPHATESTENABLE = FALSE;
        VertexShader = compile vs_1_1 Common_VS();
        PixelShader  = compile ps_2_0 PotentialInit_PS();
    }
    pass PosCopy < string Script = "Draw=Buffer;";>
    {
        ALPHABLENDENABLE = FALSE;
        ALPHATESTENABLE = FALSE;
        VertexShader = compile vs_1_1 Common_VS();
        PixelShader  = compile ps_2_0 PosCopy_PS();
    }
    pass PosUpdate < string Script = "Draw=Buffer;";>
    {
        ALPHABLENDENABLE = FALSE;
        ALPHATESTENABLE = FALSE;
        VertexShader = compile vs_3_0 Common_VS();
        PixelShader  = compile ps_3_0 PosButterfly_PS();
    }
    pass CalcPotential < string Script = "Draw=Buffer;";>
    {
        ALPHABLENDENABLE = FALSE;
        ALPHATESTENABLE = FALSE;
        VertexShader = compile vs_3_0 Common_VS();
        PixelShader  = compile ps_3_0 Potential_PS();
    }
    pass DrawObject {
        ZENABLE = TRUE;
        #if(WriteZBuffer == 0)
        ZWRITEENABLE = FALSE;
        #endif
        AlphaBlendEnable = TRUE;
        #if(TEX_ADD_FLG == 1)
        DestBlend = ONE;
        SrcBlend = ONE;
        #else
        DestBlend = INVSRCALPHA;
        SrcBlend = SRCALPHA;
        #endif
        CullMode = NONE;
        VertexShader = compile vs_3_0 ParticleSS_VS();
        PixelShader  = compile ps_3_0 ParticleSS_PS();
   }
}

///////////////////////////////////////////////////////////////////////////////////////////////
// ��Z���t�V���h�E�n�ʉe�͔�\��
technique ShadowTec < string MMDPass = "shadow"; > { }

