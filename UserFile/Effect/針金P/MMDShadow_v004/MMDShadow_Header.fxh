////////////////////////////////////////////////////////////////////////////////////////////////
//
//  MMDShadow_Header.fxh : MMDShadow �V���h�E�}�b�v�쐬�ɕK�v�Ȋ�{�p�����[�^��`�w�b�_�t�@�C��
//  MMD�ƂقƂ�Ǔ����V���h�E�}�b�v���G�t�F�N�g�݂̂Ŏ������Ă��܂��B
//  �����̃p�����[�^�𑼂̃G�t�F�N�g�t�@�C���� #include ���Ďg�p���܂��B
//  �쐬: �j��P
//
////////////////////////////////////////////////////////////////////////////////////////////////
// �����̃p�����[�^��ύX���Ă�������
// ���t�@�C���X�V��ɢMMEffect�����S�čX�V��ŎQ�Ƃ��Ă���G�t�F�N�g�t�@�C�����X�V����K�v������܂�

// �V���h�E�}�b�v�o�b�t�@�T�C�Y
#define ShadowMapSize  2048

// VSM�V���h�E�}�b�v�̎���
#define UseSoftShadow  1
// 0 : �������Ȃ�(MMD�W���̃V���h�E�}�b�v�ƂقƂ�Ǔ����ɂȂ�B�\�t�g�V���h�E�͎g���Ȃ����Ǖ`�摬�x�͌��シ��)
// 1 : ��������(�\�t�g�V���h�E���g����悤�ɂȂ�܂�)


// ����Ȃ��l�͂������牺�͂�����Ȃ��ł�

////////////////////////////////////////////////////////////////////////////////////////////////
// �p�����[�^�錾

#ifndef MMDSHADOW_MAIN

#ifndef MIKUMIKUMOVING

    // MMD�̢�Z���t�V���h�E���죂ɂ����颉e�͈ͣ���͒l
    float4x4 MMDShadow_LtPMat : PROJECTION < string Object = "Light"; >;
    static float MMDShadow_SelfShadowLength = 10000.0f * ( 1.0f - MMDShadow_LtPMat._33 / 0.015f );

#else

    shared texture MMDShadow_ParamTex : RENDERCOLORTARGET;
    sampler MMDShadow_ParamSamp = sampler_state
    {
        Texture = <MMDShadow_ParamTex>;
        MinFilter = POINT;
        MagFilter = POINT;
        MipFilter = NONE;
        AddressU  = CLAMP;
        AddressV  = CLAMP;
    };
    /* ������œǂ݂������ǃG���[�ɂȂ�
    float4 MMDShadow_OwnerDat[1] : TEXTUREVALUE <
       string TextureName = "MMDShadow_ParamTex";
    >; */
    static float MMDShadow_OwnerDat = tex2Dlod(MMDShadow_ParamSamp, float4(0.5f, 0.5f, 0, 0 )).r;
    // MMD�̢�Z���t�e���죂ɂ����颉e�͈ͣ���͒l
    static float MMDShadow_SelfShadowLength = abs(MMDShadow_OwnerDat);
    // MMD�̃Z���t�V���h�E���[�h�t���O false:mode1, true:mode2
    static bool MMDShadow_ParthFlag = (MMDShadow_OwnerDat < 0.0f) ? true : false;

#endif

// �J�����ʒu
float3 MMDShadow_CameraPosition  : POSITION  < string Object = "Camera"; >;

// �J��������(���K���ς�)
float3 MMDShadow_CameraDirection : DIRECTION < string Object = "Camera"; >;

// MMD�Ɩ�������͒lXYZ�~(-1),MMM�ł͓��͒lXYZ�~(-100)
float3 MMDShadow_LightPosition   : POSITION  < string Object = "Light"; >;

// ���C�g����(���K���ς�)�Anormalize(-MMDShadow_LightPosition) �ł����܂�
float3 MMDShadow_LightDirection  : DIRECTION < string Object = "Light"; >;


