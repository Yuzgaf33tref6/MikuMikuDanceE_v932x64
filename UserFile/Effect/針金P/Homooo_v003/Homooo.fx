////////////////////////////////////////////////////////////////////////////////////////////////
//
//  Homooo.fx ver0.0.3 ���i���Oo�O�j���z���H���
//  �쐬: �j��P
//
////////////////////////////////////////////////////////////////////////////////////////////////
// �����̃p�����[�^��ύX���Ă�������
#define TexFile  "Homooo.png" // �{�[�h�\��t����e�N�X�`���t�@�C����
float HomoooAppear = 10.0;       // ���i���Oo�O�j���z���H����̏o���x(�傫������Ƃ����ς����i���Oo�O�j���z���H������Č�����)
float HomoooSize = 1.0;          // ���i���Oo�O�j���z���H����̑傫��
float HomoooSpeedMin = 40.0;     // ���i���Oo�O�j���z���H����̏����ŏ��l
float HomoooSpeedMax = 120.0;    // ���i���Oo�O�j���z���H����̏����ő�l
float HomoooInitPos = 1.0;       // ���i���Oo�O�j���z���H����̔������̈ʒu(�傫������Ɣz�u���΂���܂�)
float HomoooLife = 0.8;          // ���i���Oo�O�j���z���H����̎���(�b)
float HomoooDecrement = 0.2;     // ���i���Oo�O�j���z���H������������J�n���鎞��(0.0�`1.0:HomoooLife�Ƃ̔�)
float DiffusionAngle = 30.0;     // ���ˊg�U�p(0.0�`180.0)
float SpeedDampCoef = 10.0;      // ���ˑ��x�̌����W��
float SpeedFixCoef = 0.1;        // ���ˑ��x�̌Œ�W��
float3 HomoooColor = {1.0, 1.0, 1.0}; // �e�N�X�`���̏�Z�F(RBG)


// ����Ȃ��l�͂������牺�͂�����Ȃ��ł�

////////////////////////////////////////////////////////////////////////////////////////////////
// �p�����[�^�錾

#define ArrangeFileName "Arrange.png" // �z�u��������t�@�C����
#define TEX_WIDTH_A  8   // �z�u��������e�N�X�`���s�N�Z����
#define TEX_WIDTH    1   // ���W���e�N�X�`���s�N�Z����
#define TEX_HEIGHT  64   // �z�u��������e�N�X�`���s�N�Z������

#define PAI 3.14159265f   // ��

float AcsTr  : CONTROLOBJECT < string name = "(self)"; string item = "Tr"; >;
float AcsSi  : CONTROLOBJECT < string name = "(self)"; string item = "Si"; >;
static float Scale = AcsSi * 0.05f;

static float diffD = radians( clamp(90.0f - DiffusionAngle, -90.0f, 90.0f) );

// ���W�ϊ��s��
float4x4 WorldMatrix        : WORLD;
float4x4 ViewMatrix         : VIEW;
float4x4 ProjMatrix         : PROJECTION;
float4x4 ViewProjMatrix     : VIEWPROJECTION;
float4x4 ViewMatrixInverse  : VIEWINVERSE;

static float3x3 BillboardMatrix = {
    normalize(ViewMatrixInverse[0].xyz),
    normalize(ViewMatrixInverse[1].xyz),
    normalize(ViewMatrixInverse[2].xyz),
};

//�J�����ʒu
float3 CameraPosition  : POSITION  < string Object = "Camera"; >;

texture2D HomoooTex <
    string ResourceName = TexFile;
