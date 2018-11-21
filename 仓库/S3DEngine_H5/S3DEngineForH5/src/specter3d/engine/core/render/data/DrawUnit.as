package specter3d.engine.core.render.data
{
	import specter3d.engine.specter3d;
	import specter3d.engine.core.Transform3D;
	import specter3d.engine.materials.Material3D;
	import specter3d.engine.resources.SubGeometry3D;

	use namespace specter3d;
	/**
	 * 渲染单元
	 * @author wangcx
	 *
	 */
	public class DrawUnit
	{
		/**
		 * 灯光 
		 */		
		public static const LIGHT_UNIT:int = 0;
		
		/**
		 * surface
		 */		
		public static const SURFACE_UNIT:int = 1;
		
		/**
		 * surface
		 */		
		public static const SKYBOX_UNIT:int = 2;
		
		private var _type:int;
		
		public function DrawUnit(type:int)
		{
			this._type = type;
		}
		
		public function get type():int
		{
			return this._type;
		}

		public function get subGeometry():SubGeometry3D
		{
			return null;
		}
		
		public function get material():Material3D
		{
			// TODO Auto Generated method stub
			return null;
		}

		public function set material(value:Material3D):void
		{
			// TODO Auto Generated method stub
		}
		
		public function get transform():Transform3D
		{
			return null;
		}
	}
}
