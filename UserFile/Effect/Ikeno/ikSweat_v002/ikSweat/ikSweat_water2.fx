
// �傫�߂ŁA�����؂��������B


// �v���Z�b�g�̒l���g�����ǂ����B0�̏ꍇ�̓A�N�Z�T���Őݒ肵���p�����[�^���g����B
#define USE_PRESET	1

#if defined(USE_PRESET) && USE_PRESET > 0
// ���H�̑傫�� (0.5�`4.0 ���������߂���ƋO�Ղ��r�؂��)
const float ParticleSize = 1.5;
// �O�Ղ��������x(1�����ɂ��邱�ƁB1�ɋ߉߂���ƖO�a���ăt���b�g�ɂȂ�B)
const float DryRate = 0.94;
// ���H�̗������x (���߂���ƋO�Ղ��r�؂��)
const float FallSpeedRate = 2.0;
// ���H�̌��� (0.5�`4.0���x�B�傫���قǌ���)
const float Thickness = 1.0;
// �������x: 1.0 (�s����)
const float MaterialAlpha = 0.03;
// �����܂ł̎��Ԃ̉����x
const float LifetimeScale = 1.0;
#endif


// ���H����������܂ł̍ŏ�����
const float LifetimeMin = 0.1;
// ���H����������܂ł̗h�ꕝ
// LifetimeMin �` LifetimeMin+LifetimeFluctuation �������܂ł̊Ԃɗ�������B
const float LifetimeFluctuation = 0.1;

// �����������H�����ł���܂ł̎���
const float DurationMin = 60.0;
// ���ł���܂ł̎��Ԃ̗h�ꕝ
const float DurationFluctuation = 30.0;


// ���H�̐F�B
const float3 MaterialColor = float3(1,1,1);

// ���H�̌����v�Z�ŁA���̉e�����ǂꂾ���キ���邩�B
const float AmbientPower = 0.5;
// �n�C���C�g�̉s���F�p�x�ɑ΂��锽���̉s��
const float Smoothness = 0.40;			// 0.3�`0.5���x
// �n�C���C�g�̋��x�F�n�C���C�g�̖��邳
const float SpecularScale = 1.5;

// ���H�̉e�̐F�B���f���̐F�Ɉˑ��B
const float3 MaterialShadowColor = float3(162/255.0,110/255.0,98/255.0);
// �e�̔Z��
const float ShadowPower = 0.5;


// 0�t���Đ����ɐ��H��������? (0:�����Ȃ��B1:����)
#define RESET_AT_START		0

// ���[�N�p�e�N�X�`���̃T�C�Y
#define	TEX_SIZE	1024
#define	TRAIL_TEX_SIZE	1024		// �O�՗p

// �ҏW���[�h�ŃG�t�F�N�g���~�߂�
#define STOP_IN_EDITMODE	0

// �e�`�F�b�N���ɑΏۗ̈����h�邩?
#define	DISPLAY_TARGET_AREA	0

// �e�N�X�`����ɉ��̉J���p�^�[�������邩?
static int NumRaindropInTextureW = 4;	// ������
static int NumRaindropInTextureH = 1;	// �c����

// ���[�V�����ɂ��e��
#define USE_MOTION		0
const float MovemenScale = 0.1;			// �����̉e���x
const float MaxMovement = 1.0;			// �ړ����
const float StaticFriction = 0.1;		// ��~���̐��H�́A����ȉ��̑��x�̓����𖳎�����
const float Friction = 0.95;			// ���x�̌�����(1�����ɂ��邱��)


