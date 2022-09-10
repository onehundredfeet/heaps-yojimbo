package heaps.yojimbo;

import yojimbo.Native;
import heaps.yojimbo.Common;


class RemoteClient extends ClientBase {
	var _allocator : yojimbo.Native.Allocator;
	var _matcher : yojimbo.Native.Matcher;
	var _connectionToken : haxe.io.Bytes;
	var _adapter : yojimbo.Native.Adapter;
	
	public function new(clientID) {
		super(true);
		_allocator = yojimbo.Native.Allocator.getDefault();
		_adapter = new Adapter();
		_clientID = clientID;
		
		ClientBase.setSelf(this);
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

		var address = new Address("0.0.0.0", ClientPort + 1);

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
	}

	function onConnection() {
		
	}


}

