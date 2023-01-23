package engine.battle.ability.def
{
   import engine.core.util.Enum;
   
   public class BattleAbilityMoveTag extends Enum
   {
      
      public static const NONE:BattleAbilityMoveTag = new BattleAbilityMoveTag("NONE",enumCtorKey);
      
      public static const POSSESSED_MOVE:BattleAbilityMoveTag = new BattleAbilityMoveTag("POSSESSED_MOVE",enumCtorKey);
       
      
      public function BattleAbilityMoveTag(param1:String, param2:Object)
      {
         super(param1,param2);
      }
   }
}
