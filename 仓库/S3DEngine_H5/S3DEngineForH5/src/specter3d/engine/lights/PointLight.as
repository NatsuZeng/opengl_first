package specter3d.engine.lights
{
	import specter3d.engine.core.geom.Vector3D;
	/**
	 * 点光源
	 * @author wangcx
	 *
	 */
	public class PointLight extends LightBase
	{

		public function PointLight()
		{
			super(LightType.POINT_LIGHT);
		}
		
		private var _attenuation:Vector3D=new Vector3D(0.5, 0.5, 0.5);
		private var _range:Number=6.0;

		/**
		 * 衰减
		 */
		public function get attenuation():Vector3D
		{
			return _attenuation;
		}

		/**
		 * @private
		 */
		public function set attenuation(value:Vector3D):void
		{
			_attenuation=value;
		}

		/**
		 * 范围半径
		 */
		public function get range():Number
		{
			return _range;
		}

		/**
		 * @private
		 */
		public function set range(value:Number):void
		{
			_range= value < 1 ? 1 : value;
		}
	}
}
