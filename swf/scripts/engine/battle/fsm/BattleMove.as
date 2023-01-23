package engine.battle.fsm
{
   import engine.battle.ability.def.BattleAbilityTargetRule;
   import engine.battle.ability.def.IBattleAbilityDef;
   import engine.battle.ability.effect.model.BattleFacing;
   import engine.battle.ability.effect.model.IPersistedEffects;
   import engine.battle.ability.model.BattleAbilityValidation;
   import engine.battle.board.def.IBattleAttractor;
   import engine.battle.board.model.BattleBoard;
   import engine.battle.board.model.IBattleBoard;
   import engine.battle.board.model.IBattleBoardTriggers;
   import engine.battle.board.model.IBattleEntity;
   import engine.battle.board.model.IBattleMove;
   import engine.battle.sim.TileDiamond;
   import engine.battle.sim.TileLanes;
   import engine.battle.sim.TileRectContainer;
   import engine.battle.sim.TileRectHugger;
   import engine.core.BoxBoolean;
   import engine.core.logging.ILogger;
   import engine.path.IPath;
   import engine.path.IPathGraph;
   import engine.path.IPathGraphLink;
   import engine.path.IPathGraphNode;
   import engine.path.Path;
   import engine.path.PathEvent;
   import engine.path.PathFloodSolver;
   import engine.path.PathFloodSolverNode;
   import engine.path.PathStatus;
   import engine.stat.def.StatType;
   import engine.stat.model.Stat;
   import engine.stat.model.StatEvent;
   import engine.tile.ITileResident;
   import engine.tile.Tile;
   import engine.tile.Tiles;
   import engine.tile.def.TileLocation;
   import engine.tile.def.TileRect;
   import engine.tile.def.TileRectRange;
   import flash.errors.IllegalOperationError;
   import flash.events.EventDispatcher;
   import flash.utils.Dictionary;
   
   public class BattleMove extends EventDispatcher implements IBattleMove
   {
      
      public static var FLOOD_CACHE_DISABLE:Boolean;
      
      private static var _floodCache:Dictionary;
      
      private static var _scratchEntities:Vector.<ITileResident> = new Vector.<ITileResident>();
       
      
      private var _entity:IBattleEntity;
      
      public var _wayPointTile:Tile;
      
      public var _wayPointFacing:BattleFacing;
      
      public var _wayPointSteps:int = 1;
      
      public var _waypointBlocked:Boolean;
      
      public var _pathEndBlocked:Boolean;
      
      protected var steps:Vector.<Tile>;
      
      private var _path:IPath;
      
      private var _flood:PathFloodSolver;
      
      private var _executed:Boolean;
      
      private var _executing:Boolean;
      
      private var _committed:Boolean;
      
      private var _interrupted:Boolean;
      
      private var _forcedMove:Boolean = false;
      
      private var _reactToEntityIntersect:Boolean = false;
      
      private var _changeFacing:Boolean = true;
      
      private var _clampMovement:int;
      
      private var _maxStars:int = 1000;
      
      private var _searchBonus:int = 0;
      
      private var _suppressCommit:Boolean;
      
      private var logger:ILogger;
      
      public var callbackExecuted:Function;
      
      public var unlimited:Boolean;
      
      public var _cleanedup:Boolean;
      
      public var noflood:Boolean;
      
      public var allowUnwalkables:Boolean;
      
      private var _scratchRect:TileRect;
      
      private var _avoidHazards:Boolean;
      
      private var _willpower:Stat;
      
      private var _lastTileRect:TileRect;
      
      private var _lastTileRectDirty:Boolean = true;
      
      private var _scratchHugSorter:Array;
      
      private var needsDispatch_MOVE_CHANGED:Boolean;
      
      private var _pathFloodCacheKey:String;
      
      private var _pathFloodCacheKey_center:Tile;
      
      private var _pathFloodCacheKey_remainStarred:int;
      
      private var _pathFloodCacheKey_tileConfiguration:int;
      
      private var _trimmedImpossibleEndpoints:Vector.<Tile>;
      
      private var _trimmedImpossibleResidents:Vector.<IBattleEntity>;
      
      private var _trimmedImpossibleResidentsCache:Dictionary;
      
      public function BattleMove(param1:IBattleEntity, param2:int = 1000, param3:int = 0, param4:Boolean = false, param5:Boolean = false, param6:Boolean = false, param7:Boolean = false)
      {
         this.steps = new Vector.<Tile>();
         this._lastTileRect = new TileRect(null,0,0);
         this._scratchHugSorter = [];
         this._trimmedImpossibleEndpoints = new Vector.<Tile>();
         this._trimmedImpossibleResidents = new Vector.<IBattleEntity>();
         this._trimmedImpossibleResidentsCache = new Dictionary();
         super();
         if(!param1)
         {
            throw new ArgumentError("BattleMove null entity");
         }
         this._avoidHazards = param7;
         this.allowUnwalkables = param6;
         this._entity = param1;
         this.unlimited = param4;
         this.logger = this._entity.logger;
         this.steps.push(param1.tile);
         this._maxStars = param2;
         this._searchBonus = param3;
         var _loc8_:IPersistedEffects = param1.effects;
         this.noflood = param5;
         this.updateFloods();
      }
      
      public static function flushCache() : void
      {
         var _loc1_:Boolean = false;
         var _loc2_:* = null;
         var _loc3_:PathFloodSolver = null;
         if(!_floodCache)
         {
            return;
         }
         for(_loc2_ in _floodCache)
         {
            _loc3_ = _floodCache[_loc2_];
            if(_loc3_)
            {
               _loc3_.cleanup();
            }
            _loc1_ = true;
         }
         if(_loc1_)
         {
            _floodCache = new Dictionary();
         }
      }
      
      private static function heuristicFloodDistance(param1:Tile, param2:Tile) : Number
      {
         var _loc3_:int = Math.abs(param1.x - param2.x);
         var _loc4_:int = Math.abs(param1.y - param2.y);
         return _loc3_ * 100 + _loc4_;
      }
      
      public static function computeMoveToRange(param1:IBattleAbilityDef, param2:IBattleEntity, param3:IBattleEntity, param4:Tile, param5:ILogger, param6:int, param7:BoxBoolean, param8:IBattleAttractor, param9:Boolean, param10:Boolean) : BattleMove
      {
         var _loc11_:TileRect = !!param3 ? param3.rect : param4.rect;
         var _loc12_:int = TileRectRange.computeRange(_loc11_,param2.rect);
         var _loc13_:int = int(param2.stats.getValue(StatType.MOVEMENT));
         param7.value = true;
         if(_loc13_ + param6 <= 0)
         {
            return null;
         }
         var _loc14_:BattleMove = new BattleMove(param2,param6,0,param10);
         var _loc15_:int = param1.rangeMax(param2);
         var _loc16_:int = param1.rangeMin(param2);
         var _loc17_:BattleAbilityValidation = BattleAbilityValidation.validateRange(param1,param2,null,param3,param4);
         if(_loc17_ != BattleAbilityValidation.OK || param9)
         {
            if(_loc14_.pathForAbility(param1,param3,param4,_loc16_,_loc15_,true,_loc13_ + param6,param8,param9))
            {
               return _loc14_;
            }
            param7.value = false;
            if(_loc13_ <= 0)
            {
               _loc14_.cleanup();
               return null;
            }
            if(_loc14_.pathTowardRect(_loc11_,true,_loc13_,false))
            {
               if(_loc14_.pathEndBlocked)
               {
                  param5.error("BattleMove.computeMoveToRange generated a move with pathEndBlocked: " + _loc14_);
                  _loc14_.cleanup();
                  return null;
               }
               return _loc14_;
            }
            _loc14_.cleanup();
            return null;
         }
         _loc14_.cleanup();
         return null;
      }
      
      public function get cleanedup() : Boolean
      {
         return this._cleanedup;
      }
      
      public function listenForWillpower() : void
      {
         if(this.entity)
         {
            this._willpower = this.entity.stats.getStat(StatType.WILLPOWER,false);
            if(this._willpower)
            {
               this._willpower.addEventListener(StatEvent.CHANGE,this.entityWillpowerHandler);
            }
         }
      }
      
      public function unlistenForWillpower() : void
      {
         if(this._willpower)
         {
            this._willpower.removeEventListener(StatEvent.CHANGE,this.entityWillpowerHandler);
            this._willpower = null;
         }
      }
      
      public function cleanup() : void
      {
         if(this._cleanedup)
         {
            throw new IllegalOperationError("double cleanup");
         }
         this._cleanedup = true;
         this.unlistenForWillpower();
         this._entity = null;
         this.logger = null;
         this.steps = null;
         this.flood = null;
         this._path = null;
         this._trimmedImpossibleEndpoints = null;
         this._trimmedImpossibleResidents = null;
         this._trimmedImpossibleResidentsCache = null;
         this.callbackExecuted = null;
      }
      
      private function entityWillpowerHandler(param1:StatEvent) : void
      {
      }
      
      override public function toString() : String
      {
         if(this.cleanedup)
         {
            return "BattleMove-CLEANEDUP";
         }
         if(!this.entity)
         {
            return "BattleMove-NOENTITY";
         }
         return "[" + this.entity.id + " " + this.first + " -> " + this.last + "] steps " + (this.numSteps - 1) + (this.pathEndBlocked ? " P.E.BLOCKED" : "");
      }
      
      public function clone() : IBattleMove
      {
         return new BattleMove(this._entity,this._maxStars,this._searchBonus,this.unlimited);
      }
      
      public function copy(param1:IBattleMove) : void
      {
         if(this.committed)
         {
            throw new IllegalOperationError("BattleMove.copy already committed " + this);
         }
         if(param1.entity != this.entity)
         {
            throw new ArgumentError("BattleMove.copy incompatible entities");
         }
         if(param1.first != this.entity.tile)
         {
            throw new IllegalOperationError("BattleMove.copy " + this + " bad tiles " + this.steps + " should start with " + this.entity.tile);
         }
         this.steps = (param1 as BattleMove).steps.concat();
         this._lastTileRectDirty = true;
         this._executed = false;
         this._executing = false;
         this._committed = false;
      }
      
      public function equals(param1:BattleMove) : Boolean
      {
         var _loc2_:int = 0;
         if(this.steps.length == param1.steps.length)
         {
            _loc2_ = 0;
            while(_loc2_ < this.steps.length)
            {
               if(!this.steps[_loc2_].equals(param1.steps[_loc2_]))
               {
                  return false;
               }
               _loc2_++;
            }
            return true;
         }
         return false;
      }
      
      public function get forcedMove() : Boolean
      {
         return this._forcedMove;
      }
      
      public function set forcedMove(param1:Boolean) : void
      {
         this._forcedMove = param1;
      }
      
      public function get changeFacing() : Boolean
      {
         return this._changeFacing;
      }
      
      public function set changeFacing(param1:Boolean) : void
      {
         this._changeFacing = param1;
      }
      
      public function get reactToEntityIntersect() : Boolean
      {
         return this._reactToEntityIntersect;
      }
      
      public function set reactToEntityIntersect(param1:Boolean) : void
      {
         this._reactToEntityIntersect = param1;
      }
      
      public function get numSteps() : int
      {
         return !!this.steps ? this.steps.length : 0;
      }
      
      public function getStep(param1:int) : Tile
      {
         return this.steps && param1 >= 0 && param1 < this.steps.length ? this.steps[param1] : null;
      }
      
      public function addStep(param1:Tile) : void
      {
         if(Boolean(this.steps.length) && this.steps[this.steps.length - 1] == param1)
         {
            throw new ArgumentError("Attempt to add duplicate tile [" + param1 + "] as step " + this.steps.length);
         }
         this.steps.push(param1);
         this._lastTileRectDirty = true;
      }
      
      public function get first() : Tile
      {
         if(this.cleanedup || this.steps.length == 0)
         {
            throw new IllegalOperationError("No first for invalid BattleMove " + this + ", cleanedup=" + this.cleanedup);
         }
         return this.steps[0];
      }
      
      public function get last() : Tile
      {
         return this.steps[this.steps.length - 1];
      }
      
      public function get lastFacing() : BattleFacing
      {
         if(this.steps.length <= 1)
         {
            return this.entity.facing;
         }
         var _loc1_:Tile = this.steps[this.steps.length - 1];
         var _loc2_:Tile = this.steps[this.steps.length - 2];
         return BattleFacing.findFacing(_loc1_.x - _loc2_.x,_loc1_.y - _loc2_.y);
      }
      
      public function get lastTileRect() : TileRect
      {
         if(!this._entity || !this.last)
         {
            return null;
         }
         if(this._lastTileRectDirty)
         {
            this._lastTileRect.setup(this.last.location,this._entity.localWidth,this._entity.localLength,this.lastFacing);
            this._lastTileRectDirty = false;
         }
         return this._lastTileRect;
      }
      
      public function getStepFacing(param1:int) : BattleFacing
      {
         if(this.steps.length <= param1 || param1 < 1)
         {
            return this.entity.facing;
         }
         var _loc2_:Tile = this.steps[param1];
         var _loc3_:Tile = this.steps[param1 - 1];
         return BattleFacing.findFacing(_loc2_.x - _loc3_.x,_loc2_.y - _loc3_.y);
      }
      
      public function getStepIndex(param1:Tile) : int
      {
         return this.steps.indexOf(param1);
      }
      
      public function hasStep(param1:Tile) : Boolean
      {
         return this.steps.indexOf(param1) >= 0;
      }
      
      public function get executed() : Boolean
      {
         return this._executed;
      }
      
      public function setExecuted() : void
      {
         if(this._cleanedup)
         {
            throw new IllegalOperationError("cleaned up cannot setExecuted");
         }
         if(!this._committed)
         {
            this.setCommitted("BattleMove.setExecuted");
         }
         if(this._executed)
         {
            throw new IllegalOperationError("already executed");
         }
         this._executing = false;
         this._executed = true;
         this.logger.i("MOVE","Executed " + this);
         this.doDispatch(BattleMoveEvent.EXECUTED);
         if(this.callbackExecuted != null)
         {
            this.callbackExecuted(this);
         }
      }
      
      public function get committed() : Boolean
      {
         return this._committed;
      }
      
      public function uncommitMove() : void
      {
         if(this._executing)
         {
            throw new IllegalOperationError("currently executing");
         }
         if(this._executed)
         {
            this._executed = false;
            this.doDispatch(BattleMoveEvent.EXECUTED);
         }
         if(this._committed)
         {
            this._committed = false;
            this.doDispatch(BattleMoveEvent.COMMITTED);
         }
         this._clampMovement = 3;
         this._maxStars = 0;
         this.resetFlood();
         this.reset(this._entity.tile);
      }
      
      private function resetFlood() : void
      {
         this.flood = null;
      }
      
      public function setCommitted(param1:String) : void
      {
         var _loc2_:Stat = null;
         var _loc3_:int = 0;
         var _loc4_:Stat = null;
         if(this._committed)
         {
            throw new IllegalOperationError("already committed");
         }
         if(this.first != this.entity.tile)
         {
            throw new IllegalOperationError("Attempt to teleport " + this.entity + " from " + this.entity.tile + " to " + this.first);
         }
         if(this._suppressCommit)
         {
            return;
         }
         if(this.logger.isDebugEnabled)
         {
            _loc2_ = this.entity.stats.getStat(StatType.WILLPOWER,false);
            if(_loc2_)
            {
               _loc3_ = int(this.entity.stats.exertionMoveBonusCur);
               _loc4_ = this.entity.stats.getStat(StatType.MOVEMENT);
               this.logger.debug("BattleMove.setCommitted " + this + " reason=" + param1 + " mov=" + _loc4_ + " wil=" + _loc2_ + " bonus=" + _loc3_);
            }
            else
            {
               this.logger.info("BattleMove.setCommitted " + this + " no WILLPOWER stat");
            }
         }
         this._committed = true;
         this.doDispatch(BattleMoveEvent.COMMITTED);
      }
      
      public function get path() : IPath
      {
         return this._path;
      }
      
      private function setPath(param1:IPath) : void
      {
         if(this.committed)
         {
            throw new IllegalOperationError("BattleMove.setPath already committed " + this);
         }
         if(this._path == param1)
         {
            return;
         }
         if(this._path)
         {
            this._path.dispatcher.removeEventListener(PathEvent.EVENT_PATH_STATUS_CHANGED,this.pathStatusChangedHandler);
            this._path.status = PathStatus.TERMINATE;
            this._path = null;
         }
         this._path = param1;
         this._pathEndBlocked = false;
         if(this._path)
         {
            this._path.dispatcher.addEventListener(PathEvent.EVENT_PATH_STATUS_CHANGED,this.pathStatusChangedHandler);
            this._pathEndBlocked = this._isEndBlockedAt(this._path.nodes.length - 1);
         }
      }
      
      private function _isEndBlockedAt(param1:int) : Boolean
      {
         var _loc2_:Tile = null;
         var _loc3_:Tile = null;
         var _loc4_:BattleFacing = null;
         var _loc5_:BattleBoard = null;
         var _loc6_:Tiles = null;
         var _loc7_:Vector.<IBattleEntity> = null;
         var _loc8_:int = 0;
         if(param1 > 0)
         {
            _loc2_ = this.steps[param1 - 0];
            _loc3_ = this.steps[param1 - 1];
            _loc4_ = BattleFacing.findFacing(_loc2_.x - _loc3_.x,_loc2_.y - _loc3_.y);
            _loc5_ = this._entity.board as BattleBoard;
            _loc6_ = _loc5_.tiles;
            this._scratchRect = !!this._scratchRect ? this._scratchRect : this._entity.rect.clone();
            this._scratchRect.setLocation(_loc2_.location);
            this._scratchRect.facing = _loc4_;
            _loc7_ = new Vector.<IBattleEntity>();
            if(_loc5_.findAllRectIntersectionEntities(this._scratchRect,this._entity,_loc7_))
            {
               _loc8_ = 0;
               while(_loc8_ < _loc7_.length)
               {
                  if(!_loc7_[_loc8_].nonexistant)
                  {
                     if(this.entity.awareOf(_loc7_[_loc8_]))
                     {
                        return true;
                     }
                  }
                  _loc8_++;
               }
            }
         }
         return false;
      }
      
      public function reset(param1:Tile) : void
      {
         if(!this._flood || this._flood.cleanedup)
         {
            this._flood = null;
            this.updateFloods();
         }
         if(!param1)
         {
            param1 = this.first;
         }
         if(this.steps.length == 1 && param1 == this.steps[0])
         {
            if(this.wayPointSteps == 1 && !this.wayPointTile)
            {
               if(!this._path)
               {
                  return;
               }
            }
         }
         this.setPath(null);
         if(param1 != this.entity.tile)
         {
            throw new IllegalOperationError("BattleMove.reset " + this + " invalid tile " + param1);
         }
         if(this.committed)
         {
            throw new IllegalOperationError("BattleMove.reset already committed " + this);
         }
         this.steps.splice(0,this.steps.length,param1);
         this.setWayPoint(param1);
         this.updateFloods();
         this.handlePlanChanged(false);
      }
      
      public function setWayPoint(param1:Tile) : void
      {
         if(Boolean(param1) && param1 != this.last)
         {
            throw new IllegalOperationError("BattleMove [" + this.entity + "] bad waypoint [" + param1 + "]");
         }
         if(this.committed)
         {
            throw new IllegalOperationError("BattleMove.setWayPoint Attempt to modify committed move " + this);
         }
         this._wayPointSteps = this.numSteps;
         this._wayPointTile = param1;
         this._waypointBlocked = !!param1 ? this._isEndBlockedAt(this._wayPointSteps - 1) : false;
         this._wayPointFacing = !!param1 ? this.getStepFacing(this._wayPointSteps - 1) : null;
         if(!this._entity.hasSubmergedMove)
         {
            this.updateFloods();
         }
         this.doDispatch(BattleMoveEvent.WAYPOINT);
      }
      
      public function trimStepsToWaypoint(param1:Boolean) : Boolean
      {
         if(this._wayPointSteps < this.steps.length)
         {
            this.steps.splice(this._wayPointSteps,this.steps.length - this._wayPointSteps);
            this.handlePlanChanged(param1);
            return true;
         }
         return false;
      }
      
      public function trimStepsTo(param1:int) : void
      {
         if(param1 < 0)
         {
            throw new ArgumentError("BattleMove.trimStepsTo invalid index " + param1 + " for " + this);
         }
         if(param1 < this.steps.length - 1)
         {
            this.steps.splice(param1 + 1,this.steps.length - param1 - 1);
            this.handlePlanChanged(true);
         }
      }
      
      public function trimStepsInLoop(param1:Tile) : Boolean
      {
         var _loc2_:int = this.steps.indexOf(param1);
         if(_loc2_ >= 0)
         {
            if(_loc2_ < this.steps.length - 1)
            {
               this.steps.splice(_loc2_ + 1,this.steps.length - _loc2_);
            }
            this.handlePlanChanged(true);
            return true;
         }
         return false;
      }
      
      public function pathForAbility(param1:IBattleAbilityDef, param2:IBattleEntity, param3:Tile, param4:int, param5:int, param6:Boolean, param7:int, param8:IBattleAttractor, param9:Boolean) : Boolean
      {
         var _loc11_:TileRect = null;
         var _loc10_:BattleAbilityTargetRule = param1.targetRule;
         if(_loc10_ == BattleAbilityTargetRule.SPECIAL_RUN_THROUGH || _loc10_ == BattleAbilityTargetRule.SPECIAL_RUN_TO || _loc10_ == BattleAbilityTargetRule.SPECIAL_TRAMPLE)
         {
            if(param5 > 0)
            {
               _loc11_ = !!param2 ? param2.rect : new TileRect(param3.location,1,1);
               param5 = Math.max(1,param5 - _loc11_.width - 1);
            }
            return this.pathToLanes(param1,param2,param3,param4,param5,param6,param7,param9);
         }
         return this.pathToDiamond(param1,param2,param3,param4,param5,param6,param7,param8,param9);
      }
      
      public function pathToLanes(param1:IBattleAbilityDef, param2:IBattleEntity, param3:Tile, param4:int, param5:int, param6:Boolean, param7:int, param8:Boolean) : Boolean
      {
         var _loc12_:BattleAbilityValidation = null;
         var _loc14_:TileLocation = null;
         var _loc15_:Tile = null;
         var _loc16_:PathFloodSolverNode = null;
         if(param5 < 0)
         {
            throw new ArgumentError("No need to path when maxDist < 0");
         }
         var _loc9_:TileRect = new TileRect(this.last.location,this.entity.boardWidth,this.entity.boardLength);
         var _loc10_:TileRect = !!param2 ? param2.rect : param3.rect;
         var _loc11_:TileLanes = new TileLanes(param2.board.tiles,_loc10_,param4,param5,_loc9_,param7);
         if(!param8 && _loc11_.hugs.indexOf(this.last.location) >= 0)
         {
            _loc12_ = BattleAbilityValidation.validateRange(param1,this.entity,this,param2,param3);
            if(_loc12_ == BattleAbilityValidation.OK)
            {
               return true;
            }
         }
         var _loc13_:int = this.numSteps;
         for each(_loc14_ in _loc11_.hugs)
         {
            _loc15_ = this.entity.board.tiles.getTile(_loc14_.x,_loc14_.y);
            _loc16_ = this.flood.resultSet[_loc15_];
            if(_loc16_)
            {
               this.trimStepsTo(_loc13_);
               this.process(_loc15_,param6);
               if(param7 > 0)
               {
                  if(this.numSteps > param7 + 1)
                  {
                     this.trimStepsTo(param7);
                  }
               }
               if(!this.pathEndBlocked)
               {
                  _loc12_ = BattleAbilityValidation.validateRange(param1,this.entity,this,param2,param3);
                  if(_loc12_ == BattleAbilityValidation.OK)
                  {
                     return true;
                  }
               }
            }
         }
         if(_loc13_ > 1)
         {
            this.reset(this.steps[0]);
            return this.pathToLanes(param1,param2,param3,param4,param5,param6,param7,param8);
         }
         return false;
      }
      
      private function _updateHugSorter(param1:Vector.<TileLocation>) : void
      {
         var _loc3_:TileLocation = null;
         var _loc4_:Tile = null;
         var _loc5_:PathFloodSolverNode = null;
         var _loc6_:Object = null;
         var _loc2_:int = 0;
         while(_loc2_ < param1.length)
         {
            _loc3_ = param1[_loc2_];
            _loc4_ = this.entity.board.tiles.getTile(_loc3_.x,_loc3_.y);
            _loc5_ = this.flood.resultSet[_loc4_];
            if(_loc2_ < this._scratchHugSorter.length)
            {
               _loc6_ = this._scratchHugSorter[_loc2_];
            }
            else
            {
               _loc6_ = {};
               this._scratchHugSorter.push(_loc6_);
            }
            if(!_loc5_)
            {
               _loc6_.tl = null;
               _loc6_.gg = int.MAX_VALUE;
            }
            else
            {
               _loc6_.tl = _loc3_;
               _loc6_.gg = _loc5_.gg - _loc5_.g;
            }
            _loc2_++;
         }
         while(_loc2_ < this._scratchHugSorter.length)
         {
            _loc6_ = this._scratchHugSorter[_loc2_];
            _loc6_.tl = null;
            _loc6_.gg = int.MAX_VALUE;
            _loc2_++;
         }
         this._scratchHugSorter.sortOn("gg",Array.NUMERIC);
      }
      
      public function pathToDiamond(param1:IBattleAbilityDef, param2:IBattleEntity, param3:Tile, param4:int, param5:int, param6:Boolean, param7:int, param8:IBattleAttractor, param9:Boolean) : Boolean
      {
         var _loc13_:BattleAbilityValidation = null;
         var _loc15_:Object = null;
         var _loc16_:TileLocation = null;
         var _loc17_:Tile = null;
         var _loc18_:PathFloodSolverNode = null;
         if(param5 < 0)
         {
            throw new ArgumentError("No need to path when maxDist < 0");
         }
         var _loc10_:TileRect = !!param8 ? param8.core : new TileRect(this.last.location,this.entity.boardWidth,this.entity.boardLength);
         var _loc11_:TileRect = !!param2 ? param2.rect : param3.rect;
         var _loc12_:TileDiamond = new TileDiamond(this.entity.board.tiles,_loc11_,param4,param5,_loc10_,param7);
         if(!param9 && _loc12_.hugs.indexOf(this.last.location) >= 0)
         {
            _loc13_ = BattleAbilityValidation.validateRange(param1,this.entity,this,param2,null);
            if(_loc13_ == BattleAbilityValidation.OK)
            {
               return true;
            }
         }
         var _loc14_:int = this.numSteps;
         this._updateHugSorter(_loc12_.hugs);
         for each(_loc15_ in this._scratchHugSorter)
         {
            _loc16_ = _loc15_.tl;
            if(!_loc16_)
            {
               break;
            }
            _loc17_ = this.entity.board.tiles.getTile(_loc16_.x,_loc16_.y);
            _loc18_ = this.flood.resultSet[_loc17_];
            if(_loc18_)
            {
               this.trimStepsTo(_loc14_ - 1);
               this.process(_loc17_,param6);
               if(param7 > 0)
               {
                  if(this.numSteps > param7 + 1)
                  {
                     this.trimStepsTo(param7);
                  }
               }
               if(!this.pathEndBlocked)
               {
                  _loc13_ = BattleAbilityValidation.validateRange(param1,this._entity,this,param2,param3);
                  if(_loc13_ == BattleAbilityValidation.OK)
                  {
                     return true;
                  }
               }
            }
         }
         if(_loc14_ > 1)
         {
            this.reset(this.steps[0]);
            return this.pathToDiamond(param1,param2,param3,param4,param5,param6,param7,param8,param9);
         }
         return false;
      }
      
      public function pathIntoRect(param1:TileRect, param2:Boolean, param3:int) : Boolean
      {
         var _loc7_:TileLocation = null;
         var _loc8_:Tile = null;
         var _loc9_:PathFloodSolverNode = null;
         var _loc4_:TileRect = new TileRect(this.last.location,this.entity.boardWidth,this.entity.boardLength);
         if(param1.testIntersectsRect(_loc4_))
         {
            return true;
         }
         var _loc5_:TileRectContainer = new TileRectContainer(_loc4_,param1);
         var _loc6_:int = this.steps.length - 1;
         for each(_loc7_ in _loc5_.hugs)
         {
            _loc8_ = this.entity.board.tiles.getTile(_loc7_.x,_loc7_.y);
            _loc9_ = this.flood.resultSet[_loc8_];
            if(_loc9_)
            {
               this.process(_loc8_,param2);
               if(this.numSteps > param3 + 1)
               {
                  this.trimStepsTo(param3);
               }
               if(!this.pathEndBlocked)
               {
                  return true;
               }
               this.trimStepsTo(_loc6_);
            }
         }
         if(this.numSteps > 1)
         {
            this.reset(this.steps[0]);
            return this.pathIntoRect(param1,param2,param3);
         }
         return false;
      }
      
      public function pathTowardRect(param1:TileRect, param2:Boolean, param3:int, param4:Boolean) : Boolean
      {
         var _loc8_:Tile = null;
         var _loc11_:PathFloodSolverNode = null;
         var _loc15_:Tile = null;
         var _loc16_:IPathGraphNode = null;
         var _loc17_:PathFloodSolverNode = null;
         var _loc18_:int = 0;
         var _loc19_:int = 0;
         var _loc5_:Tile = this.first;
         var _loc6_:int = TileRectRange.computeTileRange(_loc5_.location,param1);
         var _loc7_:IPathGraph = this.entity.board.tiles.pathGraph;
         var _loc9_:int = _loc6_;
         var _loc10_:int = 0;
         var _loc12_:int = 0;
         var _loc13_:int = Math.max(0,_loc6_ - param3);
         if(!param4)
         {
            _loc13_ = Math.max(1,_loc13_);
         }
         var _loc14_:int = 0;
         for(; _loc14_ < this._flood.resultList.length; _loc14_++)
         {
            _loc15_ = this._flood.resultList[_loc14_];
            if(_loc15_.location != _loc5_.location)
            {
               if(!_loc15_._numResidents)
               {
                  if(!param4)
                  {
                     if(param1.contains(_loc15_.x,_loc15_.y))
                     {
                        continue;
                     }
                  }
                  _loc16_ = _loc7_.getNode(_loc15_);
                  _loc17_ = this._flood.getNode(_loc16_);
                  _loc18_ = !!_loc17_ ? _loc17_.gg - _loc17_.g : 0;
                  if(_loc17_.g <= param3)
                  {
                     _loc19_ = TileRectRange.computeTileRange(_loc15_.location,param1);
                     if(_loc19_ < _loc9_ || _loc19_ == _loc9_ && _loc18_ < _loc12_)
                     {
                        if(!(Boolean(_loc8_) && _loc18_ > _loc12_))
                        {
                           if(this.process(_loc15_,false))
                           {
                              if(this.pathEndBlocked)
                              {
                                 this.reset(this.steps[0]);
                              }
                              else
                              {
                                 _loc9_ = _loc19_;
                                 _loc8_ = _loc15_;
                                 _loc10_ = _loc17_.g;
                                 _loc11_ = _loc17_;
                                 _loc12_ = _loc18_;
                                 if(_loc19_ <= _loc13_ && _loc12_ == 0)
                                 {
                                    return true;
                                 }
                              }
                           }
                           else if(this.steps.length > 1)
                           {
                              this.reset(this.steps[0]);
                           }
                        }
                     }
                  }
               }
            }
         }
         if(_loc11_)
         {
            if(this.steps.length > 1 && this.last != _loc8_)
            {
               this.reset(this.steps[0]);
               return this.process(_loc8_,false);
            }
            return true;
         }
         if(this.steps.length > 1)
         {
            this.reset(this.steps[0]);
         }
         return false;
      }
      
      public function pathToRect(param1:TileRect, param2:Boolean, param3:int, param4:Boolean) : Boolean
      {
         var _loc8_:TileLocation = null;
         var _loc9_:Tile = null;
         var _loc10_:PathFloodSolverNode = null;
         if(param4)
         {
            if(this.pathIntoRect(param1,param2,param3))
            {
               return true;
            }
         }
         var _loc5_:TileRect = new TileRect(this.last.location,this.entity.boardWidth,this.entity.boardLength);
         var _loc6_:TileRectHugger = new TileRectHugger(_loc5_,param1);
         if(_loc6_.hugs.indexOf(this.last.location) >= 0)
         {
            return true;
         }
         var _loc7_:int = this.steps.length - 1;
         for each(_loc8_ in _loc6_.hugs)
         {
            _loc9_ = this.entity.board.tiles.getTile(_loc8_.x,_loc8_.y);
            _loc10_ = this.flood.resultSet[_loc9_];
            if(_loc10_)
            {
               this.process(_loc9_,param2);
               if(this.numSteps > param3 + 1)
               {
                  this.trimStepsTo(param3);
               }
               if(!this.pathEndBlocked)
               {
                  return true;
               }
               this.trimStepsTo(_loc7_);
            }
         }
         if(this.numSteps > 1)
         {
            this.reset(this.steps[0]);
            return this.pathToRect(param1,param2,param3,param4);
         }
         return false;
      }
      
      public function process(param1:Tile, param2:Boolean) : Boolean
      {
         var _loc5_:IPath = null;
         var _loc7_:int = 0;
         var _loc8_:IPathGraphLink = null;
         var _loc9_:IBattleEntity = null;
         var _loc10_:int = 0;
         var _loc11_:int = 0;
         var _loc12_:int = 0;
         var _loc13_:int = 0;
         var _loc14_:int = 0;
         if(!param1)
         {
            throw new ArgumentError("uuuuuuhhhh");
         }
         if(this.committed)
         {
            throw new ArgumentError("Can\'t process when turn has already been commited.");
         }
         if(param1 == this.last)
         {
            if(this.needsDispatch_MOVE_CHANGED)
            {
               this.notifyPlanChanged();
            }
            return false;
         }
         if(param2)
         {
            if(this.trimStepsInLoop(param1))
            {
               return true;
            }
         }
         if(this._entity.hasSubmergedMove)
         {
            if(this.numSteps > 1)
            {
               this.reset(null);
            }
         }
         var _loc3_:int = this.steps.length;
         var _loc4_:IPathGraphNode = this.entity.board.tiles.pathGraph.getNode(param1);
         var _loc6_:Boolean = this.trimStepsToWaypoint(false);
         this.needsDispatch_MOVE_CHANGED = _loc6_ || this.needsDispatch_MOVE_CHANGED;
         _loc5_ = this._flood.reconstructPathTo(_loc4_);
         if(!_loc5_)
         {
            if(_loc6_)
            {
               this.notifyPlanChanged();
            }
            return false;
         }
         if(_loc5_.status == PathStatus.COMPLETE)
         {
            _loc7_ = 0;
            while(_loc7_ < _loc5_.links.length)
            {
               _loc8_ = _loc5_.links[_loc7_];
               this.addStep(_loc8_.dst.key as Tile);
               _loc7_++;
            }
         }
         if(_loc3_ > 1)
         {
            _loc9_ = this.entity;
            _loc10_ = Math.min(_loc9_.stats.getStat(StatType.EXERTION).value,_loc9_.stats.getStat(StatType.WILLPOWER).value);
            _loc11_ = int(_loc9_.stats.getValue(StatType.WILLPOWER_MOVE,1));
            _loc12_ = _loc11_ * _loc10_;
            _loc13_ = this.getMovementStat();
            _loc14_ = _loc13_ + _loc12_;
            if(this.steps.length > _loc14_ + 1)
            {
               this.reset(this.steps[0]);
               this.updateFloods();
               this.process(param1,param2);
               return true;
            }
         }
         if(param2)
         {
            this.trimLoops();
         }
         this.handlePlanChanged(true);
         return true;
      }
      
      private function trimLoops() : void
      {
         var _loc2_:Tile = null;
         var _loc3_:int = 0;
         var _loc1_:int = 0;
         while(_loc1_ < this.steps.length - 1)
         {
            _loc2_ = this.steps[_loc1_];
            _loc3_ = this.steps.indexOf(_loc2_,_loc1_ + 1);
            if(_loc3_ > _loc1_)
            {
               this.steps.splice(_loc1_ + 1,_loc3_ - _loc1_);
               this._lastTileRectDirty = true;
            }
            _loc1_++;
         }
      }
      
      protected function pathStatusChangedHandler(param1:PathEvent) : void
      {
         var _loc2_:int = 0;
         var _loc3_:IPathGraphLink = null;
         if(param1.path != this.path)
         {
            throw new IllegalOperationError("balls");
         }
         if(this.path.status == PathStatus.WAITING || this.path.status == PathStatus.WORKING)
         {
            return;
         }
         if(this.path.status == PathStatus.COMPLETE)
         {
            _loc2_ = 0;
            while(_loc2_ < this.path.links.length)
            {
               _loc3_ = this.path.links[_loc2_];
               this.addStep(_loc3_.dst.key as Tile);
               _loc2_++;
            }
         }
         this.setPath(null);
         this.handlePlanChanged(true);
      }
      
      private function heuristicHazards(param1:Tile) : Number
      {
         var _loc2_:IBattleBoard = this.entity.board;
         var _loc3_:IBattleBoardTriggers = _loc2_.triggers;
         if(_loc3_)
         {
            this._scratchRect = !!this._scratchRect ? this._scratchRect : this._entity.rect.clone();
            this._scratchRect.setLocation(param1.location);
            if(_loc3_.findEntityHazardAtRect(this._entity,this._scratchRect,true))
            {
               return 4;
            }
         }
         return 0;
      }
      
      public function createFlood(param1:Tile, param2:int, param3:Boolean, param4:String, param5:String, param6:Boolean) : PathFloodSolver
      {
         var _loc7_:IPathGraphNode = null;
         var _loc8_:NodeBlockedChecker_BattleMove = null;
         var _loc9_:Function = null;
         var _loc10_:PathFloodSolver = null;
         if(param1)
         {
            _loc7_ = this.entity.board.tiles.pathGraph.getNode(param1);
            _loc8_ = new NodeBlockedChecker_BattleMove(this);
            _loc8_.stepsBlock = param3;
            _loc9_ = param6 ? this.heuristicHazards : null;
            return new PathFloodSolver(_loc7_,heuristicFloodDistance,_loc9_,_loc8_.nodeBlockedFunc,param2,param4,param5);
         }
         return null;
      }
      
      private function handlePlanChanged(param1:Boolean) : void
      {
         var _loc4_:IPathGraphNode = null;
         var _loc5_:IPathGraphNode = null;
         var _loc6_:Path = null;
         var _loc7_:IPathGraphNode = null;
         var _loc8_:int = 0;
         var _loc9_:Tile = null;
         var _loc10_:IPathGraphNode = null;
         var _loc11_:IPathGraphLink = null;
         this._lastTileRectDirty = true;
         var _loc2_:IBattleEntity = this.entity;
         if(_loc2_)
         {
            this.updateFloods();
         }
         else
         {
            this.flood = null;
         }
         var _loc3_:Tiles = this.entity.board.tiles;
         if(this.steps.length > 1)
         {
            _loc4_ = _loc3_.pathGraph.getNode(this.first);
            _loc5_ = _loc3_.pathGraph.getNode(this.last);
            _loc6_ = new Path(_loc4_,_loc5_);
            _loc7_ = _loc4_;
            _loc8_ = 1;
            while(_loc8_ < this.steps.length)
            {
               _loc9_ = this.steps[_loc8_];
               _loc10_ = _loc3_.pathGraph.getNode(_loc9_);
               _loc11_ = _loc7_.getLink(_loc10_);
               _loc6_.links.push(_loc11_);
               _loc7_ = _loc10_;
               _loc8_++;
            }
            _loc6_.status = PathStatus.COMPLETE;
            this.setPath(_loc6_);
         }
         else
         {
            this.setPath(null);
         }
         if(param1)
         {
            this.notifyPlanChanged();
         }
      }
      
      public function notifyPlanChanged() : void
      {
         this.needsDispatch_MOVE_CHANGED = false;
         this.doDispatch(BattleMoveEvent.MOVE_CHANGED);
      }
      
      public function getMovementStat() : int
      {
         if(!this.entity || !this.entity.stats || this.cleanedup)
         {
            return 0;
         }
         if(this.unlimited)
         {
            return 20;
         }
         var _loc1_:int = int(this.entity.stats.getValue(StatType.MOVEMENT));
         if(this._clampMovement)
         {
            _loc1_ = Math.min(this._clampMovement,_loc1_);
         }
         return Math.max(0,_loc1_);
      }
      
      private function makePathFloodCacheKey(param1:Tile, param2:int) : String
      {
         if(this.noflood)
         {
            throw IllegalOperationError("Attempt to makePathFloodCacheKey with noflood turned on: " + this);
         }
         var _loc3_:BattleBoard = this.entity.board as BattleBoard;
         if(this._pathFloodCacheKey)
         {
            if(this._pathFloodCacheKey_center == param1 && this._pathFloodCacheKey_remainStarred == param2 && this._pathFloodCacheKey_tileConfiguration == _loc3_._tileConfiguration)
            {
               return this._pathFloodCacheKey;
            }
         }
         var _loc4_:uint = 0;
         _loc4_ |= uint(this.entity.numericId);
         _loc4_ |= uint(param2) << 24;
         var _loc5_:uint = 0;
         _loc5_ |= _loc3_._tileConfiguration;
         this._pathFloodCacheKey = _loc4_.toString(16) + "_" + _loc5_.toString(16) + "_" + param1.x.toString(16) + "_" + param1.y.toString(16);
         this._pathFloodCacheKey_center = param1;
         this._pathFloodCacheKey_remainStarred = param2;
         this._pathFloodCacheKey_tileConfiguration = _loc3_._tileConfiguration;
         return this._pathFloodCacheKey;
      }
      
      public function updateFloods() : void
      {
         var _loc10_:String = null;
         if(this.noflood)
         {
            return;
         }
         if(this.cleanedup)
         {
            throw new IllegalOperationError("BattleMove.updateFloods already cleaned up " + this);
         }
         if(!this.steps.length)
         {
            throw new IllegalOperationError("BattleMove.updateFloods no steps " + this);
         }
         var _loc1_:IBattleEntity = this.entity;
         if(!_loc1_)
         {
            return;
         }
         var _loc2_:int = this.getMovementStat();
         var _loc3_:int = _loc2_ - this.wayPointSteps + 1;
         var _loc4_:int = Math.min(_loc1_.stats.getValue(StatType.EXERTION),_loc1_.stats.getValue(StatType.WILLPOWER));
         _loc4_ = Math.min(this._maxStars,_loc4_);
         var _loc5_:int = int(_loc1_.stats.getValue(StatType.WILLPOWER_MOVE,1));
         var _loc6_:int = _loc5_ * _loc4_;
         var _loc7_:int = _loc3_ + _loc6_;
         _loc7_ += this._searchBonus;
         var _loc8_:Tile = this._wayPointTile;
         if(this._entity.hasSubmergedMove)
         {
            _loc8_ = this.first;
         }
         if(!_loc8_)
         {
            _loc8_ = this.first;
         }
         if(!_loc8_)
         {
            return;
         }
         var _loc9_:String = this.makePathFloodCacheKey(_loc8_,_loc7_);
         if(this._flood && !this._flood.cleanedup && this._flood.cacheKey == _loc9_)
         {
            return;
         }
         if(!_floodCache && !FLOOD_CACHE_DISABLE)
         {
            _floodCache = new Dictionary();
         }
         if(_floodCache)
         {
            this.flood = _floodCache[_loc9_];
         }
         if(!this._flood || this._flood.cleanedup || this._flood.cacheKey != _loc9_)
         {
            this.flood = this.createFlood(_loc8_,_loc7_,true,_loc9_,_loc10_,this._avoidHazards);
            this._flood.update(-1,null);
         }
         this.doDispatch(BattleMoveEvent.FLOOD_CHANGED);
      }
      
      public function isInRange(param1:Tile) : Boolean
      {
         if(this.flood)
         {
            return this.flood.inResultSet(param1);
         }
         return false;
      }
      
      public function get executing() : Boolean
      {
         return this._executing;
      }
      
      private function get canDispatch() : Boolean
      {
         return this._entity && this._entity.board && !this._entity.cleanedup && !this._entity.board.cleanedup;
      }
      
      public function setExecuting() : void
      {
         this._executing = true;
         this.doDispatch(BattleMoveEvent.EXECUTING);
      }
      
      public function get interrupted() : Boolean
      {
         return this._interrupted;
      }
      
      private function doDispatch(param1:String, param2:IBattleEntity = null) : void
      {
         if(this.canDispatch)
         {
            dispatchEvent(new BattleMoveEvent(param1,this,param2));
         }
      }
      
      public function setInterrupted() : void
      {
         this._interrupted = true;
         this.doDispatch(BattleMoveEvent.INTERRUPTED);
      }
      
      public function handleIntersectEntity(param1:IBattleEntity) : void
      {
         this.doDispatch(BattleMoveEvent.INTERSECT_ENTITY,param1);
      }
      
      public function get entity() : IBattleEntity
      {
         return this._entity;
      }
      
      public function get suppressCommit() : Boolean
      {
         return this._suppressCommit;
      }
      
      public function set suppressCommit(param1:Boolean) : void
      {
         if(this._suppressCommit == param1)
         {
            return;
         }
         this._suppressCommit = param1;
         this.doDispatch(BattleMoveEvent.SUPPRESS_COMMIT);
      }
      
      public function get flood() : PathFloodSolver
      {
         if(!this._flood || this._flood.cleanedup)
         {
            this._flood = null;
            this.updateFloods();
         }
         return this._flood;
      }
      
      public function set flood(param1:PathFloodSolver) : void
      {
         if(this._flood == param1)
         {
            return;
         }
         if(this._flood)
         {
            if(!_floodCache)
            {
               this._flood.cleanup();
            }
            else if(!this._flood.cleanedup)
            {
               --this._flood.refcount;
               if(this._flood.refcount <= 0)
               {
                  delete _floodCache[this._flood.cacheKey];
                  this._flood.cleanup();
               }
            }
         }
         this._flood = param1;
         if(Boolean(this._flood) && Boolean(_floodCache))
         {
            ++this._flood.refcount;
            _floodCache[this._flood.cacheKey] = this._flood;
         }
      }
      
      public function get trimmedImpossibleEndpoints() : Vector.<Tile>
      {
         return this._trimmedImpossibleEndpoints;
      }
      
      public function get trimmedImpossibleResidents() : Vector.<IBattleEntity>
      {
         return this._trimmedImpossibleResidents;
      }
      
      public function trimImpossibleEndpoints() : void
      {
         var _loc2_:Boolean = false;
         var _loc3_:int = 0;
         var _loc4_:Tile = null;
         var _loc5_:* = false;
         var _loc6_:ITileResident = null;
         var _loc7_:IBattleEntity = null;
         if(this._trimmedImpossibleEndpoints.length)
         {
            this._trimmedImpossibleEndpoints.splice(0,this._trimmedImpossibleEndpoints.length);
            this._trimmedImpossibleResidentsCache = new Dictionary();
         }
         if(this.steps.length < 3)
         {
            this.logger.info("BattleMove.trimImpossibleEndpoints SKIP " + this);
            return;
         }
         var _loc1_:Tiles = this._entity.board.tiles;
         while(this.steps.length > 2)
         {
            _loc3_ = this.steps.length - 1;
            _loc4_ = this.steps[_loc3_];
            _scratchEntities.splice(0,_scratchEntities.length);
            _loc5_ = !_loc2_;
            if(!_loc1_.isTileBlockedForEntity(this._entity,_loc4_,_loc5_,false,this.allowUnwalkables,_scratchEntities))
            {
               break;
            }
            _loc2_ = true;
            this.steps.pop();
            this._trimmedImpossibleEndpoints.push(_loc4_);
            for each(_loc6_ in _scratchEntities)
            {
               _loc7_ = _loc6_ as IBattleEntity;
               if(Boolean(_loc7_) && !this._trimmedImpossibleResidentsCache[_loc7_])
               {
                  this._trimmedImpossibleResidents.push(_loc7_);
               }
            }
         }
         if(this._trimmedImpossibleEndpoints.length)
         {
            this.logger.info("BattleMove.trimImpossibleEndpoints TRIMMED " + this + " removed " + this._trimmedImpossibleEndpoints.length);
         }
      }
      
      public function get wayPointTile() : Tile
      {
         return this._wayPointTile;
      }
      
      public function get pathEndBlocked() : Boolean
      {
         return this._pathEndBlocked;
      }
      
      public function get wayPointFacing() : BattleFacing
      {
         return this._wayPointFacing;
      }
      
      public function get wayPointSteps() : int
      {
         return this._wayPointSteps;
      }
      
      public function get waypointBlocked() : Boolean
      {
         return this._waypointBlocked;
      }
   }
}

