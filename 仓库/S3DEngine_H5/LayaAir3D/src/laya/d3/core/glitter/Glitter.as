package laya.d3.core.glitter {
	import laya.d3.core.Sprite3D;
	import laya.d3.core.render.IRenderable;
	import laya.d3.core.render.RenderObject;
	import laya.d3.core.render.RenderQueue;
	import laya.d3.core.render.RenderState;
	import laya.d3.resource.tempelet.GlitterTemplet;
	import laya.display.Node;
	
	/**
	 * <code>Glitter</code> 类用于创建闪光。
	 */
	public class Glitter extends Sprite3D {
		/** @private */
		private var _templet:GlitterTemplet;
		/** @private */
		private var _renderObject:RenderObject;
		
		/**
		 * 获取闪光模板。
		 * @return 闪光模板。
		 */
		public function get templet():GlitterTemplet {
			return _templet;
		}
		
		override public function _clearSelfRenderObjects():void {
			_renderObject.renderQneue.deleteRenderObj(_renderObject);
		}
		
		/**
		 * 创建一个 <code>Glitter</code> 实例。
		 *  @param	settings 配置信息。
		 */
		public function Glitter(settings:GlitterSettings) {
			_templet = new GlitterTemplet(settings);
		}
		
		/**
		 * @private
		 * 更新闪光。
		 * @param	state 渲染状态参数。
		 */
		public override function _update(state:RenderState):void {
			
			state.owner = this;
			
			if (active) {
				if (_renderObject) {
					var renderQueueIndex:int;
					renderQueueIndex = RenderQueue.DEPTHREAD_ALPHA_BLEND_DOUBLEFACE;
					
					var renderQueue:RenderQueue = state.scene.getRenderQueue(renderQueueIndex);
					if (_renderObject.renderQneue != renderQueue) {
						_renderObject.renderQneue.deleteRenderObj(_renderObject);
						_renderObject = _addRenderObject(state, renderQueueIndex);
					}
				} else {
					_renderObject = _addRenderObject(state, renderQueueIndex);
				}
			} else {
				_clearSelfRenderObjects();
			}
			
			_childs.length && _updateChilds(state);
		}
		
		private function _addRenderObject(state:RenderState, renderQueueIndex:int):RenderObject {
			var renderObj:RenderObject = state.scene.getRenderObject(renderQueueIndex);
			_renderObject = renderObj;
			
			var renderElement:IRenderable = templet;
			renderObj.mainSortID = 0;//根据MeshID排序，处理同材质合并处理。
			renderObj.triangleCount = renderElement.triangleCount;
			renderObj.owner = state.owner;
			
			renderObj.renderElement = renderElement;
			renderObj.material = null;
			return renderObj;
		}
	}
}