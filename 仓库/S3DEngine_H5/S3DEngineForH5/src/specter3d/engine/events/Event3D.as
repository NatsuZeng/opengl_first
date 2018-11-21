package specter3d.engine.events 
{
	import laya.events.Event;
	
	/**
	 * ...
	 * @author wangcx
	 */
	public class Event3D extends Event 
	{
		public static const ADDED:String="added3D";

		public static const REMOVED:String="removed3D";
		
		public static const POSITION_CHANGED:String="positionChanged";
		
		public static const ROTATION_CHANGED:String="rotationChanged";

		public static const SCALE_CHANGED:String="scaleChanged";
		
		public static const UPDATE_TRANSFORM:String="update_transform";
	}

}