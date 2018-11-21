package specter3d.engine.core
{
	import laya.events.EventDispatcher;
	import laya.maths.Rectangle;
	import laya.webgl.WebGLContext;
	
	import specter3d.engine.specter3d;
	import specter3d.engine.core.camera.Camera3D;
	import specter3d.engine.core.context.AppGlobalContext;
	import specter3d.engine.core.render.Renderer;
	import specter3d.engine.interfaces.IRenderUpdate;

	use namespace specter3d;
	/**
	 * 3D层
	 * @author wangcx
	 *
	 */
	public class Layer3D extends EventDispatcher implements IRenderUpdate
	{

		public function Layer3D(name:String, camera:Camera3D, scene:Scene3D)
		{
			this._name=name;
			this._scene3d=scene;
			this._camera3d=camera;
			this._viewPort=new Rectangle();
			this._renderer=new Renderer(this);
		}

		private var _camera3d:Camera3D;
		private var _globalPosDirty:Boolean;
		private var _height:Number;
		private var _name:String;

		private var _renderer:Renderer;
		private var _scene3d:Scene3D;
		private var _viewPort:Rectangle;

		private var _viewportDirty:Boolean=true;
		private var _width:Number;
		private var _x:Number=0;
		private var _y:Number=0;

		public function get camera3d():Camera3D
		{
			return _camera3d;
		}

		public function get height():Number
		{
			return _height;
		}

		public function set height(value:Number):void
		{
			if (value > 2048)
				value=2048;
			if (_height == value)
				return;
			_height=value;
			_viewPort.height=value;
			_viewportDirty=true;
		}

		public function get scene3d():Scene3D
		{
			return _scene3d;
		}

		public function updateRender(_gl:WebGLContext, time:Number, dt:Number=0):void
		{
			_renderer.clear();
			updateGlobalPos();
			updateViewSizeData();
			collectingObject();
			_renderer.render(_gl);
		}

		public function get width():Number
		{
			return _width;
		}

		public function set width(value:Number):void
		{
			if (value > 2048)
				value=2048;
			if (_width == value)
				return;
			_width=value;
			_viewPort.width=value;
			_viewportDirty=true;
		}
		
		public function update(time:Number, dt:Number=0):void
		{
			this._scene3d._rootContainer3D.update(time,dt);
		}
		
		public function get x():Number
		{
			return _x;
		}

		public function set x(value:Number):void
		{
			if (x == value)
				return;
			_x=value;
			_globalPosDirty=true;
		}

		public function get y():Number
		{
			return _y;
		}

		public function set y(value:Number):void
		{
			if (y == value)
				return;
			_y=value;
			_globalPosDirty=true;
		}

		protected function updateGlobalPos():void
		{
			if (_globalPosDirty)
			{
				_globalPosDirty=false;
				_viewPort.x=_x;
				_viewPort.y=_y;
				_viewportDirty=true;
			}
		}

		protected function updateViewSizeData():void
		{
			if (_viewportDirty)
			{
				_viewportDirty=false;
				_camera3d.setViewPort(_viewPort.x, _viewPort.y, _viewPort.width, _viewPort.height);
			}
		}

		/**
		 * 对象收集
		 *
		 */
		private function collectingObject():void
		{
			//检查层次结构的对象是否可见
			if (this._scene3d && this._scene3d._rootContainer3D.visible)
			{
				this._scene3d._rootContainer3D.collectRender(this._camera3d, AppGlobalContext.stage3d.webglContext, _renderer._renderUnits);
			}
		}
	}
}
