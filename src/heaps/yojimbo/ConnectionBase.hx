package heaps.yojimbo;


class ConnectionBase extends hxbit.NetworkHost.NetworkClient {
	var _handlers : Array< (hxbit.NetworkHost.NetworkClient, yojimbo.Native.Message, Int, Dynamic) -> Void > = [];
	var _handlerData : Array<Dynamic> = [];

	public function setHandler(  msgType : Int,  f : (hxbit.NetworkHost.NetworkClient, yojimbo.Native.Message, Int, Dynamic) -> Void, d : Dynamic) {
		if (msgType < 1) {
			throw ("Msg type must be greater than 0");
		}
		if (_handlers.length <= msgType) {
			_handlers.resize( msgType + 1);
			_handlerData.resize(msgType + 1);
		}
		_handlers[msgType] =  f;
		_handlerData[msgType] = d;
	}


	public function process(m : yojimbo.Native.Message,  channel) {
		var len = -1;
		var b : hl.Bytes = m.accessPayload(len);
		var bytes = b.toBytes(len);
		if (len > 0 && b != null) {
			var mt = m.getType();

			switch(mt) {
				case Common.MT_HEAPS:this.processMessagesData(bytes, 0, len);
				default: if (_handlers[mt] != null) _handlers[mt](this, m, channel, _handlerData[mt]);
			}
		//	trace("Processing bytes of length " + bytes.length);
		//	trace('message from client ${_clientID} on channel ${channel} len: ${len} msg: ${Base64.encode(bytes)}' );
			
		} else {
			trace("Empty bytes?");
		}
	}


}