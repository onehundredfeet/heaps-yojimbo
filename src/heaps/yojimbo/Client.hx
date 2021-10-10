package heaps.yojimbo;

class ServerConnection extends hxbit.NetworkHost.NetworkClient {
	public function new(host : Client ) {
		super(host);
	}
	override function error(msg:String) {
		super.error(msg);
	}
	override function send( bytes : haxe.io.Bytes ) {
	}
	override function stop() {
	}
/*
	var socket : Socket;

	public function new(host, s) {
		super(host);
		this.socket = s;
		if( s != null )
			s.onData = function() {
				// process all pending messages
				while( socket != null && readData(socket.input, socket.input.available) ) {
				}
			}
	}

	override function error(msg:String) {
		socket.close();
		super.error(msg);
	}

	override function send( bytes : haxe.io.Bytes ) {
		socket.out.wait();
		socket.out.writeInt32(bytes.length);
		socket.out.write(bytes);
		socket.out.flush();
	}

	override function stop() {
		super.stop();
		if( socket != null ) {
			socket.close();
			socket = null;
		}
	}
	*/

}

class Client extends Host {
	var connected = false;
	public function connect( host : String, port : Int, ?onConnect : Bool -> Void ) {
		close();
		isAuth = false;

	}
	function close() {
		connected = false;
		
	}
	override function dispose() {
		super.dispose();
		close();
	}
}

