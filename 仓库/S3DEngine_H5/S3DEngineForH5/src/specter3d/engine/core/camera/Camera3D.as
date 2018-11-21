package specter3d.engine.core.camera
{
	import specter3d.engine.core.Object3D;
	import specter3d.engine.core.context.AppGlobalContext;
	import specter3d.engine.core.geom.Matrix3D;
	import specter3d.engine.core.geom.Vector3D;
	import specter3d.engine.math.Ray;

	public class Camera3D extends Object3D
	{
		public var orthographic:Boolean = false;
		
		protected var _aspect:Number = 1.0;
		protected var _near:Number;
		protected var _far:Number;
		
		protected var _viewProjection:Matrix3D = new Matrix3D();
		protected var _projectMatrix:Matrix3D = new Matrix3D();
		protected var _unprojectMatrix:Matrix3D = new Matrix3D();
		protected var _dirty:Boolean = false;
		
		public function Camera3D(aspect:Number=1, near:Number=0.1, far:Number=2000)
		{
			super();
			_aspect = aspect;
			_near = near;
			_far = far;
			this.transform.setPosition(0, 0, -1000);
			_dirty = true;
		}

		public function get aspect():Number
		{
			return _aspect;
		}

		public function set aspect(value:Number):void
		{
			_aspect = value;
			_dirty = true;
		}

		public function get near():Number
		{
			return _near;
		}

		public function set near(value:Number):void
		{
			_near = value;
			_dirty = true;
		}

		public function get far():Number
		{
			return _far;
		}

		public function set far(value:Number):void
		{
			_far = value;
			_dirty = true;
		}

		/**
		 * 相机空间矩阵（相机世界位置的逆矩阵）
		 * @return 
		 * 
		 */	
		private var _viewMatrix:Matrix3D = new Matrix3D();
		public function get viewMatrix():Matrix3D
		{
			_viewMatrix.copyFrom(this.transform.world);
			_viewMatrix.invert();
			return _viewMatrix;
		}
		
		/**
		 * 模型变换矩阵 
		 * @return 
		 * 
		 */		
		public function get modelViewMatrix():Matrix3D
		{
			_viewProjection.copyFrom(this.transform.world);
			_viewProjection.invert();
			_viewProjection.append(projectMatrix);
			return _viewProjection;
		}
		
		/**
		 * 透视矩阵
		 * @return 
		 * 
		 */		
		public function get projectMatrix():Matrix3D
		{
			if (_dirty)
			{
				_dirty = false;
				updateProjectionMatrix();
			}
			return _projectMatrix;
		}
		
		public function get unprojectMatrix():Matrix3D
		{
			_unprojectMatrix.copyFrom(projectMatrix);
			_unprojectMatrix.invert();
			return _unprojectMatrix;
		}
		
		public function updateProjectionMatrix():void
		{
			// 重载
		}
		
		public function setViewPort(x:Number, y:Number, width:Number, height:Number):void
		{
			_aspect = width / height;
			_dirty = true;
		}
		
		private function project(point3d:Vector3D, v:Vector3D=null):Vector3D
		{
			if (!v)
				v = new Vector3D();
			
			projectMatrix.transformVector(point3d, v);
			
			v.x = v.x / v.w;
			v.y = -v.y / v.w;
			v.z = v.z;
			
			return v;
		}
		
		private function unproject(nX:Number, nY:Number, sZ:Number, v:Vector3D = null):Vector3D
		{
			if (!v)
				v = new Vector3D();
			
			v.x = nX;
			v.y = -nY;
			v.z = sZ;
			v.w = 1;
			
			v.x *= sZ;
			v.y *= sZ;
			
			unprojectMatrix.transformVector(v, v);
			
			v.z = sZ;
			
			return v;
		}
		
		public function screen2DToScene3D(sX:Number, sY:Number, sZ:Number, v:Vector3D):Vector3D
		{
			if (!v)
				v = new Vector3D();
			
			var nX:Number = (sX*2 - AppGlobalContext.stageWidth)/ AppGlobalContext.stageWidth;
			var nY:Number = (sY*2 - AppGlobalContext.stageHeight)/ AppGlobalContext.stageHeight;
			unproject(nX, nY, sZ, v);
			transform.world.transformVector(v, v);
			
			return v;
		}
		
		public function scene3DToScreen2D(point3d:Vector3D, v:Vector3D):Vector3D
		{
			if (!v)
				v = new Vector3D();
			
			viewMatrix.transformVector(point3d, v);
			project(v, v);
			
			v.x = (v.x + 1.0) * AppGlobalContext.stageWidth / 2.0;
			v.y = (v.y + 1.0) * AppGlobalContext.stageHeight / 2.0;
			
			return v;
		}
		
		public function screenPositionToRay(nX:Number, nY:Number, sZ:Number, v:Vector3D = null):Ray
		{
			var ray:Ray = new Ray();
			ray.origin = transform.getPosition(false, ray.origin);
			var target:Vector3D = unproject(nX, nY, sZ);
			ray.direction = target.subtract(ray.origin);
			return ray;
		}
	}
}