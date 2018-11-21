package specter3d.engine.loaders
{
	import laya.events.Event;
	import laya.utils.Dictionary;
	import laya.utils.Handler;
	
	import specter3d.engine.core.context.AppGlobalContext;
	import specter3d.engine.debug.Debug;
	import specter3d.engine.events.LoaderEvent;
	import specter3d.engine.utlis.HashMap;

	public class QueueFileLoader extends FileLoader
	{
		/**
		 * 所有要下载的字节数
		 */
		private var _byteAll:int = 0;
		/**
		 * 目前已下载的字节数
		 */
		private var _byteNow:int = 0;
		
		/**
		 * 加载器列表
		 */
		private var _loaderArr:Array = [];
		
		/**
		 * 总下载下载进度
		 */
		private var _nowPer:int = 0;
		
		
		private var _timerRunning:Boolean = false;
		
		/**
		 * 更新进度函数
		 */
		private var _updataProgress:Handler = null;
		/**
		 * 当前加载资源vo
		 */
		private var currentResourceVo:ResourceVo;
		/**
		 * 存在加载队列资源map，key是url,value是token数组
		 */
		private var existQueueHashMap:HashMap = new HashMap();
		/**
		 * 是否加载中
		 */
		private var loading:Boolean = false;
		/**
		 * 资源map，key是token,value是数组[0]=这批资源的数量[1]加载完的回调
		 */
		private var resourceHashMap:HashMap = new HashMap();
		
		/**
		 * 资源数组
		 */
		private var resourceVoArr:Vector.<ResourceVo> = new Vector.<ResourceVo>();
		
		/**
		 * 资源令牌
		 */
		private var token:int = 0;
		
		/**无效URL记录*/
		private static var _invalidURLMap:Dictionary = new Dictionary();
		
		/**所有已经加载过的历史记录*/
		private static var _history:Dictionary = new Dictionary();
		
		/**是否已经成功加载过某个资源*/
		public static function hasLoaded(url:String):Boolean
		{
			return url && _history.get(url);
		}
		
		/**
		 * 所有要下载的字节数
		 */
		public function get byteAll():int
		{
			return _byteAll;
		}
		
		/**
		 * 目前已下载的字节数
		 */
		public function get byteNow():int
		{
			return _byteNow;
		}
		
		/**
		 * 加载单个资源
		 * @param resourceVo
		 * @param callbackHandler,资源加载完回调函数
		 *	用法实例：
		 * AppGlobalContext.QueueLoader.loadOne(new ResourceVo("aaaa", 1), test1);
		 * 加载完成之后从AssetLib这里面获取资源,例子:获取图片 var data:ImageObject = AssetLib.getData(url) as ImageObject;
		 */
		public function loadOne(resourceVo:ResourceVo, callbackHandler:Handler = null, group:String = "default_group"):void
		{
			if (resourceVo.url == AssetLib.relativePath)
			{
				Debug.error(Debug.ENGINE,"加载空目录.");
				return;
			}
			this._nowPer = 0;
			this._byteAll = 0;
			this._byteNow = 0;
			var num:int = 0;
			resourceVo.group = group;
			if (operationResourceVo(resourceVo))
			{
				num = num + 1;
			}
			startLoader(num, callbackHandler);
		}
		
		/**
		 * 加载一组资源
		 * @param arr ResourceVo 数组
		 * @param callbackHandler,资源加载完回调函数
		 *	用法实例：
		 *  var arr:Vector.<ResourceVo>=new Vector.<ResourceVo>();
		 arr.push(new ResourceVo("aaaa", 1, test));//单个资源加载完完成
		 arr.push(new ResourceVo("aaaa", 2, test));//单个资源加载完完成
		 arr.push(new ResourceVo("aaaa", 3, test));//单个资源加载完完成
		 AppGlobalContext.QueueLoader.loads(arr, test1);//该组所有资源加载完成
		 加载完成之后从AssetLib这里面获取资源,例子:获取图片 var data:ImageObject = AssetLib.getData(url) as ImageObject;
		 */
		public function loads(arr:Vector.<ResourceVo>, callbackHandler:Handler = null, group:String = "default_group"):void
		{
			this._nowPer = 0;
			this._byteAll = 0;
			this._byteNow = 0;
			var num:int = 0;
			while (arr.length > 0)
			{
				var resourceVo:ResourceVo = arr.pop();
				resourceVo.group = group;
				if (operationResourceVo(resourceVo))
				{
					num = num + 1;
				}
			}
			startLoader(num, callbackHandler);
		}
		
		/**
		 * 处理resourceVo
		 * @param resourceVo
		 * @return
		 *
		 */
		private function operationResourceVo(resourceVo:ResourceVo):Boolean
		{
			resourceVo.token = "token" + token;
			if (_invalidURLMap.get(resourceVo.url)) //是无效url
			{
				if (resourceVo.errorCallBackHandler != null)
				{
					resourceVo.errorCallBackHandler.runWith(resourceVo.url);
				}
				return false;
			}
			if (resourceVo.url == AssetLib.relativePath)
			{ //空目录
				return false;
			}
			if (!this.checkResourceExist(resourceVo))
			{
				Debug.dotrace(Debug.ENGINE,"加载资源" + resourceVo.url);
				if (!this.checkExistQueueExist(resourceVo))
				{
					resourceVoArr.push(resourceVo);
					return true;
				}
				else
				{
					if (existQueueHashMap.getValue(resourceVo.url) == null)
					{
						existQueueHashMap.put(resourceVo.url, []);
					}
					(existQueueHashMap.getValue(resourceVo.url) as Array).push(["token" + token, resourceVo.callBackHandler, resourceVo.url]);
					return true;
				}
			}
			else
			{
				if (resourceVo.callBackHandler != null)
				{
					resourceVo.callBackHandler.runWith(resourceVo.url);
				}
			}
			return false;
		}
		
		/**
		 * 开始加载
		 * @param num
		 * @param callbackHandler
		 *
		 */
		private function startLoader(num:int, callbackHandler:Handler):void
		{
			if (num == 0) //资源存在 或 路径失效，无需加载
			{
				callbackHandler && callbackHandler.run();
			}
			else
			{
				resourceHashMap.put("token" + token, [num, callbackHandler]);
				resourceVoArr.sort(resourceVoCompare);
			}
			
			token = token + 1;
			this.execute();
			
			if (resourceVoArr.length && !_timerRunning)
			{
				AppGlobalContext.timer.loop(10, this, _updatePer);
				_timerRunning = true;
			}
		}
		
		public function clean():void
		{
			while (resourceVoArr.length)
			{
				var vo:ResourceVo = resourceVoArr.pop();
				vo.callBackHandler = null;
			}
			resourceVoArr.length = 0;
		}
		
		/**
		 * 总下载下载进度
		 */
		public function get nowPer():int
		{
			return _nowPer;
		}
		
		/**
		 * 更新进度函数
		 */
		public function set updataProgress(value:Handler):void
		{
			_updataProgress = value;
		}
		
		override protected function nextLoad(failure:Boolean = false):void
		{
			// TODO Auto Generated method stub
			super.nextLoad(failure);
			loadComplete(failure);
			this.loading = false;
			this.execute();
		}
		
		/**
		 * 加载失败
		 * @param event
		 *
		 */
		override protected function onFileLoaderError(event:LoaderEvent):void
		{
			// TODO Auto Generated method stub
			super.onFileLoaderError(event);
			currentResourceVo.loadTime = currentResourceVo.loadTime + 1;
			if (currentResourceVo.loadTime > 1) //加载失败3次，放弃加载该资源
			{
				_invalidURLMap.set(currentResourceVo.url, currentResourceVo.url); //记录无效url
				loadComplete(true);
			}
			else
			{
				resourceVoArr.splice(0, 0, currentResourceVo);
			}
			this.loading = false;
			this.execute();
		}
		
		/**
		 * 加载完成
		 * @param event
		 *
		 */
		
		/**
		 * 加载完成
		 * @param event
		 *
		 */
		override protected function onFileLoaderOver(event:Event):void
		{
			// TODO Auto Generated method stub
			super.onFileLoaderOver(event);
			this.parseData((event.currentTarget as URLLoader).data);
		}
		
		private function _updatePer():void 
		{
			var _tmpAll:int;
			var _tmpNow:int;
			for each (var ld:Object in this._loaderArr)
			{
				_tmpAll += URLLoader(ld).bytesTotal;
				_tmpNow += URLLoader(ld).bytesLoaded;
			}
			this._byteAll = _tmpAll;
			this._byteNow = _tmpNow;
			this._nowPer = this.byteNow / this.byteAll * 100;
			_updataProgress && _updataProgress.runWith([_byteNow, _byteAll, _nowPer]);
		}
		
		/**
		 * 判断资源是否存在加载队列
		 * @return
		 *
		 */
		private function checkExistQueueExist(resourceVo:ResourceVo):Boolean
		{
			for (var i:int = 0; i < resourceVoArr.length; i++)
			{
				if (resourceVoArr[i].url == resourceVo.url)
				{
					return true;
				}
			}
			return false;
		}
		
		
		/**
		 * 判断资源是否存在
		 * @return
		 *
		 */
		private function checkResourceExist(resourceVo:ResourceVo):Boolean
		{
			return AssetLib.hasAsset(resourceVo.url);
		}
		
		/**
		 * 执行加载
		 *
		 */
		private function execute():void
		{
			if (!loading)
			{
				loading = true;
				currentResourceVo = resourceVoArr.pop();
				if (currentResourceVo)
				{
					if (currentResourceVo.hasListener(ResourceVo.START))
					{
						var event:Event = new Event();
						event.type = ResourceVo.START;
						currentResourceVo.dispatchEvent(event);
					}
					_loaderArr.push(this.load(currentResourceVo.url, currentResourceVo.group));
				}
				else
				{
					loading = false;
					AppGlobalContext.timer.clear(this, _updatePer);
					_timerRunning = false;
					_updataProgress = null;
					_byteAll = 0; //所有要下载的
					_byteNow = 0; //目前已下载的
					_nowPer = 0; //下载进度
					_loaderArr = [];
				}
			}
		}
		
		/**
		 * 加载结束
		 *
		 */
		protected function loadComplete(failure:Boolean = false):void
		{
			var resourceInfoArr:Array = resourceHashMap.getValue(currentResourceVo.token) as Array;
			resourceInfoArr[0] = resourceInfoArr[0] - 1;
			_history.set(currentResourceVo.url, true); //记录到历史
			
			if (currentResourceVo.hasListener(failure ? ResourceVo.ERROR : ResourceVo.FINISH))
			{
				var event:Event = new Event();
				event.type = failure ? ResourceVo.ERROR : ResourceVo.FINISH
				currentResourceVo.dispatchEvent(event);
			}
			
			if(!failure)
			{
				if (currentResourceVo.callBackHandler != null)
				{
					currentResourceVo.callBackHandler.runWith(currentResourceVo.url);
				}
			}
			else
			{
				if (currentResourceVo.errorCallBackHandler != null)
				{
					currentResourceVo.errorCallBackHandler.runWith(currentResourceVo.url);
				}
			}
			
			if (resourceInfoArr[0] <= 0) //代表当前这批资源加载完成
			{
				if (resourceInfoArr[1] as Handler)
				{
					(resourceInfoArr[1] as Handler).run();
				}
				resourceHashMap.remove(currentResourceVo.token);
			}
			var existTokenArr:Array = existQueueHashMap.getValue(currentResourceVo.url) as Array;
			if (existTokenArr)
			{
				for (var i:int = 0; i < existTokenArr.length; i++)
				{
					var existTokenArrItem:Array = existTokenArr[i] as Array;
					var tokenTemp:String = existTokenArrItem[0].toString();
					resourceInfoArr = resourceHashMap.getValue(tokenTemp) as Array;
					resourceInfoArr[0] = resourceInfoArr[0] - 1;
					if ((existTokenArrItem[1] as Handler) != null)
					{
						(existTokenArrItem[1] as Handler).runWith(existTokenArrItem[2].toString());
					}
					if (resourceInfoArr[0] <= 0) //代表当前这批资源加载完成
					{
						if (resourceInfoArr[1] as Handler)
						{
							(resourceInfoArr[1] as Handler).run();
						}
						resourceHashMap.remove(tokenTemp);
					}
				}
				existQueueHashMap.remove(currentResourceVo.url);
			}
		}
		
		/**
		 * resourceVoArr 比较器
		 * @param a
		 * @param b
		 * @return
		 *
		 */
		private function resourceVoCompare(a:ResourceVo, b:ResourceVo):int
		{
			if (a.level < b.level)
			{
				return -1;
			}
			else if (a.level > b.level)
			{
				return 1;
			}
			else
			{
				return 0;
			}
			
		}
		
		override protected function progressing(event:LoaderEvent):void
		{
			event.target.off(event.type, progressing);
			if (currentResourceVo && currentResourceVo.url == url)
				currentResourceVo.progressing(event);
		}
		
		public function get waitLoadSize():int{
			if (resourceVoArr){
				return resourceVoArr.length;
			}
			return 0;
		}
		
		
	}
}
