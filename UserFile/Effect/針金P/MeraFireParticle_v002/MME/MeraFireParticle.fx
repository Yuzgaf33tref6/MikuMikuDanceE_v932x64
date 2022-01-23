////////////////////////////////////////////////////////////////////////////////////////////////
//
//  MeraFireParticle.fx ver0.0.2 �����������̂��闱�q�n���G�t�F�N�g
//  �쐬: �j��P
//
////////////////////////////////////////////////////////////////////////////////////////////////
// �����̃p�����[�^��ύX���Ă�������

float ParticleSize = 0.15;       // ���q�傫��
float ParticleSpeedMax = 3.0;    // ���q�����ő�l
float ParticleSpeedMin = 2.0;    // ���q�����ŏ��l
float ParticleInitPos = 0.5;     // ���q�������̈ʒu(�傫������Ɨ��q�̔z�u���΂���܂�)
float ParticleLife = 1.0;        // ���q�̎���(�b)
float ParticleDecrement = 0.2;   // ���q���������J�n���鎞��(0.0�`1.0:ParticleLife�Ƃ̔�)
float ParticleOccur = 1.0;       // ���q�����x(�傫������Ɨ��q���o�₷���Ȃ�)
float DiffusionAngle = 30.0;     // ���ˊg�U�p(0.0�`180.0)
float SpeedDampCoef = 2.0;       // ���ˑ��x�̌����W��
float SpeedFixCoef = 0.3;        // ���ˑ��x�̌Œ�W��

#define FireSourceTexFile  "FireSource.png" // ���̎�ƂȂ�e�N�X�`���t�@�C����
#define FireColorTexFile   "palette1.png" // ���Fpallet�e�N�X�`���t�@�C����

//���������������߂�p�����[�^,������M��Ό����ڂ����\����B
float fireDisFactor = 0.02f; 
float fireSizeFactor = 3.0f;
float fireShakeFactor = 0.3f;

float fireRiseFactor = 4.0;    // ���̏㏸�x
float fireWvAmpFactor = 1.0;   // ���̍��E�̗h�炬�U��
float fireWvFreqFactor = 0.3;  // ���̍��E�̗h�炬���g��

#define RISE_DIREC  1  // ���̏㏸������ 0:�A�N�Z�T�������, 1:������Œ�
#define ADD_FLG     1  // 0:����������, 1:���Z����


// ����Ȃ��l�͂������牺�͂�����Ȃ��ł�

////////////////////////////////////////////////////////////////////////////////////////////////
// �p�����[�^�錾
#define ArrangeFileName "Arrange.pfm" // �z�u��������t�@�C����
#define TEX_WIDTH_A   4   // �z�u��������e�N�X�`���s�N�Z����
#define TEX_WIDTH     1   // ���W���e�N�X�`���s�N�Z����
#define TEX_HEIGHT 1024   // �z�u��������e�N�X�`���s�N�Z������

// ��ƃ��C���T�C�Y
#define TEX_WORK_WIDTH  256
#define TEX_WORK_HEIGHT 512

#define PAI 3.14159265f   // ��

float AcsTr  : CONTROLOBJECT < string name = "(self)"; string item = "Tr"; >;
float AcsSi  : CONTROLOBJECT < string name = "(self)"; string item = "Si"; >;

static float diffD = radians( clamp(90.0f - DiffusionAngle, -90.0f, 90.0f) );

float time : TIME;
float elapsed_time : ELAPSEDTIME;
static float Dt = clamp(elapsed_time, 0.001f, 0.1f);

static float P_Count = ParticleOccur * (Dt / ParticleLife) * 10.0f; // 1�t���[��������̗��q������
static float fireShake = fireShakeFactor / (Dt * 60.0f);

// ���W�ϊ��s��
float4x4 WorldMatrix          : WORLD;
float4x4 WorldViewMatrix      : WORLDVIEW;
float4x4 ViewProjMatrix       : VIEWPROJECTION;
float4x4 WorldViewProjMatrix  : WORLDVIEWPROJECTION;
float4x4 ViewMatrixInverse    : VIEWINVERSE;

