
/**********************************************************************************
 * VMDFormat�N���X
 * ����F���ڂ�
 * Ver.1.12
 * 2010/03/06
 * 
 * MikuMikuDance�̃��[�V�����t�@�C���ł���VMD�t�H�[�}�b�g�t�@�C���ւ�
 * �A�N�Z�X�ƃf�[�^�Ǘ���񋟂��܂��B
 * �N�I�[�^�j�I���ƃI�C���[�p�̑��ݕϊ��ȂǁA�ʓ|�ȕ������������Ă��܂�
 * �Ƃ������������������炢���ȂƎv�����@�\��S���Ԃ�����ł��܂�
 * 
 * �|�[�Y�f�[�^�̃C���|�[�g�A�G�N�X�|�[�g���\�ł�
 * Clone���\�b�h�ɂ��R�s�[�ɑΉ����Ă��܂�
 * ����ł̖������́A�J�������R�[�h�f�[�^�̖�����4�o�C�g���s���ł��i�Ƃ肠����0���߁j
 * �G���[�����͏\���Ƃ͂����܂���̂ŁA���p�̍ۂ͂����ӂ�������
 * �܂��AMMD���󂯓���\�Ȓl�͈̔͂̃`�F�b�N�͍s���Ă��܂���
 * 
 * DirectX���g�������Ȃ������̂ŁADirectX�Ȃ�ȒP�ɂ���Ă���镔�����S�������N�����c
 * 
 * �v���O���~���O��@�I�ɂ���܂����N�\�����ł����A��������Ǝg���܂킷����
 * �ʓ|�Ȃ̂ŁA��������������
 * 
 * �g�p��F
 
   VMDFormat vmd = new VMDFormat();
   if(vmd.Read(@"C:\test.vmd")){
     if(vmd.MotionRecords.Count > 0) Debug.WriteLine(vmd.MotionRecords[0].BoneName);
   }
 
 ***********************************************************************************/


using System;
using System.Collections.Generic;
using System.Text;
using System.IO;
using System.Drawing;

namespace PathMakerPlugin
{
    /// <summary>
    /// VMD�t�H�[�}�b�g�t�@�C���ւ̃A�N�Z�X�ƃf�[�^�Ǘ���񋟂���
    /// </summary>
    public class VMDFormat : ICloneable
    {
        /// <summary>
        /// �W����VMD�t�@�C���̃w�b�_
        /// </summary>
        public const string DefaultHeaderScript = "Vocaloid Motion Data 0002";
        /// <summary>
        /// �W����VPD�t�@�C���̃w�b�_
        /// </summary>
        public const string PoseHeaderScript = "Vocaloid Pose Data file";

        private string hdscr;
        private string actor;

        private bool actor_isdef; //���f�������O������ύX���ꂽ��

        /// <summary>
        /// �w�b�_������
        /// </summary>
        public string HeaderScript
        {
            get { return hdscr; }
            set { hdscr = value; }
        }
        /// <summary>
        /// ���f������
        /// </summary>
        public string Actor
        {
            get { return actor; }
            set { actor = value; actor_isdef = false; }
        }

        /// <summary>
        /// ���[�V�������R�[�h�̃��X�g
        /// </summary>
        public List<VMDFormat.MotionRecord> MotionRecords = new List<MotionRecord>();
        /// <summary>
        /// �\��R�[�h�̃��X�g
        /// </summary>
        public List<VMDFormat.ExpressionRecord> ExpressionRecords = new List<ExpressionRecord>();
        /// <summary>
        /// �J�������R�[�h�̃��X�g
        /// </summary>
        public List<VMDFormat.CameraRecord> CameraRecords = new List<CameraRecord>();
        /// <summary>
        /// �Ɩ����R�[�h�̃��X�g
        /// </summary>
        public List<VMDFormat.LightRecord> LightRecords = new List<LightRecord>();
        /// <summary>
        /// �Z���t�V���h�E���R�[�h�̃��X�g
        /// </summary>
        public List<VMDFormat.ShadowRecord> ShadowRecords = new List<ShadowRecord>();

        /// <summary>
        /// �����l��ݒ肵�ăC���X�^���X���쐬
        /// </summary>
        public VMDFormat()
        {
            this.Reset();
        }


        /// <summary>
        /// �i�[���ꂽ��������������
        /// </summary>
        public void Reset()
        {
            this.HeaderScript = DefaultHeaderScript;
            this.Actor = "�����~�N";

            this.MotionRecords.Clear();
            this.ExpressionRecords.Clear();
            this.CameraRecords.Clear();
            this.LightRecords.Clear();

            this.actor_isdef = true;
        }

        /// <summary>
        /// �N���X�̕���
        /// </summary>
        public object Clone()
        {
            VMDFormat vmd = new VMDFormat();
            int i;

            vmd.HeaderScript = this.HeaderScript;
            vmd.Actor = this.Actor;

            //List�̓��e�����X�ƃR�s�[
            for (i = 0; i < this.MotionRecords.Count; i++)
                vmd.MotionRecords.Add((MotionRecord)this.MotionRecords[i].Clone());
            for (i = 0; i < this.ExpressionRecords.Count; i++)
                vmd.ExpressionRecords.Add((ExpressionRecord)this.ExpressionRecords[i].Clone());
            for (i = 0; i < this.CameraRecords.Count; i++)
                vmd.CameraRecords.Add((CameraRecord)this.CameraRecords[i].Clone());
            for (i = 0; i < this.LightRecords.Count; i++)
                vmd.LightRecords.Add((LightRecord)this.LightRecords[i].Clone());
            for (i = 0; i < this.ShadowRecords.Count; i++)
                vmd.ShadowRecords.Add((ShadowRecord)this.ShadowRecords[i].Clone());

            return vmd;
        }

        /// <summary>
        /// VMD�t�@�C�����J���ď���ǂݏo��
        /// </summary>
        /// <param name="FileName">VMD�t�@�C���̃t���p�X</param>
        /// <returns>���������true�A���s�����false��Ԃ�</returns>
        public bool Read(string FileName)
        {
            bool ret;
            FileStream fs;

            if (!File.Exists(FileName)) return false;

            try
            {
                fs = new FileStream(FileName, FileMode.Open, FileAccess.Read);
            }
            catch
            {
                return false;
            }

            //Stream��Read�ւƃ��_�C���N�g
            ret = this.Read(fs);

            fs.Close();

            return ret;
        }

