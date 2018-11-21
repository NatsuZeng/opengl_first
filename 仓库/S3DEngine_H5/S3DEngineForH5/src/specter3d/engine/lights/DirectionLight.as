package specter3d.engine.lights
{
	import specter3d.engine.specter3d;
	import specter3d.engine.core.geom.Vector3D;

	use namespace specter3d;
	/**
	 * 平行光
	 * @author wangcx
	 *
	 */
	public class DirectionLight extends LightBase
	{

		public function DirectionLight(xDir:Number=0, yDir:Number=-1, zDir:Number=1)
		{
			super(LightType.DIRECTION_LIGHT);
			direction=new Vector3D(xDir, yDir, zDir);
		}

		private var _direction:Vector3D;

		public function get direction():Vector3D
		{
			return _direction;
		}

		public function set direction(value:Vector3D):void
		{
			_direction=value;
			_direction.normalize();
		}
	}
}
