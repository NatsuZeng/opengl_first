package specter3d.engine.errors 
{
	/**
	 * ...
	 * @author 回眸笑苍生
	 */
	public class AbstractMethodError extends Error 
	{
		
		public function AbstractMethodError(id:*=0)
		{
			super("An abstract method was called! Either an instance of an abstract class was created, or an abstract method was not overridden by the subclass.", id);
		}
		
	}

}