package engine.battle.fsm.state.turn.cmd
{
   import engine.battle.board.model.IBattleMove;
   import engine.battle.fsm.state.BattleStateTurnBase;
   import engine.battle.fsm.txn.BattleTxnMoveSend;
   
   public class BattleTurnCmdMove extends BattleTurnCmd
   {
       
      
      public var move:IBattleMove;
      
      public function BattleTurnCmdMove(param1:BattleStateTurnBase, param2:int, param3:Boolean, param4:IBattleMove)
      {
         super(param1,param2,param3);
         if(param4 != turn.move)
         {
            throw new ArgumentError("bad move");
         }
         this.move = param4;
      }
      
      override protected function handleBattleExecute() : void
      {
         var _loc1_:BattleTxnMoveSend = null;
         if(Boolean(turn.entity.playerControlled) && battleFsm.isOnline)
         {
            _loc1_ = new BattleTxnMoveSend(battleFsm.battleId,turn.number,this.move,ordinal,battleFsm.session.credentials,null,battleFsm,logger);
            _loc1_.send(battleFsm.session.communicator);
         }
         turn.entity.mobility.executeMove(this.move);
         battleComplete();
      }
   }
}
