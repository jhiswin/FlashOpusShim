package 
{
	import flash.utils.Dictionary;
	/**
	 * ...
	 * @author 
	 */
	public class Instanced 
	{
		
		public function Instanced() 
		{
			instanceId = ++instanceIdCounter;
			
			dictInstances[instanceId] = this;
		}
		
		private static var instanceIdCounter:int = 0;
		
		private static var dictInstances:Dictionary = new Dictionary();
		
		public static function Instance(instanceId:int):*
		{
			return dictInstances[instanceId];
		}
		
		private var instanceId:int;
		
		public function GetInstanceId():int
		{
			return instanceId;
		}
	}

}