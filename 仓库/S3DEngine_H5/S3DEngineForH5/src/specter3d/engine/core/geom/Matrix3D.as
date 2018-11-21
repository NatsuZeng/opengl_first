package specter3d.engine.core.geom
{
	/**
	 * Matrix3D 
	 * @author wangcx
	 * 
	 */	
	public class Matrix3D
	{

		private static var _mt:Matrix3D=new Matrix3D();

		/**
		 *
		 * @param u
		 * @param v
		 * @param w
		 * @param a
		 * @param b
		 * @param c
		 * @param degress
		 * @param m
		 */
		public static function getAxisRotation(u:Number, v:Number, w:Number, a:Number, b:Number, c:Number, degress:Number, m:Matrix3D):void
		{

			var rad:Number=degress / 180.0 * Math.PI;

			var u2:Number=u * u;
			var v2:Number=v * v;
			var w2:Number=w * w;
			var l2:Number=u2 + v2 + w2;
			var l:Number=Math.sqrt(l2);

			u/=l;
			v/=l;
			w/=l;
			u2/=l2;
			v2/=l2;
			w2/=l2;

			var cos:Number=Math.cos(rad);
			var sin:Number=Math.sin(rad);

			m.rawData[0]=u2 + (v2 + w2) * cos;
			m.rawData[1]=u * v * (1 - cos) + w * sin;
			m.rawData[2]=u * w * (1 - cos) - v * sin;
			m.rawData[3]=0;

			m.rawData[4]=u * v * (1 - cos) - w * sin;
			m.rawData[5]=v2 + (u2 + w2) * cos;
			m.rawData[6]=v * w * (1 - cos) + u * sin;
			m.rawData[7]=0;

			m.rawData[8]=u * w * (1 - cos) + v * sin;
			m.rawData[9]=v * w * (1 - cos) - u * sin;
			m.rawData[10]=w2 + (u2 + v2) * cos;
			m.rawData[11]=0;

			m.rawData[12]=(a * (v2 + w2) - u * (b * v + c * w)) * (1 - cos) + (b * w - c * v) * sin;
			m.rawData[13]=(b * (u2 + w2) - v * (a * u + c * w)) * (1 - cos) + (c * u - a * w) * sin;
			m.rawData[14]=(c * (u2 + v2) - w * (a * u + b * v)) * (1 - cos) + (a * v - b * u) * sin;
			m.rawData[15]=1;

		}

		/**
		 *
		 */
		public function Matrix3D()
		{
			identity();
		}
		/**矩阵元素数组*/
		public var rawData:Float32Array=new Float32Array(16);

		/**
		 * 通过将另一个 Matrix3D 对象与当前 Matrix3D 对象相乘来后置一个矩阵。
		 * @param lhs
		 *
		 */
		public function append(lhs:Matrix3D):void
		{
			var m111:Number=rawData[0];
			var m121:Number=rawData[4];
			var m131:Number=rawData[8];
			var m141:Number=rawData[12];

			var m112:Number=rawData[1];
			var m122:Number=rawData[5];
			var m132:Number=rawData[9];
			var m142:Number=rawData[13];

			var m113:Number=rawData[2];
			var m123:Number=rawData[6];
			var m133:Number=rawData[10];
			var m143:Number=rawData[14];

			var m114:Number=rawData[3];
			var m124:Number=rawData[7];
			var m134:Number=rawData[11];
			var m144:Number=rawData[15];

			var m211:Number=lhs.rawData[0];
			var m221:Number=lhs.rawData[4];
			var m231:Number=lhs.rawData[8];
			var m241:Number=lhs.rawData[12];

			var m212:Number=lhs.rawData[1];
			var m222:Number=lhs.rawData[5];
			var m232:Number=lhs.rawData[9];
			var m242:Number=lhs.rawData[13];

			var m213:Number=lhs.rawData[2];
			var m223:Number=lhs.rawData[6];
			var m233:Number=lhs.rawData[10];
			var m243:Number=lhs.rawData[14];

			var m214:Number=lhs.rawData[3];
			var m224:Number=lhs.rawData[7];
			var m234:Number=lhs.rawData[11];
			var m244:Number=lhs.rawData[15];

			rawData[0]=m111 * m211 + m112 * m221 + m113 * m231 + m114 * m241;
			rawData[1]=m111 * m212 + m112 * m222 + m113 * m232 + m114 * m242;
			rawData[2]=m111 * m213 + m112 * m223 + m113 * m233 + m114 * m243;
			rawData[3]=m111 * m214 + m112 * m224 + m113 * m234 + m114 * m244;

			rawData[4]=m121 * m211 + m122 * m221 + m123 * m231 + m124 * m241;
			rawData[5]=m121 * m212 + m122 * m222 + m123 * m232 + m124 * m242;
			rawData[6]=m121 * m213 + m122 * m223 + m123 * m233 + m124 * m243;
			rawData[7]=m121 * m214 + m122 * m224 + m123 * m234 + m124 * m244;

			rawData[8]=m131 * m211 + m132 * m221 + m133 * m231 + m134 * m241;
			rawData[9]=m131 * m212 + m132 * m222 + m133 * m232 + m134 * m242;
			rawData[10]=m131 * m213 + m132 * m223 + m133 * m233 + m134 * m243;
			rawData[11]=m131 * m214 + m132 * m224 + m133 * m234 + m134 * m244;

			rawData[12]=m141 * m211 + m142 * m221 + m143 * m231 + m144 * m241;
			rawData[13]=m141 * m212 + m142 * m222 + m143 * m232 + m144 * m242;
			rawData[14]=m141 * m213 + m142 * m223 + m143 * m233 + m144 * m243;
			rawData[15]=m141 * m214 + m142 * m224 + m143 * m234 + m144 * m244;

		}

		/**
		 * 在 Matrix3D 对象上后置一个增量旋转。
		 * @param degrees
		 * @param axis
		 * @param pivot
		 *
		 */
		public function appendRotation(degrees:Number, axis:Vector3D, pivot:Vector3D):void
		{

			if (pivot)
			{
				getAxisRotation(axis.x, axis.y, axis.z, pivot.x, pivot.y, pivot.z, degrees, _mt);
			}
			else
			{
				getAxisRotation(axis.x, axis.y, axis.z, 0, 0, 0, degrees, _mt);
			}
			append(_mt);
		}

		/**
		 * 在 Matrix3D 对象上后置一个增量缩放，沿 x、y 和 z 轴改变位置。
		 * @param x
		 * @param y
		 * @param z
		 *
		 */
		public function appendScale(x:Number, y:Number, z:Number):void
		{
			var v:Float32Array=new Float32Array([x, 0.0, 0.0, 0.0, 0.0, y, 0.0, 0.0, 0.0, 0.0, z, 0.0, 0.0, 0.0, 0.0, 1.0]);
			_mt.copyRawDataFrom(v);
			append(_mt);
		}

		/**
		 * 在 Matrix3D 对象上后置一个增量平移，沿 x、y 和 z 轴重新定位。
		 * @param x
		 * @param y
		 * @param z
		 *
		 */
		public function appendTranslation(x:Number, y:Number, z:Number):void
		{
			rawData[12]+=x;
			rawData[13]+=y;
			rawData[14]+=z;
		}

		/**
		 * 将 Vector3D 对象复制到调用方 Matrix3D 对象的特定列中。
		 * @param column
		 * @param vec
		 *
		 */
		public function copyColumnFrom(column:int, vec:Vector3D):void
		{
			rawData[column * 4 + 0]=vec.x;
			rawData[column * 4 + 1]=vec.y;
			rawData[column * 4 + 2]=vec.z;
			rawData[column * 4 + 3]=vec.w;
		}

		/**
		 * 将调用方 Matrix3D 对象的特定列复制到 Vector3D 对象中。
		 * @param column
		 * @param vec
		 *
		 */
		public function copyColumnTo(column:int, vec:Vector3D):void
		{
			vec.x=rawData[column * 4 + 0];
			vec.y=rawData[column * 4 + 1];
			vec.z=rawData[column * 4 + 2];
			vec.w=rawData[column * 4 + 3];
		}

		/**
		 * 将源 Matrix3D 对象中的所有矩阵数据复制到调用方 Matrix3D 对象中。
		 * @param mt
		 *
		 */
		public function copyFrom(mt:Matrix3D):void
		{
			for (var i:int=0; i < 16; i++)
			{
				rawData[i]=mt.rawData[i];
			}
		}
		
		public function clone():Matrix3D
		{
			var cloneMatrix:Matrix3D = new Matrix3D();
			cloneMatrix.copyFrom(this);
			return cloneMatrix;
		}

		/**
		 * 将源 Vector 对象中的所有矢量数据复制到调用方 Matrix3D 对象中。
		 * @param vec
		 *
		 */
		public function copyRawDataFrom(vec:Float32Array):void
		{
			for (var i:int=0; i < 16; i++)
			{
				rawData[i]=vec[i];
			}
		}

		/**
		 * 将调用方 Matrix3D 对象中的所有矩阵数据复制到提供的矢量中。
		 * @param vec
		 *
		 */
		public function copyRawDataTo(vec:Float32Array):void
		{
			for (var i:int=0; i < 16; i++)
			{
				vec[i]=rawData[i];
			}
		}

		/**
		 * 将 Vector3D 对象复制到调用方 Matrix3D 对象的特定行中。
		 * @param raw
		 * @param vec
		 *
		 */
		public function copyRawFrom(raw:int, vec:Vector3D):void
		{
			rawData[raw + 0]=vec.x;
			rawData[raw + 4]=vec.y;
			rawData[raw + 8]=vec.z;
			rawData[raw + 12]=vec.w;
		}

		/**
		 * 将调用方 Matrix3D 对象的特定行复制到 Vector3D 对象中。
		 * @param raw
		 * @param vec
		 *
		 */
		public function copyRawTo(raw:int, vec:Vector3D):void
		{
			vec.x=rawData[raw + 0];
			vec.y=rawData[raw + 4];
			vec.z=rawData[raw + 8];
			vec.w=rawData[raw + 12];
		}

		/**
		 * 获取矩阵数据
		 * @param dest
		 */
		public function copyToMatrix3D(dest:Matrix3D):void
		{
			for (var i:int=0; i < 16; i++)
			{
				dest.rawData[i]=rawData[i];
			}
		}

		/**
		 * 将转换矩阵的平移、旋转和缩放设置作为由三个 Vector3D 对象组成的矢量返回。
		 * @param style
		 * @param vec
		 *
		 */
		public function decompose(orientationStyle:String, vec:Vector.<Vector3D>):void
		{

			var mr:Float32Array=new Float32Array([0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0])
			copyRawDataTo(mr);
			// postion
			vec[0].x=mr[12];
			vec[0].y=mr[13];
			vec[0].z=mr[14];

			mr[12]=mr[13]=mr[14]=0.0;
			// scale
			vec[2].x=Math.sqrt(mr[0] * mr[0] + mr[1] * mr[1] + mr[2] * mr[2]);
			vec[2].y=Math.sqrt(mr[4] * mr[4] + mr[5] * mr[5] + mr[6] * mr[6]);
			vec[2].z=Math.sqrt(mr[8] * mr[8] + mr[9] * mr[9] + mr[10] * mr[10]);

			if (mr[0] * (mr[5] * mr[10] - mr[6] * mr[9]) - mr[1] * (mr[4] * mr[10] - mr[6] * mr[8]) + mr[2] * (mr[4] * mr[9] - mr[5] * mr[8]) < 0)
				vec[2].z=-vec[2].z;

			mr[0]/=vec[2].x;
			mr[1]/=vec[2].x;
			mr[2]/=vec[2].x;
			mr[4]/=vec[2].y;
			mr[5]/=vec[2].y;
			mr[6]/=vec[2].y;
			mr[8]/=vec[2].z;
			mr[9]/=vec[2].z;
			mr[10]/=vec[2].z;

			if (orientationStyle == OrientationStyle.EulerAngles)
			{
				vec[1].y=Math.asin(-mr[2]);
				if (mr[2] != 1 && mr[2] != -1)
				{
					vec[1].x=Math.atan2(mr[6], mr[10]);
					vec[1].z=Math.atan2(mr[1], mr[0]);
				}
				else
				{
					vec[1].z=0;
					vec[1].x=Math.atan2(mr[4], mr[5]);
				}
			}
			else if (orientationStyle == OrientationStyle.AxisAngle)
			{
				vec[1].w=Math.acos((mr[0] + mr[5] + mr[10] - 1) / 2);
				var len:Number=Math.sqrt((mr[6] - mr[9]) * (mr[6] - mr[9]) + (mr[8] - mr[2]) * (mr[8] - mr[2]) + (mr[1] - mr[4]) * (mr[1] - mr[4]));
				vec[1].x=(mr[6] - mr[9]) / len;
				vec[1].y=(mr[8] - mr[2]) / len;
				vec[1].z=(mr[1] - mr[4]) / len;
			}
			else if (orientationStyle == OrientationStyle.Quaternion)
			{
				var tr:Number=mr[0] + mr[5] + mr[10];
				if (tr > 0)
				{
					vec[1].w=Math.sqrt(1 + tr) / 2;
					vec[1].x=(mr[6] - mr[9]) / (4 * vec[1].w);
					vec[1].y=(mr[8] - mr[2]) / (4 * vec[1].w);
					vec[1].z=(mr[1] - mr[4]) / (4 * vec[1].w);
				}
				else if ((mr[0] > mr[5]) && (mr[0] > mr[10]))
				{
					vec[1].x=Math.sqrt(1 + mr[0] - mr[5] - mr[10]) / 2;
					vec[1].w=(mr[6] - mr[9]) / (4 * vec[1].x);
					vec[1].y=(mr[1] + mr[4]) / (4 * vec[1].x);
					vec[1].z=(mr[8] + mr[2]) / (4 * vec[1].x);
				}
				else
				{
					vec[1].z=Math.sqrt(1 + mr[10] - mr[0] - mr[5]) / 2;
					vec[1].x=(mr[8] + mr[2]) / (4 * vec[1].z);
					vec[1].y=(mr[6] + mr[9]) / (4 * vec[1].z);
					vec[1].w=(mr[1] - mr[4]) / (4 * vec[1].z);
				}
			}
		}

		/**
		 * 可逆
		 * @return
		 */
		public function determinant():Number
		{
			return ((rawData[0] * rawData[5] - rawData[4] * rawData[1]) * (rawData[10] * rawData[15] - rawData[14] * rawData[11]) - (rawData[0] * rawData[9] - rawData[8] * rawData[1]) * (rawData[6] * rawData[15] - rawData[14] * rawData[7]) + (rawData[0] * rawData[13] - rawData[12] * rawData[1]) * (rawData[6] * rawData[11] - rawData[10] * rawData[7]) + (rawData[4] * rawData[9] - rawData[8] * rawData[5]) * (rawData[2] * rawData[15] - rawData[14] * rawData[3]) - (rawData[4] * rawData[13] - rawData[12] * rawData[5]) * (rawData[2] * rawData[11] - rawData[10] * rawData[3]) + (rawData[8] * rawData[13] - rawData[12] * rawData[9]) * (rawData[2] * rawData[7] - rawData[6] * rawData[3]));
		}

		/**
		 * 将当前矩阵转换为恒等或单位矩阵。
		 *
		 */
		public function identity():void
		{
			rawData[0]=1.0;
			rawData[1]=0.0;
			rawData[2]=0.0;
			rawData[3]=0.0;

			rawData[4]=0.0;
			rawData[5]=1.0;
			rawData[6]=0.0;
			rawData[7]=0.0;

			rawData[8]=0.0;
			rawData[9]=0.0;
			rawData[10]=1.0;
			rawData[11]=0.0;

			rawData[12]=0.0;
			rawData[13]=0.0;
			rawData[14]=0.0;
			rawData[15]=1.0;

		}

		/**
		 * 朝着目标矩阵的平移、旋转和缩放转换插补此矩阵。
		 * @param dest
		 * @param percent
		 *
		 */
		public function interpolateTo(dest:Matrix3D, percent:Number):void
		{
			for (var i:int=0; i < 16; i++)
			{
				dest.rawData[i]=rawData[i] + (dest.rawData[i] - rawData[i]) * percent;
			}
		}

		/**
		 * 反转当前矩阵。
		 *
		 */
		public function invert():void
		{
			var d:Number=determinant();
			if (d < 0.0)
			{
				d=-d;
			}
			var invertable:Boolean=d > 0.00000000001;
			if (invertable)
			{
				d=1 / d;
				var m11:Number=rawData[0];
				var m21:Number=rawData[4];
				var m31:Number=rawData[8];
				var m41:Number=rawData[12];
				var m12:Number=rawData[1];
				var m22:Number=rawData[5];
				var m32:Number=rawData[9];
				var m42:Number=rawData[13];
				var m13:Number=rawData[2];
				var m23:Number=rawData[6];
				var m33:Number=rawData[10];
				var m43:Number=rawData[14];
				var m14:Number=rawData[3];
				var m24:Number=rawData[7];
				var m34:Number=rawData[11];
				var m44:Number=rawData[15];

				rawData[0]=d * (m22 * (m33 * m44 - m43 * m34) - m32 * (m23 * m44 - m43 * m24) + m42 * (m23 * m34 - m33 * m24));
				rawData[1]=-d * (m12 * (m33 * m44 - m43 * m34) - m32 * (m13 * m44 - m43 * m14) + m42 * (m13 * m34 - m33 * m14));
				rawData[2]=d * (m12 * (m23 * m44 - m43 * m24) - m22 * (m13 * m44 - m43 * m14) + m42 * (m13 * m24 - m23 * m14));
				rawData[3]=-d * (m12 * (m23 * m34 - m33 * m24) - m22 * (m13 * m34 - m33 * m14) + m32 * (m13 * m24 - m23 * m14));
				rawData[4]=-d * (m21 * (m33 * m44 - m43 * m34) - m31 * (m23 * m44 - m43 * m24) + m41 * (m23 * m34 - m33 * m24));
				rawData[5]=d * (m11 * (m33 * m44 - m43 * m34) - m31 * (m13 * m44 - m43 * m14) + m41 * (m13 * m34 - m33 * m14));
				rawData[6]=-d * (m11 * (m23 * m44 - m43 * m24) - m21 * (m13 * m44 - m43 * m14) + m41 * (m13 * m24 - m23 * m14));
				rawData[7]=d * (m11 * (m23 * m34 - m33 * m24) - m21 * (m13 * m34 - m33 * m14) + m31 * (m13 * m24 - m23 * m14));
				rawData[8]=d * (m21 * (m32 * m44 - m42 * m34) - m31 * (m22 * m44 - m42 * m24) + m41 * (m22 * m34 - m32 * m24));
				rawData[9]=-d * (m11 * (m32 * m44 - m42 * m34) - m31 * (m12 * m44 - m42 * m14) + m41 * (m12 * m34 - m32 * m14));
				rawData[10]=d * (m11 * (m22 * m44 - m42 * m24) - m21 * (m12 * m44 - m42 * m14) + m41 * (m12 * m24 - m22 * m14));
				rawData[11]=-d * (m11 * (m22 * m34 - m32 * m24) - m21 * (m12 * m34 - m32 * m14) + m31 * (m12 * m24 - m22 * m14));
				rawData[12]=-d * (m21 * (m32 * m43 - m42 * m33) - m31 * (m22 * m43 - m42 * m23) + m41 * (m22 * m33 - m32 * m23));
				rawData[13]=d * (m11 * (m32 * m43 - m42 * m33) - m31 * (m12 * m43 - m42 * m13) + m41 * (m12 * m33 - m32 * m13));
				rawData[14]=-d * (m11 * (m22 * m43 - m42 * m23) - m21 * (m12 * m43 - m42 * m13) + m41 * (m12 * m23 - m22 * m13));
				rawData[15]=d * (m11 * (m22 * m33 - m32 * m23) - m21 * (m12 * m33 - m32 * m13) + m31 * (m12 * m23 - m22 * m13));
			}
		}

		/**
		 * 通过将当前 Matrix3D 对象与另一个 Matrix3D 对象相乘来前置一个矩阵。
		 * @param rhs
		 *
		 */
		public function prepend(rhs:Matrix3D):void
		{

			var m111:Number=rhs.rawData[0];
			var m121:Number=rhs.rawData[4];
			var m131:Number=rhs.rawData[8];
			var m141:Number=rhs.rawData[12];
			var m112:Number=rhs.rawData[1];
			var m122:Number=rhs.rawData[5];
			var m132:Number=rhs.rawData[9];
			var m142:Number=rhs.rawData[13];
			var m113:Number=rhs.rawData[2];
			var m123:Number=rhs.rawData[6];
			var m133:Number=rhs.rawData[10];
			var m143:Number=rhs.rawData[14];
			var m114:Number=rhs.rawData[3];
			var m124:Number=rhs.rawData[7];
			var m134:Number=rhs.rawData[11];
			var m144:Number=rhs.rawData[15];
			var m211:Number=rawData[0];
			var m221:Number=rawData[4];
			var m231:Number=rawData[8];
			var m241:Number=rawData[12];
			var m212:Number=rawData[1];
			var m222:Number=rawData[5];
			var m232:Number=rawData[9];
			var m242:Number=rawData[13];
			var m213:Number=rawData[2];
			var m223:Number=rawData[6];
			var m233:Number=rawData[10];
			var m243:Number=rawData[14];
			var m214:Number=rawData[3];
			var m224:Number=rawData[7];
			var m234:Number=rawData[11];
			var m244:Number=rawData[15];

			rawData[0]=m111 * m211 + m112 * m221 + m113 * m231 + m114 * m241;
			rawData[1]=m111 * m212 + m112 * m222 + m113 * m232 + m114 * m242;
			rawData[2]=m111 * m213 + m112 * m223 + m113 * m233 + m114 * m243;
			rawData[3]=m111 * m214 + m112 * m224 + m113 * m234 + m114 * m244;

			rawData[4]=m121 * m211 + m122 * m221 + m123 * m231 + m124 * m241;
			rawData[5]=m121 * m212 + m122 * m222 + m123 * m232 + m124 * m242;
			rawData[6]=m121 * m213 + m122 * m223 + m123 * m233 + m124 * m243;
			rawData[7]=m121 * m214 + m122 * m224 + m123 * m234 + m124 * m244;

			rawData[8]=m131 * m211 + m132 * m221 + m133 * m231 + m134 * m241;
			rawData[9]=m131 * m212 + m132 * m222 + m133 * m232 + m134 * m242;
			rawData[10]=m131 * m213 + m132 * m223 + m133 * m233 + m134 * m243;
			rawData[11]=m131 * m214 + m132 * m224 + m133 * m234 + m134 * m244;

			rawData[12]=m141 * m211 + m142 * m221 + m143 * m231 + m144 * m241;
			rawData[13]=m141 * m212 + m142 * m222 + m143 * m232 + m144 * m242;
			rawData[14]=m141 * m213 + m142 * m223 + m143 * m233 + m144 * m243;
			rawData[15]=m141 * m214 + m142 * m224 + m143 * m234 + m144 * m244;
		}

		/**
		 * 在 Matrix3D 对象上前置一个增量旋转。
		 * @param degrees
		 * @param axis
		 * @param pivot
		 *
		 */
		public function prependRotation(degrees:Number, axis:Vector3D, pivot:Vector3D):void
		{
			if (pivot)
			{
				getAxisRotation(axis.x, axis.y, axis.y, pivot.x, pivot.y, pivot.z, degrees, _mt);
			}
			else
			{
				getAxisRotation(axis.x, axis.y, axis.y, 0, 0, 0, degrees, _mt);
			}
			prepend(_mt);
		}

		/**
		 * 在 Matrix3D 对象上前置一个增量缩放，沿 x、y 和 z 轴改变位置
		 * @param x
		 * @param y
		 * @param z
		 *
		 */
		public function prependScale(x:Number, y:Number, z:Number):void
		{
			var v:Float32Array=new Float32Array([x, 0, 0, 0, 0, y, 0, 0, 0, 0, z, 0, 0, 0, 0, 1]);
			_mt.copyRawDataFrom(v);
			prepend(_mt);
		}

		/**
		 * 在 Matrix3D 对象上前置一个增量平移，沿 x、y 和 z 轴重新定位。
		 * @param x
		 * @param y
		 * @param z
		 *
		 */
		public function prependTranslation(x:Number, y:Number, z:Number):void
		{
			_mt.identity();
			_mt.setPosition(x, y, z);
			prepend(_mt);
		}

		/**
		 * 设置转换矩阵的平移、旋转和缩放设置。
		 * @param components
		 *
		 */
		public function recompose(components:Vector.<Vector3D>):void
		{
			identity();
			appendScale(components[2].x, components[2].y, components[2].z);

			var angle:Number=-components[1].x;
			var v:Float32Array=new Float32Array([1, 0, 0, 0, 0, Math.cos(angle), -Math.sin(angle), 0, 0, Math.sin(angle), Math.cos(angle), 0, 0, 0, 0, 0]);
			_mt.copyRawDataFrom(v);
			append(_mt);

			angle=-components[1].y;
			var v0:Float32Array=new Float32Array([Math.cos(angle), 0, Math.sin(angle), 0, 0, 1, 0, 0, -Math.sin(angle), 0, Math.cos(angle), 0, 0, 0, 0, 0]);
			_mt.copyRawDataFrom(v0);
			append(_mt);

			angle=-components[1].z;
			var v1:Float32Array=new Float32Array([Math.cos(angle), -Math.sin(angle), 0, 0, Math.sin(angle), Math.cos(angle), 0, 0, 0, 0, 1, 0, 0, 0, 0, 0]);
			_mt.copyRawDataFrom(v1);
			append(_mt);
			setPosition(components[0].x,components[0].y,components[0].z);
			rawData[15]=1.0;
		}

		/**
		 * 设置位移
		 * @param x
		 * @param y
		 * @param z
		 */
		public function setPosition(x:Number, y:Number, z:Number):void
		{
			rawData[12]=x;
			rawData[13]=y;
			rawData[14]=z;
		}

		/**
		 * 设置位移
		 * @param position
		 */
		public function setPosition2(position:Vector3D):void
		{
			rawData[12]=position.x;
			rawData[13]=position.y;
			rawData[14]=position.z;
		}

		/**
		 * 使用转换矩阵将 Vector3D 对象从一个空间坐标转换到另一个空间坐标。
		 * @param _in
		 * @param _out
		 *
		 */
		public function transformVector(_in:Vector3D, _out:Vector3D = null):Vector3D
		{
			if(!_out)
				_out = new Vector3D();
			var x:Number=_in.x;
			var y:Number=_in.y;
			var z:Number=_in.z;
			_out.x=(x * rawData[0] + y * rawData[4] + z * rawData[8] + rawData[12]);
			_out.y=(x * rawData[1] + y * rawData[5] + z * rawData[9] + rawData[13]);
			_out.z=(x * rawData[2] + y * rawData[6] + z * rawData[10] + rawData[14]);
			_out.w=(x * rawData[3] + y * rawData[7] + z * rawData[11] + rawData[15]);
			return _out;
		}

		/**
		 * 使用转换矩阵将由数字构成的矢量从一个空间坐标转换到另一个空间坐标。
		 * @param vin
		 * @param vout
		 *
		 */
		public function transformVectors(vin:Float32Array, vout:Float32Array):void
		{
			var i:int=0;
			var x:Number=0.0;
			var y:Number=0.0;
			var z:Number=0.0;

			while (i + 3 <= 24)
			{
				x=vin[i];
				y=vin[i + 1];
				z=vin[i + 2];
				vout[i + 0]=x * rawData[0] + y * rawData[4] + z * rawData[8] + rawData[12];
				vout[i + 1]=x * rawData[1] + y * rawData[5] + z * rawData[9] + rawData[13];
				vout[i + 2]=x * rawData[2] + y * rawData[6] + z * rawData[10] + rawData[14];
				i+=3;
			}
		}

		/**
		 * 将当前 Matrix3D 对象转换为一个矩阵，并将互换其中的行和列。
		 *
		 */
		public function transpose():void
		{

			var v:Float32Array=new Float32Array([0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]);

			for (var i:int=0; i < 16; i++)
			{
				v[i]=rawData[i];
			}

			rawData[1]=v[4];
			rawData[2]=v[8];
			rawData[3]=v[12];
			rawData[4]=v[1];
			rawData[6]=v[9];
			rawData[7]=v[13];
			rawData[8]=v[2];
			rawData[9]=v[6];
			rawData[11]=v[14];
			rawData[12]=v[3];
			rawData[13]=v[7];
			rawData[14]=v[11];
		}
		
		public function log():String
		{
			var s:String = "";
			s += rawData[0] + "\t" + rawData[1] + "\t" + rawData[2] + "\t" + rawData[3];
			s += rawData[4] + "\t" + rawData[5] + "\t" + rawData[6] + "\t" + rawData[7];
			s += rawData[8] + "\t" + rawData[9] + "\t" + rawData[10] + "\t" + rawData[11];
			s += rawData[12] + "\t" + rawData[13] + "\t" + rawData[14] + "\t" + rawData[15];
			return s;
		}
	}
}
