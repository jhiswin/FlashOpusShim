package 
{
	import flash.utils.ByteArray;
	/**
	 * ...
	 * @author 
	 */
	public class ShimBlob extends Instanced
	{
		
		public function ShimBlob(type:String) 
		{
			super();
			
			this.type = type;
		
		}
		
		private var type:String;
		
		public function GetType():String
		{
			return type;
		}
		
		private var ba:ByteArray = new ByteArray();
		
		public function GetBa():ByteArray
		{
			return ba;
		}
		
		public static function FromConcat(arrShimBlobInstanceIds:Array, type:String):ShimBlob
		{
			var b:ShimBlob = new ShimBlob(type);
			
			if ( arrShimBlobInstanceIds != null )
			{
				for (var i:int = 0 ; i < arrShimBlobInstanceIds.length ; i++)
				{
					var bb:ShimBlob = Instanced.Instance(arrShimBlobInstanceIds[i]);
					
					if ( bb != null )
					{
						var src:ByteArray = bb.ba;
						src.position = 0;
						
						Copy(src, b.ba, src.length);
					}
				}
			}
			
			return b;
		}
		
		public static function FromCopy(src:ByteArray, type:String):ShimBlob
		{
			var b:ShimBlob = new ShimBlob(type);
			
			Copy(src, b.ba, src.length);
			
			return b;
		}
		
		public static function Copy(src:ByteArray, dst:ByteArray, bytes:int):void
		{
			src.readBytes(dst, dst.position, bytes);
			dst.position += bytes;
		}
		
		public function ToBase64():String
		{
			ba.position = 0;
			var str:String = ShimUtils.StringFromByteArray(ba);
			return str;
			
		}
		
		
	}

}