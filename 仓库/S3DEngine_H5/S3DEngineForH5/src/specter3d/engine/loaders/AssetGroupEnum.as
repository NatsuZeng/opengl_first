package specter3d.engine.loaders
{

	/**
	 * 资源分组枚举值定义
	 * @author wangcx
	 *
	 */
	public class AssetGroupEnum
	{
		/**
		 * 默认资源组（常驻内存永不释放）
		 */
		public static const DEFAULT_GROUP:String="default_group";
		
		/**
		 * 场景资源组(游戏在切换场景时释放)
		 */
		public static const SCENE_GROUP:String="scene_group";

		/**
		 * 存放3D特效资源（游戏在切换场景时释放）
		 */
		public static const EFFECT_GROUP:String="effect_group";
		
		/**
		 * UI Root资源组 存放公共的UI资源（常驻内存永不释放）
		 */
		public static const UI_ROOT_GROUP:String="ui_root_group";
		
		/**
		 * Temp UI资源组 存放外载的公共图片、ICON等（根据需求释放）
		 */
		public static const TEMP_UI_GROUP:String="temp_ui_group";
	}
}
