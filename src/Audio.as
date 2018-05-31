package 
{
	import flash.events.Event;
	import flash.events.SampleDataEvent;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.utils.ByteArray;
	/**
	 * ...
	 * @author 
	 */
	public class Audio extends Instanced
	{
		public static const CHANNELS:int 	= 2;
		public static const SIZEOFFLOAT:int = 4;
		
		public function Audio() 
		{
			super();
		}
		
		private var sound:Sound = null;
		private var soundChannel:SoundChannel = null;
		
		public function Play():void
		{
			if (sound != null ) 
				return;
				
			sound = new Sound();
			sound.addEventListener(SampleDataEvent.SAMPLE_DATA, OnSampleData);
			soundChannel = sound.play();
			soundChannel.addEventListener(Event.SOUND_COMPLETE, OnSoundComplete);
		}
		
		private var frame:int = 0;
		
		public function Reset():void
		{
			frame = 0;
		}
		
		private function OnSoundComplete(e:Event):void
		{
			Pause();
			Reset();
		}
		
		private function OnSampleData(e:SampleDataEvent):void
		{
			if ( sourceBlob == null )
				return;
			
			var dst:ByteArray = e.data;
			dst.position = 0;
			
			var src:ByteArray = sourceBlob.GetBa();
			src.position = frame * CHANNELS * SIZEOFFLOAT;
			
			var framesRequired:int = 4096;
			
			var bytes:int = Math.min(framesRequired * CHANNELS * SIZEOFFLOAT, src.length - src.position);
						
			ShimBlob.Copy(src, dst, bytes);
			
			frame += bytes / (CHANNELS * SIZEOFFLOAT);
		}
		
		public function Pause():void
		{
			if ( soundChannel == null ) 
				return;
				
			soundChannel.stop();
			
			soundChannel = null;
			sound = null;
		}
		
		private var sourceURL:String = null;
		private var sourceBlob:ShimBlob = null;
		
		public function SrcUsesFlash(url:String):Boolean
		{
			Pause();
			Reset();
			
			sourceBlob = null;
			this.sourceURL = url;
			
			if ( url.indexOf("ShimBlob:") != 0 ) 
				return false;
			
			var instanceId:int = parseInt(sourceURL.split(":")[1]);
			
			if ( instanceId == 0 ) 
				return false;
					
			sourceBlob = Instanced.Instance(instanceId);
				
			return sourceBlob != null;
		}
		
		public function CanPlayType(str:String):String
		{
			return str == "raw/pcm"? "probably"
								   : "";
		}
	}

}