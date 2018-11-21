package specter3d.engine.primitives
{
	import laya.d3.graphics.VertexElement;
	import laya.d3.graphics.VertexElementFormat;
	
	import specter3d.engine.materials.compilation.ShaderRegisterUsage;
	import specter3d.engine.resources.Geometry3D;
	import specter3d.engine.resources.SubGeometry3D;
	import specter3d.engine.utlis.GeomUtil;
	
	public class SphereGeometry extends Geometry3D
	{
		private var _radius:Number;
		private var _segmentsW:uint;
		private var _segmentsH:uint;
		private var _yUp:Boolean;
		
		public function SphereGeometry(radius:Number = 50, segmentsW:uint = 16, segmentsH:uint = 12, yUp:Boolean = true)
		{
			super();
			// 基础属性
			_radius = radius;
			_segmentsW = segmentsW;
			_segmentsH = segmentsH;
			_yUp = yUp;
			buildGeometry();
		}
		
		protected function buildGeometry():void
		{
			var vertices:Float32Array;
			var indices:Uint16Array;
			var i:uint, j:uint, triIndex:uint;
			var numVerts:uint = (_segmentsH + 1)*(_segmentsW + 1);
			var stride:uint = 13;
			var skip:uint = stride - 9;
			
			vertices = new Float32Array(numVerts*stride);
			indices = new Uint16Array((_segmentsH - 1)*_segmentsW*6);
			
			var startIndex:uint;
			var index:uint = 0;
			var comp1:Number, comp2:Number, t1:Number, t2:Number;
			
			for (j = 0; j <= _segmentsH; ++j) {
				
				startIndex = index;
				
				var horangle:Number = Math.PI*j/_segmentsH;
				var z:Number = -_radius*Math.cos(horangle);
				var ringradius:Number = _radius*Math.sin(horangle);
				
				for (i = 0; i <= _segmentsW; ++i) {
					var verangle:Number = 2*Math.PI*i/_segmentsW;
					var x:Number = ringradius*Math.cos(verangle);
					var y:Number = ringradius*Math.sin(verangle);
					var normLen:Number = 1/Math.sqrt(x*x + y*y + z*z);
					var tanLen:Number = Math.sqrt(y*y + x*x);
					
					if (_yUp) {
						t1 = 0;
						t2 = tanLen > .007? x/tanLen : 0;
						comp1 = -z;
						comp2 = y;
						
					} else {
						t1 = tanLen > .007? x/tanLen : 0;
						t2 = 0;
						comp1 = y;
						comp2 = z;
					}
					
					if (i == _segmentsW) {
						vertices[index++] = vertices[startIndex];
						vertices[index++] = vertices[startIndex + 1];
						vertices[index++] = vertices[startIndex + 2];
						vertices[index++] = vertices[startIndex + 3] + (x*normLen)*.5;
						vertices[index++] = vertices[startIndex + 4] + ( comp1*normLen)*.5;
						vertices[index++] = vertices[startIndex + 5] + (comp2*normLen)*.5;
						vertices[index++] = tanLen > .007? -y/tanLen : 1;
						vertices[index++] = t1;
						vertices[index++] = t2;
						
					} else {
						vertices[index++] = x;
						vertices[index++] = comp1;
						vertices[index++] = comp2;
						vertices[index++] = x*normLen;
						vertices[index++] = comp1*normLen;
						vertices[index++] = comp2*normLen;
						vertices[index++] = tanLen > .007? -y/tanLen : 1;
						vertices[index++] = t1;
						vertices[index++] = t2;
					}
					
					if (i > 0 && j > 0) {
						var a:int = (_segmentsW + 1)*j + i;
						var b:int = (_segmentsW + 1)*j + i - 1;
						var c:int = (_segmentsW + 1)*(j - 1) + i - 1;
						var d:int = (_segmentsW + 1)*(j - 1) + i;
						
						if (j == _segmentsH) {
							vertices[index - 9] = vertices[startIndex];
							vertices[index - 8] = vertices[startIndex + 1];
							vertices[index - 7] = vertices[startIndex + 2];
							
							indices[triIndex++] = a;
							indices[triIndex++] = c;
							indices[triIndex++] = d;
							
						} else if (j == 1) {
							indices[triIndex++] = a;
							indices[triIndex++] = b;
							indices[triIndex++] = c;
							
						} else {
							indices[triIndex++] = a;
							indices[triIndex++] = b;
							indices[triIndex++] = c;
							indices[triIndex++] = a;
							indices[triIndex++] = c;
							indices[triIndex++] = d;
						}
					}
					
					index += skip;
				}
			}
			
			var _subGeometry:SubGeometry3D=new SubGeometry3D();
			_subGeometry.indices=indices;
//			_subGeometry.updateVertexAttribute(vertices, attributes);
			buildUVs(_subGeometry, vertices);
			addSubGeometry(_subGeometry);
			_subGeometry.vertexData;
		}
		
		protected function buildUVs(target:SubGeometry3D, data:Float32Array):void
		{
			var i:int, j:int;
			var stride:uint = 13;
			var numUvs:uint = (_segmentsH + 1)*(_segmentsW + 1)*stride;
//			var data:Float32Array;
			var skip:uint = stride - 2;
			
//			data = new Float32Array(numUvs, true);
			
			var index:int = 9;
			for (j = 0; j <= _segmentsH; ++j) {
				for (i = 0; i <= _segmentsW; ++i) {
					data[index++] = ( i/_segmentsW )*1;
					data[index++] = ( j/_segmentsH )*1;
					index += skip;
				}
			}
			target.updateVertexAttribute(data,GeomUtil.SUB_GEOMETRY_ATTRIBUTES);
		}
		
	}
}