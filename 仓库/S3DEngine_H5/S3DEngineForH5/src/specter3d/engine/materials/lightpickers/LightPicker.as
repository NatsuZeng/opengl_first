package specter3d.engine.materials.lightpickers
{
	import laya.events.Event;
	import laya.events.EventDispatcher;
	
	import specter3d.engine.lights.DirectionLight;
	import specter3d.engine.lights.LightBase;
	import specter3d.engine.lights.LightType;
	import specter3d.engine.lights.PointLight;
	/**
	 * LightPicker
	 * @author wangcx
	 *
	 */
	public class LightPicker extends EventDispatcher
	{
		/**
		 * Create LightPicker
		 * @param _lights
		 * 
		 */
		public function LightPicker(_lights:Vector.<LightBase>)
		{
			_directionalLights = new Vector.<DirectionLight>();
			_pointLights = new Vector.<PointLight>();
			_allPickedLights = new Vector.<LightBase>();
			this.lights=_lights;
		}
		private var _allPickedLights:Vector.<LightBase>;
		private var _directionalLights:Vector.<DirectionLight>;
		private var _numDirectionalLights:uint;
		private var _numLight:uint;
		private var _numPointLights:uint;
		private var _pointLights:Vector.<PointLight>;

		public function get pointLights():Vector.<PointLight>
		{
			return _pointLights;
		}

		public function get directionalLights():Vector.<DirectionLight>
		{
			return _directionalLights;
		}

		public function get lights():Vector.<LightBase>
		{
			return _allPickedLights;
		}

		public function set lights(value:Vector.<LightBase>):void
		{
			var _light:LightBase;
			var len:int=value.length;
			for (var i:int=0; i < value.length; i++)
			{
				_light=value[i];
				switch (_light.lightType)
				{
					case LightType.DIRECTION_LIGHT:
						_directionalLights[_numDirectionalLights++]=_light;
						_allPickedLights[_numLight++]=_light;
						break;
					case LightType.POINT_LIGHT:
						_pointLights[_numPointLights++]=_light;
						_allPickedLights[_numLight++]=_light;
						break;
				}
			}
			event(Event.CHANGE);
		}


		public function get numDirectionalLights():uint
		{
			return _numDirectionalLights;
		}

		public function get numLight():uint
		{
			return _numLight;
		}

		public function get numPointLights():uint
		{
			return _numPointLights;
		}
	}
}
