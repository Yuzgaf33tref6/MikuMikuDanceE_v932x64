// �G�ꂽ�������Â��Ȃ����
// �R���N���[�g������z�ȂǁB

#define	PROSITY				0.5		// �G�ꂽ�����������Ȃ�x��
#define	TRANSLUCENCE		0.0		// �G�ꂽ�����������ɂȂ�x��

#define	TEXTURE_LOOP		2		// �e�N�X�`���̌J��Ԃ���

#define	SPECULAR_POWER		48
#define	SPECULAR_INTENSITY	1.0

// ikPolishShader�̖@���}�b�v�𗬗p����?
#define USE_POLISH_NORMAL	0

// �e�N�X�`���ɂ��G��x�����̎w��
#define TRANSLUCENCE_MASK	"masktest.png"
#define TRANSLUCENCE_MASK_MODE	1 // 0:�������A1:�V����
// �V�����ł́A
// R: �����x����
// G: �����e�����u�ԃX�y�L�������x
// B: �G�ꂽ�Ƃ��̍����Ȃ�x�����B���w��B
// ���قǃG�t�F�N�g�̉e�����󂯂Â炭�A���قǉe�����󂯂�B
// �������ł́A�ԃ`�����l���݂̂��Q�Ƃ��Ă����B


//-----------------------------------------------------------------------------

#include "WetMapCommon.fxsub"
