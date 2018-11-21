package specter3d.engine.core.drive
{
	import laya.events.EventDispatcher;
	import laya.utils.Browser;
	
	import specter3d.engine.core.context.AppGlobalContext;
	import specter3d.engine.interfaces.IRenderUpdate;
	import specter3d.engine.managers.NativeEventManager;
	import specter3d.engine.utlis.HashMap;

	/**
	 * 渲染驱动器
	 * @author wangcx
	 *
	 */
	public final class RenderDrive extends EventDispatcher
	{
		private static var _instances:RenderDrive;

		public static function getInstance():RenderDrive
		{
			_instances||=new RenderDrive(new RenderDriveSingletonEnforcer);
			return _instances;
		}

		public function RenderDrive(singleton:RenderDriveSingletonEnforcer)
		{
			if (!singleton)
				throw new Error("This class is a multiton and cannot be instantiated manually. Use RenderDrive.getInstance instead.");

			driveList=new HashMap();
			Browser.window.requestAnimationFrame(render);
			function render(timestamp:Number):void
			{
				var deltaTime:Number=timestamp - absoluteTime;
				if (deltaTime >= _intervalTime)
				{
					absoluteTime=timestamp;
					NativeEventManager.instance.runEvent();
					AppGlobalContext.timer._update();
					driveList.forEach(updateRender, absoluteTime, deltaTime);
				}
				Browser.window.requestAnimationFrame(render);
			}
		}

		private var _frameRate:int=60;
		private var _intervalTime:Number=0;
		private var absoluteTime:Number=0;
		private var driveList:HashMap;

		public function get frameRate():int
		{
			return _frameRate;
		}

		public function set frameRate(value:int):void
		{
			_frameRate=value;
			_intervalTime=1000 / _frameRate;
		}

		/**
		 * 注册到渲染列表
		 * @param anim
		 *
		 */
		public function register(anim:IRenderUpdate):void
		{
			anim && driveList.put(anim, anim);
		}

		public function get time():Number
		{
			return Math.floor(absoluteTime);
		}

		/**
		 * 从渲染列表中移除
		 * @param anim
		 *
		 */
		public function unregister(anim:IRenderUpdate):void
		{
			driveList.remove(anim);
		}

		private function updateRender(key:*, value:*, time:Number, dt:Number):void
		{
			if (value is IRenderUpdate)
			{
				value.update(time, dt);
			}
		}
	}
}

internal class RenderDriveSingletonEnforcer
{
}
