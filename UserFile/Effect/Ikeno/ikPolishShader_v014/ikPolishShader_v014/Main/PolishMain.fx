////////////////////////////////////////////////////////////////////////////////////////////////
// �ėp�̃v���Z�b�g�B�ʏ�͑S�������ݒ肷�邾���ł����B

// �p�����[�^�錾

#define ToonColor_Scale			0.5			// �g�D�[���F����������x�����B(0.0�`1.0)

// ���X�y�L����
// �Ԃ̃R�[�g�w�ƃ{�f�B�{�́A�畆�Ɗ��Ȃǂ̂悤�ɕ����̃n�C���C�g������ꍇ�p
const float SecondSpecularSmooth =	 0.4;		// 1�ɋ߂Â��قǃX�y�L�������s���Ȃ�B(0�`1)
const float SecondSpecularIntensity = 0.0;		// �X�y�L�����̋��x�B0�ŃI�t�B1�œ��{�B(0�`)

// PMXEditor�̊��F�����C�g�̋����̉e�����󂯂�悤�ɂ���B
// #define EMMISIVE_AS_AMBIENT
#define IGNORE_EMISSIVE			// ���F�𖳌��ɂ���B

// AutoLuminous�΍�B���邢�������J�b�g����B
// #define DISABLE_HDR

// �X�t�B�A�}�b�v����
// �X�t�B�A�}�b�v�ɂ��U�n�C���C�g���s���R�Ɍ�����ꍇ�ɖ���������B
// NCHL�p�̃��f�����g���ꍇ���A�X�t�B�A�}�b�v�𖳌��ɂ���B
//#define IGNORE_SPHERE

// �X�t�B�A�}�b�v�̋��x
float3 SphereScale = float3(1.0, 1.0, 1.0) * 0.25;

// �e�X�g�p�F�F�𖳎�����B
//#define DISABLE_COLOR

// �X�y�L�����ɉ����ĕs�����x���グ��B
// �L���ɂ���ƁA�K���X�Ȃǂɉf��n�C���C�g����苭���o��B
// #define ENABLE_SPECULAR_ALPHA

//----------------------------------------------------------
// SSS�p�̐ݒ�

// �t������̌��Ŗ��邭����(�J�[�e����t���ςȂǂɎg��)
//#define ENABLE_BACKLIGHT

// �ގ��ݒ��SSS�ɂ��A�ɂ��񂾌��ɂ��F
#define ScatterColor	MaterialToon
//#define ScatterColor	float3(1.0, 0.6, 0.3)

// SSS���ʂ�L���ɂ��邩�B
// #define ENABLE_SSS

// �\�w�F�\�ʂ̐F
const float3 TopCol = float3(1.0,1.0,1.0);	// �F
const float TopScale = 2.0;					// �����Ƃ̊p�x���ɔ�������x�����B
const float TopBias = 0.01;					// ���ʂłǂ̒��x�e����^���邩
const float TopIntensity = 0.0;				// �S�̉e���x
// �[�w�F�����̐F
const float3 BottomCol = float3(1.0, 1.0, 1.0);	// �F
const float BottomScale = 0.4;			// �����Ƃ̊p�x���ɔ�������x�����B
const float BottomBias = 0.2;			// ���ʂłǂ̒��x�e����^���邩
const float BottomIntensity = 0.0;			// �S�̉e���x

//----------------------------------------------------------
// ���ʏ����̓ǂݍ���
#include "PolishMain_common.fxsub"
