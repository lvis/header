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
	
	import org.efflex.viewStackEffects.FadeZoom;
	
	
	public class FadeZoomInstance extends ViewStackInstance
	{
		
		
		public var alphaFrom					: Number;
		public var alphaTo						: Number;
		
		public var scaleXTo						: Number;
		public var scaleXFrom					: Number;
		public var scaleYTo						: Number;
		public var scaleYFrom					: Number;
		
		public var verticalAlign				: String;
		public var horizontalAlign				: String;
		
		public var effectTarget					: String;
		
		private var _effectTarget				: Bitmap
		
		public function FadeZoomInstance( target:UIComponent )
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
						case FadeZoom.NEXT_CHILD :
						{
							_effectTarget = bitmapTo;
							break;
						}
						case FadeZoom.PREV_CHILD :
						{
							display.swapChildren( bitmapFrom, bitmapTo );
							_effectTarget = bitmapFrom;
							break;
						}
					}
					
					_effectTarget.alpha = alphaFrom;
					_effectTarget.scaleX = scaleXFrom;
					_effectTarget.scaleY = scaleYFrom;
					
					alignTarget();
					
					tween = createTween( this, [ alphaFrom, scaleXFrom, scaleYFrom ], [ alphaTo, scaleXTo, scaleYTo ], duration );
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
					_effectTarget.alpha = Number( value[ 0 ] );
					_effectTarget.scaleX = Number( value[ 1 ] );
					_effectTarget.scaleY = Number( value[ 2 ] );
					
					alignTarget();
				}
			}
		}
		
		private function alignTarget():void
		{
			switch( horizontalAlign )
			{
				case FadeZoom.LEFT :
				{
					_effectTarget.y = contentX;
					break;
				}
				case FadeZoom.CENTER :
				{
					_effectTarget.x = contentX + ( ( contentWidth - _effectTarget.width ) / 2 );
					break;
				}
				case FadeZoom.RIGHT :
				{
					_effectTarget.x = contentX + contentWidth - _effectTarget.width;
					break;
				}
			}
			
			switch( verticalAlign )
			{
				case FadeZoom.TOP :
				{
					_effectTarget.y = contentY;
					break;
				}
				case FadeZoom.MIDDLE :
				{
					_effectTarget.y = contentY + ( ( contentHeight - _effectTarget.height ) / 2 );
					break;
				}
				case FadeZoom.BOTTOM :
				{
					_effectTarget.y = contentY + contentHeight - _effectTarget.height;
					break;
				}
			}
		}
		
	}
}