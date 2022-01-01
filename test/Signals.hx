package test;

import h3d.mat.Pass;
import hvector.ShaderMath.abs;
import heaps.yojimbo.RemappedSignal;
import hxd.BitmapData.BitmapInnerData;
import h3d.mat.BigTexture;
import heaps.yojimbo.BitWriter;
import heaps.yojimbo.IntSignal;
import hxbit.Serializer;
import heaps.yojimbo.BitReader;

class Signals {

    public static function testSignals() {

        final DEPTH = 15;

        var x = new IntSignal( 12, 0, DEPTH, ESignalCompression.RLE(3));
        
        for (i in 0...DEPTH)
            x.push(i);

        var remapTests = [
            [for (i in 0...DEPTH) (i - 5) * 0.5],
            [for (i in 0...DEPTH) Math.cos(i * Math.PI / 100.) * 4.],
            [for (i in 0...DEPTH) -5.],
            [for (i in 0...DEPTH) 0.],
            [for (i in 0...DEPTH) Math.floor(i / 5) + 0.],
        ];

       

      
        final BITS = 10;

        var pass = 0;

        for (test in remapTests) {
            var rs = [
                new RemappedSignal( BITS, -5., 5, true, DEPTH, ESignalCompression.RAW),       // 150
                new RemappedSignal( BITS, -5., 5, true, DEPTH, ESignalCompression.UNIQUE),    // 165
                new RemappedSignal( BITS, -5., 5, true, DEPTH, ESignalCompression.DELTA(5)),  // 124
                new RemappedSignal( BITS, -5., 5, true, DEPTH, ESignalCompression.RLE(4))     // 165
            ];

            var bitCounts = [];
            var a = new BitWriter();

            for (r in rs) {
                for (x in test) {
                    r.pushRemapped(x);
                }
            }

            x.write(a, DEPTH);
            var bitCount = a.bitLength();
    
            for (r in rs) {
                r.write(a, DEPTH);
                bitCounts.push( a.bitLength() - bitCount);
                bitCount = a.bitLength();
            }
    
            a.addInt(32, 8);
            a.addInt(32, 10);
            a.addInt(32, 16);
            a.addInt(32, 6);
            a.addInt(32, 21);
            a.addInt(32, 32);       
    
            trace("done adding");
    
            var b = new BitReader( a.getBytes());
    
            x.read(b, DEPTH);
            for (r in rs) {
                r.read(b, DEPTH);
            }
    
            for(i in 0...DEPTH) {
                if (x.history(i) != (DEPTH - 1) - i)
                    throw '${i} should be ${ (DEPTH - 1) - i} is ${x.history(i)}';
            }
            var ci = 0;
            for (r in rs) {
                for(i in 0...DEPTH) {
                    var ri = (DEPTH - 1) - i;
                    var a = r.simulate(test[i]);
                    if (a != r.remapHistory(ri)) {
                        throw 'setting ${ci} history ${i} should be ${a} is ${r.remapHistory(ri)}';
                    }
                }
                ci++;
            }
            var i = 0;
            for (bd in bitCounts) {
                trace('${i} bits used: ${bd} bytes: ${bd/8.} vsfloats: ${((bd/8.) / (4 * DEPTH)) * 100.}% vsraw ${(bd / bitCounts[0]) * 100.}%');
                i++;
            }
    
            if (b.getInt(8) != 32) {
                throw "error";
            }
            if (b.getInt(10) != 32) {
                throw "error";
            }
            if (b.getInt(16) != 32) {
                throw "error";
            }
            if (b.getInt(6) != 32) {
                throw "error";
            }
            if (b.getInt(21) != 32) { 
                throw "error";
            }
            if (b.getInt(32) != 32) {
                throw "error";
            }
    
            trace('Pass ${pass} success');
            pass ++;
        }



       

   
       
        trace("done");

        
    }
    public static function main() {
        trace("Start");


        testSignals();

        trace("Done");
    }
}