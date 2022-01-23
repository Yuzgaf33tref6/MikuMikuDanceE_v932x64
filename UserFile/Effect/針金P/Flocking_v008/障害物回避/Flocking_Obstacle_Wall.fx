////////////////////////////////////////////////////////////////////////////////////////////////
//
// Flocking_Obstacle_Wall.fx  �t���b�L���O�A���S���Y��(��Q������F�Օ��ǂƂ��Ďg�p,Pmd��)
//  �쐬: �j��P( ���͉��P����basic.fx���� )
//
////////////////////////////////////////////////////////////////////////////////////////////////
// �����̃p�����[�^��ύX���Ă�������
float AvoidanceFactor = 15.0;       // ���x(�傫������Ə�Q������Փˉ�����₷���Ȃ�)


// ����Ȃ��l�͂������牺�͂�����Ȃ��ł�
////////////////////////////////////////////////////////////////////////////////////////////////

// PMD�p�����[�^
float4x4 PmdWorldMatrix : CONTROLOBJECT < string name = "(self)"; string item = "�Z���^�["; >;
float XScale10  : CONTROLOBJECT < string name = "(self)"; string item = "X*10"; >;
float XScale100 : CONTROLOBJECT < string name = "(self)"; string item = "X*100"; >;
float YScale10  : CONTROLOBJECT < string name = "(self)"; string item = "Y*10"; >;
float YScale100 : CONTROLOBJECT < string name = "(self)"; string item = "Y*100"; >;
float ZScale10  : CONTROLOBJECT < string name = "(self)"; string item = "Z*10"; >;
float ZScale100 : CONTROLOBJECT < string name = "(self)"; string item = "Z*100"; >;
float PmdClear  : CONTROLOBJECT < string name = "(self)"; string item = "����"; >;
static float Xmax = 5.0f + 45.0f * XScale10 + 495.0f * XScale100;
static float Ymax = 5.0f + 45.0f * YScale10 + 495.0f * YScale100;
static float Zmax = 5.0f + 45.0f * ZScale10 + 495.0f * ZScale100;
static float Xmin = -Xmax;
static float Ymin = -Ymax;
static float Zmin = -Zmax;
static bool ClearFlag = PmdClear>0.5f ? true : false;

#define TEX_WIDTH  1               // ���j�b�g�f�[�^�i�[�e�N�X�`���s�N�Z����
#define TEX_HEIGHT 1024            // ���j�b�g�f�[�^�i�[�e�N�X�`���s�N�Z������

float time1 : Time;

float4x4 WorldViewProjMatrix      : WORLDVIEWPROJECTION;
float4x4 WorldMatrix              : WORLD;

float3   LightDirection    : DIRECTION < string Object = "Light"; >;
float3   CameraPosition    : POSITION  < string Object = "Camera"; >;

// �}�e���A���F
float4   MaterialDiffuse   : DIFFUSE  < string Object = "Geometry"; >;
float3   MaterialAmbient   : AMBIENT  < string Object = "Geometry"; >;
float3   MaterialEmmisive  : EMISSIVE < string Object = "Geometry"; >;
float3   MaterialSpecular  : SPECULAR < string Object = "Geometry"; >;
float    SpecularPower     : SPECULARPOWER < string Object = "Geometry"; >;
float3   MaterialToon      : TOONCOLOR;
// ���C�g�F
float3   LightDiffuse      : DIFFUSE   < string Object = "Light"; >;
float3   LightAmbient      : AMBIENT   < string Object = "Light"; >;
float3   LightSpecular     : SPECULAR  < string Object = "Light"; >;
static float4 DiffuseColor  = MaterialDiffuse  * float4(LightDiffuse, 1.0f);
static float3 AmbientColor  = saturate(MaterialAmbient  * LightAmbient + MaterialEmmisive);
static float3 SpecularColor = MaterialSpecular * LightSpecular;

// ���j�b�g�̍��W���L�^����Ă���e�N�X�`��
shared texture Flocking_CoordTex : RenderColorTarget;
sampler Flocking_SmpCoord = sampler_state
{
   Texture = <Flocking_CoordTex>;
   ADDRESSU = CLAMP;
   ADDRESSV = CLAMP;
   MAGFILTER = NONE;
   MINFILTER = NONE;
   MIPFILTER = NONE;
};

