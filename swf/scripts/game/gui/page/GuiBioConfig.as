package game.gui.page
{
   import flash.events.Event;
   import flash.events.EventDispatcher;
   
   public class GuiBioConfig extends EventDispatcher
   {
      
      public static const EVENT_CHANGED:String = "GuiBioConfig.EVENT_CHANGED";
       
      
      public var showColor:Boolean = true;
      
      public var showRename:Boolean = true;
      
      public var showDismiss:Boolean = true;
      
      public var showServiceDays:Boolean = true;
      
      public var showBattles:Boolean = true;
      
      public function GuiBioConfig()
      {
         super();
      }
      
      public function notify() : void
      {
         dispatchEvent(new Event(EVENT_CHANGED));
      }
      
      public function reset() : void
      {
         this.showColor = true;
         this.showRename = true;
         this.showDismiss = true;
         this.showServiceDays = true;
         this.showBattles = true;
         this.notify();
      }
   }
}
