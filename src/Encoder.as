package 
{
	import flash.utils.ByteArray;
	/**
	 * ...
	 * @author 
	 */
	public class Encoder 
	{
		public static const STATE_READY:int = 0;
		public static const STATE_ENCODING:int = 1;
		public static const STATE_FINISHING:int = 2;
		
		private var state:int = STATE_READY;
	
		public function GetState():int
		{
			return state;
		}
		
		public function Finish():void
		{
			if ( state != STATE_ENCODING ) 
				return;
				
			state = STATE_FINISHING;
		}
		
		public function Start():void
		{
			if ( state != STATE_READY ) 
				return;
				
			state = STATE_ENCODING;
		}
		
		protected function Finished():void
		{
			state = STATE_READY;
		}
		
		public function GetBaOut():ByteArray
		{
			throw new Error("Override");
		}
		
		public function WriteF32MonoToStereo(baSrc:ByteArray, frames:int):void
		{
			throw new Error("Override");
		}
	}

}