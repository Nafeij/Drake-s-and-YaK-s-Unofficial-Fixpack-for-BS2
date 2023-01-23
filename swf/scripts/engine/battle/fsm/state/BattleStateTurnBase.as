package engine.battle.fsm.state
{
   import engine.battle.ability.model.BattleAbility;
   import engine.battle.ability.model.BattleAbilityEvent;
   import engine.battle.ability.model.IBattleAbilityManager;
   import engine.battle.board.model.IBattleBoard;
   import engine.battle.board.model.IBattleEntity;
   import engine.battle.board.model.IBattleScenario;
   import engine.battle.entity.model.BattleEntityEvent;
   import engine.battle.fsm.BattleFsm;
   import engine.battle.fsm.BattleStateDataEnum;
   import engine.battle.fsm.BattleTurn;
   import engine.battle.fsm.state.turn.cmd.BattleTurnCmdAction;
   import engine.battle.fsm.state.turn.cmd.TurnSeqCmds;
   import engine.battle.sim.IBattleParty;
   import engine.battle.wave.BattleWaves;
   import engine.core.fsm.StateData;
   import engine.core.fsm.StatePhase;
   import engine.core.logging.ILogger;
   import engine.saga.Saga;
   import engine.saga.SagaAchievements;
   import engine.saga.SagaTriggerType;
   import engine.saga.SagaVar;
   import flash.errors.IllegalOperationError;
   
   public class BattleStateTurnBase extends BaseBattleState
   {
      
      public static var SUPPRESS_DEATH_CHECK:Boolean;
      
      public static var INCOMPLETES_BLOCK_FINISH:Boolean = true;
       
      
      protected var _turn:BattleTurn;
      
      protected var _board:IBattleBoard;
      
      public var cmdSeq:TurnSeqCmds;
      
      private var _completing:Boolean;
      
      private var man:IBattleAbilityManager;
      
      public var readyToFinishBattle:Boolean;
      
      private var deads_need_processing:Boolean;
      
      private var survivors_counted:Boolean;
      
      private var _surviving_players:int = 0;
      
      private var _surviving_enemies:int = 0;
      
      private var survivor:String = null;
      
      public var playerVictory:Boolean;
      
      public function BattleStateTurnBase(param1:StateData, param2:BattleFsm, param3:ILogger, param4:Boolean)
      {
         super(param1,param2,param3,param2.turn.timerSecs * 1000);
         this._board = battleFsm.board;
         this._turn = battleFsm.turn as BattleTurn;
         this.cmdSeq = new TurnSeqCmds(param4);
         this.man = this._board.abilityManager;
      }
      
      public function skip(param1:Boolean, param2:String, param3:Boolean) : void
      {
         throw new IllegalOperationError("pure virtual");
      }
      
      override public function update(param1:int) : void
      {
         super.update(param1);
         if(this.cmdSeq)
         {
            this.cmdSeq.updateTurnSeqCmds();
         }
      }
      
      override protected function handleEnteredState() : void
      {
         var _loc1_:IBattleEntity = null;
         var _loc2_:Saga = null;
         var _loc3_:IBattleEntity = null;
         var _loc4_:String = null;
         var _loc5_:int = 0;
         super.handleEnteredState();
         for each(_loc1_ in this._board.entities)
         {
            this.listenEntity(_loc1_);
         }
         this._board.addEventListener(BattleEntityEvent.REMOVED,this.entityRemovedHandler);
         this._board.addEventListener(BattleEntityEvent.ADDED,this.entityAddedHandler);
         _loc2_ = this._board.scene.context.saga as Saga;
         if(_loc2_)
         {
            _loc3_ = this.turn.entity;
            _loc2_.setVar(SagaVar.VAR_BATTLE_UNIT_ID,_loc3_.id);
            _loc2_.setVar(SagaVar.VAR_BATTLE_UNIT_ENTITY_ID,_loc3_.def.id);
            _loc2_.setVar(SagaVar.VAR_BATTLE_UNIT_CLASS_ID,_loc3_.def.entityClass.id);
            _loc2_.setVar(SagaVar.VAR_BATTLE_UNIT_RACE,_loc3_.def.entityClass.race);
            _loc2_.setVar(SagaVar.VAR_BATTLE_UNIT_PLAYER,_loc3_.isPlayer);
            _loc2_.setVar(SagaVar.VAR_BATTLE_UNIT_ENEMY,_loc3_.isEnemy);
            _loc4_ = !!_loc3_.attractor ? _loc3_.attractor.def.id : "";
            _loc2_.setVar(SagaVar.VAR_BATTLE_UNIT_ATTRACTOR,_loc4_);
            _loc2_.setVar(SagaVar.VAR_BATTLE_UNIT_VISIBLE,_loc3_.visibleToPlayer);
            _loc2_.triggerBattleTurn(this.turn.entity.def.id,this.turn.entity.isPlayer);
         }
         if(!this._turn || !this._turn.entity || this._turn != battleFsm._turn)
         {
            return;
         }
         this._board.onStartedTurn();
         if(!this._turn || !this._turn.entity || this._turn != battleFsm._turn)
         {
            return;
         }
         this._turn.entity.onStartTurn();
         if(!this._turn || !this._turn.entity || this._turn != battleFsm._turn)
         {
            return;
         }
         if(this._turn.entity.freeTurns)
         {
            logger.info("Free Turn " + this._turn.entity.freeTurns);
         }
         if(this._board.scenario)
         {
            this._board.scenario.handleTurnStart(this._turn.entity);
            if(!this._turn || !this._turn.entity || this._turn != battleFsm._turn)
            {
               return;
            }
            if(this._turn.entity.freeTurns)
            {
               this._board.scenario.handleFreeTurn(this._turn.entity);
            }
         }
         else if(this._turn.entity.freeTurns)
         {
            _loc5_ = 5;
            if(this._turn.entity.freeTurns >= _loc5_)
            {
               SagaAchievements.unlockAchievementById("acv_culling_frenzy",_loc2_.minutesPlayed,true);
            }
         }
      }
      
      public function get entity() : IBattleEntity
      {
         return !!this.turn ? this.turn.entity : null;
      }
      
      override protected function handleCleanup() : void
      {
         var _loc1_:IBattleEntity = null;
         if(this.man)
         {
            this.man.removeEventListener(BattleAbilityEvent.INCOMPLETES_EMPTY,this.abilityIncompletesEmptyHandler);
         }
         this.man = null;
         this.cmdSeq.cleanup();
         this.cmdSeq = null;
         super.handleCleanup();
         for each(_loc1_ in this._board.entities)
         {
            this.unlistenEntity(_loc1_);
         }
         this._board = null;
         this._turn = null;
      }
      
      private function listenEntity(param1:IBattleEntity) : void
      {
         param1.addEventListener(BattleEntityEvent.ALIVE,this.aliveHandler);
         param1.addEventListener(BattleEntityEvent.ENABLED,this.entityEnabledHandler);
         param1.addEventListener(BattleEntityEvent.IMMORTAL_STOPPED,this.immortalStoppedHandler);
         param1.addEventListener(BattleEntityEvent.END_TURN_IF_NO_ENEMIES_REMAIN,this.endTurnIfNoEnemiesRemainHandler);
      }
      
      private function unlistenEntity(param1:IBattleEntity) : void
      {
         param1.removeEventListener(BattleEntityEvent.ALIVE,this.aliveHandler);
         param1.removeEventListener(BattleEntityEvent.ENABLED,this.entityEnabledHandler);
         param1.removeEventListener(BattleEntityEvent.IMMORTAL_STOPPED,this.immortalStoppedHandler);
         param1.removeEventListener(BattleEntityEvent.END_TURN_IF_NO_ENEMIES_REMAIN,this.endTurnIfNoEnemiesRemainHandler);
      }
      
      private function entityRemovedHandler(param1:BattleEntityEvent) : void
      {
         this.unlistenEntity(param1.entity);
      }
      
      private function entityAddedHandler(param1:BattleEntityEvent) : void
      {
         this.listenEntity(param1.entity);
      }
      
      private function entityEnabledHandler(param1:BattleEntityEvent) : void
      {
         if(!this.checkStateOk())
         {
            return;
         }
         var _loc2_:IBattleEntity = param1.entity;
         var _loc3_:IBattleParty = _loc2_.party;
         this.deads_need_processing = true;
         this.checkVictory(_loc3_);
      }
      
      private function checkStateOk() : Boolean
      {
         if(phase != StatePhase.ENTERED)
         {
            return false;
         }
         if(!battleFsm || battleFsm.cleanedup || battleFsm.aborted)
         {
            return false;
         }
         if(!this._board || this._board.cleanedup)
         {
            return false;
         }
         return true;
      }
      
      protected function aliveHandler(param1:BattleEntityEvent) : void
      {
         var _loc4_:int = 0;
         var _loc5_:IBattleParty = null;
         if(!this.checkStateOk())
         {
            return;
         }
         if(SUPPRESS_DEATH_CHECK)
         {
            return;
         }
         var _loc2_:IBattleEntity = param1.entity;
         var _loc3_:IBattleParty = _loc2_.party;
         this.deads_need_processing = true;
         if(!_loc2_.alive)
         {
            if(_loc3_ && _loc2_ && Boolean(_loc2_.mobile))
            {
               _loc4_ = 0;
               while(_loc4_ < this._board.numParties)
               {
                  _loc5_ = this._board.getParty(_loc4_);
                  if(_loc3_.team != _loc5_.team)
                  {
                     ++_loc5_.artifactChargeCount;
                  }
                  _loc4_++;
               }
            }
            if(battleFsm.interact == _loc2_)
            {
               if(Boolean(battleFsm.activeEntity) && battleFsm.activeEntity.party.isPlayer)
               {
                  battleFsm.interact = battleFsm.activeEntity;
               }
               else
               {
                  battleFsm.interact = null;
               }
            }
         }
         this.checkVictory(_loc3_);
      }
      
      private function immortalStoppedHandler(param1:BattleEntityEvent) : void
      {
         if(!this.checkStateOk() || SUPPRESS_DEATH_CHECK)
         {
            return;
         }
         this.deads_need_processing = true;
         this.checkVictory(param1.entity.party,param1.entity);
      }
      
      private function endTurnIfNoEnemiesRemainHandler(param1:BattleEntityEvent) : void
      {
         var _loc2_:IBattleEntity = null;
         for each(_loc2_ in battleFsm.participants)
         {
            if(_loc2_.alive && Boolean(_loc2_.isEnemy) && Boolean(_loc2_.active) && Boolean(_loc2_.enabled))
            {
               return;
            }
         }
         param1.entity.endTurn(false,"NO ENEMIES REMAIN",false);
      }
      
      private function recalculateSurvivors(param1:IBattleEntity = null) : void
      {
         var _loc2_:IBattleEntity = null;
         this._surviving_players = 0;
         this._surviving_enemies = 0;
         this.survivor = null;
         this.playerVictory = false;
         this.survivors_counted = true;
         for each(_loc2_ in battleFsm.participants)
         {
            if(_loc2_.alive && Boolean(_loc2_.enabled) && Boolean(_loc2_.active) && !_loc2_.incorporeal && _loc2_ != param1)
            {
               if(_loc2_.isPlayer)
               {
                  ++this._surviving_players;
               }
               else if(_loc2_.isEnemy)
               {
                  ++this._surviving_enemies;
               }
               if(this.survivor == null && this.survivor != _loc2_.team)
               {
                  this.survivor = _loc2_.team;
               }
            }
         }
      }
      
      private function checkVictory(param1:IBattleParty, param2:IBattleEntity = null) : void
      {
         var _loc4_:SagaTriggerType = null;
         var _loc5_:int = 0;
         this.recalculateSurvivors(param2);
         var _loc3_:Saga = Saga.instance;
         if(_loc3_ && battleFsm && !battleFsm.forceKillAll)
         {
            if(this._surviving_players != 0 && this._surviving_enemies == 0 && _loc3_.triggerNoMoreEnemiesRemainPreVictory())
            {
               this.recalculateSurvivors(param2);
            }
         }
         this.playerVictory = this.survivor == "0";
         if(Boolean(param1) && Boolean(_loc3_))
         {
            if(param1.isPlayer)
            {
               _loc4_ = SagaTriggerType.BATTLE_REMAINING_PLAYERS;
               _loc5_ = this._surviving_players;
            }
            else if(param1.isEnemy)
            {
               _loc4_ = SagaTriggerType.BATTLE_REMAINING_ENEMIES;
               _loc5_ = this._surviving_enemies;
            }
            if(_loc4_)
            {
               _loc3_.triggerBattleRemainingUnits(_loc4_,_loc5_);
            }
         }
         this.processDeads();
      }
      
      public function get surviving_enemies() : int
      {
         var _loc1_:IBattleEntity = null;
         if(this._surviving_enemies > 0)
         {
            return this._surviving_enemies;
         }
         this._surviving_enemies = 0;
         for each(_loc1_ in battleFsm.participants)
         {
            if(_loc1_.alive && Boolean(_loc1_.enabled) && Boolean(_loc1_.active) && !_loc1_.incorporeal)
            {
               if(_loc1_.isEnemy)
               {
                  ++this._surviving_enemies;
               }
            }
         }
         return this._surviving_enemies;
      }
      
      private function abilityIncompletesEmptyHandler(param1:BattleAbilityEvent) : void
      {
         this.processDeads();
      }
      
      private function processDeads() : void
      {
         var _loc2_:IBattleScenario = null;
         if(!this.deads_need_processing)
         {
            return;
         }
         if(!battleFsm || battleFsm.cleanedup || battleFsm.aborted)
         {
            return;
         }
         if(!this._board || this._board.cleanedup)
         {
            return;
         }
         if(INCOMPLETES_BLOCK_FINISH)
         {
            if(this.man.numIncompleteAbilities)
            {
               this.man.addEventListener(BattleAbilityEvent.INCOMPLETES_EMPTY,this.abilityIncompletesEmptyHandler);
               return;
            }
            this.man.removeEventListener(BattleAbilityEvent.INCOMPLETES_EMPTY,this.abilityIncompletesEmptyHandler);
         }
         if(this._surviving_enemies == 0 || this._surviving_players == 0)
         {
            _loc2_ = this._board.scenario;
            if(_loc2_)
            {
               if(this.playerVictory)
               {
                  _loc2_.handleBattleWin();
                  if(Boolean(battleFsm) && battleFsm.aborted)
                  {
                     logger.info("BattleStateTurnBase.aliveHandler party wiped out but deferred to Scenario " + _loc2_);
                     return;
                  }
               }
            }
            if(this.handleVictoryWaves())
            {
               logger.i("WAVE","BattleStateTurnBase player victorious, continuing battle");
            }
            else
            {
               logger.info("BattleStateTurnBase.aliveHandler VICTORIOUS_TEAM=" + this.survivor);
               data.setValue(BattleStateDataEnum.VICTORIOUS_TEAM,this.survivor);
               this.readyToFinishBattle = true;
            }
         }
         var _loc1_:IBattleEntity = this.entity;
         if(Boolean(_loc1_) && !_loc1_.alive)
         {
            this.handleSelfDied();
         }
      }
      
      private function handleVictoryWaves() : Boolean
      {
         if(!this.playerVictory)
         {
            return false;
         }
         if(!this._board.waves)
         {
            return false;
         }
         this._board.waves.isPlayerVictorious = true;
         return this._board.waves.hasMoreWaves;
      }
      
      protected function handleSelfDied() : void
      {
      }
      
      protected function get turn() : BattleTurn
      {
         return this._turn;
      }
      
      protected function get board() : IBattleBoard
      {
         return this._board;
      }
      
      public function turnCompleting() : void
      {
         if(cleanedup || !this.cmdSeq)
         {
            return;
         }
         this.processDeads();
         if(cleanedup || !this.cmdSeq)
         {
            return;
         }
         this._completing = true;
         this.cmdSeq.completing();
      }
      
      public function turnCompletedWaves() : Boolean
      {
         var _loc1_:BattleWaves = this._board.waves;
         if(!_loc1_)
         {
            return false;
         }
         if(!_loc1_.isWaveComplete && !_loc1_.isPlayerVictorious)
         {
            return false;
         }
         if(_loc1_.hasMoreWaves)
         {
            if(_loc1_.isPlayerVictorious)
            {
               battleFsm.transitionTo(BattleStateWaveRedeploy,data);
            }
            else
            {
               battleFsm.transitionTo(BattleStateWaveRespawn,data);
            }
            return true;
         }
         return false;
      }
      
      public function turnCompleted() : void
      {
         if(this.entity)
         {
            this.entity.onEndTurn();
         }
         if(this.turnCompletedWaves())
         {
            return;
         }
         this.advanceToNextState();
      }
      
      public function advanceToNextState() : void
      {
         if(this.readyToFinishBattle)
         {
            battleFsm.transitionTo(BattleStateFinish,data);
         }
         else
         {
            phase = StatePhase.COMPLETED;
         }
      }
      
      public function performAction(param1:BattleAbility) : void
      {
         this.cmdSeq.addCmd(new BattleTurnCmdAction(this,0,true,param1,false));
      }
   }
}
