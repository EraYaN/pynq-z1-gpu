using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;
using System.Windows.Documents;
using System.Windows.Input;
//using System.Windows.Media;
using System.Windows.Media.Imaging;
using System.Windows.Navigation;
using System.Windows.Shapes;
using System.Drawing;
using System.IO;
using System.Collections;

namespace SpriteTool
{
    // RAM Addresses
    // 16x16: (128+120)*256 + 64 * ID_MONO16 + offset   
    enum SpriteType
    {
        Mono //16x16        
    }
    /// <summary>
    /// Interaction logic for MainWindow.xaml
    /// </summary>
    public partial class MainWindow : Window
    {
        Bitmap wimg;
		const byte bitsperbyte = 6;
        public MainWindow()
        {
            InitializeComponent();
        }

        private void dropLabelMono_Drop(object sender, DragEventArgs e)
        {
            if (e.Data.GetDataPresent(DataFormats.FileDrop))
            {

				string[] files_tmp = (string[])e.Data.GetData(DataFormats.FileDrop);
				List<string> files = new List<string>();
				List<string> Extensions = new List<string> { ".JPG", ".JPEG", ".JPE", ".BMP", ".GIF", ".PNG" ,".TIFF", ".TIF"};
				foreach (string s in files_tmp)
				{
					if (File.Exists(s))
					{
						if (Extensions.Contains(System.IO.Path.GetExtension(s).ToUpperInvariant()))
						{
							files.Add(s);
						}
					}
					if (Directory.Exists(s))
					{
						DirectoryInfo di = new DirectoryInfo(s);
						FileInfo[] fis = di.GetFiles("*.*", SearchOption.AllDirectories);
						foreach (FileInfo fi in fis)
						{
							if (Extensions.Contains(fi.Extension.ToUpperInvariant()))
							{
								files.Add(fi.FullName);
							}
						}
					}
				}
				if (files.Count > 0)
				{
					string setname;
					if (setName_TextBox.Text != "")
						setname = setName_TextBox.Text;
					else
						setname = System.IO.Path.GetFileNameWithoutExtension(files[0]);
					bool firstfile = true;
					files.Sort();
					using (StreamWriter sw = new StreamWriter(setname + "_set.cpp"))
					{
                        using (StreamWriter sw_h = new StreamWriter(setname + "_set.h"))
                        {
                            using (StreamWriter sw_data = new StreamWriter(setname + "_set_data.cpp"))
                            {
                                using (StreamWriter sw_data_h = new StreamWriter(setname + "_set_data.h"))
                                {
                                    sw_h.WriteLine("#pragma once");
                                    sw_h.WriteLine("#ifndef _SPRITES_SET_{0}_", setname.ToUpper());
                                    sw_h.WriteLine("#define _SPRITES_SET_{0}_", setname.ToUpper());
                                    sw_h.WriteLine("#include \"{0}\"", setname + "_set_data.h");
                                    sw_h.WriteLine("extern Sprite *sprites_{0}_set[];", setname.ToLower());
                                    sw.WriteLine("#include \"Util.h\"");
                                    sw.WriteLine("//Number of sprites in set: {0}", files.Count());
                                    sw.Write("Sprite *sprites_{0}_set[] = ", setname.ToLower());
                                    sw.WriteLine("{");
                                    sw_data.WriteLine("#include \"Util.h\"");
                                    sw_data_h.WriteLine("#pragma once");
                                    sw_data_h.WriteLine("#ifndef _SPRITES_SET_{0}_DATA_", setname.ToUpper());
                                    sw_data_h.WriteLine("#define _SPRITES_SET_{0}_DATA_", setname.ToUpper());
                                    foreach (string f in files)
                                    {
                                        processFile(f, setname, sw, sw_h, sw_data, sw_data_h, firstfile);
                                        firstfile = false;
                                    }
                                    sw.WriteLine("\r\n};");
                                    sw_h.WriteLine("#endif");
                                    sw_data_h.WriteLine("#endif");
                                }
                            }
                        }
					}
				}
            }
        }
        void processFile(string filename, string setname, StreamWriter sw, StreamWriter sw_h, StreamWriter sw_data, StreamWriter sw_data_h, bool firstfile = false)
		{
			wimg = (Bitmap)Bitmap.FromFile(filename, true);
			int h = wimg.Height;
			int w = wimg.Width;
			int size = w * h;
			Color[] sprite = new Color[size];
			int i = 0;
			for (int y = 0; y < h; y++)
			{
				for (int x = w - 1; x >= 0; x--)
				{
					sprite[i] = wimg.GetPixel(x, y);
					i++;
				}
			}
			wimg.Dispose();
			string varname = System.IO.Path.GetFileNameWithoutExtension(filename);
			if(!firstfile){
				sw.WriteLine(",");
			}
			sw.Write("new Sprite(0,{0},{1},{2},set_{3}_sprite_{4})", w, h, (int)Math.Ceiling((w * h) / 6.0), setname, varname);
			sw_data.Write("extern const prog_uchar set_{0}_sprite_{1}[] = ", setname, varname);
            sw_data_h.WriteLine("PROGMEM extern const prog_uchar set_{0}_sprite_{1}[];", setname, varname);
			sw_data.WriteLine("{");
			uint data = 0;
			i = bitsperbyte-1;
			int count = 0 ;
			bool first = true;
			foreach (Color c in sprite)
			{
				uint grayscale1 = Conv8to1(ConvRGBto8(c))==1?0u:1u;
				data = data | (grayscale1 << (byte)((bitsperbyte-1) - i));
				i--;
				if (i < 0)
				{
					i = bitsperbyte-1;
					if (!first)
						sw_data.Write(",");
					if (count % 8 == 0)
					{
                        if (!first)
                        {
                            sw_data.WriteLine();
                        }
						sw_data.Write("\t");
					}
					count++;
					first = false;
					sw_data.Write("{0,3}", data);
					data = 0;
				}
			}
			sw_data.WriteLine("\r\n};\r\n");
		}
        
        uint Conv4to8(uint a)
        {
            return (uint)Math.Round((double)a * 255.0 / 15.0);
        }
        uint Conv8to4(uint a)
        {
            return (uint)Math.Min(15, Math.Round((double)a / 256.0 * 16.0));
        }
        uint Conv8to1(uint a)
        {
            return (uint)Math.Min(1, Math.Round((double)a / 256.0));
        }
        uint ConvRGBto8(Color c)
        {
            return (uint)Math.Round(((float)c.B + (float)c.G + (float)c.R)/3);
        }
    }
}
