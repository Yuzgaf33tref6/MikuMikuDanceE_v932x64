////////////////////////////////////////////////////////////////////////////////////////////////
//
//  DLEX_Object.fx : DiscoLightEx�I�u�W�F�N�g�`��(Lat�����f����p)
//  ( DiscoLightEx.fx ����Ăяo����܂��D�I�t�X�N���[���`��p)
//  �쐬: �j��P( ���͉��P����full.fx���� )
//
////////////////////////////////////////////////////////////////////////////////////////////////
// �����̃p�����[�^��ύX���Ă�������
//(DiscoLightEx.fx�Ɠ����p�����[�^�͓����l�ɐݒ肵�Ă�������)

// Lat�����f���̃t�F�C�X�ގ��ԍ����X�g
#define LatFaceNo  "7,17,19,22,24"  // ��Lat���~�NVer2.31_Normal.pmd�̗�, ���f���ɂ���ď���������K�v����

// �Z���t�V���h�E�̗L��
#define Use_SelfShadow  1  // 0:�Ȃ�, 1:�L��

// �\�t�g�V���h�E�̗L��
#define UseSoftShadow  1  // 0:�Ȃ�, 1:�L��

// �V���h�E�}�b�v�o�b�t�@�T�C�Y
#define ShadowMapSize  1024   // 512, 1024, 2048, 4096 �̂ǂꂩ�őI��

float LightPowerMax = 2.0; // ���C�g�ő唭�����x

float LightDistance = 0.5;   // �����̋����ɑ΂��錸���ʌW��(0.0�`1.0���x�Œ���)

float AmbientPower = 0.03; // �������U�����̋���(0.0�`1.0���x�Œ���)

float BallRotateMax = 1.5; // ���C�g��]���x�ő�l

#define LightTexNum   6    // ���C�g�e�N�X�`����ސ�(�ő�6�܂�)

// ���C�g�ɓ\��e�N�X�`���t�@�C����
#define LightTexFile1   "LightTex01.png"
#define LightTexFile2   "LightTex02.png"
#define LightTexFile3   "LightTex03.png"
#define LightTexFile4   "LightTex04.png"
#define LightTexFile5   "LightTex05.png"
#define LightTexFile6   "LightTex06.png"

// �e�N�X�`���ɃL���[�u�x�[�X�F�̏�Z���A1:�s��, 0:�s��Ȃ�
#define CubeBackColor1   1
#define CubeBackColor2   1
#define CubeBackColor3   1
#define CubeBackColor4   0
#define CubeBackColor5   1
#define CubeBackColor6   0


#define FLG_EXCEPTION  0  // MMD�Ń��f���`�悪����ɂ���Ȃ��ꍇ�͂�����1�ɂ���


// ����Ȃ��l�͂������牺�͂�����Ȃ��ł�

///////////////////////////////////////////////////////////////////////////////////////////////
// �p�����[�^�Z�b�g

#ifndef MIKUMIKUMOVING
    #define DLEX_OBJNAME   "(OffscreenOwner)"
#else
    #define DLEX_OBJNAME   "DiscoLightEx.pmx"
#endif

// ���C�g�̕\����ON/OFF
bool LightOn : CONTROLOBJECT < string Name = DLEX_OBJNAME; >;

// �����ʒu
float3 LightPosition : CONTROLOBJECT < string name = DLEX_OBJNAME; string item = "�����ʒu"; >;

// �����̋����ɑ΂��錸���ʌW��
static float Attenuation = 1.0f/max(lerp(0.1f, 5.0f, LightDistance), 0.1f);

//���C�g���
float NowLightTex : CONTROLOBJECT < string name = DLEX_OBJNAME; string item = "ײĎ��"; >;

//���C�g�p���[
float MorphLtPow : CONTROLOBJECT < string name = DLEX_OBJNAME; string item = "�������x"; >;
static float LightPower = LightOn ? saturate(1.0f - MorphLtPow) * LightPowerMax : LightPowerMax;

float MorphSdBulr : CONTROLOBJECT < string name = DLEX_OBJNAME; string item = "�e�ڂ���"; >;
float MorphSdDens : CONTROLOBJECT < string name = DLEX_OBJNAME; string item = "�e�Z�x"; >;
static float ShadowBulrPower = LightOn ? max( lerp(0.5f, 5.0f, MorphSdBulr), 0.0f) : 1.0f; // �\�t�g�V���h�E�̂ڂ������x
static float ShadowDensity = LightOn ? saturate(1.0f - MorphSdDens) : 0.0f;                // �Z���t�e�̔Z�x

#define CUBECOLOR1  float3(0.5, 1.0, 0.5);
#define CUBECOLOR2  float3(1.0, 0.5, 0.5);
#define CUBECOLOR3  float3(1.0, 1.0, 0.5);
#define CUBECOLOR4  float3(0.5, 0.5, 1.0);
#define CUBECOLOR5  float3(0.5, 1.0, 1.0);
#define CUBECOLOR6  float3(1.0, 0.5, 1.0);

float pmdRotX1 : CONTROLOBJECT < string name = DLEX_OBJNAME; string item = "+X��]"; >;
float pmdRotY1 : CONTROLOBJECT < string name = DLEX_OBJNAME; string item = "+Y��]"; >;
float pmdRotZ1 : CONTROLOBJECT < string name = DLEX_OBJNAME; string item = "+Z��]"; >;
float pmdRotX2 : CONTROLOBJECT < string name = DLEX_OBJNAME; string item = "-X��]"; >;
float pmdRotY2 : CONTROLOBJECT < string name = DLEX_OBJNAME; string item = "-Y��]"; >;
float pmdRotZ2 : CONTROLOBJECT < string name = DLEX_OBJNAME; string item = "-Z��]"; >;

