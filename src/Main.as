package
{
	import com.worlize.websocket.WebSocket;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.net.FileReference;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.utils.ByteArray;
	
	public class Main extends Sprite 
	{
		
		public function Main() 
		{
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align     = StageAlign.TOP_LEFT;
			stage.frameRate = 20;
			
			Main.mic = new Mic(false);
			Main.inter = new Interface();
		}
		
		public static var inter:Interface;
		
		public static var mic:Mic;
	
		ShimXHR;
	}
	
}

