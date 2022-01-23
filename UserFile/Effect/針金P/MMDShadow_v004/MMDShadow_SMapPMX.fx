////////////////////////////////////////////////////////////////////////////////////////////////
//
//  MMDShadowMapPMX.fx : MMDShadow �V���h�E�}�b�v�쐬(PMX�ŃV���h�E�}�b�vOFF�w��̂��郂�f���ɓK��)
//  ( MMDShadow.fx ����Ăяo����܂��D�I�t�X�N���[���`��p)
//  �쐬: �j��P
//
////////////////////////////////////////////////////////////////////////////////////////////////
// �����̃p�����[�^��ύX���Ă�������

// PMX�̍ގ��ŃV���h�E�}�b�vOFF�̍ގ��ԍ������X�g�A�b�v����  ��) "3,5,12"
#define NONE_SHADOWMAP  "10000"


// ����Ȃ��l�͂������牺�͂�����Ȃ��ł�

////////////////////////////////////////////////////////////////////////////////////////////////
// �p�����[�^�錾

#define MMDSHADOWMAPDRAW

// ���ʂ̃V���h�E�}�b�v�p�����[�^����荞��
#include "MMDShadow_Header.fxh"


// ���ߒl�ɑ΂���[�x�ǂݎ��臒l
float AlphaClipThreshold = 0.005;

// �}�e���A���F
float4 MaterialDiffuse : DIFFUSE  < string Object = "Geometry"; >;

bool opadd; // ���Z�����t���O

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


////////////////////////////////////////////////////////////////////////////////////////////////
//MMM�Ή�

#ifndef MIKUMIKUMOVING
    bool parthf;
    struct VS_INPUT{
        float4 Pos    : POSITION;
        float2 Tex    : TEXCOORD0;
    };
    #define MMM_SKINNING
    #define GETPOS  (IN.Pos)
#else
    #define parthf  MMDShadow_ParthFlag
    #define VS_INPUT  MMM_SKINNING_INPUT
    #define MMM_SKINNING  MMM_SKINNING_OUTPUT SkinOut = MMM_SkinnedPositionNormal(IN.Pos, IN.Normal, IN.BlendWeight, IN.BlendIndices, IN.SdefC, IN.SdefR0, IN.SdefR1);
    #define GETPOS  (SkinOut.Position)
#endif


////////////////////////////////////////////////////////////////////////////////////////////////
// Z�v���b�g�`��

struct VS_OUTPUT {
    float4 Pos  : POSITION;    // �ˉe�ϊ����W
    float4 PPos : TEXCOORD0;   // �ˉe�ϊ����W
    float2 Tex  : TEXCOORD1;   // �e�N�X�`��
};

// ���_�V�F�[�_
VS_OUTPUT VS_ShadowMap(VS_INPUT IN)
{
    VS_OUTPUT Out = (VS_OUTPUT)0; 
    MMM_SKINNING

    // ���C�g�̖ڐ��ɂ�郏�[���h�r���[�ˉe�ϊ�������
    Out.Pos = mul( GETPOS, MMDShadow_GetLightWorldViewProjMatrix(parthf) );
    Out.PPos = Out.Pos;

    // �e�N�X�`�����W
    Out.Tex = IN.Tex;

    return Out;
}

// �s�N�Z���V�F�[�_
float4 PS_ShadowMap(VS_OUTPUT IN, uniform bool useTexture) : COLOR
{
    // ���l
    float alpha = MaterialDiffuse.a;

    // ���l��0.98�̍ގ��̓V���h�E�}�b�v�ɂ͕`�悵�Ȃ�
    clip(abs(alpha - 0.98f) - 0.00001f);

    // ���Z�������f���̓V���h�E�}�b�v�ɂ͕`�悵�Ȃ�
    clip( !opadd - 0.001f );

    if ( useTexture ) {
        // �e�N�X�`�����ߒl�K�p
        alpha *= tex2D( ObjTexSampler, IN.Tex ).a;
    }
    // ���l��臒l�ȉ��̉ӏ��̓V���h�E�}�b�v�ɂ͕`�悵�Ȃ�
    clip(alpha - AlphaClipThreshold);

    // Z�l
    float z = saturate(IN.PPos.z / IN.PPos.w);

    return float4(z, z*z, 0, 1);
}

///////////////////////////////////////////////////////////////////////////////////////
// �e�N�j�b�N

// �V���h�E�}�b�v��`�悵�Ȃ��ގ�
technique NoneDepthTec   < string MMDPass = "object";    string Subset = NONE_SHADOWMAP; > { }
technique NoneDepthTecSS < string MMDPass = "object_ss"; string Subset = NONE_SHADOWMAP; > { }


// �I�u�W�F�N�g�`��(�Z���t�V���h�E�Ȃ�)
technique DepthTec0 < string MMDPass = "object"; bool UseTexture = false; >
{
    pass DrawObject {
        AlphaBlendEnable = FALSE;
        VertexShader = compile vs_3_0 VS_ShadowMap();
        PixelShader  = compile ps_3_0 PS_ShadowMap(false);
    }
}

technique DepthTec1 < string MMDPass = "object"; bool UseTexture = true; >
{
    pass DrawObject {
        AlphaBlendEnable = FALSE;
        VertexShader = compile vs_3_0 VS_ShadowMap();
        PixelShader  = compile ps_3_0 PS_ShadowMap(true);
    }
}

// �I�u�W�F�N�g�`��(�Z���t�V���h�E����)
technique DepthTecSS0 < string MMDPass = "object_ss"; bool UseTexture = false; >
{
    pass DrawObject {
        AlphaBlendEnable = FALSE;
        VertexShader = compile vs_3_0 VS_ShadowMap();
        PixelShader  = compile ps_3_0 PS_ShadowMap(false);
    }
}

technique DepthTecSS1 < string MMDPass = "object_ss"; bool UseTexture = true; >
{
    pass DrawObject {
        AlphaBlendEnable = FALSE;
        VertexShader = compile vs_3_0 VS_ShadowMap();
        PixelShader  = compile ps_3_0 PS_ShadowMap(true);
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////

// �֊s�͕`�悵�Ȃ�
technique EdgeTec < string MMDPass = "edge"; > { }
// �n�ʉe�͕`�悵�Ȃ�
technique ShadowTec < string MMDPass = "shadow"; > { }