/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/*
�EMMD���C�g�����̃r���[�ϊ��s��

MMD�̃��C�g�̓f�B���N�V���i�����C�g(���s����)�ł��邽�߁A���C�g�̈ʒu���W�͖{�����C�g�̌����Ƌt�����̖������_�ɂȂ�B

float3 LightPosition : POSITION < string Object = "Light"; >; �Ŏ擾�����l��MME�ł�MMD�Ɩ�������͒lXYZ �~(-1)�̒l�ł���A
MMM�̏ꍇ�͏Ɩ�������͒lXYZ �~(-100)�̒l�ł���B

MMD�̃��C�g�����r���[�ϊ��s��ɂ��ẮA�J�����ʒu����LightPosition�~50�̈ʒu�����̌������W�Ƃ��Čv�Z���Ă���B
���C�g������z���������Ƃ��āA���C�g�����ƃJ�������������ɐ����ɂȂ������x��(������y���������ɃJ�������_��
�����悤�Ɍ��߂�)�ɂȂ�悤�ɕϊ�����B
����Ĉȉ��̌v�Z���� float4x4 LightViewMatrix : VIEW < string Object = "Light"; >; �Ɠ����l�����߂���
*/

float4x4 MMDShadow_LightViewMatrix()
{
   // x�������x�N�g��(MMDShadow_LightDirection��z�������x�N�g��)
   float3 ltViewX = cross( MMDShadow_CameraDirection, MMDShadow_LightDirection ); 

   // x�������x�N�g���̐��K��(MMDShadow_CameraDirection��MMDShadow_LightDirection�̕�������v����ꍇ�͓��ْl�ƂȂ�)
   float viewLength = length(ltViewX);
   if(viewLength == 0.0f) viewLength = 1;
   ltViewX /= viewLength;

   // y�������x�N�g��
   float3 ltViewY = cross( MMDShadow_LightDirection, ltViewX );  // ���ɐ����Ȃ̂ł���Ő��K��

   // ���̌����ʒu
   #ifndef MIKUMIKUMOVING
   float3 ltViewPos = MMDShadow_CameraPosition + MMDShadow_LightPosition * 50.0f;
   #else
   float3 ltViewPos = MMDShadow_CameraPosition + MMDShadow_LightPosition * 0.5f;
   #endif

   // �r���[���W�ϊ��̉�]�s��
   float3x3 ltViewRot = { ltViewX.x, ltViewY.x, MMDShadow_LightDirection.x,
                          ltViewX.y, ltViewY.y, MMDShadow_LightDirection.y,
                          ltViewX.z, ltViewY.z, MMDShadow_LightDirection.z };

   // �r���[�ϊ��s��
   return float4x4( ltViewRot[0],  0,
                    ltViewRot[1],  0,
                    ltViewRot[2],  0,
                   -mul( ltViewPos, ltViewRot ), 1 );
}


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/*
�EMMD���C�g�����̎ˉe�ϊ��s��

MMD�̃��C�g�����ˉe�ϊ��s��̓��C�g�����ƃJ���������̂Ȃ��p�ɂ���čs��̎Z����@�����ނ���Ă���B
��̓I�ɂ́A�Ȃ��p���̗]����Βl��

�@ |cos��| = 0.0�`0.8 �̎�(���C�g�ƃJ�����̕���������Ȃ�ɈقȂ鎞)
   mode1��mode2���ꂼ��ʂɃV���h�E���������ӓI�Ɍ��߂���

�A |cos��| = 0.9�`1.0 �̎�(���C�g�ƃJ�����̕������߂��Ȃ�,�܂��͑��΂��鎞)
   mode1��mode2�̋�ʂȂ��V���h�E������|cos��|��茈�߂���

�B |cos��| = 0.8�`0.9 �̎�
   �@�ƇA�̑J�ڕ⊮�l�ɂȂ�B�v�f._23, ._24 ��|cos��|�ɑ΂���2���֐���ԁA���͐��`��ԂɂȂ��Ă���

���ۂɂ͈ȉ��̌v�Z���� float4x4 LightProjMatrix : PROJECTION < string Object = "Light"; >; �Ɠ����l�����߂���

float MMDShadow_SelfShadowLength;  // MMD�̢�Z���t�e���죂ɂ����颉e�͈ͣ���͒l(0�`9999)
bool ParthFlag;   // �Z���t�V���h�E���[�h�t���O false:mode1,true:mode2
*/

