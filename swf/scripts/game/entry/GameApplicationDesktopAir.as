package game.entry
{
   import com.stoicstudio.platform.PlatformStarling;
   import engine.gui.core.GuiApplication;
   import flash.desktop.NativeApplication;
   import flash.events.ErrorEvent;
   import flash.events.Event;
   import flash.events.InvokeEvent;
   import flash.events.UncaughtErrorEvent;
   
   public class GameApplicationDesktopAir extends GuiApplication
   {
       
      
      public var entry:GameEntryDesktopAir;
      
      public function GameApplicationDesktopAir(param1:String, param2:String, param3:String)
      {
         super(param1,param2,param3);
         this.entry = new GameEntryDesktopAir(this,param1,param2,param3);
         this.resizeHandler();
         NativeApplication.nativeApplication.addEventListener(InvokeEvent.INVOKE,this.invokeHandler);
         NativeApplication.nativeApplication.addEventListener(Event.EXITING,this.exitingHandler);
         NativeApplication.nativeApplication.addEventListener(Event.CLOSING,this.closingHandler);
      }
      
      protected function closingHandler(param1:Event) : void
      {
         this.entry.closingHandler(param1);
      }
      
      protected function exitingHandler(param1:Event) : void
      {
         this.entry.exitingHandler(param1);
      }
      
      protected function invokeHandler(param1:InvokeEvent) : void
      {
         var event:InvokeEvent = param1;
         try
         {
            this.entry.invokeHandler(event);
         }
         catch(e:Error)
         {
            entry.logError(e.getStackTrace());
         }
      }
      
      override protected function resizeHandler() : void
      {
         super.resizeHandler();
         if(this.entry)
         {
            this.entry.implResizeHandler();
         }
      }
      
      final private function handleUncaughtError(param1:UncaughtErrorEvent) : void
      {
         var _loc2_:String = null;
         var _loc3_:Error = null;
         var _loc4_:ErrorEvent = null;
         if(param1.error is Error)
         {
            _loc3_ = param1.error as Error;
            if(_loc3_.errorID == 3694)
            {
               if(this.entry.useStarling && Boolean(PlatformStarling.instance))
               {
                  if(this.entry && !this.entry.resetOnActivate && this.entry.appInfo && Boolean(this.entry.appInfo.logger))
                  {
                     this.entry.appInfo.logger.info("Asset error: will reset on next activate");
                     this.entry.resetOnActivate = true;
                  }
                  return;
               }
            }
            _loc2_ = _loc3_.getStackTrace();
         }
         else if(param1.error is ErrorEvent)
         {
            _loc4_ = param1.error as ErrorEvent;
            _loc2_ = "ERROR EVENT: type=" + _loc4_.type + " text=" + _loc4_.text;
         }
         else
         {
            _loc2_ = String(param1.error.toString());
         }
         if(this.entry && this.entry.appInfo && Boolean(this.entry.appInfo.logger))
         {
            this.entry.appInfo.logger.critical(_loc2_);
         }
      }
      
      final protected function addUncaughtErrorHandler() : void
      {
         if(Boolean(loaderInfo) && Boolean(loaderInfo.uncaughtErrorEvents))
         {
            loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR,this.handleUncaughtError);
         }
      }
   }
}
