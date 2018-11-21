package specter3d.engine.resources
{
	import laya.d3.graphics.IndexBuffer3D;
	import laya.d3.graphics.VertexBuffer3D;
	import laya.d3.graphics.VertexDeclaration;
	import laya.d3.graphics.VertexElement;
	import laya.d3.graphics.VertexElementFormat;
	import laya.webgl.WebGLContext;
	import specter3d.engine.core.camera.Camera3D;
	import specter3d.engine.specter3d;

	use namespace specter3d;

	/**
	 * 几何体
	 * @author wangcx
	 *
	 */
	public class SubGeometry3D extends ResourceBase
	{

		public function SubGeometry3D()
		{

		}

		public var parentGeometry:Geometry3D;

		protected var _autoDeriveVertexNormals:Boolean=true;
		protected var _autoDeriveVertexTangents:Boolean=true;

		protected var _autoGenerateUVs:Boolean=false;
		protected var _faceNormals:Float32Array;

		protected var _faceNormalsDirty:Boolean=true;
		protected var _faceTangents:Float32Array;
		protected var _faceTangentsDirty:Boolean=true;
		protected var _faceWeights:Float32Array;
		protected var _indexBuffer:IndexBuffer3D;
		protected var _indices:Uint16Array;
		protected var _invalidBuffer:Boolean=false;
		protected var _isUploaded:Boolean=false;
		protected var _numTriangles:int;
		protected var _numVertices:int;
		protected var _secondaryUvs:Float32Array;

		protected var _uvsDirty:Boolean=true;
		protected var _vertexBuffer:VertexBuffer3D;
		protected var _vertexData:Float32Array;
		protected var _vertexDeclaration:VertexDeclaration;
		protected var _vertexNormalsDirty:Boolean=true;
		protected var _vertexTangentsDirty:Boolean=true;
		specter3d var _attributes:Array;
		private var _useFaceWeights:Boolean=false;

		public function get UVData():Float32Array
		{
			if (_uvsDirty && _autoGenerateUVs)
				_vertexData=updateDummyUVs(_vertexData);
			return _vertexData;
		}

		public function get UVOffset():int
		{
			return 0;
		}

		public function get UVStride():uint
		{
			return 2;
		}

		public function get autoDeriveVertexNormals():Boolean
		{
			return _autoDeriveVertexNormals;
		}

		public function set autoDeriveVertexNormals(value:Boolean):void
		{
			_autoDeriveVertexNormals=value;

			_vertexNormalsDirty=value;
		}

		public function get autoDeriveVertexTangents():Boolean
		{
			return _autoDeriveVertexTangents;
		}

		public function set autoDeriveVertexTangents(value:Boolean):void
		{
			_autoDeriveVertexTangents=value;
		}

		public function get autoGenerateUVs():Boolean
		{
			return _autoGenerateUVs;
		}

		public function set autoGenerateUVs(value:Boolean):void
		{
			_autoGenerateUVs=value;
		}

		public function bindBuffer():void
		{
			_vertexBuffer.bindWithIndexBuffer(_indexBuffer);
		}

		public function clone():SubGeometry3D
		{
			var _clone:SubGeometry3D=new SubGeometry3D();
			_clone.indices=_indices.concat() as Uint16Array;
			_clone.updateVertexAttribute(_vertexData.concat() as Float32Array, _attributes.concat());
			return _clone;
		}

		public function get indices():Uint16Array
		{
			return _indices != null ? _indices : null;
		}

		public function set indices(value:Uint16Array):void
		{
			if (isDispose)
				return;
			_indices=value;

			var numTriangles:int=value.length / 3;
			_numTriangles=numTriangles;
			_invalidBuffer=true;
		}

		override public function get isUploaded():Boolean
		{
			return _isUploaded;
		}

		public function get numTriangles():int
		{
			return _indices != null ? _indices.length / 3 : 0;
		}

		public function get numVertices():int
		{
			return _numVertices;
		}

		public function get secondaryUVOffset():int
		{
			return 0;
		}

		public function get secondaryUVStride():uint
		{
			return 2;
		}

		public function updateVertexAttribute(data:Float32Array, attributes:Array):void
		{
			if (isDispose)
				return;
			_attributes=attributes;
			var numAttribute:int=attributes ? attributes.length : 0;
			if (numAttribute < 1)
			{
				throw new Error("Must be at least one attribute ​​to create the buffer.");
			}
			var _vertexStride:int=0;
			for (var i:int=0; i < numAttribute; i++)
			{
				var format:String=attributes[i].elementFormat;
				switch (format)
				{
					case VertexElementFormat.Single:
						_vertexStride+=4;
						break;
					case VertexElementFormat.Vector2:
						_vertexStride+=2 * 4;
						break;
					case VertexElementFormat.Vector3:
						_vertexStride+=3 * 4;
						break;
					case VertexElementFormat.Vector4:
						_vertexStride+=4 * 4;
						break;
				}
			}
			var numVertices:int=(data.length / (_vertexStride / 4));
			if (numVertices != _numVertices)
			{
				_vertexDeclaration=new VertexDeclaration(_vertexStride, attributes);
				_vertexData=data;
				_numVertices=numVertices;
				_invalidBuffer=true;
			}
		}

		override public function upload(_context3d:WebGLContext):void
		{
			if (isDispose)
				return;
			if (_invalidBuffer)
			{
				if (!_indexBuffer)
				{
					_indexBuffer=IndexBuffer3D.create(IndexBuffer3D.INDEXTYPE_USHORT, _indices.length, WebGLContext.STATIC_DRAW);
				}
				if (!_vertexBuffer)
				{
					_vertexBuffer=VertexBuffer3D.create(_vertexDeclaration, _numVertices, WebGLContext.STATIC_DRAW);
				}
				_vertexBuffer.setData(_vertexData);
				_indexBuffer.setData(_indices);
				_vertexBuffer.bindWithIndexBuffer(_indexBuffer);
				_invalidBuffer=false;
				_isUploaded=true;
			}
		}

		public function get vertexData():Float32Array
		{
			if (_autoDeriveVertexNormals && _vertexNormalsDirty)
				_vertexData=updateVertexNormals(_vertexData);
			if (_autoDeriveVertexTangents && _vertexTangentsDirty)
				_vertexData=updateVertexTangents(_vertexData);
			if (_uvsDirty && _autoGenerateUVs)
				_vertexData=updateDummyUVs(_vertexData);
			return _vertexData;
		}

		public function get vertexOffset():int
		{
			return 0;
		}

		public function get vertexStride():int
		{
			return _vertexDeclaration ? _vertexDeclaration.vertexStride : -1;
		}

		protected function updateDummyUVs(target:Float32Array):Float32Array
		{
			_uvsDirty=false;

			var idx:uint, uvIdx:uint;
			var stride:int=13;
			var skip:int=stride - 2;
			var len:uint=_vertexData.length / 13 * stride;

			if (!target)
				target=new Float32Array();
			target.fixed=false;
			target.length=len;
			target.fixed=true;

			idx=9;
			uvIdx=0;
			while (idx < len)
			{
				target[idx++]=uvIdx * .5;
				target[idx++]=1.0 - (uvIdx & 1);
				idx+=skip;

				if (++uvIdx == 3)
					uvIdx=0;
			}

			return target;
		}

		protected function updateFaceTangents():void
		{
			var i:uint;
			var index1:uint, index2:uint, index3:uint;
			var len:uint=_indices.length;
			var ui:uint, vi:uint;
			var v0:Number;
			var dv1:Number, dv2:Number;
			var denom:Number;
			var x0:Number, y0:Number, z0:Number;
			var dx1:Number, dy1:Number, dz1:Number;
			var dx2:Number, dy2:Number, dz2:Number;
			var cx:Number, cy:Number, cz:Number;
			var vertices:Float32Array=_vertexData;
			var uvs:Float32Array=_vertexData;
			var posStride:int=13;
			var posOffset:int=0;
			var texStride:int=13;
			var texOffset:int=9;

			_faceTangents||=new Float32Array(_indices.length);
			while (i < len)
			{
				index1=_indices[i];
				index2=_indices[i + 1];
				index3=_indices[i + 2];

				ui=texOffset + index1 * texStride + 1;
				v0=uvs[ui];
				ui=texOffset + index2 * texStride + 1;
				dv1=uvs[ui] - v0;
				ui=texOffset + index3 * texStride + 1;
				dv2=uvs[ui] - v0;

				vi=posOffset + index1 * posStride;
				x0=vertices[vi];
				y0=vertices[vi + 1];
				z0=vertices[vi + 2];
				vi=posOffset + index2 * posStride;
				dx1=vertices[vi] - x0;
				dy1=vertices[vi + 1] - y0;
				dz1=vertices[vi + 2] - z0;
				vi=posOffset + index3 * posStride;
				dx2=vertices[vi] - x0;
				dy2=vertices[vi + 1] - y0;
				dz2=vertices[vi + 2] - z0;

				cx=dv2 * dx1 - dv1 * dx2;
				cy=dv2 * dy1 - dv1 * dy2;
				cz=dv2 * dz1 - dv1 * dz2;
				var r:Number=Math.sqrt(cx * cx + cy * cy + cz * cz);
				denom=r > 0 ? 1 / r : 0;
				_faceTangents[i++]=denom * cx;
				_faceTangents[i++]=denom * cy;
				_faceTangents[i++]=denom * cz;
			}

			_faceTangentsDirty=false;
		}

		protected function updateVertexNormals(target:Float32Array):Float32Array
		{
			if (_faceNormalsDirty)
				updateFaceNormals();

			var v1:uint;
			var f1:uint=0, f2:uint=1, f3:uint=2;
			var lenV:uint=_vertexData.length;
			var normalStride:int=13;
			var normalOffset:int=3;

			target||=new Float32Array(lenV);
			v1=normalOffset;
			while (v1 < lenV)
			{
				target[v1]=0.0;
				target[v1 + 1]=0.0;
				target[v1 + 2]=0.0;
				v1+=normalStride;
			}
			var i:uint, k:uint;
			var lenI:uint=_indices.length;
			var index:uint;
			var weight:uint;

			while (i < lenI)
			{
				weight=_useFaceWeights ? _faceWeights[k++] : 1;
				index=normalOffset + _indices[i++] * normalStride;
				target[index++]+=_faceNormals[f1] * weight;
				target[index++]+=_faceNormals[f2] * weight;
				target[index]+=_faceNormals[f3] * weight;
				index=normalOffset + _indices[i++] * normalStride;
				target[index++]+=_faceNormals[f1] * weight;
				target[index++]+=_faceNormals[f2] * weight;
				target[index]+=_faceNormals[f3] * weight;
				index=normalOffset + _indices[i++] * normalStride;
				target[index++]+=_faceNormals[f1] * weight;
				target[index++]+=_faceNormals[f2] * weight;
				target[index]+=_faceNormals[f3] * weight;
				f1+=3;
				f2+=3;
				f3+=3;
			}

			v1=normalOffset;
			while (v1 < lenV)
			{
				var vx:Number=target[v1];
				var vy:Number=target[v1 + 1];
				var vz:Number=target[v1 + 2];
				var d:Number=1.0 / Math.sqrt(vx * vx + vy * vy + vz * vz);
				target[v1]=vx * d;
				target[v1 + 1]=vy * d;
				target[v1 + 2]=vz * d;
				v1+=normalStride;
			}

			_vertexNormalsDirty=false;
			return target;
		}

		protected function updateVertexTangents(target:Float32Array):Float32Array
		{
			if (_faceTangentsDirty)
				updateFaceTangents();
			var i:uint;
			var lenV:uint=_vertexData.length;
			var tangentStride:int=13;
			var tangentOffset:int=6;

			target||=new Float32Array(lenV);

			i=tangentOffset;

			while (i < lenV)
			{
				target[i]=0.0;
				target[i + 1]=0.0;
				target[i + 2]=0.0;
				i+=tangentStride;
			}

			var k:uint;
			var lenI:uint=_indices.length;
			var index:uint;
			var weight:uint;
			var f1:uint=0, f2:uint=1, f3:uint=2;

			i=0;

			while (i < lenI)
			{
				weight=_useFaceWeights ? _faceWeights[k++] : 1;
				index=tangentOffset + _indices[i++] * tangentStride;
				target[index++]+=_faceTangents[f1] * weight;
				target[index++]+=_faceTangents[f2] * weight;
				target[index]+=_faceTangents[f3] * weight;
				index=tangentOffset + _indices[i++] * tangentStride;
				target[index++]+=_faceTangents[f1] * weight;
				target[index++]+=_faceTangents[f2] * weight;
				target[index]+=_faceTangents[f3] * weight;
				index=tangentOffset + _indices[i++] * tangentStride;
				target[index++]+=_faceTangents[f1] * weight;
				target[index++]+=_faceTangents[f2] * weight;
				target[index]+=_faceTangents[f3] * weight;
				f1+=3;
				f2+=3;
				f3+=3;
			}
			i=tangentOffset;
			while (i < lenV)
			{
				var vx:Number=target[i];
				var vy:Number=target[i + 1];
				var vz:Number=target[i + 2];
				var _r:Number=Math.sqrt(vx * vx + vy * vy + vz * vz);
				var d:Number=_r > 0 ? 1.0 / _r : 0;

				target[i]=vx * d;
				target[i + 1]=vy * d;
				target[i + 2]=vz * d;
				i+=tangentStride;
			}

			_vertexTangentsDirty=false;

			return target;
		}

		specter3d function activate(_context3d:WebGLContext, _camera3d:Camera3D, _program:*):void
		{
			!isUploaded && upload(_context3d);
			bindBuffer();
			var _size:int=-1;
			for (var i:int=0; i < _attributes.length; i++)
			{
				var _element:VertexElement=_attributes[i];
				switch (_element.elementFormat)
				{
					case VertexElementFormat.Single:
						_size=1;
						break;
					case VertexElementFormat.Vector2:
						_size=2;
						break;
					case VertexElementFormat.Vector3:
						_size=3;
						break;
					case VertexElementFormat.Vector4:
						_size=4;
						break;
				}
				//激活绑定需要上传的属性
				activeAttribute(_context3d, _program, _size, _element.offset, vertexStride, _element.elementUsage);
			}
		}

		/**
		 * 激活Attribute
		 * @param _context3d
		 * @param size
		 * @param offset
		 * @param vertexStride
		 * @param attribName
		 *
		 */
		private function activeAttribute(_context3d:WebGLContext, _program:*, size:int, offset:int, vertexStride:int, attribName:String):void
		{
			var attribute:*=_context3d.getAttribLocation(_program, attribName);
			if (attribute != -1)
			{
				_context3d.vertexAttribPointer(attribute, size, WebGLContext.FLOAT, false, vertexStride, offset);
				_context3d.enableVertexAttribArray(attribute);
			}
		}

		private function updateFaceNormals():void
		{
			var i:uint, j:uint, k:uint;
			var index:uint;
			var len:uint=_indices.length;
			var x1:Number, x2:Number, x3:Number;
			var y1:Number, y2:Number, y3:Number;
			var z1:Number, z2:Number, z3:Number;
			var dx1:Number, dy1:Number, dz1:Number;
			var dx2:Number, dy2:Number, dz2:Number;
			var cx:Number, cy:Number, cz:Number;
			var d:Number;
			var vertices:Float32Array=_vertexData;
			var posStride:int=13;
			var posOffset:int=0;

			_faceNormals||=new Float32Array(len);
			if (_useFaceWeights)
				_faceWeights||=new Float32Array(len / 3);

			while (i < len)
			{
				index=posOffset + _indices[i++] * posStride;
				x1=vertices[index];
				y1=vertices[index + 1];
				z1=vertices[index + 2];
				index=posOffset + _indices[i++] * posStride;
				x2=vertices[index];
				y2=vertices[index + 1];
				z2=vertices[index + 2];
				index=posOffset + _indices[i++] * posStride;
				x3=vertices[index];
				y3=vertices[index + 1];
				z3=vertices[index + 2];
				dx1=x3 - x1;
				dy1=y3 - y1;
				dz1=z3 - z1;
				dx2=x2 - x1;
				dy2=y2 - y1;
				dz2=z2 - z1;
				cx=dz1 * dy2 - dy1 * dz2;
				cy=dx1 * dz2 - dz1 * dx2;
				cz=dy1 * dx2 - dx1 * dy2;
				d=Math.sqrt(cx * cx + cy * cy + cz * cz);
				// length of cross product = 2*triangle area
				if (_useFaceWeights)
				{
					var w:Number=d * 10000;
					if (w < 1)
						w=1;
					_faceWeights[k++]=w;
				}
				d=1 / d;
				_faceNormals[j++]=cx * d;
				_faceNormals[j++]=cy * d;
				_faceNormals[j++]=cz * d;
			}

			_faceNormalsDirty=false;
		}
	}
}
