//--------------------------------------------------------------//
// ikLensGhost
//--------------------------------------------------------------//

const bool UseCustomLightColor <
   string UIName = "UseCustomLightColor";
   string UIWidget = "Numeric";
   string UIHelp = "�Ǝ��̃��C�g�F���g�p���邩";
   bool UIVisible =  true;
> = false;

const float3 CustomLightColor <
   string UIName = "CustomLightColor";
   string UIWidget = "Color";
   string UIHelp = "���C�g�F";
   bool UIVisible =  true;
> = float3( 154.0/255.0, 154.0/255.0, 154.0/255.0);

const float FlareIntensity
<
   string UIName = "FlareIntensity";
   string UIWidget = "Slider";
   string UIHelp = "���C�g�̋��x";
   bool UIVisible =  true;
   float UIMin = 0.00;
   float UIMax = 10.0;
> = float( 1.0 );
const float GhostIntensity
<
   string UIName = "GhostIntensity";
   string UIWidget = "Slider";
   string UIHelp = "�S�[�X�g�̋��x";
   bool UIVisible =  true;
   float UIMin = 0.00;
   float UIMax = 10.0;
> = float( 0.5 );
const float DirtIntensity
<
   string UIName = "DirtIntensity";
   string UIWidget = "Slider";
   string UIHelp = "�����Y�_�[�g�̋��x";
   bool UIVisible =  true;
   float UIMin = 0.00;
   float UIMax = 10.0;
> = float( 1.0 );

// +���ƐԂ��ۂ��A-���Ɛ��ۂ��Ȃ�
const float ColorShiftRate
<
   string UIName = "ColorShiftRate";
   string UIWidget = "Slider";
   string UIHelp = "�F�Y������x����";
   bool UIVisible =  true;
   float UIMin = -0.2;
   float UIMax = 0.2;
> = float( 0.2 );

const float ColorEmphasizeRate
<
   string UIName = "ColorEmphasizeRate";
   string UIWidget = "Slider";
   string UIHelp = "�F�Y���̃R���g���X�g����������x����";
   bool UIVisible =  true;
   float UIMin = 0.0;
   float UIMax = 1.0;
> = float( 0.5 );

const float GhostBrightness <
   string UIName = "GhostBrightness";
   string UIWidget = "Numeric";
   string UIHelp = "�S�[�X�g�̖��邳";
   bool UIVisible =  true;
   float UIMin = 0.0;
   float UIMax = 1.0;
> = float( 0.75 );

const float GhostBulriness <
   string UIName = "GhostBlurriness";
   string UIWidget = "Numeric";
   string UIHelp = "�S�[�X�g�̃{�P�x��";
   bool UIVisible =  true;
   float UIMin = 1.0;
   float UIMax = 4.0;
> = float( 2.0 );

const float GhostDistortion <
   string UIName = "GhostDistortion";
   string UIWidget = "Numeric";
   string UIHelp = "�S�[�X�g�̘c�ݓx��";
   bool UIVisible =  true;
   float UIMin = 0.0;
   float UIMax = 1.0;
> = float( 0.75 );

// �����Y�t���A�̈ꕔ������������
// �S�̂̃T�C�Y��Si�Œ���
#define		MiniSizeFlare		0

// ���C�g�����ɏo��S�[�X�g
#define		FlareMainTexName	"LensFlareMain.png"
// ���C�g�̎��͂ɏo��S�[�X�g
#define		FlareSubTexName		"LensFlareSub.png"

// �J�����\�ʂ̉���
// �g�p���Ȃ��ꍇ�́A#define�̑O��//������B
#define		DirtTexName			"LensDirt.png"


// ���C�g��������Ƀ����Y�t���A���o��
// 0�̏ꍇ�A�A�N�Z�T���̈ʒu����Ƀ����Y�t���A���o��
#define USE_LIGHT_POSITION		0


//--------------------------------------------------------------//

#include "lensGhost_common.fxsub"

//--------------------------------------------------------------//
