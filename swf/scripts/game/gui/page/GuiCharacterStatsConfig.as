package game.gui.page
{
   import flash.events.Event;
   import flash.events.EventDispatcher;
   
   public class GuiCharacterStatsConfig extends EventDispatcher
   {
      
      public static const EVENT_CHANGED:String = "GuiCharacterStatsConfig.EVENT_CHANGED";
       
      
      public var disabled:Boolean = false;
      
      public var bio:GuiBioConfig;
      
      public function GuiCharacterStatsConfig()
      {
         this.bio = new GuiBioConfig();
         super();
      }
      
      public function notify() : void
      {
         dispatchEvent(new Event(EVENT_CHANGED));
      }
      
      public function reset() : void
      {
         this.disabled = false;
         this.notify();
      }
   }
}
