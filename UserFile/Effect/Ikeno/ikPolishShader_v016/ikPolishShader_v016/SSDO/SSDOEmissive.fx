///////////////////////////////////////////////////////////////////////////////
//
///////////////////////////////////////////////////////////////////////////////

#include "../ikPolishShader.fxsub"

// ���Ȕ����F�̋����B(0.0�`1.0)
#define EmissiveIntensity	1.0

// �����̋���
#define AmbientIntensity	0.2

// ���ˋ��x
#define GI_SCALE			0.5

// �F�̋����x��(1�`4)
#define COLOR_BOOST			2


//------------------------------------
// AutoLuminous�p�̐ݒ�
// AL���g�p����
#define ENABLE_AL

//�e�N�X�`�����P�x���ʃt���O
// #define TEXTURE_SELECTLIGHT

// AL�̋��x���ǂꂾ���グ�邩
#define AL_Power	1.0

//臒l
float LightThreshold = 0.9;
//------------------------------------

#include "SSDO_common.fxsub"

///////////////////////////////////////////////////////////////////////////////
