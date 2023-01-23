package engine.landscape.view
{
   import engine.core.logging.ILogger;
   import engine.landscape.def.LandscapeSpriteDef;
   import engine.saga.ISaga;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   
   public class LandscapeViewConfig
   {
      
      public static var GREY_BITMAPS_URL:String = "common/scene/grey1.png";
      
      public static var ENABLE_BITMAPS:Boolean = true;
      
      public static var ENABLE_ANIMS:Boolean = true;
      
      public static var NEW_LANDSCAPE:Boolean = false;
      
      public static var OMIT_EMPTY_LAYERS:Boolean = true;
      
      public static var EDITOR_MODE:Boolean = false;
      
      public static var DO_LLV:Boolean = false;
      
      public static var BUFFER_RENDER_ENABLED:Boolean = true;
      
      public static var LOAD_BARRIER_ENABLED:Boolean = true;
      
      public static var FORCE_UNLOCK_CAMERA_PAN:Boolean = false;
      
      public static var DEBUG_RENDER_FRAME:Boolean = false;
      
      public static var disableClickables:Boolean;
      
      public static var forceTooltips:Boolean;
      
      private static var _showClickables:Boolean;
      
      public static var showClickablesDispatcher:EventDispatcher = new EventDispatcher();
      
      public static var allowRandomLayers:Boolean = true;
      
      public static var allowConditions:Boolean = true;
      
      public static var allowOcclusionLayers:Boolean = true;
      
      public static var pixelize:int = 0;
       
      
      public function LandscapeViewConfig()
      {
         super();
      }
      
      public static function get showClickables() : Boolean
      {
         return _showClickables;
      }
      
      public static function set showClickables(param1:Boolean) : void
      {
         _showClickables = param1;
         showClickablesDispatcher.dispatchEvent(new Event(Event.CHANGE));
      }
      
      public static function spriteDefOk(param1:ISaga, param2:LandscapeSpriteDef, param3:ILogger) : Boolean
      {
         if(param2.clickable)
         {
            if(disableClickables)
            {
               if(!param2.tooltip || !forceTooltips)
               {
                  return false;
               }
            }
         }
         if(param1)
         {
            if(param2.ifCondition)
            {
               if(!param1.expression.evaluate(param2.ifCondition,true))
               {
                  if(param3.isDebugEnabled)
                  {
                     param3.debug("SpriteDef [" + param2 + "] ifCondition skipping [" + param2.ifCondition + "]");
                  }
                  return false;
               }
            }
         }
         if(param2.anchor)
         {
            return true;
         }
         if(param2.anim)
         {
            return ENABLE_ANIMS;
         }
         if(!param2.clickable && !param2.label && !param2.anchor)
         {
            return ENABLE_BITMAPS || param2.bmp == GREY_BITMAPS_URL;
         }
         return true;
      }
   }
}
