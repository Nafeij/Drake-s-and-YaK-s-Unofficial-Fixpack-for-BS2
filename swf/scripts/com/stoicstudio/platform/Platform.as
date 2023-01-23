package com.stoicstudio.platform
{
   import engine.core.logging.ILogger;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.utils.getTimer;
   
   public class Platform
   {
      
      public static var id:String = "unknown";
      
      public static var paused:Boolean;
      
      private static var pauseTime:int;
      
      public static var pauseDuration:int;
      
      public static var suspended:Boolean;
      
      public static var qualityTextures:Number = 1;
      
      public static var drawQuality:Number = 1;
      
      public static var textScale:Number = 1;
      
      public static var startPageScale:Number;
      
      public static var requiresUiSafeZoneBuffer:Boolean = false;
      
      public static var supportsOSFilePicker:Boolean = false;
      
      public static var showSaveSpinner:Boolean = false;
      
      public static var showStartupLogos:Boolean = false;
      
      public static var optimizeForConsole:Boolean = false;
      
      public static var suppressAchievements:Boolean = false;
      
      public static var suppressUIAchievementNotifications:Boolean = false;
      
      public static var _showBuyTbs2Func:Function;
      
      public static var DEFAULT_TEXTSCALE:Number = 1;
      
      public static const EVENT_TEXTSCALE:String = "Platform.EVENT_TEXTSCALE";
      
      public static var dispatcher:EventDispatcher = new EventDispatcher();
      
      public static var toucher:IUserInputToucher;
       
      
      public function Platform()
      {
         super();
      }
      
      public static function setTextScale(param1:Number) : void
      {
         if(param1 != textScale)
         {
            textScale = param1;
            dispatcher.dispatchEvent(new Event(EVENT_TEXTSCALE));
         }
      }
      
      public static function getInfo(param1:ILogger) : void
      {
         param1.info("Platform:");
         param1.info("      paused          = " + paused);
         param1.info("      pauseTime       = " + pauseTime);
         param1.info("      pauseDuration   = " + pauseDuration);
         param1.info("      suspended       = " + suspended);
         param1.info("      qualityTextures = " + qualityTextures);
         param1.info("      drawQuality     = " + drawQuality);
      }
      
      public static function update(param1:int, param2:ILogger) : void
      {
      }
      
      public static function pause() : void
      {
         if(!paused)
         {
            paused = true;
            pauseTime = getTimer();
         }
      }
      
      public static function resume() : void
      {
         if(paused)
         {
            paused = true;
            pauseDuration = getTimer() - pauseTime;
         }
      }
      
      public static function showBuyTbs2() : void
      {
         if(_showBuyTbs2Func != null)
         {
            _showBuyTbs2Func();
         }
      }
   }
}
