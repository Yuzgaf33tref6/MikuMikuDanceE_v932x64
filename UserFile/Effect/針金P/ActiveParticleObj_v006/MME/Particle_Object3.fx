////////////////////////////////////////////////////////////////////////////////////////////////
//
//  Particle_Object.fx  �I�u�W�F�N�g���ړ����Ă��鎞�����������f���𗱎q�ɂ��ĕ��o
//   (ActiveParticleObj.fx�ƈꏏ�Ɏg�p,�������f���ɓK�p����)
//  �쐬: �j��P
//
////////////////////////////////////////////////////////////////////////////////////////////////
// �����̃p�����[�^��ύX���Ă�������

int RepertCount = 1000;  // ���f��������(�ő�4096�܂�)

#define SHADOW_ON  0        // ��Z���t�V���h�E�n�ʉe�`�� 0:���Ȃ�,1:����

#define EDGE_ON_MAT   "0-"      // �G�b�W��`�悷��ގ��ԍ�
float EdgeThickness = 1.0;  // �G�b�W�̑���

// ���q�I�u�W�F�N�gID�ԍ�
#define  ObjectNo  3   // 0�`3�ȊO�ŐV���ɗ��q�I�u�W�F�N�g�𑝂₷�ꍇ�̓t�@�C�����ύX�Ƃ��̒l��4,5,6���ƕς��Ă���


// ����Ȃ��l�͂������牺�͂�����Ȃ��ł�
////////////////////////////////////////////////////////////////////////////////////////////////

#define LOOPSCRIPT_OBJECT       "LoopByCount=RepertCount; LoopGetIndex=RepertIndex; Pass=DrawObject; LoopEnd=;"
#define LOOPSCRIPT_OBJECT_EDGE  "LoopByCount=RepertCount; LoopGetIndex=RepertIndex; Pass=DrawObject; Pass=DrawEdge; LoopEnd=;"
#define LOOPSCRIPT_EDGE         "LoopByCount=RepertCount; LoopGetIndex=RepertIndex; Pass=DrawEdge; LoopEnd=;"
#define LOOPSCRIPT_SHADOW       "LoopByCount=RepertCount; LoopGetIndex=RepertIndex; Pass=DrawShadow; LoopEnd=;"
#define LOOPSCRIPT_ZPLOT        "LoopByCount=RepertCount; LoopGetIndex=RepertIndex; Pass=ZValuePlot; LoopEnd=;"

#define  WorldMatrixTexName(n)  ActiveParticle_WorldMatrixTex##n   // ���[���h���W�L�^�p�e�N�X�`����

int RepertIndex;  // �������f���J�E���^

#define TEX_WIDTH_W   16  // ���q���[���h���W�e�N�X�`���s�N�Z����
#define TEX_HEIGHT  1024  // ���q���[���h���W�e�N�X�`���s�N�Z������

// ���W�ϊ��s��
float4x4 WorldViewProjMatrix : WORLDVIEWPROJECTION;
float4x4 ViewProjMatrix      : VIEWPROJECTION;
float4x4 WorldMatrix         : WORLD;
float4x4 ViewMatrix          : VIEW;
float4x4 ProjMatrix          : PROJECTION;
float4x4 LightViewProjMatrix : VIEWPROJECTION < string Object = "Light"; >;

float3 LightDirection    : DIRECTION < string Object = "Light"; >;
float3 CameraPosition    : POSITION  < string Object = "Camera"; >;

// �}�e���A���F
float4 MaterialDiffuse   : DIFFUSE  < string Object = "Geometry"; >;
float3 MaterialAmbient   : AMBIENT  < string Object = "Geometry"; >;
float3 MaterialEmmisive  : EMISSIVE < string Object = "Geometry"; >;
float3 MaterialSpecular  : SPECULAR < string Object = "Geometry"; >;
float  SpecularPower     : SPECULARPOWER < string Object = "Geometry"; >;
float3 MaterialToon      : TOONCOLOR;
float4 EdgeColor         : EDGECOLOR;
float4 GroundShadowColor : GROUNDSHADOWCOLOR;
// ���C�g�F
float3 LightDiffuse      : DIFFUSE  < string Object = "Light"; >;
float3 LightAmbient      : AMBIENT  < string Object = "Light"; >;
float3 LightSpecular     : SPECULAR < string Object = "Light"; >;
static float4 DiffuseColor  = MaterialDiffuse  * float4(LightDiffuse, 1.0f);
static float3 AmbientColor  = MaterialAmbient  * LightAmbient + MaterialEmmisive;
static float3 SpecularColor = MaterialSpecular * LightSpecular;

