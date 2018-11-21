package specter3d.engine.math
{
	import specter3d.engine.core.geom.Vector3D;

	public class Ray
	{
		public var origin:Vector3D;
		public var direction:Vector3D;
		
		public function Ray(origin:Vector3D=null, direction:Vector3D=null)
		{
			this.origin = origin || new Vector3D;
			this.direction = direction || new Vector3D;
		}
	}
}