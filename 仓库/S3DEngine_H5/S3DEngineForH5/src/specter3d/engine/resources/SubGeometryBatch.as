package specter3d.engine.resources
{
	import specter3d.engine.specter3d;

	use namespace specter3d;
	
	/**
	 * 合并SubGeometry，暂时只有场景灯用到 
	 */	
	public class SubGeometryBatch extends SubGeometry3D
	{		
		public function SubGeometryBatch()
		{
		}	
		
		specter3d function set vertexBufferDirty(value:Boolean):void { _vertexBufferDirty = value; }
		specter3d function set uvBufferDirty(value:Boolean):void { _uvBufferDirty = value; }
		specter3d function set vertexColorBufferDirty(value:Boolean):void { _vertexColorBufferDirty = value; }
		
		public function batchVertices(source:Vector.<Number>, startIndex:int):void
		{
			for each(var v:Number in source)
			{
				_vertices[startIndex++] = v;
			}
			_vertexBufferDirty = true;
			_numVertices = _vertices.length / 3;
		}
		
		public function batchUVs(source:Vector.<Number>, startIndex:int):void
		{
			for each(var v:Number in source)
			{
				_uvs[startIndex++] = v;
			}
			_uvBufferDirty = true;
		}
		
		public function batchColors(source:Vector.<Number>, startIndex:int):void
		{
			for each(var v:Number in source)
			{
				_verticesColor[startIndex++] = v;
			}
			_vertexColorBufferDirty = true;
		}
		
		public function batchIndexs(source:Vector.<uint>, startIndex:int, addIndex:uint):void
		{
			for each(var v:uint in source)
			{
				_indices[startIndex++] = v + addIndex;
			}
			_indexBufferDirty = true;
			_numIndices = _indices.length;
			_numTriangles = _numIndices / 3;
		}
		
		public function clearBatch():void
		{
			_vertices.length = 0;
			_uvs.length = 0;
			_verticesColor.length = 0;
			_indices.length = 0;
			
			_numIndices = 0;
			_numTriangles = 0;
			_numVertices = 0;
		}
	}
}