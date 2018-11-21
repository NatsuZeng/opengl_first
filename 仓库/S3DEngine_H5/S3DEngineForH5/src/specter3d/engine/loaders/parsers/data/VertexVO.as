package specter3d.engine.loaders.parsers.data
{
	import specter3d.engine.core.geom.Vector3D;

	public class VertexVO
	{
		public var x:Number;
		public var y:Number;
		public var z:Number;
		public var u:Number;
		public var v:Number;
		public var normal:Vector3D;
		public var tangent:Vector3D;
		public var materialId:uint; // 分解材质后，该顶点的唯一材质id
	}
}