package engine.battle.fsm
{
   import flash.events.Event;
   
   public class BattleFsmEvent extends Event
   {
      
      public static const DEPLOY:String = "BattleFsmEvent.DEPLOY";
      
      public static const TURN:String = "BattleFsmEvent.TURN";
      
      public static const TURN_COMMITTED:String = "BattleFsmEvent.TURN_COMMITTED";
      
      public static const TURN_COMPLETE:String = "BattleFsmEvent.TURN_COMPLETE";
      
      public static const INTERACT:String = "BattleFsmEvent.INTERACT";
      
      public static const TURN_ATTACK:String = "BattleFsmEvent.TURN_ATTACK";
      
      public static const TURN_ABILITY:String = "BattleFsmEvent.TURN_ABILITY";
      
      public static const TURN_ABILITY_TARGETS:String = "BattleFsmEvent.TURN_ABILITY_TARGETS";
      
      public static const TURN_IN_RANGE:String = "BattleFsmEvent.TURN_IN_RANGE";
      
      public static const TURN_ENTITY_INCOMPLETE_EFFECTS_COMPLETE:String = "BattleFsmEvent.TURN_ENTITY_INCOMPLETE_EFFECTS_COMPLETE";
      
      public static const PLAYER_EXIT:String = "BattleFsmEvent.PLAYER_EXIT";
      
      public static const TURN_MOVE_COMMITTED:String = "BattleFsmEvent.TURN_MOVE_COMMITTED";
      
      public static const TURN_MOVE_EXECUTED:String = "BattleFsmEvent.TURN_MOVE_EXECUTED";
      
      public static const TURN_MOVE_INTERRUPTED:String = "BattleFsmEvent.TURN_MOVE_INTERRUPTED";
      
      public static const TURN_ABILITY_EXECUTING:String = "BattleFsmEvent.TURN_ABILITY_EXECUTING";
      
      public static const BATTLE_RESPAWN:String = "BattleFsmEvent.BATTLE_RESPAWN";
      
      public static const KILLS:String = "BattleFsmEvent.KILLS";
      
      public static const FIRST_STRIKE:String = "BattleFsmEvent.FIRST_STRIKE";
      
      public static const PILLAGE:String = "BattleFsmEvent.PILLAGE";
      
      public static const BATTLE_FINISHED:String = "BattleFsmEvent.BATTLE_FINISHED";
      
      public static const WAVE_RESPITE:String = "BattleFsmEvent.WAVE_RESPITE";
      
      public static const WAVE_ENEMY_REINFORCEMENTS:String = "BattleFsmEvent.WAVE_ENEMY_REINFORCEMENTS";
      
      public static const WAVE_RESPAWN_COMPLETED:String = "BattleFsmEvent.WAVE_RESPAWN_COMPLETED";
       
      
      public function BattleFsmEvent(param1:String)
      {
         super(param1);
      }
   }
}
