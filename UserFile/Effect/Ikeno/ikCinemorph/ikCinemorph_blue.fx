//�p�����[�^

// �����Y�̃R�[�e�B���O�F
// ��
float3 CoatingColor1 = float3(0.04, 0.25, 1.0);
float3 CoatingColor2 = float3(0.2, 0.8, 1.0) * 0.1;

// ��ʒ��S�����ɓ_�Ώ̂̈ʒu�ɂ��S�[�X�g���o����?
#define ENABLE_SYMMETRY	1


// �F����������B
// ���F�ɋ߂Â��B�R�[�e�B���O�F�𔒂ɂ���ꍇ�͎g�����ق��������B
#define ENABLE_COLOR_EMPHASIZE	0
// �F���������銄��(1.0�`4.0���x)
#define COLOR_EMPHASIZE_RATE	4.0

//����ьW���@0�`1
float OverExposureRatio = 0.85;


//****************** �ȉ��͘M��Ȃ��ق��������ݒ�

// ��䊂̒���
// AL���lRy�Œ����𒲐��\ 
float StretchSampStep0 = 8.0 / 1024.0;

#define X_SCALE		0.5

//�e�N�X�`���t�H�[�}�b�g
#define TEXFORMAT "A16B16G16R16F"

#define SCREEN_TEXFORMAT "A8R8G8B8"
//#define SCREEN_TEXFORMAT "A16B16G16R16F"


// �U�炷���BsampleCoeffs�̌��ȉ��ɂ���B
#define SampleNum	4
// �U�炷�ʒu
float2 sampleCoeffs[] = {
	float2(1.0,-1.0),
	float2(0.8, 0.3),
	float2(0.2, -0.25),
	float2(0.9, -1.5),
};


//******************�ݒ�͂����܂�

#include "ikCinemorphCommon.fxsub"

