package specter3d.engine.loaders.parsers
{
	import laya.events.EventDispatcher;
	import laya.utils.Byte;
	import laya.utils.Timer;
	
	import specter3d.engine.core.context.AppGlobalContext;
	import specter3d.engine.errors.AbstractMethodError;
	import specter3d.engine.events.AssetEvent;
	import specter3d.engine.events.ParserEvent;
	import specter3d.engine.utlis.ParserUtil;
	/**
	 * 解析器基类
	 */
	public class ParserBase extends EventDispatcher
	{

		/**
		 * 通过proceedparsing表明还有需要解析的内容需要下一帧继续解析 （允许异步解析）。
		 */
		protected static const MORE_TO_PARSE:Boolean=false;

		/**
		 * 通过proceedparsing表示不再需要返回解析。
		 */
		protected static const PARSING_DONE:Boolean=true;


		/**
		 * 创建接解析器
		 * @param format
		 *
		 */
		public function ParserBase(format:String)
		{
			_dataFormat=format;
		}
		public var isParsering:Boolean=false;
		public var url:String;
		protected var _data:*;
		protected var _dataFormat:String;
		protected var _frameLimit:Number;
		private var _name:String;
		private var _parsingComplete:Boolean;
		private var _parsingFailure:Boolean;

		private var _parsingPaused:Boolean;
		private var _timer:Timer;


		/**
		 * 要解析的文件数据的数据格式。可以是Parserdataformat.binary或Parserdataformat.plain_text。
		 */
		public function get dataFormat():String
		{
			return _dataFormat;
		}

		public function get name():String
		{
			return _name;
		}

		public function set name(value:String):void
		{
			_name=value;
		}

		/**
		 * 分析数据（可能含有bytearry，纯文本或bitmapasset）是异步的，即解析器将定期停止解析，AVM可能前进到下一帧。
		 * @param data
		 * @param frameLimit
		 *
		 */
		public function parseAsync(data:*, frameLimit:Number=30):void
		{
			_data=data;

			startParsing(frameLimit);
		}


		public function get parsingComplete():Boolean
		{
			return _parsingComplete;
		}

		public function get parsingFailure():Boolean
		{
			return _parsingFailure;
		}

		public function set parsingFailure(b:Boolean):void
		{
			_parsingFailure=b;
		}


		public function get parsingPaused():Boolean
		{
			return _parsingPaused;
		}


		protected function finalizeAsset(asset:*):void
		{
			dispatchEvent(new AssetEvent(AssetEvent.ASSET_COMPLETE, asset));
		}


		/**
		 * 完成对数据的解析。
		 */
		protected function finishParsing(isError:Boolean=false):void
		{
			AppGlobalContext.timer.clear(this, onInterval);
			_parsingComplete=true;
			if (isError)
			{
				dispatchEvent(new ParserEvent(ParserEvent.PARSE_ERROR));
			}
			else
			{
				if (hasListener(ParserEvent.PARSE_COMPLETE))
				{
					dispatchEvent(new ParserEvent(ParserEvent.PARSE_COMPLETE));
				}
			}
		}

		protected function getByteData():Byte
		{
			return ParserUtil.toByte(_data);
		}

		protected function getTextData():String
		{
			return ParserUtil.toString(_data);
		}

		protected function onInterval():void
		{
			(proceedParsing() && !_parsingFailure) && finishParsing();
		}

		/**
		 * 解析下一个数据块。
		 * @return
		 *
		 */
		protected function proceedParsing():Boolean
		{
			throw new AbstractMethodError();
			return true;
		}

		/**
		 * 初始化数据解析。
		 * @param frameLimit
		 */
		private function startParsing(frameLimit:Number):void
		{
			_frameLimit=frameLimit;
			AppGlobalContext.timer.loop(_frameLimit, this, onInterval);
		}
	}
}
