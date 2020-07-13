//-----------------------------------------------------------------------------
// �p�����[�^�錾

//-----------------------------------------------------------------------------
// ��{�I�Ȑݒ�

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

//-----------------------------------------------------------------------------
// AutoReflection�̍ގ��ݒ�𗘗p����
// #define USE_AUTOREFLECTION_SETTINGS

// NCHL�̍ގ��ݒ�𗘗p����
// #define USE_NCHL_SETTINGS
//#define NCHL_ALPHA_AS_SMOOTHNESS		// �X�y�L�����l���X���[�X�l�X�Ƃ��Ďg���B
//#define NCHL_ALPHA_AS_INTENSITY		// �X�y�L�����l���X�y�L�������x�Ƃ��Ďg���B
// �����������Ɏw��\�ł��B

//-----------------------------------------------------------------------------
// �ގ��}�b�v���g�p���邩?
// #define USE_MATERIALMAP

// �ގ��}�b�v��r,g,b,a�ɂ́AMetalness�ASmoothness�AIntensity�ASSS���i�[����Ă�����̂Ƃ���B
#define MATERIALMAP_MAIN_FILENAME "skin_material.png"		//�t�@�C����
const float MaterialMapLoopNum = 1;		// �J��Ԃ���


// �ʂ̍ގ��}�b�v���g�p���邩? USE_MATERIALMAP���w�肵�Ȃ��Ă��L���ɂȂ�B
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
// �� Voxel���ł͖@���}�b�v���g�p�ł��Ȃ��B


//----------------------------------------------------------------------------
// voxel�p�p�����[�^�錾

// �u���b�N�̃T�C�Y�B0.1�`1.0���x�B
float VoxelGridSize = 0.5;

// �e�N�X�`���̉𑜓x��������B8�`32���x�B
// 8�Ńe�N�X�`����8��������B�������قǑe���Ȃ�B
float VoxelTextureGridSize = 16;

// �������铧���x��臒l
// float VoxelAlphaThreshold = 0.05;

// �u���b�N��`�悷��Ƃ����������l������?
// 0:�s�����ŕ`��A1:�������x�𗘗p����B
// �� ikPolishShader�ł͎w��ł��Ȃ�
// #define VOXEL_ENBALE_ALPHA_BLOCK	0

// �u���b�N�̃t�`���ۂ߂邩? 0.0�`0.1���x �傫���قǃG�b�W���������������
// �� 0�ɂ��Ă��v�Z�덷�ŃG�b�W��������ꍇ������܂��B
float VoxelBevelOffset = 0.05;

// �`�F�b�N�񐔁B4�`16���x�B�����قǐ��m�ɂȂ邪�d���Ȃ�B
#define VOXEL_ITERATION_NUMBER	6

// �O������u���b�N�T�C�Y���R���g���[������A�N�Z�T����
#define VOXEL_CONTROLLER_NAME	"ikiVoxelSize.x"

// �t�������`�F�b�N������? 0:���Ȃ��A1:�`�F�b�N����B
// 1�ɂ��邱�Ƃŏ���������̂�����ł���B����Ɍ����ڂ����������Ȃ�B
#define VOXEL_ENABLE_FALLOFF		0

//-----------------------------------------------------------------------------
#include "vox_PolishMaterial_common.fxsub"
