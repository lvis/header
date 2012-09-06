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
	
	import org.efflex.viewStackEffects.Scroll;
	

	
	public class ScrollInstance extends ViewStackInstance
	{
		
		public var scaleDurationByChange		: Boolean = true;
		public var direction 					: String;
		
		
		public function ScrollInstance( target:UIComponent )
		{
			super( target );
		}
		
		override public function play():void
        {
        	var i:uint;
			var child:Bitmap;
			var numChildren:uint = viewStack.numChildren;
			
			var toX:Number;
        	var toY:Number;
        	var targetDuration:Number;
        	
			switch( state )
			{
				case HIDING :
				{
					child = new Bitmap();
					child.bitmapData = BitmapData( bitmapDatum[ selectedIndexFrom ] );
					child.x = contentX;
					child.y = contentY;
					display.addChildAt( child, 0 );
					viewStack.callLater( onTweenEnd, [ 0 ] );
					break;
				}
				case SHOWING :
				{
		        	switch( direction )
					{
						case Scroll.HORIZONTAL :
						{
							toX = -( contentWidth * selectedIndexTo );
							toY = display.y;
							display.x = -( selectedIndexFrom * contentWidth );
							break;
						}
						case Scroll.VERTICAL :
						{
							toX = display.x
							toY = -( contentHeight * selectedIndexTo );
							display.y = -( selectedIndexFrom * contentHeight );
							break;
						}
					}
					
					createScroll();
					targetDuration = ( scaleDurationByChange ) ? duration * Math.abs( selectedIndexFrom - selectedIndexTo ) : duration;
					tween = createTween( this, new Array( display.x, display.y ), new Array( toX, toY ), targetDuration );
					break;
				}
				case HIDING_AFTER_INTERRUPT :
				{
					createScroll();
					viewStack.callLater( onTweenEnd, [ 0 ] );
					break;
				}
				case SHOWING_AFTER_INTERRUPT :
				{
		        	switch( direction )
					{
						case Scroll.HORIZONTAL :
						{
							toX = -( contentWidth * selectedIndexTo );
							toY = display.y;
							break;
						}
						case Scroll.VERTICAL :
						{
							toX = display.x
							toY = -( contentHeight * selectedIndexTo );
							break;
						}
					}
					
					createScroll();
					targetDuration = ( scaleDurationByChange ) ? duration * Math.abs( selectedIndexFrom - selectedIndexTo ) : duration;
					if( targetDuration == 0 ) targetDuration = duration;
					tween = createTween( this, new Array( display.x, display.y ), new Array( toX, toY ), targetDuration );
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
					display.x = Number( value[ 0 ] );
					display.y = Number( value[ 1 ] );
					break;
				}
			}
		}
		
		private function createScroll():void
		{
			var i:uint;
			var child:Bitmap;
			var numChildren:uint = viewStack.numChildren;
			
			switch( direction )
			{
				case Scroll.HORIZONTAL :
				{
					for( i = 0; i < numChildren; i++ )
					{
						child = new Bitmap();
						child.bitmapData = BitmapData( bitmapDatum[ i ] );
						child.x = contentWidth * i;
						display.addChild( child );
					}
					break;
				}
				case Scroll.VERTICAL :
				{
					for( i = 0; i < numChildren; i++ )
					{
						child = new Bitmap();
						child.bitmapData = BitmapData( bitmapDatum[ i ] );
						child.y = contentHeight * i;
						display.addChild( child );
					}
					break;
				}
			}
		}
		
	}
}