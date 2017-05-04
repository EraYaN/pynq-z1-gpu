using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Drawing;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Data;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Media.Imaging;
using System.Windows.Navigation;
using System.Windows.Shapes;
using System.Runtime.InteropServices;
using System.IO;

namespace SRAMDebugTool
{
	/// <summary>
	/// Interaction logic for MainWindow.xaml
	/// </summary>
	public partial class MainWindow : Window
	{
		Bitmap MemoryMap;
		Color foregroundColor = Color.Black;
		Color backgroundColor = Color.White;
		const Boolean IsGrayscale = true;
		public MainWindow()
		{
			InitializeComponent();
			MemoryMap = new Bitmap(256, 256);
			for (int y = 0; y < MemoryMap.Height; y++)
			{
				for (int x = 0; x < MemoryMap.Width; x++)
				{
					MemoryMap.SetPixel(x, y, Color.FromKnownColor(KnownColor.Blue));
				}
			}
			MemoryMapImage.Source = loadBitmap(MemoryMap);
			for (int i = 0; i < 64; i++)
			{
				Button button = new Button();
				button.MouseDown += button_MouseDown;
				button.Content = String.Format("Kleur: {0}",Convert.ToString(i,16).ToUpper());
				button.Foreground = System.Windows.Media.Brushes.Red;
				byte grayvalue = (byte)Conv6to8(i);
				System.Windows.Media.SolidColorBrush mySolidColorBrush = new System.Windows.Media.SolidColorBrush();
				mySolidColorBrush.Color = System.Windows.Media.Color.FromArgb(255, grayvalue, grayvalue, grayvalue);
				button.Background = mySolidColorBrush;
				button.BorderThickness = new Thickness(0);
				ColorStack.Children.Add(button);
			}
		}

		void button_MouseDown(object sender, MouseButtonEventArgs e)
		{
			Button s = (Button)sender;
			System.Windows.Media.Color c =  ((System.Windows.Media.SolidColorBrush)s.Background).Color;

			if (e.LeftButton==MouseButtonState.Pressed)
			{				
				foregroundColor = Color.FromArgb(c.R,c.G,c.B);
			}
			if (e.RightButton == MouseButtonState.Pressed)
			{
				backgroundColor = Color.FromArgb(c.R, c.G, c.B);
			}
		}

		[DllImport("gdi32")]
		static extern int DeleteObject(IntPtr o);

		public static BitmapSource loadBitmap(System.Drawing.Bitmap source)
		{
			IntPtr ip = source.GetHbitmap();
			BitmapSource bs = null;
			try
			{
				bs = System.Windows.Interop.Imaging.CreateBitmapSourceFromHBitmap(ip,
				   IntPtr.Zero, Int32Rect.Empty,
				   System.Windows.Media.Imaging.BitmapSizeOptions.FromEmptyOptions());
			}
			finally
			{
				DeleteObject(ip);
			}

			return bs;
		}
		private void MemoryMapImage_MouseMove(object sender, MouseEventArgs e)
		{
			System.Windows.Point p = Mouse.GetPosition(MemoryMapImage);
			int X = (int)Math.Round(p.X / MemoryMapImage.ActualWidth * MemoryMap.Width);
			int Y = (int)Math.Round(p.Y / MemoryMapImage.ActualHeight * MemoryMap.Height);
			if (e.LeftButton == MouseButtonState.Pressed)
			{
				if (X < MemoryMap.Width && Y < MemoryMap.Height)
					MemoryMap.SetPixel(X, Y, foregroundColor);
			}
			else if (e.RightButton == MouseButtonState.Pressed)
			{
				if (Y < MemoryMap.Width && Y < MemoryMap.Height)
					MemoryMap.SetPixel(X, Y, backgroundColor);
			}
			MemoryMapImage.Source = loadBitmap(MemoryMap);
			statusBarPosition.Content = String.Format("Position: ({0,3}, {1,3}); Mem cell: {2,6} ({2:X4}))", X, Y, X + Y * MemoryMap.Width);
		}

		private void readButton_Click(object sender, RoutedEventArgs e)
		{
			try
			{
				using (StreamReader sr = new StreamReader(filename.Text))
				{
					while (!sr.EndOfStream)
					{
						String[] tmp = sr.ReadLine().Split(' ');
						if (tmp.Length == 2)
						{
							int i = Convert.ToInt32(tmp[0]);
							int y = i / MemoryMap.Width;
							int x = i % MemoryMap.Width;
							if (tmp[1].Contains('X'))
							{
								MemoryMap.SetPixel(x, y, Color.FromKnownColor(KnownColor.Blue));
							}
							else
							{
								if (IsGrayscale)
								{
									int grayvalue = Conv6to8(Convert.ToInt32(tmp[1], 2));
									MemoryMap.SetPixel(x, y, Color.FromArgb(grayvalue, grayvalue, grayvalue));
								}
							}
						}

					}
				}
				MemoryMapImage.Source = loadBitmap(MemoryMap);
			}
			catch (Exception ex)
			{
				MessageBox.Show(ex.ToString());
			}
		}
		private void writeButton_Click(object sender, RoutedEventArgs e)
		{
			try
			{
				using (StreamWriter sw = new StreamWriter(filename.Text))
				{
					int i = 0;
					for (int y = 0; y < MemoryMap.Height; y++)
					{
						for (int x = 0; x < MemoryMap.Width; x++)
						{
							Color c = MemoryMap.GetPixel(x, y);
							StringBuilder VHDLString = new StringBuilder();
							if (IsGrayscale)
							{
								if (c.ToArgb() == Color.Blue.ToArgb())
								{
									VHDLString.Append("XXXXXX");
								}
								else
								{
									int grayvalue = Conv8to6(ConvRGBto8(c));
									VHDLString.Append(Convert.ToString(grayvalue, 2).PadLeft(6, '0'));
								}
							}

							sw.WriteLine("{0} {1}", i, VHDLString.ToString());
							i++;
						}
					}
				}
			}
			catch (Exception ex)
			{
				MessageBox.Show(ex.ToString());
			}
		}
		int Conv4to8(int a)
		{
			return (int)Math.Round((double)a * 256.0 / 16.0);
		}
		int Conv8to4(int a)
		{
			return (int)Math.Min(15, Math.Round((double)a / 256.0 * 16.0));
		}
		int Conv6to8(int a)
		{
			return (int)Math.Round((double)a * 256.0 / 64.0);
		}
		int Conv8to6(int a)
		{
			return (int)Math.Min(63, Math.Round((double)a / 256.0 * 64.0));
		}
        int ConvRGBto8(Color c)
        {
            return (int)Math.Round(((float)c.B + (float)c.G + (float)c.R) / 3);
        }
	}
}
