package specter3d.engine.core
{
	import laya.events.EventDispatcher;
	import laya.utils.Browser;
	import laya.webgl.WebGL;
	import laya.webgl.WebGLContext;
	
	import specter3d.engine.specter3d;
	import specter3d.engine.core.camera.Camera3D;
	import specter3d.engine.core.camera.PerspectiveCamera3D;
	import specter3d.engine.core.context.AppGlobalContext;
	import specter3d.engine.events.EngineContextEvent;
	import specter3d.engine.interfaces.IRenderUpdate;
	import specter3d.engine.managers.Mouse3DManager;
	import specter3d.engine.utlis.HashMap;

	use namespace specter3d;
	/**
	 * Stage3D 类是specter3d显示对象的根节点。
	 * @author wangcx
	 *
	 */
	public class Stage3D extends EventDispatcher implements IRenderUpdate
	{

		public static const DEFAULT_LAYER3D:String="defaultLayer3D";
		private static var _layer3dHash:HashMap;
		private static var _layer3ds:Vector.<Layer3D>=new Vector.<Layer3D>();
		
		private var _canvas:*;

		public function Stage3D(antialias:Boolean=true)
		{
			this._antialias=antialias;
			if (!initWebglContext3D())
			{
				alert("S3DEngine Stage3D init err,must support webGL!");
				return;
			}
			if (!_layer3dHash)
			{
				_layer3dHash=new HashMap();
				_defaultCamera=new PerspectiveCamera3D();
				_defaultScene=new Scene3D();
				_mainLayer=createLayer3d(DEFAULT_LAYER3D);
//				_mouseManager = new Mouse3DManager();
			}
			else
			{
				throw new Error("This class is a multiton and cannot be instantiated manually.");
			}
		}

		specter3d var webglContext:WebGLContext;

		private var _antialias:Boolean=true;
		private var _backBufferHeight:int;
		private var _backBufferWidth:int;
		private var _color:uint;

		private var _defaultCamera:Camera3D;
		private var _defaultScene:Scene3D;
		private var _isEngineInit:Boolean=false;
		private var _mainLayer:Layer3D;
		private var _mouseManager:Mouse3DManager;

		public function get mouseManager():Mouse3DManager
		{
			return _mouseManager;
		}

		public function addChild(child:Object3D, layerName:String="defaultLayer3D"):Object3D
		{
			var _layer3d:Layer3D=getLayer3D(layerName);
			if (_layer3d && _layer3d.scene3d)
				_layer3d.scene3d.addChild(child);
			return child;
		}

		public function addChildAt(child:Object3D, index:int, layerName:String="defaultLayer3D"):Object3D
		{
			var _layer3d:Layer3D=getLayer3D(layerName);
			if (_layer3d && _layer3d.scene3d)
				_layer3d.scene3d.addChildAt(child, index);
			return child;
		}

		public function get backgroundColor():uint
		{
			return _color;
		}

		public function set backgroundColor(value:uint):void
		{
			_color=value;
		}

		public function clear():void
		{
			if (webglContext)
			{
				webglContext.enable(WebGLContext.DEPTH_TEST);
				webglContext.enable(WebGLContext.CULL_FACE);
				_cullFaceEnabled = true;
				webglContext.frontFace(WebGLContext.CW);
				webglContext.clearColor(((_color >> 16) & 0xff) / 255.0, ((_color >> 8) & 0xff) / 255.0, (_color & 0xff) / 255.0, ((_color >> 24) & 0xff) / 255.0);
				webglContext.clear(WebGLContext.COLOR_BUFFER_BIT | WebGLContext.DEPTH_BUFFER_BIT);
			}
		}

		public function clearDepthBuffer():void
		{
			webglContext && webglContext.clearDepth(WebGLContext.DEPTH_BUFFER_BIT);
		}
		
		/**
		 * 创建一个 Layer3d 默认情况下都是共用 一个 Camera 与  Scene 对象进行渲染，如果有多个Layer3d共用Camera 与  Scene时当前的Scene中所以对象将会被渲染多次
		 * @param name 全局唯一名称
		 * @param camera 默认为 defaultCamera
		 * @param scene 默认为 _defaultScene
		 * @return
		 *
		 */
		public function createLayer3d(name:String, camera:Camera3D=null, scene:Scene3D=null):Layer3D
		{
			var _layer:Layer3D=new Layer3D(name, camera ? camera : _defaultCamera, scene ? scene : _defaultScene);
			_layer3dHash.put(name, _layer);
			_layer3ds.push(_layer);
			_layer.x=0;
			_layer.y=0;
			return _layer;
		}

		public function getChildAt(index:int, layerName:String="defaultLayer3D"):Object3D
		{
			var child:Object3D;
			var _layer3d:Layer3D=getLayer3D(layerName);
			if (_layer3d && _layer3d.scene3d)
				child=_layer3d.scene3d.getChildAt(index);
			return child;
		}

		public function getChildByName(name:String, layerName:String="defaultLayer3D"):Object3D
		{
			var child:Object3D;
			var _layer3d:Layer3D=getLayer3D(layerName);
			if (_layer3d && _layer3d.scene3d)
				child=_layer3d.scene3d.getChildByName(name);
			return child;
		}

		public function getChildIndex(child:Object3D, layerName:String="defaultLayer3D"):int
		{
			var index:int=-1;
			var _layer3d:Layer3D=getLayer3D(layerName);
			if (_layer3d && _layer3d.scene3d)
				index=_layer3d.scene3d.getChildIndex(child);
			return index;
		}

		public function getLayer3D(layerName:String):Layer3D
		{
			return _layer3dHash.getValue(layerName) as Layer3D;
		}

		public function removeChild(child:Object3D, layerName:String="defaultLayer3D"):Object3D
		{
			var _layer3d:Layer3D=getLayer3D(layerName);
			if (_layer3d && _layer3d.scene3d)
				_layer3d.scene3d.removeChild(child);
			return child;
		}

		public function removeChildAt(index:int, layerName:String="defaultLayer3D"):Object3D
		{
			var child:Object3D;
			var _layer3d:Layer3D=getLayer3D(layerName);
			if (_layer3d && _layer3d.scene3d)
				child=_layer3d.scene3d.removeChildAt(index);
			return child;
		}

		/**
		 * 舞台高
		 * @return
		 *
		 */
		public function get stageHeight():Number
		{
			return _mainLayer.height;
		}

		/**
		 * 舞台宽
		 * @return
		 *
		 */
		public function get stageWidth():Number
		{
			return _mainLayer.width;
		}

		public function update(time:Number, dt:Number=0):void
		{
			// 舞台大小检查
			var isResize:Boolean=false;
			if (_mainLayer.width != Browser.clientWidth)
			{
				_mainLayer.width=Browser.clientWidth;
				isResize=true;
			}

			if (_mainLayer.height != Browser.clientHeight)
			{
				_mainLayer.height=Browser.clientHeight;
				isResize=true;
			}
			clear();
			// 开始渲染
			for (var i:int=0; i < _layer3ds.length; i++)
			{
				// 每次执行层渲染的时候都会清理一次深度
				clearDepthBuffer();
				_layer3ds[i].update(time, dt);
				_layer3ds[i].updateRender(webglContext, time, dt);
			}

			if (isResize && AppGlobalContext._instance.hasListener(EngineContextEvent.RESIZE))
			{
				AppGlobalContext._instance.event(EngineContextEvent.RESIZE);
			}

			if (!_isEngineInit && AppGlobalContext._instance.hasListener(EngineContextEvent.ENGINE_INIT_COMPLETE))
			{
				_isEngineInit=true;
				AppGlobalContext._instance.event(EngineContextEvent.ENGINE_INIT_COMPLETE);
			}
		}

		public function get canvas():* 
		{
			return _canvas;
		}
		
		/**
		 * 初始化WebglContext3D
		 * @return
		 *
		 */
		private function initWebglContext3D():Boolean
		{
			_canvas = Browser.document.getElementById('webglx');
			_canvas.width=Browser.width;
			_canvas.height=Browser.height;
			WebGL.mainContext=webglContext=_canvas.getContext('webgl', {stencil: true, alpah: false, antialias: _antialias, premultipliedAlpha: false});
			return webglContext != null;
		}
		
		//-----------------------------------
		//
		// 渲染状态
		//
		//-----------------------------------
		private var _cullFaceEnabled:Boolean = false;
		private var _cullFace:int = -1;
		
		public function get cullFaceEnabled():Boolean
		{
			return _cullFaceEnabled;
		}
		
		public function set cullFaceEnabled(value:Boolean):void
		{
			if (_cullFaceEnabled == value)
				return;
			
			_cullFaceEnabled = value;
			if (_cullFaceEnabled)
				webglContext.enable(WebGLContext.CULL_FACE);
			else
				webglContext.disable(WebGLContext.CULL_FACE);
		}
		
		public function get cullFace():int
		{
			return _cullFace;
		}
		
		public function set cullFace(value:int):void
		{
			if (_cullFace == value)
				return;
			
			_cullFace = value;
			webglContext.cullFace(_cullFace);
		}
	}
}
