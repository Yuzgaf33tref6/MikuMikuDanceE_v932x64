//-----------------------------------------------------------------------------
// �K���X�Ȃǂ̔������p�B�X�y�L�������������x�̉e�����󂯂Ȃ��B

//----------------------------------------------------------
// SSS�p�̐ݒ�

// �x���x�b�g���ʂ�L���ɂ��邩?
#define ENABLE_VELVET	0
const float VelvetExponent = 2.0;			// ���̑傫��
const float VelvetBaseReflection = 0.01;	// ���ʂł̖��邳 
#define VELVET_MUL_COLOR		float3(0.50, 0.50, 0.50)	// ���ʂ̐F(��Z)
#define VELVET_MUL_RIM_COLOR	float3(1.00, 1.00, 1.00)	// ���̐F(��Z)
#define VELVET_ADD_COLOR		float3(0.00, 0.00, 0.00)	// ���ʂ̐F(���Z)
#define VELVET_ADD_RIM_COLOR	float3(0.00, 0.00, 0.00)	// ���̐F(���Z)

//----------------------------------------------------------
// �X�y�L�����֘A

// �N���A�R�[�g����
// ���f���̏�ɓ����ȃ��C���[��ǉ�����B
#define ENABLE_CLEARCOAT		0			// 0:�����A1:�L��
const float USE_POLYGON_NORMAL = 1.0;		// �N���A�R�[�g�w�̖@���}�b�v�𖳎�����?
const float ClearcoatSmoothness =  0.95;		// 1�ɋ߂Â��قǃX�y�L�������s���Ȃ�B(0�`1)
const float ClearcoatIntensity = 0.5;		// �X�y�L�����̋��x�B0�ŃI�t�B(0�`1.0)
const float3 ClearcoatF0 = float3(0.05,0.05,0.05);	// �X�y�L�����̔��˓x
const float4 ClearcoatColor = float4(1,1,1, 0.0);	// �N���A�R�[�g�̐F

// �X�t�B�A�}�b�v�����B
#define IGNORE_SPHERE	1

// �X�t�B�A�}�b�v�̋��x
float3 SphereScale = float3(1.0, 1.0, 1.0) * 0.1;

// �X�y�L�����ɉ����ĕs�����x���グ��B
// �L���ɂ���ƁA�K���X�Ȃǂɉf��n�C���C�g����苭���o��B
// ���ȂǃA���t�@�������Ă���ꍇ�̓G�b�W�ɋ����n�C���C�g���o�邱�Ƃ�����B
#define ENABLE_SPECULAR_ALPHA	1


//----------------------------------------------------------
// ���̑�

#define ToonColor_Scale			0.5			// �g�D�[���F����������x�����B(0.0�`1.0)

// �A���t�@���J�b�g�A�E�g����
// �t���ςȂǂ̔����e�N�X�`���ŉ��������Ȃ�ꍇ�Ɏg���B
#define Enable_Cutout	1
#define CutoutThreshold	(1/255.0)		// ����/�s�����̋��E�̒l


//----------------------------------------------------------
// ���ʏ����̓ǂݍ���
#include "Sources/PolishMain_common.fxsub"
