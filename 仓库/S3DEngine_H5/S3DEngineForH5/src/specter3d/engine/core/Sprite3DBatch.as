package specter3d.engine.core
{
	import specter3d.engine.specter3d;
	import specter3d.engine.materials.Material3D;
	import specter3d.engine.resources.SubGeometry3D;

	use namespace specter3d;

	/**
	 * 贴图灯合并
	 */
	public class Sprite3DBatch extends Sprite3D
	{
		private var _spriteCount:int = 0;	// 灯的数量
		private var _sprites:Vector.<Sprite3D> = new Vector.<Sprite3D>;	// 本批内的所有灯
		private var _bufferDirty:Boolean = false;	// 当灯有增删时buffer需要重建
		
		public function Sprite3DBatch( material:Material3D, width:Number, height:Number)
		{
			super(material, width, height);
			_geometry.clearBatch();
		}
		
		override public function dispose():void
		{
			_sprites.length = 0;
			super.dispose();
		}
		
		public function get spriteCount():int
		{
			return _spriteCount;
		}
		
		override public function get material():Material3D
		{
			return _sprites[0].material;
		}
		
		public function canBatch(sprite3D:Sprite3D):Boolean
		{
			if (_spriteCount == 0)
				return true;
			
			if (material.canBatch(sprite3D.material))
				return true;
			
			return false;
		}
		
		public function addSprite(sprite:Sprite3D):void
		{
			sprite._parentBatch = this;
			sprite._indexInBatch = _spriteCount;
			_bufferDirty = true;
			
			_sprites[_spriteCount++] = sprite;
		}
		
		public function removeSprite(sprite:Sprite3D):void
		{
			if (sprite._parentBatch != this)
				return;
			
			_sprites.splice(sprite._indexInBatch, 1);
			_spriteCount--;
			_bufferDirty = true;
			
			sprite._indexInBatch = -1;
			sprite._parentBatch = null;
			sprite._batched = false;
		}
		
		public function batchAll():void
		{			
			if (_bufferDirty)
			{
				clearBatch();
				rebuildIndex();
				_bufferDirty = false;
			}
			
			for (var i:int = 0; i < _spriteCount; i++)
			{
				batch(_sprites[i]);
			}
		}
		
		private function reset():void
		{
			clearBatch();
			clearSprites();			
			
			_spriteCount = 0;
			_sprites.length = 0;
			_bufferDirty = false;
		}
		
		private function clearBatch():void
		{
			_geometry.clearBatch();
			_geometry.disposeGpuBuffer();
		}
		
		private function clearSprites():void
		{
			for each (var sprite:Sprite3D in _sprites)
			{
				sprite._indexInBatch = -1;
				sprite._parentBatch = null;
				sprite._batched = false;
			}
		}
		
		private function rebuildIndex():void
		{
			for (var i:int = 0; i < _spriteCount; i++)
			{
				var sprite:Sprite3D = _sprites[i];
				sprite._indexInBatch = i;	// 更新在批内的索引位置 
				sprite._batched = false;		// 需要重新合并到批
			}
		}
		
		private function batch(sprite:Sprite3D):void
		{
			var geometry2:SubGeometry3D = sprite._geometry;
			var index:int = sprite._indexInBatch;
			
			// 合并顶点位置
			if (sprite._vertexTransformDirty || !sprite._batched)
			{
				sprite.updateLightVertices();
				_geometry.batchVertices(geometry2.vertexData, index * 12);
			}
			
			// 合并uv坐标
			if (sprite._uvTransformDirty || !sprite._batched)
			{
				sprite.updateLightUVs();
				_geometry.batchUVs(geometry2.UVData, index * 8);
			}
			
			// 合并顶点色即灯光颜色
			if (sprite._colorTransformDirty || !sprite._batched)
			{
				sprite.updateLightColors();
				_geometry.batchColors(geometry2.vertexColorData, index * 16);
			}
			
			// 合并index
			if (!sprite._batched)
			{
				_geometry.batchIndexs(geometry2.indexData, index * 6, index * 4);
				sprite._batched = true;
			}
		}

		///////////////////////// 缓存池 ////////////////////////
		public static function createBatch():Sprite3DBatch
		{
			if (sPoolIndex > 0)
			{
				sPoolIndex--;
				return sPool.pop();
			}
			return new Sprite3DBatch(null, 1, 1);
		}
		
		public static function freeBatch(batch:Sprite3DBatch):void
		{
			batch.reset();
			sPool[sPoolIndex++] = batch;
		}
		
		private static var sPool:Vector.<Sprite3DBatch> = new Vector.<Sprite3DBatch>;
		private static var sPoolIndex:int = 0;
	}
}