package specter3d.engine.core.camera.lens
{
	import laya.d3.math.Matrix4x4;
	import laya.events.EventDispatcher;
	import laya.maths.Rectangle;
	/**
	 * 镜头
	 * @author 回眸笑苍生
	 *
	 */
	public class Lens3D extends EventDispatcher
	{

		public function Lens3D()
		{
			super();
			this._viewPort=new Rectangle();
			this._projection=new Matrix4x4();
			this._invProjection=new Matrix4x4();
			this._near=0.1;
			this._far=3000;
			this._projDirty=true;
			this._invProjDirty=true;
		}

		protected var _far:Number; // 远裁面
		protected var _invProjDirty:Boolean; // 投影逆矩阵需要更新
		protected var _invProjection:Matrix4x4; // 投影逆矩阵
		protected var _near:Number; // 近裁面
		protected var _projDirty:Boolean; // 投影矩阵需要更新

		protected var _projection:Matrix4x4; // 投影矩阵
		protected var _viewPort:Rectangle; // 相机视口
		protected var _zoom:Number; // 焦距

		public function clone():Lens3D
		{
			var c:Lens3D=new Lens3D();
			c.copyfrom(this);
			return c;
		}

		public function copyfrom(lens:Lens3D):void
		{
			this._projection.copyFrom(lens._projection);
			this._viewPort.copyFrom(lens._viewPort);
			this._near=lens._near;
			this._far=lens._far;
			this._projDirty=lens._projDirty;
			this._invProjDirty=lens._invProjDirty;
			this._invProjection.copyFrom(lens._invProjection);
			this._zoom=lens.zoom;
		}

		/**
		 * 远裁面
		 * @return
		 *
		 */
		public function get far():Number
		{
			return _far;
		}

		/**
		 * 远裁面
		 * @return
		 *
		 */
		public function set far(value:Number):void
		{
			if (_far == value)
			{
				return;
			}
			_far=value;
			invalidateProjection();
		}

		/**
		 * 逆投影矩阵
		 * @return
		 *
		 */
		public function get invProjection():Matrix4x4
		{
			if (_invProjDirty)
			{
				_invProjection.copyFrom(projection);
				_invProjection.invert();
				_invProjDirty=false;
			}
			return _invProjection;
		}

		/**
		 * 近裁面
		 * @return
		 *
		 */
		public function get near():Number
		{
			return _near;
		}

		/**
		 * 近裁面
		 * @return
		 *
		 */
		public function set near(value:Number):void
		{
			if (_near == value)
			{
				return;
			}
			_near=value;
			invalidateProjection();
		}

		/**
		 * 投影矩阵
		 * @return
		 *
		 */
		public function get projection():Matrix4x4
		{
			if (_projDirty)
			{
				updateProjectionMatrix();
			}
			return _projection;
		}

		/**
		 * 视口
		 * @return
		 *
		 */
		public function setViewPort(x:int, y:int, width:int, height:int):void
		{
			if (_viewPort.x == x && _viewPort.y == y && _viewPort.width == width && _viewPort.height == height)
			{
				return;
			}
			_viewPort.setTo(x, y, width, height);
			invalidateProjection();
		}

		/**
		 * 更新投影矩阵
		 */
		public function updateProjectionMatrix():void
		{
			this._projDirty=false;
			this._invProjDirty=true;
		}

		/**
		 * 视口
		 * @return
		 *
		 */
		public function get viewPort():Rectangle
		{
			return _viewPort;
		}

		/**
		 * 焦距
		 * @return
		 *
		 */
		public function get zoom():Number
		{
			return _zoom;
		}

		/**
		 * 焦距
		 * @return
		 *
		 */
		public function set zoom(value:Number):void
		{
			if (value == _zoom)
			{
				return;
			}
			_zoom=value;
			invalidateProjection();
		}

		protected function invalidateProjection():void
		{
			this._projDirty=true;
			this._invProjDirty=true;
		}
	}
}
