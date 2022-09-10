package test;

class Server {

    public static function main() {
        yojimbo.Native.Yojimbo.logLevel(yojimbo.Native.LogLevel.YOJIMBO_LOG_LEVEL_INFO);
		heaps.yojimbo.Common.initialize(5);

        //
        // Hosts a secure server which requires a matcher to be running
        // Insecure server TBD
        //
        var server = new heaps.yojimbo.Server();

        var time = 0.;
        var dt = 0.1;

        server.onClientConnected = function (c) {
            trace("Client identified ("+c.IDX()+"," + c.ID() + ")");
            var p = new Player(0x0000FF, c.ID(), Std.random(100),Std.random(100));
            c.ownerObject = p;
            c.sync();
        }

        server.start("127.0.0.1", heaps.yojimbo.Common.ServerPort, time);
        
        while(true) {
            server.incomingUpdate( time, dt );
            server.outgoingUpdate();
            Sys.sleep(dt);
            time += dt;
        }

        server.stop();
    }
}