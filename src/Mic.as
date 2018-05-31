package 
{
	import flash.events.SampleDataEvent;
	import flash.events.StatusEvent;
	import flash.media.Microphone;
	import flash.system.Security;
	import flash.system.SecurityPanel;
	import flash.utils.ByteArray;
	/**
	 * ...
	 * @author 
	 */
	public class Mic 
	{
		public function Mic(activate:Boolean, fCallback:Function = null) 
		{
			this.fCallback = fCallback;
			
			mic = Microphone.getMicrophone();
		
			if ( mic != null ) 
			{
				mic.addEventListener(StatusEvent.STATUS,  OnMicStatus);
				mic.setSilenceLevel(0, -1);
				mic.rate = 44;
								
				if ( activate ) 
					SetOn(true);
			}
		
		}
		
		private var mic:Microphone	   = null;
	
		private var fCallback:Function = null;
		
		public function IsOn():Boolean
		{
			return mic != null && mic.muted == false && mic.hasEventListener(SampleDataEvent.SAMPLE_DATA);
		}
	
		private function OnMicStatus(e:StatusEvent):void 
		{
			if ( e.code == "Microphone.Muted" ) 
			{
				Main.inter.MicAccess(false);
			}
			
			if ( e.code == "Microphone.Unmuted" ) 
			{
				SetOn(true);
				
				Main.inter.MicAccess(true);
			}
		}
		
		public function GetFrameRate():int
		{
			if ( mic == null ) return 0;
			
			switch(mic.rate) {
			case 5:  return 5512;
			case 8:  return 8000;
			case 11: return 11025;
			case 22: return 22050;
			case 44: return 44100;
			}
			
			return 0;
		}
		
		private function OnMicSampleData(e:SampleDataEvent):void
		{
			var baMic:ByteArray = e.data;
			baMic.position = 0;
			
			if ( fCallback != null ) 
				fCallback(baMic);
		}
		
		public function SetCallback(fCallback:Function):void
		{
			this.fCallback = fCallback;
		}
		
		public function SetOn(on:Boolean):void
		{			
			if ( mic != null ) 
			{
				mic.removeEventListener(SampleDataEvent.SAMPLE_DATA, OnMicSampleData);
				
				if ( on ) 
				{
					mic.addEventListener(SampleDataEvent.SAMPLE_DATA, OnMicSampleData);
				}
			}
		}
		
		public function RequestAccess(permanent:Boolean):void
		{
			if ( permanent ) 
			{
				Security.showSettings(SecurityPanel.PRIVACY);
			}
			
			else
			{
				if( ! IsOn() )
				{
					SetOn(true);
				}
			}
			
		}
   
		
	}

}
