////////////////////////////////////////////////////////////////////////////////////////////////
//
//  EnvMapRT�p�V�F�[�_�[�FHDR2RGBM�ŃR���o�[�g����.rgbm�e�N�X�`�����g���X�J�C�h�[���p
//
////////////////////////////////////////////////////////////////////////////////////////////////
// �p�����[�^�錾

// �X�t�B�A�}�b�v����
#define IGNORE_SPHERE

// AutoLuminous�Ή�
// #define ENABLE_AL

// �e�N�X�`���Ŏw�肷��
// #define TEXTURE_SELECTLIGHT

// AL�̋��x���ǂꂾ���グ�邩
#define AL_Power	1.0

//臒l
float LightThreshold = 0.9;

// PMXEditor�̊��F�����C�g�̋����̉e�����󂯂�悤�ɂ���B
//#define EMISSIVE_AS_AMBIENT	// ���Ȕ����F���A���r�G���g�F�Ƃ��Ĉ���
//#define IGNORE_EMISSIVE			// ���Ȕ����F�̐ݒ�𖳌��ɂ���B

// �K���}�␳�ς̃e�N�X�`����?
#define IS_LINEAR_TEXTURE

// �e�N�X�`����RGBM�Ƃ��Ĉ���?
#define USE_TEXTURE_AS_RGBM

#include "TEnvMap_common.fxsub"

