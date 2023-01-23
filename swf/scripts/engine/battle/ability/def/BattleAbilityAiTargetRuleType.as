package engine.battle.ability.def
{
   import engine.core.util.Enum;
   
   public class BattleAbilityAiTargetRuleType extends Enum
   {
      
      public static const NONE:BattleAbilityAiTargetRuleType = new BattleAbilityAiTargetRuleType("NONE",enumCtorKey);
      
      public static const TILE_MAX_ADJACENT_ENEMY:BattleAbilityAiTargetRuleType = new BattleAbilityAiTargetRuleType("TILE_MAX_ADJACENT_ENEMY",enumCtorKey);
      
      public static const TILESPRAY_ENEMIES:BattleAbilityAiTargetRuleType = new BattleAbilityAiTargetRuleType("TILESPRAY_ENEMIES",enumCtorKey);
      
      public static const WILLPOWER_DOMINANCE:BattleAbilityAiTargetRuleType = new BattleAbilityAiTargetRuleType("WILLPOWER_DOMINANCE",enumCtorKey);
       
      
      public function BattleAbilityAiTargetRuleType(param1:String, param2:Object)
      {
         super(param1,param2);
      }
   }
}