static float ballRotX = (pmdRotX1 - pmdRotX2) * BallRotateMax;
static float ballRotY = (pmdRotY1 - pmdRotY2) * BallRotateMax;
static float ballRotZ = (pmdRotZ1 - pmdRotZ2) * BallRotateMax;

// ��{�[�����W
float4x4 BoneFaceMatrix : CONTROLOBJECT < string name = "(self)"; string item = "��"; >;
static float3 LatFacePos = BoneFaceMatrix._41_42_43;
static float3 LatFaceDirec = -normalize( BoneFaceMatrix._31_32_33 );

////////////////////////////////////////////////////////////////////////////////////////////////
// �e�N�X�`���̃L���[�u�z�u�֘A�̏���

// �{�[����]�s��
float BallTime : TIME;
float3x3 CalcRotateMatrix(float time)
{
   float cosX, sinX;
   float cosY, sinY;
   float cosZ, sinZ;

   sincos(ballRotX * time, sinX, cosX);
   sincos(ballRotY * time, sinY, cosY);
   sincos(ballRotZ * time, sinZ, cosZ);

   return float3x3(
      cosY * cosZ + sinX * sinY * sinZ,  cosY * sinZ - sinX * sinY * cosZ, cosX * sinY,
     -cosX * sinZ,                       cosX * cosZ,                      sinX, 
      sinX * cosY * sinZ - sinY * cosZ, -sinY * sinZ - sinX * cosY * cosZ, cosX * cosY
   );
}
static float3x3 BallRotateMatrix = CalcRotateMatrix(BallTime);

// ���C�g�{�[���e�N�X�`��
texture2D LightTex1
<
   string ResourceName = LightTexFile1;
>;
sampler LightTexSmp1 = sampler_state
{
    Texture = (LightTex1);
    ADDRESSU = CLAMP;
    ADDRESSV = CLAMP;
    MINFILTER = LINEAR;
    MAGFILTER = LINEAR;
    MIPFILTER = NONE;
};

#if LightTexNum > 1
texture2D LightTex2
<
   string ResourceName = LightTexFile2;
>;
sampler LightTexSmp2 = sampler_state
{
    Texture = (LightTex2);
    ADDRESSU = CLAMP;
    ADDRESSV = CLAMP;
    MINFILTER = LINEAR;
    MAGFILTER = LINEAR;
    MIPFILTER = NONE;
};
#endif

#if LightTexNum > 2
texture2D LightTex3
<
   string ResourceName = LightTexFile3;
>;
sampler LightTexSmp3 = sampler_state
{
    Texture = (LightTex3);
    ADDRESSU = CLAMP;
    ADDRESSV = CLAMP;
    MINFILTER = LINEAR;
    MAGFILTER = LINEAR;
    MIPFILTER = NONE;
};
#endif

#if LightTexNum > 3
texture2D LightTex4
<
   string ResourceName = LightTexFile4;
>;
sampler LightTexSmp4 = sampler_state
{
    Texture = (LightTex4);
    ADDRESSU = CLAMP;
    ADDRESSV = CLAMP;
    MINFILTER = LINEAR;
    MAGFILTER = LINEAR;
    MIPFILTER = NONE;
};
#endif

#if LightTexNum > 4
texture2D LightTex5
<
   string ResourceName = LightTexFile5;
>;
sampler LightTexSmp5 = sampler_state
{
    Texture = (LightTex5);
    ADDRESSU = CLAMP;
    ADDRESSV = CLAMP;
    MINFILTER = LINEAR;
    MAGFILTER = LINEAR;
    MIPFILTER = NONE;
};
#endif

#if LightTexNum > 5
texture2D LightTex6
<
   string ResourceName = LightTexFile6;
>;
sampler LightTexSmp6 = sampler_state
{
    Texture = (LightTex6);
    ADDRESSU = CLAMP;
    ADDRESSV = CLAMP;
    MINFILTER = LINEAR;
    MAGFILTER = LINEAR;
    MIPFILTER = NONE;
};
#endif

static const float lightNum = 1.0f / max(2.0*(LightTexNum-1), 1.0f);

// ���C�g�{�[���F�v�Z(2D�e�N�X�`�����L���[�u�z�u�ɂ��ĎQ��)
float3 GetTexCubeColor( float3 dir )
{
   float3 absDir = abs(dir);
   float2 uv;
   float3 color;

   if(absDir.x >= absDir.y && absDir.x >= absDir.z){
      if(dir.x > 0){
         uv = float2(-dir.y, dir.z) / dir.x;
         color = CUBECOLOR1;
      }else{
         uv = float2(dir.y, dir.z) / dir.x;
         color = CUBECOLOR2;
      }
   }else if(absDir.y >= absDir.x && absDir.y >= absDir.z){
      if(dir.y > 0){
         uv = float2(dir.z, -dir.x) / dir.y;
         color = CUBECOLOR3;
      }else{
         uv = float2(-dir.z, -dir.x) / dir.y;
         color = CUBECOLOR4;
      }
   }else{
      if(dir.z > 0){
         uv = float2(-dir.x, dir.y) / dir.z;
         color = CUBECOLOR5;
      }else{
         uv = float2(dir.x, dir.y) / dir.z;
         color = CUBECOLOR6;
      }
   }

   uv = 0.5f * (uv + 1.0f);

   #if LightTexNum > 1
   if(NowLightTex < lightNum)
   #endif
   {
      return tex2D(LightTexSmp1, uv).rgb * lerp(float3(1,1,1), color, CubeBackColor1);
   }
#if LightTexNum > 1
   else
   #if LightTexNum > 2
   if(NowLightTex < lightNum*3.0f)
   #endif
   {
      return tex2D(LightTexSmp2, uv).rgb * lerp(float3(1,1,1), color, CubeBackColor2);
   }
#endif
#if LightTexNum > 2
   else
   #if LightTexNum > 3
   if(NowLightTex < lightNum*5.0f)
   #endif
   {
      return tex2D(LightTexSmp3, uv).rgb * lerp(float3(1,1,1), color, CubeBackColor3);
   }
#endif
#if LightTexNum > 3
   else
   #if LightTexNum > 4
   if(NowLightTex < lightNum*7.0f)
   #endif
   {
      return tex2D(LightTexSmp4, uv).rgb * lerp(float3(1,1,1), color, CubeBackColor4);
   }
#endif
#if LightTexNum > 4
   else
   #if LightTexNum > 5
   if(NowLightTex < lightNum*9.0f)
   #endif
   {
      return tex2D(LightTexSmp5, uv).rgb * lerp(float3(1,1,1), color, CubeBackColor5);
   }
#endif
#if LightTexNum > 5
   else{
      return tex2D(LightTexSmp6, uv).rgb * lerp(float3(1,1,1), color, CubeBackColor6);
   }
#endif

}


