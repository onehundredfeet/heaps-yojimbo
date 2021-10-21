package test;

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

        var x = new IntSignal( 12, 0, DEPTH, ESignalCompression.RLE);

        for (i in 0...DEPTH)
            x.push(i);

        var r = new RemappedSignal( 10, -10., 13, DEPTH, ESignalCompression.RLE);

        for (i in 0...DEPTH) {
            var a = (i - 5) * 0.5;
            var b = r.pushRemapped(a);
            trace('${i}: ${a} -> ${b}');
        }

        var a = new BitWriter();
   
        x.write(a);
        r.write(a);

        a.addInt(32, 8);
        a.addInt(32, 10);
        a.addInt(32, 16);
        a.addInt(32, 6);
        a.addInt(32, 21);
        a.addInt(32, 32);       

        trace("done adding");

        var b = new BitReader( a.getBytes());

        x.read(b);
        r.read(b);

        for(i in 0...15) {
            if (x.history(i) != 14 - i)
                throw "Error";
        }
        for(i in 0...15) {
            trace('${i}: ${r.remapHistory(i)}');
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

        trace("done");

        
    }
    public static function main() {
        trace("Start");


        testSignals();

        trace("Done");
        Sys.exit(0);
    }
}