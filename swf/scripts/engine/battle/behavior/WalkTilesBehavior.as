package engine.battle.behavior
{
   import engine.battle.ability.effect.model.BattleFacing;
   import engine.battle.board.model.IBattleBoardTriggers;
   import engine.battle.board.model.IBattleEntity;
   import engine.battle.board.model.IBattleMove;
   import engine.battle.entity.model.BattleEntity;
   import engine.core.logging.ILogger;
   import engine.stat.def.StatType;
   import engine.stat.model.Stat;
   import engine.tile.ITileResident;
   import engine.tile.Tile;
   import engine.tile.Tiles;
   import engine.tile.def.TileRect;
   import flash.errors.IllegalOperationError;
   import flash.geom.Point;
   
   public class WalkTilesBehavior extends Behavior
   {
      
      private static var _scratchEntities:Vector.<ITileResident> = new Vector.<ITileResident>();
       
      
      public var changeFacing:Boolean = true;
      
      protected var _move:IBattleMove;
      
      private var step:int;
      
      protected var _lastT:Number = -1;
      
      public var _t:Number = 0;
      
      private var consumedWillpower:int = 0;
      
      private var _callback:Function;
      
      private var _stopped:Boolean;
      
      private var _interrupted:Boolean;
      
      private var _fastForwarded:Boolean;
      
      private var _completedNormally:Boolean;
      
      public var remainingDistance:Number = 0;
      
      private var prevCheckStep:int = -1;
      
      public function WalkTilesBehavior(param1:IBattleEntity)
      {
         super(param1);
      }
      
      override public function toString() : String
      {
         return "" + this._move;
      }
      
      public function start(param1:IBattleMove, param2:Function) : void
      {
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         if(this.stopped)
         {
            throw new IllegalOperationError("Not sure what you think you\'re doing...");
         }
         this.remainingDistance = param1.numSteps - 1;
         this._move = param1;
         this._callback = param2;
         if(param1.forcedMove == false)
         {
            _loc3_ = int(entity.stats.exertionMoveBonusCur);
            _loc4_ = this._move.getMovementStat() + _loc3_;
            if(param1.numSteps - 1 > _loc4_)
            {
               logger.error("Attempt to move " + (param1.numSteps - 1) + " STEPS, but max move (w/ stars) is " + _loc4_ + " for " + entity);
            }
         }
      }
      
      public function fastForward() : void
      {
         if(this._stopped)
         {
            return;
         }
         logger.debug("WalkTilesBehavior.fastForward " + entity);
         this._fastForwarded = true;
         this.t = this._move.numSteps - 1;
         this.stop("fastForward");
      }
      
      protected function stop(param1:String) : void
      {
         if(this._stopped)
         {
            return;
         }
         if(logger.isDebugEnabled)
         {
            logger.debug("WalkTilesBehavior.stop t=" + this._t + ", step=" + this.step + " remain=" + this.remainingDistance + " steps=" + this.move.numSteps + " reason [" + param1 + "]");
         }
         if(!this._fastForwarded && !this._interrupted && !this._completedNormally)
         {
            throw new IllegalOperationError("Cannot stop() " + entity + " without having been fastForwarded, interrupted, or completedNormally first");
         }
         this._stopped = true;
         this.remainingDistance = 0;
         this._pointStep();
         if(this._callback != null)
         {
            this._callback(this);
         }
      }
      
      public function get t() : Number
      {
         return this._t;
      }
      
      public function set t(param1:Number) : void
      {
         var _loc6_:int = 0;
         var _loc7_:Tile = null;
         var _loc9_:Tile = null;
         var _loc10_:Tiles = null;
         var _loc11_:Boolean = false;
         var _loc12_:int = 0;
         var _loc13_:int = 0;
         var _loc14_:int = 0;
         var _loc15_:Stat = null;
         var _loc16_:ITileResident = null;
         var _loc17_:BattleEntity = null;
         if(!this._move || this.stopped)
         {
            throw new IllegalOperationError("stopped already");
         }
         this._t = Math.min(this._move.numSteps - 1,param1);
         this.remainingDistance = this._move.numSteps - 1 - this._t;
         this._lastT = this.t;
         var _loc2_:int = this._t;
         var _loc3_:int = this._move.getMovementStat();
         var _loc4_:int = int(entity.stats.getValue(StatType.WILLPOWER_MOVE,1));
         var _loc5_:ILogger = entity.logger;
         var _loc8_:int = this.prevCheckStep + 1;
         while(_loc8_ <= _loc2_)
         {
            this.prevCheckStep = _loc8_;
            _loc9_ = this.move.getStep(_loc8_);
            if(!_loc9_)
            {
               throw new IllegalOperationError("no tile for step " + _loc8_ + " of " + this.move);
            }
            if(this.move.forcedMove == false)
            {
               if(_loc8_ > _loc3_)
               {
                  _loc11_ = false;
                  _loc12_ = _loc8_ - _loc3_;
                  _loc13_ = 1 + (_loc12_ - 1) / _loc4_;
                  _loc14_ = _loc13_ - this.consumedWillpower;
                  if(_loc14_ > 0)
                  {
                     if(entity.stats.getValue(StatType.WILLPOWER) <= 0)
                     {
                        _loc5_.info("Attempt to move with insufficient WILLPOWER: " + entity + ", step=" + _loc8_);
                        _loc11_ = true;
                     }
                     if(!_loc11_)
                     {
                        if(this.consumedWillpower >= entity.stats.getValue(StatType.EXERTION))
                        {
                           _loc5_.info("Attempt to move with insufficient EXERTION: " + entity + ", step=" + _loc8_);
                           _loc11_ = true;
                        }
                     }
                     if(_loc11_)
                     {
                        _loc5_.info("FAIL STOP " + entity + " AT " + _loc8_);
                        _loc6_ = Math.max(0,_loc8_ - 1);
                        _loc7_ = this.move.getStep(_loc6_);
                        entity.setPos(_loc7_.x,_loc7_.y);
                        this.interrupt("willpower failure");
                        return;
                     }
                     this.consumedWillpower = _loc13_;
                     entity.stats.getStat(StatType.WILLPOWER).base = Number(entity.stats.getStat(StatType.WILLPOWER).base) - _loc14_;
                     if(_loc5_.isDebugEnabled)
                     {
                        _loc15_ = entity.stats.getStat(StatType.WILLPOWER);
                        _loc5_.debug("WalkTilesBehavior consume willpower from " + entity + " delta " + _loc14_ + " remain " + _loc15_);
                     }
                  }
               }
            }
            _loc10_ = entity.board.tiles;
            _scratchEntities.splice(0,_scratchEntities.length);
            if(_loc10_.isTileBlockedForEntity(entity,_loc9_,false,false,false,_scratchEntities))
            {
               for each(_loc16_ in _scratchEntities)
               {
                  if(!(entity.isTeleporting && _loc16_ != this.move.last))
                  {
                     _loc17_ = _loc16_ as BattleEntity;
                     if(_loc17_)
                     {
                        _loc5_.info("WalkTilesBehavior " + entity + " collided with " + _loc17_ + " at " + _loc17_.tile);
                        entity.notifyCollision(_loc17_);
                        if(this.stopped)
                        {
                           _loc5_.info("WalkTilesBehavior " + entity + " collision with " + _loc17_ + " STOPPED at checkStep" + _loc8_);
                           this.backupToValidSpot(_loc8_);
                           return;
                        }
                     }
                  }
               }
            }
            this.step = _loc8_;
            this._pointStep(false);
            if(!this._checkMovementResults(_loc9_,_loc8_,_loc3_,_loc4_))
            {
               return;
            }
            _loc8_++;
         }
         this._pointStep(true);
         if(!this._checkMovementResults(entity.tile,_loc2_,_loc3_,_loc4_))
         {
            return;
         }
         if(this.t >= this._move.numSteps - 1)
         {
            this._completedNormally = true;
            entity.mobility.handleTrimmedImpossibles();
            this.stop("completedNormally @t=" + this.t);
         }
      }
      
      private function _checkMovementResults(param1:Tile, param2:int, param3:int, param4:int) : Boolean
      {
         var _loc6_:Array = null;
         var _loc7_:Tile = null;
         var _loc8_:ITileResident = null;
         var _loc9_:IBattleEntity = null;
         var _loc10_:int = 0;
         var _loc11_:int = 0;
         var _loc12_:TileRect = null;
         var _loc13_:IBattleBoardTriggers = null;
         if(!entity.alive)
         {
            if(!this.stopped)
            {
               this.interrupt("walker " + entity + " died");
            }
            return false;
         }
         var _loc5_:Boolean = false;
         if(this.move.reactToEntityIntersect == true)
         {
            _loc6_ = new Array();
            this._collectIntersectChecks(_loc6_,param1.x,param1.y);
            for each(_loc7_ in _loc6_)
            {
               if(_loc7_)
               {
                  if(!(entity.isTeleporting && _loc7_ != this.move.last))
                  {
                     for each(_loc8_ in _loc7_.residents)
                     {
                        if(_loc8_ is IBattleEntity)
                        {
                           _loc9_ = _loc8_ as IBattleEntity;
                           if(_loc9_.alive == true && entity != _loc9_)
                           {
                              _loc5_ = true;
                              this.move.handleIntersectEntity(_loc9_);
                           }
                        }
                     }
                  }
               }
            }
         }
         if(!this.move.forcedMove)
         {
            if(param2 >= param3 && Boolean(this.remainingDistance))
            {
               if(entity.stats.getValue(StatType.WILLPOWER) <= 0)
               {
                  if(param4 > 1)
                  {
                     _loc11_ = param2 - param3;
                     _loc10_ = _loc11_ % param4;
                  }
                  if(_loc10_ <= 0)
                  {
                     logger.info("WalkTilesBehavior.t WILLPOWER EXPENDED INTERRUPTED " + entity + " AT " + param2 + " t=" + this._t + " remaining=" + this.remainingDistance);
                     this.interrupt("willpower expenditure");
                     return false;
                  }
                  logger.info("WalkTilesBehavior.t WILLPOWER EXPENDED MOMENTUM=" + _loc10_ + " " + entity + " AT " + param2);
               }
            }
         }
         if(_loc5_ == false && Boolean(entity.board.triggers))
         {
            if(param2 > 0)
            {
               _loc12_ = entity.rect.clone();
               _loc12_.setLocation(param1.location);
               if(this.stopped)
               {
                  logger.info("WalkTilesBehavior.t movement interrupted " + entity + " AT " + param2);
                  return false;
               }
               _loc13_ = entity.board.triggers;
               _loc13_.checkTriggers(entity,_loc12_,true);
            }
            if(this.stopped)
            {
               logger.info("WalkTilesBehavior.t TRIGGER INTERRUPTED " + entity + " AT " + param2);
               return false;
            }
         }
         return true;
      }
      
      private function _collectIntersectChecks(param1:Array, param2:int, param3:int) : void
      {
         var _loc8_:int = 0;
         var _loc9_:Tile = null;
         var _loc4_:int = int(entity.boardWidth);
         var _loc5_:int = int(entity.boardLength);
         var _loc6_:Tiles = entity.board.tiles;
         var _loc7_:int = 0;
         while(_loc7_ < _loc4_)
         {
            _loc8_ = 0;
            while(_loc8_ < _loc5_)
            {
               _loc9_ = _loc6_.getTile(param2 + _loc7_,param3 + _loc8_);
               param1.push(_loc9_);
               _loc8_++;
            }
            _loc7_++;
         }
      }
      
      private function backupToValidSpot(param1:int) : void
      {
         var _loc2_:Tile = null;
         while(param1 > 0)
         {
            if(!this._move || this._move.cleanedup)
            {
               throw new IllegalOperationError("Move got cleanedup while we were backing up to a valid spot " + this);
            }
            logger.info("WalkTilesBehavior.backupToValidSpot " + entity + " BACKUP from checkStep" + param1);
            param1--;
            _loc2_ = this._move.getStep(param1);
            if(!_loc2_)
            {
               throw new IllegalOperationError("null tile");
            }
            if(!entity.board.tiles.isTileBlockedForEntity(entity,_loc2_,false,false,false))
            {
               logger.info("WalkTilesBehavior.backupToValidSpot " + entity + " CHOSE " + _loc2_);
               entity.setPos(_loc2_.x,_loc2_.y);
               return;
            }
         }
         logger.error("WalkTilesBehavior.backupToValidSpot " + entity + " UNABLE TO UNWIND!");
      }
      
      private function _pointStep(param1:Boolean = false) : void
      {
         var _loc3_:Number = NaN;
         var _loc4_:Tile = null;
         var _loc5_:Point = null;
         var _loc6_:Tile = null;
         if(!entity || !this._move)
         {
            return;
         }
         var _loc2_:Tile = this._move.getStep(this.step);
         if(!_loc2_)
         {
            logger.error("_pointStep no curStep for " + this);
            return;
         }
         if(this.step < this._move.numSteps - 1)
         {
            _loc3_ = this.t - this.step;
            if(_loc3_)
            {
               if(_loc3_ >= 1)
               {
                  _loc3_ = 0;
                  entity.setPos(_loc2_.x,_loc2_.y);
               }
               else
               {
                  _loc4_ = this._move.getStep(this.step + 1);
                  if(this.changeFacing)
                  {
                     _loc5_ = entity.faceTile(_loc2_,_loc4_);
                  }
                  else
                  {
                     _loc5_ = new Point(_loc4_.x - _loc2_.x,_loc4_.y - _loc2_.y);
                  }
                  if(param1)
                  {
                     entity.setPos(_loc2_.x + _loc5_.x * _loc3_,_loc2_.y + _loc5_.y * _loc3_);
                  }
                  else
                  {
                     entity.setPos(_loc2_.x,_loc2_.y);
                  }
               }
            }
         }
         else if(this.step > 0)
         {
            _loc6_ = this.move.getStep(this.step - 1);
            if(Boolean(entity) && Boolean(_loc6_))
            {
               entity.setPos(_loc2_.x,_loc2_.y);
               if(this.changeFacing)
               {
                  entity.facing = BattleFacing.findFacing(_loc2_.x - _loc6_.x,_loc2_.y - _loc6_.y);
               }
            }
         }
      }
      
      public function get interrupted() : Boolean
      {
         return this._interrupted;
      }
      
      public function interrupt(param1:String) : void
      {
         if(!this._interrupted)
         {
            if(this._t != this.step)
            {
               this._t = this.step;
               this._pointStep();
            }
            this._interrupted = true;
            this.stop("interrupted @_t=" + this._t + ": " + param1);
         }
      }
      
      public function get move() : IBattleMove
      {
         return this._move;
      }
      
      public function get stopped() : Boolean
      {
         return this._stopped;
      }
      
      public function get previousStep() : Tile
      {
         var _loc1_:int = this.step - 1;
         if(_loc1_ >= 0 && _loc1_ < this.move.numSteps)
         {
            return this.move.getStep(_loc1_);
         }
         return null;
      }
      
      public function update(param1:int) : void
      {
      }
   }
}
