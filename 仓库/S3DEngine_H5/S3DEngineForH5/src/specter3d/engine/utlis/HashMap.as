package specter3d.engine.utlis
{
	/**
	 * 哈希表 项目中哈希结构均需使用 HashMap
	 * @author wangcx
	 *
	 */
	public class HashMap
	{

		public function HashMap()
		{
			_values=[];
			_keys=[];
		}

		private var _keys:Array;
		private var _mapLenth:int=0;
		private var _values:Array;

		public final function clear():void
		{
			_values.length=0;
			_keys.length=0;
			_mapLenth=0;
		}


		public final function clone():HashMap
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

		public final function containsKey(key:*):Boolean
		{
			var result:*=null;
			var index:int=indexOf(key);
			return index >= 0;
		}

		public function forEach(callback:Function, ... args):void
		{
			if (_mapLenth > 0)
			{
				args.unshift(null,null);
				for (var i:int=0; i < _mapLenth; i++)
				{
					args[0]=_keys[i];
					args[1]=_values[i];
					callback.apply(null, args);
				}
			}
		}

		public final function getValue(key:*):Object
		{
			var result:*=null;
			var index:int=indexOf(key);
			if (index >= 0)
			{
				result=_values[index];
			}
			return result;
		}

		public function isEmpty():Boolean
		{
			if (this.size as Number < 1)
			{
				return true;
			}
			return false;
		}


		public final function keySet():Array
		{
			return _keys.concat();
		}


		public final function put(key:*, value:*):*
		{
			if (key == null || key == undefined)
			{
				return value;
			}
			var index:int=indexOf(key);
			if (index >= 0)
			{
				_values[index]=value;
				return;
			}
			ArrayUtil.insertAt(_keys, _mapLenth, key);
			ArrayUtil.insertAt(_values, _mapLenth, value);
			_mapLenth++;
			return value;
		}


		public final function putAll(map:HashMap):void
		{
			var len:uint=map._mapLenth;
			if (len > 0)
			{
				for (var i:uint=0; i < len; i++)
				{
					this.put(map._keys[i], map._values[i]);
				}
			}
		}


		public final function remove(key:*):*
		{
			var result:*=null;
			var index:int=indexOf(key);
			if (index >= 0)
			{
				ArrayUtil.removeAt(_keys, index);
				result=ArrayUtil.removeAt(_values, index);
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
			var out:Array=[];
			for (var i:int=0; i < _keys.length; i++)
			{
				out[i]=_keys[i] + "=" + _values[i];
			}
			return out.join(",");
		}

		public final function values():Array
		{
			return _values.concat();
		}

		/**
		 * 获取指定对象的键名索引。
		 * @param	key 键名对象。
		 * @return 键名索引。
		 */
		private function indexOf(key:Object):int
		{
			var index:int=_keys.indexOf(key);
			if (index < 0)
			{
				key=(key is String) ? Number(key) : ((key is Number) ? key.toString() : key);
				index = _keys.indexOf(key);
			}
			return index;
		}
	}
}
