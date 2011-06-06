/*
 * BetweenAS3
 * 
 * Licensed under the MIT License
 * 
 * Copyright (c) 2009 BeInteractive! (www.be-interactive.org) and
 *                    Spark project  (www.libspark.org)
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 * 
 */
package org.libspark.betweenas3.tickers
{
	import flash.display.Shape;
	import flash.events.Event;
	import flash.utils.getTimer;
	import org.libspark.betweenas3.core.ticker.ITicker;
	import org.libspark.betweenas3.core.ticker.TickerListener;
	
	/**
	 * 毎フレームコールバックを行う ITicker の実装です.
	 * 
	 * @author	yossy:beinteractive
	 */
	public class EnterFrameTicker implements ITicker
	{
		private static var _shape:Shape = new Shape();
		
		public function EnterFrameTicker()
		{
			_tickerListenerPaddings = new Vector.<TickerListener>(10, true);
			
			var prevListener:TickerListener = null;
			
			for (var i:uint = 0; i < 10; ++i) {
				var listener:TickerListener = new TickerListener();
				if (prevListener != null) {
					prevListener.nextListener = listener;
					listener.prevListener = prevListener;
				}
				prevListener = listener;
				_tickerListenerPaddings[i] = listener;
			}
		}
		
		private var _first:TickerListener = null;
		private var _last:TickerListener = null;
		private var _numListeners:uint = 0;
		private var _tickerListenerPaddings:Vector.<TickerListener>;
		private var _time:Number;
		
		/**
		 * @inheritDoc
		 */
		public function get time():Number
		{
			return _time;
		}
		
		/**
		 * @inheritDoc
		 */
		public function addTickerListener(listener:TickerListener):void
		{
			if (listener.nextListener != null || listener.prevListener != null) {
				return;
			}
			
			if (_last != null) {
				if (_last.nextListener != null) {
					_last.nextListener.prevListener = listener;
					listener.nextListener = _last.nextListener;
				}
				listener.prevListener = _last;
				_last.nextListener = listener;
			}
			
			_last = listener;
			
			if (_first == null) {
				_first = listener;
			}
			
			++_numListeners;
		}
		
		/**
		 * @inheritDoc
		 */
		public function removeTickerListener(listener:TickerListener):void
		{
			var l:TickerListener = _first;
			
			while (l != null) {
				
				if (l == listener) {
					if (l.prevListener != null) {
						l.prevListener.nextListener = l.nextListener;
						l.nextListener = null;
					}
					else {
						_first = l.nextListener;
					}
					if (l.nextListener != null) {
						l.nextListener.prevListener = l.prevListener;
						l.prevListener = null;
					}
					else {
						_last = l.prevListener;
					}
					--_numListeners;
				}
				
				l = l.nextListener;
			}
		}
		
		/**
		 * @inheritDoc
		 */
		public function start():void
		{
			_time = getTimer() / 1000;
			_shape.addEventListener(Event.ENTER_FRAME, update);
		}
		
		/**
		 * @inheritDoc
		 */
		public function stop():void
		{
			_shape.removeEventListener(Event.ENTER_FRAME, update);
		}
		
		// internal なのはテストのため
		
		/**
		 * @private
		 */
		internal function update(e:Event):void
		{
			// リスナの数を 8 の倍数になるようにパディングして 8 個ずつ一気にループさせる
			
			var t:Number = _time = getTimer() / 1000, i:int = (_numListeners / 8 + 1) | 0, n:uint = i * 8 - _numListeners, listener:TickerListener = _tickerListenerPaddings[0], l:TickerListener = _tickerListenerPaddings[n], ll:TickerListener = null;
			
			// このようにつなぎかえることでパディングの数を変える
			if ((l.nextListener = _first) != null) {
				_first.prevListener = l;
			}
			
			while (--i >= 0) {
				if ((listener = listener.nextListener).tick(t)) {
					if (listener.prevListener != null) {
						listener.prevListener.nextListener = listener.nextListener;
					}
					if (listener.nextListener != null) {
						listener.nextListener.prevListener = listener.prevListener;
					}
					if (listener == _first) {
						_first = listener.nextListener;
					}
					if (listener == _last) {
						_last = listener.prevListener;
					}
					ll = listener.prevListener;
					listener.nextListener = null;
					listener.prevListener = null;
					listener = ll;
					--_numListeners;
				}
				if ((listener = listener.nextListener).tick(t)) {
					if (listener.prevListener != null) {
						listener.prevListener.nextListener = listener.nextListener;
					}
					if (listener.nextListener != null) {
						listener.nextListener.prevListener = listener.prevListener;
					}
					if (listener == _first) {
						_first = listener.nextListener;
					}
					if (listener == _last) {
						_last = listener.prevListener;
					}
					ll = listener.prevListener;
					listener.nextListener = null;
					listener.prevListener = null;
					listener = ll;
					--_numListeners;
				}
				if ((listener = listener.nextListener).tick(t)) {
					if (listener.prevListener != null) {
						listener.prevListener.nextListener = listener.nextListener;
					}
					if (listener.nextListener != null) {
						listener.nextListener.prevListener = listener.prevListener;
					}
					if (listener == _first) {
						_first = listener.nextListener;
					}
					if (listener == _last) {
						_last = listener.prevListener;
					}
					ll = listener.prevListener;
					listener.nextListener = null;
					listener.prevListener = null;
					listener = ll;
					--_numListeners;
				}
				if ((listener = listener.nextListener).tick(t)) {
					if (listener.prevListener != null) {
						listener.prevListener.nextListener = listener.nextListener;
					}
					if (listener.nextListener != null) {
						listener.nextListener.prevListener = listener.prevListener;
					}
					if (listener == _first) {
						_first = listener.nextListener;
					}
					if (listener == _last) {
						_last = listener.prevListener;
					}
					ll = listener.prevListener;
					listener.nextListener = null;
					listener.prevListener = null;
					listener = ll;
					--_numListeners;
				}
				if ((listener = listener.nextListener).tick(t)) {
					if (listener.prevListener != null) {
						listener.prevListener.nextListener = listener.nextListener;
					}
					if (listener.nextListener != null) {
						listener.nextListener.prevListener = listener.prevListener;
					}
					if (listener == _first) {
						_first = listener.nextListener;
					}
					if (listener == _last) {
						_last = listener.prevListener;
					}
					ll = listener.prevListener;
					listener.nextListener = null;
					listener.prevListener = null;
					listener = ll;
					--_numListeners;
				}
				if ((listener = listener.nextListener).tick(t)) {
					if (listener.prevListener != null) {
						listener.prevListener.nextListener = listener.nextListener;
					}
					if (listener.nextListener != null) {
						listener.nextListener.prevListener = listener.prevListener;
					}
					if (listener == _first) {
						_first = listener.nextListener;
					}
					if (listener == _last) {
						_last = listener.prevListener;
					}
					ll = listener.prevListener;
					listener.nextListener = null;
					listener.prevListener = null;
					listener = ll;
					--_numListeners;
				}
				if ((listener = listener.nextListener).tick(t)) {
					if (listener.prevListener != null) {
						listener.prevListener.nextListener = listener.nextListener;
					}
					if (listener.nextListener != null) {
						listener.nextListener.prevListener = listener.prevListener;
					}
					if (listener == _first) {
						_first = listener.nextListener;
					}
					if (listener == _last) {
						_last = listener.prevListener;
					}
					ll = listener.prevListener;
					listener.nextListener = null;
					listener.prevListener = null;
					listener = ll;
					--_numListeners;
				}
				if ((listener = listener.nextListener).tick(t)) {
					if (listener.prevListener != null) {
						listener.prevListener.nextListener = listener.nextListener;
					}
					if (listener.nextListener != null) {
						listener.nextListener.prevListener = listener.prevListener;
					}
					if (listener == _first) {
						_first = listener.nextListener;
					}
					if (listener == _last) {
						_last = listener.prevListener;
					}
					ll = listener.prevListener;
					listener.nextListener = null;
					listener.prevListener = null;
					listener = ll;
					--_numListeners;
				}
			}
			
			// 元に戻す
			if ((_first = l.nextListener) != null) {
				_first.prevListener = null;
			}
			else {
				_last = null;
			}
			l.nextListener = _tickerListenerPaddings[n + 1];
		}
	}
}