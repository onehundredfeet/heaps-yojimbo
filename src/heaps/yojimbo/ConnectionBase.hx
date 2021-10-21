package heaps.yojimbo;


class ConnectionBase extends hxbit.NetworkHost.NetworkClient {
	var _handlers : Array< (yojimbo.Native.Message, Int) -> Void > = [];
	
	public function setHandler(  msgType : Int,  f : (yojimbo.Native.Message, Int) -> Void) {
		if (msgType < 1) {
			throw ("Msg type must be greater than 0");
		}
		if (_handlers.length <= msgType) {
			_handlers.resize( msgType + 1);
		}
		_handlers[msgType] =  f;
	}


	public function process(m : yojimbo.Native.Message,  channel) {
		var len = -1;
		var b : hl.Bytes = m.accessPayload(len);
		var bytes = b.toBytes(len);
		if (len > 0 && b != null) {
			switch(m.getType()) {
				case Common.MT_HEAPS:this.processMessagesData(bytes, 0, len);
				default: if (_handlers[m.getType()] != null) _handlers[m.getType()](m, channel);
			}
		//	trace("Processing bytes of length " + bytes.length);
		//	trace('message from client ${_clientID} on channel ${channel} len: ${len} msg: ${Base64.encode(bytes)}' );
			
		} else {
			trace("Empty bytes?");
		}
	}


}