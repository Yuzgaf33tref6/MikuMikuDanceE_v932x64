//-----------------------------------------------------------------------------
// �����Y�S�[�X�g

// ���C�g���̂̐F�F
#define LIGHT_COLOR		float3(1.0, 0.4, 0.1)
// ���̋؂̐F�F
#define RAY_COLOR		float3(1.0, 0.8, 0.4)
// �� MMD�̃��C�g�F�̐F�Ə�Z����܂��B

// �ȈՃ����Y�S�[�X�g��`�悷�邩?
#define ENBLE_LENS_GHOST	1

// ���̒����BSi�ł������\�B�傫���قǒZ���Ȃ�B
#define LIGHT_LENGTH	6

// ���̎Q�Ɣ͈́B(0.1�`1.0�B�������قǌ������ӂ���������)
#define LIGHT_SIZE		0.5


// ���C�g�ʒu�̎w����@�F
// 0: MMD�̃��C�g�ʒu���g���B
// 1: �R���g���[���Ŏw�肵��"����"�ɂ���B���_��B
// 2: �R���g���[���Ŏw�肵��"�ʒu"�ɂ���
#define USE_CTRL_POSITION	1
// �R���g���[���̎w��F
// �Ώۃ��f�����B(self)���ƃA�N�Z�T�����g
#define CTRL_NAME	"(self)"
//#define CTRL_NAME	"xxx.pmx"
// �Ώۃ{�[�����B.pmx���w���ɂ���ꍇ�ɐݒ肷��B
// �A�N�Z�T���̏ꍇ�́A�s����//������B
//#define CTRL_BONE_NAME	"�Z���^�["


// �Q�Ɖ�
#define NUM_SAMPLES		16

// �O�t���Ƃ̍������s����? �`�������኱�}����
#define ENABLE_TEMPORAL_BLUR	1

// �o�b�t�@�T�C�Y�B512 or 1024������B
#define BUFFER_SIZE		1024

//-----------------------------------------------------------------------------
#include "ikGodray_common.fxsub"
