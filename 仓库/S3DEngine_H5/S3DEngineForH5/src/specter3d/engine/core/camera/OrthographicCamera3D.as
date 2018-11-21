package specter3d.engine.core.camera
{
	public class OrthographicCamera3D extends Camera3D
	{
		private var _projectHeight:Number;
		
		public function OrthographicCamera3D(projectHeight:Number=500, aspect:Number=1, near:Number=0.1, far:Number=2000)
		{
			_projectHeight = projectHeight;
			super(aspect, near, far);
		}
		
		public function get projectHeight():Number
		{
			return _projectHeight;
		}
		
		public function set projectHeight(value:Number):void
		{
			if (_projectHeight == value)
				return;
			_projectHeight = value;
			_dirty = true;
		}
		
		override public function updateProjectionMatrix():void
		{
			var m:Float32Array = _projectMatrix.rawData;
			
			var bottom:Number = _projectHeight * 0.5;
			var top:Number = - bottom;
			var right:Number = bottom * _aspect;
			var left:Number = - right; 
			
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
			
			m[12] = 0;
			m[13] = 0;
			m[14] = -near / (far - near);
			m[15] = 0;
			
			_projectMatrix.copyRawDataFrom(m);
		}
	}
}