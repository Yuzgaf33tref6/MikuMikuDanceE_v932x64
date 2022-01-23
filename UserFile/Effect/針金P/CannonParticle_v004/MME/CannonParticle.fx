////////////////////////////////////////////////////////////////////////////////////////////////
//
//  CannonParticle.fx ver0.0.4 �ł��o�����p�[�e�B�N���G�t�F�N�g
//  �쐬: �j��P
//
////////////////////////////////////////////////////////////////////////////////////////////////
// �����̃p�����[�^��ύX���Ă�������

// ���q���ݒ�
#define UNIT_COUNT   2   // �����̐��~1024 ����x�ɕ`��o���闱�q�̐��ɂȂ�(�����l�Ŏw�肷�邱��)

#define MMD_LIGHT   1    // MMD�̏Ɩ��F�� 0:�A�����Ȃ�, 1:�A������

#define TEX_FileName  "sample.png"  // ���q�ɓ\��t����e�N�X�`���t�@�C����
#define TEX_PARTICLE_XNUM   1       // ���q�e�N�X�`����x�������q��
#define TEX_PARTICLE_YNUM   1       // ���q�e�N�X�`����y�������q��
#define TEX_USE_MIPMAP      0       // �e�N�X�`���̃~�b�v�}�b�v����,0:���Ȃ�,1:����
#define TEX_ZBuffWrite      1       // Z�o�b�t�@�̏������� 0:���Ȃ�, 1:���� (�e�N�X�`���Ƀ����߂�����ꍇ��0�ɂ���)

#define USE_SPHERE       1          // �X�t�B�A�}�b�v�� 0:�g��, 1:�g��Ȃ�
#define SPHERE_SATURATE  1          // �X�t�B�A�}�b�v�K�p��� 0:���̂܂�, 1:�F�͈͂�0�`1�ɐ��� ��������0����AutoLuminous�Ŕ�������
#define SPHERE_FileName  "sphere_sample.png" // ���q�ɓ\��t����X�t�B�A�}�b�v�e�N�X�`���t�@�C����

// ���q�p�����[�^�ݒ�
float3 ParticleColor = {1.0, 1.0, 1.0}; // �e�N�X�`���̏�Z�F(RBG)
float ParticleRandamColor = 0.8;   // ���q�F�̂΂���x(0.0�`1.0)
float ParticleSize = 0.2;          // ���q�傫��
float ParticleSpeedMin = 150.0;    // ���q�����x�ŏ��l
float ParticleSpeedMax = 200.0;    // ���q�����x�ő�l
float ParticleRotSpeed = 4.0;      // ���q�̉�]�X�s�[�h
float ParticleInitPos = 1.0;       // ���q�������̕��U�ʒu(�傫������Ɨ��q�̏����z�u���L���Ȃ�܂�)
float ParticleLife = 8.0;          // ���q�̎���(�b)
float ParticleDecrement = 0.9;     // ���q���������J�n���鎞��(0.0�`1.0:ParticleLife�Ƃ̔�)
float ParticleOccur = 1.0;         // ���q�����x(�傫������Ɨ��q���o�₷���Ȃ�)
float DiffusionAngle = 10.0;       // ���ˊg�U�p(0.0�`180.0)
float FloorFadeMax = 5.0;          // �t�F�[�h�A�E�g�J�n����
float FloorFadeMin = 0.0;          // �t�F�[�h�A�E�g�I������

// �����p�����[�^�ݒ�
float3 GravFactor = {0.0, -20.0, 0.0};   // �d�͒萔
float ResistFactor = 5.0;          // ���x��R��
float RotResistFactor = 8.0;       // ��]��R��(�傫������Ƃ���犴�������܂�)

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

float AcsTr  : CONTROLOBJECT < string name = "(self)"; string item = "Tr"; >;
float AcsSi  : CONTROLOBJECT < string name = "(self)"; string item = "Si"; >;

int RepertCount = UNIT_COUNT;  // �V�F�[�_���`�攽����
int RepertIndex;               // �������f���J�E���^

static float diffD = radians( clamp(90.0f - DiffusionAngle, -90.0f, 90.0f) );