float4x4 MMDShadow_LightProjMatrix(bool ParthFlag)
{
   float s = (10000.0 - MMDShadow_SelfShadowLength) / 100000.0;

   float c0, c1, c2;
   float4x4 ltPrjMat;

   if(ParthFlag){
      // �@mode2�̎ˉe�ϊ��s��
      ltPrjMat = float4x4( 3*s,    0,      0,   0,
                             0,  3*s,  1.5*s, 3*s,
                             0,    0, 0.15*s,   0,
                             0,   -1,      0,   1 );
      c0 = 3.0;  c1 = -4.7;  c2 = 1.8;
   }else{
      // �@mode1�̎ˉe�ϊ��s��
      ltPrjMat = float4x4( 2*s,    0,      0,   0,
                             0,  2*s,  0.5*s,   s,
                             0,    0, 0.15*s,   0,
                             0,   -1,      0,   1 );
      c0 = 1.0;  c1 = -1.3;  c2 = 0.4;
   }

   // ���C�g�����ƃJ���������̂Ȃ��p�̗]����Βl
   float absCosD = abs( dot(MMDShadow_CameraDirection, MMDShadow_LightDirection) );

   if(absCosD > 0.9){
      // �A�̎ˉe�ϊ��s��
      ltPrjMat = float4x4( s,         0,                 0,             0,
                           0,         s, 0.5*s*(1-absCosD), s*(1-absCosD),
                           0,         0,            0.15*s,             0,
                           0, absCosD-1,                 0,             1 );
   }else if(absCosD > 0.8){
      // �B�̎ˉe�ϊ��s��
      float t = 10 * ( absCosD - 0.8 );
      ltPrjMat._11 = lerp( ltPrjMat._11, s, t );
      ltPrjMat._22 = lerp( ltPrjMat._22, s, t );
      ltPrjMat._24 = s * ( c0 + c1*t + c2*t*t );
      ltPrjMat._23 = 0.5 * ltPrjMat._24;
      ltPrjMat._42 = lerp( -1, -0.1, t );
   }

   return ltPrjMat;
}

