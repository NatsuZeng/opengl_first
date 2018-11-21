package specter3d.engine.core.camera.lens
{
	import specter3d.engine.events.Lens3DEvent;
	/**
	* 正交投影
	* @author wangcx
	*
	*/
	public class OrthogrhicLens extends Lens3D
	{
		public function OrthogrhicLens(left:Number, right:Number, bottom:Number, top:Number)
		{
			super();
			this.setOrth(left, right, bottom, top);
		}

		private var _bottom:Number;

		private var _left:Number;
		private var _right:Number;
		private var _top:Number;

		public function get bottom():Number
		{
			return _bottom;
		}

		public function get left():Number
		{
			return _left;
		}

		public function get right():Number
		{
			return _right;
		}

		public function setOrth(left:Number, right:Number, bottom:Number, top:Number):void
		{
			this._left=left;
			this._right=right;
			this._top=top;
			this._bottom=bottom;
			this.invalidateProjection();
		}

		override public function setViewPort(x:int, y:int, width:int, height:int):void
		{
			super.setViewPort(x, y, width, height);
			this._left=-width / 2;
			this._right=width / 2;
			this._top=height / 2;
			this._bottom=-height / 2;
		}

		public function get top():Number
		{
			return _top;
		}

		override public function updateProjectionMatrix():void
		{
			super.updateProjectionMatrix();
			var rawData:Float32Array=_projection.rawData;
			rawData[0]=2 / (_right - _left);
			rawData[1]=0;
			rawData[2]=0;
			rawData[3]=0;

			rawData[4]=0;
			rawData[5]=2 / (_top - _bottom);
			rawData[6]=0;
			rawData[7]=0;

			rawData[8]=0;
			rawData[9]=0;
			rawData[10]=1 / (_far - _near);
			rawData[11]=-_near / (_far - _near);

			rawData[12]=0;
			rawData[13]=0;
			rawData[14]=0;
			rawData[15]=1;
			this._projection.copyRawDataFrom(rawData);
			this.event(Lens3DEvent.PROJECTION_UPDATE);
		}
	}
}
