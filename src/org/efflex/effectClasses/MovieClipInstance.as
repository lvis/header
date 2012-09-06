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
	import flash.display.BlendMode;
	import flash.display.DisplayObjectContainer;
	import flash.display.FrameLabel;
	import flash.display.MovieClip;
	import flash.events.Event;
	
	import mx.core.Application;
	import mx.core.Container;
	import mx.core.UIComponent;
	
	public class MovieClipInstance extends ContainerInstance
	{
		
		public var source						: Class;
		public var frameFrom					: Object;
		public var frameTo						: Object;
		
		private var _movieClip					: MovieClip;
		
		public var _frameNumberFrom				: int = -1;
		public var _frameNumberTo				: int = -1;
		
		public function MovieClipInstance( target:UIComponent )
		{
			super( target );
		}

		override public function play():void
        {
			_movieClip = MovieClip( new source() );
		
			var frameLabel:FrameLabel;
			var frameLabels:Array = _movieClip.currentLabels;
			var numFrameLabels:uint = frameLabels.length;
			for( var i:uint = 0; i < numFrameLabels; i++)
			{
			    frameLabel = FrameLabel( frameLabels[ i ] );
			    if( frameLabel.name == frameFrom.toString() ) _frameNumberFrom = frameLabel.frame;
			    if( frameLabel.name == frameTo.toString() ) _frameNumberTo = frameLabel.frame;
			}
			
			if( frameFrom )
			{
				if( _frameNumberFrom == -1 && frameFrom is int )
				{
					if( frameFrom < 1 ) throw new Error( "Frame number must be bigger than 0" );
					if( frameFrom > _movieClip.totalFrames ) throw new Error( "Frame number must be less than totalFrames" );
					_frameNumberFrom = int( frameFrom );
				}
				else
				{
					throw new Error( "Frame label '" + frameFrom + "' could not be found" );
				}
			}
			else
			{
				_frameNumberFrom = 0;
			}
			
			if( frameTo )
			{
				if( _frameNumberTo == -1&& frameTo is int )
				{
					if( frameTo < 1 ) throw new Error( "Frame number must be bigger than 0" );
					if( frameTo > _movieClip.totalFrames ) throw new Error( "Frame number must be less than totalFrames" );
					_frameNumberTo = int( frameTo );
				}
				else
				{
					throw new Error( "Frame label '" + frameFrom + "' could not be found" );
				}
			}
			else
			{
				_frameNumberTo = _movieClip.totalFrames;
			}
			
			_movieClip.gotoAndStop( _frameNumberFrom );
			display.addChild( _movieClip );
			
			if( isNaN( duration ) ) duration = ( Math.abs( _frameNumberTo - _frameNumberFrom ) / Application.application.stage.frameRate ) * 1000;
			
			tween = createTween( this, 0, 1, duration );
			
			super.play();
        }

		override public function onTweenUpdate( value:Object ):void
		{
			super.onTweenUpdate( value );
			
			var diff:int = _frameNumberTo - _frameNumberFrom;
			_movieClip.gotoAndStop( Math.round( _frameNumberFrom + ( diff * Number( value ) ) ) );
		}
		
		override public function finishEffect():void
	    {
			display.removeChild( _movieClip );
	    	_movieClip = null;
	    	
	    	super.finishEffect();
	    }
	    
	}
}