static float3x3 BillboardMatrix = {
    normalize(ViewMatrixInverse[0].xyz),
    normalize(ViewMatrixInverse[1].xyz),
    normalize(ViewMatrixInverse[2].xyz),
};

// �J����Z����]�s��
float2 ViewportSize : VIEWPORTPIXELSIZE;
static float4 WPos = float4(WorldMatrix._41_42_43, 1);
static float4 pos0 = mul( WPos, ViewProjMatrix);
#if RISE_DIREC==0
    static float4 posY = mul( float4(WPos.xyz + WorldMatrix._21_22_23, 1), ViewProjMatrix);
#else
    static float4 posY = mul( float4(WPos.x, WPos.y+1, WPos.z, 1), ViewProjMatrix);
#endif
static float2 rotVec0 = posY.xy/posY.w - pos0.xy/pos0.w;
static float2 rotVec = normalize( float2(rotVec0.x*ViewportSize.x/ViewportSize.y, rotVec0.y) );
static float3x3 RotMatrix = float3x3( rotVec.y, -rotVec.x, 0,
                                      rotVec.x,  rotVec.y, 0,
                                             0,         0, 1 );
static float3x3 BillboardZRotMatrix = mul( RotMatrix, BillboardMatrix);

// �㉺�J�����A���O���ɂ��k��(�K��)
float3 CameraDirection : DIRECTION < string Object = "Camera"; >;
#if RISE_DIREC==0
    static float absCosD = abs( dot(normalize(WorldMatrix._21_22_23), -CameraDirection) );
#else
    static float absCosD = abs( dot(float3(0,1,0), -CameraDirection) );
#endif
static float yScale = 1.0 - 0.7*smoothstep(0.5, 1.0, absCosD);

// ���̎�ƂȂ�e�N�X�`��
texture2D ParticleTex <
    string ResourceName = FireSourceTexFile;
>;
sampler ParticleSamp = sampler_state {
    texture = <ParticleTex>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = NONE;
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

// �m�C�Y�e�N�X�`��
texture2D NoiseOne <
    string ResourceName = "NoiseFreq1.png"; 
    int Miplevels = 1;
>;
sampler2D NoiseOneSamp = sampler_state {
    texture = <NoiseOne>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = NONE;
    AddressU  = WRAP;
    AddressV = WRAP;
};
texture2D NoiseTwo <
    string ResourceName = "NoiseFreq2.png"; 
    int Miplevels = 1;
>;
sampler2D NoiseTwoSamp = sampler_state {
    texture = <NoiseTwo>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = NONE;
    AddressU  = WRAP;
    AddressV = WRAP;
};

// ���A�j���[�V������ƃ��C��
texture2D WorkLayer : RENDERCOLORTARGET <
    int Width = TEX_WORK_WIDTH;
    int Height = TEX_WORK_HEIGHT;
    int Miplevels = 1;
    string Format = "A8R8G8B8" ;
>;
sampler2D WorkLayerSamp = sampler_state {
    texture = <WorkLayer>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = NONE;
    AddressU  = CLAMP;
    AddressV = CLAMP;
};
texture WorkLayerDepthBuffer : RenderDepthStencilTarget <
   int Width=TEX_WORK_WIDTH;
   int Height=TEX_WORK_HEIGHT;
    string Format = "D24S8";
>;

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
      WPos.xyz *= ParticleInitPos * AcsSi * 0.01f;
      #if RISE_DIREC==0
          WPos = mul( WPos, WorldMatrix );
      #else
          WPos.xyz = WPos.xyz * length(WorldMatrix._11_12_13) + WorldMatrix._41_42_43;
      #endif
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
      float speedRate = (exp(-SpeedDampCoef*(Pos.w-1.0f) ) + SpeedFixCoef) /
                        (exp(-SpeedDampCoef*(Pos.w-1.0f-Dt)) + SpeedFixCoef);
      Vel.xyz *= float3(speedRate, pow(speedRate, 0.3), speedRate);
   }

   // ���������q�̋N�_
   Vel.w += p_count;
   if(Vel.w >= float(TEX_WIDTH*TEX_HEIGHT)) Vel.w -= float(TEX_WIDTH*TEX_HEIGHT);
   if(time < 0.001f) Vel.w = 0.0f;

   return Vel;
}

