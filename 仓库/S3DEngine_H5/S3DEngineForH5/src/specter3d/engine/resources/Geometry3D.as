package specter3d.engine.resources
{
	import specter3d.engine.specter3d;

	use namespace specter3d;
	
	public class Geometry3D
	{

		public function Geometry3D()
		{
			_subGeometries=new Vector.<SubGeometry3D>();
		}
		
		specter3d var _subGeometries:Vector.<SubGeometry3D>=null;

		public function addSubGeometry(subGeometry:SubGeometry3D):void
		{
			if (!subGeometry)
				return;
			_subGeometries.push(subGeometry);
			subGeometry.parentGeometry=this;
		}

		public function clone():Geometry3D
		{
			var clone:Geometry3D=new Geometry3D();
			var len:uint=_subGeometries.length;
			for (var i:int=0; i < len; ++i)
			{
				clone.addSubGeometry(_subGeometries[i].clone());
			}
			return clone;
		}

		public function removeSubGeometry(subGeometry:SubGeometry3D):void
		{
			_subGeometries.splice(_subGeometries.indexOf(subGeometry), 1);
			subGeometry.parentGeometry=null;
		}

		public function get subGeometry():Vector.<SubGeometry3D>
		{
			return _subGeometries;
		}
	}
}