////////////////////////////////////////////////////////////////////////////////////////////////
// �V���h�E�}�b�v�֘A�̏���

#if Use_SelfShadow==1

// Z�v���b�g�͈�
#define Z_NEAR  1.0     // �ŋߒl
#define Z_FAR   1000.0  // �ŉ��l

// �V���h�E�}�b�v�o�b�t�@�T�C�Y
#if ShadowMapSize==512
    #define SMAPSIZE_WIDTH   512
    #define SMAPSIZE_HEIGHT  1024
#endif
#if ShadowMapSize==1024
    #define SMAPSIZE_WIDTH   1024
    #define SMAPSIZE_HEIGHT  2048
#endif
#if ShadowMapSize==2048
    #define SMAPSIZE_WIDTH   2048
    #define SMAPSIZE_HEIGHT  4096
#endif
#if ShadowMapSize==4096
    #define SMAPSIZE_WIDTH   4096
    #define SMAPSIZE_HEIGHT  8192
#endif

#if LightID > 1
    #define  ShadowMap(n)  FL_ShadowMap##n  // �V���h�E�}�b�v(�O��)�e�N�X�`����
#else
    #define  ShadowMap(n)  FL_ShadowMap   // �V���h�E�}�b�v(�O��)�e�N�X�`����
#endif

// �Ǝ��V���h�E�}�b�v�T���v���[
shared texture DL_ShadowMap : OFFSCREENRENDERTARGET;
sampler ShadowMapSamp = sampler_state {
    texture = <DL_ShadowMap>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = LINEAR;
    AddressU  = CLAMP;
    AddressV = CLAMP;
};


#if UseSoftShadow==1
// �V���h�E�}�b�v�̃T���v�����O�Ԋu
static float2 SMapSampStep = float2(ShadowBulrPower/1024.0f, ShadowBulrPower/2048.0f);

// �V���h�E�}�b�v�̎��ӃT���v�����O1
float4 GetZPlotSampleBase1(float2 Tex, float smpScale)
{
    float2 smpStep = SMapSampStep * smpScale;
    float mipLv = log2( max(SMAPSIZE_WIDTH*smpStep.x, 1.0f) );
    float4 Color = tex2Dlod(ShadowMapSamp, float4(Tex, 0, mipLv)) * 2.0f;
    Color += tex2Dlod(ShadowMapSamp, float4(Tex+smpStep*float2(-1,-1), 0, mipLv));
    Color += tex2Dlod(ShadowMapSamp, float4(Tex+smpStep*float2( 1,-1), 0, mipLv));
    Color += tex2Dlod(ShadowMapSamp, float4(Tex+smpStep*float2(-1, 1), 0, mipLv));
    Color += tex2Dlod(ShadowMapSamp, float4(Tex+smpStep*float2( 1, 1), 0, mipLv));
    return (Color / 6.0f);
}

// �V���h�E�}�b�v�̎��ӃT���v�����O2
float4 GetZPlotSampleBase2(float2 Tex, float smpScale)
{
    float2 smpStep = SMapSampStep * smpScale;
    float mipLv = log2( max(SMAPSIZE_WIDTH*smpStep.x, 1.0f) );
    float4 Color = tex2Dlod(ShadowMapSamp, float4(Tex, 0, mipLv)) * 2.0f;
    Color += tex2Dlod(ShadowMapSamp, float4(Tex+smpStep*float2(-1, 0), 0, mipLv));
    Color += tex2Dlod(ShadowMapSamp, float4(Tex+smpStep*float2( 1, 0), 0, mipLv));
    Color += tex2Dlod(ShadowMapSamp, float4(Tex+smpStep*float2( 0,-1), 0, mipLv));
    Color += tex2Dlod(ShadowMapSamp, float4(Tex+smpStep*float2( 0, 1), 0, mipLv));
    return (Color / 6.0f);
}
#endif

#define MSC   0.98  // �}�b�v�k����

// �o�����ʃV���h�E�}�b�v���Z�v���b�g�ǂݎ��
float2 GetZPlotDP(float3 Vec)
{
    bool flagFront = (Vec.z >= 0) ? true : false;

    if ( !flagFront ) Vec.yz = -Vec.yz;
    float2 Tex = Vec.xy * MSC / (1.0f + Vec.z);
    Tex.y = -Tex.y;
    Tex = (Tex + 1.0f) * 0.5f;
    Tex.y = flagFront ? 0.5f*Tex.y : 0.5f*(Tex.y+1.0f) + 1.0f/SMAPSIZE_HEIGHT;

    #if UseSoftShadow==1
    float4 Color;
    Color  = GetZPlotSampleBase1(Tex, 1.0f) * 0.508f;
    Color += GetZPlotSampleBase2(Tex, 2.0f) * 0.254f;
    Color += GetZPlotSampleBase1(Tex, 3.0f) * 0.127f;
    Color += GetZPlotSampleBase2(Tex, 4.0f) * 0.063f;
    Color += GetZPlotSampleBase1(Tex, 5.0f) * 0.032f;
    Color += GetZPlotSampleBase2(Tex, 6.0f) * 0.016f;
    #else
    float4 Color = tex2Dlod(ShadowMapSamp, float4(Tex,0,0));
    #endif

    return Color.xy;
}

