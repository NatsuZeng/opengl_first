package specter3d.engine.core.context
{
	import specter3d.engine.sprite3d;

	use namespace sprite3d;
	
	/**
	 * 应用程序上下文对象
	 * @author 回眸笑苍生
	 *
	 */
	public class AppGlobalContext
	{
		sprite3d static var _instance:AppGlobalContext;

		/**
		 * 引擎初始化
		 * @param fps
		 * @param _autoSize
		 *
		 */
		public static function initEngine(fps:int=60, _autoSize:Boolean=true):void
		{

		}

		sprite3d static function get instance():AppGlobalContext
		{
			!_instance && (_instance=new AppGlobalContext(new AppGlobalContextSingletonEnforcer));
			return _instance;
		}

		public function AppGlobalContext(singleton:AppGlobalContextSingletonEnforcer)
		{
			if (!singleton)
				throw new Error("This class is a multiton and cannot be instantiated manually.");
		}
	}
}

internal class AppGlobalContextSingletonEnforcer
{
}
