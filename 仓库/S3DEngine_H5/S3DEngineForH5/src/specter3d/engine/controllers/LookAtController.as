package specter3d.engine.controllers
{
	import specter3d.engine.core.Object3D;
	import specter3d.engine.core.geom.Vector3D;
	import specter3d.engine.events.Event3D;
	import specter3d.engine.utlis.Matrix3DUtils;
	
	/**
	 * Extended camera used to automatically look at a specified target object.
	 *
	 * @see away3d.containers.View3D
	 */
	public class LookAtController extends ControllerBase
	{
		protected var _lookAtPosition:Vector3D;
		protected var _lookAtObject:Object3D;
		protected var _origin:Vector3D = new Vector3D(0.0, 0.0, 0.0);
		protected var _upAxis:Vector3D = Vector3D.Y_AXIS;
		private var _pos:Vector3D = new Vector3D();
		/**
		 * Creates a new <code>LookAtController</code> object.
		 */
		public function LookAtController(targetObject:Object3D = null, lookAtObject:Object3D = null)
		{
			super(targetObject);
			
			if (lookAtObject)
				this.lookAtObject = lookAtObject;
			else
				this.lookAtPosition = new Vector3D();
		}
		
		/**
        * The vector representing the up direction of the target object.
        */
		public function get upAxis():Vector3D
		{
			return _upAxis;
		}
		
		public function set upAxis(upAxis:Vector3D):void
		{
			_upAxis = upAxis;
			
			notifyUpdate();
		}

		/**
		 * The Vector3D object that the target looks at.
		 */
		public function get lookAtPosition():Vector3D
		{
			return _lookAtPosition;
		}
		
		public function set lookAtPosition(val:Vector3D):void
		{
			if (_lookAtObject) {
				_lookAtObject.transform.off(Event3D.POSITION_CHANGED, this, onLookAtObjectChanged);
				_lookAtObject = null;
			}
			
			_lookAtPosition = val;
			
			notifyUpdate();
		}
		
		/**
		 * The 3d object that the target looks at.
		 */
		public function get lookAtObject():Object3D
		{
			return _lookAtObject;
		}
		
		public function set lookAtObject(val:Object3D):void
		{
			if (_lookAtPosition)
				_lookAtPosition = null;
			
			if (_lookAtObject == val)
				return;
			
			if (_lookAtObject)
				_lookAtObject.transform.off(Event3D.POSITION_CHANGED, this, onLookAtObjectChanged);
			
			_lookAtObject = val;
			
			if (_lookAtObject)
				_lookAtObject.on(Event3D.POSITION_CHANGED, this, onLookAtObjectChanged);
			
			notifyUpdate();
		}
		
		/**
		 * @inheritDoc
		 */
		public override function update(interpolate:Boolean = true):void
		{
			interpolate = interpolate; // prevents unused warning
			
			if (_targetObject) {
				if (_lookAtPosition) {
					_targetObject.lookAt(_lookAtPosition, _upAxis);
				} else if (_lookAtObject) {
					_pos = _lookAtObject.transform.getPosition(false, _pos);
					if (_targetObject.parent) {
						Matrix3DUtils.transformVector(_targetObject.parent.transform.invWorld, _pos, _pos);
					}
					_targetObject.lookAt(_pos, _upAxis);
				}
			}
		}
		
		private function onLookAtObjectChanged(event:Event3D):void
		{
			notifyUpdate();
		}
	}
}
