package engine.battle.ability.def
{
   import engine.core.util.Enum;
   
   public class BattleAbilityKilledFacingReponseRule extends Enum
   {
      
      public static const NONE:BattleAbilityKilledFacingReponseRule = new BattleAbilityKilledFacingReponseRule("NONE",enumCtorKey);
      
      public static const FACE_KILLER:BattleAbilityKilledFacingReponseRule = new BattleAbilityKilledFacingReponseRule("FACE_KILLER",enumCtorKey);
      
      public static const FACE_AWAY_FROM_KILLER:BattleAbilityKilledFacingReponseRule = new BattleAbilityKilledFacingReponseRule("FACE_AWAY_FROM_KILLER",enumCtorKey);
       
      
      public function BattleAbilityKilledFacingReponseRule(param1:String, param2:Object)
      {
         super(param1,param2);
      }
   }
}
