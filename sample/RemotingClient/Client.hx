// original client/server code from http://haxe.org/doc/flash/chat

class ServerApiImpl extends haxe.remoting.AsyncProxy<ServerApi> {
}

class Client implements ClientApi {

	var api : ServerApiImpl;
	var name : String;
	var tf : flash.text.TextField;
	var log : flash.text.TextField;

	function new() {
		var s = new flash.net.XMLSocket();
		s.addEventListener(flash.events.Event.CONNECT, onConnect);
		s.connect("localhost",1024);
		var context = new haxe.remoting.Context();
		context.addObject("client",this);
		var scnx = haxe.remoting.SocketConnection.create(s,context);
		api = new ServerApiImpl(scnx.api);
	}

	function onConnect(event:flash.events.Event):Void{
		// create an input textfield
		tf = new flash.text.TextField();
		tf.x = 5;
		tf.y = flash.Lib.current.stage.stageHeight-25;
		tf.width = flash.Lib.current.stage.stageWidth-10;
		tf.height = 20;
		tf.type = flash.text.TextFieldType.INPUT;
		tf.border = true;
		tf.background = true;
		tf.backgroundColor = 0xEEEEEE;
		flash.Lib.current.addChild(tf);
		flash.Lib.current.stage.addEventListener(flash.events.KeyboardEvent.KEY_DOWN, onKeyDown);
		
		log = new flash.text.TextField();
		log.x = 5;
		log.y = 5;
		log.width = flash.Lib.current.stage.stageWidth-10;
		log.height = flash.Lib.current.stage.stageHeight-35;
		log.background = true;
		log.backgroundColor = 0xFFFFFF;
		log.border = true;
		log.multiline = true;
		flash.Lib.current.addChild(log);
		display("Please enter your name in the bottom textfield to login and press ENTER");
	}

	function onKeyDown(event:flash.events.KeyboardEvent):Void {
		// ENTER pressed ?
		if( event.keyCode == 13 ) {
			var text = tf.text;
			tf.text = "";
			send(text);
		}
	}

	function send( text : String ) {
		if( name == null ) {
			name = text;
			api.identify(name);
			return;
		}
		api.say(text);
	}

	public function userJoin( name ) {
		display("User join <b>"+name+"</b>");
	}

	public function userLeave( name ) {
		display("User leave <b>"+name+"</b>");
	}

	public function userSay( name : String, text : String ) {
		display("<b>"+name+ " :</b> "+text.split("&").join("&amp;").split("<").join("&lt;").split(">").join("&gt;"));
	}

	function display( line : String ) {
		var bottom = (log.scrollV == log.maxScrollV);
		log.htmlText += line + "<br>";
		if( bottom )
			log.scrollV = log.maxScrollV;
	}

	// --

	static var c : Client;

	static function main() {
		c = new Client();
	}

}
