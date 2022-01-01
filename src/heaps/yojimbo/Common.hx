package heaps.yojimbo;


import yojimbo.Native;
import sys.io.File;
import haxe.crypto.Base64;
import hvector.Float2;

final  ProtocolId = 0x11223344; //.make(,0x556677);
final ClientPort = 30001;
final ServerPort = 40000;

final MT_HEAPS = 0;

var initialized = false;
function initialize( maxMessageTypes : Int) {
    if (!initialized) {
        yojimbo.Native.Yojimbo.setMaxMessageTypes(maxMessageTypes);
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

class Float2Serializable implements hxbit.Serializable  {
    public function new (x, y) {
        this.x = x;
        this.y = y;
    }
    @:s public var x : Float;
    @:s public var y : Float;

    @:from
    static public function fromFloat2(v : Float2) {
      return new Float2Serializable(v.x, v.y);
    }
  
    @:to
    public function toFloat2() {
      return new Float2( x, y );
    }

}

function compressFloat( x : Float, o : Float, s : Float, bits : Int ) : Int {
    final MAX_INTF : Float = ((1 << bits) - 1);
    var a = (x - o) * (MAX_INTF / s );
    return Math.floor(a);
}
function decompressFloat( x : Int, o : Float, s : Float, bits : Int ) : Float {
    final MAX_INTF : Float = ((1 << bits) - 1);
    var a = x * (s / MAX_INTF) + o;
    return a;
}

class QuantizedVector2 implements hxbit.Serializable  {

    final MAX_INTF : Float;
    final MAX_INT : Int;
    
    public function new (x, y, ox, oy, sizex, sizey, bits) {
        if (bits > 16) bits = 16;
        
        this.bits = bits;
        MAX_INTF  = ((1 << bits) - 1);
        MAX_INT = ((1 << bits) - 1);
        this.x = x;
        this.y = y;

        originx = ox;
        originy = oy;

        downscalex = MAX_INTF / sizex;
        downscaley = MAX_INTF / sizey;
        upscalex =  sizex / MAX_INTF;
        upscaley =  sizey / MAX_INTF;
    }

    public function set( x, y ) {
        this.x = Math.floor((x - originx) * downscalex);
        this.y = Math.floor((y - originy) * downscaley);
        
       if (this.x < 0) this.x = 0;
       if (this.y < 0) this.y = 0;
       if (this.x > MAX_INT) this.x = MAX_INT;
       if (this.y > MAX_INT) this.y = MAX_INT;
    }

    var bits : Int;
     var x : Int;
     var y : Int;
     var originx : Float;
     var originy : Float;
     var downscalex : Float;
     var downscaley : Float;
     var upscalex : Float;
     var upscaley : Float;

    
    @:to
    public function toFloat2() {
        var xf = cast(x,Float) * upscalex + originx;
        var yf = cast(y,Float) * upscaley + originy;
        return new Float2( xf, yf );
    }

    @:keep
    public function customSerialize(ctx : hxbit.Serializer) {
        if (bits > 8) ctx.addByte((x >> 8) & 0xff );
        ctx.addByte(x & 0xff );
        if (bits > 8) ctx.addByte((y >> 8) & 0xff );
        ctx.addByte(y & 0xff );
    }

    @:keep
    public function customUnserialize(ctx : hxbit.Serializer) {
        var hbx = (bits > 8) ? ctx.getByte() : 0;
        var lbx = ctx.getByte();
        x = hbx << 8 | lbx;
        var hby = (bits > 8) ? ctx.getByte() : 0;
        var lby = ctx.getByte();
        y = hby << 8 | lby;
    }
}


class User implements hxbit.Serializable {
    @:s public var name : String;
    @:s public var age : Int;
    @:s public var friends : Array<User>;    
}

/*
	static function enableReplication( o : NetworkSerializable, b : Bool ) {
		if( b ) {
			if( o.__host != null ) return;
			if( current == null ) throw "No NetworkHost defined";
			current.register(o);
		} else {
			if( o.__host == null ) return;
			o.__host.unregister(o);
		}
	}
*/

class NetSerializable implements hxbit.NetworkSerializable 
{
    public function startReplication(h : Host) {
        __host = h;
        h.register(this);
    }
    public function stopReplication() {
        if (__host != null) {
            __host.unregister(this);
            __host = null;
        }
    }
}

class Cursor extends NetSerializable {

	@:s var color : Int;
	@:s public var uid : Int;
	@:s public var x(default, set) : Float;
	@:s public var y(default, set) : Float;

    // shared initialization
    public function init() {

    }

    // NetworkSerializable init
    public override function alive() {
        super.alive();
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

    public override function networkAllow( op : hxbit.NetworkSerializable.Operation, propId : Int, client : hxbit.NetworkSerializable ) : Bool {
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
