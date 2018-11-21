package specter3d.engine.events
{
	import laya.events.Event;
	/**
	 * 引擎上下文对象事件定义 
	 * @author wangcx
	 * 
	 */
	public class EngineContextEvent extends Event
	{
		/**舞台大小改变(在范围内)*/
		public static const RESIZE:String="resize";
	
		/**引擎初始化结束*/
		public static const ENGINE_INIT_COMPLETE:String="EngineInitComplete";
	}
}