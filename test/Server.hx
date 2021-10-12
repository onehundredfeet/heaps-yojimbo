package test;

class Server {

    public static function main() {

        //
        // Hosts a secure server which requires a matcher to be running
        // Insecure server TBD
        //
        var server = new heaps.yojimbo.Server();

        var time = 0.;
        var dt = 0.1;

        server.onClientConnected = function (c) {
            trace("Client identified ("+c.IDX()+"," + c.ID() + ")");
            var p = new Player(0x0000FF, c.ID());
            c.ownerObject = p;
            c.sync();
        }

        server.start("127.0.0.1", heaps.yojimbo.Common.ServerPort);

        while(true) {
            server.incomingUpdate( time, dt );
            server.outgoingUpdate();
            Sys.sleep(dt);
            time += dt;
        }

        server.stop();
    }
}