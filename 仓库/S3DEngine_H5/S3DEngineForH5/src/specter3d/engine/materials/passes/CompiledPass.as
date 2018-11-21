package specter3d.engine.materials.passes
{
	import laya.webgl.WebGLContext;
	
	import specter3d.engine.specter3d;
	import specter3d.engine.core.camera.Camera3D;
	import specter3d.engine.core.geom.Vector3D;
	import specter3d.engine.core.render.data.DrawUnit;
	import specter3d.engine.lights.DirectionLight;
	import specter3d.engine.lights.PointLight;
	import specter3d.engine.materials.Material3D;
	import specter3d.engine.materials.compilation.ShaderCompiler;
	import specter3d.engine.materials.compilation.ShaderElementArray;
	import specter3d.engine.materials.compilation.ShaderRegisterUsage;
	import specter3d.engine.materials.lightpickers.LightPicker;

	use namespace specter3d;
	/**
	 * CompiledPass
	 * @author wangcx
	 *
	 */
	public class CompiledPass extends Material3DPass
	{

		public function CompiledPass(material:Material3D)
		{
			super(material);
		}
		/**
		 * 材质环境的颜色
		 */
		private var _ambientColor:uint=0xffffff;
		/**
		 * 材质散射的颜色
		 */
		private var _diffuseColor:uint=0xffffff;

		private var _lightPicker:LightPicker;

		/**
		 * 这个放射指数描述材质发光，使用它去控制反射关的光照情形
		 */
		private var _specular:Number=1;

		/**
		 * 材质镜面反射的颜色
		 */
		private var _specularColor:uint=0xffffff;

		public function get lightPicker():LightPicker
		{
			return _lightPicker;
		}

		public function set lightPicker(value:LightPicker):void
		{
			_lightPicker=value;
		}

		override protected function getFragmentCode(_code:ShaderElementArray):ShaderElementArray
		{
			_useUV && _code.useMacro(ShaderRegisterUsage.USE_MACRO_UV);
			_useNormal && _code.useMacro(ShaderRegisterUsage.USE_MACRO_NORMAL);
			_useTangent && _code.useMacro(ShaderRegisterUsage.USE_MACRO_TANGENT);
			_diffuseTexture && _code.useMacro(ShaderRegisterUsage.USE_MACRO_DIFFUSE_MAP);
			_normalMapTexture && _code.useMacro(ShaderRegisterUsage.USE_MACRO_NORMAL_MAP);
			if (_lightPicker)
			{
				_lightPicker.numDirectionalLights > 0 && _code.useMacro(ShaderRegisterUsage.USE_MACRO_LIGHT_DIRECTION);
				_lightPicker.numPointLights > 0 && _code.useMacro(ShaderRegisterUsage.USE_MACRO_LIGHT_POINT);
			}
			_code.additional(ShaderCompiler.FRAGMENTS_PROGRAM);
			return _code;
		}

		override protected function getVertexCode(_code:ShaderElementArray):ShaderElementArray
		{
			_useUV && _code.useMacro(ShaderRegisterUsage.USE_MACRO_UV);
			_useNormal && _code.useMacro(ShaderRegisterUsage.USE_MACRO_NORMAL);
			_useTangent && _code.useMacro(ShaderRegisterUsage.USE_MACRO_TANGENT);
			if (_lightPicker)
			{
				_lightPicker.numDirectionalLights > 0 && _code.useMacro(ShaderRegisterUsage.USE_MACRO_LIGHT_DIRECTION);
				_lightPicker.numPointLights > 0 && _code.useMacro(ShaderRegisterUsage.USE_MACRO_LIGHT_POINT);
			}
			_code.additional(ShaderCompiler.VERTEX_PROGRAM);
			return _code;
		}

		specter3d override  function render(_context3d:WebGLContext, renderable:DrawUnit, camera:Camera3D):void
		{
			super.render(_context3d, renderable, camera);
			if (_lightPicker && _lightPicker.numLight > 0)
			{
				var u_diffuseColor:*, u_direction:*, u_ambientColor:*, u_specularColor:*, u_specularShininess:*, u_position:*,u_range:*,u_attenuation:*;
				for (var i:int=0; i < _lightPicker.numDirectionalLights; i++)
				{
					u_direction=_context3d.getUniformLocation(this._program, "u_DirectionLight.direction");
					u_diffuseColor=_context3d.getUniformLocation(this._program, "u_DirectionLight.diffuseColor");
					u_ambientColor=_context3d.getUniformLocation(_program, "u_DirectionLight.ambientColor");
					u_specularColor=_context3d.getUniformLocation(_program, "u_DirectionLight.specularColor");
					u_specularShininess=_context3d.getUniformLocation(_program, "u_DirectionLight.specularShininess");

					var _dlight:DirectionLight=_lightPicker.directionalLights[i];
					_context3d.uniform3fv(u_direction, _dlight.direction.elementsForVec3);
					_context3d.uniform3fv(u_diffuseColor, _dlight._diffuseRGB.elementsForVec3);
					_context3d.uniform3fv(u_ambientColor, _dlight._ambientRGB.elementsForVec3);
					_context3d.uniform3fv(u_specularColor, _dlight._specularRGBS.elementsForVec3);
					_context3d.uniform1f(u_specularShininess, _dlight.specularShininess);
				}
				var numPointLight:* = _context3d.getUniformLocation(this._program, "numPointLight");
				_context3d.uniform1i(numPointLight, _lightPicker.numPointLights);
				for (var j:int=0; j < _lightPicker.numPointLights; j++)
				{
					u_position=_context3d.getUniformLocation(this._program, "u_PointLight["+j+"].position");
					u_diffuseColor=_context3d.getUniformLocation(this._program, "u_PointLight["+j+"].diffuseColor");
					u_ambientColor=_context3d.getUniformLocation(_program, "u_PointLight["+j+"].ambientColor");
					u_specularColor=_context3d.getUniformLocation(_program, "u_PointLight["+j+"].specularColor");
					u_specularShininess=_context3d.getUniformLocation(_program, "u_PointLight["+j+"].specularShininess");
					u_range = _context3d.getUniformLocation(_program, "u_PointLight["+j+"].range");
					u_attenuation = _context3d.getUniformLocation(_program, "u_PointLight["+j+"].attenuation");
					
					var _plight:PointLight=_lightPicker.pointLights[j];
					var _position:Vector3D=_plight.transform.getPosition(false);
					_context3d.uniform3fv(u_position, _position.elementsForVec3);
					_context3d.uniform3fv(u_diffuseColor, _plight._diffuseRGB.elementsForVec3);
					_context3d.uniform3fv(u_ambientColor, _plight._ambientRGB.elementsForVec3);
					_context3d.uniform3fv(u_specularColor, _plight._specularRGBS.elementsForVec3);
					_context3d.uniform1f(u_specularShininess, _plight.specularShininess);
					_context3d.uniform1f(u_range, _plight.range);
					_context3d.uniform3fv(u_attenuation, _plight.attenuation.elementsForVec3);
				}
			}
		}
	}
}
