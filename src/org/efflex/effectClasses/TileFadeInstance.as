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

package org.efflex.effectClasses
{
	import flash.display.Bitmap;
	
	import mx.core.UIComponent;

	public class TileFadeInstance extends TileInstance
	{
		
		public var alphaFrom					: Number;
		public var alphaTo						: Number;
		
		private var _alphaDifference			: Number;
		
		public function TileFadeInstance( target:UIComponent )
		{
			super( target );
		}
		
		override public function play():void
        {
        	_alphaDifference = alphaTo - alphaFrom;
        	
        	super.play();
        }
        
		override public function onTweenUpdate( value:Object ):void
		{
			super.onTweenUpdate( value );
			
			var tile:Bitmap;
			for( var r:int = 0; r < numRows; r++ )
			{
				for( var c:int = 0; c < numColumns; c++ )
				{
					tile = getTileAt( c, r );
					tile.alpha = alphaFrom + ( _alphaDifference * getTileValueAt( c, r ) );
				}
			}
		}
		
		override protected function createTiles():void
		{
			super.createTiles();
			
			var tile:Bitmap;
			for( var r:int = 0; r < numRows; r++ )
			{
				for( var c:int = 0; c < numColumns; c++ )
				{
					tile = getTileAt( c, r );
					tile.alpha = alphaFrom;
				}
			}
		}
	}
}