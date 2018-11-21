package specter3d.engine.resources
{
	import laya.webgl.WebGLContext;
	import specter3d.engine.core.context.AppGlobalContext;
	import specter3d.engine.specter3d;

	use namespace specter3d;
	public class TextureResource extends ResourceBase
	{

		public function TextureResource(name:String=null)
		{
			super(name);
		}
		protected var _height:int;

		protected var _width:int;
		/**
		 * WebGLTexture
		 */
		protected var _glTexture:*;

		/**
		 * @inheritDoc
		 */
		override public function dispose():void
		{
			var _context3d:WebGLContext=AppGlobalContext.stage3d.webglContext;
			if (_glTexture != null)
			{
				_context3d.deleteTexture(_glTexture);
				_glTexture=null; 
				_context3d=null;
			}
		}

		public function get height():int
		{
			return _height;
		}

		/**
		 * @inheritDoc
		 */
		override public function get isUploaded():Boolean
		{
			return _glTexture != null;
		}

		public function get width():int
		{
			return _width;
		}
	}
}
