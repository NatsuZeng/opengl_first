package specter3d.engine.utlis
{
	import laya.utils.Byte;
	

	public class ParserUtil
	{
		public static function toByte(data : *) : Byte
		{
			return data is ArrayBuffer ? new Byte(data) : null;
		}
		
		public static function toString(data : *, length : uint = 0) : String
		{
			var ba : Byte;
			
			length ||= LimitValueUtlis.UINT_MAX_VALUE;
			
			if (data is String)
				return String(data).substr(0, length);
			
			ba = toByte(data);
			if (ba) {
				ba.pos = 0;
				return ba.readUTFBytes(Math.min(ba.bytesAvailable, length));
			}
			
			return null;
		}
	}
}