package engine.battle.fsm.state
{
   import engine.battle.ability.model.BattleAbility;
   import engine.battle.ability.model.BattleAbilityVars;
   import engine.battle.fsm.BattleFsm;
   import engine.battle.fsm.BattleMove;
   import engine.battle.fsm.BattleMoveVars;
   import engine.battle.fsm.state.turn.cmd.BattleTurnCmdAction;
   import engine.battle.fsm.state.turn.cmd.BattleTurnCmdMove;
   import engine.battle.fsm.txn.BattleTxnQuery;
   import engine.core.fsm.StateData;
   import engine.core.fsm.StatePhase;
   import engine.core.logging.ILogger;
   import tbs.srv.battle.data.client.BattleActionData;
   import tbs.srv.battle.data.client.BattleMoveData;
   
   public class BattleStateTurnRemote extends BattleStateTurnBase
   {
      
      public static const DEFAULT_FETCH_TIME_MS:int = 500;
       
      
      private var txnQuery:BattleTxnQuery;
      
      public function BattleStateTurnRemote(param1:StateData, param2:BattleFsm, param3:ILogger)
      {
         super(param1,param2,param3,false);
      }
      
      override protected function handleEnteredState() : void
      {
         super.handleEnteredState();
      }
      
      override protected function handleCleanup() : void
      {
         if(this.txnQuery)
         {
            this.txnQuery.abort();
            this.txnQuery = null;
         }
      }
      
      override public function handleMessage(param1:Object) : Boolean
      {
         var _loc2_:BattleMoveData = null;
         var _loc3_:BattleActionData = null;
         if(param1["class"] == "tbs.srv.battle.data.client.BattleMoveData")
         {
            _loc2_ = new BattleMoveData();
            _loc2_.parseJson(param1,logger);
            this.handleMoveMsg(_loc2_);
            return true;
         }
         if(param1["class"] == "tbs.srv.battle.data.client.BattleActionData")
         {
            _loc3_ = new BattleActionData();
            _loc3_.parseJson(param1,logger);
            this.handleActionMsg(_loc3_);
            return true;
         }
         return super.handleMessage(param1);
      }
      
      private function handleMoveMsg(param1:BattleMoveData) : void
      {
         logger.debug("BattleStateTurnRemote.handleMoveMsg got MOVE " + param1);
         if(turn.move.committed)
         {
            return;
         }
         if(cmdSeq.hasOrdinal(param1.ordinal))
         {
            return;
         }
         if(param1.entity != turn.entity)
         {
            logger.error("BattleStateTurnRemote.handleMoveMsg IGNORE attempt " + param1);
            return;
         }
         if(param1.tiles[0] != turn.entity.tile.location)
         {
            logger.error("BattleStateTurnRemote.handleMoveMsg INVALID move " + param1);
            return;
         }
         var _loc2_:BattleMove = new BattleMoveVars(battleFsm.board,param1,logger);
         var _loc3_:int = param1.ordinal;
         turn.move.copy(_loc2_);
         turn.move.setCommitted("BattleStateTurnRemote");
         cmdSeq.addCmd(new BattleTurnCmdMove(this,_loc3_,false,turn.move));
      }
      
      private function handleActionMsg(param1:BattleActionData) : void
      {
         if(cmdSeq.hasOrdinal(param1.ordinal))
         {
            return;
         }
         logger.debug("BattleStateTurnRemote.handleActionMsg got ACTION " + param1);
         if(param1.entity != turn.entity)
         {
            logger.error("BattleStateTurnRemote.handleActionMsg IGNORE attempt " + param1);
            return;
         }
         var _loc2_:BattleAbility = BattleAbilityVars.parse(param1,battleFsm.board,logger,battleFsm.board.abilityManager);
         cmdSeq.addCmd(new BattleTurnCmdAction(this,param1.ordinal,false,_loc2_,param1.terminator));
      }
      
      override protected function handleTimeout() : void
      {
         logger.debug("BattleStateTurnRemote Timed out");
         this.checkTurnQuery();
      }
      
      private function checkTurnQuery() : void
      {
         if(!this.txnQuery)
         {
            this.txnQuery = new BattleTxnQuery(battleFsm.battleId,turn.number,this.checkTurnHandler,battleFsm,logger);
            this.txnQuery.send(battleFsm.session.communicator);
         }
      }
      
      private function checkTurnHandler(param1:BattleTxnQuery) : void
      {
         if(phase == StatePhase.ENTERED)
         {
            if(Boolean(param1) && param1.success)
            {
               this.txnQuery.resend(battleFsm.session.communicator,5000);
            }
         }
      }
   }
}
