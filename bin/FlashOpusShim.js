
window.ShimFormData = function()
{
	this.dictKeyToArrValue = {};
}

window.ShimFormData.prototype.isShimFormData = true;

window.ShimFormData.prototype.append = function(name, value, filename)
{
	var arr = this.dictKeyToArrValue[name];
	
	if( arr == null ) 
	{
		arr = [];
		this.dictKeyToArrValue[name] = arr;
	}
	
	arr.push(value);
}

window.ShimFormData.prototype.delete = function(name)
{
	delete this.dictKeyToArrValue[name];
}

window.ShimFormData.prototype.get = function(name)
{
	var arr = this.dictKeyToArrValue[name];
	
	if( ! arr ) return undefined;
	
	return arr[0];
}

window.ShimFormData.prototype.getAll = function(name)
{
	var arr = this.dictKeyToArrValue[name];
	
	if( ! arr ) return [];
	
	return arr.concat();
}

window.ShimFormData.prototype.has = function(name)
{
	return this.dictKeyToArrValue[name] != undefined;
}

window.ShimFormData.prototype.dictKeyToArrValue = null;

window.ShimFormData.prototype.set = function(name, value, filename)
{
	var arr = [];
	
	this.dictKeyToArrValue[name] = arr;

	arr.push(value);
}




var originalXHR = XMLHttpRequest;

window.XMLHttpRequest = function(url, protocols)
{
	this.instanceId = FlashOpusShim_GetFlash().ShimXHR_New();
		
	XMLHttpRequest.dictInstanceIdToObject[this.instanceId] = this;
}

window.XMLHttpRequest.dictInstanceIdToObject = {};

window.XMLHttpRequest.prototype.instanceId = 0;

window.XMLHttpRequest.prototype.onreadystatechange = null;

window.XMLHttpRequest.prototype.readyState = 0;

window.XMLHttpRequest.prototype.response = null;

window.XMLHttpRequest.prototype.status = 0;

window.XMLHttpRequest.prototype.msgQueue = null;

window.XMLHttpRequest.prototype.open = function(method, url)
{
	FlashOpusShim_GetFlash().ShimXHR_open(this.instanceId, method, url);
}

window.XMLHttpRequest.prototype.setRequestHeader = function(header, value)
{
	FlashOpusShim_GetFlash().ShimXHR_setRequestHeader(this.instanceId, header, value);
}

window.XMLHttpRequest.prototype.append = function(name, value)
{
	var self = this;
	
	if( value.isShimBlob )
	{
		var obj = 
		{ 	
			ready:true,
			
			callback: function() 
			{
				FlashOpusShim_GetFlash().ShimXHR_append(self.instanceId, name, arg.instanceId);
			}
		}
		
		this.Enqueue(obj);
		
	}
		
	else if( typeof(value) == typeof("") ) 
	{
		var obj = 
		{
			ready:true,
			
			callback: function() 
			{
				FlashOpusShim_GetFlash().ShimXHR_append(self.instanceId, name, value);
			}
		}
		
		this.Enqueue(obj);
	}
	
	else
	{
		var obj = 
		{
		};
		
		var reader = new FileReader();
	
		var self = this;
		
		reader.onload = function()
		{
			var dataUrl = reader.result;
			var base64 = dataUrl.split(',')[1];
			
			obj.callback = function()
			{
				FlashOpusShim_GetFlash().ShimXHR_append(self.instanceId, name, base64, true);
			}
			
			obj.ready = true;
		};
		
		this.Enqueue(obj);
	  
		reader.readAsDataURL(value);
	}
}

window.XMLHttpRequest.prototype.ServiceQueue = function()
{
	var obj = this.msgQueue[0];
	
	if( obj.ready ) 
	{
		obj.callback();
		
		this.msgQueue.shift();
	}
	
	if( this.msgQueue.length == 0 )
	{
		this.msgQueue = null;
		
		clearInterval(this.serviceId);
		
		this.serviceId = null;
	}
}

window.XMLHttpRequest.prototype.Enqueue = function(obj)
{
	if( ! this.msgQueue )
	{
		this.msgQueue = [];
		
		var self = this;
		
		this.serviceId = setInterval(function(){self.ServiceQueue();}, 0);
	}
	
	this.msgQueue.push(obj);
}