import engine.battle.board.model.BattleBoard;
import engine.battle.board.model.IBattleEntity;
import engine.battle.board.model.IBattleMove;
import engine.battle.entity.model.BattleEntityMobility;
import engine.battle.fsm.BattleMove;
import engine.path.IPathGraphNode;
import engine.tile.Tile;
import engine.tile.Tiles;
import flash.utils.Dictionary;

class NodeBlockedChecker_BattleMove
{
    
   
   public var stepsBlock:Boolean;
   
   public var move:BattleMove;
   
   public var moveBlocked:Dictionary;
   
   public function NodeBlockedChecker_BattleMove(param1:BattleMove)
   {
      var _loc5_:IBattleEntity = null;
      var _loc6_:BattleEntityMobility = null;
      var _loc7_:IBattleMove = null;
      var _loc8_:int = 0;
      var _loc9_:int = 0;
      var _loc10_:int = 0;
      var _loc11_:int = 0;
      var _loc12_:Tile = null;
      var _loc13_:int = 0;
      var _loc14_:int = 0;
      var _loc15_:Tile = null;
      this.moveBlocked = new Dictionary();
      super();
      this.move = param1;
      var _loc2_:IBattleEntity = param1.entity;
      var _loc3_:BattleBoard = _loc2_.board as BattleBoard;
      var _loc4_:Tiles = _loc3_.tiles;
      for each(_loc5_ in _loc3_.movers)
      {
         if(_loc5_ != _loc2_)
         {
            _loc6_ = _loc5_.mobility as BattleEntityMobility;
            _loc7_ = _loc6_.move;
            if(_loc6_.moving && Boolean(_loc7_))
            {
               _loc8_ = _loc7_.numSteps;
               _loc9_ = int(_loc5_.boardWidth);
               _loc10_ = int(_loc5_.boardLength);
               _loc11_ = 0;
               while(_loc11_ < _loc8_)
               {
                  _loc12_ = _loc7_.getStep(_loc11_);
                  _loc13_ = 0;
                  while(_loc13_ < _loc9_)
                  {
                     _loc14_ = 0;
                     while(_loc14_ < _loc10_)
                     {
                        _loc15_ = _loc4_.getTile(_loc12_.x + _loc13_,_loc12_.y + _loc14_);
                        if(_loc15_)
                        {
                           this.moveBlocked[_loc15_] = _loc15_;
                        }
                        _loc14_++;
                     }
                     _loc13_++;
                  }
                  _loc11_++;
               }
            }
         }
      }
   }
   
   public function nodeBlockedFunc(param1:IPathGraphNode, param2:Boolean) : Boolean
   {
      var _loc6_:int = 0;
      var _loc3_:Tile = param1.key as Tile;
      var _loc4_:Tiles = this.move.entity.board.tiles;
      var _loc5_:IBattleEntity = this.move.entity as IBattleEntity;
      if(this.moveBlocked[_loc3_])
      {
         return true;
      }
      if(_loc4_.isTileBlockedForEntity(_loc5_,_loc3_,param2,true))
      {
         return true;
      }
      if(Boolean(this.stepsBlock) && Boolean(this.move._wayPointTile))
      {
         _loc6_ = 0;
         while(_loc6_ < this.move.numSteps && _loc6_ < this.move._wayPointSteps)
         {
            if(_loc3_ == this.move.getStep(_loc6_))
            {
               return true;
            }
            _loc6_++;
         }
      }
      return false;
   }
}
