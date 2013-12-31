// original client/server code from http://haxe.org/doc/flash/chat

package ;

import potio.remoting.SocketConnection;
import potio.net.ThreadRemotingServer;


// define a typed remoting API
class ClientApiImpl extends haxe.remoting.AsyncProxy<ClientApi> {
}


// our client class
class ClientData implements ServerApi {

	var api : ClientApiImpl;
	var name : String;

	public function new( scnx : SocketConnection ) {
		api = new ClientApiImpl(scnx.client);
		(cast scnx).__private = this;
	}

	public function identify( name : String ) {
		if( this.name != null )
			throw "You are already identified";
		this.name = name;
		Server.clients.add(this);
		for( c in Server.clients ) {
			if( c != this )
				c.api.userJoin(name);
			api.userJoin(c.name);
		}
	}

	public function say( text : String ) {
		for( c in Server.clients )
			c.api.userSay(name,text);
	}

	public function leave() {
		if( Server.clients.remove(this) )
			for( c in Server.clients )
				c.api.userLeave(name);
	}

	public static function ofConnection( scnx : SocketConnection ) : ClientData {
		return (cast scnx).__private;
	}

}

/**
 * ...
 * @author icedac
 */

class Server 
{
	public static var clients = new List<ClientData>();

	public static function initClientApi( scnx : SocketConnection, context : haxe.remoting.Context ) {
		trace("Client connected");
		var c = new ClientData(scnx);
		context.addObject("api",c);
	}

	public static function onClientDisconnected( scnx ) {
		trace("Client disconnected");
		ClientData.ofConnection(scnx).leave();
	}
}

class Main
{
	static function main() {
		var host = "localhost";
		var domains = [host];
		var s = new ThreadRemotingServer(domains);
		s.initClientApi = Server.initClientApi;
		s.clientDisconnected = Server.onClientDisconnected;
		trace("Starting server...");
		s.run(host, 1024);
	}
}

