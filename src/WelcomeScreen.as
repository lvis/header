package 
{
    import flash.display.*;
    import flash.events.*;
    import flash.utils.*;
    
    public class WelcomeScreen extends flash.display.Loader
    {
        public function WelcomeScreen()
        {
            super();
            this.visible = false;
            this.alpha = 0;
            timer = new flash.utils.Timer(1);
            timer.addEventListener(flash.events.TimerEvent.TIMER, updateView);
            timer.start();
            this.loadBytes(new WelcomeScreen_WelcomeScreenGraphic() as flash.utils.ByteArray);
            this.addEventListener(flash.events.MouseEvent.MOUSE_DOWN, mouseDown);
            return;
        }

        public function closeScreenFade(arg1:flash.events.TimerEvent):void
        {
            if (this.alpha > 0) 
            {
                this.alpha = this.alpha - fadeOutRate;
            }
            else 
            {
                timer.stop();
                this.parent.removeChild(this);
            }
            return;
        }

        public function mouseDown(arg1:flash.events.MouseEvent):void
        {
            closeScreen();
            return;
        }

        public function closeScreen():void
        {
            timer.removeEventListener(flash.events.TimerEvent.TIMER, updateView);
            timer.removeEventListener(flash.events.MouseEvent.MOUSE_DOWN, mouseDown);
            timer.addEventListener(flash.events.TimerEvent.TIMER, closeScreenFade);
            return;
        }

        public function updateView(arg1:flash.events.TimerEvent):void
        {
            if (this.alpha < 1) 
            {
                this.alpha = this.alpha + this.fadeInRate;
            }
            this.stage.addChild(this);
            this.x = this.stage.stageWidth / 2 - this.width / 2;
            this.y = this.stage.stageHeight / 2 - this.height / 2;
            this.visible = true;
            if (this.ready && timer.currentCount > this.timeAutoClose) 
            {
                closeScreen();
            }
            return;
        }

        internal var fadeInRate:Number=0.01;

        public var ready:Boolean=false;

        public var timer:flash.utils.Timer;

        internal var fadeOutRate:Number=0.02;

        internal var timeAutoClose:int=1;
    }
}
