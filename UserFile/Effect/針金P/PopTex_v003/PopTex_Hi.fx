////////////////////////////////////////////////////////////////////////////////////////////////
//
//  PopTex.fx ver0.0.3  �e�N�X�`���摜�𐷂�グ�Ă���C�Ղ��Ղ�񂳂��܂��D
//  �쐬: �j��P( ���͉��P����full.fx���� )
//
////////////////////////////////////////////////////////////////////////////////////////////////
// �����̃p�����[�^��ύX���Ă�������
#define TexFile     "pudding.png"         // ��ʂɓ\��t����e�N�X�`���t�@�C����
#define HeightFile  "puddingHeight.png"   // �����}�b�v�e�N�X�`���t�@�C����
#define ElasticFile "puddingSoft.png"     // ��x�}�b�v�e�N�X�`���t�@�C����

float RectSlace = 1.0;   // �摜�̏c����

float HeightScale = 1.0;      // �����X�P�[��
float ElasticScale = 1000.0;  // �e���X�P�[��
float ViscosityScale = 20.0;  // �S���X�P�[��

#define MappingType  0  // �}�b�s���O�Ɏg���l 0:�O���[�X�P�[�����蓖��,1:���l�����蓖��

// ����Ȃ��l�͂������牺�͂�����Ȃ��ł�
////////////////////////////////////////////////////////////////////////////////////////////////
// �p�����[�^�錾

// ���f�����_���iX�t�@�C���ƘA�����Ă���̂ŁA�ύX�s�j
#define VERTEX_WIDTH   256
#define VERTEX_HEIGHT  256

static float XRate = ((float)VERTEX_WIDTH - 1.0f)/(float)VERTEX_WIDTH;
static float YRate = ((float)VERTEX_HEIGHT - 1.0f)/(float)VERTEX_HEIGHT;
static float XStep = 1.0f/(float)VERTEX_WIDTH;
static float YStep = 1.0f/(float)VERTEX_HEIGHT;

// PMD�p�����[�^
float PmdHeight : CONTROLOBJECT < string name = "PopTexControl.pmd"; string item = "����"; >;
float PmdSoft : CONTROLOBJECT < string name = "PopTexControl.pmd"; string item = "�_�炩��"; >;
float PmdElastic : CONTROLOBJECT < string name = "PopTexControl.pmd"; string item = "�e��"; >;
float PmdViscosity : CONTROLOBJECT < string name = "PopTexControl.pmd"; string item = "�S��"; >;
static float Height = PmdHeight*HeightScale;
static float Soft = PmdSoft;
static float Elastic = PmdElastic*ElasticScale;
static float Viscosity = PmdViscosity*ViscosityScale;


// ���W�ϊ��s��
float4x4 WorldMatrix         : WORLD;
float4x4 ViewMatrix          : VIEW;
float4x4 ProjMatrix          : PROJECTION;
float4x4 ViewProjMatrix      : VIEWPROJECTION;
float4x4 LightViewProjMatrix : VIEWPROJECTION < string Object = "Light"; >;

float3   LightDirection    : DIRECTION < string Object = "Light"; >;
float3   CameraPosition    : POSITION  < string Object = "Camera"; >;

// �}�e���A���F
float4   MaterialDiffuse   : DIFFUSE  < string Object = "Geometry"; >;
float3   MaterialAmbient   : AMBIENT  < string Object = "Geometry"; >;
float3   MaterialEmmisive  : EMISSIVE < string Object = "Geometry"; >;
float3   MaterialSpecular  : SPECULAR < string Object = "Geometry"; >;
float    SpecularPower     : SPECULARPOWER < string Object = "Geometry"; >;
float4   GroundShadowColor : GROUNDSHADOWCOLOR;

