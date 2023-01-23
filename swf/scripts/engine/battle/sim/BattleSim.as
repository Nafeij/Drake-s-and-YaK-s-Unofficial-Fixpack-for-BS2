package engine.battle.sim
{
   import engine.battle.board.model.BattleBoard;
   import engine.battle.fsm.BattleFsm;
   
   public class BattleSim
   {
       
      
      public var board:BattleBoard;
      
      public var started:Boolean;
      
      public var fsm:BattleFsm;
      
      public function BattleSim(param1:BattleBoard, param2:BattleFsm)
      {
         super();
         this.board = param1;
         this.fsm = param2;
      }
      
      public function cleanup() : void
      {
         this.board = null;
      }
   }
}
