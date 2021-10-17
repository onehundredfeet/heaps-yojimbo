package test;

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

    @:rpc(immediate) public function move( x : Float, y : Float) {
        trace("Moving...");
        this.x = x;
        this.y = y;
     }
}
