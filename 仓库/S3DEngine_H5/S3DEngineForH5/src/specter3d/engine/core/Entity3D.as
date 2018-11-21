package specter3d.engine.core
{
	import specter3d.engine.specter3d;
	import specter3d.engine.bounds.Bound;
	import specter3d.engine.core.picker.PickerType;
	import specter3d.engine.core.picker.PickerVO;

	use namespace specter3d;
	
	public class Entity3D extends Object3D
	{
		public function Entity3D()
		{
			super();
		}

		protected var _bound:Bound;
		protected var _boundDirty:Boolean = true;
		protected var _pickType:int = PickerType.BOUND;
		protected var _pickEnabled:Boolean = false;
		protected var _pickVO:PickerVO;
		
		public function get pickVO():PickerVO
		{
			if (!_pickVO)
				_pickVO = new PickerVO(this);
			return _pickVO;
		}

		public function set pickVO(value:PickerVO):void
		{
			_pickVO = value;
		}

		public function get pickType():int
		{
			return _pickType;
		}

		public function set pickType(value:int):void
		{
			_pickType = value;
		}

		public function get pickEnabled():Boolean
		{
			return _pickEnabled;
		}

		public function set pickEnabled(value:Boolean):void
		{
			_pickEnabled = value;
		}

		public function get bound():Bound
		{
			if (_boundDirty)
				updateBounds();
			return _bound;
		}
		
		public function set bound(value:Bound):void
		{
			if (_bound != value)
				_bound = value;
		}
		
		public function updateBounds():void
		{
			_boundDirty = false;
		}
	}
}