        /// <summary>
        /// VMD�t�@�C���̃X�g���[���������ǂݏo��
        /// </summary>
        /// <param name="stream">�g�p����X�g���[��</param>
        /// <returns>���������true�A���s�����false��Ԃ�</returns>
        public bool Read(Stream stream)
        {
            int i, RecordCount;
            BinaryReader br = new BinaryReader(stream);

            this.Reset();

            bool MotionGet = false;


            try
            {
                this.HeaderScript = StreamRead_ShiftJIS(stream, 30);
                if (this.HeaderScript.CompareTo(DefaultHeaderScript) != 0) return false;
                this.Actor = StreamRead_ShiftJIS(stream, 20);

                RecordCount = br.ReadInt32(); //���[�V�������R�[�h�̐���ǂݏo��
                if (stream.Length - stream.Position < RecordCount * MotionRecord.DataLength) return MotionGet;

                //�f�[�^��ǂݏo���ă��X�g�ɒǉ�
                for (i = 0; i < RecordCount; i++)
                    MotionRecords.Add(new MotionRecord(stream));

                if (stream.Position == stream.Length) return true;
                MotionGet |= (RecordCount > 0);


                RecordCount = br.ReadInt32(); //�\��R�[�h�̐���ǂݏo��
                if (stream.Length - stream.Position < RecordCount * ExpressionRecord.DataLength) return MotionGet;

                //�f�[�^��ǂݏo���ă��X�g�ɒǉ�
                for (i = 0; i < RecordCount; i++)
                    ExpressionRecords.Add(new ExpressionRecord(stream));

                if (stream.Position == stream.Length) return true;
                MotionGet |= (RecordCount > 0);


                RecordCount = br.ReadInt32(); //�J�������R�[�h�̐���ǂݏo��
                if (stream.Length - stream.Position < RecordCount * CameraRecord.DataLength) return MotionGet;

                //�f�[�^��ǂݏo���ă��X�g�ɒǉ�
                for (i = 0; i < RecordCount; i++)
                    CameraRecords.Add(new CameraRecord(stream));

                if (stream.Position == stream.Length) return true;
                MotionGet |= (RecordCount > 0);


                RecordCount = br.ReadInt32(); //�Ɩ����R�[�h�̐���ǂݏo��
                if (stream.Length - stream.Position < RecordCount * LightRecord.DataLength) return MotionGet;

                //�f�[�^��ǂݏo���ă��X�g�ɒǉ�
                for (i = 0; i < RecordCount; i++)
                    LightRecords.Add(new LightRecord(stream));

                if (stream.Position == stream.Length) return true;
                MotionGet |= (RecordCount > 0);


                RecordCount = br.ReadInt32(); //�V���h�E���R�[�h�̐���ǂݏo��
                if (stream.Length - stream.Position < RecordCount * ShadowRecord.DataLength) return MotionGet;

                //�f�[�^��ǂݏo���ă��X�g�ɒǉ�
                for (i = 0; i < RecordCount; i++)
                    ShadowRecords.Add(new ShadowRecord(stream));

                MotionGet |= (RecordCount > 0);

            }
            catch
            {
                return false;
            }


            return MotionGet;
        }


        /// <summary>
        /// VMD�t�@�C�����J���ď��������o��
        /// </summary>
        /// <param name="FileName">VMD�t�@�C���̃t���p�X</param>
        /// <returns>���������true�A���s�����false��Ԃ�</returns>
        public bool Write(string FileName)
        {
            bool ret;
            FileStream fs;

            //�f�B���N�g����������΃G���[
            if (!Directory.Exists(Path.GetDirectoryName(FileName))) return false;

            try
            {
                fs = new FileStream(FileName, FileMode.Create, FileAccess.Write);
            }
            catch
            {
                return false;
            }

            //Stream��Write�ւƃ��_�C���N�g
            ret = this.Write(fs);

            fs.Close();

            return ret;
        }

        /// <summary>
        /// VMD�t�@�C���̃X�g���[���֏��������o��
        /// </summary>
        /// <param name="stream">�g�p����X�g���[��</param>
        /// <returns>���������true�A���s�����false��Ԃ�</returns>
        public bool Write(Stream stream)
        {
            BinaryWriter bw = new BinaryWriter(stream);

            try
            {

                StreamWrite_ShiftJIS(stream, this.HeaderScript, 30);
                StreamWrite_ShiftJIS(stream, this.Actor, 20);

                bw.Write(this.MotionRecords.Count);
                foreach (Record rec in MotionRecords) rec.Write(stream);

                bw.Write(this.ExpressionRecords.Count);
                foreach (Record rec in ExpressionRecords) rec.Write(stream);

                bw.Write(this.CameraRecords.Count);
                foreach (Record rec in CameraRecords) rec.Write(stream);

                bw.Write(this.LightRecords.Count);
                foreach (Record rec in LightRecords) rec.Write(stream);

                if (this.ShadowRecords.Count <= 0) return true;
                bw.Write(this.ShadowRecords.Count);
                foreach (Record rec in ShadowRecords) rec.Write(stream);

            }
            catch
            {
                return false;
            }

            return true;
        }


        /////////////////////////////////////////////////////////////////////////////////////////////////

        /// <summary>
        /// VPD�t�@�C���֏��������o��
        /// </summary>
        /// <param name="FrameNumber">�����o�������t���[���ԍ�</param>
        /// <param name="FileName">VPD�t�@�C���̃t���p�X</param>
        /// <returns>���������true�A���s�����false��Ԃ�</returns>
        public bool ExportPoseData(int FrameNumber, string FileName)
        {
            bool ret;
            FileStream fs;

            //�f�B���N�g����������΃G���[
            if (!Directory.Exists(Path.GetDirectoryName(FileName))) return false;

            try
            {
                fs = new FileStream(FileName, FileMode.Create, FileAccess.Write);
            }
            catch
            {
                return false;
            }

            //Stream��Write�ւƃ��_�C���N�g
            ret = this.ExportPoseData(FrameNumber, fs);

            fs.Close();

            return ret;
        }

        /// <summary>
        /// VPD�t�@�C���̃X�g���[���֏��������o��
        /// </summary>
        /// <param name="FrameNumber">�����o�������t���[���ԍ�</param>
        /// <param name="stream">�g�p����X�g���[��</param>
        /// <returns>���������true�A���s�����false��Ԃ�</returns>
        public bool ExportPoseData(int FrameNumber, Stream stream)
        {
            Encoding Shift_JIS = Encoding.GetEncoding(932);

            string strout1 = PoseHeaderScript;
            StringBuilder strout2 = new StringBuilder();

            const string fmt1 = "0.000000";

            int i = 0;

            foreach (MotionRecord rec in MotionRecords)
            {
                if (rec.FrameNumber == FrameNumber)
                {
                    StringBuilder s = new StringBuilder();
                    s.Append("Bone"); s.Append(i); s.Append("{"); s.Append(rec.BoneName); s.AppendLine();
                    s.Append("  "); s.AppendFormat(rec.Trans.ToString(fmt1));
                    s.Append("\t\t\t\t"); s.Append("// trans x,y,z"); s.AppendLine();
                    s.Append("  "); s.AppendFormat(rec.Qt.ToString(fmt1));
                    s.Append("\t\t"); s.Append("// Quatanion x,y,z,w"); s.AppendLine(); //�ꉞ�뎚���Č�
                    s.AppendLine("}");
                    s.AppendLine();

                    strout2.Append(s.ToString());

                    i++;
                }
            }

            if (i == 0) return false;

            strout1 = strout1 + Environment.NewLine + Environment.NewLine;
            strout1 = strout1 + this.actor + ".osm;\t\t// �e�t�@�C����" + Environment.NewLine;
            strout1 = strout1 + i.ToString() + ";\t\t\t\t// ���|�[�Y�{�[����" + Environment.NewLine;
            strout1 = strout1 + Environment.NewLine + strout2.ToString();

            StreamWriter sw = new StreamWriter(stream, Shift_JIS);

            sw.Write(strout1);

            return true;

        }





