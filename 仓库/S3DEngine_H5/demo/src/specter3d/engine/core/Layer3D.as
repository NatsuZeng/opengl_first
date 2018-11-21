package specter3d.engine.core
{
	import laya.events.EventDispatcher;
	
	import specter3d.engine.core.camera.Camera3D;

	/**
	 * 3D层 
	 * @author 回眸笑苍生
	 * 
	 */	
	public class Layer3D extends EventDispatcher
	{
		public var name:String;
		
		private var _camera3d:Camera3D;
		private var _scene3d:Scene3D;
		private var _visible:Boolean;
		private var _width:int = 400;
		private var _height:int = 400;
		
		public function Layer3D(name:String, camera:Camera3D=null, scene:Scene3D=null)
		{
			this.name=name;
			_scene3d=scene || new Scene3D();
			_camera3d=camera || new Camera3D();
		}
		
		public function get height():int
		{
			return _height;
		}

		public function set height(value:int):void
		{
			_height = value;
		}

		public function get width():int
		{
			return _width;
		}

		public function set width(value:int):void
		{
			_width = value;
		}

		public function get visible():Boolean
		{
			return _visible;
		}

		public function set visible(value:Boolean):void
		{
			_visible = value;
		}

	}
}