package specter3d.engine.utlis
{
	import laya.d3.graphics.VertexElement;
	import laya.d3.graphics.VertexElementFormat;
	
	import specter3d.engine.materials.compilation.ShaderRegisterUsage;
	import specter3d.engine.resources.SubGeometry3D;
	public class GeomUtil
	{
		public static const LIMIT:uint=3 * 0xffff;
			
		public static const SUB_GEOMETRY_ATTRIBUTES:Array=[
			new VertexElement(0, VertexElementFormat.Vector3, ShaderRegisterUsage.POSITION), 
			new VertexElement(12, VertexElementFormat.Vector3, ShaderRegisterUsage.NORMAL), 
			new VertexElement(24, VertexElementFormat.Vector3, ShaderRegisterUsage.TANGENT), 
			new VertexElement(36, VertexElementFormat.Vector2, ShaderRegisterUsage.UV), 
			new VertexElement(44, VertexElementFormat.Vector2, ShaderRegisterUsage.SECONDARY_UV)
		];
		
		public static const SKINNED_SUB_GEOMETRY_ATTRIBUTES:Array=[
			new VertexElement(0, VertexElementFormat.Vector3, ShaderRegisterUsage.POSITION), 
			new VertexElement(12, VertexElementFormat.Vector3, ShaderRegisterUsage.NORMAL), 
			new VertexElement(24, VertexElementFormat.Vector3, ShaderRegisterUsage.TANGENT), 
			new VertexElement(36, VertexElementFormat.Vector2, ShaderRegisterUsage.UV), 
			new VertexElement(44, VertexElementFormat.Vector2, ShaderRegisterUsage.SECONDARY_UV)
		];
		
		public static function constructSubGeometry(verts:Vector.<Number>, indices:Vector.<uint>, uvs:Vector.<Number>, normals:Vector.<Number>, tangents:Vector.<Number>):SubGeometry3D
		{
			var sub:SubGeometry3D=new SubGeometry3D();
			sub.indices=new Uint16Array(indices);
			var vertsData:Vector.<Number>=new Vector.<Number>();
			var index:int = 0,vi:int=0, ni:int = 0, ti:int = 0, ui:int=0;
			var loop:int=verts.length / 3 * 13;
			
			while(index < loop)
			{
				//POSITION
				vertsData[index++] = verts[vi++];
				vertsData[index++] = verts[vi++];
				vertsData[index++] = verts[vi++];
				//NORMAL
				if (normals && normals.length)
				{
					vertsData[index++]=normals[ni++];
					vertsData[index++]=normals[ni++];
					vertsData[index++]=normals[ni++];
				}
				else
				{
					vertsData[index++]=0;
					vertsData[index++]=0;
					vertsData[index++]=0;
				}
				//TANGENT
				if (tangents && tangents.length)
				{
					vertsData[index++]=tangents[ti++];
					vertsData[index++]=tangents[ti++];
					vertsData[index++]=tangents[ti++];
				}
				else
				{
					vertsData[index++]=0;
					vertsData[index++]=0;
					vertsData[index++]=0;
				}
				// UV
				if (uvs && uvs.length)
				{
					vertsData[index++]=uvs[ui];
					vertsData[index++]=uvs[ui+1];
					// use same secondary uvs as primary
					vertsData[index++]=uvs[ui++];
					vertsData[index++]=uvs[ui++];
				}
				else
				{
					vertsData[index++]=0;
					vertsData[index++]=0;
					vertsData[index++]=0;
					vertsData[index++]=0;
				}
			}
			sub.updateVertexAttribute(new Float32Array(vertsData), SUB_GEOMETRY_ATTRIBUTES);
			sub.autoDeriveVertexNormals = normals && normals.length ? false : true;
			sub.autoDeriveVertexTangents = tangents && tangents.length ? false : true;
			sub.autoGenerateUVs = uvs && uvs.length ? false : true;
			return sub;
		}


		public static function fromVectors(verts:Vector.<Number>, indices:Vector.<uint>, uvs:Vector.<Number>, normals:Vector.<Number>, tangents:Vector.<Number>):Vector.<SubGeometry3D>
		{
			var subs:Vector.<SubGeometry3D>=new Vector.<SubGeometry3D>();
			if (indices.length >= LIMIT)
			{
				var i:uint, len:uint, outIndex:uint;
				var splitVerts:Vector.<Number>=new Vector.<Number>();
				var splitIndices:Vector.<uint>=new Vector.<uint>();
				var splitUvs:Vector.<Number>=(uvs != null) ? new Vector.<Number>() : null;
				var splitNormals:Vector.<Number>=(normals != null) ? new Vector.<Number>() : null;
				var splitTangents:Vector.<Number>=(tangents != null) ? new Vector.<Number>() : null;

				var mappings:Vector.<int>=new Vector.<int>(verts.length / 3, true);
				i=mappings.length;
				while (i-- > 0)
					mappings[i]=-1;

				outIndex=0;
				len=indices.length;
				for (i=0; i < len; i+=3)
				{
					var j:uint;
					if (outIndex * 3 >= LIMIT)
					{
						subs.push(constructSubGeometry(splitVerts, splitIndices, splitUvs, splitNormals, splitTangents));
						splitVerts=new Vector.<Number>();
						splitIndices=new Vector.<uint>();
						splitUvs=(uvs != null) ? new Vector.<Number>() : null;
						splitNormals=(normals != null) ? new Vector.<Number>() : null;
						splitTangents=(tangents != null) ? new Vector.<Number>() : null;
						j=mappings.length;
						while (j-- > 0)
							mappings[j]=-1;

						outIndex=0;
					}

					for (j=0; j < 3; j++)
					{
						var originalIndex:uint;
						var splitIndex:uint;

						originalIndex=indices[i + j];

						if (mappings[originalIndex] >= 0)
						{
							splitIndex=mappings[originalIndex];
						}
						else
						{
							var o0:uint, o1:uint, o2:uint, s0:uint, s1:uint, s2:uint;

							o0=originalIndex * 3 + 0;
							o1=originalIndex * 3 + 1;
							o2=originalIndex * 3 + 2;

							splitIndex=splitVerts.length / 3;
							s0=splitIndex * 3 + 0;
							s1=splitIndex * 3 + 1;
							s2=splitIndex * 3 + 2;

							splitVerts[s0]=verts[o0];
							splitVerts[s1]=verts[o1];
							splitVerts[s2]=verts[o2];

							if (uvs)
							{
								var su:uint, ou:uint, sv:uint, ov:uint;
								su=splitIndex * 2 + 0;
								sv=splitIndex * 2 + 1;
								ou=originalIndex * 2 + 0;
								ov=originalIndex * 2 + 1;

								splitUvs[su]=uvs[ou];
								splitUvs[sv]=uvs[ov];
							}

							if (normals)
							{
								splitNormals[s0]=normals[o0];
								splitNormals[s1]=normals[o1];
								splitNormals[s2]=normals[o2];
							}

							if (tangents)
							{
								splitTangents[s0]=tangents[o0];
								splitTangents[s1]=tangents[o1];
								splitTangents[s2]=tangents[o2];
							}
							mappings[originalIndex]=splitIndex;
						}
						splitIndices[outIndex + j]=splitIndex;
					}

					outIndex+=3;
				}
				splitVerts.length > 0 && subs.push(constructSubGeometry(splitVerts, splitIndices, splitUvs, splitNormals, splitTangents));
			}
			else
			{
				subs.push(constructSubGeometry(verts, indices, uvs, normals, tangents));
			}
			return subs;
		}
	}
}
