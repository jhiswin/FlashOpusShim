package 
{
	import com.Blob;
	import com.XMLHttpRequest;
	import flash.events.Event;
	import flash.events.ProgressEvent;
	import flash.utils.ByteArray;
	import mxi.events.OErrorEvent;
	import mxi.events.OProgressEvent;
	/**
	 * ...
	 * @author 
	 */
	public class ShimXHR extends Instanced
	{
		
		public function ShimXHR() 
		{
			super();
			
			xhr = new XMLHttpRequest();
			
			xhr.addEventListener(Event.OPEN, OnOpen);
			xhr.addEventListener(OProgressEvent.PROGRESS, OnOProgress);
			xhr.addEventListener(ProgressEvent.PROGRESS, OnProgress);
			xhr.addEventListener(Event.COMPLETE, OnComplete);
			xhr.addEventListener(OErrorEvent.ERROR, OnError);
		
		}
		
		private function OnOpen(e:Event):void
		{
			UpdateProperties();
		}
		
		private function OnOProgress(e:OProgressEvent):void
		{
			UpdateProperties();
		}
		
		private function OnProgress(e:ProgressEvent):void
		{
			UpdateProperties();
		}
		
		private function OnComplete(e:Event):void
		{
			UpdateProperties();
		}
		
		private function OnError(e:OErrorEvent):void
		{
			UpdateProperties();
		}
		
		private function UpdateProperties():void
		{
			var status:int = xhr.getStatus();
			
			var readyState:int = xhr._readyState;
			
			if ( this.response == null )
			{
				if ( xhr._response != null ) 
				{
					var p:uint = xhr._response.position;
					xhr._response.position = 0;
					this.response = ShimBlob.FromCopy(xhr._response, "");
					xhr._response.position = p;
				}
			}
			
			Main.inter.FlashOpusShim_ShimXHR_UpdateProperties(GetInstanceId(), readyState, status, response);
		}
		
		private var xhr:XMLHttpRequest;
		
		private var options:Object = { };
		
		private var response:ShimBlob = null;
		
		public function open(method:String, url:String):void
		{
			options.method = method;
			options.url = url;
		}
		
		public function setRequestHeader(name:String, value:String) : void
		{
			xhr.setRequestHeader(name, value);
		}
		
		public function append(name:String, value:Object):void
		{
			if ( value is ByteArray ) 
			{
				var bl:Blob = new Blob([value]);
				xhr.appendBlob(name, bl);
			}
				
			else xhr.append(name, value);
		}
		
		public function send() : void
		{	
			xhr.send(options);
		}
		
		public function abort() : void 
		{	
			xhr.abort();
		}
	
		
	}

}