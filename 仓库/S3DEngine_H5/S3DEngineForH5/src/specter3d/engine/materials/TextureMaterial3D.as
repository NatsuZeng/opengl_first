package specter3d.engine.materials
{
	import specter3d.engine.specter3d;
	import specter3d.engine.resources.BitmapTexture;

	use namespace specter3d;
	
	public class TextureMaterial3D extends Material3D
	{
		
		public function TextureMaterial3D(diffuseTexture:BitmapTexture,smooth:Boolean = true, repeat:Boolean = false, mipmap:Boolean = true)
		{
			super();
			this.smooth = smooth;
			this.repeat = repeat;
			this.mipmap = mipmap;
			this.diffuseTexture = diffuseTexture;
		}
		
		public function get normalMap():BitmapTexture
		{
			return _compiledPass.normalMapTexture;
		}

		public function set normalMap(value:BitmapTexture):void
		{
			_compiledPass.normalMapTexture = value;
		}

		specter3d function get diffuseTexture():BitmapTexture
		{
			return _compiledPass.diffuseTexture;
		}

		specter3d function set diffuseTexture(value:BitmapTexture):void
		{
			_compiledPass.diffuseTexture = value;
		}

		public function set smooth(value:Boolean):void
		{
			_compiledPass.smooth = value;
		}
		
		public function set repeat(value:Boolean):void
		{
			_compiledPass.repeat = value;
		}
		
		public function set mipmap(value:Boolean):void
		{
			_compiledPass.mipmap = value;
		}		
	}
}