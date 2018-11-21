package specter3d.engine.core.drive
{
	import laya.events.EventDispatcher;
	import laya.utils.Browser;
	import specter3d.engine.interfaces.IRenderUpdate;
	import specter3d.engine.utlis.HashMap;
	/**
	 * 渲染驱动器 
	 * @author 回眸笑苍生
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
				var deltaTime:Number=timestamp - absoluteTime
				absoluteTime=timestamp;
				onEnterFrame(absoluteTime, deltaTime);
				Browser.window.requestAnimationFrame(render);
			}
		}

		private var absoluteTime:Number;
		private var driveList:HashMap;

		/**
		 * 注册到渲染列表
		 * @param anim
		 *
		 */
		public function register(anim:IRenderUpdate):void
		{
			anim && driveList.put(anim, anim);
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

		private function onEnterFrame(time:Number, dt:Number):void
		{
			driveList.forEach(updateRender,time,dt);
		}
		
		private function updateRender(key:*,value:*,time:Number, dt:Number):void
		{
			var render:IRenderUpdate = value as IRenderUpdate;
			render.update(time,dt);
		}
	}
}

internal class RenderDriveSingletonEnforcer
{
}
