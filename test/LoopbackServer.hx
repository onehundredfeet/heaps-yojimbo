package test;

class LoopbackServer {

    public static function main() {

        //
        // Hosts a secure server which requires a matcher to be running
        // Insecure server TBD
        //
        var server = new heaps.yojimbo.Server();

        var time = 0.;
        var dt = 0.1;

        var splayer : Player;
        var cplayer : Player;

        server.onClientConnected = function (c) {
            trace("Client identified ("+c.IDX()+"," + c.ID() + ")");
            splayer = new Player(0x0000FF, c.ID(), Std.random(100),Std.random(100));
            splayer.startReplication( server );
            c.ownerObject = splayer;
            c.sync();
        }

        Player.onPlayer = function(p) {
            trace("Created client side player");
            cplayer = p;
        }
        
        server.start("127.0.0.1", heaps.yojimbo.Common.ServerPort, time);
        var client = server.startLoopback(0, time);
        
        while(true) {
            client.incomingUpdate( time, dt);
            client.outgoingUpdate();
            server.incomingUpdate( time, dt );
            server.outgoingUpdate();
            Sys.sleep(dt);
            time += dt;
        }

        server.stop();
    }
}