package engine.battle.ability.def
{
   import engine.core.util.Enum;
   
   public class BattleAbilityAiUseRuleType extends Enum
   {
      
      public static const NONE:BattleAbilityAiUseRuleType = new BattleAbilityAiUseRuleType("NONE",enumCtorKey);
      
      public static const STR_LE_HALF:BattleAbilityAiUseRuleType = new BattleAbilityAiUseRuleType("STR_LE_HALF",enumCtorKey);
      
      public static const ALLIES_NEAR_ENEMIES:BattleAbilityAiUseRuleType = new BattleAbilityAiUseRuleType("ALLIES_NEAR_ENEMIES",enumCtorKey);
       
      
      public function BattleAbilityAiUseRuleType(param1:String, param2:Object)
      {
         super(param1,param2);
      }
   }
}
