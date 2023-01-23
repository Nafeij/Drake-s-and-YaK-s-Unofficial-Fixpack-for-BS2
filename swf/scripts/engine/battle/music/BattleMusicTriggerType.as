package engine.battle.music
{
   import engine.core.util.Enum;
   
   public class BattleMusicTriggerType extends Enum
   {
      
      public static var TRAUMA_UP:BattleMusicTriggerType = new BattleMusicTriggerType("TRAUMA_UP",enumCtorKey);
      
      public static var WIN:BattleMusicTriggerType = new BattleMusicTriggerType("WIN",enumCtorKey);
      
      public static var LOSE:BattleMusicTriggerType = new BattleMusicTriggerType("LOSE",enumCtorKey);
      
      public static var RESPAWN:BattleMusicTriggerType = new BattleMusicTriggerType("RESPAWN",enumCtorKey);
      
      public static var PILLAGE:BattleMusicTriggerType = new BattleMusicTriggerType("PILLAGE",enumCtorKey);
      
      public static var WAVE:BattleMusicTriggerType = new BattleMusicTriggerType("WAVE",enumCtorKey);
       
      
      public function BattleMusicTriggerType(param1:String, param2:Object)
      {
         super(param1,param2);
      }
   }
}