        /// <summary>
        /// VPD�t�@�C���������ǂݏo��
        /// </summary>
        /// <param name="FrameNumber">�ǂݍ��ݐ�̃t���[���ԍ�</param>
        /// <param name="FileName">VPD�t�@�C���̃t���p�X</param>
        /// <returns>���������true�A���s�����false��Ԃ�</returns>
        public bool ImportPoseData(int FrameNumber, string FileName)
        {
            bool ret;
            FileStream fs;

            if (!File.Exists(FileName)) return false;

            try
            {
                fs = new FileStream(FileName, FileMode.Open, FileAccess.Read);
            }
            catch
            {
                return false;
            }

            //Stream��Read�ւƃ��_�C���N�g
            ret = this.ImportPoseData(FrameNumber, fs);

            fs.Close();

            return ret;
        }

        /// <summary>
        /// VPD�t�@�C���̃X�g���[���������ǂݍ���
        /// </summary>
        /// <param name="FrameNumber">�ǂݍ��ݐ�̃t���[���ԍ�</param>
        /// <param name="stream">�g�p����X�g���[��</param>
        /// <returns>���������true�A���s�����false��Ԃ�</returns>
        public bool ImportPoseData(int FrameNumber, Stream stream)
        {
            Encoding Shift_JIS = Encoding.GetEncoding(932);
            StreamReader sr = new StreamReader(stream, Shift_JIS);

            string strin;
            int i, num;

            strin = sr.ReadLine(); //�w�b�_

            if (!strin.StartsWith(PoseHeaderScript)) return false;

            sr.ReadLine();
            strin = sr.ReadLine(); //���f����

            //VMD�̃��f�������w�肳��Ă��Ȃ����́A�|�[�Y�f�[�^�̃��f������ݒ�
            if (actor_isdef)
            {
                this.actor = strin.Substring(0, strin.IndexOf(";"));
                this.actor = this.actor.Replace(".osm", "");
                this.actor = this.actor.Replace(".pmd", "");
            }

            strin = sr.ReadLine(); //�{�[����
            strin = strin.Substring(0, strin.IndexOf(";"));
            num = int.Parse(strin);

            for (i = 0; i < num; i++)
            {
                MotionRecord newrec = new MotionRecord();
                string[] strs;

                sr.ReadLine();

                strin = sr.ReadLine(); //�{�[����
                newrec.BoneName = strin.Substring(strin.IndexOf('{') + 1);

                strin = sr.ReadLine(); //Trans
                strin = strin.Substring(0, strin.IndexOf(";"));
                strin = strin.Replace(" ", "");
                strs = strin.Split(',');
                newrec.Trans.x = float.Parse(strs[0]);
                newrec.Trans.y = float.Parse(strs[1]);
                newrec.Trans.z = float.Parse(strs[2]);

                strin = sr.ReadLine(); //��]
                strin = strin.Substring(0, strin.IndexOf(";"));
                strin = strin.Replace(" ", "");
                strs = strin.Split(',');
                newrec.Qt.x = float.Parse(strs[0]);
                newrec.Qt.y = float.Parse(strs[1]);
                newrec.Qt.z = float.Parse(strs[2]);
                newrec.Qt.w = float.Parse(strs[3]);

                sr.ReadLine(); //}

                MotionRecords.Add(newrec);
            }

            return true;

        }






        /////////////////////////////////////////////////////////////////////////////////////////////////

        /// <summary>
        /// �e���R�[�h�̊�{�N���X
        /// </summary>
        public abstract class Record : IComparable, ICloneable
        {

            private int _FrameNumber = 0;

            /// <summary>
            /// �t���[���ԍ�
            /// </summary>
            public int FrameNumber
            {
                get { return _FrameNumber; }
                set { _FrameNumber = value; }
            }

            /// <summary>
            /// �t���[���ԍ��̑召��Ԃ��܂�
            /// </summary>
            /// <param name="other">��r���郌�R�[�h</param>
            /// <returns>�t���[���ԍ��̍�</returns>
            public int CompareTo(object other)
            {
                return (this.FrameNumber - ((Record)other).FrameNumber);
            }

            /// <summary>
            /// �X�g���[������P�Ƃ̃��R�[�h��ǂݏo��
            /// </summary>
            abstract public void Read(Stream stream);
            /// <summary>
            /// �X�g���[���ɒP�Ƃ̃��R�[�h�������o��
            /// </summary>
            abstract public void Write(Stream stream);
            /// <summary>
            /// �N���X�̕���
            /// </summary>
            abstract public object Clone();

        }

        /////////////////////////////////////////////////////////////////////////////////////////////////

        /// <summary>
        /// ���[�V�������R�[�h�̏����i�[����N���X
        /// </summary>
        public class MotionRecord : Record, IComparable<MotionRecord>
        {

            public MotionRecord() { }

            /// <summary>
            /// �C���X�^���X�̍쐬�Ɠ����Ƀf�[�^��ǂݏo��
            /// </summary>
            public MotionRecord(Stream stream)
            {
                this.Read(stream);
            }

            /// <summary>
            /// �N���X�̕���
            /// </summary>
            public override object Clone()
            {
                //�l�^���������Ȃ��̂�MemberwiseClone�ōς܂���
                return this.MemberwiseClone();
            }


            /// <summary>
            /// �{�[����
            /// </summary>
            public string BoneName = " ";

            /// <summary>
            /// ���s�ړ��̏��
            /// </summary>
            public Transfer Trans = Transfer.GetDefault();

            /// <summary>
            /// ��]�̏�� (�N�I�[�^�j�I��)
            /// </summary>
            public Quaternion Qt = Quaternion.GetDefault();

            /// <summary>
            /// X�����W�̕⊮�Ȑ�
            /// </summary>
            public ComplementBezier CBX = ComplementBezier.GetDefault();
            /// <summary>
            /// Y�����W�̕⊮�Ȑ�
            /// </summary>
            public ComplementBezier CBY = ComplementBezier.GetDefault();
            /// <summary>
            /// Z�����W�̕⊮�Ȑ�
            /// </summary>
            public ComplementBezier CBZ = ComplementBezier.GetDefault();
            /// <summary>
            /// ��]�̕⊮�Ȑ�
            /// </summary>
            public ComplementBezier CBQ = ComplementBezier.GetDefault();

