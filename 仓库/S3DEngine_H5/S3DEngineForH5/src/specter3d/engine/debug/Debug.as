package specter3d.engine.debug
{
	import specter3d.engine.core.context.AppGlobalContext;
	import specter3d.engine.utlis.ArrayUtil;

	public final class Debug
	{
		/**
		 * 查看所有频道
		 */
		public static const ALL:String="all";

		/**
		 * 查看引擎频道
		 */
		public static const ENGINE:String="engine";
		/**
		 *  开启GLSL调试
		 */
		public static var glslDebug:Boolean=false;

		/**
		 * 当前频道
		 */
		private static var _channel:String;
		private static var tempArr:Array=[];

		public static function get channel():String
		{
			return _channel;
		}

		/**
		 * 打印调试信息
		 * @param user
		 * @param msg
		 *
		 */
		public static function dotrace(user:String, ... msg):void
		{
			if (_channel == user || _channel == ALL)
			{
				msg.unshift("[" + user + "->debug] running time:" + AppGlobalContext.renderDrive.time + " ms\n");
				traceLog(msg);
			}
		}

		/**
		 * 打印错误信息
		 * @param user
		 * @param msg
		 *
		 */
		public static function error(user:String, ... msg):void
		{
			if (_channel == user || _channel == ALL)
			{
				msg.unshift("[" + user + "->error] running time:" + AppGlobalContext.renderDrive.time + " ms\n");
				traceLog(msg);
			}
		}

		/**
		 * 设置日志信息频道
		 * @param value
		 *
		 */
		public static function setChannel(value:String):void
		{
			_channel=value;
		}

		/**
		 * 打印警告信息
		 * @param user
		 * @param msg
		 *
		 */
		public static function warning(user:String, ... msg):void
		{
			if (_channel == user || _channel == ALL)
			{
				msg.unshift("[" + user + "->warning] running time:" + AppGlobalContext.renderDrive.time + " ms\n");
				traceLog(msg);
			}
		}

		private static function traceLog(obj:Object):void
		{
			tempArr.length=0;
			var key:String;
			var index:int = 0;
			for (key in obj)
			{
				ArrayUtil.insertAt(tempArr,index++,obj[key]);
			}
			var rst:String;
			rst=tempArr.join("");
			trace(rst);
		}
	}
}
