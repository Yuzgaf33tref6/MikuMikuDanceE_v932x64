////////////////////////////////////////////////////////////////////////////////////////////////
//
//  EnvMapRT�p�V�F�[�_�[�Fraymmd��skyspec_hdr.dds�����}�b�v�Ƃ��Ďg���ꍇ�p�̐ݒ�
//
////////////////////////////////////////////////////////////////////////////////////////////////
// �p�����[�^�錾

// �X�t�B�A�}�b�v����
#define IGNORE_SPHERE

// AutoLuminus�Ή�
// #define ENABLE_AL

// �e�N�X�`���Ŏw�肷��
// #define TEXTURE_SELECTLIGHT

// AL�̋��x���ǂꂾ���グ�邩
#define AL_Power	1.0

//臒l
float LightThreshold = 0.9;

// PMXEditor�̊��F�����C�g�̋����̉e�����󂯂�悤�ɂ���B
//#define EMMISIVE_AS_AMBIENT	// ���Ȕ����F���A���r�G���g�F�Ƃ��Ĉ���
//#define IGNORE_EMISSIVE			// ���Ȕ����F�̐ݒ�𖳌��ɂ���B

// �K���}�␳�ς̃e�N�X�`����?
#define IS_LINEAR_TEXTURE

// �e�N�X�`����RGBM�Ƃ��Ĉ���?
#define USE_TEXTURE_AS_RGBM
// RGBM�̌W���BUE4�n�Ȃ�6�AUnity�n�Ȃ�8���w��
#define RGBM_SCALE_FACTOR	6

#include "TEnvMap_common.fxsub"