/*
�ELightProjMatrix�ɑ΂���⑫����

���㎮���LightProjMatrix._33�����͂ǂ̕��ނɑ����Ă������Z�莮�ɂȂ邽�߁A��������
  MMD�̢�Z���t�e���죂ɂ����颉e�͈ͣ�̃V���h�E�������͒l���ȉ��̂悤�Ȏ��ŋ��߂邱�Ƃ��o����B

static float SelfShadowLength = 10000 * ( 1 - LightProjMatrix._33 / 0.015 );

���V���h�E������ s = (10000 - SelfShadowLength) / 100000 �̑��΋�������ɂ���
  �ˉe�ϊ��s������߂Ă���(VMD�ɋL�^�����V���h�E���������̒l�������Ă���)�B

���ˉe�ϊ��s����V���h�E�}�b�v���K�p�����͈�(�ˉe���W��xy:-1�`+1,z:0�`1�ƂȂ�͈�)�̓r���[���W��
  �@mode1�̎�
     y = 0 �` 2/s
     y=0 �ŁAx = -1/(2s) �` +1/(2s)
     y=2/s �ŁAx = -3/(2s) �` +3/(2s)
     Near�Fz = -(10/3)y�AFar�Fz = (10/3)y+1/(0.15s)
     mode1�ł̓J�����ߋ����`�������𕽋ϓI(�}�b�v�͈͂̃J�����ŋ߁E�ŉ��X�P�[�����3�{)�ɃV���h�E�}�b�v�͈͂����蓖�Ă�B
     �V���h�E�������Z���Ɖ����������̓Z���t�V���h�E�K�p�͈͊O�ɂȂ�B

  �@mode2�̎�
     y = 0 �` +��
     y=0 �ŁAx = -1/(3s) �` +1/(3s)
     y=+�� �ŁAx = -�� �` +��
     Near�Fz = -10y�AFar�Fz = 10y+1/(0.15s)
     mode2�ł̓J���������̑S�͈͂��J�o�[���Ă��邪�A���̕��}�b�v�͈͂̃J�����ŋ߁E�ŉ��X�P�[����͋ɒ[�ɑ傫���Ȃ�B
     ����ăJ�����ߋ����̓V���h�E�}�b�v�𑜓x�͍������������E�������̃V���h�E�}�b�v�𑜓x�͑e���Ȃ�B

  �r���[���W�ŃJ�����ʒu��z����ɂ���J����������y���������������Ă��āA�V���h�E�}�b�v�K�p�͈͂��r���[���W��y>0�ł��邽�߁A
  �@mode1,�@mode2�ł̓J�����̌�둤�̓V���h�E�}�b�v�͈͊O�ɂȂ�B

  �A�̎�(�Ƃ肠����absCosD=1�ɂ���)
     y = -1/s �` +1/s
     x = -1/s �` +1/s
     Near�Fz = 0�AFar�Fz = 1/(0.15s)
     ����āA���C�g�ƃJ�����̕������߂��Ȃ�(�܂��͑��΂���)�ƃV���h�E�}�b�v�K�p�͈͂̓J�����ʒu�𒆐S�ɂ����͈͂ɑJ�ڂ���悤�ɂȂ�B

��MMD�W����LightProjMatrix�͎��̏�Ԃ̎��͐������擾�ł��Ȃ��Ȃ�
�@  MMD��[�\��(V)]-[�Z���t�V���h�E�\��(P)]��OFF�ɂ�����
�@  MMD��[�Z���t�e����]�Ţ�e�Ȃ����I��������
    �{�[���I����Ԃ̎�
  ��L�ȊO�Ȃ��Z���t�V���h�E�̃I�u�W�F�N�g�`��̎��ł��������擾�ł���B�Ȃ�LightViewMatrix�͏�ɐ������擾�ł���͗l�B

*/

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// ���W�ϊ��s��

float4x4 MMDShadow_WorldMatrix : WORLD;

float4x4 MMDShadow_GetLightViewProjMatrix(bool ParthFlag)
{
    return mul( MMDShadow_LightViewMatrix(), MMDShadow_LightProjMatrix(ParthFlag) );
}

float4x4 MMDShadow_GetLightWorldViewProjMatrix(bool ParthFlag)
{
    return mul( MMDShadow_WorldMatrix, MMDShadow_GetLightViewProjMatrix(ParthFlag) );
}

////////////////////////////////////////////////////////////////////////////////////////////////
// VSM�V���h�E�}�b�v�֘A�̏���

#ifndef MMDSHADOWMAPDRAW

// ����p�����[�^
#define MMDShadow_CTRLFILENAME  "MMDShadow.x"
bool MMDShadow_Valid  : CONTROLOBJECT < string name = MMDShadow_CTRLFILENAME; >;

// �ڂ������x
float MMDShadow_AcsSi : CONTROLOBJECT < string name = MMDShadow_CTRLFILENAME; string item = "Si"; >;
float MMDShadow_BlurUp   : CONTROLOBJECT < string name = "(self)"; string item = "ShadowBlur+"; >;
float MMDShadow_BlurDown : CONTROLOBJECT < string name = "(self)"; string item = "ShadowBlur-"; >;
static float MMDShadow_ShadowBulrPower = max((MMDShadow_AcsSi * 0.1f + 5.0f*MMDShadow_BlurUp)*(1.0f - MMDShadow_BlurDown), 0.0f);

