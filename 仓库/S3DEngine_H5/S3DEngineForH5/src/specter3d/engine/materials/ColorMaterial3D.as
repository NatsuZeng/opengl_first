package specter3d.engine.materials
{
	import specter3d.engine.core.geom.Vector3D;

	public class ColorMaterial3D extends Material3D
	{
		private var _color:uint = 0xffffff;
		
		public function ColorMaterial3D(color : uint = 0xcccccc, alpha : Number = 1)
		{
			super();
			this.color = color;
			this.alpha = alpha;
		}

		public function get color():uint
		{
			return _color;
		}

		public function set color(value:uint):void
		{
			_color = value;
			var _colorR:Number=((_color >> 16) & 0xff) / 255;
			var _colorG:Number=((_color >> 8) & 0xff) / 255;
			var _colorB:Number=(_color & 0xff) / 255;
			_compiledPass.color = new Vector3D(_colorR,_colorG,_colorB)
		}
	}
}