// ���C�g�F
#ifndef MIKUMIKUMOVING
float3 LightDiffuse      : DIFFUSE  < string Object = "Light"; >;
float3 LightAmbient      : AMBIENT  < string Object = "Light"; >;
float3 LightSpecular     : SPECULAR < string Object = "Light"; >;
static float4 DiffuseColor  = MaterialDiffuse  * float4(LightDiffuse, 1.0f);
static float3 AmbientColor  = MaterialAmbient  * LightAmbient + MaterialEmmisive;
static float3 SpecularColor = MaterialSpecular * LightSpecular;
#else
float3 LightDiffuses[MMM_LightCount]   : LIGHTDIFFUSECOLORS;
float3 LightAmbients[MMM_LightCount]   : LIGHTAMBIENTCOLORS;
float3 LightSpeculars[MMM_LightCount]  : LIGHTSPECULARCOLORS;
static float4 DiffuseColor = MaterialDiffuse * float4(LightDiffuses[0], 1.0f);
static float3 AmbientColor = MaterialAmbient * LightAmbients[0] + MaterialEmmisive*1.3f;
static float3 SpecularColor = MaterialSpecular * LightSpeculars[0] * 0.1f;
#endif

bool     parthf;   // �p�[�X�y�N�e�B�u�t���O
bool     transp;   // �������t���O
bool	 spadd;    // �X�t�B�A�}�b�v���Z�����t���O
#define SKII1    1500
#define SKII2    8000

// ��ʂɓ\��t����e�N�X�`��
texture2D screen_tex <
    string ResourceName = TexFile;
    int MipLevels = 0;
>;
sampler TexSampler = sampler_state {
    texture = <screen_tex>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = LINEAR;
    AddressU  = CLAMP;
    AddressV = CLAMP;
};

// ���������L�^�����e�N�X�`��
texture2D screen_height <
    string ResourceName = HeightFile;
    int MipLevels = 1;
>;
sampler HeightSampler = sampler_state {
    texture = <screen_height>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = NONE;
    AddressU  = CLAMP;
    AddressV = CLAMP;
};

// �e�������L�^�����e�N�X�`��
texture2D screen_elastic <
    string ResourceName = ElasticFile;
    int MipLevels = 1;
>;
sampler ElasticSampler = sampler_state {
    texture = <screen_elastic>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = NONE;
    AddressU  = CLAMP;
    AddressV = CLAMP;
};

// ���ʂ̐[�x�X�e���V���o�b�t�@
texture DepthBuffer : RenderDepthStencilTarget <
   int Width=VERTEX_WIDTH;
   int Height=VERTEX_HEIGHT;
    string Format = "D24S8";
>;

// �������W�L�^�p
texture VertexBaseTex : RenderColorTarget
<
   int Width=VERTEX_WIDTH;
   int Height=VERTEX_HEIGHT;
   string Format="A32B32G32R32F";
>;
sampler SmpVertexBase = sampler_state
{
   Texture = (VertexBaseTex);
   ADDRESSU = CLAMP;
   ADDRESSV = CLAMP;
   MAGFILTER = NONE;
   MINFILTER = NONE;
   MIPFILTER = NONE;
};

// 1�X�e�b�v�O�̍��W�L�^�p
texture CoordTexOld : RenderColorTarget
<
   int Width=VERTEX_WIDTH;
   int Height=VERTEX_HEIGHT;
   string Format="A32B32G32R32F";
>;
sampler SmpCoordOld = sampler_state
{
   Texture = (CoordTexOld);
   ADDRESSU = CLAMP;
   ADDRESSV = CLAMP;
   MAGFILTER = NONE;
   MINFILTER = NONE;
   MIPFILTER = NONE;
};

// ���݂̍��W�L�^�p
texture CoordTex : RenderColorTarget
<
   int Width=VERTEX_WIDTH;
   int Height=VERTEX_HEIGHT;
   string Format="A32B32G32R32F";
>;
sampler SmpCoord : register(s3) = sampler_state
{
   Texture = (CoordTex);
   ADDRESSU = CLAMP;
   ADDRESSV = CLAMP;
   MAGFILTER = NONE;
   MINFILTER = NONE;
   MIPFILTER = NONE;
};

// ���x�L�^�p
texture VelocityTex : RenderColorTarget
<
   int Width=VERTEX_WIDTH;
   int Height=VERTEX_HEIGHT;
   string Format="A32B32G32R32F";
