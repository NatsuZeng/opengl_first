package specter3d.engine.core
{
	import laya.d3.math.Matrix4x4;
	import laya.d3.math.Vector3;
	import laya.events.EventDispatcher;
	
	import specter3d.engine.events.Event3D;
	import specter3d.engine.sprite3d;
	import specter3d.engine.utlis.Matrix3DUtils;
	import specter3d.engine.utlis.Vector3DUtils;
	
	
	use namespace sprite3d;
	/**
	 * Transform3D
	 * @author 回眸笑苍生
	 * 
	 */	
	public class Transform3D extends EventDispatcher
	{
		
		public function Transform3D(owner:Object3D)
		{
			this._owner=owner;
			this._local=new Matrix4x4();
			this._world=new Matrix4x4();
			this._invWorld=new Matrix4x4();
		}
		
		sprite3d var _dirty:Boolean; // ditry
		sprite3d var _dirtyInv:Boolean; // dirty
		private var _invWorld:Matrix4x4; // 逆全局矩阵
		private var _local:Matrix4x4; // 本地transform
		
		private var _owner:Object3D;
		private var _world:Matrix4x4; // 全局transform
		
		public function clone(owner:Object3D):Transform3D
		{
			owner.transform.local.copyFrom(this._local);
			owner.transform.world.copyFrom(this._world);
			owner.transform.invWorld.copyFrom(this._invWorld);
			owner.transform._dirty=this._dirty;
			owner.transform._dirtyInv=this._dirtyInv;
			return owner.transform;
		}
		
		/**
		 * 后方方向
		 * @param local
		 * @param out
		 * @return
		 *
		 */
		public function getBackward(local:Boolean=true, out:Vector3=null):Vector3
		{
			return Matrix3DUtils.getBackward(local ? this.local : this.world, out);
		}
		
		/**
		 * 前方方向
		 * @param local
		 * @param out
		 * @return
		 *
		 */
		public function getDir(local:Boolean=true, out:Vector3=null):Vector3
		{
			return Matrix3DUtils.getDir(local ? this.local : this.world, out);
		}
		
		/**
		 * 下方方向
		 * @param local
		 * @param out
		 * @return
		 *
		 */
		public function getDown(local:Boolean=true, out:Vector3=null):Vector3
		{
			return Matrix3DUtils.getDown(local ? this.local : this.world, out);
		}
		
		/**
		 * 左方方向
		 * @param local
		 * @param out
		 * @return
		 *
		 */
		public function getLeft(local:Boolean=true, out:Vector3=null):Vector3
		{
			return Matrix3DUtils.getLeft(local ? this.local : this.world, out);
		}
		
		/**
		 * 获取位移
		 * @param local		local?
		 * @param out		position
		 * @return 			position
		 */
		public function getPosition(local:Boolean=true, out:Vector3=null):Vector3
		{
			return Matrix3DUtils.getPosition(local ? this.local : this.world, out);
		}
		
		/**
		 * 右方方向
		 * @param local
		 * @param out
		 * @return
		 *
		 */
		public function getRight(local:Boolean=true, out:Vector3=null):Vector3
		{
			return Matrix3DUtils.getRight(local ? this.local : this.world, out);
		}
		
		/**
		 * 该方式是以欧拉角得方式获取，因此获取的角度值为-90到90范围。
		 * 如果想要以360度方式获取，或者其他方式。自己在外面缓存当前设置的角度值，
		 * 或者使用 getRotationX/Y/Z方式获取。该方式是通过计算dir向量来计算
		 * @param local
		 * @param out
		 * @return
		 *
		 */
		public function getRotation(local:Boolean=true, out:Vector3=null):Vector3
		{
			return Matrix3DUtils.getRotation(local ? this.local : this.world, out);
		}
		
		/**
		 * 获取rotationX值，该值范围为-180到180。使用欧拉角获取的数据只能为-90到90。因此需要根据方位计算出更大范围的值。
		 * @param local
		 * @return
		 *
		 */
		public function getRotationX(local:Boolean):Number
		{
			var dir:Vector3=getDir(local);
			var ang:Number=Math.atan2(dir.y, dir.z) * 180 / Math.PI;
			return ang;
		}
		
		/**
		 * 获取rotationY值，该值范围为-180到180。使用欧拉角获取的数据只能为-90到90。因此需要根据方位计算出更大范围的值。
		 * @param local
		 * @return
		 */
		public function getRotationY(local:Boolean):Number
		{
			var dir:Vector3=getDir(local);
			var ang:Number=Math.atan2(dir.x, dir.z) * 180 / Math.PI;
			return ang;
		}
		
		/**
		 * 获取rotationZ值，该值范围为-180到180。使用欧拉角获取的数据只能为-90到90。因此需要根据方位计算出更大范围的值。
		 * @param local
		 * @return
		 *
		 */
		public function getRotationZ(local:Boolean):Number
		{
			var dir:Vector3=getDir(local);
			var ang:Number=Math.atan2(dir.x, dir.y) * 180 / Math.PI;
			return ang;
		}
		
		/**
		 * 获取缩放值
		 * @param local		local
		 * @param out		缩放值
		 * @return			缩放值
		 *
		 */
		public function getScale(local:Boolean=true, out:Vector3=null):Vector3
		{
			return Matrix3DUtils.getScale(local ? this.local : this.world, out);
		}
		
		/**
		 * 上方方向
		 * @param local
		 * @param out
		 * @return
		 *
		 */
		public function getUp(local:Boolean=true, out:Vector3=null):Vector3
		{
			return Matrix3DUtils.getUp(local ? this.local : this.world, out);
		}
		
		/**
		 * 全局转本地
		 * @param point
		 * @param out
		 * @return
		 *
		 */
		public function globalToLocal(point:Vector3, out:Vector3=null):Vector3
		{
			return Matrix3DUtils.transformVector(this.invWorld, point, out);
		}
		
		/**
		 * 全局转本地
		 * @param vector
		 * @param out
		 * @return
		 *
		 */
		public function globalToLocalVector(vector:Vector3, out:Vector3=null):Vector3
		{
			return out=Matrix3DUtils.deltaTransformVector(this.invWorld, vector, out);
		}
		
		/**
		 * 世界逆矩阵
		 * @return
		 *
		 */
		public function get invWorld():Matrix4x4
		{
			if (this._dirty || this._dirtyInv)
			{
				this._invWorld.copyFrom(world);
				this._invWorld.invert();
				this._dirtyInv=false;
			}
			return this._invWorld
		}
		
		/**
		 * local
		 * @return
		 *
		 */
		public function get local():Matrix4x4
		{
			return _local;
		}
		
		/**
		 * 本地转全局
		 * @param point
		 * @param out
		 * @return
		 *
		 */
		public function localToGlobal(point:Vector3, out:Vector3=null):Vector3
		{
			return Matrix3DUtils.transformVector(this.world, point, out);
		}
		
		/**
		 * 本地转全局
		 * @param vector
		 * @param out
		 * @return
		 *
		 */
		public function localToGlobalVector(vector:Vector3, out:Vector3=null):Vector3
		{
			return Matrix3DUtils.deltaTransformVector(this.world, vector, out);
		}
		
		/**
		 * 设置pivot朝向。pivot会朝着目的点
		 * @param x			target x
		 * @param y			target y
		 * @param z			target z
		 * @param up		可以指定pivot的up方向，指定时候pivot会根据该up方向来确定朝向方位。
		 * @param smooth	插值
		 *
		 */
		public function lookAt(x:Number, y:Number, z:Number, up:Vector3=null, smooth:Number=1):void
		{
			Matrix3DUtils.lookAt(this.local, x, y, z, up, smooth);
			this.updateTransforms(true);
		}
		
		/**
		 * 绕着指定轴线进行旋转
		 * @param angle			角度
		 * @param axis			轴
		 * @param pivotPoint  	参照点，默认为自身。
		 *
		 */
		public function rotateAxis(angle:Number, axis:Vector3, pivotPoint:Vector3=null):void
		{
			Matrix3DUtils.rotateAxis(this.local, angle, axis, pivotPoint);
			this.updateTransforms(true);
			if (hasListener(Event3D.ROTATION_CHANGED))
			{
				event(Event3D.ROTATION_CHANGED);
			}
		}
		
		/**
		 * 会在上一次的基础上进行旋转。例:当前角度为30,旋转角度为15，那么结果角度就为45而不是15。setRotation(x,y,z)属于直接设置值
		 * @param angle			角度
		 * @param local
		 * @param pivotPoint	旋转参照点。例如pivotPoint->(0, 0, 0)，那么pivot会绕着0,0,0进行旋转，默认为自身。
		 *
		 */
		public function rotateX(angle:Number, local:Boolean=true, pivotPoint:Vector3=null):void
		{
			Matrix3DUtils.rotateX(this.local, angle, local, pivotPoint);
			this.updateTransforms(true);
			if (hasListener(Event3D.ROTATION_CHANGED))
			{
				event(Event3D.ROTATION_CHANGED);
			}
		}
		
		/**
		 * 会在上一次的基础上进行旋转。例:当前角度为30,旋转角度为15，那么结果角度就为45而不是15。setRotation(x,y,z)属于直接设置值
		 * @param angle			角度
		 * @param local
		 * @param pivotPoint	旋转参照点。例如pivotPoint->(0, 0, 0)，那么pivot会绕着0,0,0进行旋转，默认为自身。
		 *
		 */
		public function rotateY(angle:Number, local:Boolean=true, pivotPoint:Vector3=null):void
		{
			Matrix3DUtils.rotateY(this.local, angle, local, pivotPoint);
			this.updateTransforms(true);
			if (hasListener(Event3D.ROTATION_CHANGED))
			{
				event(Event3D.ROTATION_CHANGED);
			}
		}
		
		/**
		 * 会在上一次的基础上进行旋转。例:当前角度为30,旋转角度为15，那么结果角度就为45而不是15。setRotation(x,y,z)属于直接设置值
		 * @param angle			角度
		 * @param local
		 * @param pivotPoint	旋转参照点。例如pivotPoint->(0, 0, 0)，那么pivot会绕着0,0,0进行旋转，默认为自身。
		 *
		 */
		public function rotateZ(angle:Number, local:Boolean=true, pivotPoint:Vector3=null):void
		{
			Matrix3DUtils.rotateZ(this.local, angle, local, pivotPoint);
			this.updateTransforms(true);
			if (hasListener(Event3D.ROTATION_CHANGED))
			{
				event(Event3D.ROTATION_CHANGED);
			}
		}
		
		/**
		 * 获取x轴缩放值
		 * @return
		 *
		 */
		public function get scaleX():Number
		{
			return Matrix3DUtils.getRight(this.local, Vector3DUtils.vec0).length;
		}
		
		/**
		 * 设置x轴缩放值
		 * @param val
		 *
		 */
		public function set scaleX(val:Number):void
		{
			Matrix3DUtils.scaleX(this.local, val);
			this.updateTransforms(true);
			if (hasListener(Event3D.SCALE_CHANGED))
			{
				event(Event3D.SCALE_CHANGED);
			}
		}
		
		/**
		 * 获取y轴缩放值
		 * @return
		 *
		 */
		public function get scaleY():Number
		{
			return Matrix3DUtils.getUp(this.local, Vector3DUtils.vec0).length;
		}
		
		/**
		 * 设置y轴缩放值
		 * @param val
		 *
		 */
		public function set scaleY(val:Number):void
		{
			Matrix3DUtils.scaleY(this.local, val);
			this.updateTransforms(true);
			if (hasListener(Event3D.SCALE_CHANGED))
			{
				event(Event3D.SCALE_CHANGED);
			}
		}
		
		/**
		 * 获取z轴缩放值
		 * @return
		 *
		 */
		public function get scaleZ():Number
		{
			return Matrix3DUtils.getDir(this.local, Vector3DUtils.vec0).length;
		}
		
		/**
		 * 设置z轴缩放值
		 * @param val
		 *
		 */
		public function set scaleZ(val:Number):void
		{
			Matrix3DUtils.scaleZ(this.local, val);
			this.updateTransforms(true);
			if (hasListener(Event3D.SCALE_CHANGED))
			{
				event(Event3D.SCALE_CHANGED);
			}
		}
		
		/**
		 * 设置朝向，例如面向摄像机
		 * @param dir		朝向
		 * @param up		up vector
		 * @param smooth	插值
		 */
		public function setOrientation(dir:Vector3, up:Vector3=null, smooth:Number=1):void
		{
			Matrix3DUtils.setOrientation(this.local, dir, up, smooth);
			this.updateTransforms(true);
		}
		
		/**
		 * 设置坐标
		 * @param x			x
		 * @param y			y
		 * @param z			z
		 * @param smooth
		 * @param local
		 *
		 */
		public function setPosition(x:Number, y:Number, z:Number, smooth:Number=1):void
		{
			Matrix3DUtils.setPosition(this.local, x, y, z, smooth);
			this.updateTransforms(true);
			if (hasListener(Event3D.POSITION_CHANGED))
			{
				event(Event3D.POSITION_CHANGED);
			}
		}
		
		/**
		 * 设置Rotation
		 * @param x
		 * @param y
		 * @param z
		 *
		 */
		public function setRotation(x:Number, y:Number, z:Number):void
		{
			Matrix3DUtils.setRotation(this.local, x, y, z);
			this.updateTransforms(true);
			if (hasListener(Event3D.ROTATION_CHANGED))
			{
				event(Event3D.ROTATION_CHANGED);
			}
		}
		
		/**
		 * 设置缩放
		 * @param x			x轴缩放
		 * @param y			y轴缩放
		 * @param z			z轴缩放
		 * @param smooth	插值
		 *
		 */
		public function setScale(x:Number, y:Number, z:Number, smooth:Number=1):void
		{
			Matrix3DUtils.setScale(this.local, x, y, z, smooth);
			this.updateTransforms(true);
			if (hasListener(Event3D.SCALE_CHANGED))
			{
				event(Event3D.SCALE_CHANGED);
			}
		}
		
		/**
		 * 设置pivot位移。该位移以世界坐标轴为参照物。
		 * @param x
		 * @param y
		 * @param z
		 * @param local
		 *
		 */
		public function setTranslation(x:Number=0, y:Number=0, z:Number=0, local:Boolean=true):void
		{
			Matrix3DUtils.setTranslation(this.local, x, y, z, local);
			this.updateTransforms(true);
			if (hasListener(Event3D.POSITION_CHANGED))
			{
				event(Event3D.POSITION_CHANGED);
			}
		}
		
		public function translateAxis(distance:Number, axis:Vector3):void
		{
			Matrix3DUtils.translateAxis(this.local, distance, axis);
			this.updateTransforms(true);
			if (hasListener(Event3D.POSITION_CHANGED))
			{
				event(Event3D.POSITION_CHANGED);
			}
		}
		
		public function translateX(distance:Number, local:Boolean=true):void
		{
			Matrix3DUtils.translateX(this.local, distance, local);
			this.updateTransforms(true);
			if (hasListener(Event3D.POSITION_CHANGED))
			{
				event(Event3D.POSITION_CHANGED);
			}
		}
		
		public function translateY(distance:Number, local:Boolean=true):void
		{
			Matrix3DUtils.translateY(this.local, distance, local);
			this.updateTransforms(true);
			if (hasListener(Event3D.POSITION_CHANGED))
			{
				event(Event3D.POSITION_CHANGED);
			}
		}
		
		public function translateZ(distance:Number, local:Boolean=true):void
		{
			Matrix3DUtils.translateZ(this.local, distance, local);
			this.updateTransforms(true);
			if (hasListener(Event3D.POSITION_CHANGED))
			{
				event(Event3D.POSITION_CHANGED);
			}
		}
		
		/**
		 * update transform
		 * @param includeChildren
		 *
		 */
		public function updateTransforms(includeChildren:Boolean):void
		{
			this._dirty=true;
			this._dirtyInv=true;
			if (includeChildren)
			{
				for (var object:Object3D=_owner._childrenList; object != null; object=object._next)
				{
					object.transform.updateTransforms(includeChildren);
				}
			}
			if (this.hasListener(Event3D.UPDATE_TRANSFORM))
			{
				this.event(Event3D.UPDATE_TRANSFORM);
			}
		}
		
		/**
		 * world
		 * @return
		 *
		 */
		public function get world():Matrix4x4
		{
			if (this._dirty)
			{
				this._world.copyFrom(local);
				if (_owner.parent)
				{
					this._world.append(_owner.parent.transform.world);
				}
				this._dirty=false;
				this._dirtyInv=true;
			}
			return _world;
		}
		
		public function set world(value:Matrix4x4):void
		{
			this.local.copyFrom(value);
			if (_owner.parent)
			{
				this.local.append(_owner.parent.transform.invWorld);
			}
			this.updateTransforms(true);
		}
		
		/**
		 * 获取x坐标
		 * @return
		 *
		 */
		public function get x():Number
		{
			this.local.copyColumnTo(3, Vector3DUtils.vec0);
			return Vector3DUtils.vec0.x;
		}
		
		/**
		 * 设置x坐标
		 * @param val
		 *
		 */
		public function set x(val:Number):void
		{
			this.local.copyColumnTo(3, Vector3DUtils.vec0);
			Vector3DUtils.vec0.x=val;
			this.local.copyColumnFrom(3, Vector3DUtils.vec0);
			this.updateTransforms(true);
			if (hasListener(Event3D.POSITION_CHANGED))
			{
				event(Event3D.POSITION_CHANGED);
			}
		}
		
		/**
		 * 获取y坐标
		 * @return
		 *
		 */
		public function get y():Number
		{
			this.local.copyColumnTo(3, Vector3DUtils.vec0);
			return Vector3DUtils.vec0.y;
		}
		
		/**
		 * 设置y坐标
		 * @param val
		 *
		 */
		public function set y(val:Number):void
		{
			this.local.copyColumnTo(3, Vector3DUtils.vec0);
			Vector3DUtils.vec0.y=val;
			this.local.copyColumnFrom(3, Vector3DUtils.vec0);
			this.updateTransforms(true);
			if (hasListener(Event3D.POSITION_CHANGED))
			{
				event(Event3D.POSITION_CHANGED);
			}
		}
		
		/**
		 * 获取z坐标
		 * @return
		 *
		 */
		public function get z():Number
		{
			this.local.copyColumnTo(3, Vector3DUtils.vec0);
			return Vector3DUtils.vec0.z;
		}
		
		/**
		 * 设置z坐标
		 * @param val
		 *
		 */
		public function set z(val:Number):void
		{
			this.local.copyColumnTo(3, Vector3DUtils.vec0);
			Vector3DUtils.vec0.z=val;
			this.local.copyColumnFrom(3, Vector3DUtils.vec0);
			this.updateTransforms(true);
			if (hasListener(Event3D.POSITION_CHANGED))
			{
				event(Event3D.POSITION_CHANGED);
			}
		}
	}
}
