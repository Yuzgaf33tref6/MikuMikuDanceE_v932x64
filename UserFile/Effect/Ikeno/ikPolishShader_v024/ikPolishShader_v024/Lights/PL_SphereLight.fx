//-----------------------------------------------------------------------------
// �X�t�B�A���C�g�p�̐ݒ�
//-----------------------------------------------------------------------------

// �e��`�悷��B0:�`�悵�Ȃ��B1:�`�悷��
#define EnableShadowMap		0
// �e�̃u���[�B0�Ńu���[�Ȃ�
#define ShadowSampleCount	2	// 0-4
// �e�p�o�b�t�@�̃T�C�Y(512,1024,2048,4096)
#define SHADOW_BUFSIZE	2048


// �e�N�X�`�����g�p����B�g�p���Ȃ��ꍇ��0
#define EnableLighTexture	1
// �e�N�X�`���Q�Ƃ̃u���[
#define TextureSampleCount	1	// 0-3
// ���̃e�N�X�`���T�C�Y
#define	TextureSize		512

// ��������C�g�e�N�X�`���Ƃ��Ďg�p����B
// �v�FSaveScreen.x
#define USE_SCREEN_BMP		0


// �t�H�O�̉e�����󂯂�B
// ikPolishShader.fxsub�ŁAFOG_TYPE��2�̏ꍇ�̂ݗL���ɂȂ�B
#define VOLUMETRIC_FOG		1


// ���C�g�̔��a�T�C�Y
// ���l��.pmx�̃��[�t��"���C�g�T�C�Y+"�ƘA��������K�v������
#define LightRadiusMin	( 1.0)	// �f�t�H���g�̃T�C�Y
#define LightRadiusMax	(19.0)	// ���[�t�̃I�t�Z�b�g�T�C�Y

// ���C�g�̓͂��͈� (1MMD�P�ʂ�0.1m)
#define LightDistanceMin	(5.0)
#define LightDistanceMax	(100.0)

//-----------------------------------------------------------------------------
#include "./Sources/Sphere_Light.fxsub"
