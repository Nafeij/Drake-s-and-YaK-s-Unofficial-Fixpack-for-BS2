package engine.battle.ability.def
{
   import engine.core.util.Enum;
   
   public class BattleAbilityResponseTargetType extends Enum
   {
      
      public static const SELF:BattleAbilityResponseTargetType = new BattleAbilityResponseTargetType("SELF",enumCtorKey);
      
      public static const CASTER:BattleAbilityResponseTargetType = new BattleAbilityResponseTargetType("CASTER",enumCtorKey);
      
      public static const TARGET:BattleAbilityResponseTargetType = new BattleAbilityResponseTargetType("TARGET",enumCtorKey);
      
      public static const OTHER:BattleAbilityResponseTargetType = new BattleAbilityResponseTargetType("OTHER",enumCtorKey);
      
      public static const RANDOM:BattleAbilityResponseTargetType = new BattleAbilityResponseTargetType("RANDOM",enumCtorKey);
      
      public static const ALL_ALLIES:BattleAbilityResponseTargetType = new BattleAbilityResponseTargetType("ALL_ALLIES",enumCtorKey);
      
      public static const ALL_ENEMIES:BattleAbilityResponseTargetType = new BattleAbilityResponseTargetType("ALL_ENEMIES",enumCtorKey);
      
      public static const TRIGGER_CASTER:BattleAbilityResponseTargetType = new BattleAbilityResponseTargetType("TRIGGER_CASTER",enumCtorKey);
      
      public static const TRIGGER_TARGET:BattleAbilityResponseTargetType = new BattleAbilityResponseTargetType("TRIGGER_TARGET",enumCtorKey);
      
      public static const ORIGIN_CASTER:BattleAbilityResponseTargetType = new BattleAbilityResponseTargetType("ORIGIN_CASTER",enumCtorKey);
      
      public static const ORIGIN_TARGET:BattleAbilityResponseTargetType = new BattleAbilityResponseTargetType("ORIGIN_TARGET",enumCtorKey);
      
      public static const NONE:BattleAbilityResponseTargetType = new BattleAbilityResponseTargetType("NONE",enumCtorKey);
       
      
      public function BattleAbilityResponseTargetType(param1:String, param2:*)
      {
         super(param1,param2);
      }
   }
}
