package engine.gui
{
   import flash.events.Event;
   
   public class GuiContextEvent extends Event
   {
      
      public static const PURCHASES:String = "GuiContextEvent.PURCHASES";
      
      public static const UNLOCKS:String = "GuiContextEvent.UNLOCKS";
      
      public static const CURRENCY:String = "GuiContextEvent.CURRENCY";
      
      public static const LOCALE:String = "GuiContextEvent.LOCALE";
      
      public static const PAUSE:String = "GuiContextEvent.PAUSE";
      
      public static const OPTIONS:String = "GuiContextEvent.OPTIONS";
       
      
      public function GuiContextEvent(param1:String, param2:Boolean = false, param3:Boolean = false)
      {
         super(param1,param2,param3);
      }
   }
}
