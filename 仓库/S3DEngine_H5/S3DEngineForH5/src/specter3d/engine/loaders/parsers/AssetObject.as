package specter3d.engine.loaders.parsers
{
	import specter3d.engine.core.context.AppGlobalContext;

	public class AssetObject
	{
		
		protected var _url:String;
		protected var _lastUseTime:int;
		
		public function AssetObject(url:String)
		{
			_url = url;
			updateLastUseTime();
		}
		
		/**
		 * 最后使用的时间 
		 */
		public function get lastUseTime():int
		{
			return _lastUseTime;
		}

		/**
		 * 资源释放 
		 * 
		 */		
		public function dispose():void
		{
			
		}		
		
		/**
		 * 强制资源释放（该函数会忽略引用计数)
		 * 
		 */		
		public function updateLastUseTime():void
		{
			_lastUseTime = AppGlobalContext.timer.currTimer;
		}
	}
}