            /// <summary>
            /// �t���[���ԍ��̑召���r���܂��B�t���[���ԍ��������Ȃ�{�[�������r���܂�
            /// </summary>
            /// <param name="other">��r���郂�[�V�������R�[�h</param>
            /// <returns></returns>
            public int CompareTo(MotionRecord other)
            {
                int d1 = this.FrameNumber - other.FrameNumber;
                if (d1 == 0) d1 = this.BoneName.CompareTo(other.BoneName);

                return d1;
            }

            /// <summary>
            /// �t�@�C���������ݎ��̃f�[�^��
            /// </summary>
            public static int DataLength { get { return 111; } }

            /// <summary>
            /// �X�g���[������P�Ƃ̃��R�[�h��ǂݏo��
            /// </summary>
            public override void Read(Stream stream)
            {
                BinaryReader br = new BinaryReader(stream);

                this.BoneName = StreamRead_ShiftJIS(stream, 15);

                this.FrameNumber = br.ReadInt32();
                this.Trans.x = br.ReadSingle();
                this.Trans.y = br.ReadSingle();
                this.Trans.z = br.ReadSingle();
                this.Qt.x = br.ReadSingle();
                this.Qt.y = br.ReadSingle();
                this.Qt.z = br.ReadSingle();
                this.Qt.w = br.ReadSingle();

                read_cb(br, ref CBX);
                read_cb(br, ref CBY);
                read_cb(br, ref CBZ);
                read_cb(br, ref CBQ);
            }

            /// <summary>
            /// �X�g���[���ɒP�Ƃ̃��R�[�h�������o��
            /// </summary>
            public override void Write(Stream stream)
            {
                BinaryWriter bw = new BinaryWriter(stream);

                StreamWrite_ShiftJIS(stream, this.BoneName, 15);

                bw.Write(this.FrameNumber);
                bw.Write(this.Trans.x);
                bw.Write(this.Trans.y);
                bw.Write(this.Trans.z);
                bw.Write(this.Qt.x);
                bw.Write(this.Qt.y);
                bw.Write(this.Qt.z);
                bw.Write(this.Qt.w);

                write_cb(bw, ref CBX);
                write_cb(bw, ref CBY);
                write_cb(bw, ref CBZ);
                write_cb(bw, ref CBQ);

            }

            /// <summary>
            /// �⊮�p�^�[���̓ǂݏo��
            /// </summary>
            private void read_cb(BinaryReader br, ref ComplementBezier cb)
            {
                //���3�o�C�g�̓_�~�[�f�[�^�Ǝv����
                cb.point1.X = (int)(br.ReadUInt32() & 0x7F);
                cb.point1.Y = (int)(br.ReadUInt32() & 0x7F);
                cb.point2.X = (int)(br.ReadUInt32() & 0x7F);
                cb.point2.Y = (int)(br.ReadUInt32() & 0x7F);
            }

            /// <summary>
            /// �⊮�p�^�[���̏����o��
            /// </summary>
            private void write_cb(BinaryWriter bw, ref ComplementBezier cb)
            {
                bw.Write(cb.point1.X);
                bw.Write(cb.point1.Y);
                bw.Write(cb.point2.X);
                bw.Write(cb.point2.Y);
            }

        }

        /////////////////////////////////////////////////////////////////////////////////////////////////

        /// <summary>
        /// �\��R�[�h�̏����i�[����N���X
        /// </summary>
        public class ExpressionRecord : Record
        {

            public ExpressionRecord() { }

            /// <summary>
            /// �C���X�^���X�̍쐬�Ɠ����Ƀf�[�^��ǂݏo��
            /// </summary>
            public ExpressionRecord(Stream stream)
            {
                this.Read(stream);
            }

            /// <summary>
            /// �N���X�̕���
            /// </summary>
            public override object Clone()
            {
                //�l�^���������Ȃ��̂�MemberwiseClone�ōς܂���
                return this.MemberwiseClone();
            }

            /// <summary>
            /// �\��̖��O
            /// </summary>
            public string ExpressionName = " ";

            /// <summary>
            /// �\��p�����[�^
            /// </summary>
            public float Factor = 0;


            /// <summary>
            /// �t�@�C���������ݎ��̃f�[�^��
            /// </summary>
            public static int DataLength { get { return 23; } }

            /// <summary>
            /// �X�g���[������P�Ƃ̃��R�[�h��ǂݏo��
            /// </summary>
            public override void Read(Stream stream)
            {
                BinaryReader br = new BinaryReader(stream);

                this.ExpressionName = StreamRead_ShiftJIS(stream, 15);

                this.FrameNumber = br.ReadInt32();
                this.Factor = br.ReadSingle();

            }

            /// <summary>
            /// �X�g���[���ɒP�Ƃ̃��R�[�h�������o��
            /// </summary>
            public override void Write(Stream stream)
            {
                BinaryWriter bw = new BinaryWriter(stream);

                StreamWrite_ShiftJIS(stream, this.ExpressionName, 15);

                bw.Write(this.FrameNumber);
                bw.Write(this.Factor);
            }
        }

        /////////////////////////////////////////////////////////////////////////////////////////////////

        /// <summary>
        /// �J�������R�[�h�̏����i�[����N���X
        /// </summary>
        public class CameraRecord : Record
        {

            public CameraRecord() { }

            /// <summary>
            /// �C���X�^���X�̍쐬�Ɠ����Ƀf�[�^��ǂݏo��
            /// </summary>
            public CameraRecord(Stream stream)
            {
                this.Read(stream);
            }

            /// <summary>
            /// �N���X�̕���
            /// </summary>
            public override object Clone()
            {
                //�l�^���������Ȃ��̂�MemberwiseClone�ōς܂���
                return this.MemberwiseClone();
            }

            /// <summary>
            /// �J��������
            /// </summary>
            public float Distance = 0;

            /// <summary>
            /// ���s�ړ��̏��
            /// </summary>
            public Transfer Trans = Transfer.GetDefault();

            /// <summary>
            /// ��]�̏��i�I�C���[�p�F���W�A���j
            /// </summary>
            public EulerAngle Ang = EulerAngle.GetDefault();

            /// <summary>
            /// X�����W�̕⊮�Ȑ�
            /// </summary>
            public ComplementBezier CBX = ComplementBezier.GetDefault();
            /// <summary>
            /// Y�����W�̕⊮�Ȑ�
            /// </summary>
            public ComplementBezier CBY = ComplementBezier.GetDefault();
            /// <summary>
            /// Z�����W�̕⊮�Ȑ�
            /// </summary>
            public ComplementBezier CBZ = ComplementBezier.GetDefault();
            /// <summary>
            /// ��]�̕⊮�Ȑ�
            /// </summary>
            public ComplementBezier CBQ = ComplementBezier.GetDefault();
            /// <summary>
            /// �����̕⊮�Ȑ�
            /// </summary>
            public ComplementBezier CBD = ComplementBezier.GetDefault();
            /// <summary>
            /// ����p�̕⊮�Ȑ�
            /// </summary>
            public ComplementBezier CBV = ComplementBezier.GetDefault();

