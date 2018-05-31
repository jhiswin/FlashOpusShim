package 
{
	import com.hurlant.util.der.ByteString;
	import com.worlize.websocket.WebSocket;
	import com.worlize.websocket.WebSocketEvent;
	import com.worlize.websocket.WebSocketMessage;
	import flash.utils.ByteArray;
	/**
	 * ...
	 * @author 
	 */
	public class ShimWebSocket extends Instanced
	{
		
		public function ShimWebSocket(url:String, protocols:String = null) 
		{
			super();
			
			websocket = new WebSocket(url, null, protocols);
			
			websocket.addEventListener(WebSocketEvent.OPEN, OnWebSocketOpen);
			websocket.addEventListener(WebSocketEvent.MESSAGE, OnWebSocketMessage);
			websocket.addEventListener(WebSocketEvent.CLOSED, OnWebSocketClose);
			
			websocket.connect();
		}
		
		private var websocket:WebSocket;
		
		private function OnWebSocketOpen(e:WebSocketEvent):void
		{
			Main.inter.FlashOpusShim_ShimWebSocket_OnOpen(GetInstanceId());
		}
		
		private function OnWebSocketClose(e:WebSocketEvent):void
		{
			Main.inter.FlashOpusShim_ShimWebSocket_OnClose(GetInstanceId());
		}
		
		private function OnWebSocketMessage(e:WebSocketMessage):void
		{
			var data:Object = null;
			
			if ( e.type == WebSocketMessage.TYPE_BINARY ) 
			{
				var ba:ByteArray = e.binaryData;
				ba.position = 0;
				
				var sb:ShimBlob = ShimBlob.FromCopy(ba, "");
				
				data = sb.GetInstanceId();
			}
			
			else
				data = e.utf8Data;
		
			Main.inter.FlashOpusShim_ShimWebSocket_OnMessage(GetInstanceId(), data);
		}
		
		public function Send(obj:Object):void
		{
			if ( obj is int ) 
			{
				var s:ShimBlob = Instanced.Instance(obj as int);
				
				if( s )
				{
					var ba:ByteArray = s.GetBa();
					ba.position = 0;
					
					websocket.sendBytes(ba);
				}
			}
			
			else if( obj is String ) 
			{
				var str:String = obj as String;
				
				websocket.sendUTF(str);
			}
			
			else if ( obj is ByteArray )
			{
				(obj as ByteArray).position = 0;
				websocket.sendBytes(obj as ByteArray);
			}
		}
		
		public function Close():void
		{
			websocket.close();
		}
	}

}