// �e�N�X�`���ގ����[�t�l
float4 TextureAddValue : ADDINGTEXTURE;
float4 TextureMulValue : MULTIPLYINGTEXTURE;
float4 SphereAddValue  : ADDINGSPHERETEXTURE;
float4 SphereMulValue  : MULTIPLYINGSPHERETEXTURE;

bool parthf;   // �p�[�X�y�N�e�B�u�t���O
bool transp;   // �������t���O
bool spadd;    // �X�t�B�A�}�b�v���Z�����t���O
#define SKII1    1500
#define SKII2    8000
#define Toon     3

bool use_subtexture;    // �T�u�e�N�X�`���t���O

// �I�u�W�F�N�g�̃e�N�X�`��
texture ObjectTexture : MATERIALTEXTURE;
sampler ObjTexSampler = sampler_state {
    texture = <ObjectTexture>;
    MINFILTER = LINEAR;
    MAGFILTER = LINEAR;
    MIPFILTER = LINEAR;
    ADDRESSU  = WRAP;
    ADDRESSV  = WRAP;
};

// �X�t�B�A�}�b�v�̃e�N�X�`��
texture ObjectSphereMap : MATERIALSPHEREMAP;
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

// ���q�̃��[���h�ϊ��s�񂪋L�^����Ă���e�N�X�`��
shared texture WorldMatrixTexName(ObjectNo) : RenderColorTarget;
sampler ActiveParticle_SmpWldMat : register(s3) = sampler_state
{
    Texture = <WorldMatrixTexName(ObjectNo)>;
    ADDRESSU = CLAMP;
    ADDRESSV = CLAMP;
    MAGFILTER = NONE;
    MINFILTER = NONE;
    MIPFILTER = NONE;
};

////////////////////////////////////////////////////////////////////////////////////////////////
// ���f���̔z�u�ϊ��s��(�z�u��̃��[���h�ϊ��s��)
float4x4 SetTransMatrix(out float alpha)
{
    int i = (RepertIndex / TEX_HEIGHT) * 4;
    int j = RepertIndex % TEX_HEIGHT;
    float y = (j+0.5f)/TEX_HEIGHT;

    // ���f���̔z�u�ϊ��s��
    float4x4 TrMat = float4x4( tex2Dlod(ActiveParticle_SmpWldMat, float4((i+0.5f)/TEX_WIDTH_W, y, 0, 0)), 
                               tex2Dlod(ActiveParticle_SmpWldMat, float4((i+1.5f)/TEX_WIDTH_W, y, 0, 0)), 
                               tex2Dlod(ActiveParticle_SmpWldMat, float4((i+2.5f)/TEX_WIDTH_W, y, 0, 0)), 
                               tex2Dlod(ActiveParticle_SmpWldMat, float4((i+3.5f)/TEX_WIDTH_W, y, 0, 0)) );

    alpha = TrMat._44;
    TrMat._44 = 1.0f;

    return TrMat;
}

////////////////////////////////////////////////////////////////////////////////////////////////
// �֊s�`��

struct VS_OUTPUT2 {
    float4 Pos        : POSITION;    // �ˉe�ϊ����W
    float4 Color      : COLOR0;      // alpha�l
};

// ���_�V�F�[�_
VS_OUTPUT2 Edge_VS(float4 Pos : POSITION, float3 Normal : NORMAL)
{
    VS_OUTPUT2 Out = (VS_OUTPUT2)0;

    // �f�ރ��f���̃��[���h���W�ϊ�
    Pos = mul( Pos, WorldMatrix );

    // ���[���h���W�ϊ��ɂ�钸�_�@��
    Normal = mul( Normal, (float3x3)WorldMatrix );

    // �������f���̔z�u���W�ϊ�
    float alpha;
    float4x4 TransMatrix = SetTransMatrix(alpha);
    Pos = mul( Pos, TransMatrix );

    // �z�u���W�ϊ��ɂ�钸�_�@��
    Normal = normalize( mul( Normal, (float3x3)TransMatrix ) );

    // �J�����Ƃ̋���
    float len = max( length( CameraPosition - Pos ), 5.0f );

    // ���_��@�������ɉ����o��
    if(ProjMatrix._44 < 0.5f){
        // �p�[�X�y�N�e�B�uon
        Pos.xyz += Normal * ( EdgeThickness * pow( len, 0.9f ) * 0.0015f * pow(2.4142f / ProjMatrix._22, 0.7f) );
    }else{
        // �p�[�X�y�N�e�B�uoff
        Pos.xyz += Normal * ( EdgeThickness * 0.0025f / ProjMatrix._11 );
    }

    // �J�������_�̃r���[�ˉe�ϊ�
    Out.Pos = mul( Pos, ViewProjMatrix );

    // ���f����alpha�l
    Out.Color = float4(1.0f, 1.0f, 1.0f, alpha);

    return Out;
}