///////////////////////////////////////////////////////////////////////////////////////
// ���A�j���[�V�����̕`��

// ���_�V�F�[�_
VS_OUTPUT VS_FireAnimation( float4 Pos : POSITION, float4 Tex : TEXCOORD0 )
{
    VS_OUTPUT Out;
    
    Out.Pos = Pos;
    Out.texCoord = Tex + float2(0.5f/TEX_WORK_WIDTH, 0.5f/TEX_WORK_HEIGHT);
    
    return Out;
}

// �s�N�Z���V�F�[�_
float4 PS_FireAnimation(float2 Tex: TEXCOORD0, uniform bool flag) : COLOR0
{
    float2 oldTex = Tex;
    // ��ɉ������炷 ���Q�ƈʒu�����ɂ��炷�ƊG�͏�ɂ����
    //oldTex.y += (0.5f/TEX_WORK_HEIGHT * fireRiseFactor);
    //oldTex.x += 0.5f/TEX_WORK_WIDTH * fireWvAmpFactor * (abs(frac(fireWvFreqFactor*time)*2.0f - 1.0f) - 0.5f);
    float2 moveVec = float2( 0.5f/TEX_WORK_WIDTH * fireWvAmpFactor * (abs(frac(fireWvFreqFactor*time)*2.0f - 1.0f) - 0.5f),
                      0.5f/TEX_WORK_HEIGHT * fireRiseFactor * yScale );
    oldTex += moveVec;

    float4 oldCol = tex2D(WorkLayerSamp, oldTex);
    
    float4 tmp = oldCol;
    if( flag ){
        // ��ƃ��C���ɔR�ĕ���`�� ���O��̉������炵����ɕ`�悷�鎖�ŔR�ĕ����̂́A�����ʒu�ɕ`��ł���B
        tmp = max(oldCol, tex2D(ParticleSamp, Tex));
    }
    
    // �m�C�Y�̒ǉ�
    float2 noiseTex;
    noiseTex = Tex;
    noiseTex.y += time * fireShake;
    tmp = saturate(tmp - fireDisFactor * tex2D(NoiseOneSamp, noiseTex * fireSizeFactor));
    
    noiseTex = Tex;
    noiseTex.x += time * fireShake;
    tmp = saturate(tmp - fireDisFactor * 0.5f * tex2D(NoiseTwoSamp, noiseTex * fireSizeFactor));
    
    return float4(tmp.rgb,1);
}


///////////////////////////////////////////////////////////////////////////////////////
// �p�[�e�B�N���`��
struct VS_OUTPUT2
{
    float4 Pos   : POSITION;    // �ˉe�ϊ����W
    float2 Tex   : TEXCOORD0;   // �e�N�X�`��
    float  Alpha : COLOR0;      // ���q�̓��ߓx
};

