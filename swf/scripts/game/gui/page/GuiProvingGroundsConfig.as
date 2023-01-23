package game.gui.page
{
   import flash.events.Event;
   import flash.events.EventDispatcher;
   
   public class GuiProvingGroundsConfig extends EventDispatcher
   {
      
      public static const EVENT_CHANGED:String = "GuiProvingGroundsConfig.EVENT_CHANGED";
       
      
      public var titleText:String;
      
      public var allowRenown:Boolean = true;
      
      public var enableRenown:Boolean = true;
      
      public var allowExit:Boolean = true;
      
      public var allowDetails:Boolean = true;
      
      public var promotion:GuiPromotionConfig;
      
      public var roster:GuiRosterConfig;
      
      public var characterStats:GuiCharacterStatsConfig;
      
      public var disabled:Boolean = false;
      
      public var allowQuestionMark:Boolean = false;
      
      public var allowPromotion:Boolean = false;
      
      public var isSaga:Boolean;
      
      public function GuiProvingGroundsConfig()
      {
         this.promotion = new GuiPromotionConfig();
         this.roster = new GuiRosterConfig();
         this.characterStats = new GuiCharacterStatsConfig();
         super();
      }
      
      public function notify() : void
      {
         dispatchEvent(new Event(EVENT_CHANGED));
      }
      
      public function reset() : void
      {
         this.promotion.reset();
         this.roster.reset();
         this.characterStats.reset();
         this.allowQuestionMark = false;
         this.enableRenown = true;
         this.disabled = false;
         this.allowPromotion = false;
         this.isSaga = false;
         this.notify();
      }
   }
}