// �s�N�Z���V�F�[�_
float4 Edge_PS(VS_OUTPUT2 IN) : COLOR
{
    clip(IN.Color.a-0.001f);

    // �֊s�F�œh��Ԃ�
    return (EdgeColor*IN.Color);
}

// �I�u�W�F�N�g�`��e�N�j�b�N�� EdgeColor ���擾���邽�߂̃_�~�[����
// ���_�V�F�[�_
float4 DummyEdge_VS(float4 Pos : POSITION) : POSITION 
{
    return float4(0,0,0,0);
}
// �s�N�Z���V�F�[�_
float4 DummyEdge_PS() : COLOR
{
    return float4(0,0,0,0);
}
// �֊s�`��p�e�N�j�b�N
technique EdgeTec < string MMDPass = "edge"; > {
    pass DrawEdge {
        VertexShader = compile vs_2_0 DummyEdge_VS();
        PixelShader  = compile ps_2_0 DummyEdge_PS();
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////
// ��Z���t�V���h�E�n�ʉe�`��

#if(SHADOW_ON==1)
// ���_�V�F�[�_
VS_OUTPUT2 Shadow_VS(float4 Pos : POSITION)
{
    VS_OUTPUT2 Out = (VS_OUTPUT2)0;

    // �������f���̔z�u���W�ϊ�
    float alpha;
    float4x4 TransMatrix = SetTransMatrix(alpha);
    Pos =  mul( Pos, TransMatrix );

    // �J�������_�̃r���[�ˉe�ϊ�
    Out.Pos = mul( Pos, ViewProjMatrix );

    // ���f����alpha�l
    Out.Color = float4(1.0f, 1.0f, 1.0f, alpha);

    return Out;
}

// �s�N�Z���V�F�[�_
float4 Shadow_PS(VS_OUTPUT2 IN) : COLOR
{
    clip(IN.Color.a-0.001f);

    // �n�ʉe�F�œh��Ԃ�
    return (GroundShadowColor*IN.Color);
}

// �e�`��p�e�N�j�b�N
technique ShadowTec < string MMDPass = "shadow"; string Script = LOOPSCRIPT_SHADOW; >
{
    pass DrawShadow {
        VertexShader = compile vs_3_0 Shadow_VS();
        PixelShader  = compile ps_3_0 Shadow_PS();
    }
}

#else
technique ShadowTec < string MMDPass = "shadow"; >{ }
#endif

///////////////////////////////////////////////////////////////////////////////////////////////
// �I�u�W�F�N�g�`��i�Z���t�V���h�EOFF�j

struct VS_OUTPUT {
    float4 Pos     : POSITION;    // �ˉe�ϊ����W
    float2 Tex     : TEXCOORD1;   // �e�N�X�`��
    float3 Normal  : TEXCOORD2;   // �@��
    float3 Eye     : TEXCOORD3;   // �J�����Ƃ̑��Έʒu
    float2 SpTex   : TEXCOORD4;   // �X�t�B�A�}�b�v�e�N�X�`�����W
    float4 Color   : COLOR0;      // �f�B�t���[�Y�F
};

// ���_�V�F�[�_
VS_OUTPUT Basic_VS(float4 Pos : POSITION, float3 Normal : NORMAL, float2 Tex : TEXCOORD0, float2 Tex2 : TEXCOORD1, uniform bool useTexture, uniform bool useSphereMap, uniform bool useToon)
{
    VS_OUTPUT Out = (VS_OUTPUT)0;

    // �f�ރ��f���̃��[���h���W�ϊ�
    Pos = mul( Pos, WorldMatrix );

    // ���[���h���W�ϊ��ɂ�钸�_�@��
    Normal = mul( Normal, (float3x3)WorldMatrix );

    // �������f���̔z�u���W�ϊ�
    float alpha;
    float4x4 TransMatrix = SetTransMatrix(alpha);
    Pos = mul( Pos, TransMatrix );

    // �z�u���W�ϊ��ɂ�钸�_�@��
    Out.Normal = normalize( mul( Normal, (float3x3)TransMatrix ) );

    // �J�������_�̃r���[�ˉe�ϊ�
    Out.Pos = mul( Pos, ViewProjMatrix );

    // �J�����Ƃ̑��Έʒu
    Out.Eye = CameraPosition - Pos.xyz;

    // �f�B�t���[�Y�F�{�A���r�G���g�F �v�Z
    Out.Color.rgb = AmbientColor;
    if ( !useToon ) {
        Out.Color.rgb += max(0,dot( Out.Normal, -LightDirection )) * DiffuseColor.rgb;
    }
    Out.Color.a = DiffuseColor.a * alpha;
    Out.Color = saturate( Out.Color );

    // �e�N�X�`�����W
    Out.Tex = Tex;

    if ( useSphereMap ) {
        if( use_subtexture ) {
            // PMX�T�u�e�N�X�`�����W
            Out.SpTex = Tex2;
        } else {
            // �X�t�B�A�}�b�v�e�N�X�`�����W
            float2 NormalWV = mul( Out.Normal, (float3x3)ViewMatrix ).xy;
            Out.SpTex.x = NormalWV.x * 0.5f + 0.5f;
            Out.SpTex.y = NormalWV.y * -0.5f + 0.5f;
        }
    }

    return Out;
}

// �s�N�Z���V�F�[�_
float4 Basic_PS(VS_OUTPUT IN, uniform bool useTexture, uniform bool useSphereMap, uniform bool useToon) : COLOR0
{
    clip(IN.Color.a-0.001f);

    // �X�y�L�����F�v�Z
    float3 HalfVector = normalize( normalize(IN.Eye) + -LightDirection );
    float3 Specular = pow( max(0,dot( HalfVector, normalize(IN.Normal) )), SpecularPower ) * SpecularColor;

    float4 Color = IN.Color;
    if ( useTexture ) {
        // �e�N�X�`���K�p
        Color *= tex2D( ObjTexSampler, IN.Tex );
    }
    if ( useSphereMap ) {
        // �X�t�B�A�}�b�v�K�p
        float4 TexColor = tex2D(ObjSphareSampler,IN.SpTex);
        if(spadd) Color.rgb += TexColor.rgb;
        else      Color.rgb *= TexColor.rgb;
        Color.a *= TexColor.a;
    }

    if ( useToon ) {
        // �g�D�[���K�p
        float LightNormal = dot( IN.Normal, -LightDirection );
        Color *= tex2D( ObjToonSampler, float2(0.0f, 0.5f-LightNormal*0.5f) );
    }

    // �X�y�L�����K�p
    Color.rgb += Specular;

    return Color;
}

// �I�u�W�F�N�g�`��p�e�N�j�b�N�i�A�N�Z�T���p�j
technique MainTec0 < string MMDPass = "object"; bool UseTexture = false; bool UseSphereMap = false; bool UseToon = false;
                     string Script = LOOPSCRIPT_OBJECT; >
{
    pass DrawObject {
        VertexShader = compile vs_3_0 Basic_VS(false, false, false);
        PixelShader  = compile ps_3_0 Basic_PS(false, false, false);
    }
}

technique MainTec1 < string MMDPass = "object"; bool UseTexture = true; bool UseSphereMap = false; bool UseToon = false;
                     string Script = LOOPSCRIPT_OBJECT; >
{
    pass DrawObject {
        VertexShader = compile vs_3_0 Basic_VS(true, false, false);
        PixelShader  = compile ps_3_0 Basic_PS(true, false, false);
    }
}

technique MainTec2 < string MMDPass = "object"; bool UseTexture = false; bool UseSphereMap = true; bool UseToon = false;
                     string Script = LOOPSCRIPT_OBJECT; >
{
    pass DrawObject {
        VertexShader = compile vs_3_0 Basic_VS(false, true, false);
        PixelShader  = compile ps_3_0 Basic_PS(false, true, false);
    }
}

technique MainTec3 < string MMDPass = "object"; bool UseTexture = true; bool UseSphereMap = true; bool UseToon = false;
                     string Script = LOOPSCRIPT_OBJECT; >
{
    pass DrawObject {
        VertexShader = compile vs_3_0 Basic_VS(true, true, false);
        PixelShader  = compile ps_3_0 Basic_PS(true, true, false);
    }
}

// �I�u�W�F�N�g�`��p�e�N�j�b�N�iPMD���f���p,�G�b�W�L��j
technique MainTec4 < string MMDPass = "object";  string Subset = EDGE_ON_MAT;
                     bool UseTexture = false; bool UseSphereMap = false; bool UseToon = true;
                     string Script = LOOPSCRIPT_OBJECT_EDGE; >
{
    pass DrawObject {
        VertexShader = compile vs_3_0 Basic_VS(false, false, true);
        PixelShader  = compile ps_3_0 Basic_PS(false, false, true);
    }
    pass DrawEdge {
        CullMode = CW;
        VertexShader = compile vs_3_0 Edge_VS();
        PixelShader  = compile ps_3_0 Edge_PS();
    }
}

technique MainTec5 < string MMDPass = "object"; string Subset = EDGE_ON_MAT;
                     bool UseTexture = true; bool UseSphereMap = false; bool UseToon = true;
                     string Script = LOOPSCRIPT_OBJECT_EDGE; >
{
    pass DrawObject {
        VertexShader = compile vs_3_0 Basic_VS(true, false, true);
        PixelShader  = compile ps_3_0 Basic_PS(true, false, true);
    }
    pass DrawEdge {
        CullMode = CW;
        VertexShader = compile vs_3_0 Edge_VS();
        PixelShader  = compile ps_3_0 Edge_PS();
    }
}

technique MainTec6 < string MMDPass = "object"; string Subset = EDGE_ON_MAT;
                     bool UseTexture = false; bool UseSphereMap = true; bool UseToon = true;
                     string Script = LOOPSCRIPT_OBJECT_EDGE; >
{
    pass DrawObject {
        VertexShader = compile vs_3_0 Basic_VS(false, true, true);
        PixelShader  = compile ps_3_0 Basic_PS(false, true, true);
    }
    pass DrawEdge {
        CullMode = CW;
        VertexShader = compile vs_3_0 Edge_VS();
        PixelShader  = compile ps_3_0 Edge_PS();
    }
}

technique MainTec7 < string MMDPass = "object"; string Subset = EDGE_ON_MAT;
                     bool UseTexture = true; bool UseSphereMap = true; bool UseToon = true;
                     string Script = LOOPSCRIPT_OBJECT_EDGE; >
{
    pass DrawObject {
        VertexShader = compile vs_3_0 Basic_VS(true, true, true);
        PixelShader  = compile ps_3_0 Basic_PS(true, true, true);
    }
    pass DrawEdge {
        CullMode = CW;
        VertexShader = compile vs_3_0 Edge_VS();
        PixelShader  = compile ps_3_0 Edge_PS();
    }
}

// �I�u�W�F�N�g�`��p�e�N�j�b�N�iPMD���f���p,�G�b�W�����j
technique MainTec8 < string MMDPass = "object"; bool UseTexture = false; bool UseSphereMap = false; bool UseToon = true;
                     string Script = LOOPSCRIPT_OBJECT; >
{
    pass DrawObject {
        VertexShader = compile vs_3_0 Basic_VS(false, false, true);
        PixelShader  = compile ps_3_0 Basic_PS(false, false, true);
    }
}

technique MainTec9 < string MMDPass = "object"; bool UseTexture = true; bool UseSphereMap = false; bool UseToon = true;
                     string Script = LOOPSCRIPT_OBJECT; >
{
    pass DrawObject {
        VertexShader = compile vs_3_0 Basic_VS(true, false, true);
        PixelShader  = compile ps_3_0 Basic_PS(true, false, true);
    }
}

technique MainTec10 < string MMDPass = "object"; bool UseTexture = false; bool UseSphereMap = true; bool UseToon = true;
                      string Script = LOOPSCRIPT_OBJECT; >
{
    pass DrawObject {
        VertexShader = compile vs_3_0 Basic_VS(false, true, true);
        PixelShader  = compile ps_3_0 Basic_PS(false, true, true);
    }
}

technique MainTec11 < string MMDPass = "object"; bool UseTexture = true; bool UseSphereMap = true; bool UseToon = true;
                      string Script = LOOPSCRIPT_OBJECT; >
{
    pass DrawObject {
        VertexShader = compile vs_3_0 Basic_VS(true, true, true);
        PixelShader  = compile ps_3_0 Basic_PS(true, true, true);
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////
// �Z���t�V���h�E�pZ�l�v���b�g

struct VS_ZValuePlot_OUTPUT {
    float4 Pos          : POSITION;    // �ˉe�ϊ����W
    float4 ShadowMapTex : TEXCOORD0;   // Z�o�b�t�@�e�N�X�`��
    float4 Color        : COLOR0;      // alpha�l
};

// ���_�V�F�[�_
VS_ZValuePlot_OUTPUT ZValuePlot_VS( float4 Pos : POSITION )
{
    VS_ZValuePlot_OUTPUT Out = (VS_ZValuePlot_OUTPUT)0;

    // �f�ރ��f���̃��[���h���W�ϊ�
    Pos = mul( Pos, WorldMatrix );

    // �������f���̔z�u���W�ϊ�
    float alpha;
    float4x4 TransMatrix = SetTransMatrix(alpha);
    Pos = mul( Pos, TransMatrix );

    // ���C�g�̖ڐ��ɂ��r���[�ˉe�ϊ�
    Out.Pos = mul( Pos, LightViewProjMatrix );

    // �e�N�X�`�����W�𒸓_�ɍ��킹��
    Out.ShadowMapTex = Out.Pos;

    // ���f����alpha�l
    Out.Color = float4(1.0f, 1.0f, 1.0f, alpha);

    return Out;
}

// �s�N�Z���V�F�[�_
float4 ZValuePlot_PS( VS_ZValuePlot_OUTPUT IN ) : COLOR
{
    // R�F������Z�l���L�^����
    return float4(IN.ShadowMapTex.z/IN.ShadowMapTex.w, 0, 0, IN.Color.a);
}

// Z�l�v���b�g�p�e�N�j�b�N
technique ZplotTec < string MMDPass = "zplot"; string Script = LOOPSCRIPT_ZPLOT; >
{
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
BufferShadow_OUTPUT BufferShadow_VS(float4 Pos : POSITION, float3 Normal : NORMAL, float2 Tex : TEXCOORD0, float2 Tex2 : TEXCOORD1, uniform bool useTexture, uniform bool useSphereMap, uniform bool useToon)
{
    BufferShadow_OUTPUT Out = (BufferShadow_OUTPUT)0;

    // �f�ރ��f���̃��[���h���W�ϊ�
    Pos = mul( Pos, WorldMatrix );

    // ���[���h���W�ϊ��ɂ�钸�_�@��
    Normal = mul( Normal, (float3x3)WorldMatrix );

    // �������f���̔z�u���W�ϊ�
    float alpha;
    float4x4 TransMatrix = SetTransMatrix(alpha);
    Pos = mul( Pos, TransMatrix );

    // �z�u���W�ϊ��ɂ�钸�_�@��
    Out.Normal = normalize( mul( Normal, (float3x3)TransMatrix ) );

    // �J�������_�̃r���[�ˉe�ϊ�
    Out.Pos = mul( Pos, ViewProjMatrix );

    // �J�����Ƃ̑��Έʒu
    Out.Eye = CameraPosition - Pos.xyz;

    // ���C�g���_�ɂ��r���[�ˉe�ϊ�
    Out.ZCalcTex = mul( Pos, LightViewProjMatrix );

    // �f�B�t���[�Y�F�{�A���r�G���g�F �v�Z
    Out.Color.rgb = AmbientColor;
    if ( !useToon ) {
        Out.Color.rgb += max(0, dot( Out.Normal, -LightDirection )) * DiffuseColor.rgb;
    }
    Out.Color.a = DiffuseColor.a * alpha;
    Out.Color = saturate( Out.Color );

    // �e�N�X�`�����W
    Out.Tex = Tex;

    if ( useSphereMap ) {
        if( use_subtexture ) {
            // PMX�T�u�e�N�X�`�����W
            Out.SpTex = Tex2;
        } else {
            // �X�t�B�A�}�b�v�e�N�X�`�����W
            float2 NormalWV = mul( Out.Normal, (float3x3)ViewMatrix ).xy;
            Out.SpTex.x = NormalWV.x * 0.5f + 0.5f;
            Out.SpTex.y = NormalWV.y * -0.5f + 0.5f;
        }
    }

    return Out;
}

// �s�N�Z���V�F�[�_
float4 BufferShadow_PS(BufferShadow_OUTPUT IN, uniform bool useTexture, uniform bool useSphereMap, uniform bool useToon) : COLOR
{
    clip(IN.Color.a-0.001f);

    // �X�y�L�����F�v�Z
    float3 HalfVector = normalize( normalize(IN.Eye) + -LightDirection );
    float3 Specular = pow( max(0,dot( HalfVector, normalize(IN.Normal) )), SpecularPower ) * SpecularColor;

    float4 Color = IN.Color;
    float4 ShadowColor = float4(saturate(AmbientColor), Color.a);  // �e�̐F
    if ( useTexture ) {
        // �e�N�X�`���K�p
        float4 TexColor = tex2D( ObjTexSampler, IN.Tex );
        // �e�N�X�`���ގ����[�t��
        TexColor.rgb = lerp(1, TexColor * TextureMulValue + TextureAddValue, TextureMulValue.a + TextureAddValue.a);
        Color *= TexColor;
        ShadowColor *= TexColor;
    }
    if ( useSphereMap ) {
        // �X�t�B�A�}�b�v�K�p
        float4 TexColor = tex2D(ObjSphareSampler,IN.SpTex);
        // �X�t�B�A�e�N�X�`���ގ����[�t��
        TexColor.rgb = lerp(spadd?0:1, TexColor * SphereMulValue + SphereAddValue, SphereMulValue.a + SphereAddValue.a);
        if(spadd) {
            Color.rgb += TexColor.rgb;
            ShadowColor.rgb += TexColor.rgb;
        } else {
            Color.rgb *= TexColor.rgb;
            ShadowColor.rgb *= TexColor.rgb;
        }
        Color.a *= TexColor.a;
        ShadowColor.a *= TexColor.a;
    }
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
        if ( useToon ) {
            // �g�D�[���K�p
            comp = min(saturate(dot(IN.Normal,-LightDirection)*Toon),comp);
            ShadowColor.rgb *= MaterialToon;
        }

        float4 ans = lerp(ShadowColor, Color, comp);
        if( transp ) ans.a = 0.5f;
        return ans;
    }
}

// �I�u�W�F�N�g�`��p�e�N�j�b�N�i�A�N�Z�T���p�j
technique MainTecBS0  < string MMDPass = "object_ss"; bool UseTexture = false; bool UseSphereMap = false; bool UseToon = false;
                        string Script = LOOPSCRIPT_OBJECT; >
{
    pass DrawObject {
        VertexShader = compile vs_3_0 BufferShadow_VS(false, false, false);
        PixelShader  = compile ps_3_0 BufferShadow_PS(false, false, false);
    }
}

technique MainTecBS1  < string MMDPass = "object_ss"; bool UseTexture = true; bool UseSphereMap = false; bool UseToon = false;
                        string Script = LOOPSCRIPT_OBJECT; >
{
    pass DrawObject {
        VertexShader = compile vs_3_0 BufferShadow_VS(true, false, false);
        PixelShader  = compile ps_3_0 BufferShadow_PS(true, false, false);
    }
}

technique MainTecBS2  < string MMDPass = "object_ss"; bool UseTexture = false; bool UseSphereMap = true; bool UseToon = false;
                        string Script = LOOPSCRIPT_OBJECT; >
{
    pass DrawObject {
        VertexShader = compile vs_3_0 BufferShadow_VS(false, true, false);
        PixelShader  = compile ps_3_0 BufferShadow_PS(false, true, false);
    }
}

technique MainTecBS3  < string MMDPass = "object_ss"; bool UseTexture = true; bool UseSphereMap = true; bool UseToon = false;
                        string Script = LOOPSCRIPT_OBJECT; >
{
    pass DrawObject {
        VertexShader = compile vs_3_0 BufferShadow_VS(true, true, false);
        PixelShader  = compile ps_3_0 BufferShadow_PS(true, true, false);
    }
}

// �I�u�W�F�N�g�`��p�e�N�j�b�N�iPMD���f���p,�G�b�W�L��j
technique MainTecBS4  < string MMDPass = "object_ss"; string Subset = EDGE_ON_MAT;
                        bool UseTexture = false; bool UseSphereMap = false; bool UseToon = true;
                        string Script = LOOPSCRIPT_OBJECT_EDGE; >
{
    pass DrawObject {
        VertexShader = compile vs_3_0 BufferShadow_VS(false, false, true);
        PixelShader  = compile ps_3_0 BufferShadow_PS(false, false, true);
    }
    pass DrawEdge {
        CullMode = CW;
        VertexShader = compile vs_3_0 Edge_VS();
        PixelShader  = compile ps_3_0 Edge_PS();
    }
}

technique MainTecBS5  < string MMDPass = "object_ss"; string Subset = EDGE_ON_MAT;
                        bool UseTexture = true; bool UseSphereMap = false; bool UseToon = true;
                        string Script = LOOPSCRIPT_OBJECT_EDGE; >
{
    pass DrawObject {
        VertexShader = compile vs_3_0 BufferShadow_VS(true, false, true);
        PixelShader  = compile ps_3_0 BufferShadow_PS(true, false, true);
    }
    pass DrawEdge {
        CullMode = CW;
        VertexShader = compile vs_3_0 Edge_VS();
        PixelShader  = compile ps_3_0 Edge_PS();
    }
}

technique MainTecBS6  < string MMDPass = "object_ss"; string Subset = EDGE_ON_MAT;
                        bool UseTexture = false; bool UseSphereMap = true; bool UseToon = true;
                        string Script = LOOPSCRIPT_OBJECT_EDGE; >
{
    pass DrawObject {
        VertexShader = compile vs_3_0 BufferShadow_VS(false, true, true);
        PixelShader  = compile ps_3_0 BufferShadow_PS(false, true, true);
    }
    pass DrawEdge {
        CullMode = CW;
        VertexShader = compile vs_3_0 Edge_VS();
        PixelShader  = compile ps_3_0 Edge_PS();
    }
}

technique MainTecBS7  < string MMDPass = "object_ss"; string Subset = EDGE_ON_MAT;
                        bool UseTexture = true; bool UseSphereMap = true; bool UseToon = true;
                        string Script = LOOPSCRIPT_OBJECT_EDGE; >
{
    pass DrawObject {
        VertexShader = compile vs_3_0 BufferShadow_VS(true, true, true);
        PixelShader  = compile ps_3_0 BufferShadow_PS(true, true, true);
    }
    pass DrawEdge {
        CullMode = CW;
        VertexShader = compile vs_3_0 Edge_VS();
        PixelShader  = compile ps_3_0 Edge_PS();
    }
}

// �I�u�W�F�N�g�`��p�e�N�j�b�N�iPMD���f���p,�G�b�W�����j
technique MainTecBS8  < string MMDPass = "object_ss"; bool UseTexture = false; bool UseSphereMap = false; bool UseToon = true;
                        string Script = LOOPSCRIPT_OBJECT; >
{
    pass DrawObject {
        VertexShader = compile vs_3_0 BufferShadow_VS(false, false, true);
        PixelShader  = compile ps_3_0 BufferShadow_PS(false, false, true);
    }
}

technique MainTecBS9  < string MMDPass = "object_ss"; bool UseTexture = true; bool UseSphereMap = false; bool UseToon = true;
                        string Script = LOOPSCRIPT_OBJECT; >
{
    pass DrawObject {
        VertexShader = compile vs_3_0 BufferShadow_VS(true, false, true);
        PixelShader  = compile ps_3_0 BufferShadow_PS(true, false, true);
    }
}

technique MainTecBS10  < string MMDPass = "object_ss"; bool UseTexture = false; bool UseSphereMap = true; bool UseToon = true;
                        string Script = LOOPSCRIPT_OBJECT; >
{
    pass DrawObject {
        VertexShader = compile vs_3_0 BufferShadow_VS(false, true, true);
        PixelShader  = compile ps_3_0 BufferShadow_PS(false, true, true);
    }
}

technique MainTecBS11  < string MMDPass = "object_ss"; bool UseTexture = true; bool UseSphereMap = true; bool UseToon = true;
                        string Script = LOOPSCRIPT_OBJECT; >
{
    pass DrawObject {
        VertexShader = compile vs_3_0 BufferShadow_VS(true, true, true);
        PixelShader  = compile ps_3_0 BufferShadow_PS(true, true, true);
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////
