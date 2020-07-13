// 1���f���̍ގ��ݒ��1�t�@�C���ōs���B

//-----------------------------------------------------------------------------
// ��{�I�Ȑݒ�F�ގ��}�b�v�Ŏw�肵�Ȃ��ꍇ�̃f�t�H���g�l

// �������ǂ����B��{��0(�����)�A1(����)�̂ǂ��炩�B
const float Metalness = 0.0;

// �\�ʂ̊��炩��(0�`1)
#define ENABLE_AUTO_SMOOTHNESS		// �X�y�L�����p���[���玩���ŃX���[�X�l�X�����肷��B
const float Smoothness = 0.2;		// �����ݒ肵�Ȃ��ꍇ�̒l�B

// �f�荞�݋��x(0:�f�荞�܂Ȃ��B1:�f�荞�ށB1�ȏ�̒l���ݒ�\)
const float Intensity = 1.0;

// ������̐������˗�
// �����̏ꍇ�́A�F�����t���N�^���X�Ƃ��Ĉ����B
const float NonmetalF0 = 0.05;

// �牺�U���x�F���Ȃǂ̔������Ȃ��̂Ɏw��B0:�s�����B1:�������B
// �����̏ꍇ�͖��������B
const float SSSValue = 0.5;

// �V���h�E�}�b�v�����ȃ��f�����g��?
// �V�F�[�_�[�̃R���p�C�����Ԃ�Z�k���邽�߁A�e�̂��郂�f�����e�̂Ȃ����f����
// �ǂ��炩�p�̃V�F�[�_�[�����𐶐�����悤�ɂ��Ă���B
// �f�t�H���g�ł͉e�t�����f���p�̂ݐ������Ă���B
// #define DISABLE_SHADOW

//-----------------------------------------------------------------------------
// AutoReflection�̍ގ��ݒ�𗘗p����
// #define USE_AUTOREFLECTION_SETTINGS

// NCHL�̍ގ��ݒ�𗘗p����
// USE_NCHL_SETTINGS ��L���ɂ���ƁA���C���@���}�b�v��NCHL�̂��̂��D�悳���B
// #define USE_NCHL_SETTINGS
//#define NCHL_ALPHA_AS_SMOOTHNESS		// �X�y�L�����l���X���[�X�l�X�Ƃ��Ďg���B
//#define NCHL_ALPHA_AS_INTENSITY		// �X�y�L�����l���X�y�L�������x�Ƃ��Ďg���B
// �����������Ɏw��\�ł��B


//-----------------------------------------------------------------------------

#include "MaterialMultiMap_header.fxsub"

// �f�t�H���g�l
#define DefaultLoopNum			1		// �J��Ԃ���
#define DefaultHeightScale		1.0		// �����␳�B���ō����Ȃ� 0�ŕ��R

/* �@���}�b�v�̎w��F
	SET_NORMALMAP(�e�N�X�`���ԍ��A�e�N�X�`�����A�J��Ԃ��񐔁A�����␳) �œo�^����B

	�����@���}�b�v�ŕʃp�����[�^�ɂ���ꍇ�́A
	SET_NORMALMAP_COPY(�e�N�X�`���ԍ�, �Q�Ƃ���e�N�X�`���ԍ�, �J��Ԃ���, �����␳) ���g���B

	�� �@���}�b�v���m�Ńe�N�X�`���ԍ�������Ă͂����Ȃ��B
*/

SET_NORMALMAP(0, "dummy_n.bmp",		1.0, DefaultHeightScale)
SET_NORMALMAP(1, "dummy_n.bmp",		1.0, DefaultHeightScale)
SET_NORMALMAP(2, "dummy_n.bmp",		1.0, DefaultHeightScale)
SET_NORMALMAP(3, "dummy_n.bmp",		1.0, DefaultHeightScale)
SET_NORMALMAP(4, "dummy_n.bmp",		2.0, 0.5)


/* �ގ��}�b�v�̎w��F
	SET_MATERIALMAP(�e�N�X�`���ԍ��A�e�N�X�`�����A�J��Ԃ���) �œo�^����B
	SET_MATERIALMAP_COPY(�e�N�X�`���ԍ�, �Q�Ƃ���e�N�X�`���ԍ�, �J��Ԃ���) ���g�p�\�B
	�� �ގ��}�b�v���m�Ńe�N�X�`���ԍ�������Ă͂����Ȃ��B
*/
SET_MATERIALMAP(0, "value50.png",		2.0)


//-----------------------------------------------------------------------------
/* �T�u�Z�b�g�ԍ����̐ݒ���s���F

	MATERIAL + �@���}�b�v�̐� + �ގ��̎w����@ (UID, �T�u�Z�b�g�ԍ�, [�@���̃p�����[�^], [�ގ��̃p�����[�^]) 

		�@���̐��� 0�A1�A2 �̂����ꂩ�B
		�ގ��̎w����@��
			0�F�f�t�H���g�l
			1�F�ގ��}�b�v�Ŏw��
			V�F���ڐ��l�Ŏw��

		UID�͓����ł��ꂼ�����ʂ��邽�߂̔ԍ��B
		UID���m������Ă͂����Ȃ��B

		�T�u�Z�b�g�ԍ��̓��f���̍ގ��ԍ����w�肷��B
		��d���p���ň͂����ƁB
		"1-4,6"�̂悤�Ȏw����\�B���̏ꍇ�A1,2,3,4��6���ΏۂƂȂ�B

	�}��F
		MATERIAL00(UID, �T�u�Z�b�g�ԍ�)
			�@���}�b�v���w�肹���A�ގ��̓f�t�H���g���g�p�B
			������g�p������A�f�t�H���g�ɔC�����ق��������B

		MATERIAL10(UID, �T�u�Z�b�g�ԍ�, �@���ԍ�)
			�@����1�w��A�ގ��̓f�t�H���g���g�p�B

		MATERIAL1V(UID, �T�u�Z�b�g�ԍ�, �@���ԍ��A���^���l�X�A�X���[�X�l�X�A�C���e���V�e�B�ASSS)
			�@����1�w��A�ގ��͎w�肵���l���g�p�B
			�������A�X���[�X�l�X�� ENABLE_AUTO_SMOOTHNESS �̉e�����󂯂�B

		MATERIAL21(UID, �T�u�Z�b�g�ԍ�, ���C���@���ԍ�, �T�u�@���ԍ�, �ގ��}�b�v�ԍ�)
			�@����2�w��A�ގ����ގ��}�b�v�Ŏw��B

	�� USE_NCHL_SETTINGS���p���A���C���@������������邽�߁A
		MATERIAL1x�͎g�p����Ӗ����Ȃ��B
		MATERIAL0x���g�����AMATERIAL2x�ŃT�u�@�����ɒǉ��̖@����ݒ肷��B
		���̂Ƃ��AMATERIAL2x�̃��C�����ɂ̓_�~�[���w�肷��B
*/
#include "MaterialMultiMap_body.fxsub"

BEGIN_MATERIAL
	MATERIAL0V(0, "0,13",  0, 0.4, 1.0, 1.0)
	MATERIAL0V(1, "11,18,23-26", 1, 0.4, 1.0, 0.0)
END_MATERIAL

