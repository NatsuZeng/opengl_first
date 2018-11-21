package specter3d.engine.primitives
{
	import laya.d3.graphics.VertexElement;
	import laya.d3.graphics.VertexElementFormat;
	
	import specter3d.engine.materials.compilation.ShaderRegisterUsage;
	import specter3d.engine.resources.Geometry3D;
	import specter3d.engine.resources.SubGeometry3D;
	import specter3d.engine.utlis.GeomUtil;

	/**
	 * 面片几何体
	 * @author wangcx
	 *
	 */
	public class PlaneGeometry extends Geometry3D
	{

		/**
		 * 面片几何体
		 * @param width 宽度
		 * @param height 高度
		 * @param segments 段数
		 * @param yUp 是否Y轴朝上
		 * @param doubleSided 是否开启双面
		 *
		 */
		public function PlaneGeometry(width:Number=100, height:Number=100, segments:uint=1, yUp:Boolean=false, doubleSided:Boolean=false)
		{
			super();
			// 基础属性
			_segments=segments;
			_yUp=yUp;
			_width=width;
			_height=height;
			_doubleSided=doubleSided;
			buildGeometry();
		}

		private var _doubleSided:Boolean;
		private var _height:Number;
		private var _segments:uint;
		private var _width:Number;
		private var _yUp:Boolean;

		/**
		 * 构建几何体
		 *
		 */
		protected function buildGeometry():void
		{
			var _subGeometry:SubGeometry3D=new SubGeometry3D();
			var x:Number, y:Number;
			var numIndices:uint;
			var base:uint;
			var tw:uint=_segments + 1;
			var numVertices:uint=(_segments + 1) * tw;
			var stride:uint=13;
			var skip:uint=stride - 9;
			if (_doubleSided)
				numVertices*=2;

			numIndices=_segments * _segments * 6;
			if (_doubleSided)
				numIndices<<=1;

			var _vertexData:Float32Array=new Float32Array(numVertices * stride);
			var _indices:Uint16Array=new Uint16Array(numIndices);
			numIndices=0;
			var index:uint=0;
			for (var yi : uint = 0; yi <= _segments; ++yi) 
			{
				for (var xi : uint = 0; xi <= _segments; ++xi) 
				{
					x=(xi / _segments - .5) * _width;
					y=(yi / _segments - .5) * _height;

					_vertexData[index++]=x;
					if (_yUp)
					{
						_vertexData[index++]=0;
						_vertexData[index++]=y;
					}
					else
					{
						_vertexData[index++]=y;
						_vertexData[index++]=0;
					}

					_vertexData[index++]=0;
					if (_yUp)
					{
						_vertexData[index++]=1;
						_vertexData[index++]=0;
					}
					else
					{
						_vertexData[index++]=0;
						_vertexData[index++]=-1;
					}

					_vertexData[index++]=1;
					_vertexData[index++]=0;
					_vertexData[index++]=0;

					index+=skip;

					if (_doubleSided)
					{
						for (var i:int=0; i < 3; ++i)
						{
							_vertexData[index]=_vertexData[index - stride];
							++index;
						}
						for (i=0; i < 3; ++i)
						{
							_vertexData[index]=-_vertexData[index - stride];
							++index;
						}
						for (i=0; i < 3; ++i)
						{
							_vertexData[index]=-_vertexData[index - stride];
							++index
						}
						index+=skip;
					}

					if (xi != _segments && yi != _segments)
					{
						base=xi + yi * tw;
						var mult:int=_doubleSided ? 2 : 1;

						_indices[numIndices++]=base * mult;
						_indices[numIndices++]=(base + tw) * mult;
						_indices[numIndices++]=(base + tw + 1) * mult;
						_indices[numIndices++]=base * mult;
						_indices[numIndices++]=(base + tw + 1) * mult;
						_indices[numIndices++]=(base + 1) * mult;

						if (_doubleSided)
						{
							_indices[numIndices++]=(base + tw + 1) * mult + 1;
							_indices[numIndices++]=(base + tw) * mult + 1;
							_indices[numIndices++]=base * mult + 1;
							_indices[numIndices++]=(base + 1) * mult + 1;
							_indices[numIndices++]=(base + tw + 1) * mult + 1;
							_indices[numIndices++]=base * mult + 1;
						}
					}
				}
			}
			_subGeometry.indices=_indices;
			_subGeometry.updateVertexAttribute(_vertexData, GeomUtil.SUB_GEOMETRY_ATTRIBUTES);
			buildUVs(_subGeometry,_vertexData);
			addSubGeometry(_subGeometry);
			_subGeometry.vertexData;
		}

		protected function buildUVs(target:SubGeometry3D,_vertexData:Float32Array):void
		{
			var data:Float32Array;
			var stride:uint=13;
			var numUvs:uint=(_segments + 1) * (_segments + 1) * stride;
			var skip:uint=stride - 2;

			if (_doubleSided)
				numUvs*=2;

			if (_vertexData && numUvs == _vertexData.length)
				data=_vertexData;

			var index:uint=9;

			for (var yi : uint = 0; yi <= _segments; ++yi) {
				for (var xi : uint = 0; xi <= _segments; ++xi) {
					data[index++] = xi/_segments;
					data[index++] = 1 - yi/_segments;
					
					
					index += skip;
					
					if (_doubleSided) {
						data[index++] = xi/_segments;
						data[index++] = 1 - yi/_segments;
						index += skip;
					}
				}
			}
			target.updateVertexAttribute(data, GeomUtil.SUB_GEOMETRY_ATTRIBUTES);
		}
	}
}
