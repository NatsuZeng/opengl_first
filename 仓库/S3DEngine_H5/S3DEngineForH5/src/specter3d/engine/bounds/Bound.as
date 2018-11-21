package specter3d.engine.bounds
{
	import specter3d.engine.core.geom.Vector3D;
	import specter3d.engine.errors.AbstractMethodError;
	import specter3d.engine.resources.Geometry3D;
	import specter3d.engine.resources.SubGeometry3D;

	public class Bound
	{
		protected var _min:Vector3D;
		protected var _max:Vector3D;
		protected var _center:Vector3D;
		
		public function Bound()
		{
			_min = new Vector3D();
			_max = new Vector3D();
			_center = new Vector3D();
		}
		
		public function get min():Vector3D
		{
			return _min;
		}

		public function get max():Vector3D
		{
			return _max;
		}

		public function get center():Vector3D
		{
			return _center;
		}
		
		public function fromVertices(vertices:Float32Array):void
		{
			fromArray(vertices);
		}
		
		public function fromArray(vertices:Array):void
		{
			var i:uint;
			var len:uint = vertices.length;
			var minX:Number, minY:Number, minZ:Number;
			var maxX:Number, maxY:Number, maxZ:Number;
			
			if (len == 0) {
				setSize(0, 0, 0, 0, 0, 0);
				return;
			}
			
			var v:Number;
			
			minX = maxX = vertices[uint(i++)];
			minY = maxY = vertices[uint(i++)];
			minZ = maxZ = vertices[uint(i++)];
			
			while (i < len) {
				v = vertices[i++];
				if (v < minX)
					minX = v;
				else if (v > maxX)
					maxX = v;
				v = vertices[i++];
				if (v < minY)
					minY = v;
				else if (v > maxY)
					maxY = v;
				v = vertices[i++];
				if (v < minZ)
					minZ = v;
				else if (v > maxZ)
					maxZ = v;
			}
			
			setSize(minX, minY, minZ, maxX, maxY, maxZ);	
		}
		
		public function fromGeometry(geometry:Geometry3D):void
		{
			var subGeoms:Vector.<SubGeometry3D> = geometry.subGeometry;
			var numSubGeoms:uint = subGeoms.length;
			var minX:Number, minY:Number, minZ:Number;
			var maxX:Number, maxY:Number, maxZ:Number;
			
			if (numSubGeoms > 0) {
				var subGeom:SubGeometry3D = subGeoms[0];
				var vertices:Float32Array = subGeom.vertexData;
				var i:uint = 0;
				minX = maxX = vertices[i];
				minY = maxY = vertices[i + 1];
				minZ = maxZ = vertices[i + 2];
				
				var j:uint = 0;
				while (j < numSubGeoms) {
					subGeom = subGeoms[j++];
					vertices = subGeom.vertexData;
					var vertexDataLen:uint = vertices.length;
					i = 0;
					var stride:uint = subGeom.vertexStride;
					
					while (i < vertexDataLen) {
						var v:Number = vertices[i];
						if (v < minX)
							minX = v;
						else if (v > maxX)
							maxX = v;
						v = vertices[i + 1];
						if (v < minY)
							minY = v;
						else if (v > maxY)
							maxY = v;
						v = vertices[i + 2];
						if (v < minZ)
							minZ = v;
						else if (v > maxZ)
							maxZ = v;
						i += stride;
					}
				}
				
				setSize(minX, minY, minZ, maxX, maxY, maxZ);
			} else
				setSize(0, 0, 0, 0, 0, 0);
		}
		
		public function fromSphere(center:Vector3D, radius:Number):void
		{
			setSize(center.x - radius, center.y - radius, center.z - radius, center.x + radius, center.y + radius, center.z + radius);	
		}
		
		public function setSize(minX:Number, minY:Number, minZ:Number, maxX:Number, maxY:Number, maxZ:Number):void
		{
			_min.x = minX;
			_min.y = minY;
			_min.z = minZ;
			_max.x = maxX;
			_max.y = maxY;
			_max.z = maxZ;
			_center.x = (_max.x + _min.x) / 2;
			_center.y = (_max.y + _min.y) / 2;
			_center.z = (_max.z + _min.z) / 2;
		}
		
		public function rayIntersection(position:Vector3D, direction:Vector3D, targetNormal:Vector3D):Number
		{
			return -1;
		}
		
		public function containsPoint(point:Vector3D):Boolean
		{
			throw new AbstractMethodError();
		}
		
		public function clone():Bound
		{
			throw new AbstractMethodError();
		}
	}
}