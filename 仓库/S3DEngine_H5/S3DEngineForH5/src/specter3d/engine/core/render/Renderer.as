package specter3d.engine.core.render
{
	import laya.webgl.WebGLContext;
	
	import specter3d.engine.specter3d;
	import specter3d.engine.core.Layer3D;
	import specter3d.engine.core.camera.Camera3D;
	import specter3d.engine.core.render.data.DrawUnit;

	use namespace specter3d;
	/**
	 * 渲染器
	 * @author wangcx
	 *
	 */
	public class Renderer
	{

		public function Renderer(_layer3d:Layer3D)
		{
			_camera3d=_layer3d.camera3d;
		}

		specter3d var _renderUnits:Vector.<DrawUnit>=new Vector.<DrawUnit>();

		private var _camera3d:Camera3D;

		public function clear():void
		{
			_renderUnits.length=0;
		}

		public function render(_context3d:WebGLContext):void
		{
			if (_context3d)
			{
				var _renderUnitsLength:int=_renderUnits.length;
				for (var i:int=0; i < _renderUnitsLength; i++)
				{
					var _renderUnit:DrawUnit=_renderUnits[i];
					if(_renderUnit.type == DrawUnit.LIGHT_UNIT)
					{
						// TODO 这里做视锥裁剪 平行光不做裁剪处理
					}
					else
					{
						if(!_renderUnit || !_renderUnit.material || !_renderUnit.subGeometry) return
						
						_renderUnit.material.activate(_renderUnit,_context3d,_camera3d);
						_context3d.drawElements(WebGLContext.TRIANGLES, _renderUnit.subGeometry.numTriangles * 3, WebGLContext.UNSIGNED_SHORT, 0);
					}
				}
			}
		}
	}
}
