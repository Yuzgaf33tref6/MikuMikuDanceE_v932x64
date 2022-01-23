////////////////////////////////////////////////////////////////////////////////////////////////
//
//  Butterfly_Obstacle.fx  ���̌Q��p�[�e�B�N���G�t�F�N�g(��Q�����p�I�u�W�F�N�g)
//  �쐬: �j��P
//
////////////////////////////////////////////////////////////////////////////////////////////////
// �����̃p�����[�^��ύX���Ă�������
float AvoidFactor = 5.0;       // ���x(�傫������Ə�Q���Ƃ̏Փˉ�����₷���Ȃ�)


// ����Ȃ��l�͂������牺�͂�����Ȃ��ł�
////////////////////////////////////////////////////////////////////////////////////////////////


#define TEX_WIDTH  1        // ���j�b�g�f�[�^�i�[�e�N�X�`���s�N�Z����
#define TEX_HEIGHT 512      // ���j�b�g�f�[�^�i�[�e�N�X�`���s�N�Z������

// ���W�ϊ��s��
float4x4 WorldMatrix : WORLD;

static float AcsScaling = length(WorldMatrix._11_12_13); 
static float3 CapsPos1 = (float3)mul( float4(0.0f, -0.6f, 0.0f, 1.0f), WorldMatrix );
static float3 CapsPos2 = (float3)mul( float4(0.0f,  0.6f, 0.0f, 1.0f), WorldMatrix );

// ���j�b�g�̍��W���L�^����Ă���e�N�X�`��
shared texture Butterfly_CoordTex : RenderColorTarget;
sampler Butterfly_SmpCoord = sampler_state
{
   Texture = <Butterfly_CoordTex>;
   ADDRESSU = CLAMP;
   ADDRESSV = CLAMP;
   MAGFILTER = NONE;
   MINFILTER = NONE;
   MIPFILTER = NONE;
};

// ���j�b�g�̌����E���x���L�^����Ă���e�N�X�`��
shared texture Butterfly_VelocityTex : RenderColorTarget;
sampler Butterfly_SmpVelocity = sampler_state
{
   Texture = <Butterfly_VelocityTex>;
   ADDRESSU = CLAMP;
   ADDRESSV = CLAMP;
   MAGFILTER = NONE;
   MINFILTER = NONE;
   MIPFILTER = NONE;
};

// ���j�b�g�̃|�e���V�����ɂ�鑀�Ǘ͂��L�^����e�N�X�`��
shared texture Butterfly_PotentialTex : RenderColorTarget;
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
    float4 SteerForce = tex2D(Butterfly_SmpPotential, texCoord);

    // ���j�b�g�̈ʒu
    float3 Pos0 = (float3)tex2D(Butterfly_SmpCoord, texCoord);

    // ���j�b�g�̕����E���x
    float4 v = tex2D(Butterfly_SmpVelocity, texCoord);
    float3 Angle = v.xyz;
    float3 Vel = Angle * v.w;

    // ��Q���̕����x�N�g��
    float3 ObstaclePos;
    if( dot( Pos0-CapsPos1, CapsPos2-CapsPos1 ) <= 0.0f ){
       ObstaclePos = CapsPos1;
    }else if( dot(Pos0-CapsPos2, CapsPos1-CapsPos2 ) <= 0.0f ){
       ObstaclePos = CapsPos2;
    }else{
       float len = length(  CapsPos2 - CapsPos1 );
       float t = dot( CapsPos2-CapsPos1, Pos0-CapsPos1 ) / (len*len);
       ObstaclePos = (1.0f-t) * CapsPos1 + t * CapsPos2;
    }
    float3 ObstacleAngle = normalize( ObstaclePos - Pos0 );

    // ��Q���܂ł̋���
    float ObstacleLength = length( Pos0 - ObstaclePos ) - AcsScaling;

    // ��Q���ɏՓ˂̉\��������ꍇ�͑��Ǘ͂�t��
    if( ObstacleLength < AvoidFactor && dot( Angle, ObstacleAngle ) > -0.5f ){
       // ��Q���̃|�e���V����
       float len1 = clamp( ObstacleLength, 0.001f, AvoidFactor );
       float len2 = max( AvoidFactor-ObstacleLength, 0.0f );
       float p = max( 1.0f/len1, 0.0f ) + len2*len2;
       float3 pa = mul( -ObstacleAngle, InvRoundMatrix(Angle) );
       pa.z = 0.0f;
       SteerForce.xyz += normalize(pa)*p;
    }

    return SteerForce;
}


///////////////////////////////////////////////////////////////////////////////////////////////
// �I�u�W�F�N�g�`��

float4x4 WorldViewProjMatrix : WORLDVIEWPROJECTION;
float3 LightDirection    : DIRECTION < string Object = "Light"; >;
float3 CameraPosition    : POSITION  < string Object = "Camera"; >;

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
static float4 DiffuseColor  = MaterialDiffuse * float4(LightDiffuse, 1.0f);
static float3 AmbientColor  = saturate(MaterialAmbient * LightAmbient + MaterialEmmisive);
static float3 SpecularColor = MaterialSpecular * LightSpecular;

struct VS_OUTPUT {
    float4 Pos    : POSITION;    // �ˉe�ϊ����W
    float3 Normal : TEXCOORD2;   // �@��
    float3 Eye    : TEXCOORD3;   // �J�����Ƃ̑��Έʒu
    float4 Color  : COLOR0;      // �f�B�t���[�Y�F
};

// ���_�V�F�[�_
VS_OUTPUT Object_VS(float4 Pos : POSITION, float3 Normal : NORMAL)
{
    VS_OUTPUT Out = (VS_OUTPUT)0;

    // �J�������_�̃��[���h�r���[�ˉe�ϊ�
    Out.Pos = mul( Pos, WorldViewProjMatrix );

    // �J�����Ƃ̑��Έʒu
    Out.Eye = CameraPosition - mul( Pos, WorldMatrix ).xyz;
    // ���_�@��
    Out.Normal = normalize( mul( Normal, (float3x3)WorldMatrix ) );

    // �f�B�t���[�Y�F�{�A���r�G���g�F �v�Z
    Out.Color.rgb = AmbientColor;
    Out.Color.rgb += max(0,dot( Out.Normal, -LightDirection )) * DiffuseColor.rgb;
    Out.Color.a = DiffuseColor.a;
    Out.Color = saturate( Out.Color );

    return Out;
}

// �s�N�Z���V�F�[�_
float4 Object_PS(VS_OUTPUT IN) : COLOR0
{
    // �X�y�L�����F�v�Z
    float3 HalfVector = normalize( normalize(IN.Eye) + -LightDirection );
    float3 Specular = pow( max(0,dot( HalfVector, normalize(IN.Normal) )), SpecularPower ) * SpecularColor;

    float4 Color = IN.Color;

    // �X�y�L�����K�p
    Color.rgb += Specular;

    return Color;
}


////////////////////////////////////////////////////////////////////////////////////////////////
// �e�N�j�b�N

technique MainTec0 < string MMDPass = "object";
    string Script = 
        "RenderColorTarget0=Butterfly_PotentialTex;"
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
    pass DrawObject
    {
        VertexShader = compile vs_2_0 Object_VS();
        PixelShader  = compile ps_2_0 Object_PS();
    }
}

