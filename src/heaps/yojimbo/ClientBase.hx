package heaps.yojimbo;



class ClientBase extends Host {
	var _client : yojimbo.Native.Client;
	var _connection : ServerConnection;
	var _clientID : Int;
	var _connected = false;

	public function new(resetStatics : Bool, protocolID : Int) {
		super(resetStatics, protocolID);
		isAuth = false;
	}
	public var onConnected : (c : ServerConnection) -> Void;

	public  function connected() {
		if (_client == null) return false;
		return _client.isConnected() && _connected;
	}
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
            var m : yojimbo.Native.Message = _client.receiveMessage(channel);
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

	static function setSelf( s : ClientBase) {
		_self = s;
	}
	static var  _self : ClientBase;
}
