
/*********************************************************************************************
 * 
 * PathMaker�p�v���O�C���̃C���^�[�t�F�[�X�Ɗ�{�\���̂�񋟂��܂�
 * 
 * ******************************************************************************************/

using System;
using System.Collections.Generic;
using System.Drawing;
using System.Windows.Forms;

namespace PathMakerPlugin
{

    /// <summary>
    /// 3������̓_��\���\���́B�����Ղ��D��ŉ��Z�q�̃I�[�o�[���[�h���܂���
    /// </summary>
    public struct Point3D
    {
        /// <summary>
        /// �v�f���w�肵�ĐV�����C���X�^���X���쐬���܂�
        /// </summary>
        public Point3D(double x, double y, double z)
        {
            px = x;
            py = y;
            pz = z;
        }

        private double px;
        private double py;
        private double pz;

        /// <summary>
        /// X�����W
        /// </summary>
        public double X
        {
            get { return px; }
            set { px = value; }
        }
        /// <summary>
        /// Y�����W
        /// </summary>
        public double Y
        {
            get { return py; }
            set { py = value; }
        }
        /// <summary>
        /// Z�����W
        /// </summary>
        public double Z
        {
            get { return pz; }
            set { pz = value; }
        }

        /// <summary>
        /// �_�̍��W�̎����{
        /// </summary>
        public static Point3D operator *(Point3D u, double v)
        {
            u.X *= v; u.Y *= v; u.Z *= v;
            return u;
        }

        /// <summary>
        /// �_�̍��W�̉��Z
        /// </summary>
        public static Point3D operator +(Point3D u, Point3D v)
        {
            u.X += v.X; u.Y += v.Y; u.Z += v.Z;
            return u;
        }

        /// <summary>
        /// �_���x�N�g���ɏ]���Ĉړ�
        /// </summary>
        public static Point3D operator +(Point3D u, Vector3D v)
        {
            u.X += v.X; u.Y += v.Y; u.Z += v.Z;
            return u;
        }

        /// <summary>
        /// �_�Ɠ_�̊Ԃ̃x�N�g�����Z�o
        /// </summary>
        public static Vector3D operator -(Point3D u, Point3D v)
        {
            Vector3D v3 = new Vector3D(u.X - v.X, u.Y - v.Y, u.Z - v.Z);
            return v3;
        }


    }

    /// <summary>
    /// 3�����x�N�g���\���\���́B�����Ղ��D��ŉ��Z�q�̃I�[�o�[���[�h���܂���
    /// </summary>
    public struct Vector3D
    {
        /// <summary>
        /// �v�f���w�肵�ĐV�����C���X�^���X���쐬���܂�
        /// </summary>
        public Vector3D(double x, double y, double z)
        {
            px = x;
            py = y;
            pz = z;
        }

        private double px;
        private double py;
        private double pz;

        /// <summary>
        /// X������
        /// </summary>
        public double X
        {
            get { return px; }
            set { px = value; }
        }
        /// <summary>
        /// Y������
        /// </summary>
        public double Y
        {
            get { return py; }
            set { py = value; }
        }
        /// <summary>
        /// Z������
        /// </summary>
        public double Z
        {
            get { return pz; }
            set { pz = value; }
        }

        /// <summary>
        /// �x�N�g���̑傫��
        /// </summary>
        public double Length
        {
            get { return (float)Math.Sqrt(X * X + Y * Y + Z * Z); }
        }

        /// <summary>
        /// ���K�����ꂽ�x�N�g����Ԃ��܂�
        /// </summary>
        /// <returns>���K�����ꂽ�x�N�g��</returns>
        public Vector3D Normalize()
        {
            return (this / Length);
        }

        /// <summary>
        /// �x�N�g���̊O�ρi�N���X�ρj�����߂�
        /// </summary>
        public static Vector3D Cross(Vector3D u, Vector3D v)
        {
            Vector3D r = new Vector3D();
            r.X = u.Y * v.Z - u.Z * v.Y;
            r.Y = u.Z * v.X - u.X * v.Z;
            r.Z = u.X * v.Y - u.Y * v.X;
            return r;
        }

        /// <summary>
        /// �����̉��Z
        /// </summary>
        public static Vector3D operator +(Vector3D u, Vector3D v)
        {
            u.X += v.X; u.Y += v.Y; u.Z += v.Z;
            return u;
        }

        /// <summary>
        /// �����̌��Z
        /// </summary>
        public static Vector3D operator -(Vector3D u, Vector3D v)
        {
            Vector3D v3 = new Vector3D(u.X - v.X, u.Y - v.Y, u.Z - v.Z);
            return v3;
        }

        /// <summary>
        /// �x�N�g���̎����{
        /// </summary>
        public static Vector3D operator *(Vector3D u, double v)
        {
            u.X *= v; u.Y *= v; u.Z *= v;
            return u;
        }
        /// <summary>
        /// �x�N�g���̎����{
        /// </summary>
        public static Vector3D operator /(Vector3D u, double v)
        {
            u.X /= v; u.Y /= v; u.Z /= v;
            return u;
        }

        /// <summary>
        /// �x�N�g���̓���
        /// </summary>
        public static double operator *(Vector3D u, Vector3D v)
        {
            return (u.X * v.X + u.Y * v.Y + u.Z * v.Z);
        }

    }


    /// <summary>
    /// PathMaker��̃��C���s�N�`���{�b�N�X���`�悳�ꂽ���̃C�x���g��񋟂��܂�
    /// </summary>
    public delegate void PictureBoxPaintEventHandler(IPluginHost sender);

    /// <summary>
    /// PathMaker�Ńf�[�^���X�V���ꂽ���̃C�x���g��񋟂��܂�
    /// </summary>
    public delegate void DataRenewEventHandler(IPluginHost sender);



