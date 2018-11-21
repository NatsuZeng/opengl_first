package specter3d.engine.resources
{
	import laya.resource.HTMLImage;
	import laya.webgl.WebGLContext;
	
	import specter3d.engine.specter3d;
	import specter3d.engine.utlis.HTMLImageValidate;

	use namespace specter3d;
	/**
	 * 纹理
	 * @author wangcx
	 *
	 */
	public class BitmapTexture extends TextureResource
	{

		public function BitmapTexture(image:HTMLImage, generateMipmaps:Boolean=false)
		{
			_image=image;
			_generateMipmaps=generateMipmaps;
		}

		/**是否使用重复模式纹理寻址*/
		specter3d var _repeat:Boolean=false;
		specter3d var _smooth:Boolean=false;
		specter3d var _generateMipmaps:Boolean;
		private var _image:HTMLImage;
		/*private var _program:*;*/

		/**HTML Image*/
		public function get image():HTMLImage
		{
			return _image;
		}

		/**
		 * @private
		 */
		public function set image(value:HTMLImage):void
		{
			_image=value;
		}

		override public function upload(_context3d:WebGLContext):void
		{
			if (HTMLImageValidate.isBitmapDataValid(_image))
			{
				_width=_image.width;
				_height=_image.height;

				if (this._glTexture)
				{
					_context3d.deleteTexture(this._glTexture);
				}

				this._glTexture=_context3d.createTexture();
				this._glTexture.image=_image;

				_context3d.pixelStorei(WebGLContext.UNPACK_FLIP_Y_WEBGL, false);
				_context3d.bindTexture(WebGLContext.TEXTURE_2D, this._glTexture);
				_context3d.texImage2D(WebGLContext.TEXTURE_2D, 0, WebGLContext.RGBA, WebGLContext.RGBA, WebGLContext.UNSIGNED_BYTE, _image.source);
				_context3d.texParameteri(WebGLContext.TEXTURE_2D, WebGLContext.TEXTURE_WRAP_S, _repeat ? WebGLContext.REPEAT : WebGLContext.CLAMP_TO_EDGE);
				_context3d.texParameteri(WebGLContext.TEXTURE_2D, WebGLContext.TEXTURE_WRAP_T, _repeat ? WebGLContext.REPEAT : WebGLContext.CLAMP_TO_EDGE);
				_context3d.texParameteri(WebGLContext.TEXTURE_2D, WebGLContext.TEXTURE_MAG_FILTER, _smooth ? WebGLContext.LINEAR : WebGLContext.NEAREST);
				if (!_generateMipmaps)
				{
					_context3d.texParameteri(WebGLContext.TEXTURE_2D, WebGLContext.TEXTURE_MIN_FILTER, _smooth ? WebGLContext.LINEAR : WebGLContext.NEAREST);
				}
				else
				{
					_context3d.texParameteri(WebGLContext.TEXTURE_2D, WebGLContext.TEXTURE_MIN_FILTER, _smooth ? WebGLContext.LINEAR_MIPMAP_LINEAR : WebGLContext.LINEAR_MIPMAP_NEAREST);
					//告诉WebGL为当前活动纹理生成对应的一系列MipMap层
					_context3d.generateMipmap(WebGLContext.TEXTURE_2D);	
				}
			}
		}
		
		public function activeTexture(_context3d:WebGLContext,activeIndex:int):void
		{
			_context3d.activeTexture(activeIndex);
			_context3d.bindTexture(WebGLContext.TEXTURE_2D, this._glTexture);
		}
	}
}
