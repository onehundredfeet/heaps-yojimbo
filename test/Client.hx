package test;

import heaps.yojimbo.Common.loadCertificate;
import hxd.Rand;

class Client {

    public static function main() {

        //
        // Hosts a secure server which requires a matcher to be running
        // Insecure server TBD
        //
        var client = new heaps.yojimbo.Client(Std.random(10000));

        var time = 0.;
        var dt = 0.1;
        
        var cert = loadCertificate("server.pem");

        if (!client.getMatchtoken( "127.0.0.1", 443, cert)) {
          throw("Could not get match token");
        }
        if (!client.connect(time)) {
          throw("Could not get initiate conenction");
        };


        while(true) {
            client.incomingUpdate( time, dt );
            client.outgoingUpdate();
            Sys.sleep(dt);
            time += dt;
        }

        client.close();

      //  server.stop();
    }
}