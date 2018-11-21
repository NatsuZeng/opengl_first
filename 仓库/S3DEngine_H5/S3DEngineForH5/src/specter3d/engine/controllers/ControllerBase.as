package specter3d.engine.controllers
{
	import specter3d.engine.core.Object3D;
	import specter3d.engine.core.geom.Vector3D;
	import specter3d.engine.errors.AbstractMethodError;
	
	public class ControllerBase
	{
		protected var _autoUpdate:Boolean = true;
		protected var _targetObject:Object3D;
		
		protected var _sVector3D:Vector3D = new Vector3D();
		
		protected function notifyUpdate():void
		{
		}
		
		/**
		 * Target object on which the controller acts. Defaults to null.
		 */
		public function get targetObject():Object3D
		{
			return _targetObject;
		}
		
		public function set targetObject(val:Object3D):void
		{
			if (_targetObject == val)
				return;
			
//			if (_targetObject && _autoUpdate)
//				_targetObject._controller = null;
			
			_targetObject = val;
			
//			if (_targetObject && _autoUpdate)
//				_targetObject._controller = this;
			
			notifyUpdate();
		}
		
		/**
		 * Determines whether the controller applies updates automatically. Defaults to true
		 */
		public function get autoUpdate():Boolean
		{
			return _autoUpdate;
		}
		
		public function set autoUpdate(val:Boolean):void
		{
			if (_autoUpdate == val)
				return;
			
			_autoUpdate = val;
			
//			if (_targetObject) {
//				if (_autoUpdate)
//					_targetObject._controller = this;
//				else
//					_targetObject._controller = null;
//			}
		}
		
		/**
		 * Base controller class for dynamically adjusting the propeties of a 3D object.
		 *
		 * @param    targetObject    The 3D object on which to act.
		 */
		public function ControllerBase(targetObject:Object3D = null):void
		{
			this.targetObject = targetObject;
		}
		
		/**
		 * Manually applies updates to the target 3D object.
		 */
		public function update(interpolate:Boolean = true):void
		{
			throw new AbstractMethodError();
		}
	}
}
