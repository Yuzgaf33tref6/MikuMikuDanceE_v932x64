//-----------------------------------------------------------------------------
// �K���X�p
// �� ���̃G�t�F�N�g�����蓖�Ă�ގ���ColorMapRT, SSAOMaprRT���珜�O���Ă��������B

// �������ǂ����B0:������A1:�����B�傫���l�قǌ��𔽎˂���B
// �K���X�A��΂�0.1�`0.2���x�B
// �� �X�y�L�����̋����Ƌ��ܗ��ɉe������
const float Metalness = 0.1;

// Smoothness�̎w����@�F
// 0: ���f���̃X�y�L�����p���[���玩���Ō��肷��B
// 1: �X���[�X�l�X���g�p�B
// 2: ���t�l�X���g�p�B
#define SMOOTHNESS_TYPE			0
#define	SMOOTHNESS_VALUE		1.0

#define	SMOOTHNESS_MAP_ENABLE	0	// 1:�e�N�X�`�����g���A0:�g��Ȃ�
#define SMOOTHNESS_MAP_FILE		"textures/white.png"
#define SMOOTHNESS_MAP_LOOPNUM	1.0
#define SMOOTHNESS_MAP_SCALE	1.0
#define SMOOTHNESS_MAP_OFFSET	0.0

#define NORMALMAP_ENABLE		0
#define NORMALMAP_MAIN_FILENAME "textures/dummy_n.bmp"
#define NORMALMAP_MAIN_LOOPNUM	1.0
#define NORMALMAP_MAIN_HEIGHT	1.0

#define NORMALMAP_SUB_ENABLE	0
#define NORMALMAP_SUB_FILENAME "textures/dummy_n.bmp"
#define NORMALMAP_SUB_LOOPNUM	1.0
#define NORMALMAP_SUB_HEIGHT	1.0

// �����̔��]
// 0: ���]�Ȃ�
// 1: x�𔽓]
// 2: y�𔽓]
// 3: x,y�𔽓]
#define	NORMALMAP_FLIP		0

#define PARALLAX_ENABLE		0
#define PARALLAX_FILENAME	"textures/white.png"
#define PARALLAX_LOOPNUM	1.0		// �e�N�X�`���̌J��Ԃ���

// �[�x�̒�����(mmd�P��)
// �[�x�}�b�v�ł�0-1�ł̍������Ammd�łǂꂭ�炢�̍�����\�����B
#define PARALLAX_HEIGHT		1.0

// �e�N�X�`����ł̎Q�Ƌ���
// (�Q�ƃs�N�Z��/�e�N�X�`���T�C�Y)
#define PARALLAX_LENGTH		(32.0/512.0)

#define PARALLAX_ITERATION	8	// ������(1�`16)


// �����I�ɕs�����x�𒲐�����B0.5��50%�́A1.0�Ńf�t�H���g�̕s�����x�B
const float ForceAlphaScale = 1.0;


// ���ܕ\���𖳌��ɂ��邩?
// ikPolishShader.fxsub ���� ENABLE_REFRACTION �� 1 ���A
// DISABLE_REFRACTION �� 0 �̂Ƃ����܂��L���ɂȂ�B
#define DISABLE_REFRACTION		0

// �w�i�̐F���K���X�ɋz������銄���B0.0�`1.0
#define SURFACE_ABSORPTION_RATE			0.5 // �ꗥ�ŋz��
#define BODY_ABSORPTION_RATE			0.1 // ���݂ŕς��

// ���݂̌v�Z���@
#define THICKNESS_TYPE			1
// 0: �Œ�l
// 1: ���ʃ|���S���Ƃ̍�
// 2: �[�x�� (���ʂɎg�p����)


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
