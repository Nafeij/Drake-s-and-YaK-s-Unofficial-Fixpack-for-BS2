package game.gui.page
{
   import flash.events.Event;
   import flash.events.EventDispatcher;
   
   public class GuiPromotionConfig extends EventDispatcher
   {
      
      public static const EVENT_CHANGED:String = "GuiPromotionConfig.EVENT_CHANGED";
       
      
      public var disabled:Boolean = false;
      
      public var allowConfirm:Boolean = false;
      
      public var variationIndex:int = 0;
      
      public var allowVariation:Boolean = false;
      
      public var allowAccept:Boolean = false;
      
      public var enableName:Boolean = false;
      
      public var enableVariation:Boolean = false;
      
      public function GuiPromotionConfig()
      {
         super();
      }
      
      public function notify() : void
      {
         dispatchEvent(new Event(EVENT_CHANGED));
      }
      
      public function reset() : void
      {
         this.variationIndex = 0;
         this.disabled = false;
         this.allowConfirm = false;
         this.allowAccept = false;
         this.allowVariation = false;
         this.enableName = false;
         this.enableVariation = false;
         this.notify();
      }
   }
}
