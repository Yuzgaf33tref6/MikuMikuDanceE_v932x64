
// �Ǐ]���郂�f���ƃ{�[����
#define	TARGET_MODEL_NAME	"(self)"
//#define	TARGET_MODEL_NAME	"�����~�N.pmd"
//#define	TARGET_BONE_NAME	"��"


// �h�b�g�Ɛ��̐F
#define DOT_COLOR	float3(0.2, 0.2, 0.8)
// �h�b�g�p�^�[���p�e�N�X�`��
#define DOT_TEXTURE_NAME	"dot.png"

// ���t���[�������Ƀh�b�g��\�����邩?
// 1���Ƌl�܂肷���ĕ�����ɂ���
#define DOT_STEP	4
// �h�b�g�����܂ŕ\�����邩?
// �� DOT_STEP * DOT_DRAW_NUM �� 512�𒴂��Ȃ����ƁB
#define DOT_DRAW_NUM	64

// �h�b�g�̕\���T�C�Y(1�`16���x)
#define	DOT_SIZE		6
// ���t���[���̃h�b�g�̃T�C�Y(���̃h�b�g��菭���傫���\������)
#define	DOT_SIZE_CURRENT	10

// ���̕\���T�C�Y(1�`4���x)
#define	LINE_WIDTH		2


// �L�^�p�o�b�t�@�̃T�C�Y
// 256x64��1.6���t���[�����ۑ��ł���B����ȏ�ۑ��������ꍇ��256x256�Ȃǂɂ���B
#define TEX_WIDTH	256
#define TEX_HEIGHT	64

// fps
#define FRAME_PER_SECOND	30

// �J�����ɉf��ʒu���L�^���邩(1)�A�J�����Ɉˑ����Ȃ��ʒu���L�^���邩(0)
// 0�ɂ����ꍇ�A���݂̃J�������猩���A�ߋ�/�����̃^�[�Q�b�g�ʒu��\������B
// 1�ɂ����ꍇ�A�L�^���_�ł̉�ʓ��̈ʒu���L�^���ĕ\������B
#define SAVE_PROJECTION_POSITION	1

////////////////////////////////////////////////////////////////////////////////////////////////

#include "arc_common.fxsub"
