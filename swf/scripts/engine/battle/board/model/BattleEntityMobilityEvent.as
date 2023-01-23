package engine.battle.board.model
{
   import flash.events.Event;
   
   public class BattleEntityMobilityEvent extends Event
   {
      
      public static const MOVING:String = "BattleEntityEvent.MOVING";
       
      
      public function BattleEntityMobilityEvent(param1:String)
      {
         super(param1);
      }
   }
}
