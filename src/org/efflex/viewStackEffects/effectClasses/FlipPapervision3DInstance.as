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
	import mx.core.UIComponent;
	
	import org.papervision3d.objects.primitives.Plane;
	
	import org.efflex.viewStackEffects.FlipPapervision3D;
	import ws.tink.utils.MathUtil;

	public class FlipPapervision3DInstance extends Papervision3DViewStackInstance
	{
		
		public var scaleDurationByChange	: Boolean = true;
		public var direction				: String;
		public var numSegmentsWidth			: uint;
		public var numSegmentsHeight		: uint;
		
		private var _plane					: Plane;
		private var _showingSelectedIndexTo	: Boolean;
		
		private var _rotationStart			: Number;
		private var _rotationDiff			: Number;
		
		public function FlipPapervision3DInstance(target:UIComponent)
		{
			super( target );
		}
		
		override public function end():void
		{
			data.interruptedDisplayedIndex = ( _plane.material == getBitmapMaterialAt( selectedIndexTo ) ) ? selectedIndexTo : selectedIndexFrom;
			data.interruptedRotationX = _plane.rotationX;
			data.interruptedRotationY = _plane.rotationY;
			
			super.end();
		}
		
		override public function play():void
        {
			_plane = Plane( scene.getChildByName( "plane" ) );
			
			switch( state )
			{
				case SHOWING :
				{
					_rotationStart = 0;
					
					switch( direction )
					{
						case FlipPapervision3D.UP :
						{
							_rotationDiff = -180;
							break;
						}
						case FlipPapervision3D.DOWN :
						{
							_rotationDiff = 180;
							break;
						}
						case FlipPapervision3D.LEFT :
						{
							_rotationDiff = 180;
							break;
						}
						case FlipPapervision3D.RIGHT :
						{
							_rotationDiff = -180;
							break;
						}
					}
					tween = createTween( this, 0, 1, duration );
					break;
				}
				case SHOWING_AFTER_INTERRUPT :
				{
					switch( direction )
					{
						case FlipPapervision3D.UP :
						{
							_rotationStart = data.interruptedRotationX;
							_plane.rotationX = _rotationStart;
							_rotationDiff = _rotationStart - 180;
							break;
						}
						case FlipPapervision3D.DOWN :
						{
							_rotationStart = data.interruptedRotationX;
							_plane.rotationX = _rotationStart;
							_rotationDiff = _rotationStart - 180;
							break;
						}
						case FlipPapervision3D.LEFT :
						{
							_rotationStart = data.interruptedRotationY;
							_plane.rotationY = _rotationStart;
							_rotationDiff = 180 - _rotationStart;
							break;
						}
						case FlipPapervision3D.RIGHT :
						{
							_rotationStart = data.interruptedRotationY;
							_plane.rotationY = _rotationStart;
							_rotationDiff = _rotationStart - 180;
							break;
						}
					}
					if( data.interruptedDisplayedIndex == selectedIndexTo ) _rotationDiff = -_rotationStart;
					
					var changePercent:Number = Math.abs( _rotationDiff ) / 180;
					var targetDuration:Number = ( scaleDurationByChange ) ? duration *= changePercent : duration;
					tween = createTween( this, 0, 1, targetDuration );
					break;
				}
				case HIDING :
				{
					_plane = new Plane( getBitmapMaterialAt( selectedIndexFrom ), contentWidth, contentHeight, numSegmentsWidth, numSegmentsHeight );
					_plane.name = "plane";
					scene.addChild( _plane );
					
					if( !viewStack.clipContent )
					{
	    				var ratio:Number = -( camera.zoom / ( ( camera.z - _plane.z ) / camera.focus ) );
	    				setSize( contentWidth * ratio, contentHeight * ratio );
	    			}
    		
					viewStack.callLater( onTweenEnd, [ 0 ] );
					break;
				}
				case HIDING_AFTER_INTERRUPT :
				{
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
					var v:Number = Number( value );
					
					var targetRotation:Number = _rotationStart + ( _rotationDiff * v );
					if( targetRotation < -90 )
					{
						_rotationStart += 180;
						targetRotation += 180;
						_plane.material = getBitmapMaterialAt( selectedIndexTo );
					}
					if( targetRotation > 90 )
					{
						_rotationStart -= 180;
						targetRotation -= 180;
						_plane.material = getBitmapMaterialAt( selectedIndexTo );
					}
					
					switch( direction )
					{
						case FlipPapervision3D.DOWN :
						case FlipPapervision3D.UP :
						{
							_plane.rotationX = targetRotation
							if( viewStack.clipContent ) _plane.z = Math.abs( Math.sin( MathUtil.degreesToRadians( _plane.rotationX ) ) * ( contentHeight / 2 ) );
							break;
						}
						case FlipPapervision3D.LEFT :
						case FlipPapervision3D.RIGHT :
						{
							_plane.rotationY = targetRotation;
							if( viewStack.clipContent ) _plane.z = Math.abs( Math.sin( MathUtil.degreesToRadians( _plane.rotationY ) ) * ( contentWidth / 2 ) );
							break;
						}
					}
				}
			}
		}

	}
}