>;
sampler SmpVelocity = sampler_state
{
   Texture = (VelocityTex);
   ADDRESSU = CLAMP;
   ADDRESSV = CLAMP;
   MAGFILTER = NONE;
   MINFILTER = NONE;
   MIPFILTER = NONE;
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
   Out.texCoord = Tex + float2(0.5f/VERTEX_WIDTH, 0.5f/VERTEX_HEIGHT);
   return Out;
}

////////////////////////////////////////////////////////////////////////////////////////////////
// ������Ԃ̍��W��ݒ�

float4 Base_PS(float2 texCoord: TEXCOORD0) : COLOR
{
   float x = 2.0f*texCoord.x-1.0f;
   float y = (1.0f-2.0f*texCoord.y) * RectSlace;

   texCoord += float2(0.5f/VERTEX_WIDTH, 0.5f/VERTEX_HEIGHT);
   float4 h = tex2D(HeightSampler, texCoord);
#if( MappingType==0 )
   float v = -(1.0f - (h.r + h.g + h.b) * 0.33333333) * Height;
#else
   float v = -h.a * Height;
#endif

   float4 Pos = float4(x, y, v, 1.0f);
   // �{�[���ɘA�������邽�߃��[���h���W�ŊǗ�����
   Pos = mul( Pos, WorldMatrix );

   return Pos;
}

////////////////////////////////////////////////////////////////////////////////////////////////
// �v�Z���W���N���A

float4 Clear_PS(float2 texCoord: TEXCOORD0) : COLOR
{
   float4 Pos;
   if( time < 0.001f){
      // 0�t���[���Đ��Ń��Z�b�g
      Pos = tex2D(SmpVertexBase, texCoord);
   }else{
      Pos = tex2D(SmpCoord, texCoord);
   }

   return Pos;
}

////////////////////////////////////////////////////////////////////////////////////////////////
// ���x�̌v�Z

float4 Velocity_PS(float2 texCoord: TEXCOORD0) : COLOR
{
   float4 vel = float4(0,0,0,0);
   if( time > 0.001f){
      float4 Pos1 = tex2D(SmpCoordOld, texCoord);
      float4 Pos2 = tex2D(SmpCoord, texCoord);
      vel = ( Pos2 - Pos1 )/Dt;
   }

   return vel;
}

////////////////////////////////////////////////////////////////////////////////////////////////
// �����W�l��1�X�e�b�v�O�̍��W�ɃR�s�[

float4 PosCopy_PS(float2 texCoord: TEXCOORD0) : COLOR
{
   float4 Pos = tex2D(SmpCoord, texCoord);
   return Pos;
}


////////////////////////////////////////////////////////////////////////////////////////////////
// �����W�l�𕨗��v�Z�ōX�V

float4 PosPhysics_PS(float2 texCoord: TEXCOORD0) : COLOR
{
    // ��ʒu
    float4 Pos0 = tex2D(SmpVertexBase, texCoord);
    // 1�X�e�b�v�O�̈ʒu
    float4 Pos1 = tex2D(SmpCoordOld, texCoord);
    // ���x
    float4 Vel = tex2D(SmpVelocity, texCoord);
    // ��x�l
    texCoord += float2(0.5f/VERTEX_WIDTH, 0.5f/VERTEX_HEIGHT);
    float4 e = tex2D(ElasticSampler, texCoord);
#if( MappingType==0 )
    float v = 1.0f - (e.r + e.g + e.b)*0.33333333;
#else
    float v = e.a;
#endif

    // �����x�v�Z
    float4 Accel = (Pos0 - Pos1) * v * Elastic - Viscosity * Vel;

    // �V�������W�ɍX�V
    float4 Pos = Pos1 + Dt * (Vel + Dt * Accel);

    // �{�[���Ǐ]�x
    Pos = lerp(Pos0, Pos, pow(v*Soft, 0.03));

    return Pos;
}

////////////////////////////////////////////////////////////////////////////////////////////////

struct VS_TRANS {
    float4 Pos;    // ���_���W
    float3 Normal; // ���_�@��
};