            /// <summary>
            /// ����p (25 to 125)
            /// </summary>
            public int ViewAngle = 45;



            /// <summary>
            /// �t�@�C���������ݎ��̃f�[�^��
            /// </summary>
            public static int DataLength { get { return 61; } }

            /// <summary>
            /// �X�g���[������P�Ƃ̃��R�[�h��ǂݏo��
            /// </summary>
            public override void Read(Stream stream)
            {
                BinaryReader br = new BinaryReader(stream);

                this.FrameNumber = br.ReadInt32();
                this.Distance = br.ReadSingle();
                this.Trans.x = br.ReadSingle();
                this.Trans.y = br.ReadSingle();
                this.Trans.z = br.ReadSingle();
                this.Ang.x = br.ReadSingle();
                this.Ang.y = br.ReadSingle();
                this.Ang.z = br.ReadSingle();

                read_cb(br, ref CBX);
                read_cb(br, ref CBY);
                read_cb(br, ref CBZ);
                read_cb(br, ref CBQ);
                read_cb(br, ref CBD);
                read_cb(br, ref CBV);

                this.ViewAngle = br.ReadByte();
                stream.Seek(4, SeekOrigin.Current); //�s��

            }

            /// <summary>
            /// �X�g���[���ɒP�Ƃ̃��R�[�h�������o��
            /// </summary>
            public override void Write(Stream stream)
            {
                BinaryWriter bw = new BinaryWriter(stream);

                bw.Write(this.FrameNumber);
                bw.Write(this.Distance);
                bw.Write(this.Trans.x);
                bw.Write(this.Trans.y);
                bw.Write(this.Trans.z);
                bw.Write(this.Ang.x);
                bw.Write(this.Ang.y);
                bw.Write(this.Ang.z);

                write_cb(bw, ref CBX);
                write_cb(bw, ref CBY);
                write_cb(bw, ref CBZ);
                write_cb(bw, ref CBQ);
                write_cb(bw, ref CBD);
                write_cb(bw, ref CBV);

                bw.Write((byte)(this.ViewAngle));
                stream.Seek(4, SeekOrigin.Current); //�s��
            }

            /// <summary>
            /// �⊮�p�^�[���̓ǂݏo��
            /// </summary>
            private void read_cb(BinaryReader br, ref ComplementBezier cb)
            {
                //���[�V�����⊮�Ƃ̓f�[�^�`�����قȂ�
                cb.point1.X = br.ReadByte();
                cb.point2.X = br.ReadByte();
                cb.point1.Y = br.ReadByte();
                cb.point2.Y = br.ReadByte();
            }

            /// <summary>
            /// �⊮�p�^�[���̏����o��
            /// </summary>
            private void write_cb(BinaryWriter bw, ref ComplementBezier cb)
            {
                bw.Write((byte)(cb.point1.X));
                bw.Write((byte)(cb.point2.X));
                bw.Write((byte)(cb.point1.Y));
                bw.Write((byte)(cb.point2.Y));
            }

        }

        /////////////////////////////////////////////////////////////////////////////////////////////////

        /// <summary>
        /// �Ɩ����R�[�h�̏����i�[����N���X
        /// </summary>
        public class LightRecord : Record
        {

            public LightRecord() { }

            /// <summary>
            /// �C���X�^���X�̍쐬�Ɠ����Ƀf�[�^��ǂݏo��
            /// </summary>
            public LightRecord(Stream stream)
            {
                this.Read(stream);
            }

            /// <summary>
            /// �N���X�̕���
            /// </summary>
            public override object Clone()
            {
                //�l�^���������Ȃ��̂�MemberwiseClone�ōς܂���
                return this.MemberwiseClone();
            }

            /// <summary>
            /// �ԐF�v�f (0.0 to 1.0)
            /// </summary>
            public float R = 154f / 255f;
            /// <summary>
            /// �ΐF�v�f (0.0 to 1.0)
            /// </summary>
            public float G = 154f / 255f;
            /// <summary>
            /// �F�v�f (0.0 to 1.0)
            /// </summary>
            public float B = 154f / 255f;

            /// <summary>
            /// �Ǝ˕����̏�� (-1.0 to 1.0)
            /// </summary>
            public Transfer Dir = Transfer.GetDefault();


            /// <summary>
            /// �t�@�C���������ݎ��̃f�[�^��
            /// </summary>
            public static int DataLength { get { return 28; } }

            /// <summary>
            /// �X�g���[������P�Ƃ̃��R�[�h��ǂݏo��
            /// </summary>
            public override void Read(Stream stream)
            {
                BinaryReader br = new BinaryReader(stream);

                this.FrameNumber = br.ReadInt32();
                this.R = br.ReadSingle();
                this.G = br.ReadSingle();
                this.B = br.ReadSingle();
                this.Dir.x = br.ReadSingle();
                this.Dir.y = br.ReadSingle();
                this.Dir.z = br.ReadSingle();


            }

            /// <summary>
            /// �X�g���[���ɒP�Ƃ̃��R�[�h�������o��
            /// </summary>
            public override void Write(Stream stream)
            {
                BinaryWriter bw = new BinaryWriter(stream);

                bw.Write(this.FrameNumber);
                bw.Write(this.R);
                bw.Write(this.G);
                bw.Write(this.B);
                bw.Write(this.Dir.x);
                bw.Write(this.Dir.y);
                bw.Write(this.Dir.z);

            }


        }

        /////////////////////////////////////////////////////////////////////////////////////////////////

        /// <summary>
        /// �Ɩ����R�[�h�̏����i�[����N���X
        /// </summary>
        public class ShadowRecord : Record
        {

            public ShadowRecord() { }

            /// <summary>
            /// �C���X�^���X�̍쐬�Ɠ����Ƀf�[�^��ǂݏo��
            /// </summary>
            public ShadowRecord(Stream stream)
            {
                this.Read(stream);
            }

            /// <summary>
            /// �N���X�̕���
            /// </summary>
            public override object Clone()
            {
                //�l�^���������Ȃ��̂�MemberwiseClone�ōς܂���
                return this.MemberwiseClone();
            }

            /// <summary>
            /// ���[�h(0-2)
            /// </summary>
            public byte mode = 0;
            /// <summary>
            /// ���� (0.1 - (dist * 0.00001))
            /// </summary>
            public float Distance = 0.1f;



            /// <summary>
            /// �t�@�C���������ݎ��̃f�[�^��
            /// </summary>
            public static int DataLength { get { return 9; } }

