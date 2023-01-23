package engine.gui.core
{
   import flash.events.Event;
   
   public class GuiSpriteEvent extends Event
   {
      
      public static const RESIZE:String = "GuiSpriteEvent.RESIZE";
       
      
      public function GuiSpriteEvent(param1:String, param2:Boolean = false, param3:Boolean = false)
      {
         super(param1,param2,param3);
      }
   }
}
