package specter3d.engine.core.camera
{
	public class PerspectiveCamera3D extends Camera3D
	{
		protected var _fov:Number = 45;
		
		public function PerspectiveCamera3D(fov:Number=45, aspect:Number=1, near:Number=0.1, far:Number=2000)
		{
			_fov = fov;
			super(aspect, near, far);
		}
		
		public function get fov():Number
		{
			return _fov;
		}
		
		public function set fov(value:Number):void
		{
			_fov = value;
			_dirty = true;
		}
		
		override public function updateProjectionMatrix():void
		{
			var m:Float32Array = _projectMatrix.rawData;
			
			var angle: Number = fov * (Math.PI / 180.0);
			var yScale: Number = Math.tan((Math.PI  - angle) / 2.0);
			var xScale: Number = yScale / aspect;
			
			m[0] = xScale;
			m[1] = 0;
			m[2] = 0;
			m[3] = 0;
			
			m[4] = 0;
			m[5] = yScale;
			m[6] = 0;
			m[7] = 0;
			
			m[8] = 0;
			m[9] = 0;
			m[10] = far / (far - near);
			m[11] = 1;
			
			m[12] = 0;
			m[13] = 0;
			m[14] = -near * far / (far - near);
			m[15] = 0;
			
			_projectMatrix.copyRawDataFrom(m);
		}
	}
}