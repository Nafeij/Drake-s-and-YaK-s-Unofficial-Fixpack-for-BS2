package com.stoicstudio.platform
{
   import engine.core.logging.ILogger;
   import engine.landscape.view.DisplayObjectWrapper;
   import engine.landscape.view.DisplayObjectWrapperFlash;
   import flash.display.DisplayObject;
   import flash.display.Stage;
   
   public class PlatformFlash
   {
      
      public static var stage:Stage;
      
      public static var fullscreen:Boolean;
       
      
      public function PlatformFlash()
      {
         super();
      }
      
      public static function displayObjectWrapperCtor(param1:DisplayObject) : DisplayObjectWrapper
      {
         return new DisplayObjectWrapperFlash(param1);
      }
      
      public static function getInfo(param1:ILogger) : void
      {
         param1.info("PlatformFlash:");
         param1.info("      stage               = " + stage);
         if(stage)
         {
            param1.info("      stage.mouseEnabled  = " + stage.mouseEnabled);
            param1.info("      stage.mouseChildren = " + stage.mouseChildren);
         }
      }
   }
}
