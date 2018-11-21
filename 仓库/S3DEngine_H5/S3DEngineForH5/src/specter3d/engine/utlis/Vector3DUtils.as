package specter3d.engine.utlis
{
	import specter3d.engine.core.geom.Vector3D;
	/**
	 * Vector3DUtils
	 * @author wangcx
	 *
	 */
	public class Vector3DUtils
	{
		public static const BACK:Vector3D=new Vector3D(0, 0, -1);
		public static const DOWN:Vector3D=new Vector3D(0, -1, 0);
		public static const FORWARD:Vector3D=new Vector3D(0, 0, 1);
		public static const LEFT:Vector3D=new Vector3D(-1, 0, 0);
		public static const ONE:Vector3D=new Vector3D(1, 1, 1);
		public static const RIGHT:Vector3D=new Vector3D(1, 0, 0);
		public static const UP:Vector3D=new Vector3D(0, 1, 0);
		public static const ZERO:Vector3D=new Vector3D(0, 0, 0);
		public static const vec0:Vector3D=new Vector3D();
		public static const vec1:Vector3D=new Vector3D();
		public static const vec2:Vector3D=new Vector3D();

		public static function abs(a:Vector3D):void
		{
			if (a.elements[0] < 0)
			{
				a.elements[0]=-a.elements[0];
			}
			if (a.elements[1] < 0)
			{
				a.elements[1]=-a.elements[1];
			}
			if (a.elements[2] < 0)
			{
				a.elements[2]=-a.elements[2];
			}
		}

		public static function add(a:Vector3D, b:Vector3D, out:Vector3D=null):Vector3D
		{
			if (out == null)
			{
				out=new Vector3D();
			}
			out.elements[0]=a.elements[0] + b.elements[0];
			out.elements[1]=a.elements[1] + b.elements[1];
			out.elements[2]=a.elements[2] + b.elements[2];
			return out;
		}

		public static function cross(a:Vector3D, b:Vector3D, out:Vector3D=null):Vector3D
		{
			if (!out)
			{
				out=new Vector3D();
			}
			out.elements[0]=a.elements[1] * b.elements[2] - a.elements[2] * b.elements[1];
			out.elements[1]=a.elements[2] * b.elements[0] - a.elements[0] * b.elements[2];
			out.elements[2]=a.elements[0] * b.elements[1] - a.elements[1] * b.elements[0];
			return out;
		}

		public static function interpolate(a:Vector3D, b:Vector3D, value:Number, out:Vector3D=null):Vector3D
		{
			if (out == null)
			{
				out=new Vector3D();
			}
			out.elements[0]=a.elements[0] + (b.elements[0] - a.elements[0]) * value;
			out.elements[1]=a.elements[1] + (b.elements[1] - a.elements[1]) * value;
			out.elements[2]=a.elements[2] + (b.elements[2] - a.elements[2]) * value;
			return out;
		}

		public static function length(a:Vector3D, b:Vector3D):Number
		{
			var dx:Number=a.elements[0] - b.elements[0];
			var dy:Number=a.elements[1] - b.elements[1];
			var dz:Number=a.elements[2] - b.elements[2];
			return Math.sqrt(dx * dx + dy * dy + dz * dz);
		}

		public static function lengthSquared(a:Vector3D, b:Vector3D):Number
		{
			var dx:Number=a.elements[0] - b.elements[0];
			var dy:Number=a.elements[1] - b.elements[1];
			var dz:Number=a.elements[2] - b.elements[2];
			return dx * dx + dy * dy + dz * dz;
		}

		public static function max(a:Vector3D, b:Vector3D, out:Vector3D=null):Vector3D
		{
			if (out == null)
			{
				out=new Vector3D();
			}
			out.elements[0]=(a.elements[0] > b.elements[0]) ? a.elements[0] : b.elements[0];
			out.elements[1]=(a.elements[1] > b.elements[1]) ? a.elements[1] : b.elements[1];
			out.elements[2]=(a.elements[2] > b.elements[2]) ? a.elements[2] : b.elements[2];
			return out;
		}

		public static function min(a:Vector3D, b:Vector3D, out:Vector3D=null):Vector3D
		{
			if (out == null)
			{
				out=new Vector3D();
			}
			out.elements[0]=(a.elements[0] < b.elements[0]) ? a.elements[0] : b.elements[0];
			out.elements[1]=(a.elements[1] < b.elements[1]) ? a.elements[1] : b.elements[1];
			out.elements[2]=(a.elements[2] < b.elements[2]) ? a.elements[2] : b.elements[2];
			return out;
		}

		public static function mirror(vector:Vector3D, normal:Vector3D, out:Vector3D=null):Vector3D
		{
			if (out == null)
			{
				out=new Vector3D();
			}
			var dot:Number=vector.dotProduct(normal);
			out.elements[0]=vector.elements[0] - (2 * normal.elements[0]) * dot;
			out.elements[1]=vector.elements[1] - (2 * normal.elements[1]) * dot;
			out.elements[2]=vector.elements[2] - (2 * normal.elements[2]) * dot;
			return out;
		}

		public static function mul(a:Vector3D, b:Vector3D, out:Vector3D):void
		{
			out.elements[0]=a.elements[0] * b.elements[0];
			out.elements[1]=a.elements[1] * b.elements[1];
			out.elements[2]=a.elements[2] * b.elements[2];
		}

		public static function negate(a:Vector3D, out:Vector3D=null):Vector3D
		{
			if (out == null)
			{
				out=new Vector3D();
			}
			out.elements[0]=-a.elements[0];
			out.elements[1]=-a.elements[1];
			out.elements[2]=-a.elements[2];
			return out;
		}

		public static function random(min:Number, max:Number, out:Vector3D=null):Vector3D
		{
			if (out == null)
			{
				out=new Vector3D();
			}
			out.elements[0]=Math.random() * (max - min) + min;
			out.elements[1]=Math.random() * (max - min) + min;
			out.elements[2]=Math.random() * (max - min) + min;
			return out;
		}

		public static function set(a:Vector3D, x:Number=0, y:Number=0, z:Number=0, w:Number=0):void
		{
			a.elements[0]=x;
			a.elements[1]=y;
			a.elements[2]=z;
			a.w=w;
		}

		public static function setLength(a:Vector3D, length:Number):void
		{
			var l:Number=a.length;
			if (l > 0)
			{
				l=l / length;
				a.elements[0]=a.elements[0] / l;
				a.elements[1]=a.elements[1] / l;
				a.elements[2]=a.elements[2] / l;
			}
			else
			{
				a.elements[0]=a.elements[1]=a.elements[2]=0;
			}
		}

		public static function sub(a:Vector3D, b:Vector3D, out:Vector3D=null):Vector3D
		{
			if (out == null)
			{
				out=new Vector3D();
			}
			out.elements[0]=a.elements[0] - b.elements[0];
			out.elements[1]=a.elements[1] - b.elements[1];
			out.elements[2]=a.elements[2] - b.elements[2];
			return out;
		}
	}
}
