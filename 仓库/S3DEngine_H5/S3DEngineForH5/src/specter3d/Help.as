package specter3d 
{
	/**
	 * ...
	 * @author wangcx
	 */
	public class Help 
	{
		
		public static const WEBSITE_URL:String="http://www.specter3d.com";

		public static const MAJOR_VERSION:uint=1;

		public static const MINOR_VERSION:uint=0;

		public static const REVISION:uint=1;

		public static function get version():String
		{
			return MAJOR_VERSION + "." + MINOR_VERSION + "." + REVISION;
		}
		
	}

}