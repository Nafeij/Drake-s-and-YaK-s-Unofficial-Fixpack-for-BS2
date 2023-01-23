package engine.battle.fsm
{
   import engine.battle.board.model.IBattleEntity;
   import engine.battle.board.model.IBattleMove;
   import flash.events.Event;
   
   public class BattleMoveEvent extends Event
   {
      
      public static const MOVE_CHANGED:String = "BattleMoveEvent.MOVE_CHANGED";
      
      public static const EXECUTED:String = "BattleMoveEvent.EXECUTED";
      
      public static const WAYPOINT:String = "BattleMoveEvent.WAYPOINT";
      
      public static const COMMITTED:String = "BattleMoveEvent.COMMITTED";
      
      public static const INTERRUPTED:String = "BattleMoveEvent.INTERRUPTED";
      
      public static const EXECUTING:String = "BattleMoveEvent.EXECUTING";
      
      public static const FLOOD_CHANGED:String = "BattleMoveEvent.FLOOD_CHANGED";
      
      public static const INTERSECT_ENTITY:String = "BattleMoveEvent.INTERSECT_ENTITY";
      
      public static const SUPPRESS_COMMIT:String = "BattleMoveEvent.SUPPRESS_COMMIT";
       
      
      public var mv:IBattleMove;
      
      public var other:IBattleEntity;
      
      public function BattleMoveEvent(param1:String, param2:IBattleMove, param3:IBattleEntity)
      {
         super(param1);
         this.mv = param2;
         this.other = param3;
      }
   }
}
