package specter3d.engine.managers
{
	import laya.display.Input;
	import laya.events.Event;
	import laya.events.EventDispatcher;
	import laya.maths.Matrix;
	import laya.maths.Point;
	import laya.maths.Rectangle;
	import laya.utils.Browser;
	
	public class DefaultInput extends EventDispatcher {
		/**
		 * MouseManager 单例引用。
		 */
		public static const instance:DefaultInput = new DefaultInput();
		
		/**是否开启鼠标检测，默认为true*/
		public static var enabled:Boolean = true;
		/** canvas 上的鼠标X坐标。*/
		public var mouseX:Number = 0;
		/** canvas 上的鼠标Y坐标。*/
		public var mouseY:Number = 0;
		/** 是否禁用除 stage 以外的鼠标事件检测。*/
		public var disableMouseEvent:Boolean = false;
		/** 鼠标按下的时间。单位为毫秒。*/
		public var mouseDownTime:Number = 0;
		/** @private */
		private static var _isTouchRespond:Boolean;
		public var _event:Event = new Event();
		private var _matrix:Matrix = new Matrix();
		private var _point:Point = new Point();
		private var _rect:Rectangle = new Rectangle();
		private var _target:*;
		private var _lastOvers:Array = [];
		private var _currOvers:Array = [];
		private var _lastClickTimer:Number = 0;
		private var _lastMoveTimer:Number = 0;
		private var _isDoubleClick:Boolean = false;
		private var _isLeftMouse:Boolean;
		private var _eventList:Array = [];
		
		/**
		 * @private
		 * 初始化。
		 */
		public function __init__(canvas:*):void {
			var _this:DefaultInput = this;
			//var canvas:* = Render.canvas;
			var list:Array = _eventList;
			
			canvas.oncontextmenu = function(e:*):* {
				if (enabled) return false;
			}
			canvas.addEventListener('mousedown', function(e:*):void {
				if (enabled) {
					e.preventDefault();
					list.push(e);
					_this.mouseDownTime = Browser.now();
				}
			});
			canvas.addEventListener('mouseup', function(e:*):void {
				if (enabled) {
					e.preventDefault();
					list.push(e);
					_this.mouseDownTime = -Browser.now();
				}
			}, true);
			canvas.addEventListener('mousemove', function(e:*):void {
				if (enabled) {
					e.preventDefault();
					var now:Number = Browser.now();
					if (now - _this._lastMoveTimer < 10) return;
					_this._lastMoveTimer = now;
					list.push(e);
				}
			}, true);
			canvas.addEventListener("mouseout", function(e:*):void {
				if (enabled) list.push(e);
			})
			canvas.addEventListener("mouseover", function(e:*):void {
				if (enabled) list.push(e);
			})
			canvas.addEventListener("touchstart", function(e:*):void {
				if (enabled) {
					if(!Input.IOS_IFRAME) e.preventDefault();
					list.push(e);
					_this.mouseDownTime = Browser.now();
				}
			});
			canvas.addEventListener("touchend", function(e:*):void {
				if (enabled) {
					if(!Input.IOS_IFRAME) e.preventDefault();
					list.push(e);
					_this.mouseDownTime = -Browser.now();
				}
			}, true);
			canvas.addEventListener("touchmove", function(e:*):void {
				if (enabled) {
					e.preventDefault();
					list.push(e);
				}
			}, true);
			canvas.addEventListener('mousewheel', function(e:*):void {
				if (enabled) list.push(e);
			});
			canvas.addEventListener('DOMMouseScroll', function(e:*):void {
				if (enabled) list.push(e);
			});
		}
		
		private function initEvent(e:*, nativeEvent:* = null):void {
			var _this:DefaultInput = this;
			
			_this._event._stoped = false;
			_this._event.nativeEvent = nativeEvent || e;
			_this._target = null;
			
			_point.setTo(e.clientX, e.clientY);
			
			_this.mouseX = _point.x;
			_this.mouseY = _point.y;
			_this._event.touchId = e.identifier;
			
			_this._event.mouseX = _point.x;
			_this._event.mouseY = _point.y;
		}
		
		private function checkMouseWheel(e:*):void {
			_event.delta = e.wheelDelta ? e.wheelDelta * 0.025 : -e.detail;
			for (var i:int = 0, n:int = _lastOvers.length; i < n; i++) {
				var ele:* = _lastOvers[i];
				ele.event(Event.MOUSE_WHEEL, _event.setTo(Event.MOUSE_WHEEL, ele, _target));
			}
		}
		
		private function checkMouseOut():void {
			if (disableMouseEvent) return;
			for (var i:int = 0, n:int = _lastOvers.length; i < n; i++) {
				var ele:* = _lastOvers[i];
				if (!ele.destroyed && _currOvers.indexOf(ele) < 0) {
//					ele._set$P("$_MOUSEOVER", false);
					ele.event(Event.MOUSE_OUT, _event.setTo(Event.MOUSE_OUT, ele, _target));
				}
			}
			var temp:Array = _lastOvers;
			_lastOvers = _currOvers;
			_currOvers = temp;
			_currOvers.length = 0;
		}
		
		private function onMouseMove(ele:*):void {
			sendMouseMove(ele);
			_event._stoped = false;
			sendMouseOver(_target);
		}
		
		private function sendMouseMove(ele:*):void {
			ele.event(Event.MOUSE_MOVE, _event.setTo(Event.MOUSE_MOVE, ele, _target));
			!_event._stoped && ele.parent && sendMouseMove(ele.parent);
		}
		
		private function sendMouseOver(ele:*):void {
			if (ele.parent) {
//				if (!ele._get$P("$_MOUSEOVER")) {
//					ele._set$P("$_MOUSEOVER", true);
					ele.event(Event.MOUSE_OVER, _event.setTo(Event.MOUSE_OVER, ele, _target));
//				}
				_currOvers.push(ele);
			}
			!_event._stoped && ele.parent && sendMouseOver(ele.parent);
		}
		
		private function onMouseDown(ele:*):void {
			if (_isLeftMouse) {
//				ele._set$P("$_MOUSEDOWN", true);
				ele.event(Event.MOUSE_DOWN, _event.setTo(Event.MOUSE_DOWN, ele, _target));
			} else {
//				ele._set$P("$_RIGHTMOUSEDOWN", true);
				ele.event(Event.RIGHT_MOUSE_DOWN, _event.setTo(Event.RIGHT_MOUSE_DOWN, ele, _target));
			}
			!_event._stoped && ele.parent && onMouseDown(ele.parent);
		}
		
		private function onMouseUp(ele:*):void {
			var type:String = _isLeftMouse ? Event.MOUSE_UP : Event.RIGHT_MOUSE_UP;
			sendMouseUp(ele, type);
			_event._stoped = false;
			sendClick(_target, type);
		}
		
		private function sendMouseUp(ele:*, type:String):void {
			ele.event(type, _event.setTo(type, ele, _target));
			!_event._stoped && ele.parent && sendMouseUp(ele.parent, type);
		}
		
		private function sendClick(ele:*, type:String):void {
			if (ele.destroyed) return;
			if (type === Event.MOUSE_UP) {
//				ele._set$P("$_MOUSEDOWN", false);
				ele.event(Event.CLICK, _event.setTo(Event.CLICK, ele, _target));
				_isDoubleClick && ele.event(Event.DOUBLE_CLICK, _event.setTo(Event.DOUBLE_CLICK, ele, _target));
			} else if (type === Event.RIGHT_MOUSE_UP) {
//				ele._set$P("$_RIGHTMOUSEDOWN", false);
				ele.event(Event.RIGHT_CLICK, _event.setTo(Event.RIGHT_CLICK, ele, _target));
			}
			!_event._stoped && ele.parent && sendClick(ele.parent, type);
		}

		private function check(sp:*, mouseX:Number, mouseY:Number, callBack:Function):Boolean {
			_target = this;
			callBack.call(this, _target);
			return true;
		}
		
		/**
		 * 执行事件处理。
		 */
		public function runEvent():void {
			var len:int = _eventList.length;
			if (!len) return;
			
			var _this:DefaultInput = this;
			var i:int = 0;
			while (i < len) {
				var evt:* = _eventList[i];
				switch (evt.type) {
					case 'mousedown': 
						if (!_isTouchRespond)
						{
							_this._isLeftMouse = evt.button === 0;
							_this.initEvent(evt);
							_this.check(_this, _this.mouseX, _this.mouseY, _this.onMouseDown);
						}
						else
							_isTouchRespond = false;
						break;
					case 'mouseup': 
						_this._isLeftMouse = evt.button === 0;
						var now:Number = Browser.now();
						_this._isDoubleClick = (now - _this._lastClickTimer) < 300;
						_this._lastClickTimer = now;
						
						_this.initEvent(evt);
						_this.check(_this, _this.mouseX, _this.mouseY, _this.onMouseUp);
						break;
					case 'mousemove': 
						_this.initEvent(evt);
						_this.check(_this, _this.mouseX, _this.mouseY, _this.onMouseMove);
						_this.checkMouseOut();
						break;
					case "touchstart": 
						_isTouchRespond = true;
						_this._isLeftMouse = true;
						var touches:Array = evt.changedTouches;
						for (var j:int = 0, n:int = touches.length; j < n; j++) {
							_this.initEvent(touches[j], evt);
							_this.check(_this, _this.mouseX, _this.mouseY, _this.onMouseDown);
						}
						break;
					case "touchend": 
						_isTouchRespond = true;
						_this._isLeftMouse = true;
						now = Browser.now();
						_this._isDoubleClick = (now - _this._lastClickTimer) < 300;
						_this._lastClickTimer = now;
						
						var touchends:Array = evt.changedTouches;
						for (j = 0, n = touchends.length; j < n; j++) {
							_this.initEvent(touchends[j], evt);
							_this.check(_this, _this.mouseX, _this.mouseY, _this.onMouseUp);
						}
						break;
					case "touchmove": 
						var touchemoves:Array = evt.changedTouches;
						for (j = 0, n = touchemoves.length; j < n; j++) {
							_this.initEvent(touchemoves[j], evt);
							_this.check(_this, _this.mouseX, _this.mouseY, _this.onMouseMove);
						}
						_this.checkMouseOut();
						break;
					case "wheel": 
					case "mousewheel": 
					case "DOMMouseScroll": 
						_this.checkMouseWheel(evt);
						break;
					case "mouseout": 
						_this.event(Event.MOUSE_OUT, _this._event.setTo(Event.MOUSE_OUT, _this, _this));
						break;
					case "mouseover": 
						_this.event(Event.MOUSE_OVER, _this._event.setTo(Event.MOUSE_OVER, _this, _this));
						break;
				}
				i++;
			}
			_eventList.length = 0;
		}
	}
}


