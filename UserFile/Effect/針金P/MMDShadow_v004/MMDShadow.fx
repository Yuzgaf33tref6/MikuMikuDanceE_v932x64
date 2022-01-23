////////////////////////////////////////////////////////////////////////////////////////////////
//
//  MMDShadow.fx ver0.0.3  �G�t�F�N�g�݂̂Ŏ�������MMD�W���V���h�E�}�b�v�Ɠ����̃Z���t�V���h�E�`��
//  �쐬: �j��P
//
////////////////////////////////////////////////////////////////////////////////////////////////
// �p�����[�^�錾

float Script : STANDARDSGLOBAL <
    string ScriptOutput = "color";
    string ScriptClass = "object";
    string ScriptOrder = "standard";
> = 0.8;

#define MMDSHADOW_MAIN
#include "MMDShadow_Header.fxh"

// �V���h�E�}�b�v�o�b�t�@�T�C�Y
#define SMAPSIZE_WIDTH   ShadowMapSize
#define SMAPSIZE_HEIGHT  ShadowMapSize

#if UseSoftShadow==1
    #define TEX_FORMAT  "D3DFMT_G32R32F"
    #define TEX_MIPLEVELS  0
#else
    #define TEX_FORMAT  "D3DFMT_R32F"
    #define TEX_MIPLEVELS  1
#endif

// �I�t�X�N���[���V���h�E�}�b�v�o�b�t�@
shared texture MMD_ShadowMap : OFFSCREENRENDERTARGET <
    string Description = "MMDShadow.fx�̃V���h�E�}�b�v";
    int Width  = SMAPSIZE_WIDTH;
    int Height = SMAPSIZE_HEIGHT;
    float4 ClearColor = { 1, 1, 1, 1 };
    float ClearDepth = 1.0;
    string Format = TEX_FORMAT;
    bool AntiAlias = false;
    int Miplevels = TEX_MIPLEVELS;
    string DefaultEffect = 
        "self = hide;"
        "* = MMDShadow_ShadowMap.fxsub;";
>;

////////////////////////////////////////////////////////////////////////////////////////////////
#ifdef MIKUMIKUMOVING
// MMM���̓p�����[�^�̎󂯓n���p

bool ParthFlag <        // �N���b�v���]
    string UIName = "mode";
    string UIHelp = "MMD�̃Z���t�V���h�E���[�h�t���O OFF:mode1, ON:mode2";
    bool UIVisible =  true;
> = false;

float SelfShadowLength <
    string UIName = "�e�͈�";
    string UIHelp = "MMD�̢�Z���t�V���h�E���죂ɂ����颉e�͈ͣ���͒l";
    //string UIWidget = "Slider";
    string UIWidget = "Numeric";
    bool UIVisible =  true;
    float UIMin = 0.0;
    float UIMax = 9999.0;
> = float( 8875.0 );

// �p�����[�^�ۑ��p�e�N�X�`��
shared texture MMDShadow_ParamTex : RENDERCOLORTARGET
<
    int Width  = 1;
    int Height = 1;
    int Miplevels = 1;
    string Format = "D3DFMT_R32F";
>;
texture ParamDepthBuffer : RENDERDEPTHSTENCILTARGET <
    int Width  = 1;
    int Height = 1;
    string Format = "D3DFMT_D24S8";
>;

// ���_�V�F�[�_
float4 VS_Param(float4 Pos : POSITION) : POSITION
{
    return Pos;
}

// �s�N�Z���V�F�[�_
float4 PS_Param() : COLOR
{
    return float4(SelfShadowLength*(ParthFlag ? -1 : 1), 0, 0, 1);
}

#endif
////////////////////////////////////////////////////////////////////////////////////////////////
// �e�N�j�b�N

technique MainTech <
    string Script = 
        #ifdef MIKUMIKUMOVING
        "RenderColorTarget0=MMDShadow_ParamTex;"
            "RenderDepthStencilTarget=ParamDepthBuffer;"
            "Pass=ParamPass;"
        #endif
        "RenderColorTarget0=;"
            "RenderDepthStencilTarget=;"
    ;
> {
    #ifdef MIKUMIKUMOVING
    pass ParamPass < string Script= "Draw=Buffer;"; > {
        AlphaBlendEnable = FALSE;
        AlphaTestEnable  = FALSE;
        VertexShader = compile vs_2_0 VS_Param();
        PixelShader  = compile ps_2_0 PS_Param();
    }
    #endif
}

////////////////////////////////////////////////////////////////////////////////////////////////

// �n�ʉe�͕`�悵�Ȃ�
technique ShadowTec < string MMDPass = "shadow"; > { }
// Z�v���b�g�͕`�悵�Ȃ�
technique ZplotTec < string MMDPass = "zplot"; > { }

