package 
{
	import com.hurlant.util.der.ByteString;
	import flash.external.ExternalInterface;
	import flash.utils.ByteArray;
	/**
	 * ...
	 * @author 
	 */
	public class Interface 
	{
		
		public function Interface() 
		{
			ExternalInterface.addCallback("Init", Init); //throws in chrme?
			
			ExternalInterface.addCallback("RequestMicrophoneAccess", RequestMicrophoneAccess);
			
			ExternalInterface.addCallback("MediaRecorder_New",			MediaRecorder_New);
			ExternalInterface.addCallback("MediaRecorder_Start",		MediaRecorder_Start);
			ExternalInterface.addCallback("MediaRecorder_RequestData", 	MediaRecorder_RequestData);
			ExternalInterface.addCallback("MediaRecorder_Stop", 		MediaRecorder_Stop);
			ExternalInterface.addCallback("MediaRecorder_GetMimeType", 	MediaRecorder_GetMimeType);
			
			
			ExternalInterface.addCallback("Audio_New", 					Audio_New);
			ExternalInterface.addCallback("Audio_CanPlayType", 			Audio_CanPlayType);
			ExternalInterface.addCallback("Audio_SrcUsesFlash", 		Audio_SrcUsesFlash);
			ExternalInterface.addCallback("Audio_Pause", 				Audio_Pause);
			ExternalInterface.addCallback("Audio_Play", 				Audio_Play);

			ExternalInterface.addCallback("ShimBlob_New", 				ShimBlob_New);
			ExternalInterface.addCallback("ShimBlob_Realize", 			ShimBlob_Realize);
			ExternalInterface.addCallback("ShimBlob_GetType", 			ShimBlob_GetType);
			
			ExternalInterface.addCallback("ShimWebSocket_New", 			ShimWebSocket_New);
			ExternalInterface.addCallback("ShimWebSocket_Send", 		ShimWebSocket_Send);
			ExternalInterface.addCallback("ShimWebSocket_Close", 		ShimWebSocket_Close);
			
			ExternalInterface.addCallback("ShimXHR_New", 				ShimXHR_New);
			ExternalInterface.addCallback("ShimXHR_setRequestHeader", 	ShimXHR_setRequestHeader);
			ExternalInterface.addCallback("ShimXHR_send", 				ShimXHR_send);
			ExternalInterface.addCallback("ShimXHR_append", 			ShimXHR_append);
			ExternalInterface.addCallback("ShimXHR_abort", 				ShimXHR_abort);
			ExternalInterface.addCallback("ShimXHR_open", 				ShimXHR_open);
	
			FlashOpusShim_Handshake();
		}
		
		public function RequestMicrophoneAccess(permanent:Boolean):void
		{
			Main.mic.RequestAccess(permanent);
		}
		
		public function MicAccess(granted:Boolean):void
		{
			ExternalInterface.call("OnMicAccessChange", granted);
		}

		public function Init(constraints:Object):void
		{
			var audio:Object = constraints.audio;
			var video:Object = constraints.video;
			
			if ( video )
				FlashOpusShim_HandshakeError("FlashOpusShim: Video not supported in any format", "-1");
				
			else
			{
				FlashOpusShim_HandshakeSuccess();
			}
		}
		
		public function FlashOpusShim_Handshake():void
		{
			ExternalInterface.call("FlashOpusShim_Handshake");
		}
		
		public function FlashOpusShim_HandshakeError(message:String, name:String):void
		{
			ExternalInterface.call("FlashOpusShim_HandshakeError", message, name);
		}
		
		public function FlashOpusShim_HandshakeSuccess():void
		{
			ExternalInterface.call("FlashOpusShim_HandshakeSuccess");
		}
			
		public function ShimXHR_New():int
		{
			var x:ShimXHR = new ShimXHR();
			return x.GetInstanceId();
		}
	
		
		public function FlashOpusShim_ShimXHR_UpdateProperties(instanceId:int, readyState:int, status:int, response:Object):void
		{
			ExternalInterface.call("FlashOpusShim_ShimXHR_UpdateProperties", instanceId, readyState, status, response, response is ShimBlob);
		}
	
		public function ShimXHR_setRequestHeader(instanceId:int, name:String, value:String):void
		{
			var x:ShimXHR = Instanced.Instance(instanceId);
			
			if ( x ) 
				x.setRequestHeader(name, value);
		}
		
		public function ShimXHR_append(instanceId:int, key:String, obj:Object, isBase64:Boolean = false):void
		{
			var x:ShimXHR = Instanced.Instance(instanceId);
			
			if ( isBase64 ) 
			{
				var ba:ByteArray = new ByteArray();
				ShimUtils.ByteArrayFromString(obj as String, ba);
				obj = ba;
			}
			
			if( x )
				x.append(key, obj);
		}
		
		public function ShimXHR_send(instanceId:int):void
		{
			var x:ShimXHR = Instanced.Instance(instanceId);
			
			if( x )
				x.send();
		}
		
		public function ShimXHR_abort(instanceId:int):void
		{
			var x:ShimXHR = Instanced.Instance(instanceId);
			
			if ( x ) 
				x.abort();
		}
		
		public function ShimXHR_open(instanceId:int, method:String, url:String):void
		{
			var x:ShimXHR = Instanced.Instance(instanceId);
			
			if ( x ) 
				x.open(method, url);
		}
		
	
		public function MediaRecorder_New(options:Object):int
		{
			var mr:MediaRecorder = new MediaRecorder(options);
			return mr.GetInstanceId();
		}
		
		public function MediaRecorder_Start(instanceId:int, objTimeslice:Object):void
		{
			var mr:MediaRecorder = Instanced.Instance(instanceId);
			
			if ( mr )  mr.Start(objTimeslice);
		}
		
		public function MediaRecorder_RequestData(instanceId:int):void
		{
			var mr:MediaRecorder = Instanced.Instance(instanceId);
			
			if ( mr )  mr.RequestData();
		}
		
		public function MediaRecorder_Stop(instanceId:int):void
		{
			var mr:MediaRecorder = Instanced.Instance(instanceId);
			
			if ( mr )  mr.Stop();
		}
		
		public function MediaRecorder_GetMimeType(instanceId:int):String
		{
			var mr:MediaRecorder = Instanced.Instance(instanceId);
			
			return mr == null? "" : mr.GetMimeType();
		}
		
		public function FlashOpusShim_MediaRecorder_OnStop(instanceId:int):void
		{
			ExternalInterface.call("FlashOpusShim_MediaRecorder_OnStop", instanceId);
		}
		
		public function FlashOpusShim_MediaRecorder_OnStart(instanceId:int):void
		{
			ExternalInterface.call("FlashOpusShim_MediaRecorder_OnStart", instanceId);
		}

		public function FlashOpusShim_MediaRecorder_OnDataAvailable(instanceId:int, blob:ShimBlob):void
		{
			ExternalInterface.call("FlashOpusShim_MediaRecorder_OnDataAvailable", instanceId, blob.GetInstanceId());
		}
						
		public function FlashOpusShim_ShimWebSocket_OnOpen(instanceId:int):void
		{
			ExternalInterface.call("FlashOpusShim_ShimWebSocket_OnOpen", instanceId);
		}
		
		public function FlashOpusShim_ShimWebSocket_OnClose(instanceId:int):void
		{
			ExternalInterface.call("FlashOpusShim_ShimWebSocket_OnClose", instanceId);
		}
		
		public function FlashOpusShim_ShimWebSocket_OnMessage(instanceId:int, data:Object):void
		{
			ExternalInterface.call("FlashOpusShim_ShimWebSocket_OnMessage", instanceId, data, data is int);
		}
		
		public function ShimWebSocket_New(url:String, protocols:String = null):int
		{
			var w:ShimWebSocket = new ShimWebSocket(url, protocols);
			return w.GetInstanceId();
		}
		
		public function ShimWebSocket_Send(instanceId:int, obj:Object, isBase64:Boolean = false):void
		{
			var w:ShimWebSocket = Instanced.Instance(instanceId);
			
			if ( isBase64 ) 
			{
				var ba:ByteArray = new ByteArray();
				ShimUtils.ByteArrayFromString(obj as String, ba);
				obj = ba;
			}
			
			if( w )
				w.Send(obj);
		}
		
		public function ShimWebSocket_Close(instanceId:int):void
		{
			var w:ShimWebSocket = Instanced.Instance(instanceId);
			
			if ( w ) 
				w.Close();
		}
		
		public function ShimBlob_New(arrShimBlobInstanceIds:Array, type:String):int
		{
			var b:ShimBlob = ShimBlob.FromConcat(arrShimBlobInstanceIds, type);
			return b.GetInstanceId();
		}
		
		public function ShimBlob_Realize(instanceId:int):String
		{
			var b:ShimBlob = Instanced.Instance(instanceId);
			if ( b == null ) return "";
			
			return b.ToBase64();
		}
		
		public function ShimBlob_GetType(instanceId:int):String
		{
			var b:ShimBlob = Instanced.Instance(instanceId);
			if ( b == null ) return "";
			
			return b.GetType();
		}
		
		public function Audio_New():int
		{
			var a:Audio = new Audio();
			return a.GetInstanceId();
		}
		
		public function Audio_Play(instanceId:int):void
		{
			var a:Audio = Instanced.Instance(instanceId);
			a.Play();
		}

		public function Audio_Pause(instanceId:int):void
		{
			var a:Audio = Instanced.Instance(instanceId);
			a.Pause();
		}
		
		public function Audio_SrcUsesFlash(instanceId:int, url:String):Boolean
		{
			var a:Audio = Instanced.Instance(instanceId);
			return a.SrcUsesFlash(url);
		}
		
		public function Audio_CanPlayType(instanceId:int, str:String):String
		{
			var a:Audio = Instanced.Instance(instanceId);
			return a.CanPlayType(str);
		}
	}

}