window.XMLHttpRequest.prototype.send = function(arg)
{
	if( arg.isShimFormData ) 
	{
		for(var key in arg.dictKeyToArrValue)
		{
			var arr = arg.dictKeyToArrValue[key];
			
			for(i = 0 ; i < arr.length ; i++)
			{
				this.append(key, arr[i]);
			}
		}
	}
	
	else
		this.append("", arg);
	
	//FlashOpusShim_GetFlash().ShimXHR_send(this.instanceId);
	
	var self = this;
	
	var obj = 
	{
		ready:true, callback: function()
		{
			FlashOpusShim_GetFlash().ShimXHR_send(self.instanceId);
		}
	};
	
	this.Enqueue(obj);
}

window.XMLHttpRequest.prototype.abort = function(arg)
{
	FlashOpusShim_GetFlash().ShimXHR_abort(this.instanceId);
}
		
		
	
var originalWebSocket = WebSocket;

window.WebSocket = function(url, protocols)
{
	this.instanceId = FlashOpusShim_GetFlash().ShimWebSocket_New(url, protocols);
		
	WebSocket.dictInstanceIdToObject[this.instanceId] = this;
}

window.WebSocket.dictInstanceIdToObject = {};

window.WebSocket.prototype.instanceId = 0;

window.WebSocket.prototype.onopen = null;
window.WebSocket.prototype.onclose = null;
window.WebSocket.prototype.onmessage= null;

window.WebSocket.prototype.send = function(arg)
{
	if( arg.isShimBlob )
	{
		FlashOpusShim_GetFlash().ShimWebSocket_Send(this.instanceId, arg.instanceId);
	}
	
	else if( typeof(arg) == typeof("") ) 
	{
		FlashOpusShim_GetFlash().ShimWebSocket_Send(this.instanceId, arg);
	}
		
	else
	{
		var reader = new FileReader();
	
		
		var self = this;
		
		reader.onload = function()
		{
			var dataUrl = reader.result;
			var base64 = dataUrl.split(',')[1];
			
			FlashOpusShim_GetFlash().ShimWebSocket_Send(self.instanceId, base64, true);
		};
	  
		reader.readAsDataURL(arg);
	}
		
	
}

window.WebSocket.prototype.close = function()
{	
	FlashOpusShim_GetFlash().ShimWebSocket_Close(this.instanceId);
}



//Blobs are opqaue, have no internal methods, so can't be overrided. So this is a handle to a flash bytearray which can create a blob on demand.

window.ShimBlob = function(arg, options)
{
	if( typeof(arg) == typeof(1) ) 
	{
		this.instanceId = arg;
		this.type = FlashOpusShim_GetFlash().ShimBlob_GetType(this.instanceId);
	}
		
	else
	{
		this.type = (! options)? "" : options.type;
		
		var arrIds = [];
		
		for(var i = 0 ; i < arg.length ; i++)
			arrIds[i] = arg[i].instanceId;
		
		this.instanceId = FlashOpusShim_GetFlash().ShimBlob_New(arrIds, this.type);
	}
	
	ShimBlob.dictInstanceIdToObject[this.instanceId] = this;
	
}




window.ShimBlob.dictInstanceIdToObject = {};

window.ShimBlob.prototype.isShimBlob = true;

window.ShimBlob.prototype.instanceId = 0;

window.ShimBlob.prototype.type = "";

window.ShimBlob.prototype.Realize = function()
{
	var contentType = this.type;
	
	var base64Data = FlashOpusShim_GetFlash().ShimBlob_Realize(this.instanceId);
	
	contentType = contentType || '';
    var sliceSize = 1024;
    var byteCharacters = atob(base64Data);
    var bytesLength = byteCharacters.length;
    var slicesCount = Math.ceil(bytesLength / sliceSize);
    var byteArrays = new Array(slicesCount);

    for (var sliceIndex = 0; sliceIndex < slicesCount; ++sliceIndex) {
        var begin = sliceIndex * sliceSize;
        var end = Math.min(begin + sliceSize, bytesLength);

        var bytes = new Array(end - begin);
        for (var offset = begin, i = 0 ; offset < end; ++i, ++offset) {
            bytes[i] = byteCharacters[offset].charCodeAt(0);
        }
        byteArrays[sliceIndex] = new Uint8Array(bytes);
    }
	
	return new Blob(byteArrays, { type: contentType });
}

