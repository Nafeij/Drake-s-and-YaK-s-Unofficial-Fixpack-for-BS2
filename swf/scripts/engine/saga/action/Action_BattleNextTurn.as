package engine.saga.action
{
   import engine.battle.board.model.IBattleBoard;
   import engine.battle.board.model.IBattleEntity;
   import engine.battle.fsm.IBattleFsm;
   import engine.battle.fsm.IBattleTurn;
   import engine.battle.fsm.state.turn.cmd.BattleTurnCmdAction;
   import engine.saga.Saga;
   
   public class Action_BattleNextTurn extends Action
   {
       
      
      public function Action_BattleNextTurn(param1:ActionDef, param2:Saga)
      {
         super(param1,param2);
      }
      
      override protected function handleStarted() : void
      {
         var _loc2_:IBattleFsm = null;
         var _loc3_:IBattleTurn = null;
         var _loc4_:IBattleEntity = null;
         BattleTurnCmdAction.SUPPRESS_TURN_END = false;
         var _loc1_:IBattleBoard = saga.getBattleBoard();
         if(_loc1_)
         {
            _loc2_ = _loc1_.fsm;
            _loc3_ = !!_loc2_ ? _loc2_.turn : null;
            _loc4_ = !!_loc3_ ? _loc3_.entity : null;
            if(_loc4_)
            {
               _loc4_.endTurn(true,"Action_BattleNextTurn " + this,true);
            }
            else
            {
               logger.info("No active unit for " + this);
               _loc2_.skipTurn(this.toString(),true);
            }
         }
         else
         {
            logger.info("No battle board for " + this);
         }
         end();
      }
   }
}