// ���Ԑ���R���g���[���p�����[�^
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
float3 LtColor : AMBIENT < string Object = "Light"; >;
static float3 LightColor = saturate( (LtColor + float3(0.3f, 0.3f, 0.3f)) * 0.833f + float3(0.5f, 0.5f, 0.5f) );
static float3 ResColor = ParticleColor * LightColor;
#else
float3 LightColor = float3(1, 1, 1);
static float3 ResColor = ParticleColor;
#endif

// 1�t���[��������̗��q������
static float P_Count = ParticleOccur * (Dt / ParticleLife) * AcsSi*100;

// ���W�ϊ��s��
float4x4 WorldMatrix    : WORLD;
float4x4 ViewMatrix     : VIEW;
float4x4 ViewProjMatrix : VIEWPROJECTION;

#if(TEX_USE_MIPMAP == 1)
// �I�u�W�F�N�g�ɓ\��t����e�N�X�`��(�~�b�v�}�b�v������)
    texture2D ParticleTex <
        string ResourceName = TEX_FileName;
        int MipLevels = 0;
    >;
    sampler ParticleTexSamp = sampler_state {
        texture = <ParticleTex>;
        MinFilter = ANISOTROPIC;
        MagFilter = ANISOTROPIC;
        MipFilter = LINEAR;
        MaxAnisotropy = 16;
        AddressU  = CLAMP;
        AddressV  = CLAMP;
    };

    #if(USE_SPHERE == 1)
    texture2D ParticleSphere <
        string ResourceName = SPHERE_FileName;
        int MipLevels = 0;
    >;
    sampler ParticleSphereSamp = sampler_state {
        texture = <ParticleSphere>;
        MinFilter = ANISOTROPIC;
        MagFilter = ANISOTROPIC;
        MipFilter = LINEAR;
        MaxAnisotropy = 16;
        AddressU  = CLAMP;
        AddressV  = CLAMP;
    };
    #endif

#else
// �I�u�W�F�N�g�ɓ\��t����e�N�X�`��(�~�b�v�}�b�v�����Ȃ�)
    texture2D ParticleTex <
        string ResourceName = TEX_FileName;
        int MipLevels = 1;
    >;
    sampler ParticleTexSamp = sampler_state {
        texture = <ParticleTex>;
        MinFilter = LINEAR;
        MagFilter = LINEAR;
        MipFilter = NONE;
        AddressU  = CLAMP;
        AddressV  = CLAMP;
    };

    #if(USE_SPHERE == 1)
    texture2D ParticleSphere <
        string ResourceName = SPHERE_FileName;
        int MipLevels = 1;
    >;
    sampler ParticleSphereSamp = sampler_state {
        texture = <ParticleSphere>;
        MinFilter = LINEAR;
        MagFilter = LINEAR;
        MipFilter = NONE;
        AddressU  = CLAMP;
        AddressV  = CLAMP;
    };
    #endif

