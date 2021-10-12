package test;

class Player implements hxbit.NetworkSerializable {
    @:s var color : Int;
	@:s public var uid : Int;
    @:s var name : String;

    public function networkAllow( op : hxbit.NetworkSerializable.Operation, propId : Int, client : hxbit.NetworkSerializable ) : Bool {
		return client == this;
	}
    
    // source initialization
    public function new ( c, id ) {
        enableReplication = true;
        color = c;
        uid = id;
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
}
