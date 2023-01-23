package engine.battle.ability.def
{
   import engine.core.util.Enum;
   
   public class BattleAbilityTargetRotationRule extends Enum
   {
      
      public static const NONE:BattleAbilityTargetRotationRule = new BattleAbilityTargetRotationRule("NONE",enumCtorKey);
      
      public static const FACE_CASTER:BattleAbilityTargetRotationRule = new BattleAbilityTargetRotationRule("FACE_CASTER",enumCtorKey);
       
      
      public function BattleAbilityTargetRotationRule(param1:String, param2:Object)
      {
         super(param1,param2);
      }
   }
}
