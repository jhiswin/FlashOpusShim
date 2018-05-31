package 
{
	import flash.utils.ByteArray;
	/**
	 * ...
	 * @author 
	 */
	public class RawPCMEncoder extends Encoder
	{
		
		public function RawPCMEncoder() 
		{
			
		}
		
		private var ba:ByteArray = null;
		
		public override function Start():void
		{
			ba = new ByteArray();
			
			super.Start();
		}
		
		public override function Finish():void
		{
			super.Finish();
			
			Finished(); //no excess encoding to do
		}
		
		public override function GetBaOut():ByteArray
		{
			return ba;
		}
		
		public override function WriteF32MonoToStereo(baSrc:ByteArray, frames:int):void
		{
			for (var i:int = 0 ; i < frames ; i++)
			{
				var s:Number = baSrc.readFloat();
				
				ba.writeFloat(s);
				ba.writeFloat(s);
			}
		}
		
	}

}