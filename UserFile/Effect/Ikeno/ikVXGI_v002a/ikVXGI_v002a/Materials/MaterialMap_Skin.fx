//-----------------------------------------------------------------------------
// �ގ��w��B����S���ȂǗp�̐ݒ�B

//-----------------------------------------------------------------------------
// ��{�I�Ȑݒ�

// �������ǂ����B0.05(�����)�A0.4�`1.0(����)�B
// F0�l��ݒ肷��B
const float Metalness = 0.05;

// �\�ʂ̊��炩��(0�`1)
#define ENABLE_AUTO_SMOOTHNESS		// �X�y�L�����p���[���玩���ŃX���[�X�l�X�����肷��B
const float Smoothness = 0.2;		// �����ݒ肵�Ȃ��ꍇ�̒l�B

// �f�荞�݋��x(0:�f�荞�܂Ȃ��B1:�f�荞��)
const float Intensity = 1.0;

// �牺�U���x�F���Ȃǂ̔������Ȃ��̂Ɏw��B0:�s�����B1:�������B
const float SSSValue = 1.0;


//-----------------------------------------------------------------------------
// �ގ��}�b�v

// �ގ��}�b�v���g�p����? 0:�g�p���Ȃ��B1:�g�p����
#define USE_MATERIALMAP	0

// �e�}�b�v�t�@�C���̎w��
//	�t�@�C���w����R�����g�A�E�g����ƁA��{�ݒ�̒l���g����B
//	��FMetalness = 0.0;�Ń��^���l�X�}�b�v�̎w����R�����g�A�E�g����ƁA����������ɂȂ�B
//#define METALNESSMAP_FILENAME "Assets/value0.png"
const float MetalnessMapLoopNum = 1;

//#define SMOOTHNESSMAP_FILENAME "Assets/value60.png"
const float SmoothnessMapLoopNum = 1;

//#define INTENSITYMAP_FILENAME "Assets/value100.png"
const float IntensityMapLoopNum = 1;

//#define SSSMAP_FILENAME "Assets/value100.png"
const float SSSMapLoopNum = 1;


//-----------------------------------------------------------------------------
// �@���}�b�v���g�p���邩?
// #define USE_NORMALMAP

// ���C���@���}�b�v
#define NORMALMAP_MAIN_FILENAME "Assets/dummy_n.bmp" //�t�@�C����
const float NormalMapMainLoopNum = 1;				//�J��Ԃ���
const float NormalMapMainHeightScale = 0.0;		//�����␳ ���ō����Ȃ� 0�ŕ��R

// �T�u�@���}�b�v(���ׂȉ��ʗp)
#define NORMALMAP_SUB_FILENAME "Assets/dummy_n.bmp" //�t�@�C����
const float NormalMapSubLoopNum = 7;			//�J��Ԃ���
const float NormalMapSubHeightScale = 0.0;		//�����␳ ���ō����Ȃ� 0�ŕ��R


//-----------------------------------------------------------------------------
#include "MaterialMap_common.fxsub"
