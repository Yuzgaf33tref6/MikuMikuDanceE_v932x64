////////////////////////////////////////////////////////////////////////////////////////////////
//
//  Heaven_Back.fx ver0.0.2  �w�u���t�B���^�[�G�t�F�N�g(���f����ʔz�u)
//  �쐬: �j��P( ���͉��P����laughing_man.fx,FireParticleSystem.fx���� )
//
////////////////////////////////////////////////////////////////////////////////////////////////
// �����̃p�����[�^��ύX���Ă�������

float Xmin = -10.0;        // X�͈͍ŏ��l
float Xmax = 10.0;         // X�͈͍ő�l
float Ymin = -5.0;         // Y�͈͍ŏ��l
float Ymax = 25.0;         // Y�͈͍ő�l

int ParticleCount = 50;     // �����q�̕`��I�u�W�F�N�g��
float LightScale = 1.0;     // �����q�傫��
float LightSpeedMin = 1.0;  // �����q�ŏ��X�s�[�h
float LightSpeedMax = 2.0;  // �����q�ő�X�s�[�h
float LightCross = 2.0;     // �����q�̏\���x����

int SeedXY = 7;           // �z�u�Ɋւ��闐���V�[�h
int SeedSize = 3;         // �T�C�Y�Ɋւ��闐���V�[�h
int SeedSpeed = 13;       // �X�s�[�h�Ɋւ��闐���V�[�h
int SeedCross = 11;       // �\���x�����Ɋւ��闐���V�[�h


// �{�[���̓݉��Ǐ]�p�����[�^
bool flagMildFollow <        // �݉��Ǐ]on/off
   string UIName = "�݉��Ǐ]on/off";
   bool UIVisible =  true;
> = true;

float ElasticFactor = 50.0;  // �{�[���Ǐ]�̒e���x
float ResistFactor = 20.0;   // �{�[���Ǐ]�̒�R�x
float MaxDistance = 8.0;     // �{�[���Ǐ]�̍ő�Ԃꕝ


// ����Ȃ��l�͂������牺�͂�����Ȃ��ł�

////////////////////////////////////////////////////////////////////////////////////////////////
// �p�����[�^�錾

float AcsTr : CONTROLOBJECT < string name = "(self)"; string item = "Tr"; >;

int Index;

float time : Time;

// ���W�ϊ��s��
float4x4 WorldMatrix             : WORLD;
float4x4 ViewMatrix              : VIEW;
float4x4 ProjMatrix              : PROJECTION;
float4x4 ViewProjMatrix          : VIEWPROJECTION;
float4x4 WorldViewProjMatrix     : WORLDVIEWPROJECTION;
float4x4 WorldViewMatrixInverse  : WORLDVIEWINVERSE;

static float3x3 BillboardMatrix = {
    normalize(WorldViewMatrixInverse[0].xyz),
    normalize(WorldViewMatrixInverse[1].xyz),
    normalize(WorldViewMatrixInverse[2].xyz),
};

//�J�����ʒu
float3 CameraPosition  : POSITION  < string Object = "Camera"; >;


texture2D BackTex <
    string ResourceName = "HeavenBack.png";
>;
sampler BackSamp = sampler_state {
    texture = <BackTex>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = NONE;
    AddressU  = CLAMP;
    AddressV  = CLAMP;
};

texture2D FrameTex <
    string ResourceName = "HeavenFrame.png";
>;
sampler FrameSamp = sampler_state {
    texture = <FrameTex>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = NONE;
    AddressU  = CLAMP;
    AddressV  = CLAMP;
};

texture2D ParticleTex1 <
    string ResourceName = "Particle1.png";
>;
sampler ParticleSamp1 = sampler_state {
    texture = <ParticleTex1>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = NONE;
    AddressU  = CLAMP;
    AddressV  = CLAMP;
};

texture2D ParticleTex2 <
    string ResourceName = "Particle2.png";
>;
sampler ParticleSamp2 = sampler_state {
    texture = <ParticleTex2>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = NONE;
    AddressU  = CLAMP;
    AddressV  = CLAMP;
};

// �I�u�W�F�N�g�̍��W�E���x�L�^�p
texture CoordTex : RENDERCOLORTARGET
<
   int Width=2;
   int Height=1;
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
   int Width=2;
   int Height=1;
   string Format = "D24S8";
>;
float4 CoordTexArray[2] : TEXTUREVALUE <
   string TextureName = "CoordTex";
>;


////////////////////////////////////////////////////////////////////////////////////////////////
// �I�u�W�F�N�g�̍��W�E���x�v�Z

struct VS_OUTPUT
{
    float4 Pos : POSITION;    // �ϊ����W
    float2 Tex : TEXCOORD0;   // �e�N�X�`��
};

