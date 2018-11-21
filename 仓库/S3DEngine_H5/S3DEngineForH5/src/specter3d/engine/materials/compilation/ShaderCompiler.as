package specter3d.engine.materials.compilation
{
	import laya.webgl.WebGLContext;
	import specter3d.engine.debug.Debug;
	import specter3d.engine.materials.passes.Material3DPass;
	import specter3d.engine.specter3d;

	use namespace specter3d;
	/**
	 *  ShaderCompiler
	 * @author wangcx
	 * 
	 */	
	public class ShaderCompiler
	{
		public static var FRAGMENTS_PROGRAM:String=null;
		public static var LIGHTING_PROGRAM:String=null;
		public static var VERTEX_PROGRAM:String=null;
		/**
		 * 指定shader的版本默认是 GLSL 1.0
		 */
		public static var shaderVersion:int=100;

		private static var _currentId:int;
		private static var _ids:Array=[];
		private static var _keys:Array=[];

		private static var _program3DCache:Array=[];
		private static var _usages:Array=[];

		public static function __initDefinition__():void
		{
			if (VERTEX_PROGRAM == null || FRAGMENTS_PROGRAM == null)
			{
				VERTEX_PROGRAM=__INCLUDESTR__("shader/files/VertexMainProgram.vs");
				FRAGMENTS_PROGRAM=__INCLUDESTR__("shader/files/FragmentsMainProgram.fs");
				LIGHTING_PROGRAM=__INCLUDESTR__("shader/files/Lighting.glsl");
			}
		}

		public static function compile(_context3d:WebGLContext, pass:Material3DPass, vertexCode:String, fragmentCode:String):*
		{
			var key:String=getKey(vertexCode, fragmentCode);
			var _program:*=_program3DCache[key];
			if (_program == null)
			{
				_keys[_currentId]=key;
				_usages[_currentId]=0;
				_ids[key]=_currentId;
				++_currentId;

				_program=_context3d.createProgram();

				var _vshader:*=createShader(WebGLContext.VERTEX_SHADER, vertexCode, _context3d);
				var _fshader:*=createShader(WebGLContext.FRAGMENT_SHADER, fragmentCode, _context3d);
				uploadProgram3D(_context3d, _program, _vshader, _fshader);

				_program3DCache[key]=_program;
				
				if (Debug.glslDebug)
				{
					Debug.dotrace(Debug.ENGINE, "Compiling GLSL VertexCode: \n" + vertexCode);
					Debug.dotrace(Debug.ENGINE, "Compiling GLSL FragmentCode: \n" + fragmentCode);
				}
			}
			_context3d.useProgram(_program);

			var oldId:int=pass.material._programId;
			var newId:int=_ids[key];
			if (oldId != newId)
			{
				if (oldId >= 0)
					freeProgram3D(_context3d, oldId);
				_usages[newId]++;
			}
			pass.material._programId=newId;

			return _program;
		}

		/**
		 * 创建shader
		 * @param mode
		 * @param source
		 * @return
		 *
		 */
		private static function createShader(mode:*, source:String, _context3d:WebGLContext):*
		{

			var _shader:*=_context3d.createShader(mode);
			_context3d.shaderSource(_shader, source);
			_context3d.compileShader(_shader);
			/*[IF-FLASH]*/
			return _shader;
			if (!_context3d.getShaderParameter(_shader, WebGLContext.COMPILE_STATUS))
			{
				throw _context3d.getShaderInfoLog(_shader);
			}
			return _shader;
		}

		private static function freeProgram3D(_context3d:WebGLContext, programId:int):void
		{
			_usages[programId]--;
			if (_usages[programId] == 0)
			{
				var key:String=_keys[programId];
				_context3d.deleteProgram(_program3DCache[key]);
				_program3DCache[key]=null;
				delete _program3DCache[key];
				_ids[key]=-1;
			}
		}

		private static function getKey(vertexCode:String, fragmentCode:String):String
		{
			return vertexCode + "__" + fragmentCode;
		}

		private static function uploadProgram3D(_context3d:WebGLContext, _program:*, _vshader:*, _fshader:*):void
		{
			_context3d.attachShader(_program, _vshader);
			_context3d.attachShader(_program, _fshader);
			_context3d.linkProgram(_program);
		}
	}
}