// ���_�̍��W��@�����擾
VS_TRANS TransPos(float4 Pos)
{
   VS_TRANS Out = (VS_TRANS)0;

   // ���_���W���i�[����Ă���e�N�X�`���̍��W
   float x = 0.5f*(Pos.x * XRate + 1.0f);
   float y = 0.5f*(Pos.y * YRate + 1.0f);

   // �אڂ��钸�_���W���i�[����Ă���e�N�X�`���̍��W
   float x1 = x - XStep;
   float x2 = x + XStep;
   float y1 = y - YStep;
   float y2 = y + YStep;

   // ���_���[���h���W���擾
   Out.Pos = float4(tex2Dlod(SmpCoord, float4(x, y, 0, 0)).xyz, 1);

   // ���_�@���̌v�Z
   float4 PosX1 = tex2Dlod(SmpCoord, float4(x1, y, 0, 0));
   float4 PosX2 = tex2Dlod(SmpCoord, float4(x2, y, 0, 0));
   float4 PosY1 = tex2Dlod(SmpCoord, float4(x, y1, 0, 0));
   float4 PosY2 = tex2Dlod(SmpCoord, float4(x, y2, 0, 0));
   float3 vx = (float3)(PosX2 - PosX1);
   float3 vy = (float3)(PosY2 - PosY1);
   Out.Normal = cross(vx, vy);
//   Out.Normal = cross(vy, vx);

   return Out;
}

///////////////////////////////////////////////////////////////////////////////////////////////
// �e�i��Z���t�V���h�E�j�`��

// ���_�V�F�[�_
float4 Shadow_VS(float4 Pos : POSITION) : POSITION
{
    // ���_�̃��[���h���W��@�����擾
    VS_TRANS Tr = TransPos(Pos);

    // �����̉��ʒu(���s�����Ȃ̂�)
    float3 LightPos = (float3)Tr.Pos + LightDirection;

    // �n�ʂɓ��e
    float3 PlanarPos = float3(0, 0.1, 0);
    float3 PlanarNormal = float3(0, 1, 0);
    float a = dot(PlanarNormal, PlanarPos - LightPos);
    float b = dot(PlanarNormal, Tr.Pos.xyz - PlanarPos);
    float c = dot(PlanarNormal, Tr.Pos.xyz - LightPos);
    Pos = float4(Tr.Pos.xyz * a + LightPos * b, c);

    // �J�������_�̃r���[�ˉe�ϊ�
    return mul( Pos, ViewProjMatrix );
}

// �s�N�Z���V�F�[�_
float4 Shadow_PS() : COLOR
{
    // �n�ʉe�F�œh��Ԃ�
    return GroundShadowColor;
}

