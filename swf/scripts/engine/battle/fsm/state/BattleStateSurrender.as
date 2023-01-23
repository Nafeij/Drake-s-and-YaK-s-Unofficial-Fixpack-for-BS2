package engine.battle.fsm.state
{
   import engine.battle.fsm.BattleFsm;
   import engine.battle.fsm.BattleStateDataEnum;
   import engine.battle.fsm.txn.BattleTxnSurrenderSend;
   import engine.battle.sim.IBattleParty;
   import engine.core.fsm.StateData;
   import engine.core.fsm.StatePhase;
   import engine.core.logging.ILogger;
   
   public class BattleStateSurrender extends BaseBattleState
   {
       
      
      public function BattleStateSurrender(param1:StateData, param2:BattleFsm, param3:ILogger, param4:int = 0)
      {
         super(param1,param2,param3,param4);
      }
      
      override protected function handleEnteredState() : void
      {
         var _loc2_:BattleTxnSurrenderSend = null;
         super.handleEnteredState();
         var _loc1_:IBattleParty = battleFsm.board.getPartyById(battleFsm.session.credentials.userId.toString());
         _loc1_.surrendered = true;
         if(battleFsm.isOnline)
         {
            _loc2_ = new BattleTxnSurrenderSend(battleFsm.battleId,battleFsm.session.credentials,this.surrenderSendHandler,battleFsm,logger);
            _loc2_.send(battleFsm.session.communicator);
         }
         else
         {
            this.doFinish();
         }
      }
      
      private function doFinish() : void
      {
         var _loc2_:IBattleParty = null;
         var _loc1_:int = 0;
         while(_loc1_ < battleFsm.board.numParties)
         {
            _loc2_ = battleFsm.board.getParty(_loc1_);
            if(_loc2_.isEnemy)
            {
               logger.info("BattleStateSurrender.doFinish VICTORIOUS_TEAM=" + _loc2_.team);
               data.setValue(BattleStateDataEnum.VICTORIOUS_TEAM,_loc2_.team);
               break;
            }
            _loc1_++;
         }
         battleFsm.battleFinished = true;
         phase = StatePhase.COMPLETED;
      }
      
      private function surrenderSendHandler(param1:BattleTxnSurrenderSend) : void
      {
         if(param1.success)
         {
            this.doFinish();
         }
      }
   }
}
