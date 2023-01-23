package engine.battle.ability.def
{
   import engine.core.util.Enum;
   
   public class BattleAbilityRotationRule extends Enum
   {
      
      public static const NONE:BattleAbilityRotationRule = new BattleAbilityRotationRule("NONE",enumCtorKey);
      
      public static const FIRST_TARGET:BattleAbilityRotationRule = new BattleAbilityRotationRule("FIRST_TARGET",enumCtorKey);
      
      public static const ALL_TARGETS:BattleAbilityRotationRule = new BattleAbilityRotationRule("ALL_TARGETS",enumCtorKey);
       
      
      public function BattleAbilityRotationRule(param1:String, param2:Object)
      {
         super(param1,param2);
      }
   }
}
