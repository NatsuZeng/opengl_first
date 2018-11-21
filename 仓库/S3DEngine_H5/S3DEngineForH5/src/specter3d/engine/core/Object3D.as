package specter3d.engine.core
{
	import laya.events.EventDispatcher;
	import laya.webgl.WebGLContext;
	
	import specter3d.engine.specter3d;
	import specter3d.engine.core.camera.Camera3D;
	import specter3d.engine.core.geom.Matrix3D;
	import specter3d.engine.core.geom.Vector3D;
	import specter3d.engine.core.render.data.DrawUnit;
	import specter3d.engine.events.Event3D;
	import specter3d.engine.interfaces.IRenderUpdate;
	import specter3d.engine.utlis.Matrix3DUtils;

	use namespace specter3d;
	/**
	 * Object3D 类是可放在显示列表中的所有对象的基类。
	 * @author wangcx
	 *
	 */
	public class Object3D extends EventDispatcher implements IRenderUpdate
	{
		/**
		 * Create Object3D
		 */
		public function Object3D()
		{
			super();
			_transform=new Transform3D(this);
		}

		public var name:String;
		public var visible:Boolean = true;

		specter3d var _childrenList:Object3D;
		specter3d var _isRoot:Boolean;
		specter3d var _next:Object3D;
		specter3d var _parent:Object3D;

		private var _transform:Transform3D;

		/**
		 * 将一个 Object3D 子实例添加到该 Object3D 实例中。
		 * @param child
		 * @return
		 *
		 */
		public function addChild(child:Object3D):Object3D
		{
			if (child == null)
				throw new Error("Parameter child must be non-null.");
			if (child == this)
				throw new Error("An object cannot be added as a child of itself.");
			for (var container:Object3D=_parent; container != null; container=container._parent)
			{
				if (container == child)
					throw new Error("An object cannot be added as a child to one of it's children (or children's children, etc.).");
			}

			if (child._parent != this)
			{
				if (child._parent != null)
					child._parent.removeChild(child);
				addToList(child);
				child._parent=this;
				transform.updateTransforms(true);
				if (child.hasListener(Event3D.ADDED))
					child.event(Event3D.ADDED, true);
			}
			else
			{
				child=removeFromList(child);
				if (child == null)
					throw new Error("Cannot add child.");
				addToList(child);
			}
			return child;
		}

		/**
		 * 将一个 Object3D 子实例添加到该 Object3D 实例中。该子项将被添加到指定的索引位置。索引为 0 表示该 Object3D 对象的显示列表的后（底）部。
		 * @param child
		 * @param index
		 * @return
		 *
		 */
		public function addChildAt(child:Object3D, index:int):Object3D
		{
			if (child == null)
				throw new Error("Parameter child must be non-null.");
			if (child == this)
				throw new Error("An object cannot be added as a child of itself.");
			if (index < 0)
				throw new Error("The supplied index is out of bounds.");
			for (var container:Object3D=_parent; container != null; container=container._parent)
			{
				if (container == child)
					throw new Error("An object cannot be added as a child to one of it's children (or children's children, etc.).");
			}
			var current:Object3D=_childrenList;
			for (var i:int=0; i < index; i++)
			{
				if (current == null)
					throw new Error("The supplied index is out of bounds.");
				current=current._next;
			}
			if (child._parent != this)
			{
				if (child._parent != null)
					child._parent.removeChild(child);
				addToList(child, current);
				child._parent=this;
				transform.updateTransforms(true);
				if (child.hasListener(Event3D.ADDED))
					child.event(Event3D.ADDED, true);
			}
			else
			{
				child=removeFromList(child);
				if (child == null)
					throw new Error("Cannot add child.");
				addToList(child, current);
			}
			return child;
		}

		public function clone():Object3D
		{
			var res:Object3D=new Object3D();
			res._transform=this._transform.clone(res);
			res.clonePropertiesFrom(this);
			return res;
		}

		/**
		 * 确定指定显示对象是 Object3D 实例的子项还是该实例本身。
		 * @param child
		 * @return
		 *
		 */
		public function contains(child:Object3D):Boolean
		{
			if (child == null)
				throw new Error("Parameter child must be non-null.");
			if (child == this)
				return true;
			for (var object:Object3D=_childrenList; object != null; object=object._next)
			{
				if (object.contains(child))
					return true;
			}
			return false;
		}

		public function dispose():void
		{
			for (var child:Object3D=_childrenList, lastChild:Object3D; child != null; child=child._next)
			{
				child.dispose();
			}
		}

		/**
		 * 返回位于指定索引处的子显示对象实例。
		 * @param index
		 * @return
		 *
		 */
		public function getChildAt(index:int):Object3D
		{
			if (index < 0)
				throw new Error("The supplied index is out of bounds.");
			var current:Object3D=_childrenList;
			for (var i:int=0; i < index; i++)
			{
				if (current == null)
					throw new Error("The supplied index is out of bounds.");
				current=current._next;
			}
			if (current == null)
				throw new Error("The supplied index is out of bounds.");
			return current;
		}

		/**
		 * 返回位于指定名称的子显示对象实例。
		 * @param name
		 * @return
		 *
		 */
		public function getChildByName(name:String):Object3D
		{
			if (name == null)
				throw new Error("Parameter name must be non-null.");
			for (var child:Object3D=_childrenList; child != null; child=child._next)
			{
				if (child.name == name)
					return child;
			}
			return null;
		}

		/**
		 * 返回 Object3D 的 child 实例的索引位置。
		 * @param child
		 * @return
		 *
		 */
		public function getChildIndex(child:Object3D):int
		{
			if (child == null)
				throw new Error("Parameter child must be non-null.");
			if (child._parent != this)
				throw new Error("The supplied Object3D must be a child of the caller.");
			var index:int=0;
			for (var current:Object3D=_childrenList; current != null; current=current._next)
			{
				if (current == child)
					return index;
				index++;
			}
			throw new Error("Cannot get child index.");
		}

		/**
		 * 返回此对象的子项数目。
		 * @return
		 *
		 */
		public function get numChildren():int
		{
			var num:int=0;
			for (var current:Object3D=_childrenList; current != null; current=current._next)
				num++;
			return num;
		}

		public function get parent():Object3D
		{
			return _parent;
		}

		/**
		 * 从 Object3D 实例的子列表中删除指定的 child Object3D 实例
		 * @param child
		 * @return
		 *
		 */
		public function removeChild(child:Object3D):Object3D
		{
			if (child == null)
				throw new Error("Parameter child must be non-null.");
			if (child._parent != this)
				throw new Error("The supplied Object3D must be a child of the caller.");
			child=removeFromList(child);
			if (child == null)
				throw new Error("Cannot remove child.");
			if (child.hasListener(Event3D.REMOVED))
				child.event(Event3D.REMOVED, true);
			child._parent=null;
			transform.updateTransforms(true);
			return child;
		}

		/**
		 * 从 Object3D 的子列表中指定的 index 位置删除子 Object3D。
		 * @param index
		 * @return
		 *
		 */
		public function removeChildAt(index:int):Object3D
		{
			if (index < 0)
				throw new Error("The supplied index is out of bounds.");
			var child:Object3D=_childrenList;
			for (var i:int=0; i < index; i++)
			{
				if (child == null)
					throw new Error("The supplied index is out of bounds.");
				child=child._next;
			}
			if (child == null)
				throw new Error("The supplied index is out of bounds.");
			removeFromList(child);
			if (child.hasListener(Event3D.REMOVED))
				child.event(Event3D.REMOVED, true);
			child._parent=null;
			transform.updateTransforms(true);
			return child;
		}

		/**
		 * 从 Object3D 实例的子级列表中删除所有子 Object3D 实例。
		 * @param beginIndex
		 * @param endIndex
		 *
		 */
		public function removeChildren(beginIndex:int=0, endIndex:int=2147483647):void
		{
			if (beginIndex < 0)
				throw new Error("The supplied index is out of bounds.");
			if (endIndex < beginIndex)
				throw new Error("The supplied index is out of bounds.");
			var i:int=0;
			var prev:Object3D=null;
			var begin:Object3D=_childrenList;
			while (i < beginIndex)
			{
				if (begin == null)
				{
					if (endIndex < 2147483647)
					{
						throw new Error("The supplied index is out of bounds.");
					}
					else
					{
						return;
					}
				}
				prev=begin;
				begin=begin._next;
				i++;
			}
			if (begin == null)
			{
				if (endIndex < 2147483647)
				{
					throw new Error("The supplied index is out of bounds.");
				}
				else
				{
					return;
				}
			}
			var end:Object3D=null;
			if (endIndex < 2147483647)
			{
				end=begin;
				while (i <= endIndex)
				{
					if (end == null)
						throw new Error("The supplied index is out of bounds.");
					end=end._next;
					i++;
				}
			}
			if (prev != null)
			{
				prev._next=end;
			}
			else
			{
				_childrenList=end;
			}
			while (begin != end)
			{
				var next:Object3D=begin._next;
				begin._next=null;
				if (begin.hasListener(Event3D.REMOVED))
					begin.event(Event3D.REMOVED, true);
				begin._parent=null;
				begin=next;
			}
			transform.updateTransforms(true);
		}

		public function get transform():Transform3D
		{
			return _transform;
		}

		public function update(time:Number, dt:Number=0):void
		{
			for (var current:Object3D=_childrenList; current != null; current=current._next)
			{
				current.update(time, dt);
			}
		}

		/**
		 * 克隆屬性列表
		 * @param source
		 *
		 */
		protected function clonePropertiesFrom(source:Object3D):void
		{
			var _source:Object3D=source as Object3D;
			if (_source != null)
			{
				for (var child:Object3D=_source._childrenList, lastChild:Object3D; child != null; child=child._next)
				{
					var newChild:Object3D=child.clone() as Object3D;
					if (_childrenList != null)
					{
						lastChild._next=newChild;
					}
					else
					{
						_childrenList=newChild;
					}
					lastChild=newChild;
					newChild._parent=this;
				}
			}
		}

		private function addToList(child:Object3D, item:Object3D=null):void
		{
			child._next=item;
			if (item == _childrenList)
			{
				_childrenList=child;
			}
			else
			{
				for (var current:Object3D=_childrenList; current != null; current=current._next)
				{
					if (current._next == item)
					{
						current._next=child;
						break;
					}
				}
			}
		}

		/**
		 * @private
		 */
		private function removeFromList(child:Object3D):Object3D
		{
			var prev:Object3D;
			for (var current:Object3D=_childrenList; current != null; current=current._next)
			{
				if (current == child)
				{
					if (prev != null)
					{
						prev._next=current._next;
					}
					else
					{
						_childrenList=current._next;
					}
					current._next=null;
					return child;
				}
				prev=current;
			}
			return null;
		}
		
		/** 朝向一个目标 */
		public function lookAt(target:Vector3D, upAxis:Vector3D=null):void
		{
			var matrix:Matrix3D = transform.world;
			Matrix3DUtils.lookAt(matrix, target.x, target.y, target.z, Vector3D.Y_AXIS);
			transform.world = matrix;
		}
		
		/**
		 * 收集要渲染的对象添加到渲染队列 
		 * @param camera
		 * @param _context3d
		 * @param _renderUnits
		 * 
		 */		
		specter3d function collectRender(camera:Camera3D,_context3d:WebGLContext,_renderUnits:Vector.<DrawUnit>):void
		{
			if(this.visible)
			{
				for (var current:Object3D=_childrenList; current != null; current=current._next)
				{
					current.collectRender(camera,_context3d,_renderUnits);
				}
			}
		}
	}
}
