package heaps.yojimbo;

using heaps.yojimbo.IntSignal;

class RemappedSignal extends IntSignal {
	var _min = 0.;
	var _max = 1.;
	var _range = 1.;
	var _rangeScaled = 1.;
	var _inverse = 1.;
	var _inverseScaled = 1.;
	public function new(bits, min : Float, max : Float, historyDepth:Int, compression:ESignalCompression, def:Int = 0, runBits:Int = 3) {
		super(bits, 0, historyDepth, compression, def, runBits);
		_min = min;
		_max = max;
		_range = _max - _min;
		_inverse = 1. / _range;
		_inverseScaled =  (1 << bits - 1) / _range;
		_rangeScaled = _range / (1 << bits - 1);

	}

	public function pushRemapped( x : Float ) : Float{
		var c = Math.min( _max, Math.max( _min, x ));
		var y = Math.round((c - _min) * _inverseScaled);
		var q : Float = push( y );

		return (q * _rangeScaled) + _min;
	}

	public function remapHistory( d : Int ) {
		var x = history(d);
		return (x * _rangeScaled) + _min;
	}
}
