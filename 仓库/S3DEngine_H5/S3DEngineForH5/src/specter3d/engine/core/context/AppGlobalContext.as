package specter3d.engine.core.context
{
	import laya.display.Stage;
	import laya.events.EventDispatcher;
	import laya.net.LoaderManager;
	import laya.utils.Browser;
	import laya.utils.Timer;
	import laya.webgl.WebGL;
	
	import specter3d.engine.specter3d;
	import specter3d.engine.core.Layer3D;
	import specter3d.engine.core.Stage3D;
	import specter3d.engine.core.drive.RenderDrive;
	import specter3d.engine.events.EngineContextEvent;
	import specter3d.engine.loaders.MultithreadedLoader;
	import specter3d.engine.managers.Mouse3DManager;
	import specter3d.engine.managers.NativeEventManager;
	import specter3d.engine.materials.compilation.ShaderCompiler;

	use namespace specter3d;
	/**
	 * 应用程序上下文对象
	 * @author wangcx
	 *
	 */
	public class AppGlobalContext extends EventDispatcher
	{

		/**
		 *远程地址
		 */
		public static var telnetBasePath:String=null;
		specter3d static var _instance:AppGlobalContext;

		/**
		 * 文件队列加载器
		 */
		private static var _fileLoader:MultithreadedLoader=new MultithreadedLoader();

		private static var _timer:Timer;

		/**
		 * 文件队列加载器
		 */
		public static function get fileLoader():MultithreadedLoader
		{
			return _fileLoader;
		}

		/**
		 * 引擎初始化
		 * @param fps 默认60帧
		 * @param antialias 是否开启抗锯齿
		 *
		 */
		public static function initEngine(fps:int=60, antialias:Boolean=true):void
		{
			Browser.__init__();
			_timer=new Timer();
			// 3D舞台设置
			instance._stage3d=new Stage3D(antialias);
			NativeEventManager.instance.__init__(instance._stage3d.canvas);
			renderDrive.frameRate=fps;
			AppGlobalContext.renderDrive.register(instance._stage3d);
			on(EngineContextEvent.RESIZE, null, onResize);
		}

		/**
		 * 事件监听器
		 * @param type
		 * @param listener
		 *
		 */
		public static function off(type:String, caller:*, listener:Function):void
		{
			_instance.off(type, caller, listener);
		}

		/**
		 * 事件监听器
		 * @param type
		 * @param listener
		 *
		 */
		public static function on(type:String, caller:*, listener:Function):void
		{
			_instance.on(type, caller, listener);
		}

		public static function get renderDrive():RenderDrive
		{
			return RenderDrive.getInstance();
		}


		public static function get stage2d():Stage
		{
			return _instance._stage2d;
		}

		public static function get stage3d():Stage3D
		{
			return instance._stage3d;
		}

		public static function get stageHeight():int
		{
			return _instance._stageHeight;
		}

		public static function set stageMaxHeight(value:int):void
		{
			_instance._stageMaxHeight=value;
		}

		public static function set stageMaxWidth(value:int):void
		{
			_instance._stageMaxWidth=value;
		}

		public static function set stageMinHeight(value:int):void
		{
			_instance._stageMinHeight=value;
		}

		public static function set stageMinWidth(value:int):void
		{
			_instance._stageMinWidth=value;
		}

		public static function get stageWidth():int
		{
			return _instance._stageWidth;
		}

		public static function get timer():Timer
		{
			return _timer;
		}
		
		public static function get mouseManager():Mouse3DManager
		{
			return instance._stage3d.mouseManager;
		}

		private static function get instance():AppGlobalContext
		{
			!_instance && (_instance=new AppGlobalContext(new AppGlobalContextSingletonEnforcer));
			return _instance;
		}

		private static function onResize():void
		{
			instance._stageWidth=instance._stage3d.stageWidth < instance._stageMinWidth && instance._stageMinWidth > 0 ? instance._stageMinWidth : instance._stage3d.stageWidth;
			instance._stageHeight=instance._stage3d.stageHeight < instance._stageMinHeight && instance._stageMinHeight > 0 ? instance._stageMinHeight : instance._stage3d.stageHeight;
			instance._stageWidth=instance._stage3d.stageWidth > instance._stageMaxWidth && instance._stageMaxWidth > 0 ? instance._stageMaxWidth : instance._stage3d.stageWidth;
			instance._stageHeight=instance._stage3d.stageHeight > instance._stageMaxHeight && instance._stageMaxHeight > 0 ? instance._stageMaxHeight : instance._stage3d.stageHeight;
		}

		public function AppGlobalContext(singleton:AppGlobalContextSingletonEnforcer)
		{
			if (!singleton)
				throw new Error("This class is a multiton and cannot be instantiated manually.");
		}

		private var _stage2d:Stage;
		private var _stage3d:Stage3D;
		private var _stageHeight:int=0;
		private var _stageMaxHeight:int=0;
		private var _stageMaxWidth:int=0;
		private var _stageMinHeight:int=0;
		private var _stageMinWidth:int=0;
		private var _stageWidth:int=0;
	}
}

internal class AppGlobalContextSingletonEnforcer
{
}