// �e�Z�x
float MMDShadow_AcsTr : CONTROLOBJECT < string name = MMDShadow_CTRLFILENAME; string item = "Tr"; >;
float MMDShadow_AcsX  : CONTROLOBJECT < string name = MMDShadow_CTRLFILENAME; string item = "X"; >;
float MMDShadow_DensityUp   : CONTROLOBJECT < string name = "(self)"; string item = "ShadowDen+"; >;
float MMDShadow_DensityDown : CONTROLOBJECT < string name = "(self)"; string item = "ShadowDen-"; >;
static float MMDShadow_Density = max(((MMDShadow_AcsX+1.0f) * MMDShadow_AcsTr + 5.0f*MMDShadow_DensityUp)*(1.0f - MMDShadow_DensityDown), 0.0f);

// MMDShadow�ɂ��V���h�E�}�b�v�o�b�t�@
shared texture MMD_ShadowMap : OFFSCREENRENDERTARGET;
sampler MMDShadow_ShadowMapSamp = sampler_state {
    texture = <MMD_ShadowMap>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = LINEAR;
    AddressU  = CLAMP;
    AddressV = CLAMP;
};

#if UseSoftShadow==1

    // �V���h�E�}�b�v�̎��ӃT���v�����O��
    #define BASESMAP_COUNT  4

    // �V���h�E�}�b�v�o�b�t�@�T�C�Y
    #define SMAPSIZE_WIDTH   ShadowMapSize
    #define SMAPSIZE_HEIGHT  ShadowMapSize

    // �V���h�E�}�b�v�̃T���v�����O�Ԋu
    static float2 MMDShadow_SMapSampStep = float2(MMDShadow_ShadowBulrPower/SMAPSIZE_WIDTH, MMDShadow_ShadowBulrPower/SMAPSIZE_HEIGHT);

    // �V���h�E�}�b�v�̎��ӃT���v�����O1
    float2 MMDShadow_GetZPlotSampleBase1(float2 Tex, float smpScale)
    {
        float2 smpStep = MMDShadow_SMapSampStep * smpScale;
        float mipLv = log2( max(SMAPSIZE_WIDTH*smpStep.x, 1.0f) );
        float2 zplot = tex2Dlod(MMDShadow_ShadowMapSamp, float4(Tex, 0, mipLv)).xy * 2.0f;
        zplot += tex2Dlod(MMDShadow_ShadowMapSamp, float4(Tex+smpStep*float2(-1,-1), 0, mipLv)).xy;
        zplot += tex2Dlod(MMDShadow_ShadowMapSamp, float4(Tex+smpStep*float2( 1,-1), 0, mipLv)).xy;
        zplot += tex2Dlod(MMDShadow_ShadowMapSamp, float4(Tex+smpStep*float2(-1, 1), 0, mipLv)).xy;
        zplot += tex2Dlod(MMDShadow_ShadowMapSamp, float4(Tex+smpStep*float2( 1, 1), 0, mipLv)).xy;
        return (zplot / 6.0f);
    }

    // �V���h�E�}�b�v�̎��ӃT���v�����O2
    float2 MMDShadow_GetZPlotSampleBase2(float2 Tex, float smpScale)
    {
        float2 smpStep = MMDShadow_SMapSampStep * smpScale;
        float mipLv = log2( max(SMAPSIZE_WIDTH*smpStep.x, 1.0f) );
        float2 zplot = tex2Dlod(MMDShadow_ShadowMapSamp, float4(Tex, 0, mipLv)).xy * 2.0f;
        zplot += tex2Dlod(MMDShadow_ShadowMapSamp, float4(Tex+smpStep*float2(-1, 0), 0, mipLv)).xy;
        zplot += tex2Dlod(MMDShadow_ShadowMapSamp, float4(Tex+smpStep*float2( 1, 0), 0, mipLv)).xy;
        zplot += tex2Dlod(MMDShadow_ShadowMapSamp, float4(Tex+smpStep*float2( 0,-1), 0, mipLv)).xy;
        zplot += tex2Dlod(MMDShadow_ShadowMapSamp, float4(Tex+smpStep*float2( 0, 1), 0, mipLv)).xy;
        return (zplot / 6.0f);
    }

    // �Z���t�V���h�E�̎Օ��m�������߂�
    float MMDShadow_GetSelfShadowRate(float2 SMapTex, float z, bool ParthFlag)
    {
        // �V���h�E�}�b�v���Z�v���b�g�̓��v����(zplot.x:����, zplot.y:2�敽��)
        float2 zplot = float2(0,0);
        float rate = 1.0f;
        float sumRate = 0.0f;
        [unroll]
        for(int i=0; i<BASESMAP_COUNT; i+=2) {
            rate *= 0.5f; sumRate += rate;
            zplot += MMDShadow_GetZPlotSampleBase1(SMapTex, float(i+1)) * rate;
            rate *= 0.5f; sumRate += rate;
            zplot += MMDShadow_GetZPlotSampleBase2(SMapTex, float(i+2)) * rate;
        }
        zplot /= sumRate;

        // �e������(VSM:Variance Shadow Maps�@)
        float variance = max( zplot.y - zplot.x * zplot.x, 0.001f );
        float comp = variance / (variance + max(z - zplot.x, 0.0f));

        comp = smoothstep(0.1f/max(MMDShadow_ShadowBulrPower, 1.0f), 1.0f, comp);
        return (1.0f-(1.0f-comp) * min(MMDShadow_Density, 1.0f));
    }

