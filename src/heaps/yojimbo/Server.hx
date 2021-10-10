package heaps.yojimbo;
import haxe.io.UInt8Array;

class ClientConnection extends hxbit.NetworkHost.NetworkClient {
    var _server : yojimbo.Native.Server;
    var _clientIdx : Int;

	public function new(host : Server, server : yojimbo.Native.Server, idx) {
		super(host);
        _server = server;
        _clientIdx = idx;
	}
	override function error(msg:String) {
		super.error(msg);
	}
	override function send( bytes : haxe.io.Bytes ) {
        var m = _server.createMessage(_clientIdx);
        _server.sendMessage(_clientIdx, 0, m);

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

class Server extends Host {
	var connected = false;
    var _adapter : yojimbo.Native.Adapter;
    var _server : yojimbo.Native.Server;

    static var privateKeyArrayInt : Array<Int> = [ 0x60, 0x6a, 0xbe, 0x6e, 0xc9, 0x19, 0x10, 0xea, 
        0x9a, 0x65, 0x62, 0xf6, 0x6f, 0x2b, 0x30, 0xe4, 
        0x43, 0x71, 0xd6, 0x2c, 0xd1, 0x99, 0x27, 0x26,
        0x6b, 0x3c, 0x60, 0xf4, 0xb7, 0x15, 0xab, 0xa1 ];
    
        static var privateKey:haxe.io.Bytes = UInt8Array.fromArray(privateKeyArrayInt).view.buffer;
    
    static final MaxClients = 10;
    var clientsIdx : Array<Int> = [];

	public function new() {
		super();
		isAuth = false;
	}

    function start(host : String, port : Int) {
        var address = new yojimbo.Native.Address( host, port );
        var time = 100.0;
        
        _adapter = new yojimbo.Native.Adapter();

        var allocator = yojimbo.Native.Allocator.getDefault();

        _server = new yojimbo.Native.Server( allocator, privateKey, address, config, _adapter, time );
        
        yojimbo.Native.Yojimbo.logLevel(yojimbo.Native.LogLevel.YOJIMBO_LOG_LEVEL_INFO);

        _server.start( MaxClients );
    }

    function incomingUpdate(time : Float, dt : Float) {
        _server.receivePackets();

        _server.advanceTime( time );

        if ( !_server.isRunning() )
            return;

        if (_adapter.dequeue()) { 
            trace("Remaining " + _adapter.incomingEventCount());

            if (_adapter.getEventType() == yojimbo.Native.HLEventType.HLYOJIMBO_CLIENT_CONNECT) {
                trace("Client conected " + _adapter.getClientIndex());
                clientsIdx.push(_adapter.getClientIndex());
            } else if (_adapter.getEventType() == yojimbo.Native.HLEventType.HLYOJIMBO_CLIENT_DISCONNECT) {
                trace("Client disconected " + _adapter.getClientIndex());
                clientsIdx.remove(_adapter.getClientIndex());
            } else {
                trace("Unknown event " + _adapter.getEventType());
            }
        }

        for(c in clientsIdx) {
            
            var m : yojimbo.Native.Message = null;

            while ((m = _server.receiveMessage(c, 0)) != null) {
                trace("message  " );

                _server.releaseMessage(c,m);
            }
        }
    }

    function outgoingUpdate() {
        _server.sendPackets();
    }
	function close() {
        _server.stop();
	}

	override function dispose() {
		super.dispose();
		close();
	}
	

	public function wait( host : String, port : Int, ?onConnected : hxbit.NetworkHost.NetworkClient -> Void ) {
		
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
