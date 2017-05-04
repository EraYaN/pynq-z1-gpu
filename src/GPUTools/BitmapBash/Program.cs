using System;
using System.Drawing;

namespace BitmapBash
{
	class Program
	{
		static void Main(string[] args)
		{
			Bitmap source = new Bitmap("bitmap.png");
			char[] ascii = " !\"#$%&\'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~".ToCharArray();
			bool useAscii;
			int h_div, v_div;
			
			Console.WriteLine("I can use ascii encoding? (Y/N)");
			if (Console.ReadKey(false).Key == ConsoleKey.Y)
				useAscii = true;
			else
				useAscii = false;
			Console.WriteLine("\nKthx");

			Console.WriteLine("I can haz teh horizontal dividr: ");
			while(true)
			{
				if (Int32.TryParse(Console.ReadLine().ToString(), out h_div))
					break;
				else
					Console.WriteLine("Teh input iz not numerical");			
			}
			Console.WriteLine("Kthx");

			Console.WriteLine("I can haz teh vertical dividr: ");
			while (true)
			{
				if (Int32.TryParse(Console.ReadLine().ToString(), out v_div))
					break;
				else
					Console.WriteLine("Teh input iz not numerical");
			}
			Console.WriteLine("Kthx");

			int numcols = (int)Math.Ceiling((double)source.Width / h_div);
			int numrows = (int)Math.Ceiling((double)source.Height / v_div);
			int numblocks = numcols*numrows;

			for (int i=0; i<numblocks; i++)
			{
				Bitmap cbitmap = new Bitmap(h_div, v_div);
				using (Graphics g = Graphics.FromImage(cbitmap))
				{
					g.DrawImage(source, new Rectangle(0, 0, cbitmap.Width, cbitmap.Height), new Rectangle(cbitmap.Width * (i % numcols), cbitmap.Height * (int)Math.Floor((double)i/numcols), cbitmap.Width, cbitmap.Height), GraphicsUnit.Pixel);
				}
				if (useAscii && i <= ascii.Length)
					cbitmap.Save((int)ascii[i] + ".bmp");
				else
					cbitmap.Save(i + ".bmp");
			}
			Console.WriteLine("I is done, kthxbai");
		}
	}
}
