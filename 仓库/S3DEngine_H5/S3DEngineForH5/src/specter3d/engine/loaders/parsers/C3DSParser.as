package specter3d.engine.loaders.parsers
{
	import laya.utils.Byte;
	import laya.utils.Dictionary;
	
	import specter3d.engine.core.Object3D;
	import specter3d.engine.loaders.AssetType;
	import specter3d.engine.loaders.parsers.data.FaceVO;
	import specter3d.engine.loaders.parsers.data.MaterialVO;
	import specter3d.engine.loaders.parsers.data.ObjectVO;
	import specter3d.engine.loaders.parsers.data.TextureVO;
	import specter3d.engine.loaders.parsers.data.VertexVO;
	import specter3d.engine.resources.Geometry3D;
	import specter3d.engine.resources.SubGeometry3D;
	import specter3d.engine.utlis.GeomUtil;
	import specter3d.engine.utlis.LimitValueUtlis;
	/**
	 * 支持多维材质的 3ds解析器
	 * @author wangcx
	 *
	 */
	public class C3DSParser extends ParserBase
	{

		public function C3DSParser()
		{
			super(ParserDataFormat.BINARY);
		}

		public var tempName:String;
		private var _byteData:Byte;
		private var _cur_mat:MaterialVO;
		private var _cur_mat_end:uint;
		private var _cur_obj:ObjectVO; //当前正在解析的单个模型数据

		private var _cur_obj_end:uint; //当前正在解析的单个模型数据的 结束位置

		private var _firstTex:TextureVO;
		private var _materials:Object; // 材质

		private var _unfinalized_objects:Object;
		
		private var flag:Boolean = true;
		
		override protected function proceedParsing():Boolean
		{
			if (!_byteData)
			{
				_byteData=getByteData();
				_byteData.pos=0;
				_byteData.endian=Byte.LITTLE_ENDIAN;
				_materials={};
				_unfinalized_objects={};
			}

			if (_cur_mat && _byteData.pos >= _cur_mat_end)
			{
				finalizeCurrentMaterial();
			}
			else if (_cur_obj && _byteData.pos >= _cur_obj_end)
			{
				_unfinalized_objects[_cur_obj.name]=_cur_obj;
				_cur_obj_end=LimitValueUtlis.UINT_MAX_VALUE;
				_cur_obj=null;
			}
			while (flag)
			{
				if (_byteData.bytesAvailable)
				{
					var cid:uint;
					var len:uint;
					var end:uint;
	
					cid=_byteData.getUint16();
					len=_byteData.getUint32();
					end=_byteData.pos + (len - 6);
	
					switch (cid)
					{
						case 0x4D4D: // MAIN3DS
						case 0x3D3D: // EDIT3DS
						case 0xB000: // KEYF3DS
							break;
	
						case 0x4000: // EDIT_OBJECT
							_cur_obj_end=end;
							_cur_obj=new ObjectVO();
							_cur_obj.name=readNulTermString();
							_cur_obj.materials=new Vector.<String>();
							_cur_obj.materialFaces={};
							break;
						case 0x4100: // OBJ_TRIMESH 
							_cur_obj.type=AssetType.MESH;
							break;
						case 0x4110: // TRI_VERTEXL
							parseVertexList();
							break;
						case 0x4120: // TRI_FACELIST
							parseFaceList();
							break;
						case 0x4140: // TRI_MAPPINGCOORDS
							parseUVList();
							break;
						case 0x4160: // Transform
							_cur_obj.transform=readTransform();
							break;
						case 0x4150: // Smoothing groups
							parseSmoothingGroups();
							break;
						default:
							_byteData.pos+=(len - 6);
							break;
					}
				}
				else
				{
					flag = false;
				}
			}
			
			if (_byteData.bytesAvailable || _cur_obj || _cur_mat)
			{
				return MORE_TO_PARSE;
			}
			else
			{
				var name:String;
				for (name in _unfinalized_objects)
				{
					var obj:Geometry3D=constructObject(_unfinalized_objects[name]);
					obj && finalizeAsset(obj);
				}
				return PARSING_DONE;
			}
		}

		// 分解多级材质
		private function applyMultiMaterial(vertices:Vector.<VertexVO>, faces:Vector.<FaceVO>, obj:ObjectVO):void
		{
			var i:int;
			var j:int;
			var k:int;
			var l:int;
			var len:int;
			var numVerts:uint=vertices.length; // 顶点数
			var numFaces:uint=faces.length; // 面数

			// 计算每个顶点有几个材质
			var vMaterilas:Vector.<Vector.<uint>>=new Vector.<Vector.<uint>>(numVerts, true);
			for (i=0; i < numVerts; i++)
				vMaterilas[i]=new Vector.<uint>;

			// 统计每个顶点对应的材质数
			for (i=0; i < numFaces; i++)
			{
				var face:FaceVO=FaceVO(faces[i]);
				for (j=0; j < 3; j++)
				{
					var materials:Vector.<uint>=vMaterilas[(j == 0) ? face.a : ((j == 1) ? face.b : face.c)]; // 某顶点的材质列表
					if (materials.indexOf(face.materialId) == -1)
						materials.push(face.materialId);
				}
			}
			// 根据材质复制顶点
			var vClones:Vector.<Vector.<uint>>=new Vector.<Vector.<uint>>(numVerts, true); // clone表
			for (i=0; i < numVerts; i++)
			{
				var v0:VertexVO=vertices[i];
				v0.materialId=vMaterilas[i][0]; // 记录该顶点的唯一材质id
				if ((len=vMaterilas[i].length) <= 1)
					continue;

				var clones:Vector.<uint>=new Vector.<uint>(len, true);
				vClones[i]=clones; // 记录clone表
				clones[0]=i; // clone表的第一个值为，原始顶点
				for (j=1; j < len; j++)
				{
					var v1:VertexVO=new VertexVO;
					v1.x=v0.x;
					v1.y=v0.y;
					v1.z=v0.z;
					v1.u=v0.u;
					v1.v=v0.v;
					v1.materialId=vMaterilas[i][j]; // 记录该顶点的唯一材质id
					clones[j]=vertices.length; // clone表后面的值，为复制顶点的index
					vertices.push(v1);
				}
			}
			numVerts=vertices.length;
			// 更新index
			for (i=0; i < numFaces; i++)
			{
				face=FaceVO(faces[i]);
				for (j=0; j < 3; j++)
				{
					k=(j == 0) ? face.a : ((j == 1) ? face.b : face.c);
					materials=vMaterilas[k];
					len=materials.length;
					clones=vClones[k];
					if (!clones)
						continue;
					// 找出该面属于第几个材质
					var ci:int=materials.indexOf(face.materialId);
					var index:int=clones[ci];

					if (j == 0)
						face.a=index;
					else if (j == 1)
						face.b=index;
					else
						face.c=index;
				}
			}
		}

		// 分解平滑组
		private function applySmoothGroups(vertices:Vector.<VertexVO>, faces:Vector.<FaceVO>):void
		{
			var i:int;
			var j:int;
			var k:int;
			var l:int;
			var len:int;
			var numVerts:uint=vertices.length;
			var numFaces:uint=faces.length;

			// 计算每个顶点在几个组上 extract groups data for vertices
			var vGroups:Vector.<Vector.<uint>>=new Vector.<Vector.<uint>>(numVerts, true);
			for (i=0; i < numVerts; i++)
			{
				vGroups[i]=new Vector.<uint>;
			}
			for (i=0; i < numFaces; i++)
			{
				var face:FaceVO=FaceVO(faces[i]);
				for (j=0; j < 3; j++)
				{
					var groups:Vector.<uint>=vGroups[(j == 0) ? face.a : ((j == 1) ? face.b : face.c)];
					var group:uint=face.smoothGroup;
					for (k=groups.length - 1; k >= 0; k--)
					{
						if ((group & groups[k]) > 0)
						{
							group|=groups[k];
							groups.splice(k, 1);
							k=groups.length - 1;
						}
					}
					groups.push(group);
				}
			}
			// 每个顶点为不同的平滑组，复制顶点 clone vertices
			var vClones:Vector.<Vector.<uint>>=new Vector.<Vector.<uint>>(numVerts, true);
			for (i=0; i < numVerts; i++)
			{
				if ((len=vGroups[i].length) < 1)
					continue;
				var clones:Vector.<uint>=new Vector.<uint>(len, true);
				vClones[i]=clones;
				clones[0]=i;
				var v0:VertexVO=vertices[i];
				for (j=1; j < len; j++)
				{
					var v1:VertexVO=new VertexVO;
					v1.x=v0.x;
					v1.y=v0.y;
					v1.z=v0.z;
					v1.u=v0.u;
					v1.v=v0.v;
					clones[j]=vertices.length;
					vertices.push(v1);
				}
			}
			numVerts=vertices.length;

			for (i=0; i < numFaces; i++)
			{
				face=FaceVO(faces[i]);
				group=face.smoothGroup;
				for (j=0; j < 3; j++)
				{
					k=(j == 0) ? face.a : ((j == 1) ? face.b : face.c);
					groups=vGroups[k];
					len=groups.length;
					clones=vClones[k];
					for (l=0; l < len; l++)
					{
						if (((group == 0) && (groups[l] == 0)) || ((group & groups[l]) > 0))
						{
							var index:uint=clones[l];
							if (group == 0)
							{
								groups.splice(l, 1);
								clones.splice(l, 1);
							}
							if (j == 0)
								face.a=index;
							else if (j == 1)
								face.b=index;
							else
								face.c=index;
							l=len;
						}
					}
				}
			}
		}

		// 构建数据
		private function constructObject(obj:ObjectVO):Geometry3D
		{
			if (obj.type == AssetType.MESH)
			{
				var i:uint;
				var subs:Vector.<SubGeometry3D>;
				if (!obj.indices || obj.indices.length == 0)
					return null;

				var vertices:Vector.<VertexVO>=new Vector.<VertexVO>(obj.verts.length / 3, false); // 顶点数
				var faces:Vector.<FaceVO>=new Vector.<FaceVO>(obj.indices.length / 3, true); // 面数
				prepareData(vertices, faces, obj);
				applySmoothGroups(vertices, faces); // 分解平滑组

				var geom:Geometry3D=new Geometry3D();
				if (obj.materials.length > 1)
				{ // 多级材质
					applyMultiMaterial(vertices, faces, obj); // 分解多级材质

					var matLen:int=obj.materials.length;
					var vertsArray:Vector.<Vector.<Number>>=new Vector.<Vector.<Number>>(matLen, true);
					var uvsArray:Vector.<Vector.<Number>>=new Vector.<Vector.<Number>>(matLen, true);
					var indeicesArray:Vector.<Vector.<uint>>=new Vector.<Vector.<uint>>(matLen, true);

					for (i=0; i < matLen; i++)
					{
						vertsArray[i]=new Vector.<Number>;
						uvsArray[i]=new Vector.<Number>;
						indeicesArray[i]=new Vector.<uint>;
					}

					// 顶点重排
					var correspond_table:Dictionary=new Dictionary; // 重排对应表
					for (i=0; i < vertices.length; i++)
					{
						var fi:int;
						// 查找该顶点属于第几个材质
						var vertexVO:VertexVO=vertices[i];
						var matId:int=vertexVO.materialId;
						// 将该顶点放入对应的重排表中
						vertsArray[matId].push(vertexVO.x);
						vertsArray[matId].push(vertexVO.y);
						vertsArray[matId].push(vertexVO.z);
						uvsArray[matId].push(vertexVO.u);
						uvsArray[matId].push(vertexVO.v);
						var newIndex:uint=vertsArray[matId].length / 3 - 1;
						correspond_table[i]=newIndex;
					}

					// 修改所有index中对应的顶点的值
					for (fi=0; fi < faces.length; fi++)
					{
						faces[fi].a=correspond_table[faces[fi].a];
						faces[fi].b=correspond_table[faces[fi].b];
						faces[fi].c=correspond_table[faces[fi].c];
					}

					// 引索重排
					for (i=0; i < faces.length; i++)
					{
						var face:FaceVO=faces[i];
						indeicesArray[face.materialId].push(face.a);
						indeicesArray[face.materialId].push(face.b);
						indeicesArray[face.materialId].push(face.c);
					}

					// 创建SubGeometry
					for (i=0; i < matLen; i++)
					{
						if (vertsArray[i].length == 0)
						{
							continue;
						}
						subs=GeomUtil.fromVectors(vertsArray[i], indeicesArray[i], uvsArray[i], null, null);
						geom.addSubGeometry(subs[0]);
					}
				}
				else // 非多级材质
				{
					// 更新顶点和index数据
					obj.verts=new Vector.<Number>(vertices.length * 3, true);
					for (i=0; i < vertices.length; i++)
					{
						var verVo:VertexVO=vertices[i];
						obj.verts[i * 3]=verVo.x;
						obj.verts[i * 3 + 1]=verVo.y;
						obj.verts[i * 3 + 2]=verVo.z;
					}
					obj.indices=new Vector.<uint>(faces.length * 3, true);
					for (i=0; i < faces.length; i++)
					{
						obj.indices[i * 3]=faces[i].a;
						obj.indices[i * 3 + 1]=faces[i].b;
						obj.indices[i * 3 + 2]=faces[i].c;
					}

					if (obj.uvs)
					{
						obj.uvs=new Vector.<Number>(vertices.length * 2, true);
						for (i=0; i < vertices.length; i++)
						{
							var tverVo:VertexVO=vertices[i];
							obj.uvs[i * 2]=tverVo.u;
							obj.uvs[i * 2 + 1]=tverVo.v;
						}
					}
					// 创建Geometry
					subs=GeomUtil.fromVectors(obj.verts, obj.indices, obj.uvs, null, null);
					for (i=0; i < subs.length; i++)
					{
						if(obj.uvs == null)
						{
							subs[i].autoGenerateUVs = true;
						}
						geom.subGeometry.push(subs[i]);
					}
				}
			}
			return geom;
		}

		private function finalizeCurrentMaterial():void
		{
			_materials[_cur_mat.name]=_cur_mat; //  记录材质数据
			_cur_mat=null;
		}

		/**
		 * 解析面
		 *
		 */
		private function parseFaceList():void
		{
			var i:uint;
			var len:uint;
			var count:uint;

			count=_byteData.getUint16();
			_cur_obj.indices=new Vector.<uint>(count * 3, true);

			i=0;
			len=_cur_obj.indices.length;
			while (i < len)
			{
				var i0:uint, i1:uint, i2:uint;

				i0=_byteData.getUint16();
				i1=_byteData.getUint16();
				i2=_byteData.getUint16();

				_cur_obj.indices[i++]=i0;
				_cur_obj.indices[i++]=i2;
				_cur_obj.indices[i++]=i1;
				_byteData.pos+=2;
			}

			_cur_obj.smoothingGroups=new Vector.<uint>(count, true);
		}

		private function parseSmoothingGroups():void
		{
			var len:uint=_cur_obj.indices.length / 3;
			var i:uint=0;
			while (i < len)
			{
				_cur_obj.smoothingGroups[i]=_byteData.getUint32();
				i++;
			}
		}

		// 贴图
		private function parseTexture(end:uint):TextureVO
		{
			var tex:TextureVO;

			tex=new TextureVO();

			while (_byteData.pos < end)
			{
				var cid:uint;
				var len:uint;

				cid=_byteData.getUint16();
				len=_byteData.getUint32();

				switch (cid)
				{
					case 0xA300:
						tex.url=readNulTermString();
						break;

					default:
						// Skip this unknown texture sub-chunk
						_byteData.pos+=(len - 6);
						break;
				}
			}

			!_firstTex && (_firstTex=tex);
			return tex;
		}

		/**
		 * 解析UV信息
		 *
		 */
		private function parseUVList():void
		{
			var i:uint;
			var len:uint;
			var count:uint;

			count=_byteData.getUint16();
			_cur_obj.uvs=new Vector.<Number>(count * 2, true);

			i=0;
			len=_cur_obj.uvs.length;
			while (i < len)
			{
				_cur_obj.uvs[i++]=_byteData.getFloat32();
				_cur_obj.uvs[i++]=1.0 - _byteData.getFloat32();
			}
		}

		/**
		 * 解析顶点数据
		 *
		 */
		private function parseVertexList():void
		{
			var i:uint;
			var len:uint;
			var count:uint;

			count=_byteData.getUint16();
			_cur_obj.verts=new Vector.<Number>(count * 3, true);

			i=0;
			len=_cur_obj.verts.length;
			while (i < len)
			{
				var x:Number, y:Number, z:Number;

				x=_byteData.getFloat32();
				y=_byteData.getFloat32();
				z=_byteData.getFloat32();
				_cur_obj.verts[i++]=x;
				_cur_obj.verts[i++]=z;
				_cur_obj.verts[i++]=y;
			}
		}

		// 写入顶点和面数据
		private function prepareData(vertices:Vector.<VertexVO>, faces:Vector.<FaceVO>, obj:ObjectVO):void
		{
			var i:int;
			var j:int;
			var k:int;
			var len:int=obj.verts.length;
			for (i=0, j=0, k=0; i < len; )
			{
				var v:VertexVO=new VertexVO;
				v.x=obj.verts[i++];
				v.y=obj.verts[i++];
				v.z=obj.verts[i++];
				if (obj.uvs)
				{
					v.u=obj.uvs[j++];
					v.v=obj.uvs[j++];
				}
				vertices[k++]=v;
			}
			len=obj.indices.length;
			for (i=0, k=0; i < len; )
			{
				var f:FaceVO=new FaceVO();
				f.a=obj.indices[i++];
				f.b=obj.indices[i++];
				f.c=obj.indices[i++];
				f.smoothGroup=obj.smoothingGroups[k];
				// 该面的材质id
				for (var mi:int=0; mi < obj.materials.length; mi++)
				{
					var facelist:Vector.<uint>=obj.materialFaces[obj.materials[mi]];
					if (facelist.indexOf(k) >= 0)
						f.materialId=mi;
				}


				faces[k++]=f;
			}
		}

		private function readColor():uint
		{
			var cid:uint;
			var len:uint;
			var r:uint, g:uint, b:uint;

			cid=_byteData.getUint16();
			len=_byteData.getUint32();

			switch (cid)
			{
				case 0x0010: // Floats
					r=_byteData.getFloat32() * 255;
					g=_byteData.getFloat32() * 255;
					b=_byteData.getFloat32() * 255;
					break;
				case 0x0011: // 24-bit color
					r=_byteData.readByte();
					g=_byteData.readByte();
					b=_byteData.readByte();
					break;
				default:
					_byteData.pos+=(len - 6);
					break;
			}

			return (r << 16) | (g << 8) | b;
		}

		private function readNulTermString():String
		{
			var chr:uint;
			var str:String=new String();

			while ((chr=_byteData.readByte()) > 0)
			{
				str+=String.fromCharCode(chr);
			}

			return str;
		}

		/**
		 * 解析位置
		 * @return
		 *
		 */
		private function readTransform():Float32Array
		{
			var data:Float32Array=new Float32Array(16);

			// X axis
			data[0]=_byteData.getFloat32(); // X
			data[2]=_byteData.getFloat32(); // Z
			data[1]=_byteData.getFloat32(); // Y
			data[3]=0;

			// Z axis
			data[8]=_byteData.getFloat32(); // X
			data[10]=_byteData.getFloat32(); // Z
			data[9]=_byteData.getFloat32(); // Y
			data[11]=0;

			// Y Axis
			data[4]=_byteData.getFloat32(); // X 
			data[6]=_byteData.getFloat32(); // Z
			data[5]=_byteData.getFloat32(); // Y
			data[7]=0;

			// Translation
			data[12]=_byteData.getFloat32(); // X
			data[14]=_byteData.getFloat32(); // Z
			data[13]=_byteData.getFloat32(); // Y
			data[15]=1;

			return data;
		}
	}
}
