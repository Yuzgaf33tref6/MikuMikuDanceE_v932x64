//���ʂ̃A�j���[�V�������x�x�[�X
float BaseWaveSpd = 0.1;

//���ˌW��
float refractiveRatio = 0.02;

//���˗�
float reflectParam = 1;

//�����K�E�X�ڂ�������
float V_Gauss_pow = 0.01;

//���ʂ̏㉺���iWater2_Hhi_������p�j
float WaveHeight = 0.01;

//�X�N���[�����x
float2 UVScroll = float2(0.0,0.0);

//���ʕ�����
float WaveSplitLevel = 16;

//���ʂ̍r��
float WaveStrength = 8.0;

//�X�y�L�����̉s��
float SpecularPower = 16.0;

//�X�y�L�����F
float3 SpecularColor = float3(0.5,0.5,0.5)*2;

//�[�x�t�H�O�Œ዗��
float DepthFog_min = 0.025;

//�[�x�t�H�O���ʗ�
float DepthFog = 0.1;

//�[�x�t�H�O�̐F
float3 WaterColor = float3(0.1,0.2,0.3);



//��������g�̋���
float WavePow = 0.1;

//�g�̌�����
float DownPow = 0.9;

//�e�̉��ʋ���
float ShadowHeight = 0.05;

//�e�̔Z��
float ShadowPow = 0.75;

//�ΐ��̋���
float CausticsScale = 0.2;

//�ΐ��̌�����
float CausticsPow = 0.01;

//�F����
float3 Chromatic = float3(1.0,1.25,1.5);

//���ʂ̌v�Z���x
float WaveSpeed = 0.1;

//���ʂ̂ڂ����l
float WaterGause = 0.0;

#include "../WaterMain.fx"