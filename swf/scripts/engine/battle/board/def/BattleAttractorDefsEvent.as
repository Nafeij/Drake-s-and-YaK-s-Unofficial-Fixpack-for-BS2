package engine.battle.board.def
{
   import flash.events.Event;
   
   public class BattleAttractorDefsEvent extends Event
   {
      
      public static const EVENT_RECT:String = "BattleAttractorDefsEvent.EVENT_RECT";
      
      public static const EVENT_REMOVED:String = "BattleAttractorDefsEvent.EVENT_REMOVED";
      
      public static const EVENT_CHANGED:String = "BattleAttractorDefsEvent.EVENT_CHANGED";
      
      public static const EVENT_ADDED:String = "BattleAttractorDefsEvent.EVENT_ADDED";
       
      
      public var id:String;
      
      public var t:BattleAttractorDef;
      
      public function BattleAttractorDefsEvent(param1:String, param2:BattleAttractorDef, param3:String)
      {
         super(param1,bubbles,cancelable);
         this.id = param3;
         this.t = param2;
      }
   }
}
