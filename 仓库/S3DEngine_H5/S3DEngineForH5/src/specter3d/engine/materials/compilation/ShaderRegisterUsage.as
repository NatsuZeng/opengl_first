package specter3d.engine.materials.compilation
{

	public class ShaderRegisterUsage
	{
		// Macro Define
		public static const USE_MACRO_UV:String="USE_UV";
		public static const USE_MACRO_NORMAL:String="USE_NORMAL";
		public static const USE_MACRO_TANGENT:String="USE_TANGENT";
		public static const USE_MACRO_DIFFUSE_MAP:String="USE_DIFFUSE_MAP";
		public static const USE_MACRO_NORMAL_MAP:String="USE_NORMAL_MAP";
		public static const USE_MACRO_LIGHT_DIRECTION:String="USE_LIGHT_DIRECTION";
		public static const USE_MACRO_LIGHT_POINT:String="USER_LIGHT_POINT";
		// Basic properties
		public static const POSITION:String="a_Position";
		public static const NORMAL:String="a_Normal";
		public static const TANGENT:String="a_Tangent";
		public static const UV:String="a_UV";
		public static const SECONDARY_UV:String="a_SecondaryUV";

		// Matrix Define
		public static const MVP:String="u_MVPMatrix";

		//light Define
		public static const LIGHT_DIRECTION:String="u_DirectionLight";

		//texture Define
		public static const DIFFUSE_ALPHA:String = "u_DiffuseAlpha";
		public static const DIFFUSE_COLOR:String="u_DiffuseColor";
		public static const DIFFUSE_SAMPLER:String="u_DiffuseSampler";
		public static const NORMAL_MAP_SAMPLER:String="u_NormalMapSampler";
	}
}
