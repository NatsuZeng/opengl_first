package
{
	import laya.d3.graphics.IndexBuffer3D;
	import laya.d3.graphics.VertexBuffer3D;
	import laya.d3.graphics.VertexDeclaration;
	import laya.d3.graphics.VertexElement;
	import laya.d3.graphics.VertexElementFormat;
	import laya.d3.graphics.VertexElementUsage;
	import laya.d3.math.Matrix4x4;
	import laya.d3.math.Vector3;
	import laya.utils.Browser;
	import laya.webgl.WebGL;
	import laya.webgl.WebGLContext;
	
	import specter3d.engine.core.drive.RenderDrive;
	import specter3d.engine.utlis.Matrix3DUtils;
	
	/**
	 * ...
	 * @author 回眸笑苍生
	 */
	public class LayaTest
	{
		private var _context3d:WebGLContext;
		
		private var _vs:String = "";
		private var _fs:String = "";
		public var _vshader:*;
		public var _fshader:*;
		public var _program:* = null;
		public var _vb:VertexBuffer3D;
		public var _ib:IndexBuffer3D;
		
		public function LayaTest()
		{
			initEngine();
			initShader();
			
			_context3d = WebGL.mainContext;
			_program = _context3d.createProgram();
			_vshader = createShader(WebGLContext.VERTEX_SHADER, _vs);
			_fshader = createShader(WebGLContext.FRAGMENT_SHADER, _fs);
			_context3d.attachShader(_program, _vshader);
			_context3d.attachShader(_program, _fshader);
			_context3d.linkProgram(_program);
			_context3d.useProgram(_program);
			
			var modelViewMatrix:Matrix4x4 = new Matrix4x4();
			Matrix4x4.createLookAt(new Vector3(4, 4, 8), new Vector3(0, 0, 0), new Vector3(0, 1, 0), modelViewMatrix);
			
			var uModelViewMatrix:* = _context3d.getUniformLocation(_program, "uModelViewMatrix");
			_context3d.uniformMatrix4fv(uModelViewMatrix, false, modelViewMatrix.elements);
			
			var projectionMatrix:Matrix4x4 = new Matrix4x4();
			Matrix4x4.createPerspective(Math.PI / 6,Browser.clientWidth/Browser.clientHeight, 0.1, 100, projectionMatrix);
			
			var uProjectionMatrix:* = _context3d.getUniformLocation(_program, "uProjectionMatrix");
			_context3d.uniformMatrix4fv(uProjectionMatrix, false, projectionMatrix.elements);
			
			var vertexDeclaration:VertexDeclaration = new VertexDeclaration(24, 
				[new VertexElement(0, VertexElementFormat.Vector3, VertexElementUsage.POSITION0), 
					new VertexElement(12, VertexElementFormat.Vector3, VertexElementUsage.NORMAL0)]);
			
			var vertexData:Float32Array = initVertexData();
			_vb = VertexBuffer3D.create(vertexDeclaration, vertexData.length/6, WebGLContext.STATIC_DRAW);//每6个浮点数组成一个顶点结构体
			_vb.clear();
			_vb.append(vertexData);
			_ib = IndexBuffer3D.create(36, WebGLContext.STATIC_DRAW);
			_ib.clear();
			_ib.append(initIndexData());
			_vb.bind_upload(_ib);
			
			var aVertexPosition:* = _context3d.getAttribLocation(_program, "aVertexPosition");
			_context3d.vertexAttribPointer(aVertexPosition, 3, WebGLContext.FLOAT, false, 24, 0);
			_context3d.enableVertexAttribArray(aVertexPosition);
			
			var aVertexColor:* = _context3d.getAttribLocation(_program, "aVertexColor");
			_context3d.vertexAttribPointer(aVertexColor, 3, WebGLContext.FLOAT, false, 24, 12);
			_context3d.enableVertexAttribArray(aVertexColor);
			
			Browser.window.requestAnimationFrame(render);
			function render(timestamp):void 
			{
				//trace(timestamp);
				loop();
				Browser.window.requestAnimationFrame(render);
			}
			
			RenderDrive.getInstance();
		}
		
		private function loop():void
		{
			//debugger;
			_context3d.enable(WebGLContext.DEPTH_TEST);
			_context3d.enable(WebGLContext.CULL_FACE);
			_context3d.clearColor(0.0, 0.0, 0.0, 1.0);
			_context3d.clear(WebGLContext.COLOR_BUFFER_BIT | WebGLContext.DEPTH_BUFFER_BIT);
			_context3d.drawElements(WebGLContext.TRIANGLES, 36, WebGLContext.UNSIGNED_SHORT, 0);
		}
		
		private function createShader(mode:*, source:String):*
		{
			var _shader:* = _context3d.createShader(mode);
			_context3d.shaderSource(_shader, source);
			_context3d.compileShader(_shader);
			/*[IF-FLASH]*/
			return _shader;
			if (!_context3d.getShaderParameter(_shader, WebGLContext.COMPILE_STATUS))
			{
				throw _context3d.getShaderInfoLog(_shader);
			}
			return _shader;
		}
		
		private function initEngine():void
		{
			var canvas = Browser.window.document.getElementById('webglx');
			canvas.width = Browser.clientWidth;
			canvas.height = Browser.clientHeight;
			_context3d = canvas.getContext("webgl", {stencil: true, alpha: false, antialias: true, premultipliedAlpha: false});
			WebGL.mainContext = _context3d;
		}
		
		private function initVertexData():Float32Array
		{
			// 顶点数据
			var vertexData:Float32Array = new Float32Array([
				//前
				1.0, 1.0, 1.0, 0.0, 0.8, 0.0, 
				-1.0, 1.0, 1.0, 0.0, 0.8, 0.0, 
				-1.0, -1.0, 1.0, 0.0, 0.8, 0.0, 
				1.0, -1.0, 1.0, 0.0, 0.8, 0.0, 
				//后
				1.0, 1.0, -1.0, 0.6, 0.9, 0.0, -1.0, 1.0, -1.0, 0.6, 0.9, 0.0, -1.0, -1.0, -1.0, 0.6, 0.9, 0.0, 1.0, -1.0, -1.0, 0.6, 0.9, 0.0, 
				//上
				1.0, 1.0, -1.0, 1.0, 1.0, 0.0, -1.0, 1.0, -1.0, 1.0, 1.0, 0.0, -1.0, 1.0, 1.0, 1.0, 1.0, 0.0, 1.0, 1.0, 1.0, 1.0, 1.0, 0.0, 
				//下
				1.0, -1.0, -1.0, 1.0, 0.5, 0.0, -1.0, -1.0, -1.0, 1.0, 0.5, 0.0, -1.0, -1.0, 1.0, 1.0, 0.5, 0.0, 1.0, -1.0, 1.0, 1.0, 0.5, 0.0, 
				//右
				1.0, 1.0, -1.0, 0.9, 0.0, 0.2, 1.0, 1.0, 1.0, 0.9, 0.0, 0.2, 1.0, -1.0, 1.0, 0.9, 0.0, 0.2, 1.0, -1.0, -1.0, 0.9, 0.0, 0.2, 
				//左
				-1.0, 1.0, -1.0, 0.6, 0.0, 0.6, -1.0, 1.0, 1.0, 0.6, 0.0, 0.6, -1.0, -1.0, 1.0, 0.6, 0.0, 0.6, -1.0, -1.0, -1.0, 0.6, 0.0, 0.6]);
			
			return vertexData;
		}
		
		/**
		 * 索引数据
		 *
		 */
		private function initIndexData():Uint16Array
		{
			var indices:Uint16Array = new Uint16Array([0, 1, 2, 0, 2, 3, 4, 6, 5, 4, 7, 6, 8, 9, 10, 8, 10, 11, 12, 14, 13, 12, 15, 14, 16, 17, 18, 16, 18, 19, 20, 22, 21, 20, 23, 22]);
			return indices;
		}
		
		private function initShader():void
		{
			
			_vs += "attribute vec3 aVertexPosition;";
			_vs += "attribute vec3 aVertexColor;";
			_vs += "uniform mat4 uModelViewMatrix;";
			_vs += "uniform mat4 uProjectionMatrix;";
			_vs += "varying vec4 vColor;";
			_vs += "void main()";
			_vs += "{";
			_vs += "gl_Position = uProjectionMatrix * uModelViewMatrix * vec4(aVertexPosition, 1.0);";
			_vs += "vColor = vec4(aVertexColor, 1.0);";
			_vs += "}";
			
			_fs += "precision highp float;";
			_fs += "varying vec4 vColor;";
			_fs += "void main()";
			_fs += "{";
			_fs += "gl_FragColor = vColor;";
			_fs += "}";
		}
	}
	
}