#endif

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
// ���q�̉�]�s��
float3x3 RoundMatrix(int index, float etime)
{
   float rotX = ParticleRotSpeed * (1.0f + 0.3f*sin(247*index)) * etime + (float)index * 147.0f;
   float rotY = ParticleRotSpeed * (1.0f + 0.3f*sin(368*index)) * etime + (float)index * 258.0f;
   float rotZ = ParticleRotSpeed * (1.0f + 0.3f*sin(122*index)) * etime + (float)index * 369.0f;

   float sinx, cosx;
   float siny, cosy;
   float sinz, cosz;
   sincos(rotX, sinx, cosx);
   sincos(rotY, siny, cosy);
   sincos(rotZ, sinz, cosz);

   float3x3 rMat = { cosz*cosy+sinx*siny*sinz, cosx*sinz, -siny*cosz+sinx*cosy*sinz,
                    -cosy*sinz+sinx*siny*cosz, cosx*cosz,  siny*sinz+sinx*cosy*cosz,
                     cosx*siny,               -sinx,       cosx*cosy,               };

   return rMat;
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
      float3 WPos = Color2Float(j, 0);
      float3 WPos0 = WorldMatrix._41_42_43;
      WPos *= ParticleInitPos * 0.1f;
      WPos = mul( float4(WPos,1), WorldMatrix ).xyz;
      Pos.xyz = (WPos - WPos0) / AcsSi * 10.0f + WPos0;  // �����������W

      // �V���ɗ��q�𔭐������邩�ǂ����̔���
      if(p_index < Vel.w) p_index += float(TEX_WIDTH*TEX_HEIGHT);
      if(p_index < Vel.w+P_Count){
         Pos.w = 1.0011f;  // Pos.w>1.001�ŗ��q����
      }
   }else{
   // �������q�͋^�������v�Z�ō��W���X�V
      // ���q�̖@���x�N�g��
      float3 normal = mul( float3(0.0f,0.0f,1.0f), RoundMatrix(p_index, Pos.w) );

      // ��R�W���̐ݒ�
      float v = length( Vel.xyz );
      float cosa = dot( normalize(Vel.xyz), normal );
      float coefResist = lerp(ResistFactor, 0.0f, smoothstep(-0.3f*ParticleSpeedMax, -10.0f, -v));
      float coefRotResist = lerp(0.2f, RotResistFactor, smoothstep(-0.3f*ParticleSpeedMax, -10.0f, -v));

      // �����x�v�Z(���x��R��+��]��R��+�d��)
      float3 Accel = -Vel.xyz * coefResist - normal * v * cosa * coefRotResist + GravFactor;

      // �V�������W�ɍX�V
      Pos.xyz += Dt * (Vel.xyz + Dt * Accel);

      // ���łɔ������Ă��闱�q�͌o�ߎ��Ԃ�i�߂�
      Pos.w += Dt;
      Pos.w *= step(Pos.w-1.0f, ParticleLife); // �w�莞�Ԃ𒴂����0
   }

   // 0�t���[���Đ��ŗ��q������
   if(time < 0.001f) Pos = float4(WorldMatrix._41_42_43, 0.0f);

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

   int i = floor( Tex.x*TEX_WIDTH );
   int j = floor( Tex.y*TEX_HEIGHT );
   int p_index = j + i * TEX_HEIGHT;

   if(Pos.w < 1.00111f){
   // ���������Ă̗��q�ɏ����x�^����
      float3 rand = Color2Float(j, 2);
      float time1 = time + 100.0f;
      float ss, cs;
      sincos( lerp(diffD, PAI*0.5f, frac(rand.x*time1)), ss, cs );
      float st, ct;
      sincos( lerp(-PAI, PAI, frac(rand.y*time1)), st, ct );
      float3 vec  = float3( cs*ct, ss, cs*st );
      Vel.xyz = normalize( mul( vec, (float3x3)WorldMatrix ) )
                * lerp(ParticleSpeedMin, ParticleSpeedMax, frac(rand.z*time1));
   }else{
   // ���q�̑��x�v�Z
      // ���q�̖@���x�N�g��
      float3 normal = mul( float3(0.0f,0.0f,1.0f), RoundMatrix(p_index, Pos.w) );

      // ��R�W���̐ݒ�
      float v = length( Vel.xyz );
      float cosa = dot( normalize(Vel.xyz), normal );
      float coefResist = lerp(ResistFactor, 0.0f, smoothstep(-0.3f*ParticleSpeedMax, -10.0f, -v));
      float coefRotResist = lerp(0.2f, RotResistFactor, smoothstep(-0.3f*ParticleSpeedMax, -10.0f, -v));

      // �����x�v�Z(���x��R��+��]��R��+�d��)
      float3 Accel = -Vel.xyz * coefResist - normal * v * cosa * coefRotResist + GravFactor;

      // �V�������x�ɍX�V
      Vel.xyz += Dt * Accel;
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
    float4 Pos       : POSITION;    // �ˉe�ϊ����W
    float2 Tex       : TEXCOORD0;   // �e�N�X�`��
    float  TexIndex  : TEXCOORD1;   // �e�N�X�`�����q�C���f�N�X
    float2 SpTex     : TEXCOORD4;   // �X�t�B�A�}�b�v�e�N�X�`�����W
    float4 Color     : COLOR0;      // ���q�̏�Z�F
};

