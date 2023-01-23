package engine.battle.entity.model
{
   import engine.anim.def.IAnimLibrary;
   import engine.anim.view.AnimController;
   import engine.battle.ability.effect.model.EffectTag;
   import engine.battle.behavior.WalkTilesAnimBehavior;
   import engine.battle.behavior.WalkTilesBehavior;
   import engine.battle.behavior.WalkTilesSlideBehavior;
   import engine.battle.board.model.BattleEntityMobilityEvent;
   import engine.battle.board.model.IBattleBoard;
   import engine.battle.board.model.IBattleEntity;
   import engine.battle.board.model.IBattleEntityMobility;
   import engine.battle.board.model.IBattleMove;
   import engine.battle.fsm.IBattleFsm;
   import engine.battle.fsm.IBattleTurn;
   import engine.core.logging.ILogger;
   import engine.tile.Tile;
   import flash.events.EventDispatcher;
   
   public class BattleEntityMobility extends EventDispatcher implements IBattleEntityMobility
   {
      
      public static var FAST_FORWARD:Boolean;
       
      
      private var _entity:IBattleEntity;
      
      public var walkTilesBehavior:WalkTilesBehavior;
      
      private var _moving:Boolean;
      
      private var _moveStopping:Boolean;
      
      private var _move:IBattleMove;
      
      private var logger:ILogger;
      
      private var _moved:Boolean = false;
      
      private var _numStepsMoved:int = 0;
      
      public function BattleEntityMobility(param1:IBattleEntity)
      {
         super();
         this._entity = param1;
         this.logger = param1.logger;
      }
      
      public function cleanup() : void
      {
         if(this.walkTilesBehavior)
         {
            this.walkTilesBehavior.interrupt("cleanup");
         }
         this._entity = null;
      }
      
      public function get entity() : IBattleEntity
      {
         return this._entity;
      }
      
      public function stopMoving(param1:String) : void
      {
         if(this.walkTilesBehavior)
         {
            this.walkTilesBehavior.interrupt("stopMoving: " + param1);
            this.walkTilesBehavior = null;
         }
      }
      
      public function get moving() : Boolean
      {
         return this._moving;
      }
      
      public function set moving(param1:Boolean) : void
      {
         if(this._moving == param1)
         {
            return;
         }
         this._moving = param1;
         this._moveStopping = false;
         dispatchEvent(new BattleEntityMobilityEvent(BattleEntityMobilityEvent.MOVING));
      }
      
      public function get moved() : Boolean
      {
         return this._moved;
      }
      
      public function set moved(param1:Boolean) : void
      {
         this._moved = param1;
      }
      
      public function handleTrimmedImpossibles() : void
      {
         var _loc2_:IBattleEntity = null;
         var _loc3_:IBattleEntity = null;
         var _loc1_:Vector.<IBattleEntity> = this._move.trimmedImpossibleResidents;
         if(Boolean(_loc1_) && Boolean(_loc1_.length))
         {
            for each(_loc2_ in _loc1_)
            {
               this._entity.notifyCollision(_loc2_);
            }
            _loc3_ = _loc1_[_loc1_.length - 1];
            this.entity.faceTile(this.entity.tile,_loc3_.tile);
         }
      }
      
      public function executeMove(param1:IBattleMove) : void
      {
         if(param1.numSteps == 0)
         {
            throw new ArgumentError("BattleEntityMobility " + this.entity.id + " expects non-zero steps for completeness");
         }
         if(param1.executed)
         {
            throw new ArgumentError("BattleEntityMobility " + this.entity.id + " move already executed");
         }
         if(!param1.committed)
         {
            throw new ArgumentError("BattleEntityMobility " + this.entity.id + " move not committed");
         }
         if(param1.executing)
         {
            throw new ArgumentError("BattleEntityMobility " + this.entity.id + " already executing");
         }
         this.stopMoving("BattleEntityMobility.executeMove");
         if(!this.entity.alive)
         {
            throw new ArgumentError("BattleEntityMobility " + this.entity.id + " is not alive");
         }
         this._move = param1;
         param1.setExecuting();
         if(param1.numSteps == 1)
         {
            this.handleTrimmedImpossibles();
            param1.setExecuted();
            this._move = null;
            return;
         }
         var _loc2_:BattleEntity = this.entity as BattleEntity;
         var _loc3_:AnimController = _loc2_.animController;
         var _loc4_:IAnimLibrary = _loc3_.library;
         var _loc5_:Boolean = Boolean(_loc4_) && _loc4_.hasOrientedAnims(_loc3_.layer,"walk");
         if(_loc5_ == true)
         {
            this.walkTilesBehavior = new WalkTilesAnimBehavior(this.entity);
         }
         else
         {
            this.walkTilesBehavior = new WalkTilesSlideBehavior(this.entity);
         }
         if(this._entity.hasSubmergedMove || this._entity.isTeleporting)
         {
            this._entity.cameraFollowEntity(true);
         }
         this.walkTilesBehavior.changeFacing = param1.changeFacing;
         this.walkTilesBehavior.start(param1,this.walkTilesCompleteHandler);
         if(FAST_FORWARD)
         {
            this.fastForwardMove();
         }
      }
      
      public function fastForwardMove() : void
      {
         if(this.logger.isDebugEnabled)
         {
            this.logger.debug("BattleEntityMobility.fastForwardMove " + this.walkTilesBehavior);
         }
         if(this.walkTilesBehavior)
         {
            this.walkTilesBehavior.fastForward();
         }
      }
      
      private function walkTilesCompleteHandler(param1:WalkTilesBehavior) : void
      {
         var _loc4_:IBattleBoard = null;
         var _loc5_:IBattleFsm = null;
         var _loc6_:IBattleTurn = null;
         var _loc7_:IBattleEntity = null;
         if(this.logger.isDebugEnabled)
         {
            this.logger.debug("BattleEntityMobility.walkTilesCompleteHandler behavior=" + param1 + ", walkTilesBehavior=" + this.walkTilesBehavior);
         }
         if(!this._entity || this._entity.cleanedup || !this._entity.board || this._entity.board.cleanedup)
         {
            return;
         }
         if(this.walkTilesBehavior != param1)
         {
            return;
         }
         var _loc2_:BattleEntity = this.entity as BattleEntity;
         this._numStepsMoved = this._move.numSteps;
         if(_loc2_.board != null)
         {
            _loc2_.board.dispatchEvent(new BattleEntityEvent(BattleEntityEvent.MOVE_FINISHING,_loc2_));
         }
         this.walkTilesBehavior = null;
         this.moving = false;
         var _loc3_:IBattleMove = this._move;
         this._move = null;
         this._moved = true;
         if(_loc3_)
         {
            this._moved = _loc3_.numSteps > 1;
            if(this._moved == true)
            {
               if(this._entity.effects)
               {
                  if(this._entity.effects.hasTag(EffectTag.MOVED_THIS_TURN) == false)
                  {
                     this._entity.effects.addTag(EffectTag.MOVED_THIS_TURN);
                  }
               }
            }
            if(Boolean(param1) && param1.interrupted)
            {
               _loc3_.setInterrupted();
            }
            if(_loc3_.cleanedup)
            {
               return;
            }
            _loc4_ = this._entity.board;
            _loc5_ = !!_loc4_ ? _loc4_.fsm : null;
            _loc6_ = !!_loc5_ ? _loc5_.turn : null;
            _loc7_ = !!_loc6_ ? _loc6_.entity : null;
            if(this._entity == _loc7_)
            {
               if(_loc6_.move != _loc3_)
               {
                  if(!_loc6_.move.committed)
                  {
                     _loc6_.move.reset(this.entity.tile);
                  }
               }
            }
            _loc3_.setExecuted();
         }
         if(this._entity.hasSubmergedMove)
         {
            this._entity.cameraFollowEntity(false);
         }
      }
      
      public function update(param1:int) : void
      {
         if(this.walkTilesBehavior)
         {
            this.walkTilesBehavior.update(param1);
         }
      }
      
      public function get numStepsMoved() : int
      {
         return this._numStepsMoved;
      }
      
      public function get move() : IBattleMove
      {
         return this._move;
      }
      
      public function get forcedMove() : Boolean
      {
         return Boolean(this._move) && this._move.forcedMove;
      }
      
      public function get interrupted() : Boolean
      {
         return Boolean(this._move) && this._move.interrupted;
      }
      
      public function get previousTileInMove() : Tile
      {
         if(Boolean(this.walkTilesBehavior) && Boolean(this.walkTilesBehavior.move))
         {
            return this.walkTilesBehavior.previousStep;
         }
         return null;
      }
   }
}
