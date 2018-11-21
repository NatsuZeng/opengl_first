package specter3d.engine.materials.compilation
{
	public class ShaderElementArray
	{
		private static const MACRO_DEFINE:String="#define\t";
		private static const VERSION:String="#version\t";
		private static const UNIFORM:String="uniform\t";
		private static const VARYING:String="varying\t";
		private static const ATTRIBUTE:String = "attribute\t";

		private static function filterEmptyLine(line:String):Boolean
		{
			return line != "";
		}

		public function ShaderElementArray(version:int)
		{
			_codes=new Array;
			setVersion(version);
		}

		private var _codes:Array;
		private var _length:int;

		public function setVersion(version:int):void
		{
			additional(VERSION+version);
		}
		
		public function additional(element:String):void
		{
			_codes[_length]=element;
			_length++;
		}

		public function toString():String
		{
			return _codes.filter(filterEmptyLine).join("\n");
		}
		
		/**
		 * 使用宏 
		 * @param name
		 * 
		 */
		public function useMacro(name:String):void
		{
			this.additional(MACRO_DEFINE + name);
		}
		
		/**
		 *　定义 uniform
		 * @param type
		 * @param name
		 * 
		 */
		public function defineUniform(type:String, name:String):void
		{
			this.additional(UNIFORM + type + "\t" + name + ";");
		}
		
		/**
		 * 定义 varying
		 * @param type
		 * @param name
		 * 
		 */		
		public function defineVarying(type:String, name:String):void
		{
			this.additional(VARYING + type + "\t" + name + ";");
		}
		
		/**
		 * 定义 Attribute
		 * @param type
		 * @param name
		 * 
		 */
		public function defineAttribute(type:String, name:String):void
		{
			this.additional(ATTRIBUTE + type + "\t" + name + ";");
		}
		
		public function clear():void
		{
			_codes.length = 0;
			_length = 0;
		}
	}
}
