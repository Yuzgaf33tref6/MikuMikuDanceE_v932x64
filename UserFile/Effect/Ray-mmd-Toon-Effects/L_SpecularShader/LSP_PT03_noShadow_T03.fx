/////////////////////////////
// L_SpecularShader ver1.00
// �쐬: ������P
/////////////////////////////

// �p�����[�^�錾
/////////////////////////////
float3 SpColor = {0.3,0.3,0.3};  // ����̐F�B
float3 ShadowColor = {0,0,0}; // ����ȊO�̐F�B

float SpecularPow = 15; // ����̑傫��

bool ToonSpecular = 1; // 1�ɂ����Toon���̌���ɂȂ�܂��B

bool ShadowON = 0; // 1�ɂ���Ɖe�͈̔͂Ō��򂪏����܂�

/////////////////////////////
//SSAO�p�����[�^�[
float SSAOPower = 1.0; // SSAO�̋��x�B�O�Ŗ���

/////////////////////////////
// ���X�y�L�����[�}�b�v(�X�y�L�����[�̋��x���e�N�X�`���Œ����B�t���l�����˂ɂ��e�����o�܂�)
// #define USE_HILIGHT_MAP // �g��? (�g��Ȃ��ꍇ�A����//��ǉ����ăR�����g�A�E�g)
#define HILIGHT_PATH "tex/specular_test.png"

/////////////////////////////
// ���@���}�b�v(�@���̕�����ς��ĉ��ʊ��A�d��)
// #define USE_NORMAL_MAP // �g��? (�g��Ȃ��ꍇ�A����//��ǉ����ăR�����g�A�E�g)
#define NORMAL_MAP_PATH "tex/normal_test.png"


#include "_LSPCommon.fxsub"
