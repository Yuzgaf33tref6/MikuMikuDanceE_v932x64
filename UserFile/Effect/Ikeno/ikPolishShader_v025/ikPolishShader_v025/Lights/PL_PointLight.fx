//-----------------------------------------------------------------------------
// �|�C���g���C�g�p�̐ݒ�
//-----------------------------------------------------------------------------

// �e��`�悷��B0:�`�悵�Ȃ��B1:�`�悷��
#define EnableShadowMap		0
// �e�̃u���[�B0�Ńu���[�Ȃ�
#define ShadowSampleCount	2	// 0-4
// �e�p�o�b�t�@�̃T�C�Y(512,1024,2048,4096)
#define SHADOW_BUFSIZE	2048


// �t�H�O�̉e�����󂯂�B
// ikPolishShader.fxsub�ŁAFOG_TYPE��2�̏ꍇ�̂ݗL���ɂȂ�B
#define VOLUMETRIC_FOG		1


// ���C�g�̓͂��͈� (1MMD�P�ʂ�0.1m)
#define LightDistanceMin	(5.0)
#define LightDistanceMax	(100.0)

//-----------------------------------------------------------------------------
#include "./Sources/Point_Light.fxsub"
