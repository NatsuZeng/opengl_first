package specter3d.engine.loaders
{
	import laya.events.Event;
	import laya.events.EventDispatcher;
	
	import specter3d.engine.core.context.AppGlobalContext;
	import specter3d.engine.debug.Debug;
	import specter3d.engine.events.AssetEvent;
	import specter3d.engine.events.LoaderEvent;
	import specter3d.engine.events.ParserEvent;
	import specter3d.engine.loaders.parsers.C3DSParser;
	import specter3d.engine.loaders.parsers.MD5MeshParser;
	import specter3d.engine.loaders.parsers.ParserBase;
	import specter3d.engine.utlis.HashMap;
	
	public class FileLoader extends EventDispatcher
	{
		/**
		 * 解析器集合
		 */
		private static var _parserSet:HashMap=new HashMap;
		
		protected var _urlLoader:URLLoader;
		
		public function FileLoader(target:EventDispatcher=null)
		{
			super();
		}
		
		protected var _url:String;
		
		/**
		 * 资源url
		 */
		public function get url():String
		{
			return _url;
		}
		
		/**
		 * 分组
		 */
		private var _group:String;
		
		/**
		 * 注册解析器
		 * @param _suffix
		 * @param _parser
		 *
		 */
		public static function registerParser(_suffix:String, _parserClass:Class):void
		{
			var _parser:*=_parserSet.getValue(_suffix);
			!_parser && _parserSet.put(_suffix, _parserClass);
		}
		
		/**
		 * 注册所有已知类型解析器
		 * @param _suffix
		 * @param _parser
		 *
		 */
		public static function registerParserAll():void
		{
			registerParser(AssetLib.C3DS_TYPE, C3DSParser);
			registerParser(AssetLib.ZMD5MESH_TYPE, MD5MeshParser);
		}
		
		/**
		 * 分解文件后缀
		 * @param url
		 * @return
		 *
		 */
		protected function decomposeFileSuffix(url:String):String
		{
			if (!url)
			{
				return "";
			}
			var lastIndex:int=url.lastIndexOf(".");
			var type:String=url.substr(lastIndex);
			return type.toLocaleLowerCase();
		}
		
		/**
		 * 加载
		 * @param url
		 *
		 */
		protected function load(url:String, group:String):Object
		{
			_url=url;
			_group=group;
			removeAllLoadEvent();
			_urlLoader == null && (_urlLoader=new URLLoader());
			_urlLoader.on(LoaderEvent.LOADER_PROGRESS, this, progressing);
			_urlLoader.on(LoaderEvent.LOADER_ERROR, this, onFileLoaderError);
			_urlLoader.on(LoaderEvent.LOADER_COMPLETE, this, onFileLoaderOver);
			
			var responseType:String = "";
			var fileType:String = this.decomposeFileSuffix(_url);
			if (fileType == AssetLib.JPG_TYPE || fileType == AssetLib.PNG_TYPE)
			{
				responseType = URLLoader.IMAGE;
			} 
			else if (fileType == AssetLib.MP3_TYPE)
			{
				responseType = URLLoader.SOUND;
			}
			else
			{
				responseType = URLLoader.BUFFER;
			}
			if(AssetLib.requestErrorDic.indexOf(url) != -1)
			{
				_urlLoader.send(urlRequest(_url+"?error="+AppGlobalContext.timer.currTimer), null, null, responseType);
			}
			else
			{
				_urlLoader.send(urlRequest(_url), null, null, responseType);
			}
			
			return _urlLoader;
		}
		
		protected function removeAllLoadEvent():void
		{
			if(_urlLoader != null)
			{
				_urlLoader.offAll(LoaderEvent.LOADER_PROGRESS);
				_urlLoader.offAll(LoaderEvent.LOADER_COMPLETE);
				_urlLoader.offAll(LoaderEvent.LOADER_ERROR);
			}
		}
		
		protected function urlRequest($url:String):String
		{
			$url=formatPath($url);
			var __realUrl:String = AssetLib.getRealUrl ? AssetLib.getRealUrl($url) : null;
			if (__realUrl == null)
			{
				if (AppGlobalContext.telnetBasePath != null)
				{
					$url=AppGlobalContext.telnetBasePath + "/" + $url;
				}
				return $url;
			}
			return __realUrl;
		}
		
		/**
		 * 开始下一次加载
		 *
		 */
		protected function nextLoad(failure:Boolean = false):void
		{
		}
		
		protected function onAssetComplete(event:AssetEvent):void
		{
			AssetLib.putAsset(this._url, event.asset, _group ? _group : AssetGroupEnum.DEFAULT_GROUP);
		}
		
		protected function onCurrentParseComplete(_parser:ParserBase):void
		{
			_parser.offAll(ParserEvent.PARSE_ERROR);
			_parser.offAll(AssetEvent.ASSET_COMPLETE);
			_parser.offAll(ParserEvent.PARSE_COMPLETE);
			nextLoad();
		}
		
		/**
		 * 加载失败
		 * @param event
		 *
		 */
		protected function onFileLoaderError(event:LoaderEvent):void
		{
			removeAllLoadEvent();
			Debug.error(Debug.ENGINE,"载入失败:" + _url + "\n 【" + event.text + "】");
		}
		
		/**
		 * 加载完成
		 * @param event
		 *
		 */
		protected function onFileLoaderOver(event:Event):void
		{
			removeAllLoadEvent();
		}
		
		/**
		 * 解析加载的数据
		 * @param data 类型
		 *
		 */
		protected function parseData(data:Object):void
		{
			//解析器代码
			var _parser:ParserBase=getParserFromSuffix();
			if (_parser != null)
			{
				_parser.name=this._url;
				_parser.on(AssetEvent.ASSET_COMPLETE,this, onAssetComplete);
				_parser.on(ParserEvent.PARSE_COMPLETE,this, onCurrentParseComplete,[_parser]);
				_parser.on(ParserEvent.PARSE_ERROR,this, parserFileError,[_parser]);
				_parser.parseAsync(data);
			}
			else
			{
				AssetLib.putAsset(this._url, data, _group);
				nextLoad();
			}
		}
		
		private function parserFileError(_parser:ParserBase):void
		{
			_parser.offAll(ParserEvent.PARSE_ERROR);
			_parser.offAll(AssetEvent.ASSET_COMPLETE);
			_parser.offAll(ParserEvent.PARSE_COMPLETE);
			Debug.error(Debug.ENGINE, "解析失败:" + _url);
			nextLoad(true);
		}
		
		/**
		 * 根据后缀获得对应的解析器
		 * @return
		 *
		 */
		private function getParserFromSuffix():ParserBase
		{
			var _suffix:String=decomposeFileSuffix(this._url);
			var _parser:*=_parserSet.getValue(_suffix);
			if (_parser is Class)
			{
				var _parserObj:ParserBase=new _parser();
				return _parserObj;
			}
			return null;
		}
		
		/**
		 * 进度条控制
		 * @param event
		 *
		 */
		protected function progressing(event:LoaderEvent):void
		{
			dispatchEvent(event);
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
