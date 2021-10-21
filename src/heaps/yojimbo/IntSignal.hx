package heaps.yojimbo;

enum ESignalCompression {
	BIT;
	UNIQUE;
	RLE;
}

interface SerializableSignal {

}
class IntSignal implements SerializableSignal {
	var _bits = 31;
	var _min = 0;
	var _history:Array<Int>;
	var _loc = 0;
	var _mask:UInt = 0;
	var _compression:ESignalCompression;

	public function new(bits, min, historyDepth:Int, compression:ESignalCompression, def:Int = 0) {
		_bits = bits;
		_min = min;
		_history = [for (c in 0...historyDepth) def];
		final MASK:UInt = 0xffffffff;
		_mask = MASK >> (32 - _bits);
		_compression = compression;
	}

	public function push(v:Int) {
		v = (v - _min) & _mask;
		_history[_loc] = v;
		_loc = (_loc + 1) % _history.length;
	}

	static final DELTA_BITS = 3;

	public function write(ctx:BitWriter) {

		switch (_compression) {
			case ESignalCompression.BIT:
				for (i in 0..._history.length) {
					var idx = (_loc + i) % _history.length;
					ctx.addInt(_history[idx], _bits);
				}
			case ESignalCompression.UNIQUE:
				var x = 0;
				for (i in 0..._history.length) {
					var idx = (_loc + i) % _history.length;
					if (_history[idx] != x) {
						ctx.addBool(true);
						x = _history[idx];
						ctx.addInt(x, _bits);
					} else {
						ctx.addBool(false);
					}
				}
            case ESignalCompression.RLE:
                var x = 0;
                var i = 0;
				while (i < _history.length) {
					var idx = (_loc + i) % _history.length;
                    x = _history[idx];
                    ctx.addInt(x, _bits);

                    var headCount = i + 1;
                    while (headCount < _history.length) {
                        var headIdx = (_loc + headCount) % _history.length;
                        if (_history[headIdx] != x)
                            break;
						headCount++;
                    }
					var delta = headCount - i;
					if (delta == 0) {
						ctx.addBits(0,1 );
						i++;
					} else {
						ctx.addBits(1,1 );
						if (delta > 7) {
							delta = 7;
						}
						ctx.addBits(delta, DELTA_BITS );
						i += delta + 1;
					}
				}
			default:
		}
	}

	public function read(ctx:BitReader) {
		_loc = 0;

		switch (_compression) {
			case ESignalCompression.BIT:
                for (i in 0..._history.length) {
					_history[i] = ctx.getInt(_bits);
				}
			case ESignalCompression.UNIQUE:
				var x = 0;
				for (i in 0..._history.length) {
					if (ctx.getBool()) {
						x = ctx.getInt(_bits);
					}
					_history[i] = x;
					
				}
			case RLE:
				var x = 0;
                var i = 0;
				while (i < _history.length) {
					x = ctx.getInt(_bits);
					_history[i] = x;

					if (ctx.getBool()) {
						//run
						var delta = ctx.getInt(DELTA_BITS);
						for (j in 0...(delta + 1)) {
							_history[i++] = x;
						}
					} else {
						// different value
						i++;
					}

				}
                default:
			
		}
	}
}
