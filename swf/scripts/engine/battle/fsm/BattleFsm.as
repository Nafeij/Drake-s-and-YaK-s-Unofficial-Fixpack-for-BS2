package engine.battle.fsm
{
   import com.stoicstudio.platform.PlatformInput;
   import engine.battle.ability.def.IBattleAbilityDef;
   import engine.battle.ability.model.BattleAbility;
   import engine.battle.ability.model.BattleTargetSet;
   import engine.battle.ability.model.IBattleAbility;
   import engine.battle.board.BattleBoardEvent;
   import engine.battle.board.model.IBattleBoard;
   import engine.battle.board.model.IBattleEntity;
   import engine.battle.board.model.IBattleMove;
   import engine.battle.fsm.state.BaseBattleState;
   import engine.battle.fsm.state.BattleStateAborted;
   import engine.battle.fsm.state.BattleStateDeploy;
   import engine.battle.fsm.state.BattleStateError;
   import engine.battle.fsm.state.BattleStateFinish;
   import engine.battle.fsm.state.BattleStateFinished;
   import engine.battle.fsm.state.BattleStateInit;
   import engine.battle.fsm.state.BattleStateNextTurn;
   import engine.battle.fsm.state.BattleStateRespawn;
   import engine.battle.fsm.state.BattleStateStart;
   import engine.battle.fsm.state.BattleStateSurrender;
   import engine.battle.fsm.state.BattleStateTurnAi;
   import engine.battle.fsm.state.BattleStateTurnBase;
   import engine.battle.fsm.state.BattleStateTurnLocal;
   import engine.battle.fsm.state.BattleStateTurnRemote;
   import engine.battle.fsm.state.BattleStateWaveRedeploy;
   import engine.battle.fsm.state.BattleStateWaveRedeploy_Assemble;
   import engine.battle.fsm.state.BattleStateWaveRedeploy_Prepare;
   import engine.battle.fsm.state.BattleStateWaveRedeploy_Prepare_Tutorial;
   import engine.battle.fsm.state.BattleStateWaveRespawn;
   import engine.battle.fsm.state.BattleStateWaveRespawn_Complete;
   import engine.battle.fsm.state.BattleStateWaveRespawn_ResetCamera;
   import engine.battle.fsm.state.turn.cmd.BattleTurnCmdAction;
   import engine.battle.fsm.txn.BattleTxnExitSend;
   import engine.battle.fsm.txn.BattleTxnKillSend;
   import engine.battle.fsm.txn.BattleTxnSurrenderSend;
   import engine.battle.sim.IBattleParty;
   import engine.core.fsm.Fsm;
   import engine.core.fsm.StateData;
   import engine.core.logging.ILogger;
   import engine.core.util.AppInfo;
   import engine.entity.def.Item;
   import engine.math.Rng;
   import engine.path.PathFloodSolver;
   import engine.saga.ISaga;
   import engine.saga.Saga;
   import engine.saga.SagaAchievements;
   import engine.saga.SagaCheat;
   import engine.saga.SagaVar;
   import engine.session.Chat;
   import engine.session.Session;
   import engine.stat.def.StatType;
   import engine.stat.model.Stats;
   import engine.tile.Tile;
   import flash.errors.IllegalOperationError;
   import flash.events.Event;
   import flash.utils.Dictionary;
   import tbs.srv.battle.data.client.BaseBattleTurnData;
   import tbs.srv.battle.data.client.BattleAbortedData;
   import tbs.srv.battle.data.client.BattleCreateData;
   import tbs.srv.battle.data.client.BattleExitData;
   import tbs.srv.battle.data.client.BattleSurrenderData;
   import tbs.srv.battle.data.client.BattleSyncData;
   
   public class BattleFsm extends Fsm implements IBattleFsm
   {
       
      
      public var _session:Session;
      
      public var board:IBattleBoard;
      
      public var config:BattleFsmConfig;
      
      public var _order:BattleTurnOrder;
      
      public var _participants:Vector.<IBattleEntity>;
      
      public var _turn:BattleTurn;
      
      private var _battleId:String;
      
      public var _localBattleOrder:int;
      
      public var turns:Vector.<BattleTurn>;
      
      private var _isOnline:Boolean;
      
      private var _battleFinished:Boolean;
      
      private var _interact:IBattleEntity;
      
      public var _ability:BattleAbility;
      
      public var chat:Chat;
      
      private var _parentFsm:Fsm;
      
      public var battleCreateData:BattleCreateData;
      
      public var _unitsReadyToPromote:Vector.<String>;
      
      public var _unitsInjured:Vector.<String>;
      
      private var surrendered:Boolean;
      
      public var kills:int;
      
      public var firstStrike:Boolean;
      
      public var startingAchievements:Dictionary;
      
      public var startingItems:Dictionary;
      
      public var forceKillAll:Boolean = false;
      
      private var _helperShell:BattleFsm_Shell;
      
      public var _finishedData:BattleFinishedData;
      
      public var _cleanedup:Boolean;
      
      private var _eatAllSubsequent:Dictionary;
      
      public var nextTurnSuspended:Boolean;
      
      public var _halted:Boolean;
      
      public var _aborted:Boolean;
      
      private var _turnMove:IBattleMove;
      
      private var _abilityTargetSet:BattleTargetSet;
      
      private var exited:Boolean;
      
      public var _respawnedBattle:Boolean;
      
      public function BattleFsm(param1:Session, param2:IBattleBoard, param3:ILogger, param4:BattleFsmConfig, param5:BattleCreateData, param6:int, param7:Boolean, param8:Chat, param9:Fsm)
      {
         var _loc10_:Saga = null;
         this._participants = new Vector.<IBattleEntity>();
         this.turns = new Vector.<BattleTurn>();
         this._unitsReadyToPromote = new Vector.<String>();
         this._unitsInjured = new Vector.<String>();
         this.startingAchievements = new Dictionary();
         this.startingItems = new Dictionary();
         this._eatAllSubsequent = new Dictionary();
         super("BattleFsm",param3);
         BattleFsmConfig.reset();
         BattleFsmConfig.sceneEnableAi = true;
         BattleTurnCmdAction.SUPPRESS_TURN_END = false;
         this._isOnline = param7;
         this.battleCreateData = param5;
         if(param5 != null)
         {
            this._battleId = param5.battle_id;
         }
         if(!this._battleId && param7)
         {
            throw new ArgumentError("Invalid battleId for online battle.");
         }
         this._localBattleOrder = param6;
         this._session = param1;
         this.board = param2;
         this.config = param4;
         this.order = new BattleTurnOrder(param3,Saga.instance,param2);
         this.chat = param8;
         this._parentFsm = param9;
         this.setSagaTurnNumber();
         param2.addEventListener(BattleBoardEvent.BOARD_ENTITY_KILLING_EFFECT,this.killingEffectHandler);
         param2.addEventListener(BattleBoardEvent.BOARD_ENTITY_DAMAGED,this.entityDamagedHandler);
         param2.addEventListener(BattleBoardEvent.BOARD_TILE_CONFIGURATION,this.boardTileConfigurationHandler);
         this.order.addEventListener(BattleTurnOrderEvent.PILLAGE,this.pillageHandler);
         if(!this._isOnline)
         {
            param4.deployTimeoutMs = 0;
            _loc10_ = Saga.instance;
            if(Boolean(_loc10_) && _loc10_.isSurvival)
            {
               param4.deployTimeoutMs = _loc10_.survivalDeploymentTimerSec * 1000;
            }
         }
         registerState(BattleStateRespawn);
         registerState(BattleStateWaveRespawn);
         registerState(BattleStateWaveRedeploy);
         registerState(BattleStateWaveRedeploy_Prepare);
         registerState(BattleStateWaveRedeploy_Prepare_Tutorial);
         registerState(BattleStateWaveRedeploy_Assemble);
         registerState(BattleStateWaveRespawn_ResetCamera);
         registerState(BattleStateWaveRespawn_Complete);
         registerState(BattleStateDeploy);
         registerState(BattleStateFinish);
         registerState(BattleStateFinished);
         registerState(BattleStateStart);
         registerState(BattleStateError);
         registerState(BattleStateAborted);
         registerState(BattleStateNextTurn);
         registerState(BattleStateTurnAi);
         registerState(BattleStateTurnLocal);
         registerState(BattleStateTurnRemote);
         registerState(BattleStateSurrender);
         registerState(BattleStateInit);
         registerTransition(BattleStateTurnAi,BattleStateNextTurn,TRANS_COMPLETE);
         registerTransition(BattleStateTurnLocal,BattleStateNextTurn,TRANS_COMPLETE);
         registerTransition(BattleStateTurnRemote,BattleStateNextTurn,TRANS_COMPLETE);
         registerTransition(BattleStateDeploy,BattleStateStart,TRANS_COMPLETE);
         registerTransition(BattleStateStart,BattleStateNextTurn,TRANS_COMPLETE);
         registerTransition(BattleStateRespawn,BattleStateNextTurn,TRANS_COMPLETE);
         registerTransition(BattleStateWaveRedeploy,BattleStateWaveRedeploy_Prepare,TRANS_COMPLETE);
         registerTransition(BattleStateWaveRedeploy_Assemble,BattleStateWaveRespawn,TRANS_COMPLETE);
         registerTransition(BattleStateWaveRespawn,BattleStateWaveRespawn_ResetCamera,TRANS_COMPLETE);
         registerTransition(BattleStateWaveRespawn_ResetCamera,BattleStateWaveRespawn_Complete,TRANS_COMPLETE);
         registerTransition(BattleStateWaveRespawn_Complete,BattleStateNextTurn,TRANS_COMPLETE);
         registerTransition(BattleStateSurrender,BattleStateFinish,TRANS_COMPLETE);
         registerTransition(BattleStateFinish,BattleStateFinished,TRANS_COMPLETE);
         registerTransition(BattleStateInit,BattleStateDeploy,TRANS_COMPLETE);
         registerTransition(null,BattleStateError,TRANS_FAILED);
         initialState = BattleStateInit;
         this._helperShell = new BattleFsm_Shell(this);
         this.surrendered = false;
         this.collectStartingData();
      }
      
      private function collectStartingData() : void
      {
         var _loc3_:Item = null;
         var _loc4_:Vector.<String> = null;
         var _loc5_:String = null;
         var _loc1_:Saga = Saga.instance;
         if(!_loc1_ || !_loc1_.caravan)
         {
            return;
         }
         var _loc2_:Vector.<Item> = _loc1_.caravan._legend._items.items;
         for each(_loc3_ in _loc2_)
         {
            this.startingItems[_loc3_.id] = true;
         }
         _loc4_ = SagaAchievements.impl.unlocked;
         for each(_loc5_ in _loc4_)
         {
            this.startingAchievements[_loc5_] = true;
         }
      }
      
      public function get finishedData() : BattleFinishedData
      {
         return this._finishedData;
      }
      
      public function setFinishedData(param1:BattleFinishedData) : void
      {
         this._finishedData = param1;
      }
      
      private function pillageHandler(param1:BattleTurnOrderEvent) : void
      {
         dispatchEvent(new BattleFsmEvent(BattleFsmEvent.PILLAGE));
      }
      
      private function entityDamagedHandler(param1:BattleBoardEvent) : void
      {
         if(!this.firstStrike)
         {
            this.firstStrike = true;
            dispatchEvent(new BattleFsmEvent(BattleFsmEvent.FIRST_STRIKE));
         }
      }
      
      private function killingEffectHandler(param1:BattleBoardEvent) : void
      {
         var _loc6_:BattleTxnKillSend = null;
         var _loc2_:IBattleEntity = param1.entity;
         if(!_loc2_ || !_loc2_.killingEffect)
         {
            logger.error("killingEffectHandler with null entity=" + _loc2_ + " or null killingEffect");
            logger.error(new IllegalOperationError().getStackTrace());
            return;
         }
         var _loc3_:IBattleAbility = _loc2_.killingEffect.ability;
         var _loc4_:IBattleAbility = !!_loc3_ ? _loc3_.root : null;
         var _loc5_:IBattleEntity = !!_loc4_ ? _loc4_.caster : null;
         if(!_loc5_)
         {
            logger.error("killingEffectHandler with null caster, " + _loc2_ + " or null killingEffect");
         }
         if(this.isOnline)
         {
            _loc6_ = new BattleTxnKillSend(this,!!this.turn ? this.turn.number : -1,_loc2_,_loc5_,logger);
            _loc6_.send(this.session.communicator);
         }
         ++this.kills;
         dispatchEvent(new BattleFsmEvent(BattleFsmEvent.KILLS));
      }
      
      override protected function cleanup() : void
      {
         var _loc1_:IBattleParty = null;
         this._cleanedup = true;
         if(this._helperShell)
         {
            this._helperShell.cleanup();
            this._helperShell = null;
         }
         PathFloodSolver.clearCache();
         SagaAchievements.clearLocals();
         this.ability = null;
         this.turn = null;
         this.board.removeEventListener(BattleBoardEvent.BOARD_ENTITY_DAMAGED,this.entityDamagedHandler);
         this.board.removeEventListener(BattleBoardEvent.BOARD_ENTITY_KILLING_EFFECT,this.killingEffectHandler);
         this.board.removeEventListener(BattleBoardEvent.BOARD_TILE_CONFIGURATION,this.boardTileConfigurationHandler);
         this.order.removeEventListener(BattleTurnOrderEvent.PILLAGE,this.pillageHandler);
         this.session.communicator.removePollTimeRequirement(this);
         if(!this.battleFinished)
         {
            if(this.isOnline)
            {
               _loc1_ = this.board.getPartyById(this.session.credentials.userId.toString());
               if(!_loc1_.surrendered)
               {
                  _loc1_.surrendered = true;
                  new BattleTxnSurrenderSend(this.battleId,this.session.credentials,null,this,logger).send(this.session.communicator);
               }
               this.exitBattle();
            }
         }
         if(this._finishedData)
         {
            this._finishedData.cleanup();
            this._finishedData = null;
         }
         this._eatAllSubsequent = null;
         this._parentFsm = null;
         this.board = null;
         this.chat = null;
         this.config = null;
         if(this._order)
         {
            this._order.cleanup();
            this._order = null;
         }
         this._participants = null;
         this._session = null;
         this.turns = null;
         this._unitsReadyToPromote = null;
         this._unitsInjured = null;
         BattleMove.flushCache();
         super.cleanup();
      }
      
      override protected function handleCurrentChanged() : void
      {
         super.handleCurrentChanged();
         if(this.cleanedup || !this._parentFsm)
         {
            return;
         }
         this._parentFsm.popMessages();
         if(currentClass == BattleStateDeploy)
         {
            dispatchEvent(new BattleFsmEvent(BattleFsmEvent.DEPLOY));
         }
      }
      
      override public function handleOneMessage(param1:Object) : Boolean
      {
         var _loc2_:BattleSyncData = null;
         var _loc3_:BaseBattleTurnData = null;
         var _loc4_:IBattleParty = null;
         var _loc5_:BattleAbortedData = null;
         var _loc6_:BattleSurrenderData = null;
         var _loc7_:IBattleParty = null;
         var _loc8_:IBattleParty = null;
         var _loc9_:BattleExitData = null;
         var _loc10_:IBattleParty = null;
         var _loc11_:int = 0;
         if(!current)
         {
            return false;
         }
         if(param1.battle_id == undefined)
         {
            return false;
         }
         if(param1.battleId != undefined && param1.battleId != this._battleId || param1.battle_id != undefined && param1.battle_id != this._battleId)
         {
            if(logger.isDebugEnabled)
            {
               logger.debug("BattleFsm " + this.battleId + " SILENTLY EAT WRONG BATTLE " + JSON.stringify(param1));
            }
            return true;
         }
         if(logger.isDebugEnabled)
         {
            logger.debug("BattleFsm " + this.battleId + " HANDLE MSG " + (!!this.turn ? this.turn.number : -1) + " current " + currentClass + ": " + param1["class"] + ", battle_id=" + param1.battle_id);
         }
         if(param1["class"] == "tbs.srv.battle.data.client.BattleSyncData")
         {
            _loc2_ = new BattleSyncData();
            _loc2_.parseJson(param1,logger);
            if(this.handleSync(_loc2_))
            {
               return true;
            }
         }
         else
         {
            if(param1["class"] == "tbs.srv.battle.data.client.BattleAbortData")
            {
               _loc3_ = new BaseBattleTurnData();
               _loc3_.parseJson(param1,logger);
               logger.info("BattleFsm GOT ABORT from " + _loc3_);
               if(_loc3_.battle_id)
               {
                  _loc4_ = this.board.getPartyById(_loc3_.user_id.toString());
                  if(_loc4_)
                  {
                     _loc4_.aborted = true;
                  }
               }
               return true;
            }
            if(param1["class"] == "tbs.srv.battle.data.client.BattleAbortedData")
            {
               _loc5_ = new BattleAbortedData();
               _loc5_.parseJson(param1,logger);
               logger.info("BattleFsm GOT ABORTED " + _loc5_);
               transitionTo(BattleStateAborted,current.data);
               return true;
            }
            if(param1["class"] == "tbs.srv.battle.data.client.BattleSurrenderData")
            {
               _loc6_ = new BattleSurrenderData();
               _loc6_.parseJson(param1,logger);
               _loc7_ = this.board.getPartyById(_loc6_.user_id.toString());
               if(_loc7_.surrendered)
               {
                  return true;
               }
               _loc7_.surrendered = true;
               logger.info("SURRENDERING " + _loc7_ + " duly noted");
               _loc8_ = this.board.getPartyById(this.session.credentials.userId.toString());
               logger.info("BattleFsm.handleOneMsgInternal VICTORIOUS_TEAM=" + _loc8_.team);
               current.data.setValue(BattleStateDataEnum.VICTORIOUS_TEAM,_loc8_.team);
               transitionTo(BattleStateFinish,current.data);
               return true;
            }
            if(param1["class"] == "tbs.srv.battle.data.client.BattleExitData")
            {
               _loc9_ = new BattleExitData();
               _loc9_.parseJson(param1,logger);
               logger.info("BattleFsm GOT EXIT " + _loc9_);
               _loc10_ = this.board.getPartyById(_loc9_.user_id.toString());
               dispatchEvent(new BattleFsmPlayerExitEvent(BattleFsmPlayerExitEvent.PLAYER_EXIT,_loc9_.user_id,_loc10_.partyName));
               return true;
            }
         }
         if(param1.turn != undefined)
         {
            _loc11_ = int(param1.turn);
            if(!this.turn || _loc11_ > this.turn.number)
            {
               return false;
            }
            if(_loc11_ < this.turn.number)
            {
               if(logger.isDebugEnabled)
               {
                  logger.debug("BattleFsm SILENTLY EAT OLD TURN " + JSON.stringify(param1));
               }
               return true;
            }
         }
         if(!super.handleOneMessage(param1))
         {
            if(param1["class"] in this._eatAllSubsequent)
            {
               logger.info("BattleFsm.handleOneMessage " + this + " eating subsequent " + JSON.stringify(param1));
               return true;
            }
            return false;
         }
         return true;
      }
      
      public function eatAllSubsequent(param1:String) : void
      {
         if(logger.isDebugEnabled)
         {
            logger.debug("BattleStateInit.eatAllSubsequent " + param1);
         }
         this._eatAllSubsequent[param1] = true;
      }
      
      public function stopEatingSubsequent(param1:String) : void
      {
         if(logger.isDebugEnabled)
         {
            logger.debug("BattleStateInit.stopEatingSubsequent " + param1);
         }
         delete this._eatAllSubsequent[param1];
      }
      
      private function handleSync(param1:BattleSyncData) : Boolean
      {
         var _loc4_:int = 0;
         if(currentClass == BattleStateError || currentClass == BattleStateAborted)
         {
            return false;
         }
         var _loc2_:int = param1.turn;
         var _loc3_:int = param1.hash;
         if(this.turns.length > _loc2_)
         {
            _loc4_ = this.turns[_loc2_].hash;
            if(_loc3_ != _loc4_)
            {
               logger.error("BattleSyncData DIVERGENCE detected at turn " + _loc2_);
               errors.push("BattleSyncData DIVERGENCE detected at turn " + _loc2_);
               transitionTo(BattleStateError,current.data);
            }
            else if(logger.isDebugEnabled)
            {
               logger.debug("BattleSyncData SYNC OK turn " + _loc2_);
            }
            return true;
         }
         if(logger.isDebugEnabled)
         {
            logger.debug("BattleSyncData SYNC WAIT turn " + _loc2_);
         }
         return false;
      }
      
      override public function startFsm(param1:Object) : void
      {
         if(param1)
         {
            param1.setValue(BattleStateDataEnum.VICTORIOUS_TEAM,null);
         }
         super.startFsm(param1);
         if(this.isOnline)
         {
            this.session.communicator.setPollTimeRequirement(this,1000);
         }
      }
      
      public function nextTurnSuspend() : void
      {
         if(!this.nextTurnSuspended)
         {
            logger.info("BattleFsm.nextTurnSuspend");
            this.nextTurnSuspended = true;
         }
      }
      
      public function nextTurnResume() : void
      {
         var _loc1_:BattleStateNextTurn = null;
         if(this.nextTurnSuspended)
         {
            logger.info("BattleFsm.nextTurnResume");
            this.nextTurnSuspended = false;
            _loc1_ = current as BattleStateNextTurn;
            if(_loc1_)
            {
               _loc1_.handleNextTurnResume();
            }
         }
      }
      
      public function get aborted() : Boolean
      {
         return this._aborted;
      }
      
      public function get halted() : Boolean
      {
         return this._halted;
      }
      
      public function set aborted(param1:Boolean) : void
      {
         this._aborted = param1;
      }
      
      public function haltBattle() : void
      {
         if(!this.halted)
         {
            logger.info("BattleFsm.haltBattle");
            this._halted = true;
            this.turn = null;
         }
      }
      
      public function surrender() : void
      {
         if(!this.surrendered)
         {
            logger.info("BattleFsm.surrender");
            transitionTo(BattleStateSurrender,current.data);
            this.surrendered = true;
         }
      }
      
      public function abortBattle(param1:Boolean) : void
      {
         var _loc2_:StateData = null;
         var _loc3_:Saga = null;
         var _loc4_:String = null;
         if(AppInfo.terminating)
         {
            return;
         }
         if(!stopping && Boolean(current))
         {
            this._halted = false;
            this.aborted = true;
            logger.info("BattleFsm.abortBattle");
            if(currentClass == BattleStateFinish || currentClass == BattleStateFinished)
            {
               _loc3_ = this.board.getSaga() as Saga;
               if(_loc3_)
               {
                  _loc4_ = this.board.scene.def.url;
                  _loc3_.triggerBattleFinallyFinished(_loc4_);
               }
               return;
            }
            _loc2_ = current.data;
            if(param1)
            {
               _loc2_.setValue(BattleStateDataEnum.VICTORIOUS_TEAM,"0");
            }
            transitionTo(BattleStateFinish,_loc2_);
         }
      }
      
      public function get turn() : IBattleTurn
      {
         return this._turn;
      }
      
      public function get nextTurnNumber() : int
      {
         return !!this.turns ? int(this.turns.length) : 0;
      }
      
      public function set turn(param1:IBattleTurn) : void
      {
         if(this._turn == param1)
         {
            return;
         }
         if(param1)
         {
            if(param1.number != this.turns.length)
            {
               throw new IllegalOperationError("Attempt to set a turn with the wrong number: " + param1.number + ", expected: " + this.turns.length);
            }
         }
         if(this._turnMove)
         {
            this._turnMove.removeEventListener(BattleMoveEvent.COMMITTED,this.moveCommittedHandler);
            this._turnMove.removeEventListener(BattleMoveEvent.EXECUTED,this.moveExecutedHandler);
            this._turnMove.removeEventListener(BattleMoveEvent.INTERRUPTED,this.moveInterruptedHandler);
         }
         if(this._turn)
         {
            this._turn.removeEventListener(BattleTurnEvent.ABILITY,this.turnAbilityHandler);
            this._turn.removeEventListener(BattleTurnEvent.ABILITY_EXECUTING,this.turnAbilityExecutingHandler);
            this._turn.removeEventListener(BattleTurnEvent.ABILITY_TARGET,this.turnAbilityTargetHandler);
            this._turn.removeEventListener(BattleTurnEvent.ATTACK_MODE,this.turnAttackModeHandler);
            this._turn.removeEventListener(BattleTurnEvent.COMPLETE,this.turnCompleteHandler);
            this._turn.removeEventListener(BattleTurnEvent.COMMITTED,this.turnCommittedHandler);
            this._turn.removeEventListener(BattleTurnEvent.IN_RANGE,this.turnInRangeHandler);
            this._turn.cleanup();
         }
         this._turn = param1 as BattleTurn;
         this._turnMove = !!this._turn ? this._turn.move : null;
         if(this._turn)
         {
            this.turns.push(this._turn);
            this._turn.addEventListener(BattleTurnEvent.ABILITY,this.turnAbilityHandler);
            this._turn.addEventListener(BattleTurnEvent.ABILITY_EXECUTING,this.turnAbilityExecutingHandler);
            this._turn.addEventListener(BattleTurnEvent.ABILITY_TARGET,this.turnAbilityTargetHandler);
            this._turn.addEventListener(BattleTurnEvent.ATTACK_MODE,this.turnAttackModeHandler);
            this._turn.addEventListener(BattleTurnEvent.COMPLETE,this.turnCompleteHandler);
            this._turn.addEventListener(BattleTurnEvent.COMMITTED,this.turnCommittedHandler);
            this._turn.addEventListener(BattleTurnEvent.IN_RANGE,this.turnInRangeHandler);
            if(this._turnMove)
            {
               this._turn.move.addEventListener(BattleMoveEvent.COMMITTED,this.moveCommittedHandler);
               this._turn.move.addEventListener(BattleMoveEvent.EXECUTED,this.moveExecutedHandler);
               this._turn.move.addEventListener(BattleMoveEvent.INTERRUPTED,this.moveInterruptedHandler);
            }
            if(this._interact)
            {
               this._interact.hovering = false;
               this._interact = null;
            }
         }
         this.ability = !!this._turn ? this._turn.ability : null;
         if(this._turn)
         {
            logger.info("BattleFsm turnNumber=" + this._turn.number + " ent=" + (!!this._turn.entity ? this._turn.entity.id : null));
         }
         if(!this.cleanedup)
         {
            dispatchEvent(new BattleFsmEvent(BattleFsmEvent.TURN));
         }
         this.setSagaTurnNumber();
      }
      
      private function setSagaTurnNumber() : void
      {
         var _loc1_:ISaga = this.board.getSaga();
         if(_loc1_)
         {
            _loc1_.setVar(SagaVar.VAR_BATTLE_TURN,!!this._turn ? this._turn.number : -1);
         }
      }
      
      private function turnAbilityExecutingHandler(param1:BattleTurnEvent) : void
      {
         dispatchEvent(new BattleFsmEvent(BattleFsmEvent.TURN_ABILITY_EXECUTING));
      }
      
      private function moveInterruptedHandler(param1:BattleMoveEvent) : void
      {
         dispatchEvent(new BattleFsmEvent(BattleFsmEvent.TURN_MOVE_INTERRUPTED));
      }
      
      private function moveExecutedHandler(param1:BattleMoveEvent) : void
      {
         dispatchEvent(new BattleFsmEvent(BattleFsmEvent.TURN_MOVE_EXECUTED));
      }
      
      private function moveCommittedHandler(param1:BattleMoveEvent) : void
      {
         dispatchEvent(new BattleFsmEvent(BattleFsmEvent.TURN_MOVE_COMMITTED));
      }
      
      private function turnAbilityTargetHandler(param1:BattleTurnEvent) : void
      {
         dispatchEvent(new BattleFsmEvent(BattleFsmEvent.TURN_ABILITY_TARGETS));
      }
      
      private function turnAttackModeHandler(param1:BattleTurnEvent) : void
      {
         dispatchEvent(new BattleFsmEvent(BattleFsmEvent.TURN_ATTACK));
      }
      
      private function turnAbilityHandler(param1:BattleTurnEvent) : void
      {
         this.ability = !!this._turn ? this._turn.ability : null;
         dispatchEvent(new BattleFsmEvent(BattleFsmEvent.TURN_ABILITY));
      }
      
      private function turnCompleteHandler(param1:BattleTurnEvent) : void
      {
         dispatchEvent(new BattleFsmEvent(BattleFsmEvent.TURN_COMPLETE));
      }
      
      private function turnCommittedHandler(param1:BattleTurnEvent) : void
      {
         dispatchEvent(new BattleFsmEvent(BattleFsmEvent.TURN_COMMITTED));
      }
      
      private function turnInRangeHandler(param1:BattleTurnEvent) : void
      {
         dispatchEvent(new BattleFsmEvent(BattleFsmEvent.TURN_IN_RANGE));
      }
      
      public function get isOnline() : Boolean
      {
         return this._isOnline;
      }
      
      public function get interact() : IBattleEntity
      {
         return this._interact;
      }
      
      public function set interact(param1:IBattleEntity) : void
      {
         if(this._interact == param1)
         {
            return;
         }
         this.setInteractNoEvent(param1);
         dispatchEvent(new BattleFsmEvent(BattleFsmEvent.INTERACT));
      }
      
      public function setInteractNoEvent(param1:IBattleEntity) : void
      {
         if(this._turn)
         {
            if(!this._turn.committed)
            {
               this._turn.setTurnInteract(param1);
            }
         }
         if(this._interact != param1)
         {
            if(Boolean(this._interact) && PlatformInput.lastInputGp)
            {
               this._interact.hovering = false;
            }
            this._interact = param1;
            if(Boolean(this._interact) && PlatformInput.lastInputGp)
            {
               this._interact.hovering = true;
            }
         }
      }
      
      public function get ability() : BattleAbility
      {
         return this._ability;
      }
      
      public function set ability(param1:BattleAbility) : void
      {
         if(this._ability == param1)
         {
            return;
         }
         if(this._abilityTargetSet)
         {
            this._abilityTargetSet.removeEventListener(Event.CHANGE,this.abilityTargetHandler);
         }
         this._ability = param1;
         this._abilityTargetSet = !!this._ability ? this._ability.targetSet : null;
         if(this._abilityTargetSet)
         {
            this._abilityTargetSet.addEventListener(Event.CHANGE,this.abilityTargetHandler);
         }
      }
      
      private function abilityTargetHandler(param1:Event) : void
      {
         dispatchEvent(new BattleFsmEvent(BattleFsmEvent.TURN_ABILITY_TARGETS));
      }
      
      public function get battleId() : String
      {
         return this._battleId;
      }
      
      public function exitBattle() : void
      {
         var _loc1_:BattleTxnExitSend = null;
         if(!this.exited)
         {
            this.exited = true;
            if(this.isOnline)
            {
               _loc1_ = new BattleTxnExitSend(this.battleId,this.session.credentials,null,this,logger);
               _loc1_.send(this.session.communicator);
            }
         }
      }
      
      public function respawnBattle(param1:int, param2:String, param3:String, param4:String) : void
      {
         this.battleFinished = false;
         this._finishedData = null;
         this._respawnedBattle = true;
         var _loc5_:StateData = current.data;
         _loc5_.setValue(BattleStateDataEnum.BATTLE_RESPAWN_QUOTA,param1);
         _loc5_.setValue(BattleStateDataEnum.BATTLE_RESPAWN_DEPLOYMENT,param2);
         _loc5_.setValue(BattleStateDataEnum.BATTLE_RESPAWN_TAG,param4);
         _loc5_.setValue(BattleStateDataEnum.BATTLE_RESPAWN_BUCKET,param3);
         transitionTo(BattleStateRespawn,current.data);
         dispatchEvent(new BattleFsmEvent(BattleFsmEvent.BATTLE_RESPAWN));
      }
      
      public function killall() : Boolean
      {
         var _loc5_:IBattleParty = null;
         var _loc6_:Vector.<IBattleEntity> = null;
         var _loc7_:IBattleEntity = null;
         var _loc8_:int = 0;
         var _loc9_:int = 0;
         var _loc10_:Rng = null;
         var _loc11_:int = 0;
         var _loc12_:int = 0;
         var _loc13_:IBattleEntity = null;
         var _loc14_:Stats = null;
         if(this.isOnline)
         {
            return false;
         }
         if(this.cleanedup || !this.board || !this.board.boardSetup)
         {
            return false;
         }
         if(!this._turn)
         {
            return false;
         }
         SagaCheat.devCheat("killall");
         this.forceKillAll = true;
         if(Boolean(this.board.scenario) && !this.board.scenario.complete)
         {
            this.board.scenario.doCompleteAll();
         }
         var _loc1_:IBattleEntity = this._turn.entity;
         var _loc2_:Stats = !!_loc1_ ? _loc1_.def.stats : null;
         var _loc3_:int = !!_loc2_ ? _loc2_.getBase(StatType.KILLS) : 0;
         var _loc4_:int = 0;
         while(_loc4_ < this.board.numParties)
         {
            _loc5_ = this.board.getParty(_loc4_);
            if(!_loc5_.isPlayer)
            {
               _loc6_ = _loc5_.getAllMembers(null);
               for each(_loc7_ in _loc6_)
               {
                  if(_loc7_.alive && Boolean(_loc7_.enabled) && Boolean(_loc7_.active))
                  {
                     this.killOneTarget(_loc7_);
                     if(!this.board || this.cleanedup)
                     {
                        this.forceKillAll = false;
                        return true;
                     }
                  }
               }
            }
            _loc4_++;
         }
         if(_loc2_)
         {
            _loc8_ = _loc2_.getBase(StatType.KILLS);
            _loc9_ = _loc8_ - _loc3_;
            if(_loc9_ > 0)
            {
               _loc2_.setBase(StatType.KILLS,_loc3_);
               _loc10_ = this.board.abilityManager.rng;
               _loc5_ = _loc1_.party;
               _loc11_ = 0;
               while(_loc11_ < _loc9_)
               {
                  _loc12_ = _loc10_.nextMinMax(0,_loc5_.numMembers - 1);
                  _loc13_ = _loc5_.getMember(_loc12_);
                  _loc14_ = _loc13_.def.stats;
                  _loc14_.setBase(StatType.KILLS,_loc14_.getBase(StatType.KILLS) + 1);
                  _loc11_++;
               }
            }
            _loc1_.endTurn(false,"BattleFsm.killall",false);
         }
         if(Boolean(this.board) && Boolean(this.board.abilityManager))
         {
            this.board.abilityManager.forceCompleteAbilities();
         }
         this.forceKillAll = false;
         return true;
      }
      
      public function killOneTarget(param1:IBattleEntity) : void
      {
         if(this.isOnline)
         {
            return;
         }
         if(!this.board || !this.board.boardSetup)
         {
            return;
         }
         if(!this.turn || !this.turn.entity)
         {
            return;
         }
         var _loc2_:IBattleAbilityDef = this._turn.entity.board.abilityManager.getFactory.fetchIBattleAbilityDef("abl_kill");
         var _loc3_:BattleAbility = new BattleAbility(this.turn.entity,_loc2_,this.board.abilityManager);
         _loc3_.targetSet.setTarget(param1);
         _loc3_.execute(null);
      }
      
      public function killTurnInteract() : void
      {
         if(this.turn)
         {
            this.killOneTarget(this._turn.turnInteract);
         }
      }
      
      public function get battleFinished() : Boolean
      {
         return this._battleFinished;
      }
      
      public function set battleFinished(param1:Boolean) : void
      {
         if(this._battleFinished == param1)
         {
            return;
         }
         this._battleFinished = param1;
         dispatchEvent(new BattleFsmEvent(BattleFsmEvent.BATTLE_FINISHED));
      }
      
      public function findNextRangeTile(param1:Tile, param2:int, param3:int) : Tile
      {
         if(this._turn)
         {
            return this._turn.findNextRangeTile(param1,param2,param3);
         }
         return null;
      }
      
      private function boardTileConfigurationHandler(param1:BattleBoardEvent) : void
      {
         BattleMove.flushCache();
      }
      
      public function noticeInjury(param1:String) : void
      {
         if(this._unitsInjured.indexOf(param1) < 0)
         {
            this._unitsInjured.push(param1);
         }
      }
      
      public function get order() : IBattleTurnOrder
      {
         return this._order;
      }
      
      public function set order(param1:IBattleTurnOrder) : void
      {
         this._order = param1 as BattleTurnOrder;
      }
      
      public function get participants() : Vector.<IBattleEntity>
      {
         return this._participants;
      }
      
      public function get unitsReadyToPromote() : Vector.<String>
      {
         return this._unitsReadyToPromote;
      }
      
      public function get unitsInjured() : Vector.<String>
      {
         return this._unitsInjured;
      }
      
      public function get respawnedBattle() : Boolean
      {
         return this._respawnedBattle;
      }
      
      public function get cleanedup() : Boolean
      {
         return this._cleanedup;
      }
      
      public function get localBattleOrder() : int
      {
         return this._localBattleOrder;
      }
      
      public function get session() : Session
      {
         return this._session;
      }
      
      public function get activeEntity() : IBattleEntity
      {
         return !!this._turn ? this._turn._entity : null;
      }
      
      public function get waveDeploymentEnabled() : Boolean
      {
         return BattleFsmConfig.guiWaveDeployEnabled;
      }
      
      public function getBoard() : IBattleBoard
      {
         return this.board;
      }
      
      public function get showDeploymentId() : String
      {
         var _loc1_:BaseBattleState = current as BaseBattleState;
         return !!_loc1_ ? _loc1_.showDeploymentId : null;
      }
      
      public function get showRespawnDeploymentId() : String
      {
         var _loc1_:BaseBattleState = current as BaseBattleState;
         return !!_loc1_ ? _loc1_.showRespawnDeploymentId : null;
      }
      
      public function skipTurn(param1:String, param2:Boolean) : void
      {
         logger.info("BattleFsm.skipTurn " + param1);
         var _loc3_:BattleStateTurnBase = current as BattleStateTurnBase;
         if(_loc3_)
         {
            _loc3_.skip(true,param1,param2);
         }
      }
   }
}
