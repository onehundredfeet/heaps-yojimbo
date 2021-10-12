package heaps.yojimbo;




class Host extends hxbit.NetworkHost {
	var config : yojimbo.Native.ClientServerConfig;

	public function new () {
		if (hxbit.NetworkHost.current != null) {
			throw "Can not have more than one host";
		}
		
		super();
		config = getConfig();

		
	}

	function getConfig() : yojimbo.Native.ClientServerConfig {
		var channel = new yojimbo.Native.ChannelConfig();
		channel.type = yojimbo.Native.ChannelType.CHANNEL_TYPE_RELIABLE_ORDERED;
		var config = new yojimbo.Native.ClientServerConfig();
		config.addChannel(channel);
		config.protocolId = Common.ProtocolId;
	
		return config;
	}
}

