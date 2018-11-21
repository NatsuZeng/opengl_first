package specter3d.engine.bounds
{
	import specter3d.engine.core.geom.Vector3D;

	public class BoundBox extends Bound
	{
		private var _half:Vector3D;
		
		public function BoundBox()
		{
			super();
			_half = new Vector3D();
		}
		
		override public function setSize(minX:Number, minY:Number, minZ:Number, maxX:Number, maxY:Number, maxZ:Number):void
		{
			super.setSize(minX, minY, minZ, maxX, maxY, maxZ);
			_half.x = (_max.x - _min.x) * 0.5;
			_half.y = (_max.y - _min.y) * 0.5;
			_half.z = (_max.z - _min.z) * 0.5;
		}
		
		override public function rayIntersection(position:Vector3D, direction:Vector3D, targetNormal:Vector3D):Number
		{
			if (containsPoint(position))
				return 0;
			
			var _centerX:Number = _center.x;
			var _centerY:Number = _center.y;
			var _centerZ:Number = _center.z;
			var _halfExtentsX:Number = _half.x;
			var _halfExtentsY:Number = _half.y;
			var _halfExtentsZ:Number = _half.z;
			
			var px:Number = position.x - _centerX, py:Number = position.y - _centerY, pz:Number = position.z - _centerZ;
			var vx:Number = direction.x, vy:Number = direction.y, vz:Number = direction.z;
			var ix:Number, iy:Number, iz:Number;
			var rayEntryDistance:Number;
			
			// ray-plane tests
			var intersects:Boolean;
			if (vx < 0) {
				rayEntryDistance = ( _halfExtentsX - px )/vx;
				if (rayEntryDistance > 0) {
					iy = py + rayEntryDistance*vy;
					iz = pz + rayEntryDistance*vz;
					if (iy > -_halfExtentsY && iy < _halfExtentsY && iz > -_halfExtentsZ && iz < _halfExtentsZ) {
						targetNormal.x = 1;
						targetNormal.y = 0;
						targetNormal.z = 0;
						
						intersects = true;
					}
				}
			}
			if (!intersects && vx > 0) {
				rayEntryDistance = ( -_halfExtentsX - px )/vx;
				if (rayEntryDistance > 0) {
					iy = py + rayEntryDistance*vy;
					iz = pz + rayEntryDistance*vz;
					if (iy > -_halfExtentsY && iy < _halfExtentsY && iz > -_halfExtentsZ && iz < _halfExtentsZ) {
						targetNormal.x = -1;
						targetNormal.y = 0;
						targetNormal.z = 0;
						intersects = true;
					}
				}
			}
			if (!intersects && vy < 0) {
				rayEntryDistance = ( _halfExtentsY - py )/vy;
				if (rayEntryDistance > 0) {
					ix = px + rayEntryDistance*vx;
					iz = pz + rayEntryDistance*vz;
					if (ix > -_halfExtentsX && ix < _halfExtentsX && iz > -_halfExtentsZ && iz < _halfExtentsZ) {
						targetNormal.x = 0;
						targetNormal.y = 1;
						targetNormal.z = 0;
						intersects = true;
					}
				}
			}
			if (!intersects && vy > 0) {
				rayEntryDistance = ( -_halfExtentsY - py )/vy;
				if (rayEntryDistance > 0) {
					ix = px + rayEntryDistance*vx;
					iz = pz + rayEntryDistance*vz;
					if (ix > -_halfExtentsX && ix < _halfExtentsX && iz > -_halfExtentsZ && iz < _halfExtentsZ) {
						targetNormal.x = 0;
						targetNormal.y = -1;
						targetNormal.z = 0;
						intersects = true;
					}
				}
			}
			if (!intersects && vz < 0) {
				rayEntryDistance = ( _halfExtentsZ - pz )/vz;
				if (rayEntryDistance > 0) {
					ix = px + rayEntryDistance*vx;
					iy = py + rayEntryDistance*vy;
					if (iy > -_halfExtentsY && iy < _halfExtentsY && ix > -_halfExtentsX && ix < _halfExtentsX) {
						targetNormal.x = 0;
						targetNormal.y = 0;
						targetNormal.z = 1;
						intersects = true;
					}
				}
			}
			if (!intersects && vz > 0) {
				rayEntryDistance = ( -_halfExtentsZ - pz )/vz;
				if (rayEntryDistance > 0) {
					ix = px + rayEntryDistance*vx;
					iy = py + rayEntryDistance*vy;
					if (iy > -_halfExtentsY && iy < _halfExtentsY && ix > -_halfExtentsX && ix < _halfExtentsX) {
						targetNormal.x = 0;
						targetNormal.y = 0;
						targetNormal.z = -1;
						intersects = true;
					}
				}
			}
			
			return intersects? rayEntryDistance : -1;
		}
		
		
		override public function containsPoint(position:Vector3D):Boolean
		{
			var px:Number = position.x - _center.x;
			var py:Number = position.y - _center.y;
			var pz:Number = position.z - _center.z;
			return px <= _half.x && px >= -_half.x &&
				py <= _half.y && py >= -_half.y &&
				pz <= _half.z && pz >= -_half.z;
		}
		
		override public function clone():Bound
		{
			var clone:BoundBox = new BoundBox();
			clone.setSize(_min.x, _min.y, _min.z, _max.x, _max.y, _max.z);
			return clone;
		}
	}
}