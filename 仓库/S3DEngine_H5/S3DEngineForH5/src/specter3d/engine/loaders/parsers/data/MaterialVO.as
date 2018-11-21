package specter3d.engine.loaders.parsers.data
{
	import specter3d.engine.materials.Material3D;

	public class MaterialVO
	{
		public var name:String; // 材质名
		public var ambientColor:uint;
		public var diffuseColor:uint;
		public var specularColor:uint;
		public var twoSided:Boolean;
		public var colorMap:TextureVO;
		public var specularMap:TextureVO;
		public var material:Material3D;
	}
}