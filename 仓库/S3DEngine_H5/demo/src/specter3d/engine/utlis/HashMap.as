package specter3d.engine.utlis
{
	import laya.utils.Dictionary;

	/**
	 * 哈希表 项目中哈希结构均需使用 HashMap
	 * @author 回眸笑苍生
	 *
	 */
	public class HashMap
	{

		public function HashMap()
		{
			_map=new Dictionary();
		}

		private var _map:Dictionary;
		private var _mapLenth:int=0;

		
		public final  function clear():void
		{
			for (var key:* in _map)
			{
				delete _map[key];
			}
			_mapLenth=0;
		}

		
		public final  function clone():HashMap
		{
			var hashMap:HashMap=new HashMap();
			var keys:Array=this.keySet();
			for (var i:int=0; i < keys.length; i++)
			{
				var key:*=keys[i];
				var value:*=getValue(key);
				hashMap.put(key, value);
			}
			return hashMap;
		}

		public function forEach(callback:Function,... args):void
		{
			if(_mapLenth > 0)
			{
				args.unshift(null);
				args.unshift(null);
				for (var key:* in _map)
				{
					args[0] = key;
					args[1] = _map[key];
					callback.apply(null,args);
				}
			}
		}
		
		public final  function containsKey(key:*):Boolean
		{
			return _map[key] ? true : false;
		}

		
		public final  function containsValue(value:*):Boolean
		{
			var result:Boolean=false;
			for (var key:* in _map)
			{
				var tempValue:*=_map[key];
				if (tempValue == value)
				{
					result=true;
				}
			}
			return result;
		}

		
		public final  function getValue(key:*):Object
		{
			return _map[key];
		}

		public function isEmpty():Boolean
		{
			if (this.size as Number < 1)
			{
				return true;
			}
			return false;
		}

		
		public final  function keySet():Array
		{
			var returnArr:Array=[];
			for (var key:* in _map)
			{
				returnArr.push(key);
			}
			return returnArr;
		}

		
		public final  function put(key:*, value:*):*
		{
			if (key == null || key == undefined)
			{
				return value;
			}
			if (_map[key] == undefined)
			{
				_mapLenth++;
			}
			_map[key]=value;
			return value;
		}

		
		public final  function putAll(map:HashMap):void
		{
			var len:uint=map.size();
			if (len > 0)
			{
				var arr:Array=map.keySet() as Array;
				for (var i:uint=0; i < len; i++)
				{
					var _key:*=arr.pop();
					this.put(_key, map._map[_key]);
				}
			}
		}

		
		public final  function remove(key:*):*
		{
			var result:*=_map[key];
			if (result)
			{
				delete _map[key];
				_mapLenth--;
			}
			return result;
		}

		
		public final function size():uint
		{
			return _mapLenth;
		}

		public function toString():String
		{
			var out:String="";
			for (var key:* in _map)
			{
				out+=key + "=" + _map[key] + "|";
			}
			return out;
		}

		public final  function values():Array
		{
			var returnArr:Array=[];
			for (var key:* in _map)
			{
				returnArr.push(_map[key]);
			}
			return returnArr;
		}
	}
}
