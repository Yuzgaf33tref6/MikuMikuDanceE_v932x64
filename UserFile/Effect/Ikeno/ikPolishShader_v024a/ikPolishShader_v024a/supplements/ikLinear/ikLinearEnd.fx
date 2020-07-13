//=============================================================================
//
// ���`�ŉ摜�������邽�߂̃G�t�F�N�g
//
// ikLinearBegin/ikLinearEnd�̃y�A�Ŏg���B
// �� ikPolish�Ǝg���ꍇ�́AikLinearBegin�͕s�v�B
//
//=============================================================================

// �e�X�g�p�̏���\����L���ɂ���B
#define ENBALE_DEBUG_VIEW	0


// ���ϋP�x���v�Z����͈́B
// ��ʓ��̋P�x�𖾂邳���ɂȂ�ׂāALOW_PERCENT�����AHIGH_PERCENT�ȏ��
// �����̂ĂĂ��畽�ς��v�Z����B
#define LOW_PERCENT		(70)		// 50�`80 ���x
#define HIGH_PERCENT	(95)		// 80�`98 ���x


// ���ϋP�x�̉����Ə�� 0.01-4�̊�
#define LOWER_LIMIT		(0.03)
#define UPPER_LIMIT		(2.0)
/*
#define LOWER_LIMIT		(0.5)
#define UPPER_LIMIT		(0.5)
*/

// �ω����x
// �l�Ԃ̖ڂ͖��邭�Ȃ���ƈÂ��Ȃ���ŏ������x���Ⴄ�B
#define SPEED_UP		3.0
#define SPEED_DOWN		1.0

// �����I�o�␳
#define AUTO_EXPOSURE	0	// 0:�����A1:�L��

// �g�[���}�b�v����
#define TONEMAP_MODE	3
/*
0: Linear (�g�[���}�b�v�Ȃ�)
1: Reinhard
2: ACES
3: Uncharted2
*/

// �P�x�x�[�X�̃g�[���}�b�v
// �P�x�x�[�X�̂ق����ʓx�������ɂ����̂�MMD����?
// 0: rgb��Ɨ����Čv�Z����
#define LUMABASE_TONEMAP	1

// �u���[����L���ɂ���
#define ENABLE_BLOOM		1
// �u���[���̋��x
#define	BloomIntensity		0.5 // 0.0-5.0
// �u���[�������閾�邳�̂������l
#define	BloomThreshold		2.0	// 1.0-2.0 ���x


// �A���`�G�C���A�X�B
#define ENABLE_AA		1
// �A���`�G�C���A�X�̋��x
#define AA_Intensity	0.5		// 0.0 - 1.0



// �Ō�Ƀf�B�U�𑫂����ށB�L���ɂ���ƃo���f�B���O�����P�����B
#define ENABLE_DITHER	1	// 0:�����A1:�L��

// �G�f�B�^���Ԃɓ��������邩?
#define TimeSync		0


//-----------------------------------------------------------------------------
// ���܂肢���Ȃ炢����

#define CONTROLLER_NAME		"ikPolishController.pmx"

// �z���C�g�|�C���g�B�g�[���}�b�v���RGB(1,1,1)�ɂȂ閾�邳�B
//#define	WHITE_POINT		(11.2)
#define	WHITE_POINT		(4.0)

// �q�X�g�O�����͈̔�(Log2�P��)
#define LOWER_LOG		(-8)
#define UPPER_LOG		(2)		// 2^x

// ��ʂ̕��ϋP�x���ǂ��܂Ŗ��邭���邩�B
//float KeyValue = 0.5;
float KeyValue = 0.9;

// �P�x���i�[���邽�߂̃e�N�X�`���T�C�Y�B����Ȃ�̃T�C�Y���K�v
#define LUMINANCE_TEX_SIZE		512
static float MAX_MIP_LEVEL = log2(LUMINANCE_TEX_SIZE);

// �u���[���ɐF��t����
#define BLOOM_TINT1	float3(1,1,1)
#define BLOOM_TINT2	float3(1,1,1)
#define BLOOM_TINT3	float3(1,1,1)
#define BLOOM_TINT4	float3(1,1,1)
#define BLOOM_TINT5	float3(1,1,1)


//=============================================================================

#include "ikLinearEnd_body.fxsub"

