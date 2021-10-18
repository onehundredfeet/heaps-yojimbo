package heaps.yojimbo;
import heaps.yojimbo.Common.ClientPort;
import haxe.crypto.Base64;
import hl.Bytes;
import haxe.io.UInt8Array;

class ClientConnection extends hxbit.NetworkHost.NetworkClient {
    var _server : yojimbo.Native.Server;
    var _clientIdx : Int;
	var _clientID : Int;

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
	override function send( bytes : haxe.io.Bytes ) {
//		trace("Sending to client '" + Base64.encode(bytes) + "'");
        var m = _server.createMessage(_clientIdx);
		m.setPayload( bytes.getData(), bytes.length );
        _server.sendMessage(_clientIdx, 0, m);

	}
	override function stop() {
	}

	public function process(m : yojimbo.Native.Message,  channel = 0) {
		var len = -1;
		var b : hl.Bytes = m.accessPayload(len);
		var bytes = b.toBytes(len);
		if (len > 0 && b != null) {
		//	trace("Processing bytes of length " + bytes.length);
		//	trace('message from client ${_clientID} on channel ${channel} len: ${len} msg: ${Base64.encode(bytes)}' );
			this.processMessagesData(bytes, 0, len);
		} else {
			trace("Empty bytes?");
		}
		
	}

	public function processOld(m : yojimbo.Native.Message,  channel = 0) {
		
		var len = -1;
		var b : Bytes = m.accessPayload(len);
		var bytes = b.toBytes(len);
		//trace("Message from client: " + _clientIdx + " len: " + len);

//		this.processMessage(bytes,0);
	}

}

class Server extends Host {
	var connected = false;
    var _adapter : yojimbo.Native.Adapter;
    var _server : yojimbo.Native.Server;
	var _allocator : yojimbo.Native.Allocator;
	var _loopbackClient : yojimbo.Native.Client;

	public var onClientConnected : ( c : ClientConnection) -> Void;
    static var privateKeyArrayInt : Array<Int> = [ 0x60, 0x6a, 0xbe, 0x6e, 0xc9, 0x19, 0x10, 0xea, 
        0x9a, 0x65, 0x62, 0xf6, 0x6f, 0x2b, 0x30, 0xe4, 
        0x43, 0x71, 0xd6, 0x2c, 0xd1, 0x99, 0x27, 0x26,
        0x6b, 0x3c, 0x60, 0xf4, 0xb7, 0x15, 0xab, 0xa1 ];
    
        static var privateKey:haxe.io.Bytes = UInt8Array.fromArray(privateKeyArrayInt).view.buffer;
    
    static final MaxClients = 10;
    var clientsIdx : Array<Int> = [];
	var _clients : Array<ClientConnection> = [];

	public function new() {
		super();
		isAuth = true;
//		trace("New");
		Common.initialize();
		_allocator = yojimbo.Native.Allocator.getDefault();
	}

    public function start(host : String, port : Int, time : Float) {
//		trace("Start");
        var address = new yojimbo.Native.Address( host, port );
		
        _adapter = new yojimbo.Native.Adapter();

        _server = new yojimbo.Native.Server( _allocator, privateKey, address, config, _adapter, time );
        
        yojimbo.Native.Yojimbo.logLevel(yojimbo.Native.LogLevel.YOJIMBO_LOG_LEVEL_INFO);

		trace("Starting");
        _server.start( MaxClients );

		this.makeAlive();
    }

	public function startLookupback( clientID, time : Float) {
		var address = new yojimbo.Native.Address( "0.0.0.0", ClientPort );
		_loopbackClient = new yojimbo.Native.Client(_allocator, address, config, _adapter, time );

		_adapter.bindLoopbackClient(_loopbackClient);
		_adapter.bindLoopbackServer(_server);

		var c = new Client.LoopbackClient(_loopbackClient);

		_loopbackClient.connectLoopback(0, clientID, MaxClients);
		_server.connectLoopbackClient(0, clientID, null);

		return c;
	}

	public function log( s : String, ?pos : haxe.PosInfos ) {
		pos.fileName = (isAuth ? "[S]" : "[C]") + " " + pos.fileName;
		haxe.Log.trace(s, pos);
	}
	

    public function incomingUpdate(time : Float, dt : Float) {
		if (_loopbackClient != null) {
			_loopbackClient.receivePackets();
			_loopbackClient.advanceTime(time);
		}
        _server.receivePackets();
        _server.advanceTime( time );

        if ( !_server.isRunning() )
            return;

        if (_adapter.dequeue()) { 
//            trace("Remaining " + _adapter.incomingEventCount());

            if (_adapter.getEventType() == yojimbo.Native.HLEventType.HLYOJIMBO_CLIENT_CONNECT) {
				var cid = _adapter.getClientIndex();
                trace("Client conected " + cid);
                clientsIdx.push(cid);
				var c = new ClientConnection(this, _server, cid);
				_clients.push(c);
				pendingClients.push(c);
				if (onClientConnected != null) {
					onClientConnected( c );
				}
            } else if (_adapter.getEventType() == yojimbo.Native.HLEventType.HLYOJIMBO_CLIENT_DISCONNECT) {
				var cid = _adapter.getClientIndex();
                trace("Client disconected " + cid);
                clientsIdx.remove(cid);
				for(c in _clients) {
					if (c.IDX() == cid) {
						c.stop();
						_clients.remove(c);
						break;
					}
				}
				
            } else {
                trace("Unknown event " + _adapter.getEventType());
            }
        }

        for(c in _clients) {
            
            var m : yojimbo.Native.Message = null;

			final channel = 0;
            while ((m = _server.receiveMessage(c.IDX(), channel)) != null) {
//				trace('Receved message from client ${c.ID()}');
				c.process(m,channel);
				m.dispose();
                _server.releaseMessage(c.IDX(),m);
            }
        }
    }

    public function outgoingUpdate() {
		flush();
        _server.sendPackets();
    }
	public function stop() {
        _server.stop();
		Common.shutdown();
	}

	override function dispose() {
		stop();
		super.dispose();
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
