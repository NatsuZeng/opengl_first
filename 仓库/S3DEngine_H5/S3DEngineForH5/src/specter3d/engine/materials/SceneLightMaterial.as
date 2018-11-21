/*
 *	场景灯光(lightmap)用的材质
 */
package specter3d.engine.materials
{
	import specter3d.engine.specter3d;
	import specter3d.engine.resources.BitmapTexture;
	
	use namespace specter3d;
	
	public class SceneLightMaterial extends Material3D
	{
		private var _lightMapTexture : BitmapTexture;
				
		public function SceneLightMaterial(value : BitmapTexture)
		{
			if (value == bitmapData) return;
			
			if(_lightMapTexture)
			{
				BitmapTextureCache.instance().freeTexture(_lightMapTexture);
				_lightMapTexture = null
			}
			
			_lightMapTexture = BitmapTextureCache.instance().getTexture(value);
			
			_lightMapPass.lightMapTexture = _lightMapTexture;
		}
		
		override public function dispose() : void
		{
			super.dispose();
		}

		override public function canBatch(other:Material3D):Boolean
		{
			if ((other is SceneLightMaterial) &&
				(other as SceneLightMaterial)._lightMapTexture == _lightMapTexture)
				return true;	// 贴图一样，可以合并批
			
			return super.canBatch(other);
		}
		
	}	// class
} // package