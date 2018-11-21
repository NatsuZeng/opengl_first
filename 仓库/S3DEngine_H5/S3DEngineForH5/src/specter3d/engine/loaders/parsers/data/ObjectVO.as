package specter3d.engine.loaders.parsers.data
{
	public class ObjectVO
	{
		public var name:String;
		public var type:String;
		public var pivotX:Number;
		public var pivotY:Number;
		public var pivotZ:Number;
		public var transform:Float32Array;
		public var verts:Vector.<Number>;
		public var indices:Vector.<uint>;
		public var uvs:Vector.<Number>;
		public var materialFaces:Object; // 材质<->面列表
		public var materials:Vector.<String>;
		public var smoothingGroups:Vector.<uint>;
	}
}