#endif


#ifndef MIKUMIKUMOVING
////////////////////////////////////////////////////////////////////////////////////////////////
//  �ȉ�MikuMikuEfect�d�l�R�[�h
////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////////
// �p�����[�^�錾

// ���W�ϊ��s��
float4x4 WorldViewProjMatrix : WORLDVIEWPROJECTION;
float4x4 WorldMatrix         : WORLD;
float4x4 ViewMatrix          : VIEW;

float3 CameraPosition : POSITION  < string Object = "Camera"; >;

// �}�e���A���F
float4 MaterialDiffuse  : DIFFUSE  < string Object = "Geometry"; >;
float3 MaterialAmbient  : AMBIENT  < string Object = "Geometry"; >;
float3 MaterialEmmisive : EMISSIVE < string Object = "Geometry"; >;
float3 MaterialSpecular : SPECULAR < string Object = "Geometry"; >;
float  SpecularPower    : SPECULARPOWER < string Object = "Geometry"; >;
float3 MaterialToon     : TOONCOLOR;
float4 EdgeColor        : EDGECOLOR;

// �e�N�X�`���ގ����[�t�l
#if(FLG_EXCEPTION == 0)
float4 TextureAddValue : ADDINGTEXTURE;
float4 TextureMulValue : MULTIPLYINGTEXTURE;
float4 SphereAddValue  : ADDINGSPHERETEXTURE;
float4 SphereMulValue  : MULTIPLYINGSPHERETEXTURE;
#else
float4 TextureAddValue = float4(0,0,0,0);
float4 TextureMulValue = float4(1,1,1,1);
float4 SphereAddValue  = float4(0,0,0,0);
float4 SphereMulValue  = float4(1,1,1,1);
#endif

bool use_texture;       // �e�N�X�`���̗L��
bool use_spheremap;     // �X�t�B�A�}�b�v�̗L��
bool use_subtexture;    // �T�u�e�N�X�`���t���O
bool spadd;    // �X�t�B�A�}�b�v���Z�����t���O

// �I�u�W�F�N�g�̃e�N�X�`��
texture ObjectTexture: MATERIALTEXTURE;
sampler ObjTexSampler = sampler_state {
    texture = <ObjectTexture>;
    MINFILTER = LINEAR;
    MAGFILTER = LINEAR;
    MIPFILTER = LINEAR;
    ADDRESSU  = WRAP;
    ADDRESSV  = WRAP;
};

// �X�t�B�A�}�b�v�̃e�N�X�`��
texture ObjectSphereMap: MATERIALSPHEREMAP;
sampler ObjSphareSampler = sampler_state {
    texture = <ObjectSphereMap>;
    MINFILTER = LINEAR;
    MAGFILTER = LINEAR;
    MIPFILTER = LINEAR;
    ADDRESSU  = WRAP;
    ADDRESSV  = WRAP;
};

// �g�D�[���}�b�v�̃e�N�X�`��
texture ObjectToonTexture: MATERIALTOONTEXTURE;
sampler ObjToonSampler = sampler_state {
    texture = <ObjectToonTexture>;
    MINFILTER = LINEAR;
    MAGFILTER = LINEAR;
    MIPFILTER = NONE;
    ADDRESSU  = CLAMP;
    ADDRESSV  = CLAMP;
};


////////////////////////////////////////////////////////////////////////////////////////////////
// �֊s�`��

// ���_�V�F�[�_
float4 VS_Edge(float4 Pos : POSITION) : POSITION
{
    return mul( Pos, WorldViewProjMatrix );
}

// �s�N�Z���V�F�[�_
float4 PS_Edge() : COLOR
{
    // ���œh��Ԃ�
    return float4(0, 0, 0, EdgeColor.a);
}

