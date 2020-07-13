//-----------------------------------------------------------------------------
// �ގ��ݒ�t�@�C��

#include "Sources/Material_header.fxsub"

// �}�e���A���^�C�v
#define MATERIAL_TYPE		MT_NORMAL
/*
MT_NORMAL	: �ʏ� (�������܂�)
MT_FACE		: �� (��p)
MT_LEAF		: �t��J�[�e���ȂǁA����������ގ��p�B
MT_MASK		: �X�J�C�h�[���p�B
*/

// �g�p����e�N�X�`���t�@�C����
#define TEXTURE_FILENAME_0	"textures/check.png"
#define TEXTURE_FILENAME_1	"textures/check.png"
#define TEXTURE_FILENAME_2	"textures/check.png"
#define TEXTURE_FILENAME_3	"textures/check.png"
// TEXTURE_FILENAME_x �̐������A�ȉ��� xxx_MAP_FILE �Ŏw�肷��B


// �������ǂ����B�� ���˂̋���
// ���l�������قǔ��˂������Ȃ違���̐F�̉e�����󂯂�悤�ɂȂ�B
// 0: ������A1:�����B��΂Ȃǂ�0.1-0.2���x�B
#define	METALNESS_VALUE			0.0
#define	METALNESS_MAP_ENABLE	0	// 0:VALUE���g���A1: �e�N�X�`���Ŏw�肷��
#define METALNESS_MAP_FILE		0	// �g�p����e�N�X�`���t�@�C���ԍ����w��B0-3
#define METALNESS_MAP_CHANNEL	R	// �g�p����e�N�X�`���̃`�����l���BR,G,B,A
#define METALNESS_MAP_LOOPNUM	1.0
#define METALNESS_MAP_SCALE		1.0
#define METALNESS_MAP_OFFSET	0.0

// xxx_ENABLE: 1�̏ꍇ�A�e�N�X�`������l��ǂݍ��ށB
// xxx_LOOPNUM: �e�N�X�`���̌J��Ԃ��񐔁B1�Ȃ瓙�{�B�������傫���قǍׂ����Ȃ�B
// xxx_SCALE, xxx_OFFSET: �l�� (�e�N�X�`���̒l * scale + offset) �Ōv�Z����B


// �\�ʂ̊��炩��
// SMOOTHNESS_TYPE = 1 �̏ꍇ�A0:�}�b�g�A1:���炩�B
// SMOOTHNESS_TYPE = 2 �̏ꍇ�A0:���炩�A1:�}�b�g�B

// Smoothness�̎w����@�F
// 0: ���f���̃X�y�L�����p���[���玩���Ō��肷��B
// 1: �X���[�X�l�X���g�p�B
// 2: ���t�l�X���g�p�B
#define SMOOTHNESS_TYPE		0

#define	SMOOTHNESS_VALUE		1.0
#define	SMOOTHNESS_MAP_ENABLE	0
#define SMOOTHNESS_MAP_FILE		0
#define SMOOTHNESS_MAP_CHANNEL	R
#define SMOOTHNESS_MAP_LOOPNUM	1.0
#define SMOOTHNESS_MAP_SCALE	1.0
#define SMOOTHNESS_MAP_OFFSET	0.0

// �����̔��ːF���x�[�X�F�������狁�߂�?
// 0: �x�[�X�F * �X�y�L�����F�Ō���B(ver0.16�ȑO�̕���)
// 1: �x�[�X�F�݂̂Ō���B
// 2: �X�y�L�����F�݂̂Ō���B
// �� ������̏ꍇ�́A�ݒ�Ƃ͖��֌W�ɔ��ɂȂ�B
#define SPECULAR_COLOR_TYPE		0


// �X�y�L�������x

// Intensity�̈����F
#define INTENSITY_TYPE		0
// 0: Specular Intensity. �X�y�L�������x�̒���
// 1: Ambient Occlusion. �Ԑڌ��ւ̃}�X�N
// 2: Cavity. �S�Ẵ��C�e�B���O���Օ�
// 3: Cavity (View Dependent). �S�Ẵ��C�e�B���O���Օ�(�����ˑ�)

// 0:�n�C���C�g�Ȃ��A1:�n�C���C�g����
#define	INTENSITY_VALUE			1.0
#define	INTENSITY_MAP_ENABLE	0
#define INTENSITY_MAP_FILE		0
#define INTENSITY_MAP_CHANNEL	R
#define INTENSITY_MAP_LOOPNUM	1.0
#define INTENSITY_MAP_SCALE		1.0
#define INTENSITY_MAP_OFFSET	0.0


// �����x
// �������x�Ɣ牺�U���x�͋��L�ł��Ȃ��B
#define	EMISSIVE_TYPE			0
// 0: AL�Ή�
// 1: �������Ȃ� (�y��)
// 2: �����Ŏw��BEMISSIVE_VALUE or EMISSIVE_MAP
// 3: �ǉ����C�g�p
// 4: �ǉ����C�g�p(�X�N���[��)

// �ȉ��� EMISSIVE_TYPE 2�̏ꍇ�̐ݒ�F
#define	EMISSIVE_VALUE			1.0 // 0.0�`8.0
#define	EMISSIVE_MAP_ENABLE		0
#define EMISSIVE_MAP_FILE		0
#define EMISSIVE_MAP_CHANNEL	R
#define EMISSIVE_MAP_LOOPNUM	1.0
#define EMISSIVE_MAP_SCALE		1.0 // 0.0�`8.0
#define EMISSIVE_MAP_OFFSET		0.0


// �牺�U���x�F���A�v���X�`�b�N�Ȃǂ̔������Ȃ��̂Ɏw��B
// 0:�s�����B1:�������B
// �����̏ꍇ�͖��������B
#define	SSS_VALUE			0.0
#define	SSS_MAP_ENABLE		0
#define SSS_MAP_FILE		0
#define SSS_MAP_CHANNEL		R
#define SSS_MAP_LOOPNUM		1.0
#define SSS_MAP_SCALE		1.0
#define SSS_MAP_OFFSET		0.0



//-----------------------------------------------------------------------------
// ���̑�

// ���̒l�ȉ��̔������x�Ȃ�}�e���A���I�ɂ͓��������ɂ���B
#define AlphaThreshold		0.5


//-----------------------------------------------------------------------------
// �@���}�b�v

// �@���}�b�v���g�p���邩? 0:���g�p�B1:�g�p
#define NORMALMAP_ENABLE		0

// ���C���@���}�b�v
#define NORMALMAP_MAIN_FILENAME "textures/dummy_n.bmp"
#define NORMALMAP_MAIN_LOOPNUM	1.0
#define NORMALMAP_MAIN_HEIGHT	1.0

// �T�u�@���}�b�v
#define NORMALMAP_SUB_ENABLE	0
#define NORMALMAP_SUB_FILENAME "textures/dummy_n.bmp"
#define NORMALMAP_SUB_LOOPNUM	1.0
#define NORMALMAP_SUB_HEIGHT	1.0


//-----------------------------------------------------------------------------
#include "Sources/Material_body.fxsub"
