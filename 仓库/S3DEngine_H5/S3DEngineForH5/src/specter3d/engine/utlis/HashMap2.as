package specter3d.engine.utlis
{
	/**
	 * 哈希表 项目中哈希结构均需使用 HashMap2
	 * @author wangcx
	 *
	 */
	public class HashMap2
	{

		public function HashMap2()
		{
			_mapData={};
			_mapIndex=[];
			_keys=[];
		}

		private var _keys:Array;

		private var _mapData:Object;
		private var _mapIndex:Array;
		private var _mapLenth:int=0;

		public final function clear():void
		{
			for (var i:int=0; i < _keys.length; i++)
			{
				var key:*=_keys[i];
				delete _mapData[key];
				delete _mapIndex[key];
			}
			_keys.length=_mapLenth=0;
		}


		public final function clone():HashMap2
		{
			var hashMap2:HashMap2=new HashMap2();
			for (var i:int=0; i < _keys.length; i++)
			{
				var key:*=_keys[i];
				var value:*=getValue(key);
				ArrayUtil.insertAt(hashMap2._keys, hashMap2._mapLenth, key);
				hashMap2._mapData[key]=value;
				hashMap2._mapLenth++;
			}
			return hashMap2;
		}

		public final function containsKey(key:*):Boolean
		{
			return _mapData[key] ? true : false;
		}

		public function forEach(callback:Function, ... args):void
		{
			if (_mapLenth > 0)
			{
				args.unshift(null, null);
				for (var i:int=0; i < _mapLenth; i++)
				{
					var key:*=_keys[i];
					args[0]=key;
					args[1]=_mapData[key];
					callback.apply(null, args);
				}
			}
		}


		public final function getValue(key:*):Object
		{
			return _mapData[key];
		}

		public function isEmpty():Boolean
		{
			return this._mapLenth < 1;
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
			if (!containsKey(key))
			{
				ArrayUtil.insertAt(_keys, _mapLenth, key);
				_mapData[key]=value;
				_mapIndex[key]=_mapLenth;
				_mapLenth++;
			}
			return value;
		}


		public final function putAll(map:HashMap2):void
		{
			var len:uint=map.size();
			if (len > 0)
			{
				var arr:Array=map._keys;
				for (var i:uint=0; i < len; i++)
				{
					var _key:*=arr[i];
					this.put(_key, map._mapData[_key]);
				}
			}
		}


		public final function remove(key:*):*
		{
			var result:*=_mapData[key];
			if (result)
			{
				ArrayUtil.removeAt(_keys, _mapIndex[key]);
				delete _mapIndex[key];
				delete _mapData[key];
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
			var outArr:Array=[];
			for (var i:int=0; i < _keys.length; i++)
			{
				ArrayUtil.insertAt(outArr, i, _keys[i] + "=" + _mapData[_keys[i]]);
			}
			return outArr.join(",");
		}

		public final function values():Array
		{
			var returnArr:Array=[];
			for (var i:int=0; i < _keys.length; i++)
			{
				ArrayUtil.insertAt(returnArr, i, _mapData[_keys[i]]);
			}
			return returnArr;
		}
	}
}
