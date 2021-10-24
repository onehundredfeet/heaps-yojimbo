package heaps.yojimbo;


class ServerConnection extends ConnectionBase {
	var _client : yojimbo.Native.Client;
	var _channel : Int;
	public function new(host : ClientBase, client: yojimbo.Native.Client, channel = 0 ) {
		super(host);
		_channel = channel;
		_client = client;
	}
	override function error(msg:String) {
		super.error(msg);
	}
	override function send( bytes : haxe.io.Bytes ) {
		//trace ("Sending?");
		sendOnChannel(bytes, _channel);
	}
	public function sendOnChannel( bytes : haxe.io.Bytes,  channel : Int) {
		sendMsg(Common.MT_HEAPS, bytes, channel);
	}

	public function sendMsg( msgType : Int, bytes : haxe.io.Bytes,  channel : Int) {
		//trace('Sending to server on channel ${channel} len: ${bytes.length} msg: ${Base64.encode(bytes)}' );
		var m = _client.createMessage(msgType); // What should the type be used for?  Should probably be removed
		m.setPayload( bytes.getData(), bytes.length );
        _client.sendMessage(channel, m);
		//trace("Done sending message");
	}
	override function stop() {
		super.stop();
		_client.disconnect();
	}
}
