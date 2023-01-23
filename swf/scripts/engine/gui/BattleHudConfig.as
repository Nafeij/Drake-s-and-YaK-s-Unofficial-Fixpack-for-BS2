package engine.gui
{
   import engine.saga.Saga;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   
   public class BattleHudConfig extends EventDispatcher
   {
      
      public static const EVENT_CHANGED:String = "BattleHudConfig.EVENT_CHANGED";
      
      public static var instance:BattleHudConfig;
       
      
      public var showHorn:Boolean = true;
      
      public var showChat:Boolean = true;
      
      public var escape:Boolean = true;
      
      public var keyboard:Boolean = true;
      
      public var chat:Boolean = true;
      
      public var horn:Boolean = true;
      
      public var initiative:Boolean = true;
      
      public var options:Boolean = true;
      
      public var selfPopup:Boolean = true;
      
      public var selfPopupSpecial:Boolean = true;
      
      public var selfPopupMove:Boolean = true;
      
      public var selfPopupWangler:Boolean = true;
      
      public var selfPopupAttack:Boolean = true;
      
      public var selfPopupEnd:Boolean = true;
      
      public var enemyPopup:Boolean = true;
      
      public var propPopup:Boolean = true;
      
      public var enemyPopupStrength:Boolean = true;
      
      public var enemyPopupWangler:Boolean = true;
      
      public var enemyPopupArmor:Boolean = true;
      
      public var enemyPopupStars:Boolean = true;
      
      public var enemyPopupMinStars:int = 0;
      
      public function BattleHudConfig()
      {
         super();
         instance = this;
      }
      
      public function notify() : void
      {
         dispatchEvent(new Event(EVENT_CHANGED));
      }
      
      public function reset(param1:Boolean = true) : void
      {
         this.escape = true;
         var _loc2_:Saga = Saga.instance;
         this.showHorn = !_loc2_ || _loc2_.hudHornEnabled;
         this.showChat = true;
         this.chat = true;
         this.horn = true;
         this.initiative = true;
         this.options = true;
         this.selfPopup = true;
         this.selfPopupSpecial = true;
         this.selfPopupMove = true;
         this.selfPopupAttack = true;
         this.selfPopupEnd = true;
         this.enemyPopup = true;
         this.enemyPopupStrength = true;
         this.enemyPopupArmor = true;
         this.enemyPopupStars = true;
         this.selfPopupWangler = true;
         this.enemyPopupWangler = true;
         this.enemyPopupMinStars = 0;
         this.keyboard = true;
         if(param1)
         {
            this.notify();
         }
      }
   }
}
