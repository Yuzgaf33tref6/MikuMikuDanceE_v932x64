////////////////////////////////////////////////////////////////////////////////////////////////
// ikPostFog
////////////////////////////////////////////////////////////////////////////////////////////////

//******************�ݒ�͂�������

// ���邳��1���z���������J�b�g���邩�ǂ����BAL���g���ꍇ��1�ɂ���B
#define USE_HDR		0


// �R���g���[����
#define	CONTROLLER_NAME	"ikPostFogController.pmx"

// �A�N�Z�T���ʒu����Ƀt�H�O���o��
#define	POS_OBJ_NAME	"(self)"
// �R���g���[���ʒu����Ƀt�H�O���o��
//#define	POS_OBJ_NAME	CONTROLLER_NAME
//#define	POS_BONE_NAME	"�S�Ă̐e"


// ���̃t�H�O�G�t�F�N�g�̖@���}�b�v�𗘗p���邩?
#define USE_SHARED_TEXTURE	0

//****************** ���ʂ̐ݒ�͂����܂�

// �ȈՃT���V���t�g���g���ꍇ�A�A�N�Z�T���̃V���h�E�}�b�v��L���ɂ���K�v������B
// 8�`32���x�B0�Ŗ���
// �����C�g�̉e�����Ղ邾���ŁA�t�H�O���̂ɂ͉e�����Ȃ��B
#define SUNSHAFT_DIV_NUM 	0

// �e�X�g���[�h��L���ɂ���
#define ENABLE_TESTMODE		1

#define MAP_SCALE		(1.0/1.0)


////////////////////////////////////////////////////////////////////////////////////////////////

#include "ikPostFog.fxsub"
