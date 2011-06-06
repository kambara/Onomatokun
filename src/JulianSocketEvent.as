package
{
	import flash.events.Event;

	public class JulianSocketEvent extends Event
	{
		public static var WORD:String = "word";
		public static var WORD_WITH_CONFIDENCE:String = "word_with_confidence";
		
		private var _word:String;
		private var _confidence:Number;
		
		public function JulianSocketEvent(type:String, word:String, confidence:Number=NaN, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			_word = word;
			_confidence = confidence;
		}
		
		public function get word():String {
			return this._word;
		}
		
		public function get confidence():Number {
			return this._confidence;
		}
	}
}