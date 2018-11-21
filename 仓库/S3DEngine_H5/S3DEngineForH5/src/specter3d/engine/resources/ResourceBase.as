package specter3d.engine.resources
{
	import laya.events.EventDispatcher;
	import laya.webgl.WebGLContext;
	

	public class ResourceBase extends EventDispatcher
	{
		private var _id:String;
		private var _name : String;
		private var _isDispose:Boolean = false;
		
		public function ResourceBase(name : String=null)
		{
			_name = name;
		}
		
		protected function get isDispose():Boolean
		{
			return _isDispose;
		}

		public function get id():String
		{
			return _id;
		}
		
		public function set id(newID:String):void
		{
			_id = newID;
		}
		/**
		 * 该资源是否被上传到Context3D。 
		 * @return 
		 * 
		 */		
		public function get isUploaded():Boolean 
		{
			return false;
		}
		
		/**
		 * 上传资源到Context3D。
		 * 
		 */		
		public function upload(_context3d:WebGLContext):void 
		{
			throw new Error("Cannot upload without data");
		}
		
		/**
		 * 释放资源 
		 * 
		 */		
		public function dispose():void 
		{
			_isDispose = true;
		}
	}
}