    /// <summary>
    /// �v���O�C���Ŏ�������C���^�[�t�F�[�X
    /// </summary>
    public interface IPlugin
    {
        
        /// <summary>
        /// �v���O�C���̖��O
        /// </summary>
        string Name { get;}

        /// <summary>
        /// �v���O�C���̃o�[�W����
        /// </summary>
        string Version { get;}

        /// <summary>
        /// �v���O�C���̐���
        /// </summary>
        string Description { get;}

        /// <summary>
        /// �v���O�C���̃z�X�g
        /// </summary>
        IPluginHost Host { get; set;}

        /// <summary>
        /// �v���O�C�������s
        /// </summary>
        void Run();

        

    }


    /// <summary>
    /// �o�͌��ʂ���v���r���[�Đ����s�����߂̃C���^�[�t�F�[�X
    /// </summary>
    public interface IPlayer
    {
        /// <summary>
        /// ���_����̈ړ���
        /// </summary>
        Transfer tr { get; }
        /// <summary>
        /// ��]
        /// </summary>
        Quaternion qt { get; }
        /// <summary>
        /// �Đ����J�n����Ă��邩�������܂�
        /// </summary>
        bool Playing { get; }
        /// <summary>
        /// �Đ����̃t���[�������擾���܂�
        /// </summary>
        int Frame { get; }
        /// <summary>
        /// �Đ����̃L�[�t���[���ԍ����擾���܂�
        /// </summary>
        int Index { get; }

        /// <summary>
        /// �Đ���Ԃ��܂�
        /// </summary>
        /// <returns>����:true, ���s:false</returns>
        bool Start();
        /// <summary>
        /// ���̃t���[���ɐi�݂܂�
        /// </summary>
        /// <returns>����:true, ���s�܂��͏I��:false</returns>
        bool NextFrame();
        /// <summary>
        /// �p�X���C�J�[��ɍĐ��}�[�J�[��`�悵�܂�
        /// </summary>
        void Draw();
        /// <summary>
        /// �Đ����I�����܂�
        /// </summary>
        void End();

    }

    /// <summary>
    /// �v���O�C���̃z�X�g�Ŏ�������C���^�[�t�F�C�X
    /// </summary>
    public interface IPluginHost
    {
        
        /// <summary>
        /// �^�C�g���o�[�Ƀ��b�Z�[�W��\������
        /// </summary>
        /// <param name="msg">�\�����郁�b�Z�[�W</param>
        void ShowTitleMessage(string msg);

        /// <summary>
        /// �}�[�J�[�̍��W�̃��X�g���擾���܂�
        /// </summary>
        void GetMarkerPoints(out Point3D[] points);

        /// <summary>
        /// �}�[�J�[���Ƃ̑��x�{���̃��X�g���擾���܂�
        /// </summary>
        void GetMarkerSpeeds(out double[] speeds);

        /// <summary>
        /// �X�v���C���⊮���ꂽ���W�̃��X�g���擾���܂�
        /// </summary>
        void GetSplinePoints(out Point3D[] points);

        /// <summary>
        /// �}�[�J�[�̍��W�̃��X�g��ݒ肵�܂��B
        /// �v�f�����قȂ鎞�͑��x�����Z�b�g����܂��B
        /// </summary>
        void SetMarkerPoints(ref Point3D[] points);

        /// <summary>
        /// �}�[�J�[���Ƃ̑��x�̃��X�g��ݒ肵�܂�
        /// </summary>
        void SetMarkerSpeeds(ref double[] speeds);

        /// <summary>
        /// ���݂̃{�[�������擾�܂��͐ݒ肵�܂�
        /// </summary>
        string BoneName { get; set;}

        /// <summary>
        /// �J�������[�h���ۂ���Ԃ��܂�
        /// </summary>
        bool IsCameraMode { get; }

        /// <summary>
        /// ���݂̊���x���擾�܂��͐ݒ肵�܂�
        /// </summary>
        double Speed { get; set;}

        /// <summary>
        /// �o�̓t�@�C���̖��O���擾�܂��͐ݒ肵�܂�
        /// </summary>
        string OutFileName { get; set;}

        /// <summary>
        /// 3������̓_���s�N�`���{�b�N�X��̓_�ɕϊ����܂�
        /// </summary>
        PointF GetDrawPoint(Point3D point);

        /// <summary>
        /// ���C���̕`��o�b�t�@�ւ�Graphics���쐬���ĕԂ��܂�
        /// </summary>
        Graphics GetGraphics();

        /// <summary>
        /// �`��o�b�t�@����ʂɕ\�����܂�
        /// </summary>
        void PictureBoxRefresh();


        /// <summary>
        /// CSV�o�͂̌��ʂ�Ԃ��܂�
        /// </summary>
        /// <returns>CSV�o�͂̕�����</returns>
        string GetOutputCSV();

        /// <summary>
        /// �o�͂̌��ʂ�Ԃ��܂�
        /// </summary>
        /// <returns>�o��VMD�f�[�^</returns>
        VMDFormat GetOutput();

        /// <summary>
        /// PathMaker��̃��C���s�N�`���{�b�N�X���`�悳��鎞�̃C�x���g
        /// </summary>
        event PictureBoxPaintEventHandler PictureBoxPaintEvent;

        /// <summary>
        /// PathMaker�Ńf�[�^���X�V���ꂽ���̃C�x���g
        /// </summary>
        event DataRenewEventHandler DataRenewEvent;

        Icon FormIcon { get;}

        /// <summary>
        /// �v���r���[�Đ��@�\�ɃA�N�Z�X
        /// </summary>
        IPlayer Player { get;}


    }




}
