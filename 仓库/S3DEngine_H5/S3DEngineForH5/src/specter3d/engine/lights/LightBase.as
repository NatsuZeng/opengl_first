package specter3d.engine.lights
{
	import laya.webgl.WebGLContext;
	import specter3d.engine.core.Object3D;
	import specter3d.engine.core.camera.Camera3D;
	import specter3d.engine.core.geom.Vector3D;
	import specter3d.engine.core.render.data.DrawUnit;
	import specter3d.engine.errors.AbstractMethodError;
	import specter3d.engine.specter3d;

	use namespace specter3d;
	/**
	 * 灯光基类
	 * @author wangcx
	 *
	 */
	public class LightBase extends Object3D
	{
		public function LightBase(_type:int)
		{
			super();
			_lightType = _type;
			_colorRGB=new Vector3D(1, 1, 1);
			_diffuseRGB=new Vector3D(1, 1, 1);
			_ambientRGB=new Vector3D(1, 1, 1);
			_specularRGBS=new Vector3D(1, 1, 1, 10);
		}

		specter3d var _ambientColor:uint=0xffffff;
		specter3d var _ambientRGB:Vector3D;
		specter3d var _castsShadows:Boolean;
		specter3d var _color:uint=0xffffff;
		specter3d var _colorRGB:Vector3D
		specter3d var _diffuseRGB:Vector3D;
		specter3d var _specularRGBS:Vector3D;

		private var _ambient:Number=1;
		private var _diffuse:Number=1;
		private var _lightType:uint=0;
		private var _specular:Number=1;

		override public function addChild(child:Object3D):Object3D
		{
			throw new AbstractMethodError();
		}

		override public function addChildAt(child:Object3D, index:int):Object3D
		{
			throw new AbstractMethodError();
		}

		public function get ambient():Number
		{
			return _ambient;
		}

		public function set ambient(value:Number):void
		{
			_ambient=value < 0 ? 0 : value > 1 ? 1 : value;
			updateAmbient();
		}

		public function get ambientColor():uint
		{
			return _ambientColor;
		}

		public function set ambientColor(value:uint):void
		{
			_ambientColor=value;
			updateAmbient();
		}

		public function get color():uint
		{
			return _color;
		}

		public function set color(value:uint):void
		{
			_color=value;
			_colorRGB.x=((_color >> 16) & 0xff) / 0xff;
			_colorRGB.y=((_color >> 8) & 0xff) / 0xff;
			_colorRGB.z=(_color & 0xff) / 0xff;
			updateDiffuse();
			updateSpecular();
		}

		override public function contains(child:Object3D):Boolean
		{
			throw new AbstractMethodError();
		}

		public function get diffuse():Number
		{
			return _diffuse;
		}

		public function set diffuse(value:Number):void
		{
			_diffuse=value < 0 ? 0 : value;
			updateDiffuse();
		}

		override public function getChildAt(index:int):Object3D
		{
			throw new AbstractMethodError();
		}

		override public function getChildByName(name:String):Object3D
		{
			throw new AbstractMethodError();
		}

		override public function getChildIndex(child:Object3D):int
		{
			throw new AbstractMethodError();
		}

		public function get lightType():uint
		{
			return _lightType;
		}

		override public function get numChildren():int
		{
			throw new AbstractMethodError();
		}

		override public function removeChild(child:Object3D):Object3D
		{
			throw new AbstractMethodError();
		}

		override public function removeChildAt(index:int):Object3D
		{
			throw new AbstractMethodError();
		}

		override public function removeChildren(beginIndex:int=0, endIndex:int=2147483647):void
		{
			throw new AbstractMethodError();
		}

		public function get specular():Number
		{
			return _specular;
		}

		public function set specular(value:Number):void
		{
			_specular=value < 0 ? 0 : value;
			updateSpecular();
		}

		public function get specularShininess():Number
		{
			return _specularRGBS.w;
		}

		public function set specularShininess(value:Number):void
		{
			value=value < 0 ? 0.1 : value;
			_specularRGBS.w=value * 100;
		}

		specter3d override function collectRender(camera:Camera3D, _context3d:WebGLContext, _renderUnits:Vector.<DrawUnit>):void
		{
			var _drawUnit:DrawUnit=new DrawUnit(DrawUnit.LIGHT_UNIT);
			_renderUnits.push(_drawUnit);
		}

		private function updateAmbient():void
		{
			_ambientRGB.x=((_ambientColor >> 16) & 0xff) / 0xff * _ambient;
			_ambientRGB.y=((_ambientColor >> 8) & 0xff) / 0xff * _ambient;
			_ambientRGB.z=(_ambientColor & 0xff) / 0xff * _ambient;
		}

		private function updateDiffuse():void
		{
			_diffuseRGB.x=_colorRGB.x * _diffuse;
			_diffuseRGB.y=_colorRGB.y * _diffuse;
			_diffuseRGB.z=_colorRGB.z * _diffuse;
		}

		private function updateSpecular():void
		{
			_specularRGBS.x=_colorRGB.x * _specular;
			_specularRGBS.y=_colorRGB.y * _specular;
			_specularRGBS.z=_colorRGB.z * _specular;
		}
	}
}
