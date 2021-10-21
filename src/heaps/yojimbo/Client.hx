package heaps.yojimbo;

import haxe.crypto.Base64;
import yojimbo.Native;
import heaps.yojimbo.Common;

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
		sendMsg(MT_HEAPS, bytes, channel);
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

class ClientBase extends Host {
	var _client : yojimbo.Native.Client;
	var _connection : ServerConnection;
	var _clientID : Int;
	var _connected = false;

	public var onConnected : (c : ServerConnection) -> Void;

	public function id() {
		return _clientID;
	}

	public function connection() : ServerConnection {
		return _connection;
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

		/*
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
		*/
        if (_client.isConnected()) {
			if (!_connected) {
				_connected = true;
				_connection = new ServerConnection(this, _client, 0);
				self = _connection;
				clients = [_connection];
				if (onConnected != null) {
					onConnected(_connection);
				}
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

	public function close() {
		if (_connected) {
			_connected = false;
			_client.disconnect();
		}
	}

	static var  _self : ClientBase;
}

class LoopbackClient extends ClientBase {
	public function new( c : yojimbo.Native.Client ) {
		super();
		_client = c;
	}
}

class Client extends ClientBase {
	var _allocator : yojimbo.Native.Allocator;
	var _matcher : yojimbo.Native.Matcher;
	var _connectionToken : haxe.io.Bytes;
	var _adapter : yojimbo.Native.Adapter;
	
	public function new(clientID) {
		super();
		Common.initialize();
		_allocator = yojimbo.Native.Allocator.getDefault();
		_adapter = new Adapter();
		_clientID = clientID;
		ClientBase._self = this;
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

	
	override function dispose() {
		close();
		super.dispose();
		Common.shutdown();
	}

	function onConnection() {
		
	}


}

