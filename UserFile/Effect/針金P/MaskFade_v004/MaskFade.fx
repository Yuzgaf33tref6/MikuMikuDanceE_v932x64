////////////////////////////////////////////////////////////////////////////////////////////////
//
//  MaskFade.fx ver0.0.4  �}�X�N�摜��p�����t�F�[�h�C���E�t�F�[�h�A�E�g
//  �쐬: �j��P( ���͉��P����laughing_man.fx���� )
//
////////////////////////////////////////////////////////////////////////////////////////////////
// �����̃p�����[�^��ύX���Ă�������
#define UseTex  1                   // �t�F�[�h�C���O�E�t�F�[�h�A�E�g�オ�C0:�P�F�C1:�e�N�X�`��, 2:�A�j��GIF�APNG, 3:Screen.bmp�A�j��
#define TexFile  "sample.png"       // ��ʂɓ\��t����e�N�X�`���t�@�C����(�P�F,Screen.bmp�̏ꍇ�͖���)
#define AnimeStart 0.0              // �A�j��GIF�APNG�̏ꍇ�̃A�j���[�V�����J�n����(�P�ʁF�b)(�A�j��GIF�APNG�ȊO�ł͖���)
#define MaskFile "sampleMask.png"   // �}�X�N�ɗp����e�N�X�`���t�@�C����

float TexWidthSize  = 1.0;       // ��ʂɑ΂���e�N�X�`���摜�̕��䗦(�P�F�̏ꍇ�͖���)
float TexHeightSize = 1.0;       // ��ʂɑ΂���e�N�X�`���摜�̍����䗦(�P�F�̏ꍇ�͖���)


// ����Ȃ��l�͂������牺�͂�����Ȃ��ł�

///////////////////////////////////////////////////////////////////////////////////////////////

float time : TIME;

// �A�N�Z�T���p�����[�^
float4x4 WorldMatrix : WORLD;
float4 MaterialDiffuse : DIFFUSE  < string Object = "Geometry"; >;
float3 AcsRound : CONTROLOBJECT < string name = "MaskFade.x"; string item = "Rxyz"; >;
static float2 AcsOffset = WorldMatrix._41_42;
static float AcsScaling = length(WorldMatrix._11_12_13)*0.1f; 
static float AcsAlpha = MaterialDiffuse.a;
static float TexScaling = abs(WorldMatrix._43)<1.0f ? 1.0f : (WorldMatrix._43>0.0f ? 1.0f/WorldMatrix._43 : abs(WorldMatrix._43));

// �X�N���[���T�C�Y
float2 ViewportSize : VIEWPORTPIXELSIZE;
static float2 ViewportOffset = float2(0.5f, 0.5f) / ViewportSize;

// �}�X�N�ɗp����e�N�X�`��
texture2D mask_tex <
    string ResourceName = MaskFile;
    int MipLevels = 0;
>;
sampler MaskSamp = sampler_state {
    texture = <mask_tex>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MagFilter = LINEAR;
    AddressU  = CLAMP;
    AddressV = CLAMP;
};

#if(UseTex == 1)
// ��ʂɓ\��t����e�N�X�`��
texture2D screen_tex <
    string ResourceName = TexFile;
    int MipLevels = 0;
>;
#endif

#if(UseTex == 2)
// ��ʂɓ\��t����A�j���[�V�����e�N�X�`��
texture screen_tex : ANIMATEDTEXTURE <
    string ResourceName = TexFile;
    int MipLevels = 1;
    float Offset = AnimeStart;
>;
#endif

#if(UseTex == 3)
// �I�u�W�F�N�g�̃e�N�X�`��
texture screen_tex: MATERIALTEXTURE;
#endif

#if(UseTex > 0)
sampler TexSampler = sampler_state {
    texture = <screen_tex>;
    MINFILTER = LINEAR;
    MAGFILTER = LINEAR;
    MagFilter = LINEAR;
    AddressU  = WRAP;
    AddressV = WRAP;
};
#endif


///////////////////////////////////////////////////////////////////////////////////////////////
// ��ʕ`��

struct VS_OUTPUT
{
    float4 Pos  : POSITION;    // �ˉe�ϊ����W
    float2 Tex  : TEXCOORD0;   // �e�N�X�`��
};

// ���_�V�F�[�_
VS_OUTPUT MaskFade_VS(float4 Pos : POSITION, float2 Tex : TEXCOORD0)
{
    VS_OUTPUT Out = (VS_OUTPUT)0; 

    Out.Pos = Pos;
    Out.Tex = Tex + ViewportOffset;

    return Out;
}

// �s�N�Z���V�F�[�_
float4 MaskFade_PS( float2 Tex :TEXCOORD0 ) : COLOR0
{
#if(UseTex == 0)
    // �P�F�w��̏ꍇ�̐F
    float4 Color = saturate( float4(degrees(AcsRound), 1.0f) );
#else
    // �\��t����e�N�X�`���̐F
    float2 texCoord = float2( Tex.x/TexWidthSize + AcsOffset.x*time,
                              Tex.y/TexHeightSize + AcsOffset.y*time ) * TexScaling;
    float4 Color = tex2D( TexSampler, texCoord );
#endif

    // �}�X�N����e�N�X�`���̐F
    float4 MaskColor = tex2D( MaskSamp, Tex );

    // �O���C�X�P�[���v�Z
    float v = (MaskColor.r + MaskColor.g + MaskColor.b)*0.333333f;

    // �t�F�[�h���ߒl�v�Z
    float a = (1.0f+AcsScaling)*AcsAlpha - 0.5f*AcsScaling;
    float minLen = a - 0.5f*AcsScaling;
    float maxLen = a + 0.5f*AcsScaling;
    Color.a *= saturate( (maxLen - v)/(maxLen - minLen) );

    return Color;
}

///////////////////////////////////////////////////////////////////////////////////////
// �e�N�j�b�N

technique MainTec < string MMDPass = "object"; >
{
    pass DrawObject < string Script= "Draw=Buffer;"; >
    {
        ZENABLE = false;
        VertexShader = compile vs_1_1 MaskFade_VS();
        PixelShader  = compile ps_2_0 MaskFade_PS();
    }
}

