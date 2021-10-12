package test;

import heaps.yojimbo.Common.loadCertificate;
import hxd.Rand;

class Client {

    static var _player : Player;
    static var _client : heaps.yojimbo.Client;

    public static function onPlayer(p : Player) {
        if (_player == null) {
          if (p.uid == _client.id()) {
            _client.connection().ownerObject = p;
            _player = p;
          }
        }
    }
    public static function main() {

        //
        // Hosts a secure server which requires a matcher to be running
        // Insecure server TBD
        //
        _client = new heaps.yojimbo.Client(Std.random(10000));

        var time = 0.;
        var dt = 0.1;
        
        var cert = loadCertificate("server.pem");

        if (!_client.getMatchtoken( "127.0.0.1", 443, cert)) {
          throw("Could not get match token");
        }
        if (!_client.connect(time)) {
          throw("Could not get initiate conenction");
        };


        while(true) {
          _client.incomingUpdate( time, dt );
          _client.outgoingUpdate();
            Sys.sleep(dt);
            time += dt;
        }

        _client.close();

      //  server.stop();
    }
}