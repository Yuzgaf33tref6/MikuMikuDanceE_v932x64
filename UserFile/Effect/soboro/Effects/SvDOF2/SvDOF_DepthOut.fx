////////////////////////////////////////////////////////////////////////////////////////////////
//
//  ��ʊE�[�x�G�t�F�N�g�E�[�x�}�b�v���C�J�[ Ver.2
//  �쐬: ���ڂ�
//
//�@DOF�ɓ������Ă���̂Ŕėp���͂���܂���
//
////////////////////////////////////////////////////////////////////////////////////////////////

// �w�i�܂œ��߂�����臒l��ݒ肵�܂�
float TransparentThreshold = 0.5;

// ���ߔ���Ƀe�N�X�`���̓��ߓx���g�p���܂��B1�ŗL���A0�Ŗ���
#define TRANS_TEXTURE  0


////////////////////////////////////////////////////////////////////////////////////////////////

float DepthLimit = 20;

#define SCALE_VALUE 4

//�o�b�t�@�g�嗦
float fmRange = 0.75f;


// ���@�ϊ��s��
float4x4 WorldViewProjMatrix      : WORLDVIEWPROJECTION;
float4x4 WorldMatrix              : WORLD;
float4x4 WorldViewMatrix          : WORLDVIEW;
float4x4 ProjectionMatrix         : PROJECTION;

bool use_texture;  //�e�N�X�`���̗L��

//�}�j���A���t�H�[�J�X�̎g�p
bool UseMF : CONTROLOBJECT < string name = "ManualFocus.x"; >;
float MFScale : CONTROLOBJECT < string name = "ManualFocus.x"; >;

//�e���f����Tr�l
float alpha1 : CONTROLOBJECT < string name = "(OffscreenOwner)"; string item = "Tr"; >;

// �}�e���A���F
float4 MaterialDiffuse   : DIFFUSE  < string Object = "Geometry"; >;

//���ŋ����̎擾
float3 CameraPosition    : POSITION  < string Object = "Camera"; >;
float3 ControlerPos  : CONTROLOBJECT < string name = "(OffscreenOwner)"; >;
static float3 FocusVec = ControlerPos - CameraPosition;
static float FocusLength = UseMF ? (3.5 * MFScale) : (length(FocusVec) * alpha1);

//�œ_���J�����̔w�ʂɂ��邩�ǂ���
float3 CameraDirection : DIRECTION < string Object = "Camera"; >;
static bool BackOut = (dot(CameraDirection, normalize(FocusVec)) < 0) && !UseMF;


// �I�u�W�F�N�g�̃e�N�X�`��
texture ObjectTexture: MATERIALTEXTURE;
sampler ObjTexSampler = sampler_state
{
    texture = <ObjectTexture>;
    MINFILTER = LINEAR;
    MAGFILTER = LINEAR;
};

// MMD�{����sampler���㏑�����Ȃ����߂̋L�q�ł��B�폜�s�B
sampler MMDSamp0 : register(s0);
sampler MMDSamp1 : register(s1);
sampler MMDSamp2 : register(s2);


///////////////////////////////////////////////////////////////////////////////////////////////
// �I�u�W�F�N�g�`��i�Z���t�V���h�EOFF�j

struct VS_OUTPUT
{
    float4 Pos        : POSITION;    // �ˉe�ϊ����W
    float2 Tex        : TEXCOORD0;   // UV
    float3 WorldPos   : TEXCOORD1;   // ���[���h���W
};

// ���_�V�F�[�_
VS_OUTPUT objw_VS(float4 Pos : POSITION, float3 Normal : NORMAL, float2 Tex : TEXCOORD0)
{
    VS_OUTPUT Out = (VS_OUTPUT)0;
    
    // �J�������_�̃��[���h�r���[�ˉe�ϊ�
    Out.Pos = mul( Pos, WorldViewProjMatrix );
    
    //ProjectionMatrix._11 *= fmRange;
    //ProjectionMatrix._22 *= fmRange;
    
    //Out.Pos = mul( Pos, mul(WorldViewMatrix, ProjectionMatrix) );
    
    //���[���h���W
    Out.WorldPos = mul( Pos, WorldMatrix );
    
    #if TRANS_TEXTURE
        Out.Tex = Tex; //�e�N�X�`��UV
    #endif
    
    return Out;
}

// �s�N�Z���V�F�[�_
float4 objw_PS( VS_OUTPUT IN ) : COLOR0
{
    //�J�����Ƃ̋���
    float depth = length(CameraPosition - IN.WorldPos);
    float alpha = MaterialDiffuse.a;
    
    #if TRANS_TEXTURE
        if(use_texture){
            alpha *= tex2D(ObjTexSampler,IN.Tex).a;
        }
    #endif
    
    //���ŋ����Ő��K��
    depth /= (FocusLength * SCALE_VALUE);
    
    //�[�x������𒴂��Ă��邩�A�œ_���J�����̔w�ʂɂ���Ȃ烊�~�b�g�ݒ�
    depth = (depth > DepthLimit || BackOut) ? DepthLimit : depth;
    
    return float4(depth, 0, 0, (alpha >= TransparentThreshold));
    
}

// �I�u�W�F�N�g�`��p�e�N�j�b�N
technique MainTec < string MMDPass = "object"; > {
    pass DrawObject
    {
        AlphaBlendEnable = FALSE;
        VertexShader = compile vs_2_0 objw_VS();
        PixelShader  = compile ps_2_0 objw_PS();
    }
}

// �I�u�W�F�N�g�`��p�e�N�j�b�N
technique MainTecBS  < string MMDPass = "object_ss"; > {
    pass DrawObject {
        AlphaBlendEnable = FALSE;
        VertexShader = compile vs_2_0 objw_VS();
        PixelShader  = compile ps_2_0 objw_PS();
    }
}

// �G�b�W�`��
technique EdgeTec < string MMDPass = "edge"; > {
    pass DrawObject {
        AlphaBlendEnable = FALSE;
        VertexShader = compile vs_2_0 objw_VS();
        PixelShader  = compile ps_2_0 objw_PS();
    }
}

// �n�ʉe�͕\�����Ȃ�
technique ShadowTec < string MMDPass = "shadow"; > { }
// �Z���t�V���h�E�͕\�����Ȃ�
technique ZplotTec < string MMDPass = "zplot"; > { }


///////////////////////////////////////////////////////////////////////////////////////////////
