package engine.battle.fsm.state
{
   import engine.battle.ability.def.IBattleAbilityDef;
   import engine.battle.ability.model.BattleAbility;
   import engine.battle.ability.model.IBattleAbilityManager;
   import engine.battle.board.model.IBattleBoard;
   import engine.battle.board.model.IBattleEntity;
   import engine.battle.board.model.IBattleMove;
   import engine.battle.fsm.BattleFsm;
   import engine.battle.fsm.BattleMoveEvent;
   import engine.battle.fsm.BattleTurnEvent;
   import engine.battle.fsm.state.turn.cmd.BattleTurnCmdAction;
   import engine.battle.fsm.state.turn.cmd.BattleTurnCmdMove;
   import engine.core.fsm.StateData;
   import engine.core.logging.ILogger;
   import engine.saga.Saga;
   import engine.saga.SagaVar;
   
   public class BattleStateTurnLocal extends BattleStateTurnLocalBase
   {
       
      
      private var turnMove:IBattleMove;
      
      public function BattleStateTurnLocal(param1:StateData, param2:BattleFsm, param3:ILogger)
      {
         super(param1,param2,param3,true);
      }
      
      override protected function handleEnteredState() : void
      {
         if(!_turn || !_turn._entity || !_board)
         {
            return;
         }
         _turn._entity.playGoAnimation();
         this.turnMove = _turn._move;
         if(this.turnMove)
         {
            this.turnMove.addEventListener(BattleMoveEvent.COMMITTED,this.moveCommittedHandler);
            if(_turn._entity.isDisabledMove)
            {
               this.turnMove.setCommitted("disabled move");
               battleFsm.interact = _turn.entity;
            }
         }
         _turn.addEventListener(BattleTurnEvent.COMMITTED,this.turnCommittedHandler);
         _board.selectedTile = entity.tile;
         super.handleEnteredState();
         if(Boolean(fsm) && !cleanedup)
         {
            if(_turn == battleFsm._turn && _turn && _turn._entity && !_turn._entity.alive)
            {
               logger.info("Entity got into turn " + _turn + " already dead, skipping...");
               this.skip(true,"BattleStateTurnLocal.handleEnteredState already dead",false);
            }
         }
      }
      
      private function turnCommittedHandler(param1:BattleTurnEvent) : void
      {
         if(!turn.committed)
         {
            return;
         }
         if(turn.suspended)
         {
            return;
         }
         if(turn.ability)
         {
            cmdSeq.addCmd(new BattleTurnCmdAction(this,0,true,turn.ability,true));
         }
         else
         {
            this.skip(false,"BattleStateTurnLocal.turnCommittedHandler",false);
         }
      }
      
      private function moveCommittedHandler(param1:BattleMoveEvent) : void
      {
         var _loc2_:BattleAbility = null;
         if(Boolean(this.turnMove) && !entity.isDisabledMove)
         {
            if(this.turnMove.committed)
            {
               cmdSeq.addCmd(new BattleTurnCmdMove(this,0,true,this.turnMove),false);
               if(turn._numAbilities >= 1)
               {
                  _loc2_ = this.makeAblEndAbility();
                  cmdSeq.addCmd(new BattleTurnCmdAction(this,0,true,_loc2_,true));
               }
            }
         }
      }
      
      private function makeAblEndAbility() : BattleAbility
      {
         var _loc1_:IBattleEntity = turn.entity;
         var _loc2_:IBattleBoard = _loc1_.board;
         var _loc3_:IBattleAbilityManager = _loc2_.abilityManager;
         var _loc4_:IBattleAbilityDef = _loc3_.getFactory.fetchIBattleAbilityDef("abl_end");
         return new BattleAbility(_loc1_,_loc4_,_loc3_);
      }
      
      override protected function handleCleanup() : void
      {
         if(this.turnMove)
         {
            this.turnMove.removeEventListener(BattleMoveEvent.COMMITTED,this.moveCommittedHandler);
            this.turnMove = null;
         }
         turn.removeEventListener(BattleTurnEvent.COMMITTED,this.turnCommittedHandler);
         var _loc1_:Saga = Saga.instance;
         if(_loc1_)
         {
            if(_loc1_.isSurvival)
            {
               _loc1_.incrementGlobalVar(SagaVar.VAR_SURVIVAL_ELAPSED_SEC,timeoutElapsedMs / 1000);
               _loc1_.setVar("survival_win_time_num",_loc1_.getVarInt(SagaVar.VAR_SURVIVAL_ELAPSED_SEC) / 60);
            }
         }
         super.handleCleanup();
      }
      
      override public function skip(param1:Boolean, param2:String, param3:Boolean) : void
      {
         if(this.turnMove)
         {
            this.turnMove.removeEventListener(BattleMoveEvent.COMMITTED,this.moveCommittedHandler);
         }
         turn.removeEventListener(BattleTurnEvent.COMMITTED,this.turnCommittedHandler);
         super.skip(param1,param2,param3);
      }
      
      override protected function handleTimeout() : void
      {
         logger.info("BattleStateTurnLocal Timed out");
         this.skip(false,"BattleStateTurnLocal.timeoutTimerCompleteHandler",false);
      }
   }
}
