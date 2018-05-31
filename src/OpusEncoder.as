package 
{
	import com.idiil.opus.CModule;
	import com.idiil.opus.vfs.DefaultVFS;
	import com.idiil.opus.vfs.FileHandle;
	import com.idiil.opus.vfs.InMemoryBackingStore;
	import com.idiil.opus.vfs.ISpecialFile;
	import flash.display.Shape;
	import flash.events.Event;
	import flash.utils.ByteArray;
	import flash.utils.Endian;

	import opus.BundleInit;
	import opus.BundleEncode;
	import opus.BundleShutdown;
	
	public class OpusEncoder extends Encoder implements ISpecialFile
	{
		public static const OPUS_APPLICATION_VOIP:int 				 = 2048; /** Best for most VoIP/videoconference applications where listening quality and intelligibility matter most */
		public static const OPUS_APPLICATION_AUDIO:int 			 	 = 2049; /** Best for broadcast/high-fidelity application where the decoded audio should be as close as possible to the input */
		public static const OPUS_APPLICATION_RESTRICTED_LOWDELAY:int = 2051; /** Only use when lowest-achievable latency is what matters most. Voice-optimized modes cannot be used. */
		
		public function OpusEncoder(sampleRate:int, channels:int, codingMode:int, secsAdd:Number) ////CModule.dispose();	
		{
			this.sampleRate = sampleRate;
			this.channels = channels;
			this.codingMode = codingMode;
			
			this.secsAdd = secsAdd;
			
			if ( ! isInitiated ) 
			{
				CModule.vfs.console = this;
				
				CModule.startAsync(this, null, null, false, true);
				
				isInitiated = true;
			}	
		}
		
		private var secsAdd:Number;
		
		private var sampleRate:int;
		private var channels:int;
		private var codingMode:int;
		
		private static var isInitiated:Boolean = false;
		
		private var shape:Shape = null;
	
		private var ptr:uint = 0;
	
		/*public override function IsEncoding():Boolean
		{
			return ptr != 0;
		}*/
		
		private var attempt:int = 0;
		
		public override function Start():void
		{
			super.Start();
			
			
		//	CModule.vfs.console = this;
				
		//	CModule.startAsync(this);
			
			
			//CModule.vfs.console = this;
			
			
			shape = new Shape();
			shape.addEventListener(Event.EXIT_FRAME, OnEnterFrame);
			
			baIn = new ByteArray();
			baInCount = 0;
			baOut = new ByteArray();
			//baOut.endian = Endian.LITTLE_ENDIAN;
			
			baIn.writeByte(0);
			baIn.writeByte(1);
			baIn.writeByte(2);
			baIn.writeByte(3);
			baInCount += 4;
			
		//	if ( attempt > 0 ) 
		//			baIn.endian = Endian.LITTLE_ENDIAN;
			
			ptr =   BundleInit("dummypath --quiet --raw --raw-bits 16 --raw-endianness 1 --raw-rate " + sampleRate + " --raw-chan " + channels + " - -"); 
			
			attempt++;
		}
		
		/*private var isFinished:Boolean = false;
		
		public override function IsFinished():Boolean
		{
			return isFinished;
		}*/
		
		private var baInCount:int = 0;
		private var baIn:ByteArray = null;
		private var baOut:ByteArray = null;
		
		public override function GetBaOut():ByteArray
		{
			return baOut;
		}
		
		public override function Finish():void
		{
			super.Finish();
			
			var samples:int = secsAdd * 44100 * channels;
			
			for (var i:int = 0 ; i < samples ; i++)
				baIn.writeFloat(0);
			
		}
		
	//	private var ignoreErr:Boolean = true;
		
		public function write(fd:int, bufPtr:int, nbyte:int, errnoPtr:int):int
        {
			if ( fd == 1 ) 
			{
				if ( baOut != null ) 
				{
					baOut.position = baOut.length;
					CModule.readBytes(bufPtr, nbyte, baOut);
					
				}
					
				else
				{
					//var a:int = 7;
				}
			}
			
			else if ( fd == 2 ) 
			{
				var str:String = CModule.readString(bufPtr, nbyte);
            
				if ( str.indexOf("sentinel") == 0 ) 
					var a:int  = 7;
				
				//if( ! ignoreErr ) 
				//	trace(str);
			}
			
			else throw new Error("");
			
            return nbyte;
        }
 
		public function WriteF32toF32(baSrc:ByteArray, frames:int, channels:int):void
		{
			//trace("Writef32tof32 " + frames);
			
			baIn.position = baIn.length;
			
			var samples:int = frames * channels;
			
			for(var i:int = 0 ; i < samples; i++)
				baIn.writeFloat( baSrc.readFloat() );
				
			baInCount += 4 * samples;
				
			/*while ( baIn.length > 8192) 
			{
			//	trace("EnterFraemEncoding " + baIn.length);
				BundleEncode(ptr);
			}*/
		}
		
		public function WriteF32toS16(baSrc:ByteArray, frames:int, channels:int):void
		{
			//trace("Writef32toS16 " + frames);
			
			baIn.position = baIn.length;
			
			var samples:int = frames * channels;
			
			for(var i:int = 0 ; i < samples; i++)
				baIn.writeShort( baSrc.readFloat() * 32767.0 );
				
			baInCount += 2 * samples;
				
			/*while ( baIn.length > 8192) 
			{
			//	trace("EnterFraemEncoding " + baIn.length);
				BundleEncode(ptr);
			}*/
		}
		
		public function WriteF32toS8(baSrc:ByteArray, frames:int, channels:int):void
		{
		//	trace("Writef32toS8 " + frames);
			
			baIn.position = baIn.length;
			
			var samples:int = frames * channels;
			
			for(var i:int = 0 ; i < samples; i++)
				baIn.writeByte( baSrc.readFloat() * 127 );
				
			baInCount += 1 * samples;
				
		/*	while ( baIn.length > 8192) 
			{
			//	trace("EnterFraemEncoding " + baIn.length);
				BundleEncode(ptr);
			}*/
		}
		
		public override function WriteF32MonoToStereo(baSrc:ByteArray, frames:int):void
		{
			WriteF32MonotoS16Stereo(baSrc, frames);
		}
		
		
		
		public function WriteF32MonotoS16Stereo(baSrc:ByteArray, frames:int):void
		{
			//trace("Writef32MonotoS16Stereo " + frames);
			
			baIn.position = baIn.length;
			
			var samples:int = frames;
			
			for (var i:int = 0 ; i < samples; i++)
			{
				var s:int = baSrc.readFloat() * 32767.0;
				//var s:int = baSrc.readFloat() * 1000;
				
				
				
				baIn.writeShort(s);
				baIn.writeShort(s);
			}
			
			baInCount += 4 * samples ;
			
			/*while ( baIn.length > 8192) 
			{
				//trace("EnterFraemEncoding " + baIn.length);
				BundleEncode(ptr);
			}*/
		}
	
		public function GetBufferInSize():int
		{
			return baIn == null? 0 : baIn.length;
		}
		
		private function OnEnterFrame(e:Event):void
		{
			var amt:int = GetState() == STATE_FINISHING? 0 : 4096;
			
			for (var i:int = 0 ; i < 10 && baIn.length > amt ; i++)
				BundleEncode(ptr);
			
			if ( GetState() == STATE_FINISHING && baIn.length == 0 ) 
			{
				shape.removeEventListener(Event.EXIT_FRAME, OnEnterFrame);
				shape = null;
				//shouldFinish = false;
			
				//ignoreErr = false;
				BundleShutdown(ptr, baInCount);
			
			//	var v:ByteArray = baOut;
			
				baIn = null;
				
				ptr = 0;
				
				//isFinished = true;
				
				super.Finished();
				
				//CModule.vfs.console = null;
				
				
				
			//	CModule.dispose();
			}
		
		}
		
        /** See ISpecialFile */
        public function read(fd:int, bufPtr:int, nbyte:int, errnoPtr:int):int//if want more than buffer full and not finished, error, need large buffer
		{ 
			baIn.position = 0;
			
			var availableBytes:int = Math.min(nbyte, baIn.length);
			
			CModule.writeBytes(bufPtr, availableBytes, baIn);//does advance src position
			
			baIn.position = availableBytes;
			baIn.readBytes(baIn, 0, baIn.length - availableBytes);
			baIn.length -= availableBytes;
			
			return availableBytes;
		}
		
        public function fcntl(fd:int, com:int, data:int, errnoPtr:int):int
			{ return 0; }
        public function ioctl(fd:int, com:int, data:int, errnoPtr:int):int 
			{ return 0; }
		
		
		
	}

}



/*

public static function Copy(source:ByteArray, dest:ByteArray, frames:int, channels:int):void
		{
			var samples:int = frames * channels;
			
			source.readBytes(dest, dest.position, samples * 4);
			dest.position += samples * 4;
		}
		
		

"$(FLASCC)/usr/bin/gcc" -jvmopt=-Xmx1G $(BASE_CFLAGS) VFS.abc opuscodec.abc $(SRCS_C) $(LIB_OGG) opus-1.1.1-beta/.libs/libopus.a speexdsp-1.2rc3/libspeexdsp/.libs/libspeexdsp.a -DHAVE_CONFIG_H -I ./ -I./opus-1.1.1-beta/include -I./opus-tools-0.1.9/include -I./speexdsp-1.2rc3/include -I./speexdsp-1.2rc3/include/speex -I$(call nativepath,$(FLASCC)/usr/include/) -emit-swc=com.idiil.opus -o $(TARGET) -flto-api=exports.txt -swf-version=14

*/