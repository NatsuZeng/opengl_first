package specter3d.engine.loaders
{
	import laya.events.EventDispatcher;
	import laya.utils.Handler;
	
	import specter3d.engine.events.LoaderEvent;
	
	public class ResourceVo extends EventDispatcher
	{
		public static const START:String="start";
		public static const FINISH:String="finish";
		public static const ERROR:String="error";
		/**
		 * 资源分组
		 */
		internal var group:String;
		/**
		 * 资源id,用于标示是不是同一组资源，由系统自动生成
		 */
		internal var token:String;
		/**
		 * 资源加载次数，加载失败超过10次，该资源放弃加载
		 */
		internal var loadTime:int;
		
		
		private var _url:String;
		
		public function set url(value:String):void
		{
			_url=value;
		}
		
		/**
		 * 资源url
		 */
		public function get url():String
		{
			return _url;
		}
		
		/**
		 * 优先级:0-10,优先级越大越早加载
		 */
		public var level:int=1;
		/**
		 *请求加载时间
		 */
		public var reqeuestTime:uint;
		
		
		/**
		 * 资源加载的回调函数，有一个参数，为当前加载资源的url
		 */
		public var callBackHandler:Handler;
		
		/**
		 * 资源加载错误的回调函数，有一个参数，为当前加载资源的url
		 */
		public var errorCallBackHandler:Handler;
		/**
		 *进度回掉
		 */
		public var progressCallBackHandler:Handler;
		
		public function ResourceVo(url:String=null, _level:int=1, _callBackHandler:Handler=null,_errorCallBackHandler:Handler=null)
		{
			_url=AssetLib.operationUrlByVersion(url);
			level=_level;
			errorCallBackHandler = _errorCallBackHandler;
			callBackHandler=_callBackHandler;
		}
		
		
		public function progressing(e:LoaderEvent):void
		{
			if (progressCallBackHandler != null)
			{
				//progressCallBackHandler.call(null, e);
				progressCallBackHandler.runWith(e);
			}
			dispatchEvent(e);
		}
	}
}