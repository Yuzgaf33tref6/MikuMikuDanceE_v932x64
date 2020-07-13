////////////////////////////////////////////////////////////////////////////////////////////////
// �p�[�e�B�N���p�̐ݒ�t�@�C��
//
// ���ꂾ���ύX���Ă��ύX�����f����Ȃ��ꍇ�́AMME��"�S�čX�V"��I������Δ��f����܂��B

// �r���{�[�h(��ɃJ�����ɐ��ʂ�����)�ɂ��邩? 0:���Ȃ��A1:����
#define USE_BILLBOARD	1

// ���q���ݒ�
#define UNIT_COUNT   4   // �����̐��~1024 ����x�ɕ`��o���闱�q�̐��ɂȂ�(�����l�Ŏw�肷�邱��)

#define MMD_LIGHTCOLOR	1	// MMD�̏Ɩ��F�� 0:�A�����Ȃ�, 1:�A������
#define ENABLE_LIGHT	0	// �����v�Z�� 0:���Ȃ��A1:����B
float EmissivePower = 0.3;	// �����v�Z���̃p�[�e�B�N�����̖̂��邳
float Translucency = 0.0;	// ���������銄���B0:�����v�Z�̉e����B1:�����v�Z�̉e�����B

#define TEX_FileName  "dust.png"  // ���q�ɓ\��t����e�N�X�`���t�@�C����
#define TEX_PARTICLE_XNUM   4       // ���q�e�N�X�`����x�������q��
#define TEX_PARTICLE_YNUM   4       // ���q�e�N�X�`����y�������q��

#define TEX_ZBuffWrite      0       // Z�o�b�t�@�̏������� 0:���Ȃ�, 1:���� (�e�N�X�`���Ƀ����߂�����ꍇ��0�ɂ���)

#define USE_SPHERE       0          // �X�t�B�A�}�b�v�� 0:�g��Ȃ�, 1:�g��
#define SPHERE_SATURATE  1          // �X�t�B�A�}�b�v�K�p��� 0:���̂܂�, 1:�F�͈͂�0�`1�ɐ��� ��������0����AutoLuminous�Ŕ�������
#define SPHERE_FileName  "sphere_sample.png" // ���q�ɓ\��t����X�t�B�A�}�b�v�e�N�X�`���t�@�C����

#define PALLET_FileName "palletDust.png"	// ���q�̐F���w�肷��t�@�C��
#define PALLET_TEX_SIZE 64		// �p���b�g�̉���

// ���q�p�����[�^�ݒ�
float ParticleSize = 0.25;          // ���q�傫��
float ParticleSpeedMin = 0.1;    // ���q�����x�ŏ��l
float ParticleSpeedMax = 0.5;    // ���q�����x�ő�l
float ParticleRotSpeed = 1.0;      // ���q�̉�]�X�s�[�h
float ParticleInitPos = 32.0;       // ���q�������̕��U�ʒu(�傫������Ɨ��q�̏����z�u���L���Ȃ�܂�)
float ParticleLife = 16.0;          // ���q�̎���(�b)
float ParticleDecrement = 0.9;     // ���q���������J�n���鎞��(0.0�`1.0:ParticleLife�Ƃ̔�)
float ParticleOccur = 100.0;         // ���q�����x(�傫������Ɨ��q���o�₷���Ȃ�)
float DiffusionAngle = 180.0;       // ���ˊg�U�p(0.0�`180.0)
float FloorFadeMax = 1.0;          // �t�F�[�h�A�E�g�J�n����
float FloorFadeMin = 0.0;          // �t�F�[�h�A�E�g�I������

// �����p�����[�^�ݒ�
float3 GravFactor = {0.0, 0.0, 0.0};	// �d�͒萔
float ResistFactor = 5.0;		// ���x��R��
float RotResistFactor = 4.0;		// ��]��R��(�傫������Ƃ���犴�������܂�)

#define		TimeSync		1


// ���͂̃X�P�[���l
float WindPowerScale = 0.1;

// ���̑��x����
const float MaxWindSpeed = 5.0;	// �ő啗�� (�P�ʂ�MMD/sec)
const float MinWindSpeed = 1.0;		// ����ȉ��̕����͖�������B


// �����蔻��
#define ENABLE_BOUNCE	1		// �����蔻���L���ɂ���
float BounceFactor = 0.5;		// �Փˎ��̒��˕Ԃ藦�B0�`1
float FrictionFactor = 0.9;		// �Փˎ��̌������B1�Ō������Ȃ��B
float IgnoreDpethOffset = 20.0;	// ���ʂ�肱��ȏ��̃p�[�e�B�N���͏Փ˂𖳎�����


// ���ʐݒ�p
#define WATER_CTRL_NAME	"ikUWController.pmx"	// ���ʎw��̃R���g���[����

float FogAmount = 0.01;		// �����ɂ�锼�����x�̑������B�傫�Ȓl�قǂ����ɏ�����B0.0001�`1.0


//-------------------------------------------------------------------------

// �����蔻��p�̃f�[�^�𐶐����邩?
// ���̃p�[�e�B�N���̓����蔻��𗘗p�ł���ꍇ�A0���w�肷�邱�Ƃō������ł���B
#define DRAW_NORMAL_MAP		1

// ���W�����L���鎞�̖��O
// �����̃p�[�e�B�N���G�t�F�N�g���g���ꍇ�A���O���d�����Ȃ��悤�ɂ���K�v������B
#define	COORD_TEX_NAME		ParticleCoordTexDust


// �ݒ肱���܂�
//-------------------------------------------------------------------------

#ifndef AS_SETTING_FILE
#include "../Commons/ikParticle.fxsub"
#endif