// ���_�V�F�[�_
VS_OUTPUT2 Particle_VS(float4 Pos : POSITION, float2 Tex : TEXCOORD0)
{
   VS_OUTPUT2 Out;

   int Index0 = round( Pos.z * 100.0f );
   Pos.x = 2.0f * (Tex.x - 0.5f);
   Pos.y = 4.0f * (0.5f - Tex.y);
   Pos.z = 0.0f;
   int i0 = Index0 / 1024;
   int i = i0 * 8;
   int j = Index0 % 1024;
   float2 texCoord = float2((i0+0.5)/TEX_WIDTH, (j+0.5)/TEX_HEIGHT);

   // ���q�̍��W
   float4 Pos0 = tex2Dlod(CoordSmp, float4(texCoord, 0, 1));

   // �o�ߎ���
   float etime = Pos0.w - 1.0f;

   // �o�ߎ��Ԃɑ΂��闱�q�g��x
   float scale = 4.0f * sqrt(etime) + 2.0f;
   scale *= 1.0f + 0.5f * (0.66f * sin(22.1f * Index0) + 0.33f * cos(33.6f * Index0));

   // ���q�̈ʒu�E�傫���␳
   Pos.y += 1.5f;
   Pos.xy *= ParticleSize * scale * AcsSi;

   // �r���{�[�h+z����]
   Pos.xyz = mul( Pos.xyz, BillboardZRotMatrix );

   // ���q�̃��[���h���W
   Pos.xyz += Pos0.xyz;
   Pos.xyz *= step(0.001f, etime);
   Pos.w = 1.0f;

   // �J�������_�̃r���[�ˉe�ϊ�
   Out.Pos = mul( Pos, ViewProjMatrix );

   // ���q�̏�Z�F
   Out.Alpha = step(0.001f, etime) * smoothstep(0.0f, min(0.5f, ParticleLife*ParticleDecrement), etime)
                                   * smoothstep(-ParticleLife, -ParticleLife*ParticleDecrement, -etime);

   // �e�N�X�`�����W
   Out.Tex = Tex;

   return Out;
}

// �s�N�Z���V�F�[�_
float4 Particle_PS( VS_OUTPUT2 IN ) : COLOR0
{
    float tmp = tex2D(WorkLayerSamp, IN.Tex).r;
    float4 FireCol = tex2D(FireColorSamp, saturate(float2(tmp, 0.5f)));

    #if ADD_FLG == 1
        FireCol.rgb *=  0.5f * IN.Alpha * AcsTr;
    #else
        FireCol.a *= tmp * IN.Alpha * AcsTr;
    #endif

    return FireCol;
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
       "RenderColorTarget0=WorkLayer;"
            "RenderDepthStencilTarget=WorkLayerDepthBuffer;"
            "Pass=FireAnimation;"
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
   pass FireAnimation < string Script= "Draw=Buffer;"; > {
       ZWriteEnable = FALSE;
       VertexShader = compile vs_2_0 VS_FireAnimation();
       PixelShader  = compile ps_2_0 PS_FireAnimation(true);
   }
   pass DrawObject {
        ZENABLE = TRUE;
        ZWriteEnable = FALSE;
        #if ADD_FLG == 1
          DestBlend = ONE;
          SrcBlend = ONE;
        #else
          DestBlend = INVSRCALPHA;
          SrcBlend = SRCALPHA;
        #endif
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
       "RenderColorTarget0=WorkLayer;"
            "RenderDepthStencilTarget=WorkLayerDepthBuffer;"
            "Pass=FireAnimation;"
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
   pass FireAnimation < string Script= "Draw=Buffer;"; > {
       ZWriteEnable = FALSE;
       VertexShader = compile vs_2_0 VS_FireAnimation();
       PixelShader  = compile ps_2_0 PS_FireAnimation(false);
   }
   pass DrawObject {
        ZENABLE = TRUE;
        ZWriteEnable = FALSE;
        #if ADD_FLG == 1
          DestBlend = ONE;
          SrcBlend = ONE;
        #else
          DestBlend = INVSRCALPHA;
          SrcBlend = SRCALPHA;
        #endif
       VertexShader = compile vs_3_0 Particle_VS();
       PixelShader  = compile ps_3_0 Particle_PS();
   }
}



///////////////////////////////////////////////////////////////////////////////////////////////
// �n�ʉe�͕\�����Ȃ�
technique ShadowTec < string MMDPass = "shadow"; > { }
// MMD�W���̃Z���t�V���h�E�͕\�����Ȃ�
technique ZplotTec < string MMDPass = "zplot"; > { }