// �֊s�`��p�e�N�j�b�N
technique EdgeTec < string MMDPass = "edge"; > {
    pass DrawEdge {
        VertexShader = compile vs_2_0 VS_Edge();
        PixelShader  = compile ps_2_0 PS_Edge();
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////
// �I�u�W�F�N�g�`��

struct VS_OUTPUT {
    float4 Pos       : POSITION;    // �ˉe�ϊ����W
    float4 WPos      : TEXCOORD1;   // ���[���h���W
    float2 Tex       : TEXCOORD2;   // �e�N�X�`��
    float3 Normal    : TEXCOORD3;   // �@��
    float3 Eye       : TEXCOORD4;   // �J�����Ƃ̑��Έʒu
    float2 SpTex     : TEXCOORD5;   // �X�t�B�A�}�b�v�e�N�X�`�����W
    float3 BallDir   : TEXCOORD6;   // �{�[���̌���
};

// ���_�V�F�[�_
VS_OUTPUT VS_Object(float4 Pos : POSITION, float3 Normal : NORMAL, float2 Tex : TEXCOORD0, float2 Tex2 : TEXCOORD1, uniform bool isLatFace)
{
    VS_OUTPUT Out = (VS_OUTPUT)0;

    // �J�������_�̃��[���h�r���[�ˉe�ϊ�
    Out.Pos = mul( Pos, WorldViewProjMatrix );

    // ���[���h���W
    Out.WPos = mul( Pos, WorldMatrix );

    // �J�����Ƃ̑��Έʒu
    Out.Eye = CameraPosition - mul( Pos, WorldMatrix ).xyz;

    // ���_�@��
    Out.Normal = normalize( mul( Normal, (float3x3)WorldMatrix ) );

    // �e�N�X�`�����W
    Out.Tex = Tex;

    if ( use_spheremap ) {
        if ( use_subtexture ) {
            // PMX�T�u�e�N�X�`�����W
            Out.SpTex = Tex2;
        } else {
            // �X�t�B�A�}�b�v�e�N�X�`�����W
            float2 NormalWV = mul( Out.Normal, (float3x3)ViewMatrix ).xy;
            Out.SpTex.x = NormalWV.x * 0.5f + 0.5f;
            Out.SpTex.y = NormalWV.y * -0.5f + 0.5f;
        }
    }

    // �{�[���̌���
    if( isLatFace ){
        Out.BallDir = mul(LatFacePos - LightPosition, BallRotateMatrix);
    }else{
        Out.BallDir = mul(Out.WPos.xyz - LightPosition, BallRotateMatrix);
    }

    return Out;
}


// �s�N�Z���V�F�[�_
float4 PS_Object(VS_OUTPUT IN, uniform bool isLatFace, uniform bool useSelfShadow) : COLOR0
{
    // ���C�g����
    float3 LightDirection;
    if( isLatFace ){
        LightDirection = normalize(LatFacePos - LightPosition);
    }else{
        LightDirection = normalize(IN.WPos.xyz - LightPosition);
    }

    // �s�N�Z���@��
    float3 Normal = normalize( IN.Normal );
    if( isLatFace ){
        Normal = LatFaceDirec;
    }else{
        Normal = normalize( IN.Normal );
    }

    // ���C�g�F�v�Z
    float3 LightColor = GetTexCubeColor( normalize( IN.BallDir ) );
    float LightNormal = dot( Normal, -LightDirection );
    LightColor = lerp(float3(0,0,0), LightColor, saturate(LightNormal * 2 + 0.5)) * LightOn;

    // �`��F
    float4 DiffuseColor  = MaterialDiffuse  * float4(LightColor, 1.0f);
    float3 AmbientColor  = MaterialEmmisive * LightColor * AmbientPower;
    float3 SpecularColor = MaterialSpecular * LightColor;

    // �f�B�t���[�Y�F�{�A���r�G���g�F �v�Z
    float4 Color = float4(AmbientColor, DiffuseColor.a);
    float4 ShadowColor = Color;  // �e�̐F
    if( isLatFace ){
        Color.rgb += lerp(0.03f, 0.7f, max(0.0f, dot(LatFaceDirec, -LightDirection))) * DiffuseColor.rgb;
        ShadowColor = Color;
    }else{
        Color.rgb += max(0.0f, dot(Normal, -LightDirection)) * DiffuseColor.rgb;
    }
    Color = saturate( Color );
    ShadowColor = saturate( ShadowColor );

    if ( use_texture ) {
        // �e�N�X�`���K�p
        float4 TexColor = tex2D( ObjTexSampler, IN.Tex );
        if( useSelfShadow ) {
            // �e�N�X�`���ގ����[�t��
            TexColor.rgb = lerp(1, TexColor * TextureMulValue + TextureAddValue, TextureMulValue.a + TextureAddValue.a).rgb;
        }
        Color *= TexColor;
        ShadowColor *= TexColor;
    }
    if ( use_spheremap ) {
        // �X�t�B�A�}�b�v�K�p
        float4 TexColor = tex2D(ObjSphareSampler,IN.SpTex);
        if( useSelfShadow ) {
            // �X�t�B�A�e�N�X�`���ގ����[�t��
            TexColor.rgb = lerp(spadd?0:1, TexColor * SphereMulValue + SphereAddValue, SphereMulValue.a + SphereAddValue.a).rgb;
        }
        if(spadd){ Color.rgb += TexColor.rgb; ShadowColor.rgb += TexColor.rgb; }
        else     { Color.rgb *= TexColor.rgb; ShadowColor.rgb *= TexColor.rgb; }
        Color.a *= TexColor.a;
        ShadowColor.a *= TexColor.a;
    }

    // �g�D�[���K�p
    #if(FLG_EXCEPTION == 0)
    Color.rgb *= tex2D( ObjToonSampler, float2(0.0f, 0.5f - LightNormal * 0.5f) ).rgb;
    #else
    Color.rgb *= lerp(MaterialToon, float3(1,1,1), saturate(LightNormal * 16 + 0.5));
    #endif
    ShadowColor.rgb *= MaterialToon;

    // �X�y�L�����K�p
    float3 HalfVector = normalize( normalize(IN.Eye) + -LightDirection );
    float3 Specular = pow( max(0, dot( HalfVector, Normal )), SpecularPower ) * SpecularColor;
    Color.rgb += Specular;
    ShadowColor.rgb += Specular*0.3f;

    // ���C�g���x
    if( isLatFace ){
        float LtPower = LightPower / max( pow(length(LatFacePos - LightPosition) * 0.1f, Attenuation), 1.0f);
        Color.rgb *= LtPower;
        ShadowColor.rgb *= LtPower;
    }else{
        float LtPower = LightPower / max( pow(length(IN.WPos.xyz - LightPosition) * 0.1f, Attenuation), 1.0f);
        Color.rgb *= LtPower;
        ShadowColor.rgb *= LtPower;
    }

#if Use_SelfShadow==1

    // Z�l
    float L = length(IN.WPos.xyz - LightPosition);
    float z = ( Z_FAR / L ) * ( L - Z_NEAR ) / ( Z_FAR - Z_NEAR );

    // �V���h�E�}�b�vZ�v���b�g
    float2 zplot = GetZPlotDP( LightDirection );

    #if UseSoftShadow==1
    // �e������(�\�t�g�V���h�E�L�� VSM:Variance Shadow Maps�@)
    float variance = max( zplot.y - zplot.x * zplot.x, 0.002f );
    float Comp = variance / (variance + max(z - zplot.x, 0.0f));
    #else
    // �e������(�\�t�g�V���h�E����)
    float Comp = 1.0 - saturate( max(z - zplot.x, 0.0f)*1500.0f - 0.3f );
    #endif

    // �e�̍���
    ShadowColor = lerp(Color, ShadowColor, ShadowDensity);
    Color = lerp(ShadowColor, Color, Comp);

#endif

    return Color;
}


///////////////////////////////////////////////////////////////////////////////////////////////
// �e�N�j�b�N

// �I�u�W�F�N�g�`��p�e�N�j�b�N�iLat���t�F�C�X, �Z���t�V���h�EOFF�j
technique MainTec0 < string MMDPass = "object"; string Subset=LatFaceNo; > {
    pass DrawObject {
        VertexShader = compile vs_3_0 VS_Object(true);
        PixelShader  = compile ps_3_0 PS_Object(true, false);
    }
}

// �I�u�W�F�N�g�`��p�e�N�j�b�N�iPMD�EPMXL�t�F�C�X�ȊO, �Z���t�V���h�EOFF�j
technique MainTec4 < string MMDPass = "object"; > {
    pass DrawObject {
        VertexShader = compile vs_3_0 VS_Object(false);
        PixelShader  = compile ps_3_0 PS_Object(false, false);
    }
}

// �I�u�W�F�N�g�`��p�e�N�j�b�N�iLat���t�F�C�X, �Z���t�V���h�EON�j
technique MainTecSS0 < string MMDPass = "object_ss"; string Subset=LatFaceNo; > {
    pass DrawObject {
        VertexShader = compile vs_3_0 VS_Object(true);
        PixelShader  = compile ps_3_0 PS_Object(true, true);
    }
}

// �I�u�W�F�N�g�`��p�e�N�j�b�N�iPMD�EPMXL�t�F�C�X�ȊO, �Z���t�V���h�EON�j
technique MainTecSS4 < string MMDPass = "object_ss"; > {
    pass DrawObject {
        VertexShader = compile vs_3_0 VS_Object(false);
        PixelShader  = compile ps_3_0 PS_Object(false, true);
    }
}


#else
///////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////
//  �ȉ�MikuMikuMoving�d�l�R�[�h
///////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////////
// �p�����[�^�錾

//���W�ϊ��s��
float4x4 WorldViewProjMatrix : WORLDVIEWPROJECTION;
float4x4 ViewProjMatrix      : VIEWPROJECTION;
float4x4 WorldMatrix         : WORLD;
float4x4 ViewMatrix          : VIEW;
float4x4 ProjMatrix          : PROJECTION;

//�ގ����[�t�֘A
float4 AddingTexture    : ADDINGTEXTURE;       // �ގ����[�t���ZTexture�l
float4 AddingSphere     : ADDINGSPHERE;        // �ގ����[�t���ZSphereTexture�l
float4 MultiplyTexture  : MULTIPLYINGTEXTURE;  // �ގ����[�t��ZTexture�l
float4 MultiplySphere   : MULTIPLYINGSPHERE;   // �ގ����[�t��ZSphereTexture�l

//�J�����ʒu
float3 CameraPosition  : POSITION  < string Object = "Camera"; >;

// �}�e���A���F
float4 MaterialDiffuse    : DIFFUSE  < string Object = "Geometry"; >;
float3 MaterialAmbient    : AMBIENT  < string Object = "Geometry"; >;
float3 MaterialEmmisive   : EMISSIVE < string Object = "Geometry"; >;
float3 MaterialSpecular   : SPECULAR < string Object = "Geometry"; >;
float  SpecularPower      : SPECULARPOWER < string Object = "Geometry"; >;
float4 MaterialToon       : TOONCOLOR;
float4 EdgeColor          : EDGECOLOR;
float  EdgeWidth          : EDGEWIDTH;

bool use_texture;       // �e�N�X�`���̗L��
bool use_spheremap;     // �X�t�B�A�}�b�v�̗L��
bool spadd;             // �X�t�B�A�}�b�v���Z�����t���O
bool usetoontexturemap; // Toon�e�N�X�`���t���O

// �I�u�W�F�N�g�̃e�N�X�`��
texture ObjectTexture: MATERIALTEXTURE;
sampler ObjTexSampler = sampler_state {
    texture = <ObjectTexture>;
    MINFILTER = LINEAR;
    MAGFILTER = LINEAR;
};

// �X�t�B�A�}�b�v�̃e�N�X�`��
texture ObjectSphereMap: MATERIALSPHEREMAP;
sampler ObjSphareSampler = sampler_state {
    texture = <ObjectSphereMap>;
    MINFILTER = LINEAR;
    MAGFILTER = LINEAR;
};


///////////////////////////////////////////////////////////////////////////////////////////////
// �I�u�W�F�N�g�`��

struct VS_OUTPUT {
    float4 Pos     : POSITION;     // �ˉe�ϊ����W
    float4 WPos    : TEXCOORD0;    // ���[���h���W
    float2 Tex     : TEXCOORD2;    // �e�N�X�`��
    float4 SubTex  : TEXCOORD3;    // �T�u�e�N�X�`��/�X�t�B�A�}�b�v�e�N�X�`�����W
    float3 Normal  : TEXCOORD4;    // �@��
    float3 Eye     : TEXCOORD5;    // �J�����Ƃ̑��Έʒu
    float3 BallDir : TEXCOORD6;    // �{�[���̌���
};

//==============================================
// ���_�V�F�[�_
// MikuMikuMoving�Ǝ��̒��_�V�F�[�_����(MMM_SKINNING_INPUT)
//==============================================
VS_OUTPUT VS_Object(MMM_SKINNING_INPUT IN, uniform bool isLatFace)
{
    VS_OUTPUT Out = (VS_OUTPUT)0;

    //================================================================================
    //MikuMikuMoving�Ǝ��̃X�L�j���O�֐�(MMM_SkinnedPositionNormal)�B���W�Ɩ@�����擾����B
    //================================================================================
    MMM_SKINNING_OUTPUT SkinOut = MMM_SkinnedPositionNormal(IN.Pos, IN.Normal, IN.BlendWeight, IN.BlendIndices, IN.SdefC, IN.SdefR0, IN.SdefR1);

    // ���[���h���W
    Out.WPos = mul( SkinOut.Position, WorldMatrix );

    // �J�����Ƃ̑��Έʒu
    Out.Eye = CameraPosition - mul( SkinOut.Position, WorldMatrix ).xyz;

    // ���_�@��
    Out.Normal = normalize( mul( SkinOut.Normal, (float3x3)WorldMatrix ) );

    // ���_���W
    if (MMM_IsDinamicProjection)
    {
        float4x4 wvpmat = mul(mul(WorldMatrix, ViewMatrix), MMM_DynamicFov(ProjMatrix, length(Out.Eye)));
        Out.Pos = mul( SkinOut.Position, wvpmat );
    }
    else
    {
        Out.Pos = mul( SkinOut.Position, WorldViewProjMatrix );
    }

    // �e�N�X�`�����W
    Out.Tex = IN.Tex;
    Out.SubTex.xy = IN.AddUV1.xy;

    if ( use_spheremap ) {
        // �X�t�B�A�}�b�v�e�N�X�`�����W
        float2 NormalWV = mul( Out.Normal, (float3x3)ViewMatrix ).xy;
        Out.SubTex.z = NormalWV.x * 0.5f + 0.5f;
        Out.SubTex.w = NormalWV.y * -0.5f + 0.5f;
    }

    // �{�[���̌���
    if( isLatFace ){
        Out.BallDir = mul(LatFacePos - LightPosition, BallRotateMatrix);
    }else{
        Out.BallDir = mul(Out.WPos.xyz - LightPosition, BallRotateMatrix);
    }

    return Out;
}


// �s�N�Z���V�F�[�_
float4 PS_Object(VS_OUTPUT IN, uniform bool isLatFace) : COLOR0
{
    // ���C�g����
    float3 LightDirection;
    if( isLatFace ){
        LightDirection = normalize(LatFacePos - LightPosition);
    }else{
        LightDirection = normalize(IN.WPos.xyz - LightPosition);
    }

    // �s�N�Z���@��
    float3 Normal = normalize( IN.Normal );
    if( isLatFace ){
        Normal = LatFaceDirec;
    }else{
        Normal = normalize( IN.Normal );
    }

    // ���C�g�F�v�Z
    float3 LightColor = GetTexCubeColor( normalize( IN.BallDir ) );
    float LightNormal = dot( Normal, -LightDirection );
    LightColor = lerp(float3(0,0,0), LightColor, saturate(LightNormal * 2 + 0.5)) * LightOn;

    // �`��F
    float4 DiffuseColor  = MaterialDiffuse  * float4(LightColor, 1.0f);
    float3 AmbientColor  = MaterialEmmisive * LightColor * AmbientPower;
    float3 SpecularColor = MaterialSpecular * LightColor;

    // �f�B�t���[�Y�F�{�A���r�G���g�F �v�Z
    float4 Color = float4(AmbientColor, DiffuseColor.a);
    float4 ShadowColor = Color;  // �e�̐F
    if( isLatFace ){
        Color.rgb += lerp(0.03f, 0.7f, max(0.0f, dot(LatFaceDirec, -LightDirection))) * DiffuseColor.rgb;
        ShadowColor = Color;
    }else{
        Color.rgb += max(0.0f, dot(Normal, -LightDirection)) * DiffuseColor.rgb;
    }
    Color = saturate( Color );
    ShadowColor = saturate( ShadowColor );

    float4 texColor = float4(1,1,1,1);
    float  texAlpha = MultiplyTexture.a + AddingTexture.a;

    // �e�N�X�`���K�p
    if (use_texture) {
        texColor = tex2D(ObjTexSampler, IN.Tex);
        texColor.rgb = (texColor.rgb * MultiplyTexture.rgb + AddingTexture.rgb) * texAlpha + (1.0 - texAlpha);
    }
    Color.rgb *= texColor.rgb;
    ShadowColor.rgb *= texColor.rgb;

    // �X�t�B�A�}�b�v�K�p
    if ( use_spheremap ) {
        // �X�t�B�A�}�b�v�K�p
        float3 texSphare = tex2D(ObjSphareSampler,IN.SubTex.zw).rgb * MultiplySphere.rgb + AddingSphere.rgb;
        if(spadd){ Color.rgb += texSphare; ShadowColor.rgb += texSphare; }
        else     { Color.rgb *= texSphare; ShadowColor.rgb *= texSphare; }
    }
    // �A���t�@�K�p
    Color.a *= texColor.a;
    ShadowColor.a *= texColor.a;

    // �Z���t�V���h�E�Ȃ��̃g�D�[���K�p
    if (usetoontexturemap ) {
        //================================================================================
        // MikuMikuMoving�f�t�H���g�̃g�D�[���F���擾����(MMM_GetToonColor)
        //================================================================================
        float3 color = MMM_GetToonColor(MaterialToon, Normal, LightDirection, LightDirection, LightDirection);
        Color.rgb *= color;
        ShadowColor.rgb *= MaterialToon.rgb;
    }

    // �X�y�L�����K�p
    float3 HalfVector = normalize( normalize(IN.Eye) + -LightDirection );
    float3 Specular = pow( max(0, dot( HalfVector, Normal )), SpecularPower ) * SpecularColor;
    Color.rgb += Specular;
    ShadowColor.rgb += Specular*0.3f;

    // ���C�g���x
    if( isLatFace ){
        float LtPower = LightPower / max( pow(length(LatFacePos - LightPosition) * 0.1f, Attenuation), 1.0f);
        Color.rgb *= LtPower;
        ShadowColor.rgb *= LtPower;
    }else{
        float LtPower = LightPower / max( pow(length(IN.WPos.xyz - LightPosition) * 0.1f, Attenuation), 1.0f);
        Color.rgb *= LtPower;
        ShadowColor.rgb *= LtPower;
    }

#if Use_SelfShadow==1

    // Z�l
    float L = length(IN.WPos.xyz - LightPosition);
    float z = ( Z_FAR / L ) * ( L - Z_NEAR ) / ( Z_FAR - Z_NEAR );

    // �V���h�E�}�b�vZ�v���b�g
    float2 zplot = GetZPlotDP( LightDirection );

    #if UseSoftShadow==1
    // �e������(�\�t�g�V���h�E�L�� VSM:Variance Shadow Maps�@)
    float variance = max( zplot.y - zplot.x * zplot.x, 0.002f );
    float Comp = variance / (variance + max(z - zplot.x, 0.0f));
    #else
    // �e������(�\�t�g�V���h�E����)
    float Comp = 1.0 - saturate( max(z - zplot.x, 0.0f)*1500.0f - 0.3f );
    #endif

    // �e�̍���
    ShadowColor = lerp(Color, ShadowColor, ShadowDensity);
    Color = lerp(ShadowColor, Color, Comp);

#endif

    return Color;
}


///////////////////////////////////////////////////////////////////////////////////////////////
// �e�N�j�b�N

// �I�u�W�F�N�g�`��p�e�N�j�b�N�iLat���t�F�C�X, �Z���t�V���h�EOFF�j
technique MainTec0 < string MMDPass = "object"; string Subset=LatFaceNo; bool UseSelfShadow = false; > {
    pass DrawObject {
        VertexShader = compile vs_3_0 VS_Object(true);
        PixelShader  = compile ps_3_0 PS_Object(true);
    }
}

// �I�u�W�F�N�g�`��p�e�N�j�b�N�iPMD�EPMXL�t�F�C�X�ȊO, �Z���t�V���h�EOFF�j
technique MainTec4 < string MMDPass = "object"; bool UseSelfShadow = false; > {
    pass DrawObject {
        VertexShader = compile vs_3_0 VS_Object(false);
        PixelShader  = compile ps_3_0 PS_Object(false);
    }
}

// �I�u�W�F�N�g�`��p�e�N�j�b�N�iLat���t�F�C�X, �Z���t�V���h�EON�j
technique MainTecSS0 < string MMDPass = "object"; string Subset=LatFaceNo; bool UseSelfShadow = true; > {
    pass DrawObject {
        VertexShader = compile vs_3_0 VS_Object(true);
        PixelShader  = compile ps_3_0 PS_Object(true);
    }
}

// �I�u�W�F�N�g�`��p�e�N�j�b�N�iPMD�EPMXL�t�F�C�X�ȊO, �Z���t�V���h�EON�j
technique MainTecSS4 < string MMDPass = "object"; bool UseSelfShadow = true; > {
    pass DrawObject {
        VertexShader = compile vs_3_0 VS_Object(false);
        PixelShader  = compile ps_3_0 PS_Object(false);
    }
}


////////////////////////////////////////////////////////////////////////////////////////////////
// �֊s�`��

// ���_�V�F�[�_
float4 VS_Edge(MMM_SKINNING_INPUT IN) : POSITION
{
    //================================================================================
    //MikuMikuMoving�Ǝ��̃X�L�j���O�֐�(MMM_SkinnedPosition)�B���W���擾����B
    //================================================================================
    MMM_SKINNING_OUTPUT SkinOut = MMM_SkinnedPositionNormal(IN.Pos, IN.Normal, IN.BlendWeight, IN.BlendIndices, IN.SdefC, IN.SdefR0, IN.SdefR1);

    // ���[���h���W
    float4 Pos = mul(SkinOut.Position, WorldMatrix);

    // �@������
    float3 Normal = normalize( mul( SkinOut.Normal, (float3x3)WorldMatrix ) );

    // ���_���W
    if (MMM_IsDinamicProjection)
    {
        float dist = length(CameraPosition - Pos.xyz);
        float4x4 vpmat = mul(ViewMatrix, MMM_DynamicFov(ProjMatrix, dist));

        Pos += float4(Normal, 0) * IN.EdgeWeight * EdgeWidth * distance(Pos.xyz, CameraPosition) * MMM_GetDynamicFovEdgeRate(dist);
        Pos = mul( Pos, vpmat );
    }
    else
    {
        Pos += float4(Normal, 0) * IN.EdgeWeight * EdgeWidth * distance(Pos.xyz, CameraPosition);
        Pos = mul( Pos, ViewProjMatrix );
    }

    return Pos;
}

//==============================================
// �s�N�Z���V�F�[�_
//==============================================
float4 PS_Edge() : COLOR
{
    // ���œh��Ԃ�
    return float4(0, 0, 0, EdgeColor.a);
}

// �֊s�`��p�e�N�j�b�N
technique EdgeTec < string MMDPass = "edge"; > {
    pass DrawEdge {
        VertexShader = compile vs_2_0 VS_Edge();
        PixelShader  = compile ps_2_0 PS_Edge();
    }
}


#endif
///////////////////////////////////////////////////////////////////////////////////////////////
//�n�ʉe�͕`�悵�Ȃ�
technique ShadowTec < string MMDPass = "shadow"; > { }

