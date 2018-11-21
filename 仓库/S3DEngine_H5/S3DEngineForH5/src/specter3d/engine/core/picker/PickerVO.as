package specter3d.engine.core.picker
{
	import specter3d.engine.core.Entity3D;
	import specter3d.engine.core.geom.Vector3D;
	import specter3d.engine.core.render.data.DrawUnit;

	public class PickerVO
	{
		public var target:Entity3D;
		public var distance:Number;
		
		public var pickerType:int;
		public var localPosition:Vector3D;
		public var localNormal:Vector3D = new Vector3D();
		public var uv:Vector3D;
		public var index:uint;
		public var surfaceIndex:int;
		public var renderable:DrawUnit;
		
		public var localRayPosition:Vector3D = new Vector3D();
		public var localRayDirection:Vector3D = new Vector3D();
		
		public function PickerVO(target:Entity3D=null)
		{
			this.target = target;
		}
		
		public function clone():PickerVO
		{
			var vo:PickerVO = new PickerVO();
			
			vo.target = target;
			vo.distance = distance;
			vo.pickerType = pickerType;
			vo.localPosition = localPosition.clone();
			vo.uv = uv.clone();
			vo.localRayPosition = localRayPosition.clone();
			vo.localRayDirection = localRayDirection.clone();
			vo.localNormal = localNormal.clone();
			
			return vo;
		}
	}
}