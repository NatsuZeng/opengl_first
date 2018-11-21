package specter3d.engine.events
{
	import laya.events.Event;
	
	import specter3d.engine.loaders.URLLoader;
	
	public class LoaderEvent extends Event
	{
		public static const LOADER_COMPLETE: String = "onLoadComplete";
		public static const LOADER_PROGRESS: String = "onLoadProgress";
		public static const LOADER_ERROR: String = "onLoadError";
		
		public var loader: URLLoader;
		
		public var text:String;
		
		public function LoaderEvent()
		{
			super();
		}
	}
}