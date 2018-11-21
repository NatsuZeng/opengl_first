package specter3d.engine.objects
{
	import laya.webgl.WebGLContext;
	
	import specter3d.engine.specter3d;
	import specter3d.engine.bounds.Bound;
	import specter3d.engine.bounds.BoundBox;
	import specter3d.engine.core.Entity3D;
	import specter3d.engine.core.Object3D;
	import specter3d.engine.core.camera.Camera3D;
	import specter3d.engine.core.picker.PickerType;
	import specter3d.engine.core.render.data.DrawUnit;
	import specter3d.engine.interfaces.IAnimator;
	import specter3d.engine.materials.Material3D;
	import specter3d.engine.resources.Geometry3D;
	import specter3d.engine.resources.SubGeometry3D;

	use namespace specter3d;
	/**
	 * 网格
	 * @author wangcx
	 *
	 */
	public class Mesh3D extends Entity3D
	{

		public function Mesh3D(geos:Geometry3D, mats:Material3D=null)
		{
			super();
			this._geometry=geos;
			this._materials=mats;
			if(_geometry)
			{
				for (var i:int=0; i < _geometry.subGeometry.length; i++)
				{
					var subGeometry:SubGeometry3D=_geometry.subGeometry[i];
					addSurface(i, subGeometry,_materials);
				}
			}
			
			_bound = new BoundBox();
		}

		private var _geometry:Geometry3D;
		private var _materials:Material3D;

		private var _render:DrawUnit;
		private var _surfaces:Vector.<Surface3D>=new Vector.<Surface3D>();
		
		protected var _animator:IAnimator;

		public function get animator():IAnimator
		{
			return _animator;
		}

		public function set animator(value:IAnimator):void
		{
			_animator = value;
		}

		override public function updateBounds():void
		{
			_bound.fromGeometry(_geometry);
			_boundDirty = false;
		}
		
		public function get geometry():Geometry3D
		{
			return _geometry;
		}

		public function set geometry(value:Geometry3D):void
		{
			if (_geometry != value)
			{
				_geometry=value;
				_boundDirty = true;
			}
		}

		public function get materials():Material3D
		{
			return _materials;
		}

		public function set materials(value:Material3D):void
		{
			_materials=value;
		}

		protected function addSurface(index:int, subGeometry:SubGeometry3D, material:Material3D=null):Surface3D
		{
			var surface3d:Surface3D=new Surface3D(index, subGeometry, this, material);
			_surfaces.push(surface3d);
			return surface3d;
		}

		specter3d override function collectRender(camera:Camera3D, _context3d:WebGLContext, _renderUnits:Vector.<DrawUnit>):void
		{
			if (visible && _surfaces.length > 0)
			{
				for (var i:int=0; i < _surfaces.length; i++)
				{
					_renderUnits.push(_surfaces[i]);
				}
			}
			super.collectRender(camera, _context3d, _renderUnits);
			
		}

		specter3d function get surfaces():Vector.<Surface3D>
		{
			return _surfaces;
		}
		
		public function getSurfaceIndex(surface3D:Surface3D):uint
		{
			var index:uint = 0;
			
			for (var i:uint = 0; i < _surfaces.length; ++i) {
				if (_surfaces[i] == surface3D) {
					index = i;
					break;
				}
			}
			
			return index;
		}
	}
}
