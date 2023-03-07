package heaps.yojimbo;




class Host extends hxbit.NetworkHost {
	var config : yojimbo.Native.ClientServerConfig;
	var _protocolID : Int;

	public function new (resetStatics : Bool, protocolID : Int) {
		if (hxbit.NetworkHost.current != null) {
//			throw "Can not have more than one host";
		}
		_protocolID = protocolID;

		super(resetStatics);
		config = getConfig();
	}

	function getConfig() : yojimbo.Native.ClientServerConfig {
		var channel = new yojimbo.Native.ChannelConfig();
		channel.type = yojimbo.Native.ChannelType.CHANNEL_TYPE_RELIABLE_ORDERED;
		var config = new yojimbo.Native.ClientServerConfig();
		config.addChannel(channel);
		config.protocolId = _protocolID;
	
		return config;
	}
}

