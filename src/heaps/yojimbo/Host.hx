package heaps.yojimbo;


class Host extends hxbit.NetworkHost {
	var config : yojimbo.Native.ClientServerConfig;
	var connected = false;

	public function new() {
		super();
		isAuth = false;
	}

	override function dispose() {
		super.dispose();
		close();
	}

	function close() {

		connected = false;
	}

	public function connect( host : String, port : Int, ?onConnect : Bool -> Void ) {
		close();
		isAuth = false;

	}

	/*
    
	var socket : Socket;
	public var enableSound : Bool = true;

	


	function close() {
		if( socket != null ) {
			socket.close();
			socket = null;
		}
		connected = false;
	}

	public function connect( host : String, port : Int, ?onConnect : Bool -> Void ) {
		close();
		isAuth = false;
		socket = new Socket();
		socket.onError = function(msg) {
			if( !connected ) {
				socket.onError = function(_) { };
				if( onConnect != null ) onConnect(false);
			} else
				throw msg;
		};
		self = new SocketClient(this, socket);
		socket.connect(host, port, function() {
			connected = true;
			if( host == "127.0.0.1" ) enableSound = false;
			clients = [self];
			if( onConnect != null ) onConnect(true);
		});
	}

	public function wait( host : String, port : Int, ?onConnected : NetworkClient -> Void ) {
		close();
		isAuth = false;
		socket = new Socket();
		self = new SocketClient(this, null);
		socket.bind(host, port, function(s) {
			var c = new SocketClient(this, s);
			pendingClients.push(c);
			s.onError = function(_) c.stop();
			if( onConnected != null ) onConnected(c);
		});
		isAuth = true;
	}

	public function offlineServer() {
		close();
		self = new SocketClient(this, null);
		isAuth = true;
	}
	*/
}

