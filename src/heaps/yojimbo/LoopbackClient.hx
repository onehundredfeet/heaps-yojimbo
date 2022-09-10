package heaps.yojimbo;

class LoopbackClient extends ClientBase {
	public function new( c : yojimbo.Native.Client ) {
		super(false);
		_client = c;
	}
}
