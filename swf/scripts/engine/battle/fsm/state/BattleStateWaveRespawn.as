package engine.battle.fsm.state
{
   import com.greensock.TweenMax;
   import engine.battle.board.model.BattleBoard;
   import engine.battle.board.model.IBattleEntity;
   import engine.battle.fsm.BattleFsm;
   import engine.battle.fsm.BattleFsmEvent;
   import engine.battle.sim.IBattleParty;
   import engine.battle.wave.BattleWaves;
   import engine.core.fsm.StateData;
   import engine.core.fsm.StatePhase;
   import engine.core.logging.ILogger;
   import engine.resource.ResourceMonitor;
   import engine.saga.Saga;
   
   public class BattleStateWaveRespawn extends BaseBattleState
   {
       
      
      private const MIN_LOADING_TIME_SEC:Number = 3;
      
      private var _board:BattleBoard;
      
      private var _monitor:ResourceMonitor;
      
      private var _tweenTimeout:TweenMax;
      
      private var _waitedMinTime:Boolean;
      
      public function BattleStateWaveRespawn(param1:StateData, param2:BattleFsm, param3:ILogger)
      {
         super(param1,param2,param3);
      }
      
      override protected function handleEnteredState() : void
      {
         var waves:BattleWaves = null;
         var waveToClearBodiesFrom:int = 0;
         super.handleEnteredState();
         this._board = battleFsm.board as BattleBoard;
         this._board.boardSetup = false;
         this._monitor = new ResourceMonitor("Battle Wave Respawn",logger,this.resourceMonitorChangedHandler);
         this._board.saga.resman.addMonitor(this._monitor);
         waves = this._board.waves;
         while(waves.wave != null)
         {
            try
            {
               if(!waves.isPlayerVictorious)
               {
                  waves.lostAWave = true;
                  fsm.dispatchEvent(new BattleFsmEvent(BattleFsmEvent.WAVE_ENEMY_REINFORCEMENTS));
               }
               waves.nextWave();
               if(waves.def.turnsToPreserveBodies > 0)
               {
                  waveToClearBodiesFrom = waves.waveNumber - waves.def.turnsToPreserveBodies;
                  if(waveToClearBodiesFrom > 0)
                  {
                     this._board.cleanupEnemiesFromWave(waveToClearBodiesFrom);
                  }
               }
               this._board.spawnWave(waves.wave);
               break;
            }
            catch(e:Error)
            {
               if(!waves.wave)
               {
                  logger.error("Critical error spawning wave #" + waves.waveNumber + "! Terminating wave spawn attempt" + e.message + "\n" + e.getStackTrace());
                  phase = StatePhase.FAILED;
                  return;
               }
            }
            logger.error("Error spawning wave #" + waves.waveNumber + "! Advancing to next wave. " + §§pop().§§slot[1].message + "\n" + §§pop().§§slot[1].getStackTrace());
         }
         this._tweenTimeout = TweenMax.delayedCall(this.MIN_LOADING_TIME_SEC,this.tweenTimerComplete);
         this._waitedMinTime = false;
      }
      
      private function tweenTimerComplete() : void
      {
         this._waitedMinTime = true;
         this.checkReady();
      }
      
      private function resourceMonitorChangedHandler(param1:ResourceMonitor) : void
      {
         this.checkReady();
      }
      
      private function checkReady() : void
      {
         if(this._monitor.empty && this._waitedMinTime)
         {
            (this._board.scene.context.saga as Saga).triggerBattleWaveSpawned();
            this.stateCleanup();
            this._resetEnemyParties();
            this._updatePlayerParty();
            battleFsm.order.aliveOrder.length = 0;
            battleFsm.order.resetTurnOrder();
            this._board.boardSetup = true;
            phase = StatePhase.COMPLETED;
         }
      }
      
      private function _updatePlayerParty() : void
      {
         var _loc3_:IBattleParty = null;
         var _loc4_:int = 0;
         var _loc5_:IBattleEntity = null;
         var _loc1_:Saga = Saga.instance;
         var _loc2_:BattleBoard = battleFsm.board as BattleBoard;
         for each(_loc3_ in _loc2_.parties)
         {
            if(!(!_loc3_.isPlayer || _loc3_.team == "prop" || _loc3_.team == null))
            {
               _loc4_ = 0;
               while(_loc4_ < _loc3_.numMembers)
               {
                  _loc5_ = _loc3_.getMember(_loc4_);
                  if(battleFsm.participants.indexOf(_loc5_) < 0)
                  {
                     battleFsm.participants.push(_loc5_);
                  }
                  _loc4_++;
               }
            }
         }
      }
      
      private function _resetEnemyParties() : void
      {
         var _loc3_:IBattleParty = null;
         var _loc4_:int = 0;
         var _loc5_:IBattleEntity = null;
         var _loc1_:Saga = Saga.instance;
         var _loc2_:BattleBoard = battleFsm.board as BattleBoard;
         for each(_loc3_ in _loc2_.parties)
         {
            if(!(!_loc3_.isEnemy || _loc3_.team == "prop" || _loc3_.team == null))
            {
               battleFsm.order.removeParty(_loc3_);
               if(_loc3_.numAlive)
               {
                  battleFsm.order.addParty(_loc3_);
                  _loc4_ = 0;
                  while(_loc4_ < _loc3_.numMembers)
                  {
                     _loc5_ = _loc3_.getMember(_loc4_);
                     if(battleFsm.participants.indexOf(_loc5_) < 0)
                     {
                        battleFsm.participants.push(_loc5_);
                        if(_loc1_)
                        {
                           _loc1_.applyUnitDifficultyBonuses(_loc5_);
                        }
                     }
                     _loc4_++;
                  }
               }
            }
         }
      }
      
      private function stateCleanup() : void
      {
         if(this._tweenTimeout)
         {
            this._tweenTimeout.kill();
            this._tweenTimeout = null;
         }
         if(Boolean(this._board) && Boolean(this._monitor))
         {
            this._board.saga.resman.removeMonitor(this._monitor);
            this._monitor = null;
         }
      }
      
      override protected function handleCleanup() : void
      {
         this.stateCleanup();
         super.handleCleanup();
      }
   }
}
