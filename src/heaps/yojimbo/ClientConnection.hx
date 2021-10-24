package heaps.yojimbo;


class ClientConnection extends ConnectionBase {
    var _server : yojimbo.Native.Server;
    var _clientIdx : Int;
	var _clientID : Int;
	public var HXBIT_CHANNEL = 0;

	public function IDX() : Int {
		return _clientIdx;
	}
	public function ID() : Int {
		return _clientID;
	}

	public function new(host : Server, server : yojimbo.Native.Server, idx) {
		super(host);
        _server = server;
        _clientIdx = idx;
		_clientID = server.getClientId(idx);
	}
	
	override function error(msg:String) {
		super.error(msg);
	}

	override function send( bytes : haxe.io.Bytes  ) {
		sendMsg( Common.MT_HEAPS, bytes, HXBIT_CHANNEL);
	}

	public function sendMsg( msgType : Int, bytes : haxe.io.Bytes,  channel : Int) {
	//		trace("Sending to client '" + Base64.encode(bytes) + "'");
		var m = _server.createMessage(_clientIdx, msgType);
		m.setPayload( bytes.getData(), bytes.length );
		_server.sendMessage(_clientIdx, channel, m);
	}

}
