package engine.battle.fsm.state
{
   import engine.battle.fsm.BattleFsm;
   import engine.battle.fsm.txn.BattleTxnStartSend;
   import engine.core.fsm.StateData;
   import engine.core.fsm.StatePhase;
   import engine.core.logging.ILogger;
   
   public class BattleStateInit extends BaseBattleState
   {
       
      
      private var localReady:Boolean;
      
      private var txnSend:BattleTxnStartSend;
      
      private var remotesReady:Boolean = false;
      
      public function BattleStateInit(param1:StateData, param2:BattleFsm, param3:ILogger)
      {
         super(param1,param2,param3,param2.config.deployTimeoutMs);
      }
      
      override protected function handleEnteredState() : void
      {
         if(logger.isDebugEnabled)
         {
            logger.debug("BattleStateInit.handleEnteredState");
         }
         battleFsm.stopEatingSubsequent("tbs.srv.battle.data.client.BattleReadyData");
         this.checkReady();
      }
      
      private function checkReady() : void
      {
         if(logger.isDebugEnabled)
         {
            logger.debug("BattleStateInit.checkReady localReady=" + this.localReady + " phase=" + phase);
         }
         if(this.localReady && phase == StatePhase.ENTERED)
         {
            if(battleFsm.isOnline)
            {
               if(!this.txnSend)
               {
                  if(logger.isDebugEnabled)
                  {
                     logger.debug("BattleStateInit LOCAL READY: " + battleFsm.battleId);
                  }
                  this.txnSend = new BattleTxnStartSend(battleFsm.battleId,battleFsm.session.credentials,this.sendHandler,battleFsm,logger);
                  addTxn(this.txnSend);
                  this.txnSend.send(battleFsm.session.communicator,null,0);
                  this.checkComplete();
               }
            }
            else
            {
               phase = StatePhase.COMPLETED;
            }
         }
      }
      
      public function setReady() : void
      {
         logger.info("BattleStateInit.setReady");
         this.localReady = true;
         this.checkReady();
      }
      
      override protected function handleCleanup() : void
      {
         super.handleCleanup();
         battleFsm.eatAllSubsequent("tbs.srv.battle.data.client.BattleReadyData");
      }
      
      private function sendHandler(param1:BattleTxnStartSend) : void
      {
         if(param1.success)
         {
            this.checkComplete();
         }
      }
      
      override public function handleMessage(param1:Object) : Boolean
      {
         if(param1["class"] == "tbs.srv.battle.data.client.BattleReadyData")
         {
            logger.info("BattleStateInit REMOTE READY: " + param1.user_id);
            this.remotesReady = true;
            this.checkComplete();
            return true;
         }
         return false;
      }
      
      public function checkComplete() : void
      {
         if(logger.isDebugEnabled)
         {
            logger.debug("BattleStateInit.checkComplete remotesReady=" + this.remotesReady + " localReady=" + this.localReady + " + txnSend=" + this.txnSend + " txnSend.success=" + (!!this.txnSend ? this.txnSend.success : "<>"));
         }
         if(this.remotesReady && this.localReady && this.txnSend && this.txnSend.success)
         {
            phase = StatePhase.COMPLETED;
         }
      }
   }
}
