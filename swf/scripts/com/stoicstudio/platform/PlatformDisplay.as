package com.stoicstudio.platform
{
   import engine.landscape.view.DisplayObjectWrapper;
   import flash.display.DisplayObject;
   import starling.display.DisplayObject;
   
   public class PlatformDisplay
   {
      
      public static var disableEdgeAAModeFunc:Function;
       
      
      public function PlatformDisplay()
      {
         super();
      }
      
      public static function displayObjectWrapperCtor(param1:*) : DisplayObjectWrapper
      {
         if(param1 is flash.display.DisplayObject)
         {
            return PlatformFlash.displayObjectWrapperCtor(param1 as flash.display.DisplayObject);
         }
         if(param1 is starling.display.DisplayObject)
         {
            return PlatformStarling.displayObjectWrapperCtor(param1 as starling.display.DisplayObject);
         }
         throw new ArgumentError("Can\'t wrap " + param1);
      }
      
      public static function disableEdgeAAMode(param1:flash.display.DisplayObject) : void
      {
         if(disableEdgeAAModeFunc != null)
         {
            disableEdgeAAModeFunc(param1);
         }
      }
   }
}
