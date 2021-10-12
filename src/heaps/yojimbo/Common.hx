package heaps.yojimbo;


import yojimbo.Native;
import sys.io.File;
import  haxe.crypto.Base64;

final  ProtocolId = 0x11223344; //.make(,0x556677);
final ClientPort = 30000;
final ServerPort = 40000;

var initialized = false;
function initialize() {
    if (!initialized) {
        yojimbo.Native.Yojimbo.initialize();
        initialized = true;
    }
}

function shutdown() {
    if (initialized) {
        yojimbo.Native.Yojimbo.shutdown();
        initialized = false;
    }
}

function loadCertificate(cert_file) : haxe.io.Bytes{
    var certStr = File.getContent(cert_file);
    var r = ~/(-----BEGIN CERTIFICATE-----)|(-----END CERTIFICATE-----)|[\r\n]/g;
    var cleanCertStr = r.replace(certStr, "");
    var certBytes = Base64.decode(cleanCertStr);

    if (certBytes == null) {
        throw("error: failed to loading certificate file " + cert_file);
    }

    return certBytes;
}




class User implements hxbit.Serializable {
    @:s public var name : String;
    @:s public var age : Int;
    @:s public var friends : Array<User>;    
}


class Cursor implements hxbit.NetworkSerializable {

	@:s var color : Int;
	@:s public var uid : Int;
	@:s public var x(default, set) : Float;
	@:s public var y(default, set) : Float;


    // source initialization
    public function new ( ) {
        enableReplication = true;
    }

    
    // shared initialization
    public function init() {

    }

    // NetworkSerializable init
    public function alive() {
		init();
		// refresh bmp
		this.x = x;
		this.y = y;
        /*
		if( uid == net.uid ) {
			net.cursor = this;
			net.host.self.ownerObject = this;
		}
        */
	}

    public function networkAllow( op : hxbit.NetworkSerializable.Operation, propId : Int, client : hxbit.NetworkSerializable ) : Bool {
		return client == this;
	}

    @:rpc function blink( s : Float ) {
        /*
		bmp.scale(s);
		net.event.waitUntil(function(dt) {
			bmp.scaleX *= Math.pow(0.9, dt * 60);
			bmp.scaleY *= Math.pow(0.9, dt * 60);
			if( bmp.scaleX < 1 ) {
				bmp.scaleX = bmp.scaleY = 1;
				return true;
			}
			return false;
		});
        */
	}

}

/*
ChannelConfig() : type ( CHANNEL_TYPE_RELIABLE_ORDERED )
        {
            disableBlocks = false;
            sentPacketBufferSize = 1024;
            messageSendQueueSize = 1024;
            messageReceiveQueueSize = 1024;
            maxMessagesPerPacket = 256;
            packetBudget = -1;
            maxBlockSize = 256 * 1024;
            blockFragmentSize = 1024;
            messageResendTime = 0.1f;
            blockFragmentResendTime = 0.25f;
        }
*/