            /// <summary>
            /// �X�g���[������P�Ƃ̃��R�[�h��ǂݏo��
            /// </summary>
            public override void Read(Stream stream)
            {
                BinaryReader br = new BinaryReader(stream);

                this.FrameNumber = br.ReadInt32();
                this.mode = br.ReadByte();
                this.Distance = br.ReadSingle();

            }

            /// <summary>
            /// �X�g���[���ɒP�Ƃ̃��R�[�h�������o��
            /// </summary>
            public override void Write(Stream stream)
            {
                BinaryWriter bw = new BinaryWriter(stream);

                bw.Write(this.FrameNumber);
                bw.Write(this.mode);
                bw.Write(this.Distance);

            }


        }

        /////////////////////////////////////////////////////////////////////////////////////////////////





        // �c�[���I�֐��Q ////////////////

        //�X�g���[������Shift-JIS�`���̕������ǂݎ��
        //ByteSize���w�肷��ƁA���̕������ǂݎ��
        //ByteSize�Ƀ[�����w�肷��ƁA0x00���o������܂œǂݎ��
        static private string StreamRead_ShiftJIS(Stream stream, int ByteSize)
        {
            Encoding Shift_JIS = Encoding.GetEncoding(932);
            MemoryStream buf1 = new MemoryStream();
            string retstr;

            int i = 0, val;

            while (!(ByteSize > 0 && i >= ByteSize)) //�w��o�C�g���ǂݎ������I��
            {
                val = stream.ReadByte();
                i++;

                if (val == 0x00) //�I�[�R�[�h�����o
                {
                    if (ByteSize > 0) stream.Seek(ByteSize - i, SeekOrigin.Current);
                    break;
                }

                buf1.WriteByte((byte)val);

            }

            buf1.Position = 0;
            StreamReader sr = new StreamReader(buf1, Shift_JIS, false);
            retstr = sr.ReadToEnd();
            sr.Close();

            return retstr;
        }

        static private void StreamWrite_ShiftJIS(Stream stream, string str, int ByteSize)
        {
            Encoding Shift_JIS = Encoding.GetEncoding(932);
            MemoryStream buf1 = new MemoryStream();

            StreamWriter sw = new StreamWriter(buf1, Shift_JIS);
            sw.AutoFlush = true;
            sw.Write(str);

            while (buf1.Length < ByteSize) buf1.WriteByte(0);
            buf1.Position = 0;
            for (int i = 0; i < ByteSize; i++) stream.WriteByte((byte)buf1.ReadByte());

            sw.Close();

        }







    }


    /////////////////////////////////////////////////////////////////////////////////////////////////

    //�@��b�I�ȍ\���̂̒�`�@///////////////////////////////////////////////////////////////////////

    /////////////////////////////////////////////////////////////////////////////////////////////////


    /// <summary>
    /// �⊮�x�W�G�Ȑ��̏����i�[����\���̂̒�`
    /// </summary>
    public struct ComplementBezier
    {
        //0-127�̐������W
        public Point point1;

        //0-127�̐������W
        public Point point2;

        public static ComplementBezier GetDefault()
        {
            ComplementBezier def = new ComplementBezier();
            def.point1.X = 20;
            def.point1.Y = 20;
            def.point2.X = 107;
            def.point2.Y = 107;
            return def;
        }

        /// <summary>
        /// 4�̗v�f���J���}�Ō������ĕ������
        /// </summary>
        public override string ToString()
        {
            return point1.X.ToString() + "," + point1.Y.ToString() + "," + point2.X.ToString() + "," + point2.Y.ToString();
        }

        /// <summary>
        /// �J���}��؂��4�̐����̕����񂩂�l�̎󂯓���
        /// </summary>
        public bool FromString(string str)
        {
            string[] strs = str.Split(',');

            if (strs.Length != 4) throw new Exception("Can't convert to ComplementBezier.");

            this.point1.X = int.Parse(strs[0]);
            this.point1.Y = int.Parse(strs[1]);
            this.point2.X = int.Parse(strs[2]);
            this.point2.Y = int.Parse(strs[3]);

            return true;
        }


        /// <summary>
        /// �⊮�Ȑ�����⊮�̒l���擾
        /// </summary>
        /// <param name="x">0����1.0�̎���</param>
        public float GetComplementValue(float x)
        {
            //��肭XY�֐��ɗ��Ƃ����ޕ��@��������Ȃ������̂ŋ����ɑQ�߂����ĉ����Ă��܂�
            //���Ԃ񂩂Ȃ�x���ł�
            int i;
            float t = 0.5f;
            float dt = 0.5f;
            pointf_ex[] p = new pointf_ex[10];

            if (x < 0) x = 0;
            if (x > 1) x = 0;

            p[0] = new pointf_ex(0, 0);
            p[1] = new pointf_ex(point1.X / 127f, point1.Y / 127f);
            p[2] = new pointf_ex(point2.X / 127f, point2.Y / 127f);
            p[3] = new pointf_ex(1, 1);

            for (i = 0; i < 14; i++)
            {
                p[4] = p[0] * t + p[1] * (1 - t);
                p[5] = p[1] * t + p[2] * (1 - t);
                p[6] = p[2] * t + p[3] * (1 - t);

                p[7] = p[4] * t + p[5] * (1 - t);
                p[8] = p[5] * t + p[6] * (1 - t);

                p[9] = p[7] * t + p[8] * (1 - t);

                dt /= 2;
                if (p[9].X > x) t += dt; else t -= dt;

            }

            return p[9].Y;
        }

        //�������Ƃɏ����̂��ʓ|�Ȃ̂ŁA���Z�q�̃I�[�o�[���[�h�ň�C�ɏ���������
        private struct pointf_ex
        {
            public pointf_ex(float X, float Y)
            {
                this.X = X; this.Y = Y;
            }

            public float X;
            public float Y;

            public static pointf_ex operator *(pointf_ex pfex, float t)
            {
                pfex.X *= t; pfex.Y *= t;
                return pfex;
            }

            public static pointf_ex operator +(pointf_ex pfex1, pointf_ex pfex2)
            {
                pfex1.X += pfex2.X; pfex1.Y += pfex2.Y;
                return pfex1;
            }
        }
    }

    /////////////////////////////////////////////////////////////////////////////////////////////////


    /// <summary>
    /// ���s�ړ��̏����i�[����\���̂̒�`
    /// </summary>
    public struct Transfer
    {
        public float x;
        public float y;
        public float z;

        /// <summary>
        /// �v�f���w�肵�ĐV�����C���X�^���X���쐬���܂�
        /// </summary>
        public Transfer(float x, float y, float z)
        {
            this.x = x;
            this.y = y;
            this.z = z;

        }

        /// <summary>
        /// �����l���擾
        /// </summary>
        public static Transfer GetDefault()
        {
            Transfer def;
            def.x = def.y = def.z = 0;
            return def;
        }

