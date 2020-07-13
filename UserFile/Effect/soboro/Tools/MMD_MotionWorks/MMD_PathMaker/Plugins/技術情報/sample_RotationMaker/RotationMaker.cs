using System;
using System.Collections.Generic;
using System.Text;
using System.Windows.Forms;
using PathMakerPlugin;

namespace RotationMaker
{
    public class RotationMaker : IPlugin
    {
        IPluginHost host;

        public string Name
        {
            get { return "��]���C�J�["; }
        }

        public string Version
        {
            get {
                //�������g��Assembly���擾���A�o�[�W������Ԃ�
                System.Reflection.Assembly asm =
                    System.Reflection.Assembly.GetExecutingAssembly();
                System.Version ver = asm.GetName().Version;
                return ver.ToString();
            }
        }

        public string Description
        {
            get { return ""; }
        }

        public IPluginHost Host
        {
            get { return host; }
            set { host = value; }
        }

        Form1 frm;

        public void Run()
        {
            if (frm != null && !frm.IsDisposed)
            {
                frm.Activate();
                return;
            }

            //�t�H�[�������[�h
            frm = new Form1(Host);
            frm.Show();

        }
    }
}