// �e�`��p�e�N�j�b�N
technique ShadowTec < string MMDPass = "shadow"; > {
    pass DrawShadow {
        #ifdef MIKUMIKUMOVING
        StencilEnable = TRUE;
        StencilRef = 1;
        StencilMask = 0xff;
        StencilFunc = GREATER;
        StencilFail = KEEP;
        StencilZFail = KEEP;
        StencilPass = INCRSAT;
        CullMode = NONE;
        #endif
        VertexShader = compile vs_3_0 Shadow_VS();
        PixelShader  = compile ps_3_0 Shadow_PS();
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////
//MMM�Ή�
#ifndef MIKUMIKUMOVING
    #define GET_VPMAT(p) (ViewProjMatrix)
#else
    #define GET_VPMAT(p) (MMM_IsDinamicProjection ? mul(ViewMatrix, MMM_DynamicFov(ProjMatrix, length(CameraPosition-p.xyz))) : ViewProjMatrix)
#endif

///////////////////////////////////////////////////////////////////////////////////////////////
// �I�u�W�F�N�g�`��i�Z���t�V���h�EOFF�j

struct VS_OUTPUT {
    float4 Pos        : POSITION;    // �ˉe�ϊ����W
    float2 Tex        : TEXCOORD1;   // �e�N�X�`��
    float3 Normal     : TEXCOORD2;   // �@��
    float3 Eye        : TEXCOORD3;   // �J�����Ƃ̑��Έʒu
    float2 SpTex      : TEXCOORD4;   // �X�t�B�A�}�b�v�e�N�X�`�����W
    float4 Color      : COLOR0;      // �f�B�t���[�Y�F
};

// ���_�V�F�[�_
VS_OUTPUT Basic_VS(float4 Pos : POSITION, float3 Normal : NORMAL, float2 Tex : TEXCOORD0)
{
    VS_OUTPUT Out = (VS_OUTPUT)0;

    // ���_�̃��[���h���W��@�����擾
    VS_TRANS Tr = TransPos(Pos);

    // �J�����Ƃ̑��Έʒu
    Out.Eye = CameraPosition - mul( Tr.Pos, WorldMatrix ).xyz;
    // ���_�@��
    Out.Normal = normalize( mul( Tr.Normal, (float3x3)WorldMatrix ) );

    // �J�������_�̃r���[�ˉe�ϊ�
    Out.Pos = mul( Tr.Pos, GET_VPMAT(Tr.Pos) );

    // �f�B�t���[�Y�F�{�A���r�G���g�F �v�Z
    Out.Color.rgb = AmbientColor;
    Out.Color.rgb += max(0,dot( Out.Normal, -LightDirection )) * DiffuseColor.rgb;
    Out.Color.a = DiffuseColor.a;
    Out.Color = saturate( Out.Color );

    // �e�N�X�`�����W
    Out.Tex = Tex;

    return Out;
}

// �s�N�Z���V�F�[�_
float4 Basic_PS(VS_OUTPUT IN) : COLOR0
{
    // �X�y�L�����F�v�Z
    float3 HalfVector = normalize( normalize(IN.Eye) + -LightDirection );
    float3 Specular = pow( max(0,dot( HalfVector, normalize(IN.Normal) )), SpecularPower ) * SpecularColor;

    float4 Color = IN.Color;
    // �e�N�X�`���K�p
    float2 texCoord = float2(IN.Tex.x, 1.0f-IN.Tex.y);
    Color *= tex2D( TexSampler, texCoord );

    // �X�y�L�����K�p
    Color.rgb += Specular;

    return Color;
}

// �I�u�W�F�N�g�`��p�e�N�j�b�N
technique MainTec0 < string MMDPass = "object";
    string Script = 
        "RenderColorTarget0=VertexBaseTex;"
	    "RenderDepthStencilTarget=DepthBuffer;"
	    "Pass=PosBase;"
        "RenderColorTarget0=CoordTex;"
	    "RenderDepthStencilTarget=DepthBuffer;"
	    "Pass=PosClear;"
        "RenderColorTarget0=VelocityTex;"
	    "RenderDepthStencilTarget=DepthBuffer;"
	    "Pass=CalcVelocity;"
        "RenderColorTarget0=CoordTexOld;"
	    "RenderDepthStencilTarget=DepthBuffer;"
	    "Pass=PosCopy;"
        "RenderColorTarget0=CoordTex;"
	    "RenderDepthStencilTarget=DepthBuffer;"
	    "Pass=PosUpdate;"
        #ifdef MIKUMIKUMOVING
        "RenderColorTarget0=TimeTex;"
            "RenderDepthStencilTarget=TimeDepthBuffer;"
            "Pass=UpdateTime;"
        #endif
        "RenderColorTarget0=;"
	    "RenderDepthStencilTarget=;"
	    "Pass=DrawObject;"
    ;
>{
    pass PosBase < string Script = "Draw=Buffer;";>
    {
        ALPHABLENDENABLE = FALSE;
        ALPHATESTENABLE=FALSE;
        VertexShader = compile vs_1_1 Common_VS();
        PixelShader  = compile ps_2_0 Base_PS();
     }
    pass PosClear < string Script = "Draw=Buffer;";>
    {
        ALPHABLENDENABLE = FALSE;
        ALPHATESTENABLE=FALSE;
        VertexShader = compile vs_1_1 Common_VS();
        PixelShader  = compile ps_2_0 Clear_PS();
    }
    pass CalcVelocity < string Script = "Draw=Buffer;";>
    {
        ALPHABLENDENABLE = FALSE;
        ALPHATESTENABLE=FALSE;
        VertexShader = compile vs_1_1 Common_VS();
        PixelShader  = compile ps_2_0 Velocity_PS();
    }
    pass PosCopy < string Script = "Draw=Buffer;";>
    {
        ALPHABLENDENABLE = FALSE;
        ALPHATESTENABLE=FALSE;
        VertexShader = compile vs_1_1 Common_VS();
        PixelShader  = compile ps_2_0 PosCopy_PS();
    }
    pass PosUpdate < string Script = "Draw=Buffer;";>
    {
        ALPHABLENDENABLE = FALSE;
        ALPHATESTENABLE=FALSE;
        VertexShader = compile vs_1_1 Common_VS();
        PixelShader  = compile ps_2_0 PosPhysics_PS();
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
        ZEnable = TRUE;
        CullMode = NONE;
        VertexShader = compile vs_3_0 Basic_VS();
        PixelShader  = compile ps_3_0 Basic_PS();
    }
}

#ifndef MIKUMIKUMOVING
///////////////////////////////////////////////////////////////////////////////////////////////
// �Z���t�V���h�E�pZ�l�v���b�g

struct VS_ZValuePlot_OUTPUT {
    float4 Pos : POSITION;              // �ˉe�ϊ����W
    float4 ShadowMapTex : TEXCOORD0;    // Z�o�b�t�@�e�N�X�`��
};

// ���_�V�F�[�_
VS_ZValuePlot_OUTPUT ZValuePlot_VS( float4 Pos : POSITION )
{
    VS_ZValuePlot_OUTPUT Out = (VS_ZValuePlot_OUTPUT)0;

    // ���_�̃��[���h���W��@�����擾
    VS_TRANS Tr = TransPos(Pos);
    // ���C�g�̖ڐ��ɂ��r���[�ˉe�ϊ�������
    Out.Pos = mul( Tr.Pos, LightViewProjMatrix );

    // �e�N�X�`�����W�𒸓_�ɍ��킹��
    Out.ShadowMapTex = Out.Pos;

    return Out;
}

// �s�N�Z���V�F�[�_
float4 ZValuePlot_PS( float4 ShadowMapTex : TEXCOORD0 ) : COLOR
{
    // R�F������Z�l���L�^����
    return float4(ShadowMapTex.z/ShadowMapTex.w,0,0,1);
}

// Z�l�v���b�g�p�e�N�j�b�N
technique ZplotTec < string MMDPass = "zplot"; > {
    pass ZValuePlot {
        AlphaBlendEnable = FALSE;
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
    float2 SpTex    : TEXCOORD4;    // �X�t�B�A�}�b�v�e�N�X�`�����W
    float4 Color    : COLOR0;       // �f�B�t���[�Y�F
};

// ���_�V�F�[�_
BufferShadow_OUTPUT BufferShadow_VS(float4 Pos : POSITION, float3 Normal : NORMAL, float2 Tex : TEXCOORD0)
{
    BufferShadow_OUTPUT Out = (BufferShadow_OUTPUT)0;

    // ���_�̃��[���h���W��@�����擾
    VS_TRANS Tr = TransPos(Pos);

    // �J�������_�̃r���[�ˉe�ϊ�
    Out.Pos = mul( Tr.Pos, ViewProjMatrix );

    // �J�����Ƃ̑��Έʒu
    Out.Eye = CameraPosition - mul( Tr.Pos, WorldMatrix ).xyz;
    // ���_�@��
    Out.Normal = normalize( mul( Tr.Normal, (float3x3)WorldMatrix ) );
    // ���C�g���_�ɂ��r���[�ˉe�ϊ�
    Out.ZCalcTex = mul( Tr.Pos, LightViewProjMatrix );

    // �f�B�t���[�Y�F�{�A���r�G���g�F �v�Z
    Out.Color.rgb = AmbientColor;
    Out.Color.rgb += max(0,dot( Out.Normal, -LightDirection )) * DiffuseColor.rgb;
    Out.Color.a = DiffuseColor.a;
    Out.Color = saturate( Out.Color );

    // �e�N�X�`�����W
    Out.Tex = Tex;

    return Out;
}

// �s�N�Z���V�F�[�_
float4 BufferShadow_PS(BufferShadow_OUTPUT IN) : COLOR
{
    // �X�y�L�����F�v�Z
    float3 HalfVector = normalize( normalize(IN.Eye) + -LightDirection );
    float3 Specular = pow( max(0,dot( HalfVector, normalize(IN.Normal) )), SpecularPower ) * SpecularColor;

    float4 Color = IN.Color;
    float4 ShadowColor = float4(AmbientColor, Color.a);  // �e�̐F
    // �e�N�X�`���K�p
    float2 texCoord = float2(IN.Tex.x, 1.0f-IN.Tex.y);
    float4 TexColor = tex2D( TexSampler, texCoord );
    Color *= TexColor;
    ShadowColor *= TexColor;
    // �X�y�L�����K�p
    Color.rgb += Specular;

    // �e�N�X�`�����W�ɕϊ�
    IN.ZCalcTex /= IN.ZCalcTex.w;
    float2 TransTexCoord;
    TransTexCoord.x = (1.0f + IN.ZCalcTex.x)*0.5f;
    TransTexCoord.y = (1.0f - IN.ZCalcTex.y)*0.5f;

    if( any( saturate(TransTexCoord) != TransTexCoord ) ) {
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
}

// �I�u�W�F�N�g�`��p�e�N�j�b�N
technique MainTecBS0  < string MMDPass = "object_ss";
    string Script = 
        "RenderColorTarget0=VertexBaseTex;"
	    "RenderDepthStencilTarget=DepthBuffer;"
	    "Pass=PosBase;"
        "RenderColorTarget0=CoordTex;"
	    "RenderDepthStencilTarget=DepthBuffer;"
	    "Pass=PosClear;"
        "RenderColorTarget0=VelocityTex;"
	    "RenderDepthStencilTarget=DepthBuffer;"
	    "Pass=CalcVelocity;"
        "RenderColorTarget0=CoordTexOld;"
	    "RenderDepthStencilTarget=DepthBuffer;"
	    "Pass=PosCopy;"
        "RenderColorTarget0=CoordTex;"
	    "RenderDepthStencilTarget=DepthBuffer;"
	    "Pass=PosUpdate;"
        "RenderColorTarget0=;"
	    "RenderDepthStencilTarget=;"
	    "Pass=DrawObject;"
    ;
>{
    pass PosBase < string Script = "Draw=Buffer;";>
    {
        ALPHABLENDENABLE = FALSE;
        ALPHATESTENABLE=FALSE;
        VertexShader = compile vs_1_1 Common_VS();
        PixelShader  = compile ps_2_0 Base_PS();
     }
    pass PosClear < string Script = "Draw=Buffer;";>
    {
        ALPHABLENDENABLE = FALSE;
        ALPHATESTENABLE=FALSE;
        VertexShader = compile vs_1_1 Common_VS();
        PixelShader  = compile ps_2_0 Clear_PS();
    }
    pass CalcVelocity < string Script = "Draw=Buffer;";>
    {
        ALPHABLENDENABLE = FALSE;
        ALPHATESTENABLE=FALSE;
        VertexShader = compile vs_1_1 Common_VS();
        PixelShader  = compile ps_2_0 Velocity_PS();
    }
    pass PosCopy < string Script = "Draw=Buffer;";>
    {
        ALPHABLENDENABLE = FALSE;
        ALPHATESTENABLE=FALSE;
        VertexShader = compile vs_1_1 Common_VS();
        PixelShader  = compile ps_2_0 PosCopy_PS();
    }
    pass PosUpdate < string Script = "Draw=Buffer;";>
    {
        ALPHABLENDENABLE = FALSE;
        ALPHATESTENABLE=FALSE;
        VertexShader = compile vs_1_1 Common_VS();
        PixelShader  = compile ps_2_0 PosPhysics_PS();
    }
    pass DrawObject {
        CullMode = NONE;
        VertexShader = compile vs_3_0 BufferShadow_VS();
        PixelShader  = compile ps_3_0 BufferShadow_PS();
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////
#endif

