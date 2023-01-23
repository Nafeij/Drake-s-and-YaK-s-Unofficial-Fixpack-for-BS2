package engine.battle.fsm
{
   import engine.battle.board.model.IBattleBoard;
   import engine.battle.board.model.IBattleEntity;
   import engine.battle.entity.model.BattleEntityEvent;
   import engine.battle.sim.IBattleParty;
   import engine.core.logging.ILogger;
   import engine.saga.ISaga;
   import engine.saga.SagaVar;
   import flash.errors.IllegalOperationError;
   import flash.events.EventDispatcher;
   
   public class BattleTurnOrder extends EventDispatcher implements IBattleTurnOrder
   {
      
      public static var SUPPRESS_PILLAGE:Boolean;
       
      
      private var _index:int = -1;
      
      public var _turnTeams:Vector.<BattleTurnTeam>;
      
      public var _aliveOrder:Vector.<IBattleEntity>;
      
      private var _numTeamsRemaining:int = 0;
      
      private var _dirty:Boolean = true;
      
      private var logger:ILogger;
      
      public var currentTeam:BattleTurnTeam;
      
      private var _pillage:Boolean;
      
      private var _initialized:Boolean;
      
      private var saga:ISaga;
      
      private var _board:IBattleBoard;
      
      private var _didReset:Boolean;
      
      private var _keepPillage:Boolean;
      
      public var _freeTurn:IBattleEntity;
      
      public function BattleTurnOrder(param1:ILogger, param2:ISaga, param3:IBattleBoard)
      {
         this._turnTeams = new Vector.<BattleTurnTeam>();
         this._aliveOrder = new Vector.<IBattleEntity>();
         super();
         BattleTurnOrder.SUPPRESS_PILLAGE = false;
         this.logger = param1;
         this.saga = param2;
         var _loc4_:Boolean = Boolean(param2) && param2.isSurvival;
         if(_loc4_)
         {
            this._pillage = true;
            this._keepPillage = true;
         }
         this.updateSagaVars();
         this._board = param3;
         this._board.addEventListener(BattleEntityEvent.REMOVING,this.entityRemovingHandler);
      }
      
      public function get initialized() : Boolean
      {
         return this._initialized;
      }
      
      public function get activeEntity() : IBattleEntity
      {
         return Boolean(this._aliveOrder) && Boolean(this._aliveOrder.length) ? this._aliveOrder[0] : null;
      }
      
      public function cleanup() : void
      {
         if(this._board)
         {
            this._board.removeEventListener(BattleEntityEvent.REMOVING,this.entityRemovingHandler);
            this._board = null;
         }
      }
      
      private function entityRemovingHandler(param1:BattleEntityEvent) : void
      {
         this.removeEntity(param1.entity);
      }
      
      public function get pillage() : Boolean
      {
         return this._pillage;
      }
      
      private function updateSagaVars() : void
      {
         if(this.saga)
         {
            this.saga.setVar(SagaVar.VAR_PILLAGING,this._pillage);
         }
      }
      
      private function _resetTurnOrder_pillage() : void
      {
         var _loc3_:BattleTurnTeam = null;
         var _loc4_:int = 0;
         var _loc5_:BattleTurnParty = null;
         var _loc6_:int = 0;
         var _loc7_:IBattleEntity = null;
         this.pruneDeadEntities();
         var _loc1_:int = 2;
         var _loc2_:int = 0;
         while(_loc2_ < this._turnTeams.length)
         {
            _loc3_ = this._turnTeams[_loc2_];
            _loc4_ = 0;
            while(_loc4_ < _loc3_.turnParties.length)
            {
               _loc5_ = _loc3_.turnParties[_loc4_];
               _loc6_ = 0;
               while(_loc6_ < _loc5_.members.length)
               {
                  _loc7_ = _loc5_.members[_loc6_];
                  if(this._aliveOrder.indexOf(_loc7_) < 0)
                  {
                     if(_loc1_ < this._aliveOrder.length)
                     {
                        this._aliveOrder.splice(_loc1_,0,_loc7_);
                        this.logger.info("Pillage insertion " + _loc1_ + " of " + _loc7_);
                        _loc1_ += 2;
                     }
                     else
                     {
                        this._aliveOrder.push(_loc7_);
                        this.logger.info("Pillage push " + (this._aliveOrder.length - 1) + " of " + _loc7_);
                     }
                  }
                  _loc6_++;
               }
               _loc4_++;
            }
            _loc2_++;
         }
      }
      
      public function resetTurnOrder() : void
      {
         if(!this._keepPillage)
         {
            this._pillage = false;
         }
         else if(this.pillage)
         {
            this._resetTurnOrder_pillage();
            return;
         }
         this._didReset = true;
         this.updateSagaVars();
         this.pruneDeadEntities();
         this.currentTeam = null;
         this._index = -1;
         this.setDirty();
         dispatchEvent(new BattleTurnOrderEvent(BattleTurnOrderEvent.REFRESH_INITIATIVE));
      }
      
      public function commencePillaging(param1:Boolean, param2:Boolean) : void
      {
         var _loc4_:IBattleEntity = null;
         if(SUPPRESS_PILLAGE)
         {
            return;
         }
         this._keepPillage = param1 || this._keepPillage;
         if(this._pillage)
         {
            return;
         }
         this.checkDirty();
         if(this._aliveOrder.length == 0)
         {
            throw new IllegalOperationError("must have alives");
         }
         this._pillage = true;
         this.updateSagaVars();
         var _loc3_:Vector.<IBattleEntity> = new Vector.<IBattleEntity>();
         for each(_loc4_ in this._aliveOrder)
         {
            if(_loc4_.alive)
            {
               if(_loc3_.indexOf(_loc4_) < 0)
               {
                  _loc3_.push(_loc4_);
               }
            }
         }
         this._aliveOrder = _loc3_;
         this.currentTeam = null;
         this._index = -1;
         if(param2)
         {
            dispatchEvent(new BattleTurnOrderEvent(BattleTurnOrderEvent.PILLAGE));
         }
      }
      
      public function get index() : int
      {
         return this._index;
      }
      
      public function addParty(param1:IBattleParty) : void
      {
         var _loc2_:BattleTurnTeam = null;
         if(param1.team == "prop")
         {
            throw new ArgumentError("Cannot add prop party " + param1);
         }
         for each(_loc2_ in this._turnTeams)
         {
            if(_loc2_.team == param1.team)
            {
               _loc2_.addParty(param1);
               return;
            }
         }
         _loc2_ = new BattleTurnTeam(param1.team,this.logger);
         _loc2_.addParty(param1);
         this._turnTeams.push(_loc2_);
      }
      
      public function removeParty(param1:IBattleParty) : Boolean
      {
         var _loc2_:BattleTurnTeam = null;
         for each(_loc2_ in this._turnTeams)
         {
            if(_loc2_.team == param1.team)
            {
               _loc2_.removeParty(param1);
               return true;
            }
         }
         return false;
      }
      
      public function setDirty() : void
      {
         this._dirty = true;
      }
      
      public function get freeTurn() : IBattleEntity
      {
         return this._freeTurn;
      }
      
      public function set freeTurn(param1:IBattleEntity) : void
      {
         this._freeTurn = param1;
      }
      
      public function turnOrderNextTurn(param1:IBattleEntity) : IBattleEntity
      {
         var _loc3_:IBattleEntity = null;
         var _loc4_:IBattleEntity = null;
         var _loc5_:Boolean = false;
         if(this._freeTurn)
         {
            _loc3_ = this._freeTurn;
            this._freeTurn = null;
            if(_loc3_ == this.aliveOrder[0])
            {
               ++_loc3_.freeTurns;
               this.checkItOut();
               return this._aliveOrder[0];
            }
         }
         if(this._pillage)
         {
            if(!this._initialized)
            {
               this.checkDirty();
               _loc4_ = this._aliveOrder[0];
            }
            else
            {
               _loc5_ = this.saga.isSurvival;
               if(_loc5_)
               {
                  if(this._aliveOrder[0] == param1)
                  {
                     _loc4_ = this._aliveOrder.shift();
                     this._aliveOrder.push(_loc4_);
                  }
                  else
                  {
                     _loc4_ = this._aliveOrder[0];
                  }
               }
               else
               {
                  _loc4_ = this._aliveOrder.shift();
                  this._aliveOrder.push(_loc4_);
               }
               _loc4_.freeTurns = 0;
            }
            this.updateTurnTeamFromActiveEntity(_loc4_);
            this.checkItOut();
            return _loc4_;
         }
         this._index = ++this._index % this._turnTeams.length;
         this.currentTeam = this._turnTeams[this._index];
         if(this.currentTeam)
         {
            this.currentTeam.next();
         }
         this.setDirty();
         dispatchEvent(new BattleTurnOrderEvent(BattleTurnOrderEvent.CHANGED));
         var _loc2_:IBattleEntity = Boolean(this.currentTeam) && this.currentTeam.currents.length > 0 ? this.currentTeam.currents[0] : null;
         if(_loc2_)
         {
            _loc2_.freeTurns = 0;
         }
         this.checkItOut();
         return _loc2_;
      }
      
      public function updateTurnTeamFromActiveEntity(param1:IBattleEntity) : void
      {
         var _loc2_:BattleTurnTeam = null;
         if(!param1)
         {
            return;
         }
         for each(_loc2_ in this._turnTeams)
         {
            if(_loc2_.team == param1.team)
            {
               _loc2_.updateFromActiveEntity(param1);
               break;
            }
         }
      }
      
      public function get numTeams() : int
      {
         this.checkDirty();
         return this._numTeamsRemaining;
      }
      
      private function computeMaxPartySize() : int
      {
         var _loc3_:int = 0;
         var _loc4_:BattleTurnTeam = null;
         var _loc5_:BattleTurnParty = null;
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         while(_loc2_ < this._turnTeams.length)
         {
            _loc3_ = (_loc2_ + this.index) % this._turnTeams.length;
            _loc4_ = this._turnTeams[_loc3_];
            for each(_loc5_ in _loc4_.turnParties)
            {
               _loc1_ = Math.max(_loc1_,_loc5_.members.length);
            }
            _loc2_++;
         }
         return _loc1_;
      }
      
      private function checkDirty() : void
      {
         if(!this._dirty)
         {
            this.checkItOut();
            return;
         }
         this._dirty = false;
         var _loc1_:Boolean = this.saga.isSurvival;
         if(this._pillage)
         {
            if(this._initialized)
            {
               if(!(_loc1_ && this._didReset))
               {
                  this.checkItOut();
                  return;
               }
               this.logger.info("BattleTurnOrder.checkDirty survival forcing checkDirty");
            }
            else
            {
               this.logger.info("BattleTurnOrder.checkDirty uninitialized forcing checkDirty");
            }
         }
         if(!this._initialized && _loc1_)
         {
            this._aliveOrder.push(this._turnTeams[0].turnParties[0].members[0]);
         }
         this._initialized = true;
         this._didReset = false;
         if(this._index < 0)
         {
            this._index = 0;
         }
         if(Boolean(this._aliveOrder) && Boolean(this._aliveOrder.length))
         {
            this.updateTurnTeamFromActiveEntity(this._aliveOrder[0]);
         }
         this._aliveOrder.splice(0,this._aliveOrder.length);
         this._fillAliveOrder();
         if(Boolean(this._aliveOrder) && Boolean(this._aliveOrder.length))
         {
            this.updateTurnTeamFromActiveEntity(this._aliveOrder[0]);
         }
         this.checkItOut();
      }
      
      private function _fillAliveOrder() : void
      {
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc7_:BattleTurnTeam = null;
         var _loc8_:int = 0;
         var _loc9_:BattleTurnParty = null;
         var _loc10_:int = 0;
         var _loc11_:IBattleEntity = null;
         var _loc1_:int = 0;
         var _loc2_:int = this.computeMaxPartySize();
         var _loc3_:Boolean = this.saga.isSurvival;
         var _loc4_:int = 0;
         while(_loc4_ < _loc2_)
         {
            _loc5_ = 0;
            while(_loc5_ < this._turnTeams.length)
            {
               _loc6_ = (_loc5_ + this._index) % this._turnTeams.length;
               _loc7_ = this._turnTeams[_loc6_];
               _loc8_ = 0;
               for(; _loc8_ < _loc7_.turnParties.length; _loc8_++)
               {
                  _loc9_ = _loc7_.turnParties[_loc8_];
                  _loc10_ = _loc4_;
                  if(!_loc3_)
                  {
                     if(_loc6_ != this._index)
                     {
                        _loc10_++;
                     }
                  }
                  if(this._pillage)
                  {
                     if(_loc10_ >= _loc9_.members.length)
                     {
                        continue;
                     }
                  }
                  _loc11_ = _loc9_.getFutureCurrent(_loc10_);
                  if(_loc11_)
                  {
                     this._aliveOrder.push(_loc11_);
                  }
                  else
                  {
                     this.logger.info("BattleTurnOrder.checkDirty unable to getFutureCurrent " + _loc10_ + " for " + _loc9_);
                  }
               }
               _loc5_++;
            }
            _loc4_++;
         }
      }
      
      private function checkItOut() : void
      {
         var _loc2_:int = 0;
         var _loc3_:IBattleEntity = null;
         var _loc4_:int = 0;
         var _loc1_:Boolean = this.saga.isSurvival;
         if(_loc1_ && Boolean(this._aliveOrder))
         {
            _loc2_ = 0;
            while(_loc2_ < this._aliveOrder.length)
            {
               _loc3_ = this._aliveOrder[_loc2_];
               _loc4_ = this._aliveOrder.indexOf(_loc3_,_loc2_ + 1);
               if(_loc4_ > _loc2_)
               {
                  this.logger.error("Found duplicate in _aliveOrder " + _loc3_ + " @ " + _loc2_ + " and " + _loc4_);
               }
               _loc2_++;
            }
         }
      }
      
      public function get turnTeams() : Vector.<BattleTurnTeam>
      {
         return this._turnTeams;
      }
      
      public function get aliveOrder() : Vector.<IBattleEntity>
      {
         this.checkDirty();
         return this._aliveOrder;
      }
      
      public function getAllParticipants(param1:Vector.<IBattleEntity>) : Vector.<IBattleEntity>
      {
         var _loc2_:BattleTurnTeam = null;
         for each(_loc2_ in this._turnTeams)
         {
            param1 = _loc2_.getAllTeamMembers(param1);
         }
         return param1;
      }
      
      public function getAliveParticipants(param1:Vector.<IBattleEntity>) : Vector.<IBattleEntity>
      {
         var _loc2_:BattleTurnTeam = null;
         for each(_loc2_ in this._turnTeams)
         {
            param1 = _loc2_.getAliveMembers(param1);
         }
         return param1;
      }
      
      public function pruneDeadEntities() : int
      {
         var _loc2_:BattleTurnTeam = null;
         var _loc3_:int = 0;
         var _loc4_:IBattleEntity = null;
         var _loc1_:int = 0;
         for each(_loc2_ in this._turnTeams)
         {
            _loc1_ += _loc2_.pruneDeadEntities();
         }
         if(_loc1_)
         {
            this.logger.info("BattleTurnInfo.pruneDeadEntities pruned " + _loc1_ + " pillage=" + this._pillage);
            this.setDirty();
            if(this._pillage)
            {
               this.checkDirty();
               _loc3_ = 0;
               while(_loc3_ < this._aliveOrder.length)
               {
                  _loc4_ = this._aliveOrder[_loc3_];
                  if(_loc4_.alive)
                  {
                     this.logger.info("BattleTurnInfo.pruneDeadEntities  keep " + _loc4_ + " at " + _loc3_);
                     _loc3_++;
                  }
                  else
                  {
                     this.logger.info("BattleTurnInfo.pruneDeadEntities splice out " + _loc4_ + " at " + _loc3_);
                     this._aliveOrder.splice(_loc3_,1);
                  }
               }
            }
         }
         return _loc1_;
      }
      
      protected function battleTurnTeamForEntity(param1:IBattleEntity) : BattleTurnTeam
      {
         var _loc2_:BattleTurnTeam = null;
         for each(_loc2_ in this._turnTeams)
         {
            if(param1.team == _loc2_.team)
            {
               return _loc2_;
            }
         }
         return null;
      }
      
      protected function debug_spewAliveOrder() : void
      {
         this.logger.debug("############################");
         this.logger.debug("alive order:");
         var _loc1_:int = 0;
         while(_loc1_ < this._aliveOrder.length)
         {
            this.logger.debug("[" + _loc1_ + "] id=" + this._aliveOrder[_loc1_].id);
            _loc1_++;
         }
      }
      
      public function bumpToNext(param1:IBattleEntity) : void
      {
         var _loc2_:BattleTurnTeam = null;
         var _loc3_:int = 0;
         if(this.pillage == false)
         {
            _loc2_ = this.battleTurnTeamForEntity(param1);
            if(_loc2_ != null)
            {
               _loc2_.bumpToNext(param1);
            }
            this.setDirty();
            this.checkDirty();
         }
         else
         {
            _loc3_ = this._aliveOrder.indexOf(param1);
            this._aliveOrder.splice(_loc3_,1);
            this._aliveOrder.splice(1,0,param1);
         }
         dispatchEvent(new BattleTurnOrderEvent(BattleTurnOrderEvent.REFRESH_INITIATIVE));
         if(this.pillage == false)
         {
            dispatchEvent(new BattleTurnOrderEvent(BattleTurnOrderEvent.PLAY_FORGE_AHEAD_VFX,param1));
         }
         else
         {
            dispatchEvent(new BattleTurnOrderEvent(BattleTurnOrderEvent.PLAY_FORGE_AHEAD_PILLAGE_VFX,param1));
         }
      }
      
      public function moveToLast(param1:IBattleEntity) : void
      {
         var _loc2_:BattleTurnTeam = null;
         var _loc3_:int = 0;
         if(this.pillage == false)
         {
            _loc2_ = this.battleTurnTeamForEntity(param1);
            if(_loc2_ != null)
            {
               _loc2_.moveToLast(param1);
            }
            this.setDirty();
            this.checkDirty();
         }
         else
         {
            _loc3_ = this._aliveOrder.indexOf(param1);
            if(_loc3_ != -1)
            {
               this._aliveOrder.splice(_loc3_,1);
               this._aliveOrder.push(param1);
            }
            else
            {
               this.logger.error("Failed to move entity to last: is not in the current alive order");
            }
         }
         dispatchEvent(new BattleTurnOrderEvent(BattleTurnOrderEvent.REFRESH_INITIATIVE));
         dispatchEvent(new BattleTurnOrderEvent(BattleTurnOrderEvent.PLAY_INSULT_VFX,param1));
      }
      
      public function moveToBefore(param1:IBattleEntity, param2:IBattleEntity) : void
      {
         var _loc3_:BattleTurnTeam = null;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         if(this.pillage == false)
         {
            _loc3_ = this.battleTurnTeamForEntity(param1);
            if(_loc3_ != null)
            {
               _loc3_.moveToBefore(param1,param2);
            }
            this.setDirty();
            this.checkDirty();
         }
         else if(param1 != param2)
         {
            _loc4_ = this._aliveOrder.indexOf(param1);
            _loc5_ = this._aliveOrder.indexOf(param2);
            if(_loc4_ != -1 && _loc5_ != -1)
            {
               this._aliveOrder.splice(_loc4_,1);
               _loc5_ = this._aliveOrder.indexOf(param2);
               this._aliveOrder.splice(_loc5_,0,param1);
            }
         }
         dispatchEvent(new BattleTurnOrderEvent(BattleTurnOrderEvent.REFRESH_INITIATIVE));
         if(this.pillage == false)
         {
            dispatchEvent(new BattleTurnOrderEvent(BattleTurnOrderEvent.PLAY_FORGE_AHEAD_VFX,param1));
         }
         else
         {
            dispatchEvent(new BattleTurnOrderEvent(BattleTurnOrderEvent.PLAY_FORGE_AHEAD_PILLAGE_VFX,param1));
         }
      }
      
      public function addEntity(param1:IBattleEntity) : void
      {
         var _loc2_:Boolean = false;
         var _loc4_:BattleTurnTeam = null;
         var _loc5_:Boolean = false;
         var _loc6_:IBattleEntity = null;
         if(!param1.team)
         {
            throw new IllegalOperationError("An entity [" + param1 + "] is being added to the order but it has a null team");
         }
         var _loc3_:int = 0;
         while(_loc3_ < this._turnTeams.length)
         {
            _loc4_ = this._turnTeams[_loc3_];
            if(_loc4_.team == param1.team)
            {
               _loc4_.addEntity(param1);
               _loc2_ = true;
               break;
            }
            _loc3_++;
         }
         if(!_loc2_)
         {
            throw new IllegalOperationError("An entity [" + param1 + "] cannot be added due to unknown team");
         }
         if(this._pillage)
         {
            _loc3_ = 1;
            while(_loc3_ < this._aliveOrder.length)
            {
               _loc6_ = this._aliveOrder[_loc3_];
               if(_loc6_.team == param1.team)
               {
                  this._aliveOrder.splice(_loc3_,0,param1);
                  _loc5_ = true;
                  break;
               }
               _loc3_++;
            }
            if(!_loc5_)
            {
               this._aliveOrder.push(param1);
            }
         }
         this.setDirty();
         dispatchEvent(new BattleTurnOrderEvent(BattleTurnOrderEvent.REFRESH_INITIATIVE));
      }
      
      public function removeEntity(param1:IBattleEntity) : void
      {
         var _loc2_:Boolean = false;
         var _loc4_:BattleTurnTeam = null;
         var _loc5_:int = 0;
         if(!param1.team)
         {
            throw new IllegalOperationError("An entity [" + param1 + "] is being removed from the order but it has a null team");
         }
         var _loc3_:int = 0;
         while(_loc3_ < this._turnTeams.length)
         {
            _loc4_ = this._turnTeams[_loc3_];
            if(_loc4_.team == param1.team)
            {
               _loc4_.removeEntity(param1);
               _loc2_ = true;
               break;
            }
            _loc3_++;
         }
         if(!_loc2_)
         {
            throw new IllegalOperationError("An entity [" + param1 + "] cannot be removed due to unknown team");
         }
         if(this._pillage)
         {
            _loc5_ = this._aliveOrder.indexOf(param1);
            if(_loc5_ >= 0)
            {
               this._aliveOrder.splice(_loc5_,1);
            }
         }
         this.setDirty();
         dispatchEvent(new BattleTurnOrderEvent(BattleTurnOrderEvent.REFRESH_INITIATIVE));
      }
      
      public function peekNextEnemy() : IBattleEntity
      {
         var _loc5_:IBattleEntity = null;
         var _loc1_:IBattleEntity = this.activeEntity;
         if(!_loc1_)
         {
            return null;
         }
         var _loc2_:IBattleParty = _loc1_.party;
         var _loc3_:String = _loc1_.team;
         var _loc4_:int = 1;
         while(_loc4_ < this._aliveOrder.length)
         {
            _loc5_ = this._aliveOrder[_loc4_];
            if(_loc5_.party != _loc2_)
            {
               if(_loc5_.team != _loc3_)
               {
                  return _loc5_;
               }
            }
            _loc4_++;
         }
         return null;
      }
   }
}
