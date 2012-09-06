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
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;
	
	import mx.containers.ViewStack;
	import mx.core.Container;
	import mx.core.ContainerCreationPolicy;
	import mx.core.UIComponent;
	import mx.core.mx_internal;
	import mx.effects.effectClasses.TweenEffectInstance;
	import mx.managers.PopUpManager;
	
	import org.efflex.viewStackEffects.helpers.IViewStackEffectHelper;

	use namespace mx_internal;

	public class ViewStackInstance extends TweenEffectInstance
	{
		
		protected const HIDING							: String = "hiding";
		protected const SHOWING							: String = "showing";

		protected const READY_FOR_HIDE					: String = "readyForHide";
		protected const READY_FOR_SHOW					: String = "readyForShow";
		
		protected const HIDING_AFTER_INTERRUPT			: String = "hidingAfterInterrupt";
		protected const SHOWING_AFTER_INTERRUPT			: String = "showingAfterInterrupt";
		
		protected const READY_FOR_HIDE_AFTER_INTERRUPT	: String = "readyForHideAfterInterrupt";
		protected const READY_FOR_SHOW_AFTER_INTERRUPT	: String = "readyForShowAfterInterrupt";
		
		protected const COMPLETE						: String = "complete";
		
		public var hideTarget						: Boolean;
		public var transparent						: Boolean;
		public var popUp							: Boolean;
		public var modal 							: Boolean;
		public var modalTransparency				: Number;
		public var modalTransparencyColor 			: Number;
		public var modalTransparencyBlur 			: Number;
		public var modalTransparencyDuration 		: Number;
		
		private var _prevBlendMode					: String;
		
		private var _viewStack						: ViewStack;
		private var _helper							: IViewStackEffectHelper;
		private var _contentPane					: MovieClip;
		private var _mask							: Sprite;
		private var _popUpContentPane					: UIComponent;
		private var _display						: Sprite;
		
//		private var _bitmaps						: Array;
		
		public function ViewStackInstance( target:UIComponent )
		{
			super( target );
			
			if( target.parent is ViewStack )
			{
				_viewStack = ViewStack( target.parent );
			}
			else
			{
				throw new Error( "ViewStackInstance must have a target with a parent property that is a ViewStack or is a subclass of ViewStack" );
			}
		}
		
		public function get data():Object
		{
			return _contentPane;
		}
		
		public function get display():DisplayObjectContainer
		{
			return _display;
		}
		
		final public function get bitmapDatum():Array
		{
			return _contentPane.bitmapDatum;
		}
		
		final public function get interruptedBitmapData():BitmapData
		{
			return _contentPane.interruptedBitmapData;
		}
		
		final public function get selectedIndexTo():int
		{
			return _contentPane.selectedIndexTo;// : _viewStack.getChildIndex( DisplayObject( target ) );
		}
		
		final public function get selectedIndexFrom():int
		{
			return _contentPane.selectedIndexFrom;
		}
		
		final protected function get wasInterrupted():Boolean
		{
			return _contentPane.wasInterrupted;// : _viewStack.getChildIndex( DisplayObject( target ) );
		}
		
		final public function get state():String
		{
			return _contentPane.state;// : _viewStack.getChildIndex( DisplayObject( target ) );
		}
		
		final public function get viewStack():ViewStack
		{
			return _viewStack;
		}
		
		final protected function get contentX():Number
		{
			return _helper.contentX;
		}
		
		final protected function get contentY():Number
		{
			return _helper.contentY;
		}
		
		final protected function get contentWidth():Number
		{
			return _helper.contentWidth;
		}
		
		final protected function get contentHeight():Number
		{
			return _helper.contentHeight;
		}
		
		final public function set helper( Helper:Class ):void
        {
            _helper = IViewStackEffectHelper( new Helper( _viewStack ) );
        }
        
		override public function initEffect( event:Event ):void
	    {
	    	_contentPane = _viewStack.rawChildren.getChildByName( "ViewStackInstance" ) as MovieClip;
			if( !_contentPane ) createContainers();
			
			_display = Sprite( _contentPane.display );
			
			if( popUp ) _popUpContentPane = UIComponent( _contentPane.popUp );
			_contentPane.selectedIndexTo = _viewStack.selectedIndex;
			
			switch( state )
			{
				case READY_FOR_SHOW :
				{
					_contentPane.state = SHOWING;
					break;
				}
				case READY_FOR_HIDE :
				{
					_contentPane.state = HIDING;			
					
					resizeChildren();
					createBitmapDatum();
					break;
				}
				case READY_FOR_HIDE_AFTER_INTERRUPT :
				{
					_contentPane.state = HIDING_AFTER_INTERRUPT;
					createInterruptedBitmapData();
					break;
				}
				case READY_FOR_SHOW_AFTER_INTERRUPT :
				{
					_contentPane.state = SHOWING_AFTER_INTERRUPT;
					break;
				}
			}
	    	
	    	super.initEffect( event );
	    }
	    
	    override public function startEffect():void
	    {
	    	removeChildren();
	    	
	    	super.startEffect();
	    }
	    
	    override public function play():void
        {
			super.play();

			if( hideTarget ) applyEraseBlendMode( true );
        }

		protected function resizeChildren():void
		{
			viewStack.creationPolicy = ContainerCreationPolicy.ALL;
			viewStack.createComponentsFromDescriptors();
			
			var w:Number = contentWidth;
			var h:Number = contentHeight;
			var left:Number = contentX;
			var top:Number = contentY;

			var newWidth:Number;
			var newHeight:Number;

			var child:Container;
			
			var numChildren:uint = viewStack.numChildren;
			for( var i:int = 0; i < numChildren; i++ )
			{
				child = Container( viewStack.getChildAt( i ) );
				
				newWidth = w;
				newHeight = h;
			
				if ( !isNaN( child.percentWidth ) )
				{
					if( newWidth > child.maxWidth ) newWidth = child.maxWidth;
				}
				else
				{
					if( newWidth > child.explicitWidth ) newWidth = child.explicitWidth;
				}
	
				if( !isNaN( child.percentHeight ) )
				{
					if( newHeight > child.maxHeight ) newHeight = child.maxHeight;
				}
				else
				{
					if( newHeight > child.explicitHeight ) newHeight = child.explicitHeight;
				}
			
				if( child.width != newWidth || child.height != newHeight ) child.setActualSize( newWidth, newHeight );
				if( child.x != left || child.y != top ) child.move( left, top );
				if( child.mx_internal::invalidateDisplayListFlag ) child.validateNow();
			}
		}
		
        protected function createBitmapDatum():void
		{
			var bitmapData:BitmapData;

			var backgroundColor:Number = viewStack.getStyle( "backgroundColor" );
			if( isNaN( backgroundColor ) ) backgroundColor = 0xFFFFFF;
			
			var bitmapColor:int = ( transparent ) ? 0x00000000 : backgroundColor;
			
			var child:UIComponent;
			var numChildren:uint = viewStack.numChildren;
			for( var i:uint; i < numChildren; i++ )
			{
				child = UIComponent( viewStack.getChildAt( i ) );
				
				bitmapData = new BitmapData( child.width, child.height, transparent, bitmapColor );				
				bitmapData.draw( child );
				
				bitmapDatum.push( bitmapData );
			}
		}
		
		protected function createInterruptedBitmapData():void
		{
			if( interruptedBitmapData ) var preInterruptedBitmapData:BitmapData = interruptedBitmapData;

			var backgroundColor:Number = viewStack.getStyle( "backgroundColor" );
			if( isNaN( backgroundColor ) ) backgroundColor = 0xFFFFFF;
			
			var bitmapColor:int = ( transparent ) ? 0x00000000 : backgroundColor;
			
			var bitmapData:BitmapData = new BitmapData( contentWidth, contentHeight, transparent, 0x666666 );				
			bitmapData.draw( _display );
			
			_contentPane.interruptedBitmapData = bitmapData;
			
			if( preInterruptedBitmapData ) preInterruptedBitmapData.dispose();
		}		

		protected function createContainers():void
		{
			var containerContentPane:Sprite = _viewStack.mx_internal::contentPane;
			
			_contentPane = new MovieClip();
			_contentPane.name = "ViewStackInstance";
			
			_contentPane.x = ( containerContentPane ) ? containerContentPane.x : 0;
			_contentPane.y = ( containerContentPane ) ? containerContentPane.y : 0;
			
			_contentPane.bitmapDatum = new Array();
			_contentPane.state = READY_FOR_HIDE;
			_contentPane.selectedIndexFrom = _viewStack.getChildIndex( DisplayObject( target ) );
			
//			_contentPane.visible = false;
			
			_display = new Sprite();
			_contentPane.display = _display;
			
			if( popUp )
			{
				_popUpContentPane = new UIComponent();
				var globalPos:Point = viewStack.parent.localToGlobal( new Point( viewStack.x, viewStack.y ) );
				_popUpContentPane.x = globalPos.x;
				_popUpContentPane.y = globalPos.y;
				_popUpContentPane.setStyle( "modalTransparency", modalTransparency );
				_popUpContentPane.setStyle( "modalTransparencyColor", modalTransparencyColor );
				_popUpContentPane.setStyle( "modalTransparencyBlur", modalTransparencyBlur );
				_popUpContentPane.setStyle( "modalTransparencyDuration", modalTransparencyDuration );
				_popUpContentPane.addChild( _display );
				_contentPane.popUp = _popUpContentPane;
				PopUpManager.addPopUp( _popUpContentPane, viewStack, modal );
			}
			else
			{
				_contentPane.addChild( _display );
			}
			
			if( _viewStack.clipContent )
			{
				_mask = new Sprite();
				_mask.graphics.beginFill( 0x666666, 1 );
				_mask.graphics.drawRect( contentX, contentY, contentWidth, contentHeight );
			
				var maskTarget:DisplayObjectContainer = ( popUp ) ? _popUpContentPane : _contentPane;
				maskTarget.mask = _mask;
				maskTarget.addChild( _mask );
			}

			_viewStack.rawChildren.addChild( _contentPane );
		}
		
		override public function end():void
		{
			_contentPane.state = READY_FOR_HIDE_AFTER_INTERRUPT;
			
			super.end();
		}
		
		override public function finishEffect():void
		{
			super.finishEffect();

			if( hideTarget ) applyEraseBlendMode( false );
			
			switch( state )
			{
				case HIDING :
				{
					_contentPane.state = READY_FOR_SHOW;
					break;	
				}
				case HIDING_AFTER_INTERRUPT :
				{
					_contentPane.state = READY_FOR_SHOW_AFTER_INTERRUPT;
					break;	
				}
				case SHOWING_AFTER_INTERRUPT :
				case SHOWING :
				{
					_contentPane.state = COMPLETE;
					
					if( _contentPane.mask ) if( _contentPane.contains( _contentPane.mask ) ) _contentPane.removeChild( _contentPane.mask );
					if( _contentPane.contains( _display ) ) _contentPane.removeChild( _display );
			
					_viewStack.rawChildren.removeChild( _contentPane );
					
					if( _popUpContentPane )
					{
						if( _popUpContentPane.contains( _display ) ) _popUpContentPane.removeChild( _display );
						if( _popUpContentPane.mask ) _popUpContentPane.removeChild( _popUpContentPane.mask );
						PopUpManager.removePopUp( UIComponent( _popUpContentPane ) );
					}
					
					removeChildren();
					
					_popUpContentPane = null;
					_contentPane = null;
					break;
				}
			}
		}
		
		protected function removeChildren():void
		{
			var child:DisplayObject;
			var numChildren:int;
			var i:int;
			
			numChildren = display.numChildren;
			for( i = numChildren - 1; i > -1; i-- )
			{
				child = DisplayObject( display.getChildAt( i ) );
				display.removeChild( child );
			}			
		}
		
		protected function destroyBitmapDatum():void
		{
			var bitmapData:BitmapData;
			var numBitmaps:int = bitmapDatum.length;
			for( var i:int = 0; i < numBitmaps; i++ )
			{
				bitmapData = BitmapData( bitmapDatum.removeChildAt( 0 ) );
				if( bitmapData ) bitmapData.dispose();
			}
			
			if( interruptedBitmapData ) interruptedBitmapData.dispose();
		}
		
		private function applyEraseBlendMode( value:Boolean ):void
		{
			if( value )
			{
				_prevBlendMode = target.blendMode;
				target.blendMode = BlendMode.ERASE;
			}
			else
			{
				target.blendMode = ( _prevBlendMode ) ? _prevBlendMode : BlendMode.NORMAL;
			}
		}
	}
}