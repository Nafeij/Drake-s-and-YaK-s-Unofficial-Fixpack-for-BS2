package com.stoicstudio.platform
{
   import engine.core.analytic.Ga;
   import engine.core.gp.GpDeviceType;
   import engine.core.gp.GpSource;
   import engine.gui.GuiMouse;
   import engine.saga.SagaInstance;
   import engine.saga.SagaVar;
   import engine.scene.view.SceneMouseAdapterGp;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.system.Capabilities;
   import flash.system.TouchscreenType;
   
   public class PlatformInput
   {
      
      public static const dispatcher:EventDispatcher = new EventDispatcher();
      
      public static const EVENT_LAST_INPUT:String = "PlatformInput.EVENT_LAST_INPUT";
      
      public static const EVENT_CURSOR_LOST_FOCUS:String = "PlatformInput.EVENT_CURSOR_LOST_FOCUS";
      
      public static const EVENT_CURSOR_CANCEL_PRESS:String = "PlatformInput.EVENT_CURSOR_CANCEL_PRESS";
      
      private static var ga_lastInputGp:Boolean;
      
      public static var lastInputGp:Boolean;
      
      public static var hasClicker:Boolean;
      
      public static var hasKeyboard:Boolean = true;
      
      public static var isMobile:Boolean;
      
      public static var isVita:Boolean;
      
      public static var isGp:Boolean;
      
      public static var isTouch:Boolean;
      
      public static var DOUBLE_CLICK_THRESHOLD_PIXELS:int = 10;
      
      private static var DOUBLE_CLICK_THRESHOLD_INCHES:Number = 0.25;
      
      public static var DOUBLE_CLICK_THRESHOLD_MS:int = 400;
      
      public static var TOUCH_COMPENSATION_ENABLED:Boolean;
      
      public static var BLOCK_GP_DEV_MODE:Boolean = false;
       
      
      public function PlatformInput()
      {
         super();
      }
      
      public static function get platformInputString() : String
      {
         if(isVita)
         {
            return "vita";
         }
         if((isGp || GpSource.primaryDevice) && lastInputGp)
         {
            if(SceneMouseAdapterGp.ZOOM_USING_GP_TRIGGERS)
            {
               return "gp_alt";
            }
            return "gp";
         }
         if(isMobile)
         {
            return "mobile";
         }
         return "";
      }
      
      public static function touchInputGp() : void
      {
         var _loc1_:GpDeviceType = null;
         var _loc2_:String = null;
         var _loc3_:String = null;
         if(!lastInputGp || hasClicker)
         {
            hasClicker = false;
            lastInputGp = true;
            if(SagaInstance.instance)
            {
               SagaInstance.instance.setVar(SagaVar.VAR_GP,lastInputGp);
            }
            dispatcher.dispatchEvent(new Event(EVENT_LAST_INPUT));
            GuiMouse.performVanishCursor();
            if(!ga_lastInputGp)
            {
               _loc1_ = GpSource.primaryDeviceType;
               _loc2_ = !!_loc1_ ? _loc1_.visualCategory : " missing";
               _loc3_ = !!_loc1_ ? _loc1_.name : " missing";
               Ga.minimal("sys","gp",_loc2_,1);
               Ga.minimal("sys","gpid",_loc3_,1);
            }
         }
      }
      
      public static function touchInputMouse() : void
      {
         if(lastInputGp || !hasClicker)
         {
            hasClicker = true;
            lastInputGp = false;
            if(SagaInstance.instance)
            {
               SagaInstance.instance.setVar(SagaVar.VAR_GP,lastInputGp);
            }
            dispatcher.dispatchEvent(new Event(EVENT_LAST_INPUT));
         }
      }
      
      public static function init() : void
      {
         if(TOUCH_COMPENSATION_ENABLED)
         {
            isTouch = Capabilities.touchscreenType != TouchscreenType.NONE;
         }
         if(isTouch)
         {
            DOUBLE_CLICK_THRESHOLD_PIXELS = DOUBLE_CLICK_THRESHOLD_INCHES * Capabilities.screenDPI;
         }
      }
   }
}