// ���j�b�g�̌����E���x���L�^����Ă���e�N�X�`��
shared texture Flocking_VelocityTex : RenderColorTarget;
sampler Flocking_SmpVelocity = sampler_state
{
   Texture = <Flocking_VelocityTex>;
   ADDRESSU = CLAMP;
   ADDRESSV = CLAMP;
   MAGFILTER = NONE;
   MINFILTER = NONE;
   MIPFILTER = NONE;
};

// ���j�b�g�̃|�e���V�����ɂ�鑀�Ǘ͂��L�^����e�N�X�`��
shared texture Flocking_PotentialTex : RenderColorTarget;
sampler Flocking_SmpPotential = sampler_state
{
   Texture = <Flocking_PotentialTex>;
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

// MMD�{����sampler���㏑�����Ȃ����߂̋L�q�ł��B�폜�s�B
sampler MMDSamp0 : register(s0);
sampler MMDSamp1 : register(s1);
sampler MMDSamp2 : register(s2);


////////////////////////////////////////////////////////////////////////////////////////////////
// ���[���h�ϊ��s��̋t�s��
// �s�񂪓��{�C��]�C���s�ړ������܂܂Ȃ����Ƃ�O������Ƃ���D
float4x4 inverseWorldMatrix(float4x4 mat)
{
    float3x3 mat3x3_inv = transpose((float3x3)mat);
    return float4x4( mat3x3_inv[0], 0, 
                     mat3x3_inv[1], 0, 
                     mat3x3_inv[2], 0, 
                     -mul(mat._41_42_43,mat3x3_inv), 1 );
}
static float4x4 WorldInvMatrix = inverseWorldMatrix( PmdWorldMatrix );

////////////////////////////////////////////////////////////////////////////////////////////////
// ���f���̉�]�t�s��
float3x3 InvRotMatrix(float3 Angle)
{
   float3 AngleY = normalize( float3(Angle.x, 0.0f, Angle.z) );
   float cosy = -Angle.z;
   float siny = sign(Angle.x) * sqrt(1.0f - cosy*cosy);
   float3 AngleXY = normalize( float3(Angle.x, 0.0f, Angle.z) );
   float cosx = dot( Angle, AngleXY );
   float sinx = sign(Angle.y) * sqrt(1.0f - cosx*cosx);

   float3x3 rMat = { cosy, -sinx*siny, -cosx*siny,
                     0.0f,  cosx,      -sinx,     
                     siny,  sinx*cosy,  cosx*cosy };

   return rMat;
}

////////////////////////////////////////////////////////////////////////////////////////////////
// ���_�V�F�[�_

struct VS_OUTPUT2 {
   float4 Pos      : POSITION;
   float2 texCoord : TEXCOORD0;
};

VS_OUTPUT2 Common_VS(float4 Pos: POSITION, float2 Tex: TEXCOORD) {
   VS_OUTPUT2 Out;
   Out.Pos = Pos;
   Out.texCoord = Tex + float2(0.5f/TEX_WIDTH, 0.5f/TEX_HEIGHT);
   return Out;
}

////////////////////////////////////////////////////////////////////////////////////////////////
// �s�N�Z���V�F�[�_(��Q������̑��Ǘ͂����߂�)

float4 Potential_PS(float2 texCoord: TEXCOORD0) : COLOR
{
    // �|�e���V�����ɂ�郆�j�b�g�̑��Ǘ�
    float4 SteerForce = tex2D(Flocking_SmpPotential, texCoord);

    // ���j�b�g�̈ʒu
    float3 Pos0 = (float3)tex2D(Flocking_SmpCoord, texCoord);

    // ���j�b�g�̕����E���x
    float4 v = tex2D(Flocking_SmpVelocity, texCoord);
    float3 Angle = v.xyz;
    float3 Vel = Angle * v.w;

    // ��Q���̕����x�N�g��
    float sgn = 1.0f;
    float3 Pos1 = (float3)mul( float4(Pos0, 1.0f), WorldInvMatrix );
    float3 ObstaclePos = float3( clamp( Pos1.x, Xmin, Xmax ),
                                 clamp( Pos1.y, Ymin, Ymax ),
                                 clamp( Pos1.z, Zmin, Zmax ) );
    if( ObstaclePos.x==Pos1.x && ObstaclePos.y==Pos1.y && ObstaclePos.z==Pos1.z ){ // ��Q���̓����ɂ͂����Ă��܂����ꍇ�̏���
            if( Pos1.y*Xmax<-Pos1.x*Ymax && Pos1.y*Xmax>Pos1.x*Ymax && Pos1.z*Xmax<-Pos1.x*Zmax && Pos1.z*Xmax>Pos1.x*Zmax ) ObstaclePos.x = Xmin;
       else if( Pos1.y*Xmax>-Pos1.x*Ymax && Pos1.y*Xmax<Pos1.x*Ymax && Pos1.z*Xmax>-Pos1.x*Zmax && Pos1.z*Xmax<Pos1.x*Zmax ) ObstaclePos.x = Xmax;
       else if( Pos1.z*Ymax<-Pos1.y*Zmax && Pos1.z*Ymax>Pos1.y*Zmax && Pos1.x*Ymax<-Pos1.y*Xmax && Pos1.x*Ymax>Pos1.y*Xmax ) ObstaclePos.y = Ymin;
       else if( Pos1.z*Ymax>-Pos1.y*Zmax && Pos1.z*Ymax<Pos1.y*Zmax && Pos1.x*Ymax>-Pos1.y*Xmax && Pos1.x*Ymax<Pos1.y*Xmax ) ObstaclePos.y = Ymax;
       else if( Pos1.x*Zmax<-Pos1.z*Xmax && Pos1.x*Zmax>Pos1.z*Xmax && Pos1.y*Zmax<-Pos1.z*Ymax && Pos1.y*Zmax>Pos1.z*Ymax ) ObstaclePos.z = Zmin;
       else if( Pos1.x*Zmax>-Pos1.z*Xmax && Pos1.x*Zmax<Pos1.z*Xmax && Pos1.y*Zmax>-Pos1.z*Ymax && Pos1.y*Zmax<Pos1.z*Ymax ) ObstaclePos.z = Zmax;
       sgn = -1.0f;
    }
    ObstaclePos = (float3)mul( float4(ObstaclePos, 1.0f), PmdWorldMatrix );
    float3 ObstacleAngle = sgn * normalize( ObstaclePos - Pos0 );

    // ��Q���\�ʂ܂ł̋���
    float ObstacleLength = length( Pos0 - ObstaclePos );

    // ��Q���ɏՓ˂̉\��������ꍇ�͑��Ǘ͂�t��
    if( ObstacleLength < AvoidanceFactor && dot( Angle, ObstacleAngle ) > -abs(cos(time1)) ){
       // ��Q���̃|�e���V����
       float len1 = clamp( ObstacleLength, 0.001f, AvoidanceFactor );
       float len2 = max( AvoidanceFactor-ObstacleLength, 0.0f );
       float p = sgn>0.0f ? max( 1.0f/len1, 0.0f ) + len2*len2 : ObstacleLength*ObstacleLength*50.0f;
       float3 pa = mul( -ObstacleAngle, InvRotMatrix(Angle) );
       if(sgn>0.0f) pa.z = 0.0f;
       SteerForce.xyz += normalize(pa)*p;
    }

    return SteerForce;
}

////////////////////////////////////////////////////////////////////////////////////////////////
//MMM�Ή�

#ifdef MIKUMIKUMOVING
    #define VS_INPUT  MMM_SKINNING_INPUT
    #define SKINNING_OUTPUT  MMM_SKINNING_OUTPUT
    #define GETPOSNORMAL  MMM_SkinnedPositionNormal(IN.Pos, IN.Normal, IN.BlendWeight, IN.BlendIndices, IN.SdefC, IN.SdefR0, IN.SdefR1)
#else
    struct VS_INPUT{
        float4 Pos    : POSITION;
        float3 Normal : NORMAL;
        float2 Tex    : TEXCOORD0;
    };
    struct SKINNING_OUTPUT{
        float4 Position;
        float3 Normal;
    };
    #define GETPOSNORMAL  {IN.Pos, IN.Normal}
#endif

///////////////////////////////////////////////////////////////////////////////////////////////
// �I�u�W�F�N�g�`��i�Z���t�V���h�EOFF�j

struct VS_OUTPUT
{
    float4 Pos        : POSITION;    // �ˉe�ϊ����W
    float3 Normal     : TEXCOORD1;   // �@��
    float3 Eye        : TEXCOORD2;   // �J�����Ƃ̑��Έʒu
    float4 Color      : COLOR0;      // �f�B�t���[�Y�F
};

// ���_�V�F�[�_
VS_OUTPUT Basic_VS(VS_INPUT IN)
{
    VS_OUTPUT Out = (VS_OUTPUT)0;
    SKINNING_OUTPUT SkinOut = GETPOSNORMAL;

    // �J�������_�̃��[���h�r���[�ˉe�ϊ�
    Out.Pos = mul( SkinOut.Position, WorldViewProjMatrix );

    // �J�����Ƃ̑��Έʒu
    Out.Eye = CameraPosition - mul( SkinOut.Position, WorldMatrix );
    // ���_�@��
    Out.Normal = normalize( mul( SkinOut.Normal, (float3x3)WorldMatrix ) );

    // �f�B�t���[�Y�F�{�A���r�G���g�F �v�Z
    Out.Color.rgb = saturate( max(0,dot( Out.Normal, -LightDirection )) * DiffuseColor.rgb + AmbientColor );
    Out.Color.a = DiffuseColor.a;

    return Out;
}

// �s�N�Z���V�F�[�_
float4 Basic_PS( VS_OUTPUT IN ) : COLOR0
{
    // �X�y�L�����F�v�Z
    float3 HalfVector = normalize( normalize(IN.Eye) + -LightDirection );
    float3 Specular = pow( max(0,dot( HalfVector, normalize(IN.Normal) )), SpecularPower ) * SpecularColor;

    float4 Color = IN.Color;

    // �g�D�[���K�p
    float LightNormal = dot( IN.Normal, -LightDirection );
    // if(LightNormal<0){Color.rgb*=MaterialToon;} �Ƃ��Ă��悢���A���E�̃h�b�g�������Ă��܂��̂łڂ���
    Color.rgb *= lerp(MaterialToon, float3(1,1,1), saturate(LightNormal * 16 + 0.5));

    // �X�y�L�����K�p
    Color.rgb += Specular;

    // ��\���ݒ�
    if( ClearFlag ) Color.a = 0.0f;

    return Color;
}

////////////////////////////////////////////////////////////////////////////////////////////////

//�Z���t�V���h�E�Ȃ�
technique MainTec0 < string MMDPass = "object";
    string Script = 
        "RenderColorTarget0=Flocking_PotentialTex;"
	    "RenderDepthStencilTarget=DepthBuffer;"
	    "Pass=CalcPotential;"
        "RenderColorTarget0=;"
	    "RenderDepthStencilTarget=;"
	    "Pass=DrawObject;"
        ;
>{
    pass CalcPotential < string Script = "Draw=Buffer;";>
    {
        ALPHABLENDENABLE = FALSE;
        ALPHATESTENABLE = FALSE;
        VertexShader = compile vs_3_0 Common_VS();
        PixelShader  = compile ps_3_0 Potential_PS();
    }
    pass DrawObject {
        VertexShader = compile vs_2_0 Basic_VS();
        PixelShader  = compile ps_2_0 Basic_PS();
    }
}

//�Z���t�V���h�E����
technique MainTec1 < string MMDPass = "object_ss";
    string Script = 
        "RenderColorTarget0=Flocking_PotentialTex;"
	    "RenderDepthStencilTarget=DepthBuffer;"
	    "Pass=CalcPotential;"
        "RenderColorTarget0=;"
	    "RenderDepthStencilTarget=;"
	    "Pass=DrawObject;"
        ;
>{
    pass CalcPotential < string Script = "Draw=Buffer;";>
    {
        ALPHABLENDENABLE = FALSE;
        ALPHATESTENABLE = FALSE;
        VertexShader = compile vs_3_0 Common_VS();
        PixelShader  = compile ps_3_0 Potential_PS();
    }
    pass DrawObject {
        VertexShader = compile vs_2_0 Basic_VS();
        PixelShader  = compile ps_2_0 Basic_PS();
    }
}

//�G�b�W��n�ʉe�͕`�悵�Ȃ�
technique EdgeTec < string MMDPass = "edge"; > { }
technique ShadowTec < string MMDPass = "shadow"; > { }
technique ZplotTec < string MMDPass = "zplot"; > { }
