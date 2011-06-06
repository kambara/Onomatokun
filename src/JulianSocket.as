package
{
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.net.Socket;
	import flash.utils.setTimeout;
	
	public class JulianSocket extends Socket
	{
		private var host:String;
		private var port:uint;
		private var challengeCount:uint = 100;
		private var whypoTag:String = null;
		
		public function JulianSocket(host:String = "localhost", port:uint = 10500)
		{
			super();
			this.host = host;
			this.port = port;
			configure();
			reconnect();
		}
		
		private function reconnect():void {
			if (challengeCount <= 0) {
				dispatchEvent(new Event("stop_challenge"));
				return;
			}
			challengeCount--;
			dispatchEvent(new Event("connecting"));
			connect(host, port);
		}
		
		private function configure():void {
			addEventListener(Event.CONNECT, function(event:Event):void {
				trace(event.type);
				challengeCount = 10;
			});
			addEventListener(Event.CLOSE, function(event:Event):void {
				trace(event.type);
				waitAndTryConnecting();
			});
			addEventListener(IOErrorEvent.IO_ERROR, function(event:Event):void {
				trace(event.type);
				waitAndTryConnecting();
			});
			addEventListener(ProgressEvent.SOCKET_DATA, onSocketData);
		}
		
		private function waitAndTryConnecting():void {
			setTimeout(reconnect, 3000);
		}
		
		private function onSocketData(event:ProgressEvent):void {
			var data:String = Socket(event.target).readUTFBytes(event.bytesLoaded);
			//trace("----\n" + data);
			
			// <WHYPO /> タグを抽出
			var lines:Array = data.split("\n");
			var closeIndex:int;
			for each (var line:String in lines) {
				if (whypoTag) {
					// まだ閉じていないwhypoタグがある場合
					closeIndex = line.lastIndexOf("/>");
					if (closeIndex >= 0) {
						parseWhypoTag(whypoTag + line.slice(0, closeIndex)); // 閉じタグ除去
						whypoTag = null;
					} else {
						whypoTag += line;
					}
				} else {
					var openIndex:int = line.indexOf("<WHYPO");
					if (openIndex >= 0) {
						closeIndex = line.lastIndexOf("/>");
						if (closeIndex >= 0) {
							// 1行で閉じていたら即パース
							parseWhypoTag( line.slice(openIndex+1, closeIndex) );
							whypoTag = null;
						} else {
							whypoTag = line.slice(openIndex+1);
						}
					}
				}
			}
		}
		
		private function parseWhypoTag(tag:String):void {
			var attrs:Object = {};
			for each (var str:String in tag.split(" ")) {
				if (str) {
					var pair:Array = str.split("=");
					if (pair.length == 2 && String(pair[1]).length >= 3) {
						attrs[pair[0]] = String(pair[1]).slice(1, -1); // ダブルクオート除去
					}
				}
			}
			
			if (attrs["WORD"]) {
				var word:String = attrs["WORD"];
				/*
				if (word == "silB" || word == "silE") {
					return;
				}
				if (word == "noise") {
					return;
				}
				*/
				
				if (attrs["CM"]) {
					var cm:Number = parseFloat(attrs["CM"]);
					//trace("<<< " + word + " >>> " + cm.toString());
					dispatchEvent(new JulianSocketEvent(JulianSocketEvent.WORD_WITH_CONFIDENCE, word, cm));
				} else {
					//trace("<<< " + word + " >>>");
					dispatchEvent(new JulianSocketEvent(JulianSocketEvent.WORD, word));
				}
			}
		}
	}
}