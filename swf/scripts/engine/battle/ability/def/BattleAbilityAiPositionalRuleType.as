package engine.battle.ability.def
{
   import engine.core.util.Enum;
   
   public class BattleAbilityAiPositionalRuleType extends Enum
   {
      
      public static const NONE:BattleAbilityAiPositionalRuleType = new BattleAbilityAiPositionalRuleType("NONE",enumCtorKey);
      
      public static const HIGHEST_ENEMY_THREAT:BattleAbilityAiPositionalRuleType = new BattleAbilityAiPositionalRuleType("HIGHEST_ENEMY_THREAT",enumCtorKey);
      
      public static const AOE_DAMAGE_ALL:BattleAbilityAiPositionalRuleType = new BattleAbilityAiPositionalRuleType("AOE_DAMAGE_ALL",enumCtorKey);
      
      public static const LOWEST_ENEMY_THREAT:BattleAbilityAiPositionalRuleType = new BattleAbilityAiPositionalRuleType("LOWEST_ENEMY_THREAT",enumCtorKey);
      
      public static const BACK_OFF:BattleAbilityAiPositionalRuleType = new BattleAbilityAiPositionalRuleType("BACK_OFF",enumCtorKey);
       
      
      public function BattleAbilityAiPositionalRuleType(param1:String, param2:Object)
      {
         super(param1,param2);
      }
   }
}
