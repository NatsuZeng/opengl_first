package specter3d.engine.lights
{
	public class LightType
	{
		/**
		 * 平行光 
		 */		
		public static const DIRECTION_LIGHT:uint = 0x00;
		
		/**
		 * 点光源 
		 */		
		public static const POINT_LIGHT:uint = 0x01;
		
		/**
		 * 聚光灯 
		 */		
		public static const SPOT_LIGHT:uint = 0x02;
	}
}