package engine.battle.board.def
{
   import flash.events.Event;
   
   public class BattleBoardTriggerSpawnersEvent extends Event
   {
      
      public static const EVENT_RECT:String = "BattleBoardTriggerSpawnersEvent.EVENT_RECT";
      
      public static const EVENT_REMOVED:String = "BattleBoardTriggerSpawnersEvent.EVENT_REMOVED";
      
      public static const EVENT_CHANGED:String = "BattleBoardTriggerSpawnersEvent.EVENT_CHANGED";
      
      public static const EVENT_ADDED:String = "BattleBoardTriggerSpawnersEvent.EVENT_ADDED";
       
      
      public var id:String;
      
      public var t:BattleBoardTriggerSpawnerDef;
      
      public function BattleBoardTriggerSpawnersEvent(param1:String, param2:BattleBoardTriggerSpawnerDef, param3:String)
      {
         super(param1);
         this.id = param3;
         this.t = param2;
      }
   }
}
