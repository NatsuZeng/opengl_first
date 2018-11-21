/*
 *	渲染场景lightmap用的pass
 */
package specter3d.engine.materials.passes
{
	import laya.webgl.WebGLContext;
	
	import specter3d.engine.specter3d;
	import specter3d.engine.core.camera.Camera3D;
	import specter3d.engine.core.render.data.DrawUnit;
	import specter3d.engine.materials.Material3D;
	import specter3d.engine.materials.compilation.ShaderElementArray;
	import specter3d.engine.resources.BitmapTexture;
	
	use namespace specter3d;
	
	/**
	 * 场景灯渲染光照信息 
	 */	
	public class LightMapPass extends Material3DPass
	{
		private var _lightMapTexture : BitmapTexture;				// 光照贴图
		private var _constVector : Vector.<Number>;					// 常量

		public function LightMapPass(material:Material3D)
		{
			super(material);
			
			_constVector = Vector.<Number>([0.0, 0.0, 0.1, 0.0]);	//  fc0.z 没有贴图的渲染值
			
			// 贴图灯渲染设置
			_depthWrite = false;
			_depthCompareMode = Context3DCompareMode.ALWAYS;
		}
		
		public function set lightMapTexture(tex : BitmapTexture) : void
		{
			_lightMapTexture = tex;
		}
		
		/**
		 * va0	顶点位置(mvp变换后的最终位置) 
		 * va1	uv坐标(变换后的最终uv坐标)
		 * va2	光照颜色,w=强度
		 */
		
		// vertex shader 代码
		override protected function getVertexCode(_code:ShaderElementArray):ShaderElementArray
		{
			// vt0=va0是投影空间的坐标(乘MVP后的坐标)
//			coder.append(
//				"m44 vt1, va0, vc0\n" + // 顶点(cpu中已乘过m) * vp -> vt1
//				"mul op, vt1, vc4\n"	// 位置乘以textureRatioX, textureRatioY
//			);
//			
//			if(_lightMapTexture)
//			{
//				coder.append(
//					"mov v1, va1\n" +	// uv -> v1, uv为变换后的最终uv坐标
//					"mov v2, va2\n"		// color -> v2, 灯光颜色（w强度)
//				);
//			}
			return null;
		}

		// fragment shader 代码
		override protected function getFragmentCode(_code:ShaderElementArray):ShaderElementArray
		{
//			if(_lightMapTexture==null)
//			{
//				coder.append(
//					"mov oc, fc0.z\n"	// 没有贴图就渲染一个固定值
//				);
//				return;
//			}
//			
//			// 贴图采样
//			if(repeat)
//				coder.append(
//					"tex ft0, v1, fs0 <2d, linear, repeat"+FormatToAssemble.toAssemble(_lightMapTexture.format)+">\n"
//				);
//			else
//				coder.append(
//					"tex ft0, v1, fs0 <2d, linear, clamp"+FormatToAssemble.toAssemble(_lightMapTexture.format)+">\n"
//				);
//			
//			coder.append(
//				"mov ft1, v2\n" +					// 灯光颜色->ft1
//				"mul ft0.xyz, ft0.xyz, ft1.xyz\n" +	// 乘以颜色值
//				"mul ft0, ft0, ft1.w\n" +			// 乘以光照强度
//				"mov oc, ft0\n"						// 最终颜色
//			);
			return null;
		}
		
		specter3d override  function render(_context3d:WebGLContext, renderable:DrawUnit, camera:Camera3D):void
		{
			if(_lightMapTexture)
			{	// uvBuffer填入va1
				Context3DProxy.setSimpleVertexBuffer(1, renderable.getUVBuffer(), Context3DVertexBufferFormat.FLOAT_2);
				// 灯光颜色填入va2
				Context3DProxy.setSimpleVertexBuffer(2, renderable.getVertexColorBuffer(), Context3DVertexBufferFormat.FLOAT_4);
			}
			
			// 相机vp
			Context3DProxy.context3D.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, camera.viewProjection, true);
			
			super.render(renderable, camera, lightPicker);			
		}		
		
		specter3d override function activate(camera : Camera3D, textureRatioX : Number, textureRatioY : Number) : void
		{
			super.activate(camera, textureRatioX, textureRatioY);
			
			// ps常量寄存器
			Context3DProxy.context3D.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, _constVector, 1);
			
			if(_lightMapTexture)
			{	// 设置贴图寄存器
				Context3DProxy.setTextureAt(0, _lightMapTexture.getTextureForStage3D());
			}
		}
		
		specter3d override function deactivate() : void
		{
			super.deactivate();
		}
			
	}	// class
} // package