        /// <summary>
        /// �v�f���m�̉��Z
        /// </summary>
        public static Transfer operator +(Transfer u, Transfer v)
        {
            u.x += v.x; u.y += v.y; u.z += v.z;
            return u;
        }

        /// <summary>
        /// �v�f���m�̌��Z
        /// </summary>
        public static Transfer operator -(Transfer u, Transfer v)
        {
            u.x -= v.x; u.y -= v.y; u.z -= v.z;
            return u;
        }


        /// <summary>
        /// �N�I�[�^�j�I���ɂ����W�ϊ�
        /// </summary>
        public Transfer RotByQuaternion(Quaternion Qt)
        {
            Transfer u = this;

            Quaternion qt1 = new Quaternion();
            qt1.x = u.x; qt1.y = u.y; qt1.z = u.z;
            qt1.w = 0;

            qt1 = ((!Qt) * qt1) * Qt;
            u.x = qt1.x; u.y = qt1.y; u.z = qt1.z;

            return u;
        }

        /// <summary>
        /// �N�I�[�^�j�I���ɂ����W�ϊ�
        /// </summary>
        public static Transfer operator *(Transfer u, Quaternion v)
        {
            return u.RotByQuaternion(v);
        }

        /// <summary>
        /// 2�̈ړ��ʂ̊Ԃ̕⊮�����l��Ԃ�
        /// </summary>
        public static Transfer Complement(Transfer u, Transfer v, float tx, float ty, float tz)
        {
            u.x += (v.x - u.x) * tx;
            u.y += (v.y - u.y) * ty;
            u.z += (v.z - u.z) * tz;
            return u;
        }

        /// <summary>
        /// 3�̗v�f���J���}�Ō������ĕ\��
        /// </summary>
        public override string ToString()
        {
            return x.ToString() + "," + y.ToString() + "," + z.ToString();
        }

        /// <summary>
        /// �t�H�[�}�b�g���w�肵��3�̗v�f���J���}�Ō������ĕ\��
        /// </summary>
        public string ToString(string format)
        {
            return x.ToString(format) + "," + y.ToString(format) + "," + z.ToString(format);
        }
    }


    /////////////////////////////////////////////////////////////////////////////////////////////////


    /// <summary>
    /// �{�[���̉�]�̏����i�[����\���̂̒�` (�N�I�[�^�j�I��)
    /// </summary>
    public struct Quaternion
    {
        public float x;
        public float y;
        public float z;
        public float w;

        /// <summary>
        /// �I�C���[�p����N�I�[�^�j�I���𐶐�
        /// </summary>
        public Quaternion(EulerAngle eulerangle)
        {
            this = eulerangle.ToQuaternion();
        }
        /// <summary>
        /// �I�C���[�p����N�I�[�^�j�I���𐶐�
        /// </summary>
        public Quaternion(float Xd, float Yd, float Zd)
        {
            EulerAngle ea = new EulerAngle();
            ea.Xd = Xd;
            ea.Yd = Yd;
            ea.Zd = Zd;
            this = ea.ToQuaternion();
        }

        /// <summary>
        /// �����l���擾
        /// </summary>
        public static Quaternion GetDefault()
        {
            Quaternion def;
            def.x = 0;
            def.y = 0;
            def.z = 0;
            def.w = 1;
            return def;
        }

        /// <summary>
        /// 1��]�̃N�I�[�^�j�I��
        /// </summary>
        private static Quaternion GetFullQt()
        {
            Quaternion def;
            def.x = 0;
            def.y = 0;
            def.z = 0;
            def.w = -1;
            return def;
        }

        /// <summary>
        /// �N�I�[�^�j�I���ǂ����̊|���Z���s��
        /// </summary>
        public static Quaternion Multiply(Quaternion Qt1, Quaternion Qt2)
        {
            Quaternion Qret = new Quaternion();

            Qret.w = (Qt1.w * Qt2.w) - (Qt1.x * Qt2.x + Qt1.y * Qt2.y + Qt1.z * Qt2.z);
            Qret.x = (Qt1.w * Qt2.x) + (Qt2.w * Qt1.x) - (Qt1.y * Qt2.z - Qt1.z * Qt2.y);
            Qret.y = (Qt1.w * Qt2.y) + (Qt2.w * Qt1.y) - (Qt1.z * Qt2.x - Qt1.x * Qt2.z);
            Qret.z = (Qt1.w * Qt2.z) + (Qt2.w * Qt1.z) - (Qt1.x * Qt2.y - Qt1.y * Qt2.x);

            return Qret;
        }

        /// <summary>
        /// �N�I�[�^�j�I���ǂ����̊|���Z���s��
        /// </summary>
        public Quaternion Multiply(Quaternion Qt)
        {
            return Multiply(this, Qt);
        }

        /// <summary>
        /// �����ȃN�I�[�^�j�I����Ԃ�
        /// </summary>
        public static Quaternion Conjugate(Quaternion Qt)
        {
            Quaternion Qret = new Quaternion();

            Qret.w = Qt.w;
            Qret.x = -Qt.x;
            Qret.y = -Qt.y;
            Qret.z = -Qt.z;

            return Qret;
        }

        /// <summary>
        /// �����ȃN�I�[�^�j�I����Ԃ�
        /// </summary>
        public Quaternion Conjugate()
        {
            return Conjugate(this);
        }

        /// <summary>
        /// w�����̃N�I�[�^�j�I����Ԃ�
        /// </summary>
        public Quaternion Positive()
        {
            if (w > 0) return this;
            else return this * GetFullQt();
        }

        /// <summary>
        /// w�����̃N�I�[�^�j�I����Ԃ�
        /// </summary>
        public Quaternion Negative()
        {
            if (w < 0) return this;
            else return this * GetFullQt();
        }

        /// <summary>
        /// �N�I�[�^�j�I���̑傫�����擾
        /// </summary>
        public float Length
        {
            get
            {
                return (float)Math.Sqrt(w * w + x * x + y * y + z * z);
            }
        }

        /// <summary>
        /// �N�I�[�^�j�I���𐳋K��
        /// </summary>
        public Quaternion Normalize()
        {
            Quaternion qt1 = new Quaternion();
            float l1 = this.Length;
            qt1.w = this.w / l1;
            qt1.x = this.x / l1;
            qt1.y = this.y / l1;
            qt1.z = this.z / l1;
            return qt1;

        }

        //������̉�]�ʂ����W�A���ŕԂ�
        public float RotAngle
        {
            get
            {
                return ((float)(Math.Acos(this.w) * 2.0));
            }
        }

        /// <summary>
        /// �N�I�[�^�j�I�����m�̊|���Z�̉��Z�q�̃I�[�o�[���[�h
        /// </summary>
        public static Quaternion operator *(Quaternion z, Quaternion w)
        {
            return Multiply(z, w);
        }

