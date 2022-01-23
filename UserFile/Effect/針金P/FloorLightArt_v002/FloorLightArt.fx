////////////////////////////////////////////////////////////////////////////////////////////////
//
//  FloorLightArt.fx ver0.0.2 ���Ƀ��C�g�G��`���ē������܂��D�X�e�[�W���o�p
//  �쐬: �j��P
//
////////////////////////////////////////////////////////////////////////////////////////////////
// �����̃p�����[�^��ύX���Ă�������
#define TexFile  "sample.png" // �I�u�W�F�N�g�ɓ\��e�N�X�`���t�@�C����
int TexTypeCount = 4;         // �e�N�X�`����ސ�
float TexChangeTime = 10.0;   // �e�N�X�`���ύX���ԊԊu(�b)

int UnitCount = 7;            // �`��I�u�W�F�N�g��
float UnitSize = 1.0;         // �`��T�C�Y
float RotRadius = 15.0;       // ���ω�]���a
float LocalRotSpeed = 0.2;    // ���[�J����]���x(cycle/�b)
float GlobalRotSpeed = 0.1;   // ���Ӊ�]���x(cycle/�b)
float RadiusRange = 0.4;      // ���O�ړ��U��(RotRadius�Ƃ̔�)
float IOMoveFreq = 18.0;      // ���O�ړ�����(�b)
float Distortion = 0.0;       // ��]�ɕω���^����p�����[�^
float zAdjust = 0.0;          // �n�ʉe�Əd�Ȃ��Ă�����ꍇ�̕␳�l
float InitAlpha = 0.3;        // Tr=1�̎��̓��ߓx
float3 LightColor = {1.0, 1.0, 0.7}; // �e�N�X�`���̏�Z�F(RBG)

// ����Ȃ��l�͂������牺�͂�����Ȃ��ł�

////////////////////////////////////////////////////////////////////////////////////////////////
// �p�����[�^�錾

float AcsTr  : CONTROLOBJECT < string name = "(self)"; string item = "Tr"; >;

float time : TIME;

#define PAI 3.14159265f   // ��

int Index;

// ���W�ϊ��s��
float4x4 WorldMatrix        : WORLD;
float4x4 ViewMatrix         : VIEW;
float4x4 ProjMatrix         : PROJECTION;
float4x4 ViewProjMatrix     : VIEWPROJECTION;

//�J�����ʒu
float3 CameraPosition  : POSITION  < string Object = "Camera"; >;

texture2D ParticleTex <
    string ResourceName = TexFile;
>;
sampler ParticleSamp = sampler_state {
    texture = <ParticleTex>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = NONE;
    AddressU  = CLAMP;
    AddressV  = CLAMP;
};


////////////////////////////////////////////////////////////////////////////////////////////////
// ���W��2D��]
float3 Rotation2D(float3 pos, float rot)
{
    float x = pos.x * cos(rot) - pos.z * sin(rot);
    float z = pos.x * sin(rot) + pos.z * cos(rot);

    return float3(x, pos.y, z);
}

///////////////////////////////////////////////////////////////////////////////////////////////
// �I�u�W�F�N�g�`��

struct VS_OUTPUT {
   float4 Pos   : POSITION;    // �ˉe�ϊ����W
   float2 Tex   : TEXCOORD1;   // �e�N�X�`��
   float4 Color : COLOR0;      // ��Z�F
};

// ���_�V�F�[�_
VS_OUTPUT Basic_VS(float4 Pos : POSITION, float2 Tex : TEXCOORD0)
{
   VS_OUTPUT Out = (VS_OUTPUT)0;

   // ���[���h���W�ϊ�
   Pos.xyz = mul( Pos.xyz, (float3x3)WorldMatrix );

   // �I�u�W�F�N�g�T�C�Y
   Pos.x *= 8.0f * UnitSize;
   Pos.z *= 8.0f * UnitSize;
   Pos.y += zAdjust + 0.005f*Index; // �d�Ȃ��Ă�����Ȃ����߂̕␳

   // �I�u�W�F�N�g���[�J����]
   Pos.xyz = Rotation2D(Pos.xyz, time*LocalRotSpeed*2.0f*PAI);

   // �I�u�W�F�N�g���Ӊ�]
   Pos.z += RotRadius * (1.0f + RadiusRange * clamp( sin(time*2.0f*PAI/IOMoveFreq)+0.3f, -0.5f, 0.5f) * 2.0f );
   Pos.xyz = Rotation2D(Pos.xyz,  (time*GlobalRotSpeed + (float)Index/(float)UnitCount)*2.0f*PAI );

   // �I�u�W�F�N�g��]�̕ω�
   float3 pos = float3(0.0f, 0.0f, Distortion);
   Pos.xyz += Rotation2D(pos, ((float)Index/(float)UnitCount)*2.0f*PAI);

   // ���[���h���W
   Pos.xyz += WorldMatrix._41_42_43;

#ifndef MIKUMIKUMOVING
   // �J�������_�̃r���[�ˉe�ϊ�
   Out.Pos = mul( Pos, ViewProjMatrix );
#else
   // ���_���W
   if (MMM_IsDinamicProjection)
   {
       float dist = length(CameraPosition - Pos.xyz);
       Pos.y += MMM_GetDynamicFovEdgeRate(dist);
       float4x4 vpmat = mul( ViewMatrix, MMM_DynamicFov(ProjMatrix, dist) );
       Out.Pos = mul( Pos, vpmat );
   }
   else
   {
       Out.Pos = mul( Pos, ViewProjMatrix );
   }
#endif

   // �e�N�X�`�����W
   float LType = (float)floor( (time/TexChangeTime) % (float)TexTypeCount );
   Tex.x = (Tex.x +  LType) / (float)TexTypeCount;
   Out.Tex = Tex;

   // �e�N�X�`���̏�Z�F
   float a = (0.5f - abs( frac( time / TexChangeTime ) - 0.5f) ) * TexChangeTime;
   Out.Color = float4( LightColor*smoothstep( 0.0f, 1.0f, a )*AcsTr, 1.0f);

   return Out;
}

// �s�N�Z���V�F�[�_
float4 Basic_PS(VS_OUTPUT IN) : COLOR0
{
   float4 Color = tex2D( ParticleSamp, IN.Tex );
   Color.rgb *= InitAlpha;
   Color *= IN.Color;

   return Color;
}

////////////////////////////////////////////////////////////////////////////////////////////////
// �e�N�j�b�N
technique MainTec0 < string MMDPass = "object";
    string Script = "LoopByCount=UnitCount;"
                    "LoopGetIndex=Index;"
                        "Pass=DrawObject;"
                    "LoopEnd=;"; >
{
   pass DrawObject {
      ZENABLE = TRUE;
      ZWRITEENABLE = FALSE;
      AlphaBlendEnable = TRUE;
      SrcBlend = ONE;
      DestBlend = ONE;
      VertexShader = compile vs_2_0 Basic_VS();
      PixelShader  = compile ps_2_0 Basic_PS();
   }
}




