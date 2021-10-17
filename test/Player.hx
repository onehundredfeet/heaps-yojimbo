package test;

import heaps.yojimbo.Common.compressFloat;
import heaps.yojimbo.Common.decompressFloat;
import haxe.EnumTools;


class Player implements hxbit.NetworkSerializable {
    @:s var color : Int;
	@:s public var uid : Int;
    @:s var name : String;
    @:s var x : Float;
    @:s var y : Float;
    @:s var angle : Float;

    public function networkAllow( op : hxbit.NetworkSerializable.Operation, propId : Int, owner : hxbit.NetworkSerializable ) : Bool {
        //trace ('Is allowed? ${op}');
		return owner == this;
	}
    
    // source initialization
    public function new ( c, id, x, y ) {
        enableReplication = true;
        color = c;
        uid = id;
        this.x = x;
        this.y = y;

        init();
    }

    // shared initialization
    public function init() {

    }

    // NetworkSerializable init
    public function alive() {
		init();
        Client.onPlayer(this);
	}

    static final DOMAIN = 10000.;
    static final ORIGIN =  - DOMAIN / 2.;
    static final BITS = 25;

    static final ADOMAIN = Math.PI * 2.;
    static final ABITS = 14;


    public function moveF( x : Float, y : Float, a : Float) {
        move( compressFloat(x, ORIGIN, DOMAIN, BITS),compressFloat(y, ORIGIN, DOMAIN, BITS), compressFloat(AngleF.bound(a), 0., ADOMAIN, ABITS) );
    }

    @:rpc(immediate) public function move( x : Int, y : Int, a : Int) {
        var xf = decompressFloat(x, ORIGIN, DOMAIN, BITS);
        var yf = decompressFloat(y, ORIGIN, DOMAIN, BITS);
        var af = decompressFloat(a, 0., ADOMAIN, ABITS);
        
        trace('Moving... xi ${x} xf ${xf} yi ${y} yf ${yf} a ${a} af ${af}');
        this.x = xf;
        this.y = yf;
        this.angle = af;
     }
}
