package engine.saga
{
   import engine.core.util.Enum;
   
   public class SagaTriggerType extends Enum
   {
      
      public static const NONE:SagaTriggerType = new SagaTriggerType("NONE",enumCtorKey);
      
      public static const CLICK:SagaTriggerType = new SagaTriggerType("CLICK",enumCtorKey);
      
      public static const LOCATION:SagaTriggerType = new SagaTriggerType("LOCATION",enumCtorKey);
      
      public static const VARIABLE_THRESHOLD:SagaTriggerType = new SagaTriggerType("VARIABLE_TRESHOLD",enumCtorKey);
      
      public static const VARIABLE_THRESHOLD_UP:SagaTriggerType = new SagaTriggerType("VARIABLE_THRESHOLD_UP",enumCtorKey);
      
      public static const VARIABLE_THRESHOLD_DOWN:SagaTriggerType = new SagaTriggerType("VARIABLE_THRESHOLD_DOWN",enumCtorKey);
      
      public static const VARIABLE_INCREMENT:SagaTriggerType = new SagaTriggerType("VARIABLE_INCREMENT",enumCtorKey);
      
      public static const DEPLOYED:SagaTriggerType = new SagaTriggerType("DEPLOYED",enumCtorKey);
      
      public static const TALK:SagaTriggerType = new SagaTriggerType("TALK",enumCtorKey);
      
      public static const MAP_CAMP_ENTER:SagaTriggerType = new SagaTriggerType("MAP_CAMP_ENTER",enumCtorKey);
      
      public static const MAP_CAMP_EXIT:SagaTriggerType = new SagaTriggerType("MAP_CAMP_EXIT",enumCtorKey);
      
      public static const BATTLE_ALLY_KILLED:SagaTriggerType = new SagaTriggerType("BATTLE_ALLY_KILLED",enumCtorKey);
      
      public static const BATTLE_ENEMY_KILLED:SagaTriggerType = new SagaTriggerType("BATTLE_ENEMY_KILLED",enumCtorKey);
      
      public static const BATTLE_OTHER_KILLED:SagaTriggerType = new SagaTriggerType("BATTLE_OTHER_KILLED",enumCtorKey);
      
      public static const BATTLE_ABILITY_COMPLETED:SagaTriggerType = new SagaTriggerType("BATTLE_ABILITY_COMPLETED",enumCtorKey);
      
      public static const BATTLE_ABILITY_EXECUTED:SagaTriggerType = new SagaTriggerType("BATTLE_ABILITY_EXECUTED",enumCtorKey);
      
      public static const BATTLE_TURN:SagaTriggerType = new SagaTriggerType("BATTLE_TURN",enumCtorKey);
      
      public static const BATTLE_WIN:SagaTriggerType = new SagaTriggerType("BATTLE_WIN",enumCtorKey);
      
      public static const BATTLE_FINISHING_WIN:SagaTriggerType = new SagaTriggerType("BATTLE_FINISHING_WIN",enumCtorKey);
      
      public static const BATTLE_FINISHING_LOSE:SagaTriggerType = new SagaTriggerType("BATTLE_FINISHING_LOSE",enumCtorKey);
      
      public static const BATTLE_LOSE:SagaTriggerType = new SagaTriggerType("BATTLE_LOSE",enumCtorKey);
      
      public static const BATTLE_NEXT_TURN_BEGIN:SagaTriggerType = new SagaTriggerType("BATTLE_NEXT_TURN_BEGIN",enumCtorKey);
      
      public static const BATTLE_REMAINING_PLAYERS:SagaTriggerType = new SagaTriggerType("BATTLE_REMAINING_PLAYERS",enumCtorKey);
      
      public static const BATTLE_REMAINING_ENEMIES:SagaTriggerType = new SagaTriggerType("BATTLE_REMAINING_ENEMIES",enumCtorKey);
      
      public static const BATTLE_KILL_STOP:SagaTriggerType = new SagaTriggerType("BATTLE_KILL_STOP",enumCtorKey);
      
      public static const BATTLE_IMMORTAL_STOPPED:SagaTriggerType = new SagaTriggerType("BATTLE_IMMORTAL_STOPPED",enumCtorKey);
      
      public static const BATTLE_UNIT_REMOVED:SagaTriggerType = new SagaTriggerType("BATTLE_UNIT_REMOVED",enumCtorKey);
      
      public static const BATTLE_WAVE_SPAWNED:SagaTriggerType = new SagaTriggerType("BATTLE_WAVE_SPAWNED",enumCtorKey);
      
      public static const BATTLE_WAVE_LOW_TURN_WARNING:SagaTriggerType = new SagaTriggerType("BATTLE_WAVE_LOW_TURN_WARNING",enumCtorKey);
      
      public static const BATTLE_NO_ENEMIES_REMAIN_PRE_VICTORY:SagaTriggerType = new SagaTriggerType("BATTLE_NO_ENEMIES_REMAIN_PRE_VICTORY",enumCtorKey);
       
      
      public function SagaTriggerType(param1:String, param2:Object)
      {
         super(param1,param2);
      }
   }
}