//---------------------------------------------------------------------------------------

//Create a url that represents a flash blob, or a standard blob

var oldCreateObjectURL = window.URL.createObjectURL;

window.URL.createObjectURL = function(obj)
{
	if( obj.isShimBlob )
		return "ShimBlob:" + obj.instanceId;
		
	else return oldCreateObjectURL(obj);
}

//---------------------------------------------------------------------------------------

//The Audio class will check whether the src url represents a flash blob, if not, normal audio methods can be used.

var originalAudio = Audio;

window.Audio = function()
{
	this.instanceId = FlashOpusShim_GetFlash().Audio_New();
		
	Audio.dictInstanceIdToObject[this.instanceId] = this;
	
	this.original = new originalAudio();
		
}

window.Audio.dictInstanceIdToObject = {};

window.Audio.prototype.instanceId = 0;

window.Audio.prototype.original = null;

window.Audio.prototype.srcUsesFlash = false;

window.Audio.prototype.play = function()
{
	this.srcUsesFlash = FlashOpusShim_GetFlash().Audio_SrcUsesFlash(this.instanceId, this.src);
	
	if( ! this.srcUsesFlash ) 
	{
		this.original.src = this.src;
		this.original.play();
	}
	
	else
		FlashOpusShim_GetFlash().Audio_Play(this.instanceId);
}

window.Audio.prototype.pause = function()
{
	if( ! this.srcUsesFlash ) 
		this.original.pause();
	
	else
		FlashOpusShim_GetFlash().Audio_Pause(this.instanceId);
}

window.Audio.prototype.canPlayType = function(type)
{
	var str = this.original.canPlayType(type);
	
	if( str == "" ) 
		str = FlashOpusShim_GetFlash().Audio_CanPlayType(this.instanceId, type);
		
	return str;
}


//---------------------------------------------------------------------------------------

//Creates a flash mediarecorder or a standard mediarecorder depending entirely on what stream (getUserMedia) was used.

var originalMediaRecorder = window.MediaRecorder ? window.MediaRecorder:undefined;

window.MediaRecorder = function(stream, options)
{
	if( stream.isFlashOpusShim ) 
	{
		this.instanceId = FlashOpusShim_GetFlash().MediaRecorder_New(options);
		
		this.mimeType = FlashOpusShim_GetFlash().MediaRecorder_GetMimeType(this.instanceId);
		
		MediaRecorder.dictInstanceIdToObject[this.instanceId] = this;
	}
	
	else
	{
		this.original = new originalMediaRecorder(stream, options);
		
		this.mimeType = this.original.mimeType;
		
		var self = this;
		
		this.original.onstart 		  = function() { if( self.onstart ) 		self.onstart.apply(self, arguments); } 
		this.original.onstop 		  = function() { if( self.onstop ) 			self.onstop.apply(self, arguments); } 
		this.original.ondataavailable = function() { if( self.ondataavailable ) self.ondataavailable.apply(self, arguments); }
	}
}

window.MediaRecorder.dictInstanceIdToObject = {};

window.MediaRecorder.prototype.instanceId = 0;

window.MediaRecorder.prototype.original = null;


window.MediaRecorder.prototype.onstop		   = null;
window.MediaRecorder.prototype.onstart		   = null;
window.MediaRecorder.prototype.ondataavailable = null;

window.MediaRecorder.prototype.state = "unknown";

window.MediaRecorder.prototype.mimeType = null;

window.MediaRecorder.prototype.start = function(timeslice)
{
	if( this.original )
		this.original.start(timeslice);
		
	else
		FlashOpusShim_GetFlash().MediaRecorder_Start(this.instanceId, timeslice);
}

window.MediaRecorder.prototype.stop = function()
{
	if( this.original ) 
		this.original.stop();
		
	else
		FlashOpusShim_GetFlash().MediaRecorder_Stop(this.instanceId);
}

window.MediaRecorder.prototype.requestData = function()
{
	if( this.original ) 
		this.original.requestData();
		
	else
		FlashOpusShim_GetFlash().MediaRecorder_RequestData(this.instanceId);
}

//---------------------------------------------------------------------------------------

//Some extra mic permission functions purely for flash.

