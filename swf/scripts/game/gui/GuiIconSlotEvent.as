package game.gui
{
   import flash.events.Event;
   
   public class GuiIconSlotEvent extends Event
   {
      
      public static const CLICKED:String = "GuiIconSlotEvent.CLICKED";
      
      public static const DOUBLE_CLICKED:String = "GuiIconSlotEvent.DOUBLE_CLICKED";
      
      public static const DROP:String = "GuiIconSlotEvent.DROP";
      
      public static const DRAG_END:String = "GuiIconSlotEvent.DRAG_END";
      
      public static const DRAG_START:String = "GuiIconSlotEvent.DRAG_START";
       
      
      public function GuiIconSlotEvent(param1:String)
      {
         super(param1);
      }
   }
}
