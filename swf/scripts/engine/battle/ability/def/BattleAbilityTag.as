package engine.battle.ability.def
{
   import engine.core.util.Enum;
   
   public class BattleAbilityTag extends Enum
   {
      
      public static const ATTACK_STR:BattleAbilityTag = new BattleAbilityTag("ATTACK_STR",enumCtorKey);
      
      public static const ATTACK_ARM:BattleAbilityTag = new BattleAbilityTag("ATTACK_ARM",enumCtorKey);
      
      public static const SPECIAL:BattleAbilityTag = new BattleAbilityTag("SPECIAL",enumCtorKey);
      
      public static const SPECIAL_NOCOST:BattleAbilityTag = new BattleAbilityTag("SPECIAL_NOCOST",enumCtorKey);
      
      public static const PASSIVE:BattleAbilityTag = new BattleAbilityTag("PASSIVE",enumCtorKey);
      
      public static const END:BattleAbilityTag = new BattleAbilityTag("END",enumCtorKey);
       
      
      public function BattleAbilityTag(param1:String, param2:Object)
      {
         super(param1,param2);
      }
   }
}
