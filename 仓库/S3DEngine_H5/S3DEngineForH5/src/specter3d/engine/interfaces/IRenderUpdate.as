package specter3d.engine.interfaces 
{
	
	/**
	 * 渲染更新接口定义 
	 * @author wangcx
	 */
	public interface IRenderUpdate 
	{
		/**
		 * 帧时间处理 
		 * @param time
		 * @param dt 上一帧到当前帧的时间,毫秒
		 */		
		function update(time:Number, dt:Number = 0) : void;
	}
	
}