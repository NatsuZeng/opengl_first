package specter3d.engine.core.picker
{
	import specter3d.engine.specter3d;
	import specter3d.engine.core.Entity3D;
	import specter3d.engine.core.Layer3D;
	import specter3d.engine.core.Object3D;
	import specter3d.engine.core.geom.Matrix3D;
	import specter3d.engine.core.geom.Vector3D;
	import specter3d.engine.math.Ray;
	import specter3d.engine.objects.Mesh3D;
	import specter3d.engine.objects.Surface3D;
	import specter3d.engine.utlis.Matrix3DUtils;
	import specter3d.engine.utlis.Vector3DUtils;

	use namespace specter3d;
	
	public class RaycastPicker
	{
		public function RaycastPicker()
		{
		}
		
		public function dispose():void
		{
			
		}
		
		public function getViewCollision(x:Number, y:Number, layer:Layer3D):PickerVO
		{
			// 射线
			var rayPosition:Vector3D = new Vector3D;
			var rayDirection:Vector3D = new Vector3D;
			layer.camera3d.screen2DToScene3D(x, y, 0, rayPosition);
			layer.camera3d.screen2DToScene3D(x, y, 1, rayDirection);
			Vector3DUtils.sub(rayDirection, rayPosition, rayDirection);
			var ray:Ray = new Ray(rayPosition, rayDirection);
			
			// 可拾取的对象
			var entities:Vector.<Entity3D> = new Vector.<Entity3D>;
			collectEntities(layer.scene3d._rootContainer3D, entities);
			
			// 先测试包围盒与射线相交
			var pickEntities:Vector.<Entity3D> = new Vector.<Entity3D>;
			for (var i:int = 0; i < entities.length; i++)
			{
				if (intersectBound(entities[i], rayPosition, rayDirection))
				{
					pickEntities.push(entities[i]);
				}
			}
			
			// 如果没有相交则返回空
			if (pickEntities.length == 0)
				return null;
			
			// 由近到远排序
			pickEntities.sort(sortDistance);
			
			// 
			var findClosestCollision:Boolean = true;
			var shortestCollisionDistance:Number = Number.MAX_VALUE;
			var bestCollisionVO:PickerVO;
			for (i = 0; i < pickEntities.length; i++)
			{
				var entity:Entity3D = pickEntities[i];
				var pickVO:PickerVO = entity.pickVO;
				
				if (!bestCollisionVO || pickVO.distance < bestCollisionVO.distance)
				{
					if (entity.pickType == PickerType.BOUND)
					{
						updateLocalPosition(pickVO);
						return pickVO;
					}
					else if (entity.pickType == PickerType.MESH)
					{
						if (intersectMesh(entity as Mesh3D, entity.pickVO.localPosition, entity.pickVO.localRayDirection, 
							shortestCollisionDistance, findClosestCollision))
						{
							shortestCollisionDistance = pickVO.distance;
							bestCollisionVO = pickVO;
							
							if (!findClosestCollision)
							{
								updateLocalPosition(pickVO);
								return pickVO;
							}
						}
					}
				}
			}
			
			return bestCollisionVO;
		}
		
		private function collectEntities(obj3d:Object3D, result:Vector.<Entity3D>):void
		{
			if (obj3d is Entity3D && obj3d.visible && (obj3d as Entity3D).pickEnabled)
			{
				result.push(obj3d as Entity3D);
			}
			for (var current:Object3D=obj3d._childrenList; current != null; current=current._next)
			{
				collectEntities(current, result);
			}
		}
		
		private function sortDistance(a:PickerVO, b:PickerVO):int
		{
			return a.distance - b.distance;
		}
		
		public function intersectBound(entity:Entity3D, rayPosition:Vector3D, rayDirection:Vector3D):Boolean
		{
			var pickVO:PickerVO = entity.pickVO;
			var invWorld:Matrix3D = entity.transform.invWorld;
			
			var localRayPosition:Vector3D = pickVO.localRayPosition;
			var localRayDirection:Vector3D = pickVO.localRayDirection;
			Matrix3DUtils.transformVector(invWorld, rayPosition, localRayPosition);
			Matrix3DUtils.deltaTransformVector(invWorld, rayDirection, localRayDirection);
			
			var rayEntryDistance:Number = entity.bound.rayIntersection(localRayPosition, localRayDirection, pickVO.localNormal);
			if (rayEntryDistance < 0)
				return false;
			
			pickVO.distance = rayEntryDistance;
			
			return true;
		}
		
		public function intersectMesh(mesh:Mesh3D, rayPosition:Vector3D, rayDirection:Vector3D, 
									  shortestCollisionDistance:Number, findClosest:Boolean):Boolean
		{
			mesh.pickVO.renderable = null;
			var length:int = mesh.surfaces.length;
			for (var i:int = 0; i < length; i++)
			{
				var surface:Surface3D = mesh.surfaces[i];
				if (intersectSurface(surface, mesh.pickVO.localRayPosition, mesh.pickVO.localRayDirection, 
					mesh.pickVO, shortestCollisionDistance, findClosest))
				{
					shortestCollisionDistance = mesh.pickVO.distance;
					mesh.pickVO.renderable = surface;
					if (!findClosest)
						return true;
				}
			}
			return false;
		}
		
		public function intersectSurface(surface3D:Surface3D, localPosition:Vector3D, localDirection:Vector3D, 
										 pickVO:PickerVO, shortestCollisionDistance:Number, findClosestCollision:Boolean=false):Boolean
		{
			var rayPosition:Vector3D = localPosition;
			var rayDirection:Vector3D = localDirection;
			
			var t:Number;
			var i0:uint, i1:uint, i2:uint;
			var rx:Number, ry:Number, rz:Number;
			var nx:Number, ny:Number, nz:Number;
			var cx:Number, cy:Number, cz:Number;
			var coeff:Number, u:Number, v:Number, w:Number;
			var p0x:Number, p0y:Number, p0z:Number;
			var p1x:Number, p1y:Number, p1z:Number;
			var p2x:Number, p2y:Number, p2z:Number;
			var s0x:Number, s0y:Number, s0z:Number;
			var s1x:Number, s1y:Number, s1z:Number;
			var nl:Number, nDotV:Number, D:Number, disToPlane:Number;
			var Q1Q2:Number, Q1Q1:Number, Q2Q2:Number, RQ1:Number, RQ2:Number;
			var indexData:Uint16Array = surface3D.indexData;
			var vertexData:Float32Array = surface3D.vertexData;
//			var uvData:Float32Array = surface3D.UVData;
			var collisionTriangleIndex:int = -1;
			var bothSides:Boolean = (surface3D.material && surface3D.material.bothSides);
			
			var vertexStride:uint = surface3D.vertexStride;
			var vertexOffset:uint = surface3D.vertexOffset;
//			var uvStride:uint = surface3D.UVStride;
//			var uvOffset:uint = surface3D.UVOffset;
			var numIndices:int = indexData.length;
			
			for (var index:uint = 0; index < numIndices; index += 3) { // sweep all triangles
				// evaluate triangle indices
				i0 = vertexOffset + indexData[ index ]*vertexStride;
				i1 = vertexOffset + indexData[ uint(index + 1) ]*vertexStride;
				i2 = vertexOffset + indexData[ uint(index + 2) ]*vertexStride;
				
				// evaluate triangle vertices
				p0x = vertexData[ i0 ];
				p0y = vertexData[ uint(i0 + 1) ];
				p0z = vertexData[ uint(i0 + 2) ];
				p1x = vertexData[ i1 ];
				p1y = vertexData[ uint(i1 + 1) ];
				p1z = vertexData[ uint(i1 + 2) ];
				p2x = vertexData[ i2 ];
				p2y = vertexData[ uint(i2 + 1) ];
				p2z = vertexData[ uint(i2 + 2) ];
				
				// evaluate sides and triangle normal
				s0x = p1x - p0x; // s0 = p1 - p0
				s0y = p1y - p0y;
				s0z = p1z - p0z;
				s1x = p2x - p0x; // s1 = p2 - p0
				s1y = p2y - p0y;
				s1z = p2z - p0z;
				nx = s0y*s1z - s0z*s1y; // n = s0 x s1
				ny = s0z*s1x - s0x*s1z;
				nz = s0x*s1y - s0y*s1x;
				nl = 1/Math.sqrt(nx*nx + ny*ny + nz*nz); // normalize n
				nx *= nl;
				ny *= nl;
				nz *= nl;
				
				// -- plane intersection test --
				nDotV = nx*rayDirection.x + ny* +rayDirection.y + nz*rayDirection.z; // rayDirection . normal
				if (( !bothSides && nDotV < 0.0 ) || ( bothSides && nDotV != 0.0 )) { // an intersection must exist
					// find collision t
					D = -( nx*p0x + ny*p0y + nz*p0z );
					disToPlane = -( nx*rayPosition.x + ny*rayPosition.y + nz*rayPosition.z + D );
					t = disToPlane/nDotV;
					// find collision point
					cx = rayPosition.x + t*rayDirection.x;
					cy = rayPosition.y + t*rayDirection.y;
					cz = rayPosition.z + t*rayDirection.z;
					// collision point inside triangle? ( using barycentric coordinates )
					Q1Q2 = s0x*s1x + s0y*s1y + s0z*s1z;
					Q1Q1 = s0x*s0x + s0y*s0y + s0z*s0z;
					Q2Q2 = s1x*s1x + s1y*s1y + s1z*s1z;
					rx = cx - p0x;
					ry = cy - p0y;
					rz = cz - p0z;
					RQ1 = rx*s0x + ry*s0y + rz*s0z;
					RQ2 = rx*s1x + ry*s1y + rz*s1z;
					coeff = 1/( Q1Q1*Q2Q2 - Q1Q2*Q1Q2 );
					v = coeff*( Q2Q2*RQ1 - Q1Q2*RQ2 );
					w = coeff*( -Q1Q2*RQ1 + Q1Q1*RQ2 );
					if (v < 0)
						continue;
					if (w < 0)
						continue;
					u = 1 - v - w;
					if (!( u < 0 ) && t > 0 && t < shortestCollisionDistance) { // all tests passed
						shortestCollisionDistance = t;
						collisionTriangleIndex = index/3;
						pickVO.distance = t;
						pickVO.localPosition = new Vector3D(cx, cy, cz);
						pickVO.localNormal = new Vector3D(nx, ny, nz);
						//pickVO.uv = getCollisionUV(indexData, uvData, index, v, w, u, uvOffset, uvStride);
						pickVO.index = index;
						pickVO.surfaceIndex = surface3D.parentMesh.getSurfaceIndex(surface3D);
						
						// if not looking for best hit, first found will do...
						if (!findClosestCollision)
							return true;
					}
				}
			}
			
			if (collisionTriangleIndex >= 0)
				return true;
			
			return false;
		}
		
		protected function getCollisionNormal(indexData:Vector.<uint>, vertexData:Vector.<Number>, triangleIndex:uint, normal:Vector3D = null):Vector3D
		{
			var i0:uint = indexData[ triangleIndex ]*3;
			var i1:uint = indexData[ triangleIndex + 1 ]*3;
			var i2:uint = indexData[ triangleIndex + 2 ]*3;
			
			var side0x:Number = vertexData[ i1 ] - vertexData[ i0 ];
			var side0y:Number = vertexData[ i1 + 1] - vertexData[ i0 + 1];
			var side0z:Number = vertexData[ i1 + 2] - vertexData[ i0 + 2];
			var side1x:Number = vertexData[ i2 ] - vertexData[ i0 ];
			var side1y:Number = vertexData[ i2 + 1] - vertexData[ i0 + 1];
			var side1z:Number = vertexData[ i2 + 2] - vertexData[ i0 + 2];
			
			if(!normal) normal = new Vector3D();
			normal.x = side0y*side1z - side0z*side1y;
			normal.y = side0z*side1x - side0x*side1z;
			normal.z = side0x*side1y - side0y*side1x;
			normal.w = 1;
			normal.normalize();
			return normal;
		}
		
		protected function getCollisionUV(indexData:Uint16Array, uvData:Float32Array, triangleIndex:uint, v:Number, w:Number, u:Number, uvOffset:uint, uvStride:uint, uv:Vector3D = null):Vector3D
		{
			var uIndex:uint = indexData[ triangleIndex ]*uvStride + uvOffset;
			var uv0x:Number = uvData[ uIndex ];
			var uv0y:Number = uvData[ uIndex +1 ];
			uIndex = indexData[ triangleIndex + 1 ]*uvStride + uvOffset;
			var uv1x:Number = uvData[ uIndex ];
			var uv1y:Number = uvData[ uIndex +1 ];
			uIndex = indexData[ triangleIndex + 2 ]*uvStride + uvOffset;
			var uv2x:Number = uvData[ uIndex ];
			var uv2y:Number = uvData[ uIndex +1 ];
			if(!uv) uv = new Vector3D();
			uv.x = u*uv0x + v*uv1x + w*uv2x;
			uv.y = u*uv0y + v*uv1y + w*uv2y;
			return uv;
		}
		
		private function updateLocalPosition(pickVO:PickerVO):void
		{
			var collisionPos:Vector3D = pickVO.localPosition ||= new Vector3D();
			var rayDir:Vector3D = pickVO.localRayDirection;
			var rayPos:Vector3D = pickVO.localRayPosition;
			var t:Number = pickVO.distance;
			collisionPos.x = rayPos.x + t*rayDir.x;
			collisionPos.y = rayPos.y + t*rayDir.y;
			collisionPos.z = rayPos.z + t*rayDir.z;
		}
	}
}