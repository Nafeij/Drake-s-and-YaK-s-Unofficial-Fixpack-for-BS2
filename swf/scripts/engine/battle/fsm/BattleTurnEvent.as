package engine.battle.fsm
{
   import flash.events.Event;
   
   public class BattleTurnEvent extends Event
   {
      
      public static const ABILITY:String = "BattleTurnEvent.ABILITY";
      
      public static const ABILITY_EXECUTING:String = "BattleTurnEvent.ABILITY_EXECUTING";
      
      public static const ABILITY_TARGET:String = "BattleTurnEvent.ABILITY_TARGET";
      
      public static const TURN_INTERACT:String = "BattleTurnEvent.TURN_INTERACT";
      
      public static const COMPLETE:String = "BattleTurnEvent.COMPLETE";
      
      public static const COMMITTED:String = "BattleTurnEvent.COMMITTED";
      
      public static const IN_RANGE:String = "BattleTurnEvent.IN_RANGE";
      
      public static const ATTACK_MODE:String = "BattleTurnEvent.ATTACK_MODE";
       
      
      public function BattleTurnEvent(param1:String)
      {
         super(param1);
      }
   }
}
