package specter3d.engine.objects
{
	import specter3d.engine.specter3d;
	import specter3d.engine.core.Transform3D;
	import specter3d.engine.core.render.data.DrawUnit;
	import specter3d.engine.materials.Material3D;
	import specter3d.engine.resources.SubGeometry3D;
	
	use namespace specter3d;
	
	public class Surface3D extends DrawUnit 
	{
		private var _parentMesh : Mesh3D;
		private var _index:int = -1;
		private var _subGeometry:SubGeometry3D;
		private var _material:Material3D;
		
		public function Surface3D(index:int,subGeometry:SubGeometry3D,parentMesh:Mesh3D,material:Material3D)
		{
			super(DrawUnit.SURFACE_UNIT);
			this._index = index;
			this.material = material;
			this._subGeometry = subGeometry;
			this._parentMesh = parentMesh;
		}
		
		public function get parentMesh():Mesh3D
		{
			return _parentMesh;
		}

		public function set parentMesh(value:Mesh3D):void
		{
			_parentMesh = value;
		}

		override public function get material():Material3D
		{
			return _material;
		}
		
		override public function set material(value:Material3D):void
		{
			if(_material != value)
			{
				_material = value;
			}
		}

		override public function get subGeometry():SubGeometry3D
		{
			return _subGeometry;
		}
		
		override public function get transform():Transform3D
		{
			return _parentMesh.transform;
		}
		
		public function get vertexData():Float32Array
		{
			return _subGeometry.vertexData;
		}
		
		public function get indexData():Uint16Array
		{
			return _subGeometry.indices;
		}
		
		public function get UVData():Float32Array
		{
			return _subGeometry.UVData;
		}
		
		public function get UVStride():uint
		{
			return _subGeometry.UVStride;
		}
		
		public function get vertexStride():int
		{
			return _subGeometry.vertexStride;
		}
		
		public function get vertexOffset():int
		{
			return _subGeometry.vertexOffset;
		}
		
		public function get UVOffset():int
		{
			return _subGeometry.UVOffset;
		}
	}
}