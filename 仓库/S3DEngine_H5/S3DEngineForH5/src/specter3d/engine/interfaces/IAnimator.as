package specter3d.engine.interfaces
{
	import specter3d.engine.objects.Mesh3D;

	public interface IAnimator extends IRenderUpdate
	{
		function play(animatorName:String,offset:Number = 0):void;
		
		function stop():void;
		
		function set playSpeed(value:Number):void;
		
		function get playSpeed():Number;
		
		function addOwner(mesh : Mesh3D) : void;
		
		function removeOwner(mesh : Mesh3D) : void;
		
		function set isLoop(value:Boolean):void;
		
		function get isLoop():Boolean;
	}
}