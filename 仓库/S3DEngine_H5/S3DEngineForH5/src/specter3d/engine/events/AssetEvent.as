package specter3d.engine.events
{
	import laya.events.Event;

	public class AssetEvent extends Event
	{
		public static const ASSET_COMPLETE:String="assetComplete";
		public static const ASSET_RENAME:String='assetRename';
		public static const ASSET_CONFLICT_RESOLVED:String='assetConflictResolved';

		private var _asset:*;

		public function AssetEvent(_type:String, asset:*=null)
		{
			this.type = _type;
			_asset=asset;
		}


		public function get asset():*
		{
			return _asset;
		}

		public function clone():Event
		{
			return new AssetEvent(type, asset);
		}
	}
}
