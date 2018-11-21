package specter3d.engine.materials.passes
{
	import laya.webgl.WebGLContext;
	
	import specter3d.engine.specter3d;
	import specter3d.engine.core.camera.Camera3D;
	import specter3d.engine.core.render.data.DrawUnit;
	import specter3d.engine.lights.DirectionLight;
	import specter3d.engine.lights.LightBase;
	import specter3d.engine.lights.LightType;
	import specter3d.engine.materials.Material3D;
	import specter3d.engine.materials.compilation.ShaderCompiler;

	use namespace specter3d;
	/**
	 * 灯光
	 * @author wangcx
	 *
	 */
	public class LightingPass extends Material3DPass
	{

		public function LightingPass(material:Material3D)
		{
			super();
			this._material = material;
		}

		specter3d var numDirectionLight:uint=0;
		specter3d var numLight:uint=0;
		specter3d var numPointLight:uint=0;
		private var _lights:Vector.<LightBase>=new Vector.<LightBase>();

		public function addLight(light:LightBase):void
		{
			var _index:int=_lights.indexOf(light);
			if (_index == -1)
			{
				switch (light.lightType)
				{
					case LightType.DIRECTION_LIGHT:
						numDirectionLight++;
						break;
					case LightType.DIRECTION_LIGHT:
						numPointLight++;
						break;
				}
				_lights[numLight]=light;
				numLight++;
			}
		}

		public function removeLight(light:LightBase):void
		{
			var _index:int=_lights.indexOf(light);
			if (_index != -1)
			{
				switch (light.lightType)
				{
					case LightType.DIRECTION_LIGHT:
						numDirectionLight--;
						break;
					case LightType.POINT_LIGHT:
						numPointLight--;
						break;
				}
				_lights.splice(_index, 1);
				numLight--;
			}
		}
		
		override protected function getFragmentCode(code:String):String
		{
			var _codes:Array =
				[
					numDirectionLight > 0	? 	ShaderCompiler.MACRO_DEFINE + "USE_DIRECTIONLIGHT" 					: "",
					numDirectionLight > 0	? 	ShaderCompiler.UNIFORM 		+ "DirectionLight u_DirectionLight;" 	: "",
					ShaderCompiler.LIGHTING_PROGRAM
				]; 
			code += _codes.filter(filterEmptyLine).join("\n");
			return code;
		}
		
		override protected function getVertexCode(code:String):String
		{
			return code;
		}
		
		specter3d override  function render(_context3d:WebGLContext, renderable:DrawUnit, camera:Camera3D):void
		{
			for (var i:int = 0; i < numLight; i++) 
			{
				var _light:LightBase = _lights[i];
				switch (_light.lightType)
				{
					case LightType.DIRECTION_LIGHT:
						var dl:DirectionLight = _light as DirectionLight;
						var u_lightColor:*=_context3d.getUniformLocation(_program, "u_DirectionLight.lightColor");
						var u_lightDirection:*=_context3d.getUniformLocation(_program, "u_DirectionLight.lightDirection");
						_context3d.uniform3f(u_lightColor,dl._colorR,dl._colorG,dl._colorB);
						dl.direction.normalize();
						_context3d.uniform3fv(u_lightColor,dl.direction.elements);
						break;
					case LightType.POINT_LIGHT:
						
						break;
				}
			}
		}
		
		
	}
}
