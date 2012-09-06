/*
Copyright (c) 2008 Tink Ltd - http://www.tink.ws

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
documentation files (the "Software"), to deal in the Software without restriction, including without limitation 
the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and
to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions
of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO 
THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, 
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

package org.efflex.viewStackEffects.effectClasses
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import mx.core.UIComponent;
	
	import org.efflex.viewStackEffects.Squash;
	
	public class SquashInstance extends ViewStackInstance
	{
		
		public var direction 				: String;
		
		private var _bitmapFrom				: Bitmap;
		private var _bitmapTo				: Bitmap;
		
		public function SquashInstance( target:UIComponent )
		{
			super( target );
		}
		
		override public function play():void
        {
			var to:Number;
			var from:Number;
			switch( state )
			{
				case SHOWING :
				case SHOWING_AFTER_INTERRUPT :
				{
					_bitmapFrom = new Bitmap();
					_bitmapFrom.bitmapData = ( state == SHOWING ) ? BitmapData( bitmapDatum[ selectedIndexFrom ] ) : interruptedBitmapData;
					_bitmapFrom.x = contentX;
					_bitmapFrom.y = contentY;
					display.addChild( _bitmapFrom );
					
					_bitmapTo = new Bitmap();
					_bitmapTo.bitmapData = BitmapData( bitmapDatum[ selectedIndexTo ] );
					_bitmapTo.x = contentX;
					_bitmapTo.y = contentY;
					display.addChild( _bitmapTo );
					
					switch( direction )
					{
						case Squash.DOWN :
						{
							to = contentY;
							from = _bitmapTo.y = contentY - contentHeight;
							break;
						}
						case Squash.UP :
						{
							to = contentY;
							from = _bitmapTo.y = contentY + contentHeight;
							break;
						}
						case Squash.LEFT :
						{
							to = contentX;
							from = _bitmapTo.x = contentX + contentWidth;
							break;
						}
						case Squash.RIGHT :
						{
							to = contentX;
							from = _bitmapTo.x = contentX - contentWidth;
							break;
						}
					}
					
					tween = createTween( this, from, to, duration );
					break;
				}
				case HIDING :
				case HIDING_AFTER_INTERRUPT :
				{
					_bitmapFrom = new Bitmap();
					_bitmapFrom.bitmapData = ( state == HIDING ) ? BitmapData( bitmapDatum[ selectedIndexFrom ] ) : interruptedBitmapData;
					_bitmapFrom.x = contentX;
					_bitmapFrom.y = contentY;
					display.addChildAt( _bitmapFrom, 0 );
					
					viewStack.callLater( onTweenEnd, [ 0 ] );
					break;
				}
			}
			
			super.play();
		}
		
		override public function onTweenUpdate( value:Object ):void
		{
			super.onTweenUpdate( value );
			
			switch( state )
			{
				case SHOWING :
				case SHOWING_AFTER_INTERRUPT :
				{
					var position:Number = Number( value );
					
					switch( direction )
					{
						case Squash.DOWN :
						{
							_bitmapTo.y = position;
							_bitmapFrom.height = ( contentHeight - position ) - contentHeight + contentY;
							_bitmapFrom.y = contentHeight - _bitmapFrom.height + contentY;
							break;
						}
						case Squash.UP :
						{
							_bitmapTo.y = position;
							_bitmapFrom.height = _bitmapTo.y - contentY;
							_bitmapFrom.y = contentY;
							break;
						}
						case Squash.LEFT :
						{
							_bitmapTo.x = position;
							_bitmapFrom.width = _bitmapTo.x - contentX;
							_bitmapFrom.x = contentX;
							break;
						}
						case Squash.RIGHT :
						{
							_bitmapTo.x = position;
							_bitmapFrom.width = ( contentWidth - position ) - contentWidth + contentX;
							_bitmapFrom.x = contentWidth - _bitmapFrom.width + contentX;
							break;
						}
					}
				}
			}
		}
		
	}
}