#else

    #define MMDShadow_SKII1  1500
    #define MMDShadow_SKII2  8000

    // �Z���t�V���h�E�̎Օ��m�������߂�(�\�t�g�V���h�E���g��Ȃ��ꍇ)
    float MMDShadow_GetSelfShadowRate(float2 SMapTex, float z, bool ParthFlag)
    {
        float comp;
        float dist = max( min(z, 1.0f) - tex2D(MMDShadow_ShadowMapSamp, SMapTex).r, 0.0f );
        if(ParthFlag) {
            // �Z���t�V���h�E mode2
            comp = 1.0f - saturate( dist * MMDShadow_SKII2 * SMapTex.y - 0.3f );
        } else {
            // �Z���t�V���h�E mode1
            comp = 1.0f - saturate( dist * MMDShadow_SKII1 - 0.3f);
        }

        return (1.0f-(1.0f-comp) * min(MMDShadow_Density, 1.0f));
    }

#endif

float MMDShadow_ObjTr : CONTROLOBJECT < string name = "(self)"; string item = "Tr"; >;

struct MMDShadow_COLOR {
    float4 Color;        // �I�u�W�F�N�g�F
    float4 ShadowColor;  // �e�F
};

// �e�F�ɔZ�x����������
MMDShadow_COLOR MMDShadow_GetShadowDensity(float4 Color, float4 ShadowColor, bool useToon, float LightNormal)
{
    MMDShadow_COLOR Out;
    Out.Color = Color;
    Out.ShadowColor = ShadowColor;

    if( !useToon || length(Color.rgb-ShadowColor.rgb) > 0.01f ){
        float e = max(MMDShadow_Density, 1.0f);
        float s = 1.0f - 0.3f * smoothstep(3.0f, 6.0f, e);
        Out.ShadowColor = saturate(float4(pow(max(ShadowColor.rgb*s, float3(0.001f, 0.001f, 0.001f)), e), ShadowColor.a));
    }
    if( !useToon ){
        float e = lerp( max(MMDShadow_Density, 1.0f), 1.0f, smoothstep(0.0f, 0.4f, LightNormal) );
        float s = 1.0f - 0.3f * smoothstep(3.0f, 6.0f, e);
        Out.Color = saturate(float4(pow(max(Color.rgb*s, float3(0.001f, 0.001f, 0.001f)), e), Color.a));
        #ifndef MIKUMIKUMOVING
        Out.Color.a *= MMDShadow_ObjTr;
        Out.ShadowColor.a *= MMDShadow_ObjTr;
        #endif
    }

    return Out;
}

#endif
#endif
