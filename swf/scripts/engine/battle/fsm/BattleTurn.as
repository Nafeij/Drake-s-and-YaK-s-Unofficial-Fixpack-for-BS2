package engine.battle.fsm
{
   import engine.ability.def.AbilityDefLevel;
   import engine.battle.ability.def.BattleAbilityDef;
   import engine.battle.ability.def.BattleAbilityDefLevels;
   import engine.battle.ability.def.BattleAbilityRangeType;
   import engine.battle.ability.def.BattleAbilityTag;
   import engine.battle.ability.def.BattleAbilityTargetRule;
   import engine.battle.ability.def.IBattleAbilityDef;
   import engine.battle.ability.model.BattleAbility;
   import engine.battle.ability.model.BattleAbilityEvent;
   import engine.battle.ability.model.BattleAbilityValidation;
   import engine.battle.board.BattleBoardEvent;
   import engine.battle.board.model.IBattleBoard;
   import engine.battle.board.model.IBattleEntity;
   import engine.battle.board.model.IBattleMove;
   import engine.battle.entity.model.BattleEntityEvent;
   import engine.battle.entity.model.BattleEntityMobility;
   import engine.core.cmd.CmdExec;
   import engine.core.cmd.ShellCmdManager;
   import engine.core.logging.ILogger;
   import engine.stat.def.StatType;
   import engine.stat.model.Stats;
   import engine.tile.ITileResident;
   import engine.tile.Tile;
   import engine.tile.Tiles;
   import engine.tile.def.TileLocation;
   import engine.tile.def.TileRect;
   import engine.tile.def.TileRectRange;
   import flash.errors.IllegalOperationError;
   import flash.events.EventDispatcher;
   import flash.utils.Dictionary;
   
   public class BattleTurn extends EventDispatcher implements IBattleTurn
   {
       
      
      public var _entity:IBattleEntity;
      
      private var _interact:IBattleEntity;
      
      public var _move:IBattleMove;
      
      public var logger:ILogger;
      
      public var _ability:BattleAbility;
      
      private var _number:int;
      
      private var _complete:Boolean;
      
      private var _committed:Boolean;
      
      private var _suspended:Boolean;
      
      private var _attackMode:Boolean;
      
      public var selfPopupAnimating:Boolean;
      
      public var shell:ShellCmdManager;
      
      public var _inRange:Dictionary;
      
      public var _inRangeObjects:Dictionary;
      
      public var _inRangeTiles:Dictionary;
      
      public var hash:int;
      
      public var _timerSecs:int;
      
      private var _board:IBattleBoard;
      
      public var _numAbilities:int;
      
      private var listeningMoves:Dictionary;
      
      public function BattleTurn(param1:IBattleEntity, param2:int, param3:int, param4:ILogger, param5:Boolean)
      {
         this._inRange = new Dictionary();
         this._inRangeObjects = new Dictionary();
         this._inRangeTiles = new Dictionary();
         super();
         BattleMove.flushCache();
         this.logger = param4;
         this._entity = param1;
         this._number = param2;
         this.move = new BattleMove(param1,1000,0,false,false,false,param5);
         this.shell = new ShellCmdManager(param4);
         this.hash = param3;
         this._timerSecs = param1.party.timer;
         this.shell.add("info",this.shellCmdFuncInfo);
         this.shell.add("ability",this.shellCmdFuncAbility,true);
         this.move.addEventListener(BattleMoveEvent.MOVE_CHANGED,this.moveEventHandler);
         this.move.addEventListener(BattleMoveEvent.EXECUTED,this.moveExecutedHandler);
         this._board = param1.board;
         this._board.addEventListener(BattleBoardEvent.BOARD_ENTITY_ENABLED,this.boardEntityEnabledHandler);
         this._board.addEventListener(BattleEntityEvent.REMOVED,this.entityRemovedHandler);
         this._entity.addEventListener(BattleEntityEvent.TILE_CHANGED,this.entityTileChangedHandler);
         this.cacheInRanges();
      }
      
      override public function toString() : String
      {
         return "Turn " + this._number + ": " + this._entity;
      }
      
      public function notifyTargetsUpdated() : void
      {
         dispatchEvent(new BattleTurnEvent(BattleTurnEvent.ABILITY_TARGET));
      }
      
      private function entityRemovedHandler(param1:BattleEntityEvent) : void
      {
         this._board.removeEventListener(BattleEntityEvent.REMOVED,this.entityRemovedHandler);
         this._entity.removeEventListener(BattleEntityEvent.TILE_CHANGED,this.entityTileChangedHandler);
         this._entity = null;
      }
      
      private function entityTileChangedHandler(param1:BattleEntityEvent) : void
      {
         var _loc3_:IBattleMove = null;
         if(!this._entity || this.committed || this.complete)
         {
            return;
         }
         var _loc2_:BattleEntityMobility = this._entity.mobility as BattleEntityMobility;
         if(_loc2_ && _loc2_.moving && !_loc2_.move.interrupted)
         {
            _loc3_ = _loc2_.move;
            if(_loc3_)
            {
               if(!this.listeningMoves)
               {
                  this.listeningMoves = new Dictionary();
               }
               if(!this.listeningMoves[_loc3_])
               {
                  this.listeningMoves[_loc3_] = _loc3_;
                  _loc3_.addEventListener(BattleMoveEvent.EXECUTED,this.additionalMoveExecutedHandler);
               }
               return;
            }
         }
         this.handleEntityMoved();
      }
      
      private function handleEntityMoved() : void
      {
         if(Boolean(this._move) && !this._move.committed)
         {
            this._move.reset(this._entity.tile);
         }
         if(this._numAbilities == 0)
         {
            this.cacheInRanges();
         }
      }
      
      private function additionalMoveExecutedHandler(param1:BattleMoveEvent) : void
      {
         if(this.listeningMoves)
         {
            delete this.listeningMoves[param1.mv];
         }
         param1.mv.removeEventListener(BattleMoveEvent.EXECUTED,this.additionalMoveExecutedHandler);
         this.handleEntityMoved();
      }
      
      public function get attackMode() : Boolean
      {
         return this._attackMode;
      }
      
      public function set attackMode(param1:Boolean) : void
      {
         if(param1 == this._attackMode)
         {
            return;
         }
         if(this._attackMode)
         {
            this._attackMode;
         }
         else
         {
            this._attackMode;
         }
         this._attackMode = param1;
         dispatchEvent(new BattleTurnEvent(BattleTurnEvent.ATTACK_MODE));
         this.cacheInRanges();
      }
      
      private function moveExecutedHandler(param1:BattleMoveEvent) : void
      {
         this.cacheInRanges();
      }
      
      private function moveEventHandler(param1:BattleMoveEvent) : void
      {
         this.cacheInRanges();
      }
      
      private function boardEntityEnabledHandler(param1:BattleBoardEvent) : void
      {
         if(Boolean(this.move) && !this.move.committed)
         {
            if(this._entity == param1.entity)
            {
               this.move.flood = null;
               if(this.entity.tile)
               {
                  this.move.reset(this._entity.tile);
               }
            }
         }
      }
      
      public function cleanup() : void
      {
         var _loc1_:IBattleMove = null;
         if(this._board)
         {
            this._board.removeEventListener(BattleEntityEvent.REMOVED,this.entityRemovedHandler);
            this._board.removeEventListener(BattleBoardEvent.BOARD_ENTITY_ENABLED,this.boardEntityEnabledHandler);
            this._board = null;
         }
         if(this.listeningMoves)
         {
            for each(_loc1_ in this.listeningMoves)
            {
               _loc1_.removeEventListener(BattleMoveEvent.EXECUTED,this.additionalMoveExecutedHandler);
            }
            this.listeningMoves = null;
         }
         this.move.removeEventListener(BattleMoveEvent.MOVE_CHANGED,this.moveEventHandler);
         this.move.removeEventListener(BattleMoveEvent.EXECUTED,this.moveExecutedHandler);
         this.ability = null;
         if(this._entity)
         {
            this._entity.removeEventListener(BattleEntityEvent.TILE_CHANGED,this.entityTileChangedHandler);
            if(this._entity.mobility)
            {
               this._entity.mobility.stopMoving("turn end");
            }
         }
         this._entity = null;
         this.move = null;
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
         if(this._ability)
         {
            if(this._ability.executed || this._ability.executing)
            {
               if(param1)
               {
                  throw new IllegalOperationError("Can\'t change the ability while it is executing, or afterwards");
               }
            }
            this._ability.removeEventListener(BattleAbilityEvent.FINAL_COMPLETE,this.abilityFinalCompleteHandler);
            this._ability.removeEventListener(BattleAbilityEvent.EXECUTING,this.abilityExecutingHandler);
         }
         this._ability = param1;
         if(this._ability)
         {
            this._ability.addEventListener(BattleAbilityEvent.FINAL_COMPLETE,this.abilityFinalCompleteHandler);
            this._ability.addEventListener(BattleAbilityEvent.EXECUTING,this.abilityExecutingHandler);
            if(this._move && this._move.numSteps > 1 && !this._move.committed)
            {
               this._move.reset(this._move.first);
            }
         }
         this.cacheInRanges();
         dispatchEvent(new BattleTurnEvent(BattleTurnEvent.ABILITY));
      }
      
      private function abilityExecutingHandler(param1:BattleAbilityEvent) : void
      {
         dispatchEvent(new BattleTurnEvent(BattleTurnEvent.ABILITY_EXECUTING));
      }
      
      private function cacheInRanges() : void
      {
         if(!this._entity || this._entity.cleanedup || this._entity.board.cleanedup)
         {
            return;
         }
         this._inRange = new Dictionary();
         this._inRangeObjects = new Dictionary();
         this._inRangeTiles = new Dictionary();
         if(!this._entity.rect || !this._entity.tile)
         {
            dispatchEvent(new BattleTurnEvent(BattleTurnEvent.IN_RANGE));
            return;
         }
         if(!this.committed)
         {
            this.xxxxx();
         }
         dispatchEvent(new BattleTurnEvent(BattleTurnEvent.IN_RANGE));
      }
      
      private function xxxxx() : void
      {
         var _loc5_:Tile = null;
         var _loc9_:BattleAbilityTargetRule = null;
         var _loc10_:IBattleEntity = null;
         var _loc11_:int = 0;
         var _loc12_:int = 0;
         if(!this._entity)
         {
            return;
         }
         var _loc1_:BattleAbilityDefLevels = this._entity.def.attacks as BattleAbilityDefLevels;
         var _loc2_:Vector.<AbilityDefLevel> = _loc1_.getAbilityDefLevelsByTag(BattleAbilityTag.ATTACK_STR);
         var _loc3_:Vector.<AbilityDefLevel> = _loc1_.getAbilityDefLevelsByTag(BattleAbilityTag.ATTACK_ARM);
         var _loc4_:BattleAbilityValidation = null;
         var _loc6_:BattleAbilityDef = null;
         if(Boolean(this._ability) && this._ability.def.tag == BattleAbilityTag.SPECIAL)
         {
            _loc6_ = this._entity.highestAvailableAbilityDef(this._ability.def.id) as BattleAbilityDef;
         }
         if(Boolean(_loc6_) && _loc6_.targetRule.isTile)
         {
            if(this._scanForwardArcTiles(_loc6_))
            {
               return;
            }
            for each(_loc5_ in this._entity.board.tiles.tiles)
            {
               if(this.move.last != _loc5_)
               {
                  _loc4_ = BattleAbilityValidation.validate(_loc6_,this._entity,this._move,null,_loc5_,false,false,true);
                  if(_loc4_ == BattleAbilityValidation.OK)
                  {
                     this._inRangeTiles[_loc5_.location] = _loc5_.location;
                  }
               }
            }
            return;
         }
         var _loc7_:int = !!_loc6_ ? _loc6_.rangeMin(this.entity) : 0;
         var _loc8_:int = !!_loc6_ ? _loc6_.rangeMax(this.entity) : 0;
         if(!this._scanAxialTiles(_loc6_))
         {
            if(_loc6_)
            {
               if(_loc6_.rangeType != BattleAbilityRangeType.NONE)
               {
                  for each(_loc5_ in this._entity.board.tiles.tiles)
                  {
                     _loc11_ = TileRectRange.computeRange(this._entity.rect,_loc5_.rect);
                     if(_loc11_ > 0 && _loc11_ >= _loc7_ && _loc11_ <= _loc8_)
                     {
                        this._inRangeTiles[_loc5_.location] = _loc5_.location;
                     }
                  }
               }
            }
            else
            {
               for each(_loc5_ in this._entity.board.tiles.tiles)
               {
                  if(this.computeInRangeTile(_loc2_,_loc3_,_loc5_))
                  {
                     this._inRangeTiles[_loc5_.location] = _loc5_.location;
                  }
               }
            }
         }
         _loc9_ = !!_loc6_ ? _loc6_.targetRule : null;
         for each(_loc10_ in this._entity.board.entities)
         {
            if(_loc10_ != this._entity)
            {
               if(!(!_loc10_.alive && _loc9_ != BattleAbilityTargetRule.DEAD))
               {
                  _loc4_ = null;
                  if(_loc6_)
                  {
                     if(_loc6_.targetRule != BattleAbilityTargetRule.NONE)
                     {
                        _loc4_ = BattleAbilityValidation.validate(_loc6_,this._entity,this._move,_loc10_,null,false,false,true);
                        if(_loc4_ == BattleAbilityValidation.OK)
                        {
                           if(_loc6_.targetRule == BattleAbilityTargetRule.NEEDLE_TARGET_ENEMY_OTHER_ALL || _loc6_.targetRule == BattleAbilityTargetRule.CROSS_TARGET_ENEMY_OTHER_ALL)
                           {
                              if(this._entity.team == _loc10_.team)
                              {
                                 _loc4_ = null;
                              }
                           }
                        }
                     }
                  }
                  else if(_loc10_.team != this._entity.team)
                  {
                     if(_loc10_.usable)
                     {
                        _loc12_ = TileRectRange.computeRange(this._entity.rect,_loc10_.tile.rect);
                        if(_loc12_ <= 1)
                        {
                           this._inRangeObjects[_loc10_] = _loc10_;
                        }
                     }
                     else if(this.computeInRangeTarget(_loc2_,_loc3_,_loc10_))
                     {
                        this._inRange[_loc10_] = _loc10_;
                     }
                  }
                  if(_loc4_ == BattleAbilityValidation.OK)
                  {
                     this._inRange[_loc10_] = _loc10_;
                  }
               }
            }
         }
      }
      
      private function _visitTileHandler(param1:int, param2:int, param3:*) : void
      {
         var _loc4_:TileLocation = TileLocation.fetch(param1,param2);
         var _loc5_:Tile = this._entity.tiles.getTileByLocation(_loc4_);
         if(_loc5_)
         {
            this._inRangeTiles[_loc4_] = _loc4_;
         }
      }
      
      private function _scanForwardArcTiles(param1:BattleAbilityDef) : Boolean
      {
         if(!param1)
         {
            return false;
         }
         if(param1.targetRule != BattleAbilityTargetRule.FORWARD_ARC)
         {
            return false;
         }
         var _loc2_:TileRect = this._entity.rect;
         _loc2_.visitAdjacentTileLocations(this._visitTileHandler,null,false,false);
         return true;
      }
      
      private function _scanAxialTiles(param1:BattleAbilityDef) : Boolean
      {
         if(!param1)
         {
            return false;
         }
         if(!param1.targetRule.isAxial && param1.targetRule != BattleAbilityTargetRule.NEEDLE_TARGET_ENEMY_OTHER_ALL && param1.targetRule != BattleAbilityTargetRule.CROSS_TARGET_ENEMY_OTHER_ALL)
         {
            return false;
         }
         var _loc2_:int = param1.rangeMin(this.entity);
         var _loc3_:int = param1.rangeMax(this.entity);
         var _loc4_:Tiles = this._entity.board.tiles;
         this._findAxialTiles(this._entity.rect,_loc4_,_loc2_,_loc3_);
         return true;
      }
      
      private function _findAxialTiles(param1:TileRect, param2:Tiles, param3:int, param4:int) : void
      {
         var _loc13_:int = 0;
         var _loc14_:int = 0;
         var _loc15_:TileLocation = null;
         param3 = Math.max(1,param3);
         var _loc5_:int = param1.left;
         var _loc6_:int = param1.right;
         var _loc7_:int = param1.front;
         var _loc8_:int = param1.back;
         var _loc9_:int = param1.loc.x;
         var _loc10_:int = _loc9_ + param1.diameter;
         var _loc11_:int = param1.loc.y;
         var _loc12_:int = _loc11_ + param1.diameter;
         var _loc16_:int = 0;
         _loc13_ = _loc9_;
         while(_loc13_ < _loc10_)
         {
            _loc16_ = param3;
            while(_loc16_ <= param4)
            {
               _loc14_ = _loc7_ - _loc16_;
               _loc15_ = TileLocation.fetch(_loc13_,_loc14_);
               if(param2.getTileByLocation(_loc15_))
               {
                  this._inRangeTiles[_loc15_] = _loc15_;
               }
               _loc14_ = _loc8_ + (_loc16_ - 1);
               _loc15_ = TileLocation.fetch(_loc13_,_loc14_);
               if(param2.getTileByLocation(_loc15_))
               {
                  this._inRangeTiles[_loc15_] = _loc15_;
               }
               _loc16_++;
            }
            _loc13_++;
         }
         _loc14_ = _loc11_;
         while(_loc14_ < _loc12_)
         {
            _loc16_ = param3;
            while(_loc16_ <= param4)
            {
               _loc13_ = _loc5_ - _loc16_;
               _loc15_ = TileLocation.fetch(_loc13_,_loc14_);
               if(param2.getTileByLocation(_loc15_))
               {
                  this._inRangeTiles[_loc15_] = _loc15_;
               }
               _loc13_ = _loc6_ + (_loc16_ - 1);
               _loc15_ = TileLocation.fetch(_loc13_,_loc14_);
               if(param2.getTileByLocation(_loc15_))
               {
                  this._inRangeTiles[_loc15_] = _loc15_;
               }
               _loc16_++;
            }
            _loc14_++;
         }
      }
      
      public function get numInRange() : int
      {
         var _loc2_:* = undefined;
         var _loc1_:int = 0;
         for(_loc2_ in this._inRange)
         {
            _loc1_++;
         }
         return _loc1_;
      }
      
      private function computeInRangeTile(param1:Vector.<AbilityDefLevel>, param2:Vector.<AbilityDefLevel>, param3:Tile) : Boolean
      {
         var _loc5_:AbilityDefLevel = null;
         var _loc6_:BattleAbilityDef = null;
         var _loc12_:int = 0;
         var _loc4_:BattleAbilityValidation = null;
         var _loc7_:int = TileRectRange.computeTileRange(param3.def._location,this._entity.rect);
         if(_loc7_ <= 0)
         {
            return false;
         }
         var _loc8_:Stats = this.entity.stats;
         var _loc9_:int = _loc8_.getValue(StatType.RANGEMOD_GLOBAL);
         var _loc10_:int = _loc8_.getValue(StatType.RANGEMOD_MELEE);
         var _loc11_:int = _loc8_.getValue(StatType.RANGEMOD_RANGED);
         for each(_loc5_ in param1)
         {
            _loc6_ = _loc5_._def as BattleAbilityDef;
            if(_loc7_ >= _loc6_._rangeMin)
            {
               _loc12_ = _loc6_.rangeType.isMelee ? _loc10_ : (_loc6_.rangeType.isRanged ? _loc11_ : 0);
               _loc12_ += _loc9_;
               if(_loc7_ <= _loc6_._rangeMax + _loc12_)
               {
                  return true;
               }
            }
         }
         for each(_loc5_ in param2)
         {
            _loc6_ = _loc5_._def as BattleAbilityDef;
            if(_loc7_ >= _loc6_._rangeMin)
            {
               _loc12_ = _loc6_.rangeType.isMelee ? _loc10_ : (_loc6_.rangeType.isRanged ? _loc11_ : 0);
               _loc12_ += _loc9_;
               if(_loc7_ <= _loc6_._rangeMax + _loc12_)
               {
                  return true;
               }
            }
         }
         return false;
      }
      
      private function computeInRangeTarget(param1:Vector.<AbilityDefLevel>, param2:Vector.<AbilityDefLevel>, param3:IBattleEntity) : Boolean
      {
         var _loc5_:AbilityDefLevel = null;
         var _loc4_:BattleAbilityValidation = null;
         for each(_loc5_ in param1)
         {
            _loc4_ = BattleAbilityValidation.validateRange(_loc5_._def as BattleAbilityDef,this._entity,this._move,param3,null);
            if(_loc4_ == BattleAbilityValidation.OK)
            {
               return true;
            }
         }
         for each(_loc5_ in param2)
         {
            _loc4_ = BattleAbilityValidation.validateRange(_loc5_._def as BattleAbilityDef,this._entity,this._move,param3,null);
            if(_loc4_ == BattleAbilityValidation.OK)
            {
               return true;
            }
         }
         return false;
      }
      
      private function abilityFinalCompleteHandler(param1:BattleAbilityEvent) : void
      {
         this.complete = this._complete || Boolean(this._ability) && this._ability.finalCompleted;
      }
      
      public function get turnInteract() : IBattleEntity
      {
         return this._interact;
      }
      
      internal function setTurnInteract(param1:IBattleEntity) : void
      {
         if(param1 != this._interact)
         {
            this._interact = param1;
            if(Boolean(this._move) && !this._move.committed)
            {
               this._move.reset(this._move.first);
            }
            this.cacheInRanges();
            dispatchEvent(new BattleTurnEvent(BattleTurnEvent.TURN_INTERACT));
         }
      }
      
      public function get complete() : Boolean
      {
         return this._complete;
      }
      
      public function set complete(param1:Boolean) : void
      {
         if(this._complete == param1)
         {
            return;
         }
         this._complete = param1;
         dispatchEvent(new BattleTurnEvent(BattleTurnEvent.COMPLETE));
      }
      
      public function get committed() : Boolean
      {
         return this._committed;
      }
      
      public function set committed(param1:Boolean) : void
      {
         if(this._committed == param1)
         {
            return;
         }
         this._committed = param1;
         dispatchEvent(new BattleTurnEvent(BattleTurnEvent.COMMITTED));
         this.cacheInRanges();
      }
      
      private function shellCmdFuncInfo(param1:CmdExec) : void
      {
         this.logger.info("Turn: ");
         this.logger.info("    number = " + this._number);
         this.logger.info("   ability = " + this.ability);
      }
      
      private function shellCmdFuncAbility(param1:CmdExec) : void
      {
         var _loc3_:String = null;
         var _loc4_:IBattleAbilityDef = null;
         var _loc5_:BattleAbility = null;
         var _loc6_:Boolean = false;
         var _loc2_:Array = param1.param;
         if(_loc2_.length > 1)
         {
            _loc3_ = _loc2_[1];
            this.logger.info("shellCmdFuncAbility id = " + _loc3_);
            if(_loc3_ == "exec")
            {
               if(this.ability)
               {
                  this.ability.execute(null);
               }
               return;
            }
            _loc4_ = this._entity.board.abilityManager.getFactory.fetchIBattleAbilityDef(_loc3_);
            if(_loc4_ != null)
            {
               _loc5_ = new BattleAbility(this._entity,_loc4_,this._entity.board.abilityManager);
               if(_loc5_ != null)
               {
                  _loc6_ = false;
                  switch(_loc3_)
                  {
                     case "abl_tempest":
                        _loc6_ = this.handleAbilityTempest(_loc5_,_loc2_);
                        break;
                     case "abl_bloodyflail":
                        _loc6_ = this.handleAbilityBloodyFlail(_loc5_,_loc2_);
                        break;
                     case "abl_rainofarrows":
                        if(_loc2_[2] == "*")
                        {
                           this.ability = _loc5_;
                           return;
                        }
                        _loc6_ = this.handleAbilityRainOfArrows(_loc5_,_loc2_);
                        break;
                     case "abl_malice":
                        _loc6_ = this.handleAbilityMalice(_loc5_,_loc2_);
                  }
                  if(_loc6_ == true)
                  {
                     this.ability = _loc5_;
                     this.logger.info("executing ability : " + this.ability.def.name);
                     this.ability.execute(this.abilityExecuteCallback);
                  }
               }
               else
               {
                  this.logger.error("shellCmdFuncAbility not able to find ability for id=" + _loc3_ + "  def=" + _loc4_.id);
               }
            }
            else
            {
               this.logger.error("shellCmdFuncAbility not able to find abilitydef for id=" + _loc3_);
            }
         }
         this.logger.info("Turn Ability " + this.ability);
      }
      
      private function abilityExecuteCallback(param1:BattleAbility) : void
      {
      }
      
      private function handleAbilityTempest(param1:BattleAbility, param2:Array) : Boolean
      {
         var _loc3_:String = null;
         var _loc4_:IBattleEntity = null;
         if(param2.length > 2)
         {
            _loc3_ = param2[2];
            _loc4_ = this.findBattleEntity(_loc3_);
            if(_loc4_ != null)
            {
               if(this.isBattleEntityAdjacent(this._entity,_loc4_) == true)
               {
                  this.setupTempestAbilityTargetSet(_loc4_,param1);
                  return true;
               }
               this.logger.error("handleAbilityTempest: entity [ " + _loc3_ + "] is not adjacent");
            }
            else
            {
               this.logger.error("handleAbilityTempest: could not find target entity: " + _loc3_);
            }
         }
         else
         {
            this.logger.error("handleAbilityTempest : not enough arguments. argv.length = " + param2.length);
         }
         return false;
      }
      
      private function setupTempestAbilityTargetSet(param1:IBattleEntity, param2:BattleAbility) : void
      {
         var _loc6_:int = 0;
         param2.targetSet.targets.splice(0,param2.targetSet.targets.length);
         if(param1.team == this._entity.team)
         {
            this.logger.error("setupTempestAbilityTargetSet : first target must be an enemy ");
            return;
         }
         var _loc3_:Array = this.getAdjacentBattleEntitiesClockwise(this._entity);
         var _loc4_:int = param2.def.level + 1;
         var _loc5_:int = _loc3_.indexOf(param1);
         if(_loc5_ == -1)
         {
            _loc5_ = 0;
         }
         _loc6_ = _loc5_;
         while(_loc6_ < _loc3_.length)
         {
            if(param2.targetSet.targets.length < _loc4_)
            {
               param2.targetSet.targets.push(_loc3_[_loc6_]);
            }
            _loc6_++;
         }
         if(_loc5_ != 0)
         {
            _loc6_ = 0;
            while(_loc6_ < _loc5_)
            {
               if(param2.targetSet.targets.length < _loc4_)
               {
                  param2.targetSet.targets.push(_loc3_[_loc6_]);
               }
               _loc6_++;
            }
         }
      }
      
      private function handleAbilityBloodyFlail(param1:BattleAbility, param2:Array) : Boolean
      {
         var _loc3_:String = null;
         var _loc4_:IBattleEntity = null;
         if(param2.length > 2)
         {
            _loc3_ = param2[2];
            _loc4_ = this.findBattleEntity(_loc3_);
            if(_loc4_ != null)
            {
               param1.targetSet.targets.splice(0,param1.targetSet.targets.length);
               param1.targetSet.targets.push(_loc4_);
               return true;
            }
            this.logger.error("handleAbilityBloodyFlail: could not find target entity: " + _loc3_);
         }
         else
         {
            this.logger.error("handleAbilityBloodyFlail : not enough arguments. argv.length = " + param2.length);
         }
         return false;
      }
      
      private function handleAbilityRainOfArrows(param1:BattleAbility, param2:Array) : Boolean
      {
         var _loc3_:Array = null;
         var _loc4_:IBattleEntity = null;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         var _loc9_:int = 0;
         var _loc10_:int = 0;
         var _loc11_:Tile = null;
         if(param2.length > 2)
         {
            _loc3_ = param2[2].split(",");
            if(_loc3_.length == 2)
            {
               _loc4_ = this._entity as IBattleEntity;
               _loc5_ = int(this._entity.tile.x);
               _loc6_ = int(this._entity.tile.y);
               _loc7_ = int(_loc3_[0]);
               _loc8_ = int(_loc3_[1]);
               _loc9_ = _loc5_ + _loc7_;
               _loc10_ = _loc6_ + _loc8_;
               _loc11_ = this._entity.board.tiles.getTile(_loc9_,_loc10_);
               if(_loc11_ != null)
               {
                  param1.targetSet.targets.splice(0,param1.targetSet.targets.length);
                  param1.targetSet.addTarget(_loc4_);
                  param1.targetSet.addTile(_loc11_);
                  return true;
               }
            }
            else
            {
               this.logger.error("handleAbilityRainOfArrows: invalid offset given[" + param2[2] + "]");
            }
         }
         else
         {
            this.logger.error("handleAbilityRainOfArrows : not enough arguments. argv.length = " + param2.length);
         }
         return false;
      }
      
      private function handleAbilityMalice(param1:BattleAbility, param2:Array) : Boolean
      {
         var _loc3_:String = null;
         var _loc4_:IBattleEntity = null;
         if(param2.length > 2)
         {
            _loc3_ = param2[2];
            _loc4_ = this.findBattleEntity(_loc3_);
            if(_loc4_ != null)
            {
               param1.targetSet.targets.splice(0,param1.targetSet.targets.length);
               param1.targetSet.targets.push(_loc4_);
               return true;
            }
            this.logger.error("handleAbilityMalice: could not find target entity: " + _loc3_);
         }
         else
         {
            this.logger.error("handleAbilityMalice : not enough arguments. argv.length = " + param2.length);
         }
         return false;
      }
      
      private function findBattleEntity(param1:String) : IBattleEntity
      {
         var _loc2_:IBattleEntity = null;
         if(this._entity != null && this._entity.board != null)
         {
            for each(_loc2_ in this._entity.board.entities)
            {
               if(_loc2_.def.id == param1)
               {
                  return _loc2_;
               }
            }
         }
         return null;
      }
      
      private function isBattleEntityAdjacent(param1:IBattleEntity, param2:IBattleEntity) : Boolean
      {
         var _loc3_:int = int(param1.tile.x);
         var _loc4_:int = int(param1.tile.y);
         if(param1.rect.width == 1)
         {
            if(param2 == this.getBattleEntityOnTile(_loc3_,_loc4_ - 1) || param2 == this.getBattleEntityOnTile(_loc3_ + 1,_loc4_) || param2 == this.getBattleEntityOnTile(_loc3_,_loc4_ + 1) || param2 == this.getBattleEntityOnTile(_loc3_ - 1,_loc4_))
            {
               return true;
            }
         }
         else if(param1.rect.width == 2)
         {
            if(param2 == this.getBattleEntityOnTile(_loc3_,_loc4_ - 1) || param2 == this.getBattleEntityOnTile(_loc3_ + 1,_loc4_ - 1) || param2 == this.getBattleEntityOnTile(_loc3_ + 2,_loc4_) || param2 == this.getBattleEntityOnTile(_loc3_ + 2,_loc4_ + 1) || param2 == this.getBattleEntityOnTile(_loc3_,_loc4_ + 2) || param2 == this.getBattleEntityOnTile(_loc3_ + 1,_loc4_ + 2) || param2 == this.getBattleEntityOnTile(_loc3_ - 1,_loc4_ + 1) || param2 == this.getBattleEntityOnTile(_loc3_ - 1,_loc4_))
            {
               return true;
            }
         }
         return false;
      }
      
      private function getBattleEntityOnTile(param1:int, param2:int) : IBattleEntity
      {
         var _loc4_:ITileResident = null;
         var _loc3_:Tile = this._entity.board.tiles.getTile(param1,param2);
         if(_loc3_ != null)
         {
            _loc4_ = _loc3_.findResident(null);
            if(_loc4_ != null && _loc4_ is IBattleEntity)
            {
               return _loc4_ as IBattleEntity;
            }
         }
         return null;
      }
      
      private function getAdjacentBattleEntitiesClockwise(param1:IBattleEntity) : Array
      {
         var _loc5_:IBattleEntity = null;
         var _loc2_:int = int(param1.tile.x);
         var _loc3_:int = int(param1.tile.y);
         var _loc4_:Array = new Array();
         if(param1.rect.width == 1)
         {
            _loc5_ = this.getBattleEntityOnTile(_loc2_,_loc3_ - 1);
            if(_loc5_ != null && _loc4_.indexOf(_loc5_) == -1)
            {
               _loc4_.push(_loc5_);
            }
            _loc5_ = this.getBattleEntityOnTile(_loc2_ + 1,_loc3_);
            if(_loc5_ != null && _loc4_.indexOf(_loc5_) == -1)
            {
               _loc4_.push(_loc5_);
            }
            _loc5_ = this.getBattleEntityOnTile(_loc2_,_loc3_ + 1);
            if(_loc5_ != null && _loc4_.indexOf(_loc5_) == -1)
            {
               _loc4_.push(_loc5_);
            }
            _loc5_ = this.getBattleEntityOnTile(_loc2_ - 1,_loc3_);
            if(_loc5_ != null && _loc4_.indexOf(_loc5_) == -1)
            {
               _loc4_.push(_loc5_);
            }
         }
         else if(param1.rect.width == 2)
         {
            _loc5_ = this.getBattleEntityOnTile(_loc2_,_loc3_ - 1);
            if(_loc5_ != null && _loc4_.indexOf(_loc5_) == -1)
            {
               _loc4_.push(_loc5_);
            }
            _loc5_ = this.getBattleEntityOnTile(_loc2_ + 1,_loc3_ - 1);
            if(_loc5_ != null && _loc4_.indexOf(_loc5_) == -1)
            {
               _loc4_.push(_loc5_);
            }
            _loc5_ = this.getBattleEntityOnTile(_loc2_ + 2,_loc3_);
            if(_loc5_ != null && _loc4_.indexOf(_loc5_) == -1)
            {
               _loc4_.push(_loc5_);
            }
            _loc5_ = this.getBattleEntityOnTile(_loc2_ + 2,_loc3_ + 1);
            if(_loc5_ != null && _loc4_.indexOf(_loc5_) == -1)
            {
               _loc4_.push(_loc5_);
            }
            _loc5_ = this.getBattleEntityOnTile(_loc2_,_loc3_ + 2);
            if(_loc5_ != null && _loc4_.indexOf(_loc5_) == -1)
            {
               _loc4_.push(_loc5_);
            }
            _loc5_ = this.getBattleEntityOnTile(_loc2_ + 1,_loc3_ + 2);
            if(_loc5_ != null && _loc4_.indexOf(_loc5_) == -1)
            {
               _loc4_.push(_loc5_);
            }
            _loc5_ = this.getBattleEntityOnTile(_loc2_ - 1,_loc3_ + 1);
            if(_loc5_ != null && _loc4_.indexOf(_loc5_) == -1)
            {
               _loc4_.push(_loc5_);
            }
            _loc5_ = this.getBattleEntityOnTile(_loc2_ - 1,_loc3_);
            if(_loc5_ != null && _loc4_.indexOf(_loc5_) == -1)
            {
               _loc4_.push(_loc5_);
            }
         }
         return _loc4_;
      }
      
      public function get move() : IBattleMove
      {
         return this._move;
      }
      
      public function set move(param1:IBattleMove) : void
      {
         if(this._move == param1)
         {
            return;
         }
         if(this._move)
         {
            this._move.cleanup();
            this._move = null;
         }
         if(Boolean(param1) && param1.entity != this._entity)
         {
            throw new ArgumentError("BattleTurn.move ENTITY MISMATCH " + this + " move " + param1);
         }
         this._move = param1;
         if(this._move)
         {
            this._move.listenForWillpower();
         }
      }
      
      public function get number() : int
      {
         return this._number;
      }
      
      public function get entity() : IBattleEntity
      {
         return this._entity;
      }
      
      public function get suspended() : Boolean
      {
         return this._suspended;
      }
      
      public function set suspended(param1:Boolean) : void
      {
         this._suspended = param1;
         if(this._suspended)
         {
            this.logger.info("BattleTurn.suspended " + param1 + " " + this);
            this.committed = true;
         }
      }
      
      public function findNextRangeTile(param1:Tile, param2:int, param3:int) : Tile
      {
         var _loc7_:TileRect = null;
         var _loc8_:int = 0;
         var _loc9_:int = 0;
         var _loc10_:TileLocation = null;
         if(!param1)
         {
            return null;
         }
         var _loc4_:TileLocation = param1.location;
         if(!this._ability || !this._ability.def.targetRule.isTile)
         {
            return null;
         }
         var _loc5_:int = this._ability.def.rangeMax(this._ability.caster);
         if(_loc5_ < 0)
         {
            _loc7_ = this._board.def.walkableTiles.rect;
            _loc5_ = Math.max(_loc7_.width,_loc7_.length);
         }
         else
         {
            _loc5_ += Math.max(this._ability.caster.boardLength,this._ability.caster.boardWidth);
         }
         var _loc6_:int = 1;
         while(_loc6_ <= _loc5_)
         {
            _loc8_ = _loc4_.x + param2 * _loc6_;
            _loc9_ = _loc4_.y + param3 * _loc6_;
            _loc10_ = TileLocation.fetch(_loc8_,_loc9_);
            if(this._inRangeTiles[_loc10_])
            {
               return this._board.tiles.getTileByLocation(_loc10_);
            }
            _loc6_++;
         }
         return null;
      }
      
      public function hasInRangeTile(param1:Tile) : Boolean
      {
         return Boolean(param1) && Boolean(this._inRangeTiles[param1.location]);
      }
      
      public function get inRange() : Dictionary
      {
         return this._inRange;
      }
      
      public function get inRangeTiles() : Dictionary
      {
         return this._inRangeTiles;
      }
      
      public function get timerSecs() : int
      {
         return this._timerSecs;
      }
      
      public function get numAbilities() : int
      {
         return this._numAbilities;
      }
   }
}
