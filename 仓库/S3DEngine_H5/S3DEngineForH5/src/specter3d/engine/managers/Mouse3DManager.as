package specter3d.engine.managers
{
	import specter3d.engine.core.Layer3D;
	import specter3d.engine.core.Object3D;
	import specter3d.engine.core.geom.Vector3D;
	import specter3d.engine.core.picker.PickerVO;
	import specter3d.engine.core.picker.RaycastPicker;
	import specter3d.engine.events.MouseEvent3D;
	
	/**
	 * Mouse3DManager enforces a singleton pattern and is not intended to be instanced.
	 * it provides a manager class for detecting 3D mouse hits on Layer3D objects and sending out 3D mouse events.
	 */
	public class Mouse3DManager
	{
		private var _layer:Layer3D;
		
		private var _updateDirty:Boolean = true;
		private var _nullVector:Vector3D = new Vector3D();
		protected static var _collidingObject:PickerVO;
		private static var _previousCollidingObject:PickerVO;
		private static var _collidingLayerObjects:Vector.<PickerVO>;
		private static var _queuedEvents:Vector.<MouseEvent3D> = new Vector.<MouseEvent3D>();
		
		private var _mouseMoveEvent:MouseEvent3D = new MouseEvent3D(MouseEvent3D.MOUSE_MOVE);
		
		private static var _mouseUp:MouseEvent3D = new MouseEvent3D(MouseEvent3D.MOUSE_UP);
		private static var _mouseClick:MouseEvent3D = new MouseEvent3D(MouseEvent3D.CLICK);
		private static var _mouseOut:MouseEvent3D = new MouseEvent3D(MouseEvent3D.MOUSE_OUT);
		private static var _mouseDown:MouseEvent3D = new MouseEvent3D(MouseEvent3D.MOUSE_DOWN);
		private static var _mouseMove:MouseEvent3D = new MouseEvent3D(MouseEvent3D.MOUSE_MOVE);
		private static var _mouseOver:MouseEvent3D = new MouseEvent3D(MouseEvent3D.MOUSE_OVER);
		private static var _mouseWheel:MouseEvent3D = new MouseEvent3D(MouseEvent3D.MOUSE_WHEEL);
		private static var _mouseDoubleClick:MouseEvent3D = new MouseEvent3D(MouseEvent3D.DOUBLE_CLICK);
		
		private var _forceMouseMove : Boolean;		// 鼠标不动时，是否也一直发送MouseMove
		private var _mousePicker:RaycastPicker = new RaycastPicker();
		
		/**
		 * Creates a new <code>Mouse3DManager</code> object.
		 */
		public function Mouse3DManager()
		{
		}
		
		// ---------------------------------------------------------------------
		// Interface.
		// ---------------------------------------------------------------------
		
		public function updateCollider(layer:Layer3D):void
		{
			_previousCollidingObject = _collidingObject;
			if (layer == this.layer && (_forceMouseMove || _updateDirty))
			{
				//_mousePicker.getViewCollision(
				
			}
			_updateDirty = false;
		}
		
		public function fireMouseEvents():void
		{
			var i:uint;
			var len:uint;
			var event:MouseEvent3D;
			var dispatcher:Object3D;
			
			// If colliding object has changed, queue over/out events.
			if (_collidingObject != _previousCollidingObject) {
				if (_previousCollidingObject)
					queueDispatch2(_mouseOut, _mouseMoveEvent, _previousCollidingObject);
				if (_collidingObject)
					queueDispatch2(_mouseOver, _mouseMoveEvent, _collidingObject);
			}
			
			// Fire mouse move events here if forceMouseMove is on.
			if (_forceMouseMove && _collidingObject)
				queueDispatch2(_mouseMove, _mouseMoveEvent, _collidingObject);
			
			// Dispatch all queued events.
			len = _queuedEvents.length;
			for (i = 0; i < len; ++i) {
				// Only dispatch from first implicitly enabled object ( one that is not a child of a mouseChildren = false hierarchy ).
				event = _queuedEvents[i];
				dispatcher = event.object;
				
				while (dispatcher)
					dispatcher = dispatcher.parent;
				
				if (dispatcher)
					dispatcher.dispatchEvent(event);
			}
			_queuedEvents.length = 0;
			
			_updateDirty = false;
			_previousCollidingObject = _collidingObject;
		}

		public function dispose():void
		{
			_mousePicker.dispose();
		}
		
		// ---------------------------------------------------------------------
		// Private.
		// ---------------------------------------------------------------------
		
		private function queueDispatch2(event:MouseEvent3D, sourceEvent:MouseEvent3D, collider:PickerVO):void
		{
			queueDispatch(event, 
				sourceEvent.screenX, sourceEvent.screenY, sourceEvent.delta, 
				sourceEvent.ctrlKey, sourceEvent.altKey, sourceEvent.shiftKey,
				collider);
		}
		
		private function queueDispatch(event:MouseEvent3D, 
									   screenX:Number, screenY:Number, delta:Number, 
									   ctrlKey:Boolean, altKey:Boolean, shiftKey:Boolean, 
									   collider:PickerVO = null):void
		{
			// 2D properties.
			event.ctrlKey = ctrlKey;
			event.altKey = altKey;
			event.shiftKey = shiftKey;
			event.delta = delta;
			event.screenX = screenX;
			event.screenY = screenY;
			
			collider ||= _collidingObject;
			
			// 3D properties.
			if (collider) {
				// Object.
				event.object = collider.target;
				event.renderable = collider.renderable;
				// UV.
				event.uv = collider.uv;
				// Position.
				event.localPosition = collider.localPosition? collider.localPosition.clone() : null;
				// Normal.
				event.localNormal = collider.localNormal? collider.localNormal.clone() : null;
				// Face index.
				event.index = collider.index;
				// SurfaceIndex.
				event.surfaceIndex = collider.surfaceIndex;
				
			} else {
				// Set all to null.
				event.uv = null;
				event.object = null;
				event.localPosition = _nullVector;
				event.localNormal = _nullVector;
				event.index = 0;
				event.surfaceIndex = 0;
			}
			
			// Store event to be dispatched later.
			_queuedEvents.push(event);
		}
		
		// ---------------------------------------------------------------------
		// Listeners.
		// ---------------------------------------------------------------------
		
		private function onMouseMove(screenX:Number, screenY:Number, ctrlKey:Boolean, altKey:Boolean, shiftKey:Boolean):void
		{
			if (_collidingObject)
			{
				_mouseMoveEvent.screenX = screenX;
				_mouseMoveEvent.screenY = screenY;
				_mouseMoveEvent.delta = 0;
				_mouseMoveEvent.ctrlKey = ctrlKey;
				_mouseMoveEvent.altKey = altKey;
				_mouseMoveEvent.shiftKey = shiftKey;
				queueDispatch(_mouseMove, screenX, screenY, 0, ctrlKey, altKey, shiftKey);
			}
			_updateDirty = true;
		}
		
		private function onMouseOut(screenX:Number, screenY:Number, ctrlKey:Boolean, altKey:Boolean, shiftKey:Boolean):void
		{
			if (_collidingObject)
				queueDispatch(_mouseOut, screenX, screenY, 0, ctrlKey, altKey, shiftKey, _collidingObject);
			_updateDirty = true;
		}
		
		private function onMouseOver(screenX:Number, screenY:Number, ctrlKey:Boolean, altKey:Boolean, shiftKey:Boolean):void
		{
			if (_collidingObject && _previousCollidingObject != _collidingObject)
				queueDispatch(_mouseOver, screenX, screenY, 0, ctrlKey, altKey, shiftKey, _collidingObject);
			_updateDirty = true;
		}
		
		public function onClick(screenX:Number, screenY:Number, ctrlKey:Boolean, altKey:Boolean, shiftKey:Boolean):void
		{
			if (_collidingObject)
				queueDispatch(_mouseClick, screenX, screenY, 0, ctrlKey, altKey, shiftKey);
			_updateDirty = true;
		}
		
		public function onDoubleClick(screenX:Number, screenY:Number, ctrlKey:Boolean, altKey:Boolean, shiftKey:Boolean):void
		{
			if (_collidingObject)
				queueDispatch(_mouseDoubleClick, screenX, screenY, 0, ctrlKey, altKey, shiftKey);
			_updateDirty = true;
		}
		
		public function onMouseDown(screenX:Number, screenY:Number, ctrlKey:Boolean, altKey:Boolean, shiftKey:Boolean):void
		{
			if (_collidingObject)
				queueDispatch(_mouseDown, screenX, screenY, 0, ctrlKey, altKey, shiftKey);
			_updateDirty = true;
		}
		
		public function onMouseUp(screenX:Number, screenY:Number, ctrlKey:Boolean, altKey:Boolean, shiftKey:Boolean):void
		{
			if (_collidingObject)
				queueDispatch(_mouseUp, screenX, screenY, 0, ctrlKey, altKey, shiftKey);
			_updateDirty = true;
		}
		
		public function onMouseWheel(screenX:Number, screenY:Number, delta:Number, ctrlKey:Boolean, altKey:Boolean, shiftKey:Boolean):void
		{
			if (_collidingObject)
				queueDispatch(_mouseWheel, screenX, screenY, delta, ctrlKey, altKey, shiftKey);
			_updateDirty = true;
		}
		
		public function set layer(value:Layer3D):void
		{
			_layer = value;
		}
		
		public function get layer():Layer3D
		{
			return _layer;
		}
		
		public function get forceMouseMove() : Boolean
		{
			return _forceMouseMove;
		}
		
		public function set forceMouseMove(value : Boolean) : void
		{
			_forceMouseMove = value;
		}
		
		public function get mousePicker():RaycastPicker
		{
			return _mousePicker;
		}
		
		public function set mousePicker(value:RaycastPicker):void
		{
			_mousePicker = value;
		}
	}
}
