--�g����--
Wind.x��MMD�œǂݍ��߂Ε\������܂��B
�p�x��傫���w��ȂǁA�ʏ�̃A�N�Z�T���Ɠ��l�ɍs�������ł��܂��B

�ꕔ�O���t�B�b�N�{�[�h�Ŏg�p�ł��Ȃ����K�{�ȈׁA
�\���󂠂�܂��񂪌���Ή����o���Ȃ���Ԃł��c

--�p�����[�^����--�i���l�̓f�t�H���g�̕��j

//�����̖{��
int CloneNum = 64;
60F���Ő�������镗�̖{����ݒ肵�܂��B

//�e�N�X�`����
texture Aura_Tex1
<
   string ResourceName = "Wind_Tex.png";
>;
���p�̃e�N�X�`����ݒ肵�܂��B
�e�N�X�`����V�����p�ӂ�����A�t���̕���M���Ă݂Č��ʂ��m�F���Ă݂Ă��������B

//�S�̂̍Đ����x
float AnmSpd = 1;
�A�j���[�V�����S�̂̐i�s���x��ݒ肵�܂��B

//�S�̂̍���
float Height = 1;
���̐L�сH��ݒ肵�܂��B

//�z�u���̒�������̂���̗�����
float SetPosRand = 0.1;
XZ���W��iMMD��ŉ�]��g���������O�́j�̃u����ݒ肵�܂��B

//���ЂƂЂƂ̍����ő�l
float LocalHeight = 0.5;
���G�t�F�N�g���̍����ő�l��ݒ肵�܂��B
���������邱�Ƃōׂ��ȃG�t�F�N�g�ɂȂ�܂��B

//���̍L���苭��
float WindSizeSpd = 1;
�����g�U���鋭����ݒ肵�܂��B

//�L����̗�����
float WindSizeRnd = 1;
�����Ŏw�肵���������A�e���ɍL���葬�x�̃u�����^�����܂��B

//�e�N�X�`���J��Ԃ���
float ScrollNum = 1;
���G�t�F�N�g��U�l�̌J��Ԃ�����ݒ肵�܂��B
�f�t�H���g�e�N�X�`���ł͂P�����B

//�F�ݒ�
float3 Color = float3( 0, 0, 0 );
���ɒ��F����F��R,G,B�Őݒ肵�܂��B

//���邳
float Brightness = 10;
�F�̋��x��ݒ肵�܂��B

//�c�ݗ�
float DifPow = 1.0;
�c�݃G�t�F�N�g�̍ہA�w�i���Ђ��ς鋗����ݒ肵�܂��B
���܂�傫�����߂���Ƌt�Ɍ��ʂ��킩��Â炭�Ȃ�܂��B

//�S�̂̉�]���x
float RotateSpd = 0.5;
�G�t�F�N�g�S�̂�Y����]�̑��x��ݒ肵�܂��B
�i�p�^�[���ۂ��y���ׁ̈j

//�ʉ�]�W���i�X���̂΂���j
float RotateRatio = 0.05;
������XZ����]�̂΂���x��ݒ肵�܂��B
0�ɂ����ꍇXZ���ʏ�ɁA1�ɂ����ꍇ�S���͂Ɍ������Đ�������܂��B

//�ŏ����a
float MinSize = 1;
�������̍ŏ����a��ݒ肵�܂��B

//���ˎ��ԃI�t�Z�b�g�i�����_���l�j
float ShotRandOffset = 0;
�������x�̃u����ݒ肵�܂��B