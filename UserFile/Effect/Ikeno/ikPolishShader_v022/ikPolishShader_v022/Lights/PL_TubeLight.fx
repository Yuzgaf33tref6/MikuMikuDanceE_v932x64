//-----------------------------------------------------------------------------
// �`���[�u���C�g�p�̐ݒ�
//-----------------------------------------------------------------------------

// �e��`�悷��B0:�`�悵�Ȃ��B1:�`�悷��
#define EnableShadowMap		0
// �e�̃u���[�B0�Ńu���[�Ȃ�
#define ShadowSampleCount	2	// 0-4
// �e�p�o�b�t�@�̃T�C�Y(512,1024,2048,4096)
#define SHADOW_BUFSIZE	2048

// ���C�g�̓͂��͈� (1MMD�P�ʂ�0.1m)
#define LightDistanceMin	(5.0)
#define LightDistanceMax	(100.0)

// ���C�g�̃T�C�Y
// �����l��.pmx�̃��[�t��"���C�g��+/��+"�ƘA��������K�v������
#define LightWidthMin	( 0.1)	// �f�t�H���g�̃T�C�Y
#define LightHeightMin	( 1.0)	// �f�t�H���g�̃T�C�Y
#define LightWidthMax	( 0.1)	// ���[�t�̃I�t�Z�b�g�T�C�Y
#define LightHeightMax	( 9.0)	// ���[�t�̃I�t�Z�b�g�T�C�Y

//-----------------------------------------------------------------------------
#include "./Sources/Tube_Light.fxsub"