// ���ʂ̒��_�V�F�[�_
VS_OUTPUT Coord_VS(float4 Pos : POSITION, float2 Tex: TEXCOORD)
{
    VS_OUTPUT Out = (VS_OUTPUT)0; 

    Out.Pos = Pos;
    Out.Tex = Tex + float2(0.25f, 0.5f);

    return Out;
}

// 0�t���[���Đ��Ń��Z�b�g
float4 InitCoord_PS(float2 Tex: TEXCOORD0) : COLOR
{
   // �I�u�W�F�N�g�̍��W
   float4 Pos = tex2D(CoordSmp, Tex);
   if( time < 0.001f ){
      Pos = Tex.x<0.5f ? float4(WorldMatrix._41_42_43, 1.0f) : float4(0.0f, 0.0f, 0.0f, 1.0f);
   }
   return Pos;
}

// ���W�E���x�X�V
float4 Coord_PS(float2 Tex: TEXCOORD0) : COLOR
{
   // �I�u�W�F�N�g�̍��W
   float3 Pos0 = tex2D(CoordSmp, float2(0.25f, 0.5f)).xyz;

   // �I�u�W�F�N�g�̑��x
   float4 Vel = tex2D(CoordSmp, float2(0.75f, 0.5f));

   // ���[���h���W
   float3 WPos = WorldMatrix._41_42_43;

   // 1�t���[���̎��ԊԊu
   float Dt = clamp(time - Vel.w, 0.001f, 0.1f);

   // �����x�v�Z(�e����+���x��R��)
   float3 Accel = (WPos - Pos0) * ElasticFactor - Vel.xyz * ResistFactor;

   // �V�������W�ɍX�V
   float3 Pos1 = Pos0 + Dt * (Vel.xyz + Dt * Accel);

   // ���x�v�Z
   Vel.xyz = ( Pos1 - Pos0 ) / Dt;

   // �I�u�W�F�N�g�����[���h���W�����苗���ȏ㗣��Ȃ��悤�ɂ���
   if( length( WPos - Pos1 ) > MaxDistance ){
      Pos1 = WPos + normalize( Pos1 - WPos ) * MaxDistance;
   }

   // ���W�E���x�L�^
   float4 Pos = Tex.x<0.5f ? float4(Pos1, 1.0f) : float4(Vel.xyz, time);

   return Pos;
}


///////////////////////////////////////////////////////////////////////////////////////////////
//MMM�Ή�
#ifndef MIKUMIKUMOVING
    #define GET_VPMAT(p) (ViewProjMatrix)
#else
    #define GET_VPMAT(p) (MMM_IsDinamicProjection ? mul(ViewMatrix, MMM_DynamicFov(ProjMatrix, length(CameraPosition-p.xyz))) : ViewProjMatrix)
#endif

///////////////////////////////////////////////////////////////////////////////////////////////
// �w�i�`��

struct VS_OUTPUT1
{
    float4 Pos  : POSITION;    // �ˉe�ϊ����W
    float2 Tex  : TEXCOORD0;   // �e�N�X�`��
};

// ���_�V�F�[�_
VS_OUTPUT1 Back_VS(float4 Pos : POSITION, float2 Tex : TEXCOORD0)
{
    VS_OUTPUT1 Out;

    Pos.xy *= float2((Xmax-Xmin)/2.0f, (Ymax-Ymin)/2.0f);
    Pos.xy += float2((Xmax+Xmin)*0.5f, (Ymax+Ymin)*0.5f)*0.1f;

    // �r���{�[�h
    Pos.xyz = mul( Pos.xyz, BillboardMatrix );

    // ���[���h���W�ϊ�
    Pos.xyz = mul( Pos.xyz, (float3x3)WorldMatrix );
    if( flagMildFollow ){
       Pos.xyz += CoordTexArray[0].xyz;
    }else{
       Pos.xyz += WorldMatrix._41_42_43;
    }

    // �J�������_�̃r���[�ˉe�ϊ�
    Out.Pos = mul( Pos, GET_VPMAT(Pos) );

    // �e�N�X�`�����W
    Out.Tex = Tex;
 
    return Out;
}

// �s�N�Z���V�F�[�_
float4 Back_PS( float2 Tex :TEXCOORD0 ) : COLOR0
{
    float4 Color = tex2D( BackSamp, Tex );
    float4 Color1 = tex2D( FrameSamp, Tex );
    Color.a *= Color1.r*AcsTr*0.9f;
    return Color;
}

// �e�N�j�b�N
technique MainTec0 < string MMDPass = "object"; string Subset = "0";
    string Script = "RenderColorTarget0=CoordTex;"
                        "RenderDepthStencilTarget=CoordDepthBuffer;"
                        "Pass=PosInit;"
                        "Pass=PosUpdate;"
                    "RenderColorTarget0=;"
                        "RenderDepthStencilTarget=;"
                        "Pass=DrawObject;"
    ;
