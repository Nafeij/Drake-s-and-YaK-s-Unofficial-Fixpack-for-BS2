package game.gui.page
{
   import flash.events.Event;
   import flash.events.EventDispatcher;
   
   public class GuiMeadHouseConfig extends EventDispatcher
   {
      
      public static const EVENT_CHANGED:String = "GuiMeadHouseConfig.EVENT_CHANGED";
       
      
      public var show_unit_id:String;
      
      public var disabled:Boolean = false;
      
      public var allow_hire:Boolean = true;
      
      public var allow_proving_grounds:Boolean = true;
      
      public var fake_hire:Boolean = false;
      
      public function GuiMeadHouseConfig()
      {
         super();
      }
      
      public function notify() : void
      {
         dispatchEvent(new Event(EVENT_CHANGED));
      }
   }
}
