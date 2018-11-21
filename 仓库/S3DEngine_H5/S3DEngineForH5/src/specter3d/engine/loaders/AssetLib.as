package specter3d.engine.loaders
{
	import laya.resource.HTMLImage;
	
	import specter3d.engine.debug.Debug;
	import specter3d.engine.loaders.parsers.AssetObject;
	import specter3d.engine.utlis.HashMap;

	public class AssetLib
	{
		//资源扩展名
		public static const C3DS_TYPE:String=".3ds";
		public static const JPG_TYPE:String=".jpg";
		public static const PNG_TYPE:String=".png";
		public static const MP3_TYPE:String=".mp3";
		public static const ZMD5MESH_TYPE:String =".zmd5mesh";
		//end
		
		/**
		 * 相对路径
		 */
		public static var relativePath:String="";
		
		/**
		 * 取真实加载路径
		 */
		public static var getRealUrl:Function = null;
		
		/**
		 * 资源所在组map,key group name,value url array
		 */
		private static var _assetGroupInfoLib:HashMap=new HashMap;
		
		/**
		 * 资源库
		 */
		private static var _assetLib:HashMap=new HashMap;
		
		/**
		 * 资源组引用列表 （可能存在一个资源被多个组引用的情况。避免勿删再次做引用计数）
		 */
		private static var _assetGroupCiteList:HashMap=new HashMap();
		
		/**
		 * 资源组引用回收列表
		 */		
		public static var citeList:HashMap = new HashMap();
		
		/**
		 * 请求错误资源列表
		 */
		internal static var requestErrorDic:Array=[];
		
		/**
		 * 加载后超过一段时间未使用则清理（默认组除外）
		 */
		private static var autoRecoveryList:HashMap = new HashMap();
		
		private static function addCite(url:String, citeKey:String):void
		{
			var arr:Array = citeList.getValue(url) as Array;
			arr = arr ||= [];
			if(arr.indexOf(citeKey) == -1)
			{
				arr.push(citeKey);
				citeList.put(url,arr);
			}
		}
		
		/**
		 * 删除资源
		 * @param url
		 */
		internal static function delAsset(url:String):void
		{
			url=operationUrlByVersion(url);
//			SkeletonClipNodeDataPool.cleanCache(url);
			// 标记是否存在默认组
			var _isDefaultGroup:Boolean = false;
			// 删除当前资源与其他所有组的关系
			var _groupArr:Array=_assetGroupCiteList.getValue(url) as Array;
			var _index:int=-1;
			if (_groupArr)
			{
				for (var i:int = 0; i < _groupArr.length; i++) 
				{
					if(_groupArr[i] != AssetGroupEnum.DEFAULT_GROUP)
					{
						var _assetArray:Array=_assetGroupInfoLib.getValue(_groupArr[i]) as Array;
						if (_assetArray != null)
						{
							_index=_assetArray.indexOf(url);
							_index != -1 && _assetArray.splice(_index, 1);
						}
					}
					else
					{
						_isDefaultGroup = true;
					}
				}
				if(!_isDefaultGroup) 
				{
					_assetGroupCiteList.remove(url);
					disposeAsset(url);
				}
				else
				{
					_assetGroupCiteList.put(url,[AssetGroupEnum.DEFAULT_GROUP]);	
				}
			}
		}
		
		/**
		 * 获取资源的服务器地址
		 * @param url 相对于resource 下面的路径 比如："icon/box/test.png"
		 * @return
		 *
		 */
		public static function getResourceURL(url:String):String
		{
			url=relativePath + url;
			var realUrl:String=AssetLib.getRealUrl(url);
			return realUrl ? (url + "?" + realUrl) : url;
		}

		/**
		 * 资源销毁
		 * @param url
		 *
		 */
		private static function disposeAsset(url:String):void
		{
			try
			{
//				var _assetObj:Object=_assetLib.remove(url);
//				if (_assetObj is IAsset || _assetObj is ImageObject || _assetObj is S3DObject)
//					_assetObj.dispose();
//				else if (_assetObj is ByteArray)
//					_assetObj.clear();
			}
			catch (e:Error)
			{
				Debug.error(Debug.ENGINE,"dispose() " + url + " error!");
			}
		}
		
		/**
		 * 释放资源组 
		 * @param group
		 * @param ignoreCite 忽略引用强行释放
		 * 
		 */		
		public static function disposeGroup(group:String,ignoreCite:Boolean = false):void
		{
			if(group == AssetGroupEnum.DEFAULT_GROUP)
			{
				return; // 默认组的资源不允许释放
			}
			var _assetUrlArr:Array=_assetGroupInfoLib.remove(group) as Array;
			if (_assetUrlArr)
			{
				for (var i:int=0; i < _assetUrlArr.length; i++)
				{
					var url:String=_assetUrlArr[i];
					
					var _groupArr:Array=_assetGroupCiteList.getValue(url) as Array;
					var _index:int=_groupArr.indexOf(group);
					_index != -1 && _groupArr.splice(_index, 1);
					if (_groupArr.length == 0) // 当前资源没有被其他组引用,表示可以释放
					{
						if(!ignoreCite)
						{
							url = url.replace(AssetLib.relativePath,"");
							var arr:Array = citeList.getValue(url) as Array; // 检测当前资源是否还存在其他的引用
							if(arr && arr.length == 0)
							{
								disposeAsset(url);
							}
							else if(arr == null)
							{
								disposeAsset(url);
							}
						}
						else
						{
							citeList.remove(url);
							disposeAsset(url);
						}
					}
				}
			}
		}
		
		/**
		 * 获取HtmlImage资源 
		 * @param url
		 * @param citeKey
		 * @return 
		 * 
		 */		
		public static function getImage(url:String, citeKey:String):HTMLImage
		{
			return getAsset(url, citeKey) as HTMLImage;
		}
		
		/**
		 * 获取二进制资源 
		 * @param url
		 * @param citeKey
		 * @return 
		 * 
		 */		
		public static function getArrayBuffer(url:String, citeKey:String):ArrayBuffer
		{
			return getAsset(url, citeKey) as ArrayBuffer;
		}
		
		/**
		 * 获取资源通用方法 
		 * @param url
		 * @param citeKey
		 * @return 
		 * 
		 */		
		public static function getAsset(url:String, citeKey:String):Object
		{
			var _asset:Object =_assetLib.getValue(operationUrlByVersion(url));
			if(_asset)
			{
				addCite(url,citeKey);
				autoRecoveryList.remove(url);
			} 
			return _asset;
		}		
		
		/**
		 * 释放资源引用 
		 * @param url
		 * @param citeKey
		 * 
		 */		
		public static function disposeAssetCite(url:String, citeKey:String):void
		{
			var arr:Array = citeList.getValue(url) as Array;
			arr = arr ||= [];
			var index:int = arr.indexOf(citeKey);
			index != -1 && arr.splice(index,1);
			
			if(arr && arr.length == 0)
			{
				delAsset(url);
				citeList.remove(url);
			}
		}
		
		/**
		 * 根据版本处理url
		 * @param url
		 * @return
		 *
		 */
		public static function operationUrlByVersion(url:String):String
		{
			if (!url)
			{
				return url;
			}
			url = formatPath(url);
			if(url.indexOf(relativePath) != -1)
			{
				return url;
			}
			if (url.indexOf("assets") == -1)
			{
				url=relativePath + url;
			}
			return url;
		}
		
		/**
		 * 获取xml资源 (只读取不释放)
		 * @param url
		 * @return
		 *
		 */
//		public static function getXml(url:String):XML
//		{
//			return _assetLib.getValue(operationUrlByVersion(url)) as XML;
//		}
		
		/**
		 * 判断资源是否存在
		 * @param url
		 * @return
		 *
		 */
		public static function hasAsset(url:String):Boolean
		{
			if (requestErrorDic.indexOf(url) != -1)
			{
				return false;
			}
			url=url.replace(relativePath, "");
			return _assetLib.containsKey(operationUrlByVersion(url));
		}
		
		/**
		 * 判断一堆资源是否都被加载过,只要有一个未被加载,都将返回false
		 * @param urls
		 * @return
		 */
		public static function hasAssets(urls:Array):Boolean
		{
			for each (var url:String in urls)
			{
				if (!hasAsset(url))
				{
					return false;
				}
			}
			return true
		}
		
		
		/**
		 * 判断资源组是否存在改资源
		 * @param url
		 * @param group
		 * @return
		 *
		 */
		public static function hasAssetByGroup(url:String, group:String):Boolean
		{
			var _assetGroup:Array=_assetGroupInfoLib.getValue(group) as Array;
			if (!_assetGroup)
				return false;
			var index:int=_assetGroup.indexOf(url);
			return index != -1 ? true : false;
		}
		
		public static function autoRecovery(time:int):void
		{
			autoRecoveryList.forEach(autoRecoveryForEach,time);
		}
		
		private static function autoRecoveryForEach(key:*,value:*,time:int):void
		{
			var _asset:AssetObject = value;
			if(_asset && (time - _asset.lastUseTime) > 10000)
			{
				autoRecoveryList.remove(key);
				delAsset(key);
			}
		}
		
		/**
		 * 缓存资源
		 * @param url
		 * @param data
		 *
		 */
		public static function putAsset(url:String, data:Object, group:String):void
		{
			//暂时这样以后合再改
			var list:Array=_assetGroupInfoLib.getValue(group) as Array;
			if (list == null)
			{
				list=[];
				_assetGroupInfoLib.put(group, list);
			}
			var index:int=list.indexOf(url);
			if (index == -1)
			{
				list.push(url);
			}
			_assetLib.put(url, data);
			if(data is AssetObject)
			{
				autoRecoveryList.put(url.replace(AssetLib.relativePath,""), data);
			}
			var groupArr:Array=_assetGroupCiteList.getValue(url) as Array;
			groupArr=groupArr||=[];
			if (groupArr.indexOf(group) == -1)
			{
				groupArr.push(group);
				_assetGroupCiteList.put(url, groupArr);
			}
		}
		
		/**
		 * 获得重复资源
		 * @return
		 *
		 */
		internal static function getRepeatResources(url:String):Object
		{
			return _assetLib.getValue(url);
		}
		
		public static function formatPath(path:String):String
		{
			if (path == null)
			{
				return "";
			}
			path=path.replace(/\\\\/g, "\\");
			path=path.replace(/\\/g, "/");
			return path;
		}
	}
}