> {
    pass PosInit < string Script = "Draw=Buffer;";>
    {
        ALPHABLENDENABLE = FALSE;
        ALPHATESTENABLE=FALSE;
        VertexShader = compile vs_1_1 Coord_VS();
        PixelShader  = compile ps_2_0 InitCoord_PS();
    }
    pass PosUpdate < string Script = "Draw=Buffer;";>
    {
        ALPHABLENDENABLE = FALSE;
        ALPHATESTENABLE=FALSE;
        VertexShader = compile vs_1_1 Coord_VS();
        PixelShader  = compile ps_2_0 Coord_PS();
    }
    pass DrawObject {
        ZENABLE = false;
        VertexShader = compile vs_1_1 Back_VS();
        PixelShader  = compile ps_2_0 Back_PS();
    }
}


///////////////////////////////////////////////////////////////////////////////////////
// �p�[�e�B�N���`��

struct VS_OUTPUT2
{
    float4 Pos    : POSITION;    // �ˉe�ϊ����W
    float3 Tex    : TEXCOORD0;   // �e�N�X�`��
    float4 Color  : COLOR0;      // alpha�l
};

// ���_�V�F�[�_
VS_OUTPUT2 Particle_VS(float4 Pos : POSITION, float2 Tex : TEXCOORD0)
{
    VS_OUTPUT2 Out;

    // ������`
    float rand0 = abs(0.6f*sin(37 * SeedSize * Index + 13) + 0.4f*cos(71 * SeedSize * Index + 17));
    float rand1 = abs(0.4f*sin(53 * SeedSpeed * Index + 17) + 0.6f*cos(61 * SeedSpeed * Index + 19));
    float rand2 = abs(0.7f*sin(124 * SeedXY * Index + 19) + 0.3f*cos(235 * SeedXY * Index + 23));
    float rand3 = abs(0.6f*sin(83 * SeedXY * Index + 23) + 0.4f*cos(91 * SeedXY * Index + 29));
    float rand4 = (sin(47 * SeedCross * Index + 29) + cos(81 * SeedCross * Index + 31) + 3.0f) * 0.1f;

    // �p�[�e�B�N���T�C�Y
    float scale = 0.5f + rand0;
    Pos.xy *= scale*LightScale;

    // �p�[�e�B�N���z�u
    float speed = lerp(LightSpeedMin, LightSpeedMax, rand1);
    Pos.x += lerp(Xmin, Xmax, rand2) * 0.1f;
    float y = lerp(Ymin, Ymax, rand3);
    Pos.y += ((y+speed*time-Ymin)%(Ymax-Ymin)+Ymin) * 0.1f;

    // �r���{�[�h
    Pos.xyz = mul( Pos.xyz, BillboardMatrix );

    // ���[���h���W�ϊ�
    Pos.xyz = mul( Pos.xyz, (float3x3)WorldMatrix );
    if( flagMildFollow ){
       Pos.xyz += CoordTexArray[0].xyz;
    }else{
       Pos.xyz += WorldMatrix._41_42_43;
    }

    // �J�������_�̃r���[�ˉe�ϊ�
    Out.Pos = mul( Pos, GET_VPMAT(Pos) );

    // ���q�̓��ߓx
    y = abs(((y+speed*time-Ymin)%(Ymax-Ymin))/(Ymax-Ymin)-0.5f);
    float alpha = (1.0f-smoothstep(0.4f, 0.5f, y))*AcsTr;
    Out.Color = float4(alpha, alpha, alpha, 1.0f);

    // �e�N�X�`�����W
    Out.Tex = float3(Tex, 1.2f+LightCross*rand4);

    return Out;
}

// �s�N�Z���V�F�[�_
float4 Particle_PS( VS_OUTPUT2 IN ) : COLOR0
{
    float4 Color = tex2D( ParticleSamp2, IN.Tex.xy );
    float2 Tex1 = (IN.Tex.xy-0.5f)*IN.Tex.z+0.5f;
    float4 Color1 = tex2D( ParticleSamp1, Tex1 );
    Color += Color1;
    Color.xyz *= IN.Color.xyz*0.5f;
    return Color;
}

// �e�N�j�b�N
technique MainTec1 < string MMDPass = "object"; string Subset = "1-1000";
    string Script = "LoopByCount=ParticleCount;"
                    "LoopGetIndex=Index;"
                        "Pass=DrawObject;"
                    "LoopEnd=;"; >
{
    pass DrawObject {
        ZENABLE = false;
        AlphaBlendEnable = TRUE;
        SrcBlend = ONE;
        DestBlend = ONE;
        VertexShader = compile vs_1_1 Particle_VS();
        PixelShader  = compile ps_2_0 Particle_PS();
    }
}

