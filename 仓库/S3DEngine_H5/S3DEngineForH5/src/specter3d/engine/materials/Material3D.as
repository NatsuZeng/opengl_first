package specter3d.engine.materials
{
	import laya.webgl.WebGLContext;
	
	import specter3d.engine.specter3d;
	import specter3d.engine.core.camera.Camera3D;
	import specter3d.engine.core.render.data.DrawUnit;
	import specter3d.engine.materials.lightpickers.LightPicker;
	import specter3d.engine.materials.passes.CompiledPass;
	import specter3d.engine.materials.passes.Material3DPass;

	use namespace specter3d;
	/**
	 * Material3D
	 * @author wangcx
	 *
	 */
	public class Material3D
	{

		public function Material3D()
		{
			_passes=new Vector.<Material3DPass>();
			_compiledPass=new CompiledPass(this);
			_passes[0]=_compiledPass;
		}
		
		public function dispose():void
		{
			
		}

		public var name:String;
		protected var _compiledPass:CompiledPass;
		protected var _passes:Vector.<Material3DPass>;

		specter3d var _programId:int=-1;

		private var _alpha:Number=1;
		private var _alphaBlend:Boolean = false;
		
		private var _bothSides:Boolean;

		public function get bothSides():Boolean
		{
			return _bothSides;
		}

		public function set bothSides(value:Boolean):void
		{
			_bothSides = value;
			
			for (var i:int=0; i < _passes.length; i++)
				_passes[i].bothSides = _bothSides;	
		}

		public function get alphaBlend():Boolean
		{
			return _alphaBlend;
		}

		public function set alphaBlend(value:Boolean):void
		{
			_alphaBlend = value;
			for (var i:int=0; i < _passes.length; i++)
				_passes[i].alphaBlend=_alphaBlend;
		}

		public function get alpha():Number
		{
			return _alpha;
		}

		public function set alpha(value:Number):void
		{
			if (_alpha != value && _alpha >= 0)
			{
				_alpha=value;
				for (var i:int=0; i < _passes.length; i++)
					_passes[i].alpha=_alpha;
			}
		}

		public function canBatch(other:Material3D):Boolean
		{
			return false;
		}
		
		public function clone():Material3D
		{
			var res:Material3D=new Material3D();
			res.clonePropertiesFrom(this);
			return res;
		}

		public function get lightPicker():LightPicker
		{
			return _compiledPass.lightPicker;
		}

		public function set lightPicker(value:LightPicker):void
		{
			_compiledPass.lightPicker=value;
		}

		protected function clonePropertiesFrom(source:Material3D):void
		{
			name=source.name;
		}

		specter3d function activate(renderable:DrawUnit, _context3d:WebGLContext, _camera3d:Camera3D):void
		{
			for (var i:int=0; i < _passes.length; i++)
				renderPass(i, _context3d, _camera3d, renderable);
		}

		private function renderPass(index:uint, _context3d:WebGLContext, camera:Camera3D, renderable:DrawUnit):void
		{
			if (_context3d)
			{
				var _pass:Material3DPass=_passes[index];
				_pass && _pass.render(_context3d, renderable, camera);
			}
		}
	}
}
