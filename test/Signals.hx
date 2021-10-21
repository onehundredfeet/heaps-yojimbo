package test;

import hxd.BitmapData.BitmapInnerData;
import h3d.mat.BigTexture;
import heaps.yojimbo.BitWriter;
import heaps.yojimbo.IntSignal;
import hxbit.Serializer;
import heaps.yojimbo.BitReader;

class Signals {

    public static function main() {
        trace("Start");
        final DEPTH = 15;

        var a = new BitWriter();
        var x = new IntSignal( 12, 0, 15, ESignalCompression.RLE);

        x.write(a);

        a.addInt(32, 8);
        a.addInt(32, 10);
        a.addInt(32, 16);
        a.addInt(32, 6);
        a.addInt(32, 21);
        a.addInt(32, 32);
        
       

        trace("done adding");

        var b = a.getBytes();


        var b = new BitReader(b);

        x.read(b);
        
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
}