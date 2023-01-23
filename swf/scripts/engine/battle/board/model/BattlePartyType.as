package engine.battle.board.model
{
   import engine.core.util.Enum;
   
   public class BattlePartyType extends Enum
   {
      
      public static const LOCAL:BattlePartyType = new BattlePartyType("LOCAL",enumCtorKey);
      
      public static const REMOTE:BattlePartyType = new BattlePartyType("REMOTE",enumCtorKey);
      
      public static const AI:BattlePartyType = new BattlePartyType("AI",enumCtorKey);
       
      
      public function BattlePartyType(param1:String, param2:Object)
      {
         super(param1,param2);
      }
   }
}
