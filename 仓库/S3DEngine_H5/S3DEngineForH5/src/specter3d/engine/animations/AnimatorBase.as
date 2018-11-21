package specter3d.engine.animations
{
	import laya.events.EventDispatcher;
	import specter3d.engine.interfaces.IAnimator;
	import specter3d.engine.objects.Mesh3D;
	public class AnimatorBase extends EventDispatcher implements IAnimator
	{
		public function AnimatorBase()
		{
		}

		public function addOwner(mesh:Mesh3D):void
		{
			// TODO Auto Generated method stub

		}

		public function get isLoop():Boolean
		{
			// TODO Auto Generated method stub
			return false;
		}

		public function set isLoop(value:Boolean):void
		{
			// TODO Auto Generated method stub

		}

		public function play(animatorName:String, offset:Number=0):void
		{
			// TODO Auto Generated method stub

		}

		public function get playSpeed():Number
		{
			// TODO Auto Generated method stub
			return 0;
		}

		public function set playSpeed(value:Number):void
		{
			// TODO Auto Generated method stub

		}

		public function removeOwner(mesh:Mesh3D):void
		{
			// TODO Auto Generated method stub

		}

		public function stop():void
		{
			// TODO Auto Generated method stub

		}

		public function update(time:Number, dt:Number=0):void
		{
			// TODO Auto Generated method stub
		}
	}
}
