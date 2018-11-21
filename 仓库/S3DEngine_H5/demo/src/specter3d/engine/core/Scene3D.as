package specter3d.engine.core
{
	import laya.events.EventDispatcher;
	
	import specter3d.engine.sprite3d;

	use namespace sprite3d;
	/**
	 * 3D 场景 
	 * @author 回眸笑苍生
	 * 
	 */	
	public class Scene3D extends EventDispatcher
	{
		public static const SCENE_DEFAULT_NAME:String="default_scene3d";
		
		public function Scene3D(name:String=null)
		{
			_rootContainer3D=new Object3D;
			_rootContainer3D._isRoot=true;
			this._name=name||=SCENE_DEFAULT_NAME;
		}
		
		private var _name:String;
		/**
		 * 根容器
		 */
		sprite3d var _rootContainer3D:Object3D;
		/**
		 * 将一个 Object3D 子实例添加到该 Object3D 实例中。
		 * @param child
		 * @return
		 *
		 */
		public function addChild(child:Object3D):Object3D
		{
			return _rootContainer3D.addChild(child);
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
			return _rootContainer3D.addChildAt(child, index);
		}
		
		/**
		 * 确定指定显示对象是 Object3D 实例的子项还是该实例本身。
		 * @param child
		 * @return
		 *
		 */
		public function contains(child:Object3D):Boolean
		{
			return _rootContainer3D.contains(child);
		}
		
		/**
		 * 返回位于指定索引处的子显示对象实例。
		 * @param index
		 * @return
		 *
		 */
		public function getChildAt(index:int):Object3D
		{
			return _rootContainer3D.getChildAt(index);
		}
		
		/**
		 * 返回位于指定名称的子显示对象实例。
		 * @param name
		 * @return
		 *
		 */
		public function getChildByName(name:String):Object3D
		{
			return _rootContainer3D.getChildByName(name);
		}
		
		/**
		 * 返回 Object3D 的 child 实例的索引位置。
		 * @param child
		 * @return
		 *
		 */
		public function getChildIndex(child:Object3D):int
		{
			return _rootContainer3D.getChildIndex(child);
		}
		
		public function get name():String
		{
			return _name;
		}
		
		/**
		 * 返回此对象的子项数目。
		 * @return
		 *
		 */
		public function get numChildren():int
		{
			return _rootContainer3D.numChildren;
		}
		
		/**
		 * 从 Object3D 实例的子列表中删除指定的 child Object3D 实例
		 * @param child
		 * @return
		 *
		 */
		public function removeChild(child:Object3D):Object3D
		{
			return _rootContainer3D.removeChild(child);
		}
		
		/**
		 * 从 Object3D 的子列表中指定的 index 位置删除子 Object3D。
		 * @param index
		 * @return
		 *
		 */
		public function removeChildAt(index:int):Object3D
		{
			return _rootContainer3D.removeChildAt(index);
		}
		
		/**
		 * 从 Object3D 实例的子级列表中删除所有子 Object3D 实例。
		 * @param beginIndex
		 * @param endIndex
		 *
		 */
		public function removeChildren(beginIndex:int=0, endIndex:int=2147483647):void
		{
			_rootContainer3D.removeChildren(beginIndex, endIndex);
		}
		
		/**
		 * 销毁对象 
		 * 
		 */		
		public function dispose():void
		{
			_rootContainer3D.dispose();
		}
	}
}