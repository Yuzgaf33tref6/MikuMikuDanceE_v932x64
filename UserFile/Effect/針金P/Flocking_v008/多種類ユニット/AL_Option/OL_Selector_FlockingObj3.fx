////////////////////////////////////////////////////////////////////////////////////////////////
//
// Material Selector for ObjectLuminous.fx : Flocking_Multi.x(Flocking_Obj1.fx)��p
// ���ڂ뎁��OL_Selector.fx(ObjectLuminous)����
//
////////////////////////////////////////////////////////////////////////////////////////////////
// ���[�U�[�p�����[�^

//�����F (RGBA�e�v�f 0.0�`1.0)
float4 Emittion_Color
<
   string UIName = "Emittion Color1";
   string UIWidget = "Color";
   bool UIVisible =  true;
   float UIMin = 0.0; float UIMax = 1.0;
> = float4( 0.3, 0.3, 0.3, 1.0 );

//�Q�C��
float Gain
<
   string UIName = "Gain";
   string UIWidget = "Slider";
   bool UIVisible =  true;
   float UIMin = 0.0; float UIMax = 5.0;
> = float( 0.8 );

int ObjCount = 120;    // ���f��������(Flocking_Multi.fx��ObjCount[2]�Ɠ����l�ɂ���K�v����)
int StartCount = 180;  // �O���[�v�̐擪�C���f�b�N�X(Flocking_Multi.fx��StartCount[2]�Ɠ����l�ɂ���K�v����)


// ����Ȃ��l�͂������牺�͂�����Ȃ��ł�

////////////////////////////////////////////////////////////////////////////////////////////////

int Index;  // �������f���J�E���^

#define TEX_WIDTH_W   4            // ���j�b�g�z�u�ϊ��s��e�N�X�`���s�N�Z����
#define TEX_WIDTH     1            // ���j�b�g�f�[�^�i�[�e�N�X�`���s�N�Z����
#define TEX_HEIGHT 1024            // ���j�b�g�f�[�^�i�[�e�N�X�`���s�N�Z������

// ���W�ϊ��s��
float4x4 ViewProjMatrix : VIEWPROJECTION;
float4x4 WorldMatrix    : WORLD;
float4x4 ViewMatrix     : VIEW;
float4x4 ProjMatrix     : PROJECTION;

//�J�����ʒu
float3 CameraPosition   : POSITION  < string Object = "Camera"; >;

// �}�e���A���F
float4 MaterialDiffuse   : DIFFUSE  < string Object = "Geometry"; >;

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

// ���j�b�g�z�u�ϊ��s�񂪋L�^����Ă���e�N�X�`��
shared texture Flocking_TransMatrixTex : RENDERCOLORTARGET
<
   int Width=TEX_WIDTH_W;
   int Height=TEX_HEIGHT;
   string Format="A32B32G32R32F";
>;
sampler TransMatrixSmp : register(s3) = sampler_state
{
   Texture = <Flocking_TransMatrixTex>;
   AddressU  = CLAMP;
   AddressV = CLAMP;
   MinFilter = NONE;
   MagFilter = NONE;
   MipFilter = NONE;
};


////////////////////////////////////////////////////////////////////////////////////////////////
// ���f���̔z�u�ϊ��s��
float4x4 SetTransMatrix()
{
    int i = ((Index + StartCount) / TEX_HEIGHT) * 4;
    int j = (Index + StartCount) % TEX_HEIGHT;
    float y = (j+0.5f)/TEX_HEIGHT;

    // ���f���̔z�u�ϊ��s��
    return float4x4( tex2Dlod(TransMatrixSmp, float4((i+0.5f)/TEX_WIDTH_W, y, 0, 0)), 
                     tex2Dlod(TransMatrixSmp, float4((i+1.5f)/TEX_WIDTH_W, y, 0, 0)), 
                     tex2Dlod(TransMatrixSmp, float4((i+2.5f)/TEX_WIDTH_W, y, 0, 0)), 
                     tex2Dlod(TransMatrixSmp, float4((i+3.5f)/TEX_WIDTH_W, y, 0, 0)) );
}

////////////////////////////////////////////////////////////////////////////////////////////////
//MMM�Ή�

#ifdef MIKUMIKUMOVING
    #define VS_INPUT  MMM_SKINNING_INPUT
    #define GETPOS MMM_SkinnedPosition(IN.Pos, IN.BlendWeight, IN.BlendIndices, IN.SdefC, IN.SdefR0, IN.SdefR1)
    #define GETVPMAT(eye) (MMM_IsDinamicProjection ? mul(ViewMatrix, MMM_DynamicFov(ProjMatrix, length(eye))) : ViewProjMatrix)
