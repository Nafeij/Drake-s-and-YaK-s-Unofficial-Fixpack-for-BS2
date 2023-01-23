package engine.battle.ability.model
{
   import engine.core.util.Enum;
   
   public class BattleAbilityResponsePhase extends Enum
   {
      
      public static const PRE_COMPLETE:BattleAbilityResponsePhase = new BattleAbilityResponsePhase("PRE_COMPLETE",enumCtorKey);
      
      public static const POST_COMPLETE:BattleAbilityResponsePhase = new BattleAbilityResponsePhase("POST_COMPLETE",enumCtorKey);
      
      public static const POST_CHILDREN_COMPLETE:BattleAbilityResponsePhase = new BattleAbilityResponsePhase("POST_CHILDREN_COMPLETE",enumCtorKey);
       
      
      public function BattleAbilityResponsePhase(param1:String, param2:*)
      {
         super(param1,param2);
      }
   }
}
