package specter3d.engine.core.camera
{
	public class OrthographicOffCenterCamera3D extends Camera3D
	{
		private var _minX:Number;
		private var _maxX:Number;
		private var _minY:Number;
		private var _maxY:Number;
		
		public function OrthographicOffCenterCamera3D(minX:Number, maxX:Number, minY:Number, maxY:Number, aspect:Number=1, near:Number=0.1, far:Number=2000)
		{
			_minX = minX;
			_maxX = maxX;
			_minY = minY;
			_maxY = maxY;
			super(aspect, near, far);
		}
		
		public function get minX():Number
		{
			return _minX;
		}
		
		public function set minX(value:Number):void
		{
			if (_minX == value)
				return;
			_minX = value;
			_dirty = true;
		}
		
		public function get maxX():Number
		{
			return _maxX;
		}
		
		public function set maxX(value:Number):void
		{
			if (_maxX == value)
				return;
			_maxX = value;
			_dirty = true;
		}
		
		public function get minY():Number
		{
			return _minY;
		}
		
		public function set minY(value:Number):void
		{
			if (_minY == value)
				return;
			_minY = value;
			_dirty = true;
		}
		
		public function get maxY():Number
		{
			return _maxY;
		}

		public function set maxY(value:Number):void
		{
			if (_maxY == value)
				return;
			_maxY = value;
			_dirty = true;
		}

		override public function updateProjectionMatrix():void
		{
			var m:Float32Array = _projectMatrix.rawData;
			
			var bottom:Number = _maxY;
			var top:Number = _minY;
			var right:Number = _maxX;
			var left:Number = _minX; 
			
			m[0] = 2 / (right - left);
			m[1] = 0;
			m[2] = 0;
			m[3] = 0;
			
			m[4] = 0;
			m[5] = 2 / (bottom - top);
			m[6] = 0;
			m[7] = 0;
			
			m[8] = 0;
			m[9] = 0;
			m[10] = 1 / (far - near);
			m[11] = 1;
			
			m[12] = -(left + right) / (right - left);
			m[13] = -(top + bottom) / (bottom - top);
			m[14] = -near / (far - near);
			m[15] = 0;
			
			_projectMatrix.copyRawDataFrom(m);
		}
	}
}