// ���_�V�F�[�_
VS_OUTPUT2 Particle_VS(float4 Pos : POSITION, float2 Tex : TEXCOORD0)
{
   VS_OUTPUT2 Out=(VS_OUTPUT2)0;

   int i = RepertIndex;
   int j = round( Pos.z * 100.0f );
   int Index0 = i * TEX_HEIGHT + j;
   float2 texCoord = float2((i+0.5f)/TEX_WIDTH, (j+0.5f)/TEX_HEIGHT);
   Pos.z = 0.0f;
   Out.TexIndex = float(j);

   // ���q�̍��W
   float4 Pos0 = tex2Dlod(CoordSmp, float4(texCoord, 0, 0));

   // �o�ߎ���
   float etime = Pos0.w - 1.0f;

   // ���q�̖@���x�N�g��
   float3 Normal = normalize(float3(0.0f, 0.0f, -0.2f) - Pos.xyz);

   // ���q�̑傫��
   Pos.xy *= ParticleSize * 10.0f;

   // ���q�̉�]
   Pos.xyz = mul( Pos.xyz, RoundMatrix(Index0, etime) );

   // ���q�̃��[���h���W
   Pos.xyz += Pos0.xyz;
   Pos.xyz *= step(0.001f, etime);
   Pos.w = 1.0f;

   // �J�������_�̃r���[�ˉe�ϊ�
   Out.Pos = mul( Pos, ViewProjMatrix );

   // ���q�̏�Z�F
   float alpha = step(0.001f, etime) * smoothstep(-ParticleLife, -ParticleLife*ParticleDecrement, -etime) * AcsTr;
   alpha *= smoothstep(FloorFadeMin, FloorFadeMax, Pos0.y);
   Out.Color = float4( ResColor, alpha );

   // �e�N�X�`�����W
   int texIndex = Index0 % (TEX_PARTICLE_XNUM * TEX_PARTICLE_YNUM);
   int tex_i = texIndex % TEX_PARTICLE_XNUM;
   int tex_j = texIndex / TEX_PARTICLE_XNUM;
   Out.Tex = float2((Tex.x + tex_i)/TEX_PARTICLE_XNUM, (Tex.y + tex_j)/TEX_PARTICLE_YNUM);

    #if( USE_SPHERE==1 )
       // �X�t�B�A�}�b�v�e�N�X�`�����W
       Normal = mul( Normal, RoundMatrix(Index0, etime) );
       float2 NormalWV = mul( Normal, (float3x3)ViewMatrix ).xy;
       Out.SpTex.x = NormalWV.x * 0.5f + 0.5f;
       Out.SpTex.y = NormalWV.y * -0.5f + 0.5f;
    #endif

   return Out;
}


// �s�N�Z���V�F�[�_
float4 Particle_PS( VS_OUTPUT2 IN ) : COLOR0
{
    // ���q�̐F
    float4 Color = IN.Color;
    Color *= tex2D( ParticleTexSamp, IN.Tex );

    // �����_���F�ݒ�
    float4 randColor = tex2D(ArrangeSmp, float2(3.5f/TEX_WIDTH_A, (IN.TexIndex+0.5f)/TEX_HEIGHT));
    Color.rgb *= lerp(float3(1.0f,1.0f,1.0f), randColor.rgb, ParticleRandamColor);

    #if( USE_SPHERE==1 )
        // �X�t�B�A�}�b�v�K�p
        Color.rgb += tex2D(ParticleSphereSamp, IN.SpTex).rgb * LightColor;
        #if( SPHERE_SATURATE==1 )
            Color = saturate( Color );
        #endif
    #endif

    #if( TEX_ZBuffWrite==1 )
        clip(Color.a - 0.5);
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
        #if TEX_ZBuffWrite==0
        ZWRITEENABLE = FALSE;
        #endif
        AlphaBlendEnable = TRUE;
        CullMode = NONE;
        VertexShader = compile vs_3_0 Particle_VS();
        PixelShader  = compile ps_3_0 Particle_PS();
    }
}

