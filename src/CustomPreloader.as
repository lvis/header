package 
{
    import flash.display.*;
    import flash.events.*;
    import mx.events.*;
    import mx.preloaders.*;
    
    public class CustomPreloader extends mx.preloaders.DownloadProgressBar
    {
        public function CustomPreloader()
        {
            super();
            wcs = new WelcomeScreen();
            this.addChild(wcs);
            return;
        }

        internal function FlexInitComplete(arg1:flash.events.Event):void
        {
            wcs.ready = true;
            dispatchEvent(new flash.events.Event(flash.events.Event.COMPLETE));
            return;
        }

        internal function SWFDownloadProgress(arg1:flash.events.ProgressEvent):void
        {
            return;
        }

        internal function SWFDownloadComplete(arg1:flash.events.Event):void
        {
            return;
        }

        public override function set preloader(arg1:flash.display.Sprite):void
        {
            arg1.addEventListener(flash.events.ProgressEvent.PROGRESS, SWFDownloadProgress);
            arg1.addEventListener(flash.events.Event.COMPLETE, SWFDownloadComplete);
            arg1.addEventListener(mx.events.FlexEvent.INIT_PROGRESS, FlexInitProgress);
            arg1.addEventListener(mx.events.FlexEvent.INIT_COMPLETE, FlexInitComplete);
            return;
        }

        internal function FlexInitProgress(arg1:flash.events.Event):void
        {
            return;
        }

        public var wcs:WelcomeScreen;
    }
}
