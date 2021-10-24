package heaps.yojimbo;

class LoopbackClient extends ClientBase {
	public function new( c : yojimbo.Native.Client ) {
		super();
		_client = c;
	}
}
