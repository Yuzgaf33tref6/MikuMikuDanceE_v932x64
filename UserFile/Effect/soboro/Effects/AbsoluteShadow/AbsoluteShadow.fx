


#include "AbsoluteShadowCommonSystem.fx"


//�V���h�E�o�b�t�@�E�A���`�G�C���A�X�̗L��
#define SHADOWBUF_AA  false

//�ڂ����̃T���v�����O��
#define SAMP_NUM  7




float Script : STANDARDSGLOBAL <
    string ScriptOutput = "color";
    string ScriptClass = "scene";
    string ScriptOrder = "preprocess";
> = 0.8;



shared texture AbsoluteShadowMap: OFFSCREENRENDERTARGET <
    string Description = "AbsoluteShadowRenderTarget for SpotLight1.fx";
    string Format = "D3DFMT_G32R32F";
    float Width = SHADOWBUFSIZE;
    float Height = SHADOWBUFSIZE;
    float4 ClearColor = { 1, 1, 1, 1 };
    float ClearDepth = 1.0;
#if MIPMAP_ENABLE!=0
    int Miplevels = 0; //�~�b�v�}�b�v�L��
#endif
    bool AntiAlias = SHADOWBUF_AA; //�A���`�G�C���A�X�ݒ�
    string DefaultEffect = 
        "self = hide;"
        "* = AbsoluteShadowZBufDraw.fx;" 
    ;
>;

/*sampler ShadowMapSampler = sampler_state {
    texture = <AbsoluteShadowMap>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = LINEAR;
    AddressU  = CLAMP;
    AddressV = CLAMP;
};

shared texture AbsoluteShadowMapBlur : RENDERCOLORTARGET <
    string Format = "D3DFMT_G16R16";
    float Width = SHADOWBUFSIZE;
    float Height = SHADOWBUFSIZE;
#if MIPMAP_ENABLE!=0
    int Miplevels = 0; //�~�b�v�}�b�v�L��
#endif
>;


// �����_�����O�^�[�Q�b�g�̃N���A�l
float4 ClearColor = {0,0,0,0};
float ClearDepth  = 1.0;

*/




////////////////////////////////////////////////////////////////////////////////////////////////

technique AbsoluteShadow {};
