package specter3d.engine.core.geom
{
	/**
	 * Vector3D
	 * @author wangcx
	 *
	 */
	public class Vector3D
	{
		/**
		 *  x轴
		 */
		public static const X_AXIS:Vector3D=new Vector3D(1.0, 0.0, 0.0, 1.0);
		/**
		 *  y轴
		 */
		public static const Y_AXIS:Vector3D=new Vector3D(0.0, 1.0, 0.0, 1.0);
		/**
		 *  z轴
		 */
		public static const Z_AXIS:Vector3D=new Vector3D(0.0, 0.0, 1.0, 1.0);
		/**
		 *  0
		 */
		public static const ZERO:Vector3D=new Vector3D(0.0, 0.0, 0.0, 1.0);
		
		/**
		 * 临时帮助向量
		 */
		public static const HELP:Vector3D = new Vector3D(0.0, 0.0, 0.0, 1.0);
		
		/**
		 * 获取两个三维点之间的欧几里德距离
		 * @param pt1
		 * @param pt2
		 * @return
		 *
		 */
		public static function distance(pt1:Vector3D, pt2:Vector3D):Number
		{
			return Math.sqrt(((pt1.x - pt2.x) ^ 2 + (pt1.y - pt2.y) ^ 2 + (pt1.z - pt2.z) ^ 2));
		}

		/**
		 * 两个三维向量距离的平方。
		 * @param	value1 向量1。
		 * @param	value2 向量2。
		 * @return	距离的平方。
		 */
		public static function distanceSquared(value1:Vector3D, value2:Vector3D):Number
		{
			var value1e:Float32Array=value1.elements;
			var value2e:Float32Array=value2.elements;
			var x:Number=value1e[0] - value2e[0];
			var y:Number=value1e[1] - value2e[1];
			var z:Number=value1e[2] - value2e[2];
			return (x * x) + (y * y) + (z * z);
		}

		/**
		 * 求两个三维向量的点积。
		 * @param	a left向量。
		 * @param	b right向量。
		 * @return   点积。
		 */
		public static function dot(a:Vector3D, b:Vector3D):Number
		{
			var ae:Float32Array=a.elements;
			var be:Float32Array=b.elements;
			var r:Number=(ae[0] * be[0]) + (ae[1] * be[1]) + (ae[2] * be[2]);
			return r;
		}

		/**
		 * 插值三维向量。
		 * @param	a left向量。
		 * @param	b right向量。
		 * @param	t 插值比例。
		 * @param	out 输出向量。
		 */
		public static function lerp(a:Vector3D, b:Vector3D, t:Number, out:Vector3D):void
		{
			var e:Float32Array=out.elements;
			var f:Float32Array=a.elements;
			var g:Float32Array=b.elements;
			var ax:Number=f[0], ay:Number=f[1], az:Number=f[2];
			e[0]=ax + t * (g[0] - ax);
			e[1]=ay + t * (g[1] - ay);
			e[2]=az + t * (g[2] - az);
		}

		/**
		 * 分别取两个三维向量x、y、z的最大值计算新的三维向量。
		 * @param	a a三维向量。
		 * @param	b b三维向量。
		 * @param	out 结果三维向量。
		 */
		public static function max(a:Vector3D, b:Vector3D, out:Vector3D):void
		{
			var e:Float32Array=out.elements;
			var f:Float32Array=a.elements;
			var g:Float32Array=b.elements
			e[0]=Math.max(f[0], g[0]);
			e[1]=Math.max(f[1], g[1]);
			e[2]=Math.max(f[2], g[2]);
		}

		/**
		 * 分别取两个三维向量x、y、z的最小值计算新的三维向量。
		 * @param	a。
		 * @param	b。
		 * @param	out。
		 */
		public static function min(a:Vector3D, b:Vector3D, out:Vector3D):void
		{
			var e:Float32Array=out.elements;
			var f:Float32Array=a.elements;
			var g:Float32Array=b.elements
			e[0]=Math.min(f[0], g[0]);
			e[1]=Math.min(f[1], g[1]);
			e[2]=Math.min(f[2], g[2]);
		}

		/**
		 * 计算两个三维向量的乘积。
		 * @param	a left三维向量。
		 * @param	b right三维向量。
		 * @param	out 输出三维向量。
		 */
		public static function multiply(a:Vector3D, b:Vector3D, out:Vector3D):void
		{
			var e:Float32Array=out.elements;
			var f:Float32Array=a.elements;
			var g:Float32Array=b.elements
			e[0]=f[0] * g[0];
			e[1]=f[1] * g[1];
			e[2]=f[2] * g[2];
		}

		/**
		 * 缩放三维向量。
		 * @param	a 源三维向量。
		 * @param	b 缩放值。
		 * @param	out 输出三维向量。
		 */
		public static function scale(a:Vector3D, b:Number, out:Vector3D):void
		{
			var e:Float32Array=out.elements;
			var f:Float32Array=a.elements;
			e[0]=f[0] * b;
			e[1]=f[1] * b;
			e[2]=f[2] * b;
		}

		/**
		 * 求两个三维向量的差。
		 * @param	a  left三维向量。
		 * @param	b  right三维向量。
		 * @param	o out 输出向量。
		 */
		public static function subtract(a:Vector3D, b:Vector3D, o:Vector3D):void
		{
			var oe:Float32Array=o.elements;
			var ae:Float32Array=a.elements;
			var be:Float32Array=b.elements;
			oe[0]=ae[0] - be[0];
			oe[1]=ae[1] - be[1];
			oe[2]=ae[2] - be[2];
		}

		public function Vector3D(x:Number=0, y:Number=0, z:Number=0, w:Number=0)
		{
			this.elements[0]=x;
			this.elements[1]=y;
			this.elements[2]=z;
			this.elements[3]=w;
		}

		/**三维向量元素数组*/
		public var elements:*=new Float32Array(4);
		/** 考虑shader需要使用vec3的格式所以特殊处理一下 */
		private var elements3:*=new Float32Array(3);
		/** 考虑shader需要使用vec3的格式所以特殊处理一下 .vec4 格式请直接使用elements*/
		public function get elementsForVec3():Float32Array
		{
			elements3[0] = 	elements[0];
			elements3[1] = 	elements[1];
			elements3[2] = 	elements[2];
			return elements3;
		}
		
		/**
		 *　将当前 Vector3D 对象的 x、y 和 z 元素的值与另一个 Vector3D 对象的 x、y 和 z 元素的值相加。
		 * @param v
		 * @return
		 *
		 */
		public function add(v:Vector3D):Vector3D
		{
			this.elements[0]+=v.x;
			this.elements[1]+=v.y;
			this.elements[2]+=v.z;
			return this;
		}

		/**
		 *　返回一个新 Vector3D 对象，它是与当前 Vector3D 对象完全相同的副本。
		 * @return
		 *
		 */
		public function clone():Vector3D
		{
			return new Vector3D(this.elements[0], this.elements[1], this.elements[2], this.elements[3]);
		}

		/**
		 * 从一个三维向量复制。
		 * @param	v  源向量。
		 */
		public function copyFrom(v:Vector3D):Vector3D
		{
			var e:Float32Array=elements, s:Float32Array=v.elements;
			e[0]=s[0];
			e[1]=s[1];
			e[2]=s[2];
			return this;
		}

		/**
		 *　返回一个新的 Vector3D 对象，它与当前 Vector3D 对象和另一个 Vector3D 对象垂直（成直角）。
		 * @param v
		 * @return
		 *
		 */
		public function crossProduct(v:Vector3D):Vector3D
		{
			var x1:Number=y * v.z - z * v.y;
			var y1:Number=z * v.x - x * v.z;
			var z1:Number=x * v.y - y * v.x;
//			this.elements[0]=x1;
//			this.elements[1]=y1;
//			this.elements[2]=z1;
//			return this;
			return new Vector3D(x1, y1, z1);
		}

		/**
		 *　按照指定的 Vector3D 对象的 x、y 和 z 元素的值递减当前 Vector3D 对象的 x、y 和 z 元素的值。
		 * @param v
		 *
		 */
		public function decrementBy(v:Vector3D):void
		{
			this.elements[0]-=v.x;
			this.elements[1]-=v.y;
			this.elements[2]-=v.z;
		}

		/**
		 *　如果当前 Vector3D 对象和作为参数指定的 Vector3D 对象均为单元顶点，此方法将返回这两个顶点之间所成角的余弦值。
		 * @param v
		 * @return
		 *
		 */
		public function dotProduct(v:Vector3D):Number
		{
			return Vector3D.dot(this, v);
		}

		/**
		 * 当前 Vector3D 对象的长度（大小），即从原点 (0,0,0) 到该对象的 x、y 和 z 坐标的距离。
		 * @return
		 *
		 */
		public function get length():Number
		{
			return Math.sqrt(this.elements[0] * this.elements[0] + this.elements[1] * this.elements[1] + this.elements[2] * this.elements[2]);
		}

		/**
		 *　当前 Vector3D 对象长度的平方，它是使用 x、y 和 z 属性计算出来的。
		 * @return
		 *
		 */
		public function get lengthSquared():Number
		{
			return this.elements[0] * this.elements[0] + this.elements[1] * this.elements[1] + this.elements[2] * this.elements[2];
		}

		/**
		 * 将当前 Vector3D 对象设置为其逆对象。也可以将逆对象视为与原始对象相反的对象。当前 Vector3D 对象的 x、y 和 z 属性的值将更改为 -x、-y 和 -z。
		 *
		 */
		public function negate():void
		{
			this.elements[0]=-this.elements[0];
			this.elements[1]=-this.elements[1];
			this.elements[2]=-this.elements[2];
		}

		/**
		 * 通过将最前面的三个元素（x、y、z）除以矢量的长度可将 Vector3D 对象转换为单位矢量。
		 *
		 */
		public function normalize():void
		{
			var invLenght:Number=0.0;
			if (length == 0)
			{
				invLenght=0;
			}
			else
			{
				invLenght=1.0 / length;
			}
			this.elements[0]*=invLenght;
			this.elements[1]*=invLenght;
			this.elements[2]*=invLenght;
		}

		/**
		 * 将当前 Vector3D 对象的 x、y 和 z 属性的值除以其 w 属性的值。
		 *
		 */
		public function project():void
		{
			this.elements[0]/=this.elements[3];
			this.elements[1]/=this.elements[3];
			this.elements[2]/=this.elements[3];
		}

		public function scaleBy(val:Number):void
		{
			Vector3D.scale(this, val, this);
		}

		public function setTo(x:Number, y:Number, z:Number, w:Number):void
		{
			elements[0]=x;
			elements[1]=y;
			elements[2]=z;
			elements[3]=w;
		}

		/**
		 * 从另一个 Vector3D 对象的 x、y 和 z 元素的值中减去当前 Vector3D 对象的 x、y 和 z 元素的值。
		 * @param a
		 * @return
		 *
		 */
		public function subtract(a:Vector3D):Vector3D
		{
			Vector3D.subtract(this, a, this);
			return this;
		}

		/**
		 * 获取W轴坐标。
		 * @return	w  W轴坐标。
		 */
		public function get w():Number
		{
			return this.elements[3];
		}

		/**
		 * 设置Z轴坐标。
		 * @param	z  Z轴坐标。
		 */
		public function set w(value:Number):void
		{
			this.elements[3]=value;
		}

		/**
		 * 获取X轴坐标。
		 * @return	x  X轴坐标。
		 */
		public function get x():Number
		{
			return this.elements[0];
		}

		/**
		 * 设置X轴坐标。
		 * @param	x  X轴坐标。
		 */
		public function set x(value:Number):void
		{
			this.elements[0]=value;
		}

		/**
		 * 获取Y轴坐标。
		 * @return	y  Y轴坐标。
		 */
		public function get y():Number
		{
			return this.elements[1];
		}

		/**
		 * 设置Y轴坐标。
		 * @param	y  Y轴坐标。
		 */
		public function set y(value:Number):void
		{
			this.elements[1]=value;
		}

		/**
		 * 获取Z轴坐标。
		 * @return	z  Z轴坐标。
		 */
		public function get z():Number
		{
			return this.elements[2];
		}

		/**
		 * 设置Z轴坐标。
		 * @param	z  Z轴坐标。
		 */
		public function set z(value:Number):void
		{
			this.elements[2]=value;
		}
	}
}
