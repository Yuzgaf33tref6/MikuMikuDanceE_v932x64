PostClip ver0.0.1

�����̃|�X�g�G�t�F�N�g���w��̈�ŃN���b�v���āA�G�t�F�N�g���|����͈͂𐧌����܂��B
�|�X�g�G�t�F�N�g�ł���΂ǂ̃G�t�F�N�g�ł��Ή��\�ł��B
�N���b�v�̕��@�͒P���ȗ̈�w�肾���łȂ��A�[�x��@���Ȃ�MMD��3D���ɉ����ăN���b�v
���邱�Ƃ��\�A�������̃N���b�v������_���W���̂悤�ɍ������邱�Ƃ��o����̂�
���p����ŗl�X�ȕ\���Ɏg����̂łȂ����Ǝv���܂��B


�������
MMEv0.37, MMEv0.37x64�œ���m�F���s���Ă��܂��B���o�[�W�����ł͓��삵�Ȃ��\��������܂��B



����{�I�Ȏg�p���@ (���łɊ����̃|�X�g�G�t�F�N�g�����[�h����Ă���Ƃ��܂�)

(1)�܂��� PreClip.x ��MMD�Ƀ��[�h���Ă��������B���̃G�t�F�N�g�͕K�{�ł��B

(2)���� PostClip�`.x �̓��A�N���b�v�̎�ނɉ����ĕK�v�ȃG�t�F�N�g�����[�h���܂��B��x�ɕ����̃��[�h���ł��B
   �N���b�v�̎�ނ̓t�@�C�����ɉ����Ĉȉ��̂悤�ɂȂ��Ă��܂��B
     PostClip_Mask     : �}�X�N�摜�𗘗p�����N���b�v
     PostClip_Obj      : ���f���̌`��ɉ������N���b�v
     PostClip_ColorKey : �J���[�L�[��p�����N���b�v
     PostClip_Bright   : �X�N���[���P�x�ɉ������N���b�v
     PostClip_Depth    : ���f���̐[�x�ɉ������N���b�v
     PostClip_Distance : �w��ʒu�����苗�����N���b�v
     PostClip_Height   : ���f���̍����ɉ������N���b�v
     PostClip_Normal   : ���f���̖@���ɉ������N���b�v

(3)�N���b�v�������|�X�g�G�t�F�N�g��`�揇���� PreClip.x �� PostClip�`.x �̊Ԃɋ��݂܂��B
    ��)�`�揇�����̂悤�ɂ���ƃ|�X�g�G�t�F�N�gB,�|�X�g�G�t�F�N�gC���N���b�v�̑ΏۂɂȂ�܂��B
       �|�X�g�G�t�F�N�gA
       PreClip
       �|�X�g�G�t�F�N�gB
       �|�X�g�G�t�F�N�gC
       PostClip_Obj
       �|�X�g�G�t�F�N�gD

(4)PostClip�`.x �̃A�N�Z�T������� X=1 �ɂ���ƃN���b�v�����s����܂�(X=0�͌�q�̘_�������Ŏg�p)�B



���e�N���b�v�̑�����@

  PostClip�`.x�ɂ��Ă͋��ʃp�����[�^�Ƃ���MMD�̃A�N�Z�T�����삩��ȉ��̕ύX���\�ł��B
      X,Y,Z : �����̃N���b�v�Ř_���������s���܂�(��q)
      Tr�F���̃N���b�v�̊|����

  ���̑��̃p�����[�^�ɂ��Ă͊e�N���b�v�ŗL�̑���ɂȂ�܂��B

(1)PostClip_Mask�ɂ���
   �@PostClip_Mask.fx�̐擪�p�����[�^�Ń}�X�N�摜�̃t�@�C�������w�肵�Ă��������B
     �}�X�N�摜�͋g���g���̃g�����W�V�������C�u���������g���₷���ł�(http://kikyou.info/tvp/)�B
   �AMMD�̃A�N�Z�T�����삩��ȉ��̕ύX���\�ł��B
     Rx = 0:�}�X�N�摜�ɉ������t�F�[�h�C��,�t�F�[�h�A�E�g���o���܂��B
     Rx = 1:�}�X�N�摜�̔Z�x�����̂܂܃N���b�v�͈͂ɂȂ�܂��B
     Si�F(0�`1)�l���������ƃt�F�[�h�̕ω����V���[�v�ő傫���ƃ}�C���h�ɂȂ�܂��B
     Tr : Rx=0 �̎��̓t�F�[�h�̐i�s�x�C0�ŃN���b�v�����C1�őS�N���b�v

(2)PostClip_Obj�ɂ���
   �@�MMEffect�����G�t�F�N�g�������PC_ObjRT�^�u���N���b�v���������f����I������ PC_Object.fx ��K�p���܂��B

(3)PostClip_ColorKey�ɂ���
   �@PostClip_ColorKey.fx�̐擪�p�����[�^�ŃJ���[�L�[��臒l���w�肵�Ă�������(MME�̂�,MMM�̓G�t�F�N�g�v���p�e�B�ŕύX)�B
   �AMMD�̃A�N�Z�T�����삩��ȉ��̕ύX���\�ł��B
     Rx,Ry,Rz : ���ꂼ�� �J���[�L�[��R,G,B�F(0�`1)�ɑΉ����Ă��܂��B
     Si�F臒l����̃N���b�v�x�A�傫���ƃ}�C���h�ɂȂ菬�����ƃV���[�v�ȃN���b�v�ɂȂ�܂��B

(4)PostClip_Bright�ɂ���
   �@MMD�̃A�N�Z�T�����삩��ȉ��̕ύX���\�ł��B
     Rx : �P�x��臒l�I�t�Z�b�g(-1�`+1)(�N���b�v����P�x�͈̔͂��ς��܂�)�B
     Si�F臒l����̃N���b�v�x�A�傫���ƃ}�C���h�ɂȂ菬�����ƃV���[�v�ȃN���b�v�ɂȂ�܂��B

(5)PostClip_Depth�ɂ���
   �@MMD�̃A�N�Z�T�����삩��ȉ��̕ύX���\�ł��B
     Rx : �N���b�v���I���O���̐[�x
     Ry : �N���b�v���J�n�������̐[�x

(6)PostClip_Distance�ɂ���
   �@MMD�� PC_DistanceOrg.x �����[�h���Ă��������B�N���b�v����͈͂͂��̃A�N�Z���W����̋����Ō��܂�܂��B
     MMM�̏ꍇ�� PostClip_Distance.x �̍��W����̋����Ō��܂�̂ł��̍s���͕K�v����܂���B
   �AMMD�̃A�N�Z�T�����삩��ȉ��̕ύX���\�ł��B
     Rx : �N���b�v�`��AOFF:�A�N�Z���W����S���ʓ�������(���`)�ŃN���b�v, ON:�A�N�Z���W���瓙��������(�~���`)�ŃN���b�v
     Ry : �N���b�v���E�̊K������
     Si : �N���b�v���鋗��

(7)PostClip_Height�ɂ���
   �@MMD�̃A�N�Z�T�����삩��ȉ��̕ύX���\�ł��B
     Rx : �N���b�v���J�n���鉺���̍���
     Ry : �N���b�v���I������̍���

(8)PostClip_Normal�ɂ���
   �@PostClip_Normal.fx�̐擪�p�����[�^��K�v�ɉ����ēK�X�ύX���܂�(MME�̂�,MMM�̓G�t�F�N�g�v���p�e�B�ŕύX)�B
   �AMMD�̃A�N�Z�T�����삩��ȉ��̕ύX���\�ł��B
     Rx,Ry,Rz : �N���b�v����@���x�N�g���̉�]�p(�����l�͐^�����)
     Si�F臒l����̃N���b�v�x�A�傫���ƃ}�C���h�ɂȂ菬�����ƃV���[�v�ȃN���b�v�ɂȂ�܂��B



���N���b�v�̘_�������ɂ���
���̃G�t�F�N�g�ł͕����̃N���b�v������g�ݍ���āA�_���W���̂悤�ɃN���b�v����͈͂��������邱�ŁA
���G�ȃN���b�v�͈͎w�肪�\�ł��B

PostClip�`.x�ɂ��āA�N���b�v�����ɕK�v�ȋ��ʃp�����[�^�Ƃ���MMD�̃A�N�Z�T�����삩��ȉ��̕ύX���\�ł��B
(MME�̂�,MMM�̓G�t�F�N�g�v���p�e�B�ŕύX)�B

      X = 0:�����ł̓N���b�v�����s������̃N���b�v�̍����Ɏg��, 1:�N���b�v�����s����B
          (�����̃N���b�v��g�ݍ��킹��ɂ͍Ō�̃N���b�v����1�ŁA����0���܂�)
      Y = 0:�O�̃N���b�v�Ƃ̘_���a�����ɂȂ�, 1:�O�̃N���b�v�Ƃ̘_���ύ����ɂȂ�B
          (�ŏ��̃N���b�v�ɂ��Ă͋�W���Ƃ̍���,���Ȃ킿0�ł��̃N���b�v���s��1�ŃN���b�v���Ȃ��Ȃ�)
      Z = ���̃N���b�v�̔��](�_���ے�)

    ��)���̂悤�ȕ`�揇�ƃp�����[�^�w��ł́APostClip_Depth��PostClip_Obj���]�̘_����(PostClip_Depth��
       �[�x�ɂ��N���b�v����������PostClip_Obj�Ŏw�肵�����f���������N���b�v����Ȃ�)�ɂȂ�܂��B

       PreClip
       �|�X�g�G�t�F�N�gA
       �|�X�g�G�t�F�N�gB
       PostClip_Depth   ��X=0,Y=0,Z=0
       PostClip_Obj     ��X=1,Y=1,Z=1



��MikuMikuMoving�ɂ���
���̃G�t�F�N�g��MikuMikuMoving�ɂ��Ή����Ă��܂��B
PreClip.fx�y�ъePostClip�`.fx�𒼐�MikuMikuMoving�Ƀ��[�h���Ă����p�������B
�e�p�����[�^��MMM�̃G�t�F�N�g�v���p�e�B���ύX���\�ł��B
PostClip_Obj.fx �̃I�t�N���[���^�u�ł̓N���b�v���������f���� PC_ObjectMMM.fx ��K�p���Ă��������B



���X�V����
v0.0.1  2014/4/7   ����Ō��J


���Ɛӎ���
�����p�E���ρE�񎟔z�z�͎��R�ɂ���Ă��������Ă��܂��܂���B�A�����s�v�ł��B
�����������̍s�ׂ͑S�Ď��ȐӔC�ł���Ă��������B
���̃v���O�����g�p�ɂ��A�����Ȃ鑹�Q���������ꍇ�ł������͈�؂̐ӔC�𕉂��܂���B


by �j��P
Twitter : @HariganeP


