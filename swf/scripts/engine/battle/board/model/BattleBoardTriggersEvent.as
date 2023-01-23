package engine.battle.board.model
{
   import flash.events.Event;
   
   public class BattleBoardTriggersEvent extends Event
   {
      
      public static const ADDED:String = "BattleBoardTriggerEvent.ADDED";
      
      public static const REMOVED:String = "BattleBoardTriggerEvent.REMOVED";
      
      public static const ENABLED:String = "BattleBoardTriggerEvent.ENABLED";
       
      
      public var trigger:IBattleBoardTrigger;
      
      public function BattleBoardTriggersEvent(param1:String, param2:IBattleBoardTrigger)
      {
         super(param1);
         this.trigger = param2;
      }
   }
}
