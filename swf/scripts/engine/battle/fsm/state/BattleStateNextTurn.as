package engine.battle.fsm.state
{
   import engine.battle.board.model.BattlePartyType;
   import engine.battle.board.model.IBattleEntity;
   import engine.battle.fsm.BattleFsm;
   import engine.battle.fsm.BattleFsmConfig;
   import engine.battle.fsm.BattleTurn;
   import engine.battle.fsm.BattleTurnOrder;
   import engine.battle.fsm.BattleTurnParty;
   import engine.battle.fsm.BattleTurnTeam;
   import engine.battle.fsm.txn.BattleTxnTurnInitSend;
   import engine.core.fsm.StateData;
   import engine.core.fsm.StatePhase;
   import engine.core.logging.ILogger;
   import engine.math.Hash;
   import engine.saga.Saga;
   import engine.stat.def.StatType;
   import engine.stat.model.Stat;
   import flash.errors.IllegalOperationError;
   
   public class BattleStateNextTurn extends BaseBattleState
   {
      
      public static const SYNC_STATS:Array = [StatType.STRENGTH,StatType.ARMOR,StatType.WILLPOWER,StatType.ARMOR_BREAK,StatType.STRENGTH_ATTACK,StatType.MIN_STRENGTH_ATTACK,StatType.PUNCTURE_ATTACK_BONUS,StatType.MALICE_ATTACK_BONUS,StatType.BRINGTHEPAIN_COUNTER_BONUS,StatType.EXERTION,StatType.RESIST_STRENGTH,StatType.RESIST_ARMOR];
       
      
      private var txnSend:BattleTxnTurnInitSend;
      
      private var turnNumber:int;
      
      private var hash:int;
      
      private var _hasSagaTriggered:Boolean;
      
      private var _inNextTurn:Boolean;
      
      private var hashStr:String;
      
      public function BattleStateNextTurn(param1:StateData, param2:BattleFsm, param3:ILogger, param4:int = 0)
      {
         super(param1,param2,param3,param4,700);
         this.turnNumber = battleFsm.nextTurnNumber;
      }
      
      public function handleNextTurnResume() : void
      {
         this.nextTurn();
      }
      
      private function nextTurn() : void
      {
         var _loc4_:Class = null;
         var _loc6_:IBattleEntity = null;
         var _loc7_:BattleTurnTeam = null;
         var _loc8_:BattleTurnParty = null;
         var _loc9_:Saga = null;
         if(battleFsm.halted)
         {
            return;
         }
         if(battleFsm.nextTurnSuspended)
         {
            return;
         }
         if(this._inNextTurn)
         {
            return;
         }
         var _loc1_:BattleTurnOrder = battleFsm.order as BattleTurnOrder;
         var _loc2_:IBattleEntity = _loc1_.aliveOrder[0];
         if(_loc2_.cleanedup)
         {
            logger.error("BattleStateNextTurn.nextTurn current is cleanedup");
            return;
         }
         if(!_loc2_.party)
         {
            logger.error("BattleStateNextTurn.nextTurn current has no party");
            return;
         }
         if(logger.isDebugEnabled)
         {
            logger.debug("BattleStateNextTurn.nextTurn turn=" + this.turnNumber + " current=" + _loc2_);
            logger.debug("--Pillage=" + _loc1_.pillage);
            logger.debug("--Alive Order--");
            for each(_loc6_ in _loc1_.aliveOrder)
            {
               logger.debug("    " + _loc6_ + (!_loc6_.alive ? "   **DEAD**" : ""));
            }
            logger.debug("--Current Team-- " + _loc1_.currentTeam);
            for each(_loc7_ in _loc1_._turnTeams)
            {
               logger.debug("--Team-- " + _loc7_);
               for each(_loc8_ in _loc7_.turnParties)
               {
                  logger.debug("--------Party " + _loc8_);
                  for each(_loc6_ in _loc8_.members)
                  {
                     logger.debug("         " + _loc6_ + (!_loc6_.alive ? "   **DEAD**" : ""));
                  }
               }
            }
         }
         var _loc3_:BattlePartyType = _loc2_.party.type;
         if(!this._hasSagaTriggered)
         {
            _loc9_ = battleFsm.board.getSaga() as Saga;
            if(_loc9_)
            {
               this._inNextTurn = true;
               this._hasSagaTriggered = true;
               _loc9_.triggerBattleNextTurnBegin(_loc2_);
               this._inNextTurn = false;
               if(battleFsm.nextTurnSuspended || battleFsm.halted || battleFsm._finishedData || battleFsm.aborted)
               {
                  return;
               }
            }
         }
         switch(_loc3_)
         {
            case BattlePartyType.LOCAL:
               if(BattleFsmConfig.playerAi)
               {
                  _loc4_ = BattleStateTurnAi;
               }
               else
               {
                  _loc4_ = BattleStateTurnLocal;
               }
               break;
            case BattlePartyType.REMOTE:
               _loc4_ = BattleStateTurnRemote;
               break;
            case BattlePartyType.AI:
               if(BattleFsmConfig.aiEnabled)
               {
                  _loc4_ = BattleStateTurnAi;
               }
               else
               {
                  _loc4_ = BattleStateTurnLocal;
               }
               break;
            default:
               throw new IllegalOperationError("not handled party type " + _loc3_);
         }
         var _loc5_:* = _loc4_ == BattleStateTurnAi;
         battleFsm.turn = new BattleTurn(_loc2_,this.turnNumber,this.hash,logger,_loc5_);
         fsm.transitionTo(_loc4_,data);
      }
      
      override protected function handleEnteredState() : void
      {
         var _loc1_:BattleTurnTeam = null;
         var _loc2_:IBattleEntity = null;
         var _loc3_:IBattleEntity = null;
         var _loc4_:Boolean = false;
         var _loc5_:BattleTurnParty = null;
         super.handleEnteredState();
         battleFsm.order.pruneDeadEntities();
         for each(_loc1_ in battleFsm.order.turnTeams)
         {
            _loc4_ = true;
            for each(_loc5_ in _loc1_.turnParties)
            {
               if(_loc5_.party.numActive == 1 || _loc5_.members.length > 1)
               {
                  _loc4_ = false;
                  break;
               }
            }
            if(_loc4_)
            {
               battleFsm.order.commencePillaging(false,true);
               break;
            }
         }
         if(battleFsm.turn)
         {
            _loc2_ = battleFsm._turn._entity;
         }
         _loc3_ = battleFsm.order.turnOrderNextTurn(_loc2_);
         if(!_loc3_)
         {
            battleFsm.addErrorMsg("Ragnarok Error");
            phase = StatePhase.FAILED;
            return;
         }
         if(battleFsm.order.numTeams == 1)
         {
            battleFsm.addErrorMsg("Nidhogg Error");
            phase = StatePhase.FAILED;
            return;
         }
         if(battleFsm.isOnline)
         {
            this.computeHash();
            this.txnSend = new BattleTxnTurnInitSend(battleFsm.battleId,this.turnNumber,this.hashStr,this.hash,_loc3_,battleFsm.session.credentials,this.initSendHandler,battleFsm,logger);
            addTxn(this.txnSend);
            this.txnSend.send(battleFsm.session.communicator,null,0);
         }
         else
         {
            this.nextTurn();
         }
      }
      
      private function initSendHandler(param1:BattleTxnTurnInitSend) : void
      {
         if(param1.success)
         {
            this.nextTurn();
         }
      }
      
      private function computeHashStr() : void
      {
         var _loc2_:int = 0;
         var _loc5_:BattleTurnTeam = null;
         var _loc6_:BattleTurnParty = null;
         var _loc8_:String = null;
         var _loc9_:int = 0;
         var _loc10_:String = null;
         var _loc11_:StatType = null;
         var _loc12_:Stat = null;
         var _loc13_:String = null;
         var _loc1_:IBattleEntity = !!battleFsm.turn ? battleFsm.turn.entity : null;
         this.hashStr = "ending_turn=" + (this.turnNumber - 1) + " ending_entity=" + _loc1_ + " executedAbilityId=" + battleFsm.board.abilityManager.nextExecutedId + "\n";
         var _loc3_:int = 0;
         var _loc4_:IBattleEntity = null;
         var _loc7_:Vector.<IBattleEntity> = battleFsm.order.getAliveParticipants(null);
         for each(_loc4_ in _loc7_)
         {
            _loc3_ = Math.max(_loc3_,_loc4_.id.length);
         }
         _loc8_ = "                         ";
         for each(_loc4_ in _loc7_)
         {
            this.hashStr += "sync=" + battleFsm.battleId + " " + _loc4_.id;
            _loc9_ = _loc3_ - Number(_loc4_.id.length);
            if(_loc9_ > 0)
            {
               this.hashStr += _loc8_.substr(0,_loc9_);
            }
            _loc10_ = _loc4_.tile.toString();
            this.hashStr += " tile=" + _loc10_;
            _loc9_ = 8 - _loc10_.length;
            if(_loc9_ > 0)
            {
               this.hashStr += _loc8_.substr(0,_loc9_);
            }
            for each(_loc11_ in SYNC_STATS)
            {
               _loc12_ = _loc4_.stats.getStat(_loc11_,false);
               if(_loc12_)
               {
                  _loc13_ = _loc12_.value.toString();
                  this.hashStr += "  " + _loc12_.type.abbrev + "=" + _loc13_;
                  _loc9_ = 3 - _loc13_.length;
                  if(_loc9_ > 0)
                  {
                     this.hashStr += _loc8_.substr(0,_loc9_);
                  }
               }
            }
            this.hashStr += "\n";
         }
      }
      
      private function computeHash() : int
      {
         this.computeHashStr();
         this.hash = Hash.DJBHash(this.hashStr);
         if(logger.isDebugEnabled)
         {
            logger.debug("Turn Hash: " + this.hash + "\n" + this.hashStr);
         }
         return this.hash;
      }
   }
}
