///////////////////////////////////////////////////////////////////////////////////////////////
//
////////////////////////////////////////////////////////////////////////////////////////////////
// �p�����[�^�錾

// �p�l���̒��S�ƂȂ�A�N�Z�T����
// ���f�����g�̏ꍇ��(self)���w�肷��B�A�N�Z�T���Ȃǂ̏ꍇ�́A.x�ȂǊg���q�܂Ŏw�肷��B
#define	PanelObjectName		"(self)"
// �p�l���̒��S�ƂȂ�{�[����
// �{�[�����s�v�ȏꍇ�́A#define�̑O��//�����ăR�����g�A�E�g����B
//#define	PanelBoneName		"�Z���^�["
#define	PanelBoneName		"�㔼�g"

// �_�~�[�e
// ���f���̋����Ƃ͕ʂɃp�l���𓮂��������ꍇ�p�B
// �g�p���Ȃ��ꍇ�́AParentObjectName �̍s����//������B
#define	ParentObjectName		"dummyParent.pmx"
#define	ParentBoneName			"�{�[��08"


// �p�l���̗]�������̐F
float3 PanelColor = float3(1.0,1.0,1.0);
float3 PanelShadowColor = float3(1.0,1.0,1.0) * 0.8; // �e�̔Z��
float3 PanelAmbient = float3(1.0,1.0,1.0) * 0.4; // ���C�g��(0,0,0)�̂Ƃ��̖��邳

// �p�l���S�̂̃X�y�L����
float PanelSpecularPower = 32.0;
float3 PanelSpecularColor = float3(1.0,1.0,1.0);

// �p�l���̗]���B1.0 = 1MMD �� 10cm
float	PanelMargin = 0.4;
// �p�l���̃G�b�W�T�C�Y�B
float	PanelThickness = 0.03;
// �p�l���̐[�x��������ʁB
float	PanelDepthOffset = 0.5;

// ���݂�ׂ����B
// �O��֌W���j���񂵂ă`�����ꍇ�́A�傫�߂̒l�ɂ���B�傫���l�قǌ��݂�������
#define	SqueezeScale	0.1

// �p�l���̉�]��{�ɂ���B0: 1�{�B1: 2�{
#define ENABLE_TWICE_ROTATION	0

// �p�l���̉���`�悷��B0:�`�悵�Ȃ��B1:�`�悷��B
#define ENABLE_DRAW_EDGE	1

// �p�l�����̃��f�����A�e�v�Z���s�����B0:�A�e�v�Z�����Ȃ��B1:����B
// �p�l���ƃ��f�������ɗ����e���o����ȂǁA���̊�������ƁA�������������邱�Ƃ�����B
#define ENABLE_INNER_LIGHTING	1
// �X�t�B�A�}�b�v�̌v�Z���s��? 0:�s��Ȃ��B1:�s���B
// ENABLE_INNER_LIGHTING 0�̏ꍇ�A��ɃX�t�B�A�}�b�v���v�Z���Ȃ��B
#define ENABLE_SPHERE_MAP		0
// ���f�����̃V���h�E�}�b�v��L���ɂ���B
#define ENABLE_SHADOW_MAP		0


////////////////////////////////////////////////////////////////////////////////////////////////

#include "ikPaper.fxsub"

