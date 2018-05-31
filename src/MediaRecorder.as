package 
{
	import flash.display.Shape;
	import flash.events.Event;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	
	public class MediaRecorder extends Instanced
	{
		public function MediaRecorder(options:Object) 
		{
			super();
			
			if ( options == null ) options = { };
			
			this.mimeType = options.mimeType || "ogg/opus";
			
			var opusSecsAdd:Number = options.opusSecsAdd;
			
			if ( isNaN(opusSecsAdd) ) 
				opusSecsAdd = 0.0;
			
			encoder = mimeType == "ogg/opus"? new OpusEncoder(Main.mic.GetFrameRate(), 2, OpusEncoder.OPUS_APPLICATION_AUDIO, opusSecsAdd)
											: new RawPCMEncoder();
		}
		
		private var mimeType:String = null;
		
		public function GetMimeType():String
		{
			return mimeType;
		}
		
		private var shape:Shape = null;
		
		private var dataDeltaSecs:Number = NaN;
		
		private var encoder:Encoder = null;
		
		public function Start(objTimeslice:Object):void
		{
			if ( encoder.GetState() != Encoder.STATE_READY ) 
				return;
			
			if ( Main.mic.IsOn() == false )
				return;
			
			var strTimeslice:String = "" + objTimeslice;
			
			var n:Number = parseFloat(strTimeslice);
				
			dataDeltaSecs = n / 1000.0;
			
			if ( isNaN(dataDeltaSecs) ) 
				dataDeltaSecs = Number.POSITIVE_INFINITY;

			shape = new Shape();
			shape.addEventListener(Event.ENTER_FRAME, OnEnterFrame);
			
			Main.mic.SetCallback(OnMicCallback);
			
			encoder.Start();
			
			Main.inter.FlashOpusShim_MediaRecorder_OnStart(GetInstanceId());
		}
		
		private var frames:int = 0;
		
		private function OnMicCallback(ba:ByteArray):void
		{
			if ( encoder.GetState() == Encoder.STATE_ENCODING ) 
			{
				encoder.WriteF32MonoToStereo(ba, ba.length / 4);
				frames += ba.length / 4;
			}
			
			//if ( frames >= 44100 * 10 ) //test if ending is being chopped off
			//	Stop();
		}
	
		private var tLast:Number = 0;
		
		private function OnEnterFrame(e:Event):void
		{
			var tNow:Number = new Date().time / 1000.0;
			
			if ( (tNow - tLast) > dataDeltaSecs ) 
			{
				tLast = tNow;
				
				RequestData();
			}
			
			if ( encoder.GetState() == Encoder.STATE_READY ) 
			{
				shape.removeEventListener(Event.ENTER_FRAME, OnEnterFrame);
				shape = null;
				
				RequestData();
				
				Main.inter.FlashOpusShim_MediaRecorder_OnStop(GetInstanceId());
			}

		}
		
		public function RequestData():void
		{
			var ba:ByteArray = encoder.GetBaOut();
			
			ba.position = 0;
			
			var blob:ShimBlob = ShimBlob.FromCopy(ba, this.mimeType);
			
			ba.length = 0;
			
			Main.inter.FlashOpusShim_MediaRecorder_OnDataAvailable(GetInstanceId(), blob);
		}
		
		public function Stop():void 
		{		
			if( encoder.GetState() != Encoder.STATE_ENCODING ) 
				return;
			
			encoder.Finish();
		}
		
		
		
		
		
	}

}