#else
    struct VS_INPUT{
        float4 Pos    : POSITION;
        float2 Tex    : TEXCOORD0;
    };
    #define GETPOS (IN.Pos)
    #define GETVPMAT(eye) (ViewProjMatrix)
#endif

///////////////////////////////////////////////////////////////////////////////////////////////
// �I�u�W�F�N�g�`��

struct VS_OUTPUT {
    float4 Pos        : POSITION;    // �ˉe�ϊ����W
    float2 Tex        : TEXCOORD1;   // �e�N�X�`��
    float4 Color      : COLOR0;      // �f�B�t���[�Y�F
};

// ���_�V�F�[�_
VS_OUTPUT VS_Selected(VS_INPUT IN)
{
    VS_OUTPUT Out = (VS_OUTPUT)0;

    // �f�ރ��f���̃��[���h���W�ϊ�
    float4 Pos = mul( GETPOS, WorldMatrix );

    // �������f���̔z�u���W�ϊ�
    float4x4 TransMatrix = SetTransMatrix();
    Pos = mul( Pos, TransMatrix );

    // �J�������_�̃r���[�ˉe�ϊ�
    Out.Pos = mul( Pos, GETVPMAT(CameraPosition-Pos.xyz) );

    // �f�B�t���[�Y�F�{�A���r�G���g�F �v�Z
    Out.Color = float4(1.0f, 1.0f, 1.0f, MaterialDiffuse.a);

    // �e�N�X�`�����W
    Out.Tex = IN.Tex;

    return Out;
}

// �s�N�Z���V�F�[�_
float4 PS_Selected(VS_OUTPUT IN, uniform bool useTexture) : COLOR0
{
    float4 Color = IN.Color;
    if ( useTexture ) {
        // �e�N�X�`���K�p
        Color.a *= tex2D( ObjTexSampler, IN.Tex ).a;
    }

    //�����F
    Color *= Emittion_Color;
    Color.rgb *= Gain * Color.a;

    return Color;
}

////////////////////////////////////////////////////////////////////////////////////////////////
//�e�N�j�b�N

//�Z���t�V���h�E�Ȃ�
technique Select1 < string MMDPass = "object"; bool UseTexture = false;
                    string Script = "LoopByCount=ObjCount;" "LoopGetIndex=Index;" "Pass=Single_Pass;" "LoopEnd=;"; >
{
    pass Single_Pass {
        AlphaBlendEnable = FALSE;
        CullMode = NONE;
        VertexShader = compile vs_3_0 VS_Selected();
        PixelShader  = compile ps_3_0 PS_Selected(false);
    }
}

technique Select2 < string MMDPass = "object"; bool UseTexture = true;
                    string Script = "LoopByCount=ObjCount;" "LoopGetIndex=Index;" "Pass=Single_Pass;" "LoopEnd=;"; >
{
    pass Single_Pass {
        AlphaBlendEnable = FALSE;
        CullMode = NONE;
        VertexShader = compile vs_3_0 VS_Selected();
        PixelShader  = compile ps_3_0 PS_Selected(true);
    }
}

//�Z���t�V���h�E����
technique SelectSS1 < string MMDPass = "object_ss"; bool UseTexture = false;
                    string Script = "LoopByCount=ObjCount;" "LoopGetIndex=Index;" "Pass=Single_Pass;" "LoopEnd=;"; >
{
    pass Single_Pass {
        AlphaBlendEnable = FALSE;
        VertexShader = compile vs_3_0 VS_Selected();
        PixelShader  = compile ps_3_0 PS_Selected(false);
    }
}

technique SelectSS2 < string MMDPass = "object_ss"; bool UseTexture = true;
                    string Script = "LoopByCount=ObjCount;" "LoopGetIndex=Index;" "Pass=Single_Pass;" "LoopEnd=;"; >
{
    pass Single_Pass {
        AlphaBlendEnable = FALSE;
        VertexShader = compile vs_3_0 VS_Selected();
        PixelShader  = compile ps_3_0 PS_Selected(true);
    }
}


//�e��֊s�͕`�悵�Ȃ�
technique EdgeTec < string MMDPass = "edge"; > { }
technique ShadowTec < string MMDPass = "shadow"; > { }
technique ZplotTec < string MMDPass = "zplot"; > { }

