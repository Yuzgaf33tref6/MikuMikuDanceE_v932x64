//-----------------------------------------------------------------------------
// �X�|�b�g���C�g�p�̐ݒ� (�e�t��)
//-----------------------------------------------------------------------------

// �e��`�悷��B0:�`�悵�Ȃ��B1:�`�悷��
#define EnableShadowMap		1
// �e�̃u���[�B0�Ńu���[�Ȃ�
#define ShadowSampleCount	2	// 0-4
// �e�p�o�b�t�@�̃T�C�Y(512,1024,2048,4096)
#define SHADOW_BUFSIZE	1024


// �e�N�X�`�����g�p����B�g�p���Ȃ��ꍇ��0
#define EnableLighTexture	1
// ���̃e�N�X�`���T�C�Y
#define	TextureSize		256


// �t�H�O�̉e�����󂯂�B
// ikPolishShader.fxsub�ŁAFOG_TYPE��2�̏ꍇ�̂ݗL���ɂȂ�B
#define VOLUMETRIC_FOG		1


// ���C�g�̓͂��͈� (1MMD�P�ʂ�0.1m)
#define LightDistanceMin	(5.0)
#define LightDistanceMax	(100.0)

//-----------------------------------------------------------------------------
#include "./Sources/Spot_Light.fxsub"
