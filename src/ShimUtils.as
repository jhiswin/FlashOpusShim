package 
{
	import flash.utils.ByteArray;
	/**
	 * ...
	 * @author 
	 */
	public class ShimUtils 
	{
		private static const BASE64_CHARS:String = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";
		//data.writeUTFBytes("string");
		//data.readUTFBytes(data.length);
		
		public static function StringFromByteArray(data:ByteArray):String
		{
			// Initialise output
			var output:String = "";
			
			// Create data and output buffers
			var dataBuffer:Array = [];
			var outputBuffer:Array = [];
			
			if( dataBuffer.length   != 0 ) throw "";
			if( outputBuffer.length != 0 ) throw "";
			
			// Rewind ByteArray
			data.position = 0;
			
			var i:int;
			
			// while there are still bytes to be processed
			while (data.bytesAvailable > 0)
			{
				// Create new data buffer and populate next 3 bytes from data
				dataBuffer.length = 0;
				for (i = 0; i < 3 && data.bytesAvailable > 0; i++)
					dataBuffer.push(data.readUnsignedByte());
				
				// Convert to data buffer Base64 character positions and 
				// store in output buffer
				outputBuffer[0] = (dataBuffer[0] & 0xfc) >> 2;
				outputBuffer[1] = ((dataBuffer[0] & 0x03) << 4) | ((dataBuffer[1]) >> 4);
				outputBuffer[2] = ((dataBuffer[1] & 0x0f) << 2) | ((dataBuffer[2]) >> 6);
				outputBuffer[3] = dataBuffer[2] & 0x3f;
				
				// If data buffer was short (i.e not 3 characters) then set
				// end character indexes in data buffer to index of '=' symbol.
				// This is necessary because Base64 data is always a multiple of
				// 4 bytes and is basses with '=' symbols.
				for (i = dataBuffer.length; i < 3; i++) 
					outputBuffer[i + 1] = 64;
				
				// Loop through output buffer and add Base64 characters to 
				// encoded data string for each character.
				for (i = 0; i < outputBuffer.length; i++)
					output += BASE64_CHARS.charAt(outputBuffer[i]);
			}
			
			dataBuffer.length   = 0;
			outputBuffer.length = 0;
			
			// Return encoded data
			return output;
		}
		
		public static function ByteArrayFromString(data:String, out:ByteArray):void
		{
			// Create data and output buffers
			var dataBuffer:Array   = [];
			var outputBuffer:Array = [];
			
			var i:int;
			var j:int;
			
			// While there are data bytes left to be processed
			for (i = 0; i < data.length; i += 4)
			{
				// Populate data buffer with position of Base64 characters for
				// next 4 bytes from encoded data
				for (j = 0; j < 4 && i + j < data.length; j++)
					dataBuffer[j] = BASE64_CHARS.indexOf(data.charAt(i + j));
				
      			// Decode data buffer back into bytes
				outputBuffer[0] = (dataBuffer[0] << 2) + ((dataBuffer[1] & 0x30) >> 4);
				outputBuffer[1] = ((dataBuffer[1] & 0x0f) << 4) + ((dataBuffer[2] & 0x3c) >> 2);		
				outputBuffer[2] = ((dataBuffer[2] & 0x03) << 6) + dataBuffer[3];
				
				// Add all non-padded bytes in output buffer to decoded data
				for (j = 0; j < outputBuffer.length; j++)
				{
					if (dataBuffer[j+1] == 64) break;
					out.writeByte(outputBuffer[j]);
				}
			}
			
			dataBuffer.length   = 0;
			outputBuffer.length = 0;
			
		}
		
	}

}