package specter3d.engine.bounds
{
	import flash.geom.Vector3D;
	
	import specter3d.engine.core.geom.Vector3D;

	public class BoundSphere extends Bound
	{
		private var _radius:Number = 0;
		
		public function BoundSphere()
		{
			super();
		}
		
		public function get radius():Number
		{
			return _radius;
		}

		public function set radius(value:Number):void
		{
			_radius = value;
		}

		override public function setSize(minX:Number, minY:Number, minZ:Number, maxX:Number, maxY:Number, maxZ:Number):void
		{
			super.setSize(minX, minY, minZ, maxX, maxY, maxZ);
			
			var vec:Vector3D = Vector3D.HELP;
			vec.copyFrom(_center);
			_radius = vec.subtract(max).length;
		}
		
		override public function rayIntersection(position:Vector3D, direction:Vector3D, targetNormal:Vector3D):Number
		{
			if (containsPoint(position))
				return 0;
			
			var px:Number = position.x - _center.x, py:Number = position.y - _center.y, pz:Number = position.z - _center.z;
			var vx:Number = direction.x, vy:Number = direction.y, vz:Number = direction.z;
			var rayEntryDistance:Number;
			
			var a:Number = vx*vx + vy*vy + vz*vz;
			var b:Number = 2*( px*vx + py*vy + pz*vz );
			var c:Number = px*px + py*py + pz*pz - _radius*_radius;
			var det:Number = b*b - 4*a*c;
			
			if (det >= 0) { // ray goes through sphere
				var sqrtDet:Number = Math.sqrt(det);
				rayEntryDistance = ( -b - sqrtDet )/( 2*a );
				if (rayEntryDistance >= 0) {
					targetNormal.x = px + rayEntryDistance*vx;
					targetNormal.y = py + rayEntryDistance*vy;
					targetNormal.z = pz + rayEntryDistance*vz;
					targetNormal.normalize();
					
					return rayEntryDistance;
				}
			}
			
			// ray misses sphere
			return -1;
		}
		
		override public function containsPoint(position:Vector3D):Boolean
		{
			var px:Number = position.x - _center.x;
			var py:Number = position.y - _center.y;
			var pz:Number = position.z - _center.z;
			var distance2:Number = px*px + py*py + pz*pz;
			var radius2:Number = _radius * _radius;
			return distance2 <= radius2;
		}
		
		override public function clone():Bound
		{
			var clone:BoundSphere = new BoundSphere();
			clone.fromSphere(_center, _radius);
			return clone;
		}
	}
}