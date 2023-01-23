package engine.battle.fsm.state.turn.cmd
{
   import engine.battle.ability.model.BattleAbilityEvent;
   import engine.battle.ability.model.IBattleAbilityManager;
   import engine.battle.board.model.IBattleBoard;
   import engine.battle.board.model.IBattleEntity;
   import engine.battle.fsm.BattleFsm;
   import engine.battle.fsm.BattleMoveEvent;
   import engine.battle.fsm.BattleTurn;
   import engine.battle.fsm.state.BattleStateTurnBase;
   import engine.core.logging.ILogger;
   import flash.errors.IllegalOperationError;
   
   public class BattleTurnCmd extends TurnCmd
   {
       
      
      public var state:BattleStateTurnBase;
      
      public var turn:BattleTurn;
      
      public var entity:IBattleEntity;
      
      public var board:IBattleBoard;
      
      public var logger:ILogger;
      
      public var battleFsm:BattleFsm;
      
      public var started:Boolean;
      
      public var readyToComplete:Boolean;
      
      public function BattleTurnCmd(param1:BattleStateTurnBase, param2:int, param3:Boolean)
      {
         super(param1.cmdSeq,param2,param3);
         this.state = param1;
         this.battleFsm = param1.battleFsm;
         this.turn = this.battleFsm.turn as BattleTurn;
         this.board = this.battleFsm.board;
         this.logger = this.board.logger;
         this.entity = this.turn.entity;
      }
      
      protected function handleBattleExecute() : void
      {
         throw new IllegalOperationError("pure virtual");
      }
      
      protected function battleComplete() : void
      {
         this.readyToComplete = true;
         this.checkSituation();
      }
      
      final override protected function handleExecute() : void
      {
         this.checkSituation();
      }
      
      protected function handleBattleCompleting() : void
      {
      }
      
      protected function handleBattleCompleted() : void
      {
      }
      
      override protected function handleCleanup() : void
      {
         this.board.abilityManager.removeEventListener(BattleAbilityEvent.INCOMPLETES_EMPTY,this.incompleteEffectsCompleteHandler);
         if(this.turn.move)
         {
            this.turn.move.removeEventListener(BattleMoveEvent.EXECUTED,this.moveExecutedHandler);
         }
      }
      
      private function incompleteEffectsCompleteHandler(param1:BattleAbilityEvent) : void
      {
         this.board.abilityManager.removeEventListener(BattleAbilityEvent.INCOMPLETES_EMPTY,this.incompleteEffectsCompleteHandler);
         this.checkSituation();
      }
      
      private function moveExecutedHandler(param1:BattleMoveEvent) : void
      {
         this.turn.move.removeEventListener(BattleMoveEvent.EXECUTED,this.moveExecutedHandler);
         this.checkSituation();
      }
      
      private function checkSituation() : void
      {
         if(!this.board || this.board.cleanedup || !this.battleFsm || this.battleFsm.cleanedup || !this.entity || this.entity.cleanedup)
         {
            return;
         }
         var _loc1_:IBattleAbilityManager = this.board.abilityManager;
         if(!_loc1_)
         {
            return;
         }
         if(_loc1_.numIncompleteAbilities > 0)
         {
            _loc1_.addEventListener(BattleAbilityEvent.INCOMPLETES_EMPTY,this.incompleteEffectsCompleteHandler);
            if(this.logger.isDebugEnabled)
            {
               this.logger.debug("BattleTurnCmd INCOMPLETE EFFECT blocks " + this + " BY " + _loc1_.debugIncompletes);
            }
            return;
         }
         if(Boolean(this.turn.move) && this.turn.move.executing)
         {
            this.turn.move.addEventListener(BattleMoveEvent.EXECUTED,this.moveExecutedHandler);
            if(this.logger.isDebugEnabled)
            {
               this.logger.debug("BattleTurnCmd INCOMPLETE MOVE: " + this);
            }
            return;
         }
         if(!this.started)
         {
            this.started = true;
            this.handleBattleExecute();
         }
         else if(this.readyToComplete)
         {
            this.handleBattleCompleting();
            complete();
            this.handleBattleCompleted();
         }
      }
   }
}