>;
sampler HomoooSamp = sampler_state {
    texture = <HomoooTex>;
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

// ���i���Oo�O�j���z���H������W�L�^�p
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

// ���i���Oo�O�j���z���H������x�L�^�p
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
// ���ԊԊu�v�Z(MMM�ł� ELAPSEDTIME �̓I�t�X�N���[���̗L���ő傫���ς��̂Ŏg��Ȃ�)

float time : Time;

#ifndef MIKUMIKUMOVING

float elapsed_time : ELAPSEDTIME;
static float Dt = clamp(elapsed_time, 0.001f, 0.1f);

#else

// �X�V�����L�^�p
texture TimeTex : RENDERCOLORTARGET
<
   int Width=1;
   int Height=1;
   string Format = "D3DFMT_R32F" ;
>;
sampler TimeTexSmp = sampler_state
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
static float Dt = clamp(time - tex2D(TimeTexSmp, float2(0.5f,0.5f)).r, 0.001f, 0.1f);


float4 UpdateTime_VS(float4 Pos : POSITION) : POSITION
{
    return Pos;
}

float4 UpdateTime_PS() : COLOR
{
   return float4(time, 0, 0, 1);
}

#endif

static float probable = 0.5f * (Dt / HomoooLife) * HomoooAppear * 0.004f; // 1�t���[��������̄��i���Oo�O�j���z���H��������m��


////////////////////////////////////////////////////////////////////////////////////////////////
// �z�u��������e�N�X�`������f�[�^�����o��
float Color2Float(int i, int j)
{
    float4 d = tex2D(ArrangeSmp, float2((i+0.5)/TEX_WIDTH_A, (j+0.5)/TEX_HEIGHT));
    float tNum = (65536.0f * d.x + 256.0f * d.y + d.z) * 255.0f;
    int pNum = round(d.w * 255.0f);
    int sgn = 1 - 2 * (pNum % 2);
    float data = tNum * pow(10.0f, pNum/2 - 64) * sgn;
    return data;
}

////////////////////////////////////////////////////////////////////////////////////////////////
// �N�H�[�^�j�I���̐ώZ
float4 MulQuat(float4 q1, float4 q2)
{
   return float4(cross(q1.xyz, q2.xyz)+q1.xyz*q2.w+q2.xyz*q1.w, q1.w*q2.w-dot(q1.xyz, q2.xyz));
}

// �N�H�[�^�j�I���̉�]
float3 RotQuat(float3 v1, float3 v2, float3 pos)
{
   v1 = normalize( v1 );
   v2 = normalize( v2 );

   float4 q =  float4(pos, 0.0f);

   if(length(v1-v2) > 0.01f){
      float3 v = normalize( cross(v2, v1) );
      float rot = acos( dot(v1, v2) );
      float sinHD = sin(0.5f * rot);
      float cosHD = cos(0.5f * rot);
      float4 q1 = float4(v*sinHD, cosHD);
      float4 q2 = float4(-v*sinHD, cosHD);
      q = MulQuat( MulQuat(q2, q), q1);
   }

   return q.xyz;
}

////////////////////////////////////////////////////////////////////////////////////////////////

struct VS_OUTPUT {
   float4 Pos      : POSITION;
   float2 texCoord : TEXCOORD0;
};

// ���ʂ̒��_�V�F�[�_
VS_OUTPUT Common_VS(float4 Pos: POSITION, float2 Tex: TEXCOORD) {
   VS_OUTPUT Out;
   Out.Pos = Pos;
   Out.texCoord = Tex + float2(0.5f/TEX_WIDTH, 0.5f/TEX_HEIGHT);
   return Out;
}

// ���i���Oo�O�j���z���H����̔����E���W�v�Z(xyz:���W,w:�o�ߎ���)
float4 UpdatePos_PS(float2 texCoord: TEXCOORD0) : COLOR
{
   // ���i���Oo�O�j���z���H����̍��W
   float4 Pos = tex2D(CoordSmp, texCoord);

   // ���i���Oo�O�j���z���H����̑��x
   float4 Vel = tex2D(VelocitySmp, texCoord);

   if(time < 0.001f) Pos.w = 0.0f;
   if(Pos.w < 0.001f){
      // ���������i���Oo�O�j���z���H����̒�����V���ɔ���������
      int i = floor( texCoord.x*TEX_WIDTH ) * 8;
      int j = floor( texCoord.y*TEX_HEIGHT );
      float4 WPos = float4(Color2Float(i, j), Color2Float(i+1, j), 0.0f, 1.0f);
      WPos.xyz *= HomoooInitPos/AcsSi;
      WPos = mul( WPos, WorldMatrix );
      Pos.xyz = WPos.xyz / WPos.w;  // �����������W
      float probable0 = Color2Float(i+7, j);
      if(Vel.w<=probable0 && probable0<Vel.w+probable){
         Pos.w = 1.0011f;  // Pos.w>1.001�ń��i���Oo�O�j���z���H�������
      }
   }else{
      // ���i���Oo�O�j���z���H����̍��W�X�V
      Pos.xyz += Vel.xyz * Dt;

      // ���łɔ������Ă��鄡�i���Oo�O�j���z���H����͌o�ߎ��Ԃ�i�߂�
      Pos.w += Dt;
      Pos.w *= step(Pos.w-1.0f, HomoooLife); // �w�莞�Ԃ𒴂����0
   }

   return Pos;
}

// ���i���Oo�O�j���z���H����̑��x�v�Z(xyz:���x,w:�o���N�_)
float4 UpdateVelocity_PS(float2 texCoord: TEXCOORD0) : COLOR
{
   // ���i���Oo�O�j���z���H����̍��W
   float4 Pos = tex2D(CoordSmp, texCoord);

   // ���i���Oo�O�j���z���H����̑��x
   float4 Vel = tex2D(VelocitySmp, texCoord);

   if(Pos.w < 1.00111f){
      // ���������Ă̄��i���Oo�O�j���z���H����ɏ����x�^����
      int i = floor( texCoord.x*TEX_WIDTH ) * 8;
      int j = floor( texCoord.y*TEX_HEIGHT );
      float time1 = time + 100.0f;
      float ss, cs;
      sincos( lerp(diffD, PAI*0.5f, frac(Color2Float(i+3, j)*time1)), ss, cs );
      float st, ct;
      sincos( lerp(-PAI, PAI, frac(Color2Float(i+4, j)*time1)), st, ct );
      float3 vec  = float3( cs*ct, ss, cs*st );
      float rand = Color2Float(i+5, j);
      float speed = lerp(HomoooSpeedMin, HomoooSpeedMax, 1.0f-rand*rand);
      vec = RotQuat(float3(0,1,0), float3(0,1,-1), vec);
      Vel.xyz = normalize( mul( vec, (float3x3)WorldMatrix ) ) * speed;
   }else{
      // ���łɔ������Ă��鄡�i���Oo�O�j���z���H����̑��x������������
      Vel.xyz *= (exp(-SpeedDampCoef*(Pos.w-1.0f) ) + SpeedFixCoef) /
                 (exp(-SpeedDampCoef*(Pos.w-1.0f-Dt)) + SpeedFixCoef);
   }

   // �������o���̋N�_
   Vel.w += probable;
   Vel.w *= step(Vel.w, 1.0f-probable);
   if(time < 0.001f) Vel.w = 0.0f;

   return Vel;
}

///////////////////////////////////////////////////////////////////////////////////////
// ���i���Oo�O�j���z���H����̕`��
struct VS_OUTPUT2
{
    float4 Pos   : POSITION;    // �ˉe�ϊ����W
    float2 Tex   : TEXCOORD0;   // �e�N�X�`��
    float4 Color : COLOR0;      // �{�[�h�̏�Z�F
};

// ���_�V�F�[�_
VS_OUTPUT2 Homooo_VS(float4 Pos : POSITION, float2 Tex : TEXCOORD0)
{
   VS_OUTPUT2 Out;

   int Index0 = round( Pos.z * 100.0f );
   Pos.z = 0.0f;
   int i0 = Index0 / 1024;
   int i = i0 * 8;
   int j = Index0 % 1024;
   float2 texCoord = float2((i0+0.5)/TEX_WIDTH, (j+0.5)/TEX_HEIGHT);

   // ���i���Oo�O�j���z���H����̍��W
   float4 Pos0 = tex2Dlod(CoordSmp, float4(texCoord, 0, 0));

   // ���i���Oo�O�j���z���H����o�ߎ���
   float etime = Pos0.w - 1.0f;

   // �����ݒ�
   float rand0 = 0.5f * (0.66f * sin(22.1f * Index0) + 0.33f * cos(33.6f * Index0) + 1.0f);
   float rand1 = 0.5f * (0.31f * sin(45.3f * Index0) + 0.69f * cos(73.4f * Index0) + 1.0f);

   // �o�ߎ��Ԃɑ΂��鄡�i���Oo�O�j���z���H����g��x
   float scale = 4.0f * sqrt(etime) + 2.0f;

   // ���i���Oo�O�j���z���H����̑傫��
   Pos.xy *= (0.5f + rand0) * HomoooSize * scale * 10.0f;
   Pos.y *= 0.5f;
   Pos.xy *= Scale * 0.2f;

   // ���i���Oo�O�j���z���H����̉�]
   float rot = 6.18f * ( rand1 - 0.5f );

   // �r���{�[�h
   Pos.xyz = mul( Pos.xyz, BillboardMatrix );

   // ���i���Oo�O�j���z���H����̃��[���h���W
   Pos.xyz += (Pos0.xyz - WorldMatrix._41_42_43) * Scale + WorldMatrix._41_42_43;
   Pos.xyz *= step(0.001f, etime);
   Pos.w = 1.0f;

#ifndef MIKUMIKUMOVING
   // ���i���Oo�O�j���z���H����̃J�������_�̃r���[�ˉe�ϊ�
   Out.Pos = mul( Pos, ViewProjMatrix );
#else
   // ���i���Oo�O�j���z���H����̒��_���W
   if (MMM_IsDinamicProjection)
   {
       float4x4 vpmat = mul( ViewMatrix, MMM_DynamicFov(ProjMatrix, length( CameraPosition - Pos.xyz )) );
       Out.Pos = mul( Pos, vpmat );
   }
   else
   {
       Out.Pos = mul( Pos, ViewProjMatrix );
   }
#endif

   // ���i���Oo�O�j���z���H����̏�Z�F
   float alpha = step(0.002f, etime) * smoothstep(-HomoooLife, -HomoooLife*HomoooDecrement, -etime) * AcsTr;
   Out.Color = float4(HomoooColor, alpha);

   // �e�N�X�`�����W
   Out.Tex = Tex;

   return Out;
}

// �s�N�Z���V�F�[�_
float4 Homooo_PS( VS_OUTPUT2 IN ) : COLOR0
{
   float4 Color = tex2D( HomoooSamp, IN.Tex );
   Color *= IN.Color;
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
       #ifdef MIKUMIKUMOVING
       "RenderColorTarget0=TimeTex;"
           "RenderDepthStencilTarget=TimeDepthBuffer;"
           "Pass=UpdateTime;"
       #endif
       "RenderColorTarget0=;"
	    "RenderDepthStencilTarget=;"
           "Pass=DrawObject;";
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
       ZENABLE = false;
       AlphaBlendEnable = TRUE;
       VertexShader = compile vs_3_0 Homooo_VS();
       PixelShader  = compile ps_3_0 Homooo_PS();
   }
}

