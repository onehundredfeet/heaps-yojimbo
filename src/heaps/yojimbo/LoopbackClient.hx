package heaps.yojimbo;

class LoopbackClient extends ClientBase {
	public function new( c : yojimbo.Native.Client, protocolID : Int ) {
		super(false, protocolID);
		_client = c;
	}
}