window.microphonePermission = function(permanent)
{
	FlashOpusShim_GetFlash().RequestMicrophoneAccess(permanent);
}

window.OnMicAccessChange = function(granted)
{
	console.log("Mic access:" + granted);
}

//---------------------------------------------------------------------------------------

//If called, gets a flash implementation of a microphone (no video). If you don't want a flash implemtation, then don't call.

navigator.FlashOpusShim_GetUserMedia = function(constraints, onSuccess, onError)
{
	var flashvars =
	{
	};
	
	var params =
	{
		menu: "false",
		scale: "noScale",
		allowFullscreen: "true",
		allowScriptAccess: "always",
		bgcolor: "",
		wmode: "direct", // can cause issues with FP settings & webcam
		allowscriptaccess: true
	};
	
	var attributes =
	{
		id:"FlashOpusShim"
	};
	
	window.FlashOpusShim_init_constraints = constraints;
	window.FlashOpusShim_init_onSuccess   = onSuccess;
	window.FlashOpusShim_init_onError     = onError;
	
	swfobject.embedSWF(
		"FlashOpusShim.swf", 
		"altContent", "300", "200", "10.0.0", 
		"expressInstall.swf", 
	flashvars, params, attributes);
}

//---------------------------------------------------------------------------------------
			
//Callbacks from flash, re-routed through a particular object instance.

window.FlashOpusShim_GetFlash = function()
{
	return document.getElementById('FlashOpusShim');
}
	  
window.FlashOpusShim_Handshake = function()
{
	FlashOpusShim_GetFlash().Init(FlashOpusShim_init_constraints);
}

window.FlashOpusShim_HandshakeError = function(message, name)
{
	FlashOpusShim_init_onError(new DOMException(message, name));
}

window.FlashOpusShim_HandshakeSuccess = function()
{
	var stream = { isFlashOpusShim: true }
	
	FlashOpusShim_init_onSuccess( stream );
}

window.FlashOpusShim_MediaRecorder_OnStop = function(instanceId)
{
	var mr = MediaRecorder.dictInstanceIdToObject[instanceId];
	
	if( mr && mr.onstop ) 
		mr.onstop.call(mr);
}

window.FlashOpusShim_MediaRecorder_OnStart = function(instanceId)
{
	var mr = MediaRecorder.dictInstanceIdToObject[instanceId];
	
	if( mr && mr.onstart ) 
		mr.onstart.call(mr);
}

window.FlashOpusShim_MediaRecorder_OnDataAvailable = function(instanceId, blobInstanceId)
{
	var e = {};
	
	var sb = new ShimBlob(blobInstanceId);
	
	e.data = sb;
	
	var mr = MediaRecorder.dictInstanceIdToObject[instanceId];
	
	if( mr && mr.ondataavailable ) 
		mr.ondataavailable.call(mr, e);		
}

window.FlashOpusShim_ShimWebSocket_OnOpen = function(instanceId)
{
	var e = {};
	
	var ws = WebSocket.dictInstanceIdToObject[instanceId];
	
	if( ws ) 
		ws.onopen.call(ws, e);
}

window.FlashOpusShim_ShimWebSocket_OnClose = function(instanceId)
{
	var e = {};
	
	var ws = WebSocket.dictInstanceIdToObject[instanceId];
	
	if( ws ) 
		ws.onclose.call(ws, e);
}

window.FlashOpusShim_ShimWebSocket_OnMessage = function(instanceId, data, isShimBlob)
{
	var e = {};
	
	e.data = isShimBlob? new ShimBlob(data) : data;
	
	var ws = WebSocket.dictInstanceIdToObject[instanceId];
	
	if( ws ) 
		ws.onmessage.call(ws, e);	
}


window.FlashOpusShim_ShimXHR_UpdateProperties = function(instanceId, readyState, status, response, isShimBlob)
{
	var x = XMLHttpRequest.dictInstanceIdToObject[instanceId];
	
	if( ! x ) 
		return;
	
	x.status = status;
	x.response = isShimBlob? new ShimBlob(response) : response;
	
	if( x.readyState != readyState ) 
	{
		x.readyState = readyState;
		
		if( x.onreadystatechange )
			x.onreadystatechange.call(x, {});	
	}
		
}
	
	