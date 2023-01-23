package engine.battle.fsm
{
   import engine.core.fsm.StateDataEnum;
   
   public class BattleStateDataEnum extends StateDataEnum
   {
      
      public static const BOARD:BattleStateDataEnum = new BattleStateDataEnum("BOARD",enumCtorKey);
      
      public static const ERROR:BattleStateDataEnum = new BattleStateDataEnum("ERROR",enumCtorKey);
      
      public static const FINISHED:BattleStateDataEnum = new BattleStateDataEnum("FINISHED",enumCtorKey);
      
      public static const VICTORIOUS_TEAM:BattleStateDataEnum = new BattleStateDataEnum("VICTORIOUS_TEAM",enumCtorKey);
      
      public static const BATTLE_RESPAWN_QUOTA:BattleStateDataEnum = new BattleStateDataEnum("BATTLE_RESPAWN_QUOTA",enumCtorKey);
      
      public static const BATTLE_RESPAWN_TAG:BattleStateDataEnum = new BattleStateDataEnum("BATTLE_RESPAWN_TAG",enumCtorKey);
      
      public static const BATTLE_RESPAWN_DEPLOYMENT:BattleStateDataEnum = new BattleStateDataEnum("BATTLE_RESPAWN_DEPLOYMENT",enumCtorKey);
      
      public static const BATTLE_RESPAWN_BUCKET:BattleStateDataEnum = new BattleStateDataEnum("BATTLE_RESPAWN_BUCKET",enumCtorKey);
      
      public static const BATTLE_WAVE_DEPLOYMENT_ID:BattleStateDataEnum = new BattleStateDataEnum("BATTLE_WAVE_DEPLOYMENT_ID",enumCtorKey);
      
      public static const BATTLE_WAVE_RESPAWN_DEPLOYMENT_ID:BattleStateDataEnum = new BattleStateDataEnum("BATTLE_WAVE_RESPAWN_DEPLOYMENT_ID",enumCtorKey);
      
      public static const BATTLE_WAVE_PREVIOUS_WAVE_PARTY:BattleStateDataEnum = new BattleStateDataEnum("BATTLE_WAVE_RESPAWN_DEPLOYMENT_ID",enumCtorKey);
       
      
      public function BattleStateDataEnum(param1:String, param2:Object)
      {
         super(param1,param2);
      }
   }
}
