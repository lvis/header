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
	
	import mx.core.UIComponent;
	
	import org.efflex.viewStackEffects.Fade;
	
	public class FadeInstance extends ViewStackInstance
	{
		
		public var alphaFrom					: Number;
		public var alphaTo						: Number;
		public var effectTarget					: String;
		
		private var _effectTarget				: Bitmap;
		
		public function FadeInstance( target:UIComponent )
		{
			super( target );
		}
		
		override public function play():void
        {
			var bitmapFrom:Bitmap;
			var bitmapTo:Bitmap;
			
            switch( state )
			{
				case SHOWING :
				case SHOWING_AFTER_INTERRUPT :
				{
					bitmapFrom = new Bitmap();
					bitmapFrom.bitmapData = ( state == SHOWING ) ? BitmapData( bitmapDatum[ selectedIndexFrom ] ) : interruptedBitmapData;
					bitmapFrom.x = contentX;
					bitmapFrom.y = contentY;
					display.addChild( bitmapFrom );
					
					bitmapTo = new Bitmap();
					bitmapTo.bitmapData = BitmapData( bitmapDatum[ selectedIndexTo ] );
					bitmapTo.x = contentX;
					bitmapTo.y = contentY;
					display.addChild( bitmapTo );
					
					switch( effectTarget )
					{
						case Fade.NEXT_CHILD :
						{
							_effectTarget = bitmapTo;
							break;
						}
						case Fade.PREV_CHILD :
						{
							display.swapChildren( bitmapFrom, bitmapTo );
							_effectTarget = bitmapFrom;
							break;
						}
					}
			
					_effectTarget.alpha = alphaFrom;
			
					tween = createTween( this, alphaFrom, alphaTo, duration );
					break;
				}
				case HIDING :
				case HIDING_AFTER_INTERRUPT :
				{
					bitmapFrom = new Bitmap();
					bitmapFrom.bitmapData = ( state == HIDING ) ? BitmapData( bitmapDatum[ selectedIndexFrom ] ) : interruptedBitmapData;
					bitmapFrom.x = contentX;
					bitmapFrom.y = contentY;
					display.addChild( bitmapFrom );
					
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
					_effectTarget.alpha = Number( value );
				}
			}
		}
		
	}
}