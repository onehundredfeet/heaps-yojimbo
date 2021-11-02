package heaps.yojimbo;

enum ESignalCompression {
	BIT;
	UNIQUE;
	RLE;
}

interface SerializableSignal {
	 function write(ctx:BitWriter) : Void;
	 function read(ctx:BitReader) : Void;
}

class IntSignal implements SerializableSignal {
	var _bits = 31;
	var _offset = 0;
	var _history:Array<Int>;
	var _loc = -1;
	var _mask:UInt = 0;
	var _compression:ESignalCompression;
	var _runBits = 3;

	public function new(bits, min, historyDepth:Int, compression:ESignalCompression, def:Int = 0, runBits:Int = 3) {
		_bits = bits;
		_offset = min;
		_history = [for (c in 0...historyDepth) def];
		final MASK:UInt = 0xffffffff;
		_mask = MASK >> (32 - _bits);
		_compression = compression;
		_runBits = runBits;
	}

	public function push(v:Int) : Int {
		v = (v - _offset) & _mask;
		_loc = (_loc + 1) % _history.length;
		_history[_loc] = v;

		return v + _offset;
	}
	public function history(delta : Int) {
		var i = (_loc - delta + _history.length) % _history.length;
		return _history[i] + _offset;
	}

	function relativeIndex(i : Int) {
		return (_loc - i + _history.length) % _history.length;
	}
	public function write(ctx:BitWriter, depth : Int) {

		switch (_compression) {
			case ESignalCompression.BIT:
				for (i in 0...depth) {
					var idx = relativeIndex(i);
					ctx.addInt(_history[idx], _bits);
				}
			case ESignalCompression.UNIQUE:
				var x = 0;
				for (i in 0...depth) {
					var idx = relativeIndex(i);
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
				while (i < depth) {
					var idx = relativeIndex(i);
                    x = _history[idx];
                    ctx.addInt(x, _bits);

                    var headCount = i + 1;
                    while (headCount < depth) {
                        var headIdx = relativeIndex(headCount); 
                        if (_history[headIdx] != x)
                            break;
						headCount++;
                    }
					var delta = headCount - i;
					if (delta == 1) {
						ctx.addBool(false);
						i++;
					} else {
						ctx.addBool(true);
						delta -= 2;
						if (delta > 7) {
							delta = 7;
						}
						ctx.addInt(delta, _runBits );
						i += delta + 2;
					}
				}
			default:
		}
	}

	public function read(ctx:BitReader, depth : Int) {
		_loc = 0;

		switch (_compression) {
			case ESignalCompression.BIT:
                for (i in 0...depth) {
					_history[relativeIndex(i)] = ctx.getInt(_bits);
				}
			case ESignalCompression.UNIQUE:
				var x = 0;
				for (i in 0...depth) {
					if (ctx.getBool()) {
						x = ctx.getInt(_bits);
					}
					_history[relativeIndex(i)] = x;
					
				}
			case RLE:
				var x = 0;
                var i = 0;
				while (i < depth) {
					x = ctx.getInt(_bits);
					if (ctx.getBool()) {
						//run
						var delta = ctx.getInt(_runBits) + 2;
						for (j in 0...delta) {
							_history[relativeIndex(i)] = x;
							i++;
						}
					} else {
						// different value
						_history[relativeIndex(i)] = x;
						i++;
					}

				}
                default:
			
		}
	}
}
