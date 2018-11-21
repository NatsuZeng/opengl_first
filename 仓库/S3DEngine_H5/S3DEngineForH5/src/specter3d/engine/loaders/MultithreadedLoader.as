package specter3d.engine.loaders
{
	import laya.utils.Dictionary;
	import laya.utils.Handler;
	
	import specter3d.engine.core.context.AppGlobalContext;
	import specter3d.engine.debug.Debug;
	
	public class MultithreadedLoader
	{	
		private static var _maxConnectionNum:int = 6;
		
		/**
		 * 所有加载中的url
		 */		
		private static var _loadingUrlMap:Dictionary = new Dictionary();
		private static var _useLoaderMap:Dictionary = new Dictionary();
		
		/**
		 *要加载 的资源  排序用
		 */		
		private static var _loadlist:Array = [];
		
		/**
		 *加载组 
		 */		
		private static var _groupMap:Dictionary = new Dictionary;
		
		/**
		 *空闲加载器
		 */		
		private static var _loaderPool:Array = [];
		
		/**
		 *外部加载错误提示 
		 */		
		public static var loaderErrorHandler:Handler = null;
		
		private static var _timerRunning:Boolean = false;
		
		private var _failure:Boolean = false;
		
		/**
		 * 最大连接数 
		 */
		public static function get maxConnectionNum():int
		{
			return _maxConnectionNum;
		}

		/**
		 * 设置最大连接数（默认是6个）
		 */
		public static function setMaxConnectionNum(value:int):void
		{
			_maxConnectionNum = value;
		}

		private function startLoadTime():void
		{
			if (_loaderPool.length == 0 || _loadlist.length == 0)
			{
				AppGlobalContext.timer.clear(this, onTimeHandler);
				_timerRunning = false;
			}
			if (_timerRunning == false)
			{
				AppGlobalContext.timer.loop(10, this, onTimeHandler);
				_timerRunning = true;
			}
		}
		
		private function onTimeHandler():void
		{
			//有可能三个loader空闲
			for (var i:int = 0; i < _maxConnectionNum; i++)
			{
				start();
			}
		}
		
		private function start():void
		{
			if (_loaderPool.length == 0)
			{
				return;
			}
			var loader:QueueFileLoader;
			if(_loadlist.length > 0)
			{
				_loadlist.sort(sortLoadList);
				loader = _loaderPool.pop();
				var resourceVo:ResourceVo = _loadlist.pop();
				_useLoaderMap.set(resourceVo.url, loader);
				loader.loadOne(resourceVo, null, resourceVo.group);
			}
		}
		
		private function sortLoadList(a:ResourceVo, b:ResourceVo):int
		{
			return a.level - b.level;
		}
		
		public function MultithreadedLoader()
		{
			init();
		}
		
		
		private function init():void
		{
			Debug.dotrace(Debug.ENGINE,"MultithreadedLoader init.");
			if(_loaderPool.length > 0)
				return;
			FileLoader.registerParserAll();
			for (var i:int = 0; i < _maxConnectionNum; i++)
			{
				var deamon:QueueFileLoader = new QueueFileLoader();
				_loaderPool.push(deamon);
			}
		}
		
		
		/**
		 * 加载一组资源
		 * @param arr ResourceVo 数组
		 * @param callbackHandler,资源加载完回调函数
		 *	用法实例：
		 * <p>var arr:Vector.<ResourceVo>=new Vector.<ResourceVo>();</p>
		 * <p>arr.push(new ResourceVo("url0", 1, test));//单个资源加载完完成</p>
		 * <p>arr.push(new ResourceVo("url1", 2, test));//单个资源加载完完成</p>
		 * <p>arr.push(new ResourceVo("url2", 3, test));//单个资源加载完完成</p>
		 * <p>AppGlobalContext.fileLoader.loads(arr, test1);//该组所有资源加载完成</p>
		 * 加载完成之后从AssetLib这里面获取资源;
		 */
		public function loads(arr:Vector.<ResourceVo>, callbackHandler:Handler=null, group:String="default_group"):void
		{
			var map:Dictionary = new Dictionary;
			var info:Array = [map, callbackHandler, 0];
			for each(var resourceVo:ResourceVo in arr)
			{
				_groupMap.set(resourceVo, info);
				if(map.get(resourceVo) == null)
				{
					map.set(resourceVo, resourceVo);
					info[2] += 1;
				}
				doAdd(resourceVo, null, group, true);
			}
			start();
		}
		
		/**
		 * 加载单个资源
		 * @param resourceVo
		 * @param callbackHandler,资源加载完回调函数
		 * <p>用法实例：</p>
		 * AppGlobalContext.fileLoader.fileLoader(new ResourceVo("url", 1,callback));
		 * <p>加载完成之后从AssetLib这里面获取资源</p>
		 */
		public function loadOne(resourceVo:ResourceVo, group:String="default_group"):void
		{
			doAdd(resourceVo, null, group);
		} 
		
		/**
		 *清除组 
		 * @param group
		 * 
		 */		
		public function clearByGroup(group:String):void
		{
			var len:int = _loadlist.length - 1;
			for(var i:int = len; i>=0; i--)
			{
				var loadVo:ResourceVo = _loadlist[i];
				if(loadVo.group == group)
				{
					_loadlist.splice(i, 1);
					_loadingUrlMap.remove(loadVo.url);
				}
			}
			
		}
		
		/**
		 * 取消加载 
		 * @param url
		 * @param complete
		 * 
		 */		
		public function cancelLoad(url:String, complete:Handler):void
		{
			url = AssetLib.operationUrlByVersion(url);
			var data:Array = _loadingUrlMap.get(url);
			if(data != null)
			{
				var list:Array = data[1];
				var callBack:Handler = data[2] as Handler;
				for(var i:int = list.length - 1; i>=0; i--)
				{
					var arr:Array = list[i];
					var resourceVo:ResourceVo = arr[0];
					if(resourceVo.callBackHandler == complete || arr[1] == complete)
					{
						resourceVo.callBackHandler = null;
						list.splice(i, 1);
					}
				}
				if(callBack == complete)
				{
					data[2] = null;
				}
			}
		}
		
		/**
		 * 改变加载等级 
		 * @param url
		 * @param level
		 * 
		 */		
		public function chageLevel(url:String, level:int):void
		{
			for each(var loadVo:ResourceVo in _loadlist)
			{
				if(loadVo.url == url)
				{
					loadVo.level = level;
					break;
				}
			}
		}
		
		private function doAdd(resourceVo:ResourceVo, callbackHandler:Handler=null, group:String="default_group", isLockStart:Boolean = false):void
		{
			var fileName:String = getFileName(resourceVo.url);
			if(fileName.indexOf("null") != -1 || fileName == "")
			{
				return;
			}
			var list:Array;
			var loadVo:ResourceVo;
			var data:Array = _loadingUrlMap.get(resourceVo.url);
			if (data != null)
			{
				loadVo =  data[0];
				list = data[1];
				data[2] = callbackHandler;
				loadVo.level = Math.max(resourceVo.level, loadVo.level);
				list.unshift([resourceVo, callbackHandler]);
			}
			else
			{
				list = [[resourceVo, callbackHandler]];
				loadVo = new ResourceVo(resourceVo.url, resourceVo.level, Handler.create(this, onComplete),Handler.create(this, onErrorComplete));
				loadVo.url = resourceVo.url;
				_loadingUrlMap.set(resourceVo.url, [loadVo, list, callbackHandler]);
				_loadlist.push(loadVo);
			}
			loadVo.group = group;
			loadVo.progressCallBackHandler = resourceVo.progressCallBackHandler;
			if(isLockStart == false)
			{
				startLoadTime();
			}
		}
		
		private static function checkResourceExist(resourceVo:ResourceVo):Boolean
		{
			return AssetLib.hasAsset(resourceVo.url);
		}
		
		private function onErrorComplete(url:String):void
		{
			if(loaderErrorHandler != null)
			{
				loaderErrorHandler.runWith(url);
			}
			_failure = true;
			onComplete(url)
			_failure = false;
		}
		private function onComplete(url:String):void
		{
			var loader:QueueFileLoader = _useLoaderMap.get(url);
			var data:Array = _loadingUrlMap.get(url);//这个必需先取出来再删除预防回调中还有再加载相同的东西
			_loadingUrlMap.remove(url);
			_useLoaderMap.remove(url);
			if(loader == null)
			{
				Debug.error(Debug.ENGINE,"加载崩溃");
				return;
			}
			_loaderPool.push(loader);
			//有回调出错这样处理
			exceuteCallBack(data, url);
			startLoadTime();
		}
		
		private function exceuteCallBack(data:Array, url:String):void
		{
			if(data != null)
			{
				var list:Array = data[1];
				var callBack:Handler = data[2] as Handler;
				var callBackMap:Dictionary = new Dictionary;
				while (list.length)
				{
					var arr:Array = list.pop();
					var resourceVo:ResourceVo = arr[0];
					if(_failure)
					{
						if (resourceVo.errorCallBackHandler != null)
						{
							resourceVo.errorCallBackHandler.runWith(url);
						}
					}
					else
					{
						if (resourceVo.callBackHandler != null)
						{
							resourceVo.callBackHandler.runWith(url);
						}
					}
					
					var singleCallBack:Handler = arr[1] as Handler;
					if(arr[1] != callBack && singleCallBack != null && _failure == false)
					{
						singleCallBack.run();
					}
					var info:Array = _groupMap.get(resourceVo);
					if(info != null)
					{
						var map:Dictionary = info[0];
						var groupCallBack:Handler = info[1] as Handler;
						if(map.get(resourceVo) != null)
						{
							info[2] = info[2] - 1;
							map.remove(resourceVo);
						}
						if(info[2] <= 0)
						{
							groupCallBack.run();
						}
					}
					_groupMap.remove(resourceVo);
				} 
				//预防加载同一个回调多次希望回调一次虽然蛋痛
				if (callBack != null && _failure == false)
				{
					callBack.run();
				}
			}
		}
		
		private function getFileName(path:String):String
		{
			var lastIndex:int = path.lastIndexOf("\/");
			lastIndex = lastIndex <0? 0: lastIndex + 1;
			var lastSuffixIndex:int = path.lastIndexOf(".");
			if(lastSuffixIndex < 0)
				return "";
			return   path.slice(lastIndex, lastSuffixIndex);
		}
	}
}