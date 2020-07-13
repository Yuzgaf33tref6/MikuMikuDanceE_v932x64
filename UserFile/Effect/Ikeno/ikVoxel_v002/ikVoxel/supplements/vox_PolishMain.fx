////////////////////////////////////////////////////////////////////////////////////////////////
// �ėp�̃v���Z�b�g�B�ʏ�͑S�������ݒ肷�邾���ł����B

// �p�����[�^�錾

#define ToonColor_Scale			1.0			// �g�D�[���F����������x�����B(1.0�`5.0���x)

// ���X�y�L����
// �Ԃ̃R�[�g�w�ƃ{�f�B�{�́A�畆�Ɗ��Ȃǂ̂悤�ɕ����̃n�C���C�g������ꍇ�p
const float SecondSpecularSmooth =	 0.4;		// 1�ɋ߂Â��قǃX�y�L�������s���Ȃ�B(0�`1)
const float SecondSpecularIntensity = 0.0;		// �X�y�L�����̋��x�B0�ŃI�t�B1�œ��{�B(0�`)

// PMXEditor�̊��F�����C�g�̋����̉e�����󂯂�悤�ɂ���B
#define EMMISIVE_AS_AMBIENT
// #define IGNORE_EMISSIVE			// ���F�𖳌��ɂ���B

// AutoLuminous�΍�B���邢�������J�b�g����B
// #define DISABLE_HDR

// �X�t�B�A�}�b�v����
// �X�t�B�A�}�b�v�ɂ��U�n�C���C�g���s���R�Ɍ�����ꍇ�ɖ���������B
// NCHL�p�̃��f�����g���ꍇ���A�X�t�B�A�}�b�v�𖳌��ɂ���B
//#define IGNORE_SPHERE

//----------------------------------------------------------
// SSS�p�̐ݒ�

// �t������̌��Ŗ��邭����(�J�[�e����t���ςȂǂɎg��)
//#define ENABLE_BACKLIGHT

// �ގ��ݒ��SSS�ɂ��A�ɂ��񂾌��ɂ��F
#define ScatterColor	MaterialToon
//#define ScatterColor	float3(1.0, 0.6, 0.3)

// SSS���ʂ�L���ɂ��邩�B
// �ގ��ݒ��SSS�ɒǉ����Ă���Ɍ��ʂ������邩�ǂ����B
//#define ENABLE_SSS

// �\�w�F�\�ʂ̐F
const float3 TopCol = float3(1.0,1.0,1.0);	// �F
const float TopScale = 2.0;					// �����Ƃ̊p�x���ɔ�������x�����B
const float TopBias = 0.01;					// ���ʂłǂ̒��x�e����^���邩
const float TopIntensity = 0.2;				// �S�̉e���x
// �[�w�F�����̐F
const float3 BottomCol = float3(1.0, 0.0, 0.0);	// �F
const float BottomScale = 0.4;			// �����Ƃ̊p�x���ɔ�������x�����B
const float BottomBias = 0.2;			// ���ʂłǂ̒��x�e����^���邩
const float BottomIntensity = 0.2;			// �S�̉e���x


//----------------------------------------------------------------------------
// voxel�p�p�����[�^�錾

// �u���b�N�̃T�C�Y�B0.1�`1.0���x�B
float VoxelGridSize = 0.5;

// �e�N�X�`���̉𑜓x��������B8�`32���x�B
// 8�Ńe�N�X�`����8��������B�������قǑe���Ȃ�B
float VoxelTextureGridSize = 16;

// �������铧���x��臒l
float VoxelAlphaThreshold = 0.05;

// �u���b�N��`�悷��Ƃ����������l������?
// 0:�s�����ŕ`��A1:�������x�𗘗p����B
// �� ikPolishShader�ł͎w��ł��Ȃ�
#define VOXEL_ENBALE_ALPHA_BLOCK	1

// �u���b�N�̃t�`���ۂ߂邩? 0.0�`0.1���x �傫���قǃG�b�W���������������
// �� 0�ɂ��Ă��v�Z�덷�ŃG�b�W��������ꍇ������܂��B
float VoxelBevelOffset = 0.05;

// �`�F�b�N�񐔁B4�`16���x�B�����قǐ��m�ɂȂ邪�d���Ȃ�B
#define VOXEL_ITERATION_NUMBER	6

// �u���b�N�\�ʂɃe�N�X�`����ǉ�����ꍇ�̃e�N�X�`�����B
// �R�����g�A�E�g(�s����"//"������)����Ɩ����ɂȂ�B
#define VOXEL_TEXTURE	"../grid.png"

// �O������u���b�N�T�C�Y���R���g���[������A�N�Z�T����
#define VOXEL_CONTROLLER_NAME	"ikiVoxelSize.x"

// �t�������`�F�b�N������? 0:���Ȃ��A1:�`�F�b�N����B
// 1�ɂ��邱�Ƃŏ���������̂�����ł���B����Ɍ����ڂ����������Ȃ�B
#define VOXEL_ENABLE_FALLOFF		0

////////////////////////////////////////////////////////////////////////////////////////////////

#include "vox_PolishMain_common.fxsub"
