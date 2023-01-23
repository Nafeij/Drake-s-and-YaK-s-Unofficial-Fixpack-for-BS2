package engine.battle.ai.strat
{
   import engine.battle.ability.def.IBattleAbilityDef;
   import engine.battle.board.model.IBattleMove;
   
   public class AiStrat
   {
       
      
      public var weight:int = 0;
      
      public var mv:IBattleMove;
      
      public var abl:IBattleAbilityDef;
      
      public function AiStrat()
      {
         super();
      }
      
      public static function compare(param1:AiStrat, param2:AiStrat) : int
      {
         return param2.weight - param1.weight;
      }
      
      public function cleanup() : void
      {
      }
   }
}
