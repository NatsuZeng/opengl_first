package specter3d.engine.materials.passes
{
	import laya.events.EventDispatcher;
	import laya.webgl.WebGLContext;
	
	import specter3d.engine.specter3d;
	import specter3d.engine.core.camera.Camera3D;
	import specter3d.engine.core.context.AppGlobalContext;
	import specter3d.engine.core.geom.Vector3D;
	import specter3d.engine.core.render.data.DrawUnit;
	import specter3d.engine.errors.AbstractMethodError;
	import specter3d.engine.materials.Material3D;
	import specter3d.engine.materials.compilation.ShaderCompiler;
	import specter3d.engine.materials.compilation.ShaderElementArray;
	import specter3d.engine.materials.compilation.ShaderRegisterUsage;
	import specter3d.engine.resources.BitmapTexture;

	use namespace specter3d;

	/**
	 * Material3DPass
	 * @author wangcx
	 *
	 */
	public class Material3DPass extends EventDispatcher
	{
		public function Material3DPass(material:Material3D)
		{
			super();
			_material=material;
			_vertexCode=new ShaderElementArray(ShaderCompiler.shaderVersion);
			_fragmentCode=new ShaderElementArray(ShaderCompiler.shaderVersion);
			ShaderCompiler.__initDefinition__();
		}
		
		protected var _alpha:Number=1;
		protected var _color:Vector3D;
		protected var _diffuseTexture:BitmapTexture;
		protected var _normalMapTexture:BitmapTexture;
		protected var _material:Material3D;
		protected var _mipmap:Boolean=true;
		protected var _program:*;
		protected var _repeat:Boolean=false;
		protected var _smooth:Boolean=true;
		
		protected var _useNormal:Boolean=true;
		protected var _useTangent:Boolean=false;
		protected var _useUV:Boolean=false;
		
		protected var _alphaBlend:Boolean = false;
		protected var _bothSides:Boolean = false;
		protected var _defaultCulling:int = WebGLContext.BACK;
		
		private var _fragmentCode:ShaderElementArray;
		private var _vertexCode:ShaderElementArray;

		public function get normalMapTexture():BitmapTexture
		{
			return _normalMapTexture;
		}

		public function set normalMapTexture(value:BitmapTexture):void
		{
			_normalMapTexture = value;
			_useTangent = true;
		}

		public function get bothSides():Boolean
		{
			return _bothSides;
		}

		public function set bothSides(value:Boolean):void
		{
			_bothSides = value;
		}

		public function get alphaBlend():Boolean
		{
			return _alphaBlend;
		}

		public function set alphaBlend(value:Boolean):void
		{
			_alphaBlend = value;
		}

		public function get color():Vector3D
		{
			return _color;
		}

		public function set color(value:Vector3D):void
		{
			_color = value;
		}

		public function get alpha():Number
		{
			return _alpha;
		}

		public function set alpha(value:Number):void
		{
			if(value >= 0)
			{
				_alpha = value;
			}
		}

		public function get diffuseTexture():BitmapTexture
		{
			return _diffuseTexture;
		}

		public function set diffuseTexture(value:BitmapTexture):void
		{
			_diffuseTexture=value;
			_useUV=_diffuseTexture != null;
		}

		public function get material():Material3D
		{
			return _material;
		}

		public function get mipmap():Boolean
		{
			return _mipmap;
		}

		public function set mipmap(value:Boolean):void
		{
			_mipmap=value;
		}

		public function get repeat():Boolean
		{
			return _repeat;
		}

		public function set repeat(value:Boolean):void
		{
			_repeat=value;
		}

		public function get smooth():Boolean
		{
			return _smooth;
		}

		public function set smooth(value:Boolean):void
		{
			_smooth=value;
		}

		protected function getFragmentCode(code:ShaderElementArray):ShaderElementArray
		{
			throw new AbstractMethodError();
		}

		protected function getVertexCode(code:ShaderElementArray):ShaderElementArray
		{
			throw new AbstractMethodError();
		}

		specter3d function render(_context3d:WebGLContext, renderable:DrawUnit, camera:Camera3D):void
		{
			updateProgram(_context3d);
			if (renderable)
			{
				if(renderable.transform)
				{
					renderable.transform.updateModelViewProjection(camera);
					var u_projectionMatrix:*=_context3d.getUniformLocation(_program, "u_projectionMatrix");
					_context3d.uniformMatrix4fv(u_projectionMatrix, false, camera.projectMatrix.rawData);
					var u_viewMatrix:*=_context3d.getUniformLocation(_program, "u_viewMatrix");
					_context3d.uniformMatrix4fv(u_viewMatrix, false, camera.viewMatrix.rawData);
					var u_modelMatrix:*=_context3d.getUniformLocation(_program, "u_modelMatrix");
					_context3d.uniformMatrix4fv(u_modelMatrix, false, renderable.transform.world.rawData);
				}
				if(renderable.subGeometry)
				{
					renderable.subGeometry.activate(_context3d, camera, _program);	
				}
			}

			if (_diffuseTexture)
			{
				!_diffuseTexture.isUploaded && _diffuseTexture.upload(_context3d);
				_diffuseTexture.activeTexture(_context3d,WebGLContext.TEXTURE0);
				var diffuseTextureSampler:*=_context3d.getUniformLocation(_program, ShaderRegisterUsage.DIFFUSE_SAMPLER);
				_context3d.uniform1i(diffuseTextureSampler, 0);
				if(_normalMapTexture)
				{
					!_normalMapTexture.isUploaded && _normalMapTexture.upload(_context3d);
					_normalMapTexture.activeTexture(_context3d,WebGLContext.TEXTURE1);
					var normalMapSampler:*=_context3d.getUniformLocation(_program, ShaderRegisterUsage.NORMAL_MAP_SAMPLER);
					_context3d.uniform1i(normalMapSampler, 0);
				}
			}
			else
			{
				_color ||= new Vector3D();
				var diffuseColorSampler:*=_context3d.getUniformLocation(_program, ShaderRegisterUsage.DIFFUSE_COLOR);
				_context3d.uniform3fv(diffuseColorSampler, _color.elementsForVec3);
				
				_context3d.enable(WebGLContext.BLEND);
				_context3d.blendFunc(WebGLContext.SRC_ALPHA, WebGLContext.ONE_MINUS_SRC_ALPHA);
			}
			var u_alpha:*=_context3d.getUniformLocation(_program, ShaderRegisterUsage.DIFFUSE_ALPHA);
			_context3d.uniform1f(u_alpha, _alpha);
			
			if (_bothSides)
			{
				AppGlobalContext.stage3d.cullFaceEnabled = false;
			}
			else
			{
				AppGlobalContext.stage3d.cullFaceEnabled = true;
				AppGlobalContext.stage3d.cullFace = _defaultCulling;
			}
		}

		specter3d function updateProgram(_context3d:WebGLContext):void
		{
			_vertexCode=getVertexCode(_vertexCode);
			_fragmentCode=getFragmentCode(_fragmentCode);
			_program=ShaderCompiler.compile(_context3d, this, _vertexCode.toString(), _fragmentCode.toString());
			_vertexCode.clear();
			_fragmentCode.clear();
		}
	}
}
