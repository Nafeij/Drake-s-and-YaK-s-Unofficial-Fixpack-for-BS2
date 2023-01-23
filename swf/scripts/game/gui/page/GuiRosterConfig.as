package game.gui.page
{
   import flash.events.Event;
   import flash.events.EventDispatcher;
   
   public class GuiRosterConfig extends EventDispatcher
   {
      
      public static const EVENT_CHANGED:String = "GuiRosterConfig.EVENT_CHANGED";
       
      
      public var disabled:Boolean = false;
      
      public var partyClickSlot:int = -1;
      
      public var allowCharacterDetails:Boolean = false;
      
      public var allowScrolling:Boolean = true;
      
      public var allowExpandBarracks:Boolean = true;
      
      public var allowReady:Boolean = false;
      
      public var croppedRows:Boolean;
      
      public var enableItems:Boolean = true;
      
      public var showPower:Boolean = true;
      
      public var showLimits:Boolean = true;
      
      public var showTutorialDetails:Boolean = false;
      
      public var shownTutorialDetails:Boolean = false;
      
      public function GuiRosterConfig()
      {
         super();
      }
      
      public function notify() : void
      {
         dispatchEvent(new Event(EVENT_CHANGED));
      }
      
      public function reset() : void
      {
         this.croppedRows = false;
         this.allowReady = false;
         this.allowExpandBarracks = true;
         this.allowScrolling = true;
         this.disabled = false;
         this.allowCharacterDetails = false;
         this.enableItems = true;
         this.showPower = true;
         this.showLimits = true;
         this.showTutorialDetails = false;
         this.partyClickSlot = -1;
         this.notify();
      }
   }
}
