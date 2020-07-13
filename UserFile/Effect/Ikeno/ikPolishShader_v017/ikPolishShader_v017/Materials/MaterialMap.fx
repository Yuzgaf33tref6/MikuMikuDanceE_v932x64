//-----------------------------------------------------------------------------
// �ގ��ݒ�t�@�C��

// "//#define" �ƂȂ��Ă���ꍇ�A���̐ݒ�͖����ɂȂ�܂��B
// �s����//���Ȃ��A"#define" �ƂȂ��Ă���ꍇ�A���̐ݒ�͗L���ɂȂ�܂��B

//-----------------------------------------------------------------------------
// ��{�I�Ȑݒ�

// �������ǂ����B��{��0(�����)�A1(����)�̂ǂ��炩�B
const float Metalness = 0.0;

// �\�ʂ̊��炩��(0�`1)
#define ENABLE_AUTO_SMOOTHNESS		// �X�y�L�����p���[���玩���ŃX���[�X�l�X�����肷��B
const float Smoothness = 0.2;		// �����ݒ肵�Ȃ��ꍇ�̒l�B

// �f�荞�݋��x(0:�f�荞�܂Ȃ��B1:�f�荞��)
const float Intensity = 1.0;

// ������̐������˗�(0.02�`0.5���炢)
// ���ʂ��猩���Ƃ��̉f�荞�݂̋����B�ʏ��0.05�A��΂�0.1�`0.2���x�B
// �����̏ꍇ�́A�F�����t���N�^���X�Ƃ��Ĉ����B
const float NonmetalF0 = 0.05;

// �����̐F���x�[�X�F�������狁�߂�?
// 0: �x�[�X�F * �X�y�L�����F�Ō���B(ver0.16�ȑO�̕���)
// 1: �x�[�X�F�݂̂Ō���B
#define USE_ALBEDO_AS_SPECULAR_COLOR	0

// �牺�U���x�F���A�v���X�`�b�N�Ȃǂ̔������Ȃ��̂Ɏw��B0:�s�����B1:�������B
// �����̏ꍇ�͖��������B
const float SSSValue = 0.0;

// ���̒l�ȉ��̔������x�Ȃ�}�e���A���I�ɂ͓��������ɂ���B
//#define AlphaThreshold		0.5


// �e�`��̃^�C�v
// 0: �e�𔖂����� (��p)
// 1: �ʏ�
#define SHADOW_TYPE		1

//-----------------------------------------------------------------------------
// �ގ��}�b�v

// �ގ��}�b�v���g�p���邩?
// #define USE_MATERIALMAP

// 1�܂���2�Ȃ�X���[�X�l�X�}�b�v�����t�l�X�}�b�v�Ƃ��Ĉ���
// �� ���ڎw�肵��Smoothness�̒l�͕ύX����Ȃ��B
// 0: �X���[�X�l�X�}�b�v
// 1: ���]���邾��
// 2: ������������Ĕ��]����
#define USE_ROUGHNESS_MAP 0

// �ގ��}�b�v��r,g,b,a�ɂ́AMetalness�ASmoothness�AIntensity�ASSS���i�[����Ă�����̂Ƃ���B
#define MATERIALMAP_MAIN_FILENAME "skin_material.png"		//�t�@�C����
const float MaterialMapLoopNum = 1;		// �J��Ԃ���

// �ʂ̍ގ��}�b�v���g�p���邩?
// USE_MATERIALMAP���w�肵�Ȃ��Ă��L���ɂȂ�B
// #define USE_SEPARATE_MAP

// �e�}�b�v�t�@�C���̎w��
//	�t�@�C���w����R�����g�A�E�g����ƁA��{�ݒ�̒l���g����B
//	��FMetalness = 0.0;�Ń��^���l�X�}�b�v�̎w����R�����g�A�E�g����ƁA����������ɂȂ�B
#define METALNESSMAP_FILENAME "value0.png"
const float MetalnessMapLoopNum = 1;

#define SMOOTHNESSMAP_FILENAME "value60.png"
const float SmoothnessMapLoopNum = 1;

#define INTENSITYMAP_FILENAME "value100.png"
const float IntensityMapLoopNum = 1;

#define SSSMAP_FILENAME "value100.png"
const float SSSMapLoopNum = 1;


//-----------------------------------------------------------------------------
// �@���}�b�v

// �@���}�b�v���g�p���邩?
// #define USE_NORMALMAP
// USE_NCHL_SETTINGS�Ɨ����g���ꍇ�A�T�u�@���݂̂��L���ɂȂ�܂��B

// ���C���@���}�b�v
#define NORMALMAP_MAIN_FILENAME "dummy_n.bmp" //�t�@�C����
const float NormalMapMainLoopNum = 1;				//�J��Ԃ���
const float NormalMapMainHeightScale = 0.0;		//�����␳ ���ō����Ȃ� 0�ŕ��R

// �T�u�@���}�b�v(���ׂȉ��ʗp)
#define NORMALMAP_SUB_FILENAME "dummy_n.bmp" //�t�@�C����
const float NormalMapSubLoopNum = 1;			//�J��Ԃ���
const float NormalMapSubHeightScale = 0.0;		//�����␳ ���ō����Ȃ� 0�ŕ��R


//-----------------------------------------------------------------------------

// AutoReflection�̍ގ��ݒ�𗘗p����
// #define USE_AUTOREFLECTION_SETTINGS

// NCHL�̍ގ��ݒ�𗘗p����
// #define USE_NCHL_SETTINGS
//#define NCHL_ALPHA_AS_SMOOTHNESS		// �X�y�L�����l���X���[�X�l�X�Ƃ��Ďg���B
//#define NCHL_ALPHA_AS_INTENSITY		// �X�y�L�����l���X�y�L�������x�Ƃ��Ďg���B
// �����������Ɏw��\�ł��B


//-----------------------------------------------------------------------------
#include "MaterialMap_common.fxsub"
