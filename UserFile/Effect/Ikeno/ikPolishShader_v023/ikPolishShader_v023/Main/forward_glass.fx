//-----------------------------------------------------------------------------
// �K���X�p
// �� ���̃G�t�F�N�g�����蓖�Ă�ގ���ColorMapRT, SSAOMaprRT���珜�O���Ă��������B


// �������ǂ����B0:������A1:�����B�傫���l�قǌ��𔽎˂���B
// �K���X�A��΂�0.1�`0.2���x�B
// �� �X�y�L�����̋����Ƌ��ܗ��ɉe������
const float Metalness = 0.1;

// �\�ʂ̊��炩��(0�`1)
#define ENABLE_AUTO_SMOOTHNESS	0	// �X�y�L�����p���[���玩���ŃX���[�X�l�X�����肷��B
const float Smoothness = 1.0;		// �����ݒ肵�Ȃ��ꍇ�̒l�B

// �����I�ɔ������x�𒲐�����B
const float ForceAlphaScale = 0.1;


// ���ܕ\���𖳌��ɂ��邩?
// ikPolishShader.fxsub ���� ENABLE_REFRACTION �� 1 ���A
// DISABLE_REFRACTION �� 0 �̂Ƃ����܂��L���ɂȂ�B
#define DISABLE_REFRACTION		0

// ���܂ŗ��ʂ��l�����邩? ���݂̂��镨�̗p
#define BACKFACE_AWARE			0

// �w�i�̐F���K���X�ɋz������銄���B0.0�`1.0
#define ABSORPTION_RATE			1.0


// MMD�W���̃V���h�E�}�b�v�ŉA�e�v�Z���s����?
#define USE_MMD_SHADOW	0


//----------------------------------------------------------
// �X�y�L�����֘A

// �X�t�B�A�}�b�v����
#define IGNORE_SPHERE	1

// �X�t�B�A�}�b�v�̋��x
float3 SphereScale = float3(1.0, 1.0, 1.0) * 0.1;

// �X�y�L�����ɉ����ĕs�����x���グ��B
// �L���ɂ���ƁA�K���X�Ȃǂɉf��n�C���C�g����苭���o��B
// ���ȂǃA���t�@�������Ă���ꍇ�̓G�b�W�ɋ����n�C���C�g���o�邱�Ƃ�����B
#define ENABLE_SPECULAR_ALPHA	1


//----------------------------------------------------------
// ���̑�

#define ToonColor_Scale			0.5			// �g�D�[���F����������x�����B(0.0�`1.0)


// ��������s�����x���Ⴂ�Ȃ珜�O����
const float CutoutThreshold = 1.0 / 255.0;

//----------------------------------------------------------
// ���ʏ����̓ǂݍ���
#include "Sources/forward_common.fxsub"
