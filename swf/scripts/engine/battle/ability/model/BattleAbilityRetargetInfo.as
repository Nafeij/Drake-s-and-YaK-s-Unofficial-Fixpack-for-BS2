package engine.battle.ability.model
{
   import engine.battle.board.model.IBattleEntity;
   
   public class BattleAbilityRetargetInfo
   {
       
      
      public var target:IBattleEntity;
      
      public var insert:IBattleAbility;
      
      public function BattleAbilityRetargetInfo(param1:IBattleEntity, param2:IBattleAbility)
      {
         super();
         this.target = param1;
         this.insert = param2;
      }
      
      public function toString() : String
      {
         return "[" + this.target + " " + this.insert + "]";
      }
   }
}
