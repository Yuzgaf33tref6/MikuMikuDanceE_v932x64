using System;
using System.Collections.Generic;
using System.Text;
using System.IO;

namespace xBlack
{
    class Program
    {
        static void Main(string[] args)
        {
            foreach (string arg in args)
            {
                if (arg.ToLower().EndsWith(".x"))
                {
                    try
                    {
                        Console.WriteLine("Convert: " + arg);

                        Encoding Shift_JIS = Encoding.GetEncoding(932);

                        FileStream fs = new FileStream(arg, FileMode.Open, FileAccess.Read);
                        StreamReader sr = new StreamReader(fs, Shift_JIS);

                        string x = sr.ReadToEnd();

                        sr.Close();


                        x = xConvert(x);


                        string outfile = Path.Combine(Path.GetDirectoryName(arg), Path.GetFileNameWithoutExtension(arg) + "_black.x");
                        FileStream fso = new FileStream(outfile, FileMode.Create, FileAccess.Write);
                        StreamWriter sw = new StreamWriter(fso, Shift_JIS);
                        sw.Write(x);

                        sw.Close();

                    }
                    catch
                    {
                        Console.Error.WriteLine("Error!");
                    }
                }
            }
        }

        const string MaterialScript = "Material";

        const string MaterialBlack = "{\r"
            + "  0.0000;0.0000;0.0000;1.0;;\r"
            + "  5.0000;\r"
            + "  0.0000;0.0000;0.0000;;\r"
            + "  0.0000;0.0000;0.0000;;\r"
            + "}";

        static string xConvert(string x)
        {
            int i = 0, j;

            //���s�R�[�h��ϊ�
            x = x.Replace("\r\n", "\r");
            x = x.Replace("\n", "\r");

            while (true)
            {
                //"Material"������
                int index = x.IndexOf(MaterialScript, i);
                
                if (index < 0)
                {
                    break; //������Ȃ���ΏI��
                }
                else
                {
                    bool isMaterial = true;
                    int indent = 0;

                    //�s���܂łɃX�y�[�X�ȊO����������}�e���A���w��łȂ�
                    for (j = index - 1; j >= 0; j--)
                    {
                        char c = x[j];
                        if (c == '\r')
                        {
                            break;
                        }
                        else if (c == ' ')
                        {
                            indent++;
                        }
                        else
                        {
                            isMaterial = false;
                        }
                    }

                    //���̕�����" "�܂���"{"�łȂ���΃}�e���A���w��łȂ�
                    char nextchar = x[index + MaterialScript.Length];
                    if (nextchar != ' ' && nextchar != '{')
                    {
                        isMaterial = false;
                    }

                    //�}�e���A���w��Ɣ��f�ł��鎞
                    if (isMaterial)
                    {
                        int start = 0, length = 0;
                        int nestcount = 0;

                        //�}�e���A���p�����[�^�̎w��͈͂�T��
                        for (j = index + MaterialScript.Length; j < x.Length; j++)
                        {
                            if (x[j] == '{')
                            {
                                nestcount++;
                                if (start == 0) start = j; //�ŏ���"{"
                            }
                            else if (x[j] == '}')
                            {
                                nestcount--;
                                if (start != 0 && nestcount == 0) break; //"{ }"������
                            }
                        }

                        length = j - start + 1;

                        //���炩�ɒ������Ă����������̓X�L�b�v
                        if (length > 500)
                        {
                            i = index + MaterialScript.Length;
                        }
                        else
                        {

                            //�}�e���A�������ɒu���{�C���f���g���킹
                            x = x.Remove(start, length);
                            x = x.Insert(start, MaterialBlack.Replace("\r", "\r".PadRight(indent + 1)));

                            i = start + MaterialBlack.Length;

                        }

                    }
                    else
                    {
                        i = index + MaterialScript.Length;
                    }
                }
            }

            //���s�R�[�h��Windows�d�l�ɖ߂�
            x = x.Replace("\r", Environment.NewLine);

            return x;
        }
    }

    
}
