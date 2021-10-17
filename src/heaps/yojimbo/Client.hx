package heaps.yojimbo;

import haxe.crypto.Base64;
import yojimbo.Native;
import heaps.yojimbo.Common;

class ServerConnection extends hxbit.NetworkHost.NetworkClient {
	var _client : yojimbo.Native.Client;
	var _channel : Int;
	public function new(host : Client, client: yojimbo.Native.Client, channel = 0 ) {
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
		//trace('Sending to server on channel ${channel} len: ${bytes.length} msg: ${Base64.encode(bytes)}' );

		var m = _client.createMessage(0); // What should the type be used for?  Should probably be removed
		m.setPayload( bytes.getData(), bytes.length );
        _client.sendMessage(channel, m);
		//trace("Done sending message");
	}
	override function stop() {
		super.stop();
		_client.disconnect();
	}
	public function process(m : yojimbo.Native.Message,  channel = 0) {
		var len = -1;
		var b : hl.Bytes = m.accessPayload(len);
		var bytes = b.toBytes(len);
		if (len > 0 && b != null) {
			var input = new haxe.io.BytesInput(bytes, 0, len);
			this.processMessagesData(bytes, 0, len);
			//trace('message from server on channel ${channel} len: ${len} msg: ${Base64.encode(bytes)}' );
		} else {
			trace("Empty bytes?");
		}
		
	}
}

class Client extends Host {
	var connected = false;
	var _allocator : yojimbo.Native.Allocator;
	var _matcher : yojimbo.Native.Matcher;
	var _clientID : Int;
	var _connectionToken : haxe.io.Bytes;
	var _adapter : yojimbo.Native.Adapter;
	var _client : yojimbo.Native.Client;
	var _connected = false;
	var _connection : ServerConnection;

	static var  _self : Client;
	
	public function id() {
		return _clientID;
	}

	public function connection() : ServerConnection {
		return _connection;
	}
	public function new(clientID) {
		super();
		Common.initialize();
		_allocator = yojimbo.Native.Allocator.getDefault();
		_adapter = new Adapter();
		_clientID = clientID;
		_self = this;
	}


	// This will stall until we get a response
	// Should make this async in the future
	public function getMatchtoken(matcherHost, port, certificate : haxe.io.Bytes) {
		_matcher = new yojimbo.Native.Matcher( _allocator );
		
		if (!_matcher.initialize(certificate, certificate.length)) {
			trace("error: failed to initialize matcher");
			return false;
		}

		_matcher.requestMatch(matcherHost, port, ProtocolId, _clientID, false);

		if (_matcher.getMatchStatus() == MatchStatus.MATCH_FAILED) {
			trace("\nRequest match failed. Is the matcher running?\n");
			return false;
		} else {
			trace("Match status " + _matcher.getMatchStatus());
		}

		var ctlen = -1;
		var connectToken = _matcher.getConnectToken(ctlen);
		trace("Got connection token " + ctlen);

		_connectionToken = connectToken.toBytes(ctlen);
		trace("Got connection token " + _connectionToken);
		trace("Got connection token length " + ctlen);
		return true;
	}

	public function connect( time ) {
		close();
		isAuth = false;
		var address = new Address("0.0.0.0", ClientPort);

		_client = new yojimbo.Native.Client(_allocator, address, config, _adapter, time);
		
		var serverAddress = new Address("127.0.0.1", ServerPort);
		trace("Connecting to (doesn't matter - secure connections get it from the connect token) " + serverAddress.toString());

		// Initiate connection, does not resolve immediately
		_client.connect(_clientID, _connectionToken);

		trace("Connected? to  ");
		if (_client.isDisconnected())
			throw "Something went wrong with the connection";

		var clientAddress = _client.getAddress().toString();

		trace("Client address is " + clientAddress);

		return true;
	}

	public function close() {
		if (connected) {
			connected = false;
			_client.disconnect();
		}
	}
	override function dispose() {
		close();
		super.dispose();
		Common.shutdown();
	}

	function onConnection() {
		
	}
	public function incomingUpdate(time, dt : Float) : Bool{

        _client.receivePackets();

        if (_client.isDisconnected()) {
            trace("Disconnected post loop");
            return false;
        }

        _client.advanceTime(time);

        if (_client.hasConnectionFailed()) {
            trace("Connection has failed");
            return false;
        }

        while (_adapter.dequeue()) {
            switch(_adapter.getEventType()) {
                case HLEventType.HLYOJIMBO_CLIENT_CONNECT: 
                    trace("Connected!!!!!!!!!!");
                case HLEventType.HLYOJIMBO_CLIENT_DISCONNECT: 
                    trace("Disconnected!");
                default:
					trace("HUH????????? UNKNOWN EVENT!");
            }
        }
        if (_client.isConnected()) {
			if (!_connected) {
				_connected = true;
				_connection = new ServerConnection(this, _client, 0);
				self = _connection;
				clients = [_connection];
				onConnection();
			}

			var channel = 0;
            var m : Message = _client.receiveMessage(channel);
            while (m != null) {
				_connection.process(m,channel);
				m.dispose();
                _client.releaseMessage(m);
                m = _client.receiveMessage(0);
            }   
        }
        return true;
		
	}

	public function outgoingUpdate() {
		flush();
		_client.sendPackets();
	}


}

