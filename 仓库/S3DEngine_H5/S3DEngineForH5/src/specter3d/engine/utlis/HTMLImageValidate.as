package specter3d.engine.utlis
{
	import laya.resource.HTMLImage;
	
	
	public class HTMLImageValidate
	{
		private static const MAX_SIZE:uint = 2048;
		
		public static function isBitmapDataValid(img:HTMLImage):Boolean
		{
			if (img == null)
				return true;
			
			return isDimensionValid(img.width) && isDimensionValid(img.height);
		}
		
		public static function isDimensionValid(d:uint):Boolean
		{
			return d >= 1 && d <= MAX_SIZE && isPowerOfTwo(d);
		}
		
		public static function isPowerOfTwo(value:int):Boolean
		{
			return value? ((value & -value) == value) : false;
		}
		
		public static function getBestPowerOf2(value:uint):uint
		{
			var p:uint = 1;
			
			while (p < value)
				p <<= 1;
			
			if (p > MAX_SIZE)
				p = MAX_SIZE;
			
			return p;
		}
	}
}
