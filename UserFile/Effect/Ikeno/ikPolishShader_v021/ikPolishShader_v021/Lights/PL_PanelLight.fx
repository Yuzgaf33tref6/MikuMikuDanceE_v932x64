//-----------------------------------------------------------------------------
// �p�l�����C�g�p�̐ݒ�
//-----------------------------------------------------------------------------

// �e��`�悷��B0:�`�悵�Ȃ��B1:�`�悷��
#define EnableShadowMap		0
// �e�̃u���[�B0�Ńu���[�Ȃ�
#define ShadowSampleCount	2	// 0-4���x
// �\�t�g�V���h�E��L���ɂ���B0:�����A1:�L��
#define EnableSoftShadow	0
// �e�p�o�b�t�@�̃T�C�Y(512,1024,2048,4096)
#define SHADOW_BUFSIZE	1024


// �e�N�X�`�����g�p����B�g�p���Ȃ��ꍇ��0
#define EnableLighTexture	1
// ���̃e�N�X�`���T�C�Y
#define	TextureSize		256

// ��������C�g�e�N�X�`���Ƃ��Ďg�p����B
// �v�FSaveScreen.x
#define USE_SCREEN_BMP		0


// ���C�g�̓͂��͈� (1MMD�P�ʂ�0.1m)
#define LightDistanceMin	(5.0)
#define LightDistanceMax	(100.0)

// ���C�g�̃T�C�Y
// �����l��.pmx�̃��[�t��"���C�g��+/��+"�ƘA��������K�v������
#define LightWidthMin	( 1.0)	// �f�t�H���g�̃T�C�Y
#define LightHeightMin	( 1.0)	// �f�t�H���g�̃T�C�Y
#define LightWidthMax	(19.0)	// ���[�t�̃I�t�Z�b�g�T�C�Y
#define LightHeightMax	(19.0)	// ���[�t�̃I�t�Z�b�g�T�C�Y

//-----------------------------------------------------------------------------
#include "./Sources/Panel_Light.fxsub"