        /// <summary>
        /// �N�I�[�^�j�I���̉�]�ʂ������{
        /// </summary>
        public static Quaternion operator *(Quaternion q, float t)
        {
            q = q.Normalize();
            double halfangle = Math.Acos(q.w);
            if (halfangle == 0.0) //�[����]�͂��̂܂ܕԂ�
            {
                return q;
            }
            float sinrate = (float)(Math.Sin(halfangle * t) / Math.Sin(halfangle));
            q.w = (float)Math.Cos(halfangle * t);
            q.x *= sinrate;
            q.y *= sinrate;
            q.z *= sinrate;
            return q;
        }

        /// <summary>
        /// !���Z�q�������Ɋ��蓖��
        /// </summary>
        public static Quaternion operator !(Quaternion x)
        {
            return Conjugate(x);
        }


        /// <summary>
        /// �N�I�[�^�j�I�����I�C���[�p�ɕϊ�(ZXY)
        /// </summary>
        public EulerAngle ToEulerAngle()
        {
            EulerAngle ea = EulerAngle.GetDefault();

            double xx = 1f - 2 * y * y - 2 * z * z;
            double xy = 2 * x * y - 2 * z * w;
            double xz = 2 * x * z + 2 * y * w;

            double yx = 2 * x * y + 2 * z * w;
            double yy = 1f - 2 * x * x - 2 * z * z;
            double yz = 2 * y * z - 2 * x * w;

            double zx = 2 * x * z - 2 * y * w;
            double zy = 2 * y * z + 2 * x * w;
            double zz = 1f - 2 * x * x - 2 * y * y;

            ea.x = -(float)Math.Asin(yz);

            if (Math.Abs(Math.Cos(ea.x)) < 0.001)
            {
                ea.z = (float)Math.Atan2(xy, xx);
                ea.y = 0;
            }
            else
            {
                ea.z = (float)Math.Atan2(yx, yy);
                ea.y = (float)Math.Asin(xz / Math.Cos(ea.x));
                if (zz < 0) ea.y = (float)Math.PI - ea.y;
            }



            if (ea.x > Math.PI) ea.x = -2 * (float)Math.PI + ea.x;
            if (ea.y > Math.PI) ea.y = -2 * (float)Math.PI + ea.y;
            if (ea.z > Math.PI) ea.z = -2 * (float)Math.PI + ea.z;
            if (ea.x < -Math.PI) ea.x = 2 * (float)Math.PI + ea.x;
            if (ea.y < -Math.PI) ea.y = 2 * (float)Math.PI + ea.y;
            if (ea.z < -Math.PI) ea.z = 2 * (float)Math.PI + ea.z;

            /*int n = 0;

            if (ea.Xd == 180) n++;
            if (ea.Yd == 180) n++;
            if (ea.Zd == 180) n++;

            if (n == 2)
            {
                if (ea.Xd == 180) ea.Xd = 0;
                if (ea.Yd == 180) ea.Yd = 0;
                if (ea.Zd == 180) ea.Zd = 0;

            }*/

            return ea;
        }



        /// <summary>
        /// 2�̃N�I�[�^�j�I���̊Ԃ̕⊮�����l��Ԃ�
        /// </summary>
        public static Quaternion Complement(Quaternion u, Quaternion v, float t)
        {
            Quaternion d = v * (!u); //�����N�I�[�^�j�I��
            d = d.Positive();
            Quaternion r = u * (d * t);
            if (float.IsNaN(r.w))
            {
                
                System.Diagnostics.Debugger.Break();
            }
            return r;
            //return u * (d.Positive() * t);
        }


        /// <summary>
        /// 4�̗v�f���J���}�Ō������ĕԂ�
        /// </summary>
        public override string ToString()
        {
            return x.ToString() + "," + y.ToString() + "," + z.ToString() + "," + w.ToString();
        }

        /// <summary>
        /// �t�H�[�}�b�g���w�肵��4�̗v�f���J���}�Ō������ĕԂ�
        /// </summary>
        public string ToString(string format)
        {
            return x.ToString(format) + "," + y.ToString(format) + "," + z.ToString(format) + "," + w.ToString(format);
        }
    }


    /////////////////////////////////////////////////////////////////////////////////////////////////


    /// <summary>
    /// �I�C���[�p�ɂ���]�̏����i�[����\���̂̒�`
    /// </summary>
    public struct EulerAngle
    {
        public float x; //X�����̉�]
        public float y; //Y�����̉�]
        public float z; //Z�����̉�]

        /// <summary>
        /// Degree�ɂ���]�p�x
        /// </summary>
        public float Xd
        {
            get { return RadToDeg(x); }
            set { x = DegToRad(value); }
        }

        /// <summary>
        /// Degree�ɂ���]�p�x
        /// </summary>
        public float Yd
        {
            get { return RadToDeg(y); }
            set { y = DegToRad(value); }
        }

        /// <summary>
        /// Degree�ɂ���]�p�x
        /// </summary>
        public float Zd
        {
            get { return RadToDeg(z); }
            set { z = DegToRad(value); }
        }

        /// <summary>
        /// �����l���擾
        /// </summary>
        public static EulerAngle GetDefault()
        {
            EulerAngle def;
            def.x = 0;
            def.y = 0;
            def.z = 0;
            return def;
        }

        /// <summary>
        /// �I�C���[�p���N�I�[�^�j�I���ɕϊ�(ZXY)
        /// </summary>
        public Quaternion ToQuaternion()
        {

            Quaternion qx = Quaternion.GetDefault();
            Quaternion qy = Quaternion.GetDefault();
            Quaternion qz = Quaternion.GetDefault();

            //���ꂼ��̒P�Ƃ̎����̉�]�̃N�I�[�^�j�I�����쐬���A����
            qx.x = (float)Math.Sin(this.x / 2);
            qx.w = (float)Math.Cos(this.x / 2);
            qy.y = (float)Math.Sin(this.y / 2);
            qy.w = (float)Math.Cos(this.y / 2);
            qz.z = (float)Math.Sin(this.z / 2);
            qz.w = (float)Math.Cos(this.z / 2);

            return qz * qx * qy;
        }


        /// <summary>
        /// �x�����W�A���ɕϊ�
        /// </summary>
        public static float DegToRad(float x)
        {
            return (float)(x * Math.PI / 180.0);
        }
        /// <summary>
        /// ���W�A����x�ɕϊ�
        /// </summary>
        public static float RadToDeg(float x)
        {
            float y = (float)(x * 180.0 / Math.PI);
            if (y > 0) return (int)(y * 1000 + 0.5f) / 1000f; //��3���Ŏl�̌ܓ�
            else return (int)(y * 1000 - 0.5f) / 1000f; //��3���Ŏl�̌ܓ�
        }

        /// <summary>
        /// 3�̗v�f���J���}�Ō�������degree�ŕ\��:��Ƀf�o�b�O�p
        /// </summary>
        public override string ToString()
        {
            return Xd.ToString() + "," + Yd.ToString() + "," + Zd.ToString();
        }

    }

}
