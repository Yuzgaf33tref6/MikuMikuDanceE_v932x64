////////////////////////////////////////////////////////////////////////////////////////////////
//
//  EnvMapRT�p�V�F�[�_�[�F�ʏ�̃I�u�W�F�N�g�p
//
//  ���͉��P�쐬�̓��I�o�����ʊ��}�b�v ver1.0 ��������������
//
////////////////////////////////////////////////////////////////////////////////////////////////
// �p�����[�^�錾

#define IGNORE_SPHERE

// AutoLuminus�Ή�
#define ENABLE_AL
// �e�N�X�`���Ŏw�肷��
// #define TEXTURE_SELECTLIGHT
// AL�̋��x���ǂꂾ���グ�邩
#define AL_Power	4.0
//臒l
float LightThreshold = 0.9;

// �����Ō���ގ���?
// PMXEditor�̊��F�����C�g�̋����̉e�����󂯂�悤�ɂ���B
//#define EMMISIVE_AS_AMBIENT	// ���Ȕ����F���A���r�G���g�F�Ƃ��Ĉ���
#define IGNORE_EMISSIVE			// ���Ȕ����F�̐ݒ�𖳌��ɂ���B

#include "TEnvMap_common.fxsub"


