package engine.battle.board.model
{
   import engine.battle.board.BattleBoardEvent;
   import engine.core.logging.ILogger;
   import engine.tile.Tile;
   import engine.tile.Tiles;
   import engine.tile.def.TileRect;
   import engine.tile.def.TileRectRange;
   import flash.errors.IllegalOperationError;
   import flash.events.EventDispatcher;
   
   public class BattleBoardTriggers extends EventDispatcher implements IBattleBoardTriggers
   {
       
      
      private var _board:IBattleBoard;
      
      private var logger:ILogger;
      
      private var _triggers:Vector.<IBattleBoardTrigger>;
      
      private var _locked:Boolean;
      
      private var addingDeferred:Boolean;
      
      private var deferredAdds:Vector.<IBattleBoardTrigger>;
      
      private var deferredRemoves:int;
      
      public var _selectedTriggers:Vector.<IBattleBoardTrigger>;
      
      private var _beginTriggers:Vector.<IBattleBoardTrigger>;
      
      public var _triggeringEntity:IBattleEntity;
      
      public var _triggering:IBattleBoardTrigger;
      
      private var _turnEntity:IBattleEntity;
      
      public function BattleBoardTriggers(param1:IBattleBoard)
      {
         this._triggers = new Vector.<IBattleBoardTrigger>();
         this.deferredAdds = new Vector.<IBattleBoardTrigger>();
         this._selectedTriggers = new Vector.<IBattleBoardTrigger>();
         this._beginTriggers = new Vector.<IBattleBoardTrigger>();
         super();
         this._board = param1;
         this.logger = this._board.logger;
      }
      
      public function validate() : void
      {
         var _loc1_:IBattleBoardTrigger = null;
         for each(_loc1_ in this._triggers)
         {
            _loc1_.validate();
         }
      }
      
      public function get numTriggers() : int
      {
         return !!this._triggers ? int(this._triggers.length) : 0;
      }
      
      override public function toString() : String
      {
         return this._triggers.join(",");
      }
      
      public function cleanup() : void
      {
         var _loc1_:IBattleBoardTrigger = null;
         for each(_loc1_ in this._triggers)
         {
            _loc1_.clearVars();
         }
         this._triggers = null;
         this._board = null;
         this.logger = null;
      }
      
      public function getTriggerByUniqueIdOrId(param1:String) : IBattleBoardTrigger
      {
         var _loc2_:IBattleBoardTrigger = this.getTriggerByUniqueId(param1);
         if(!_loc2_)
         {
            _loc2_ = this.getTriggerById(param1);
         }
         return _loc2_;
      }
      
      public function getTriggerByUniqueId(param1:String) : IBattleBoardTrigger
      {
         var _loc2_:IBattleBoardTrigger = null;
         for each(_loc2_ in this._triggers)
         {
            if(_loc2_.id == param1)
            {
               return _loc2_;
            }
         }
         return null;
      }
      
      public function getTriggerById(param1:String) : IBattleBoardTrigger
      {
         var _loc2_:IBattleBoardTrigger = null;
         for each(_loc2_ in this._triggers)
         {
            if(_loc2_.triggerId == param1)
            {
               return _loc2_;
            }
         }
         return null;
      }
      
      public function findEntityHazardAtRect(param1:IBattleEntity, param2:TileRect, param3:Boolean) : IBattleBoardTrigger
      {
         var _loc4_:IBattleBoardTrigger = null;
         if(!this._triggers)
         {
            return null;
         }
         param2 = !!param2 ? param2 : param1.rect;
         for each(_loc4_ in this._triggers)
         {
            if(!(!_loc4_ || param3 && !_loc4_.enabled))
            {
               if(_loc4_.intersectsRect(param2) && _loc4_.isHazardToEntity(param1))
               {
                  return _loc4_;
               }
            }
         }
         return null;
      }
      
      public function findClosestEntityHazard(param1:IBattleEntity, param2:TileRect, param3:Boolean, param4:Boolean) : IBattleBoardTrigger
      {
         var _loc5_:IBattleBoardTrigger = null;
         var _loc7_:IBattleBoardTrigger = null;
         var _loc8_:int = 0;
         if(!this._triggers)
         {
            return null;
         }
         var _loc6_:int = 1000000;
         param2 = !!param2 ? param2 : param1.rect;
         for each(_loc7_ in this._triggers)
         {
            if(!(!_loc7_ || param4 && !_loc7_.enabled))
            {
               if(param3)
               {
                  if(this.board.findAllRectIntersectionEntities(_loc7_.rect,null,null))
                  {
                     continue;
                  }
               }
               if(_loc7_.isHazardToEntity(param1))
               {
                  _loc8_ = TileRectRange.computeRange(_loc7_.rect,param2);
                  if(_loc8_ < _loc6_)
                  {
                     _loc6_ = _loc8_;
                     _loc5_ = _loc7_;
                  }
               }
            }
         }
         return _loc5_;
      }
      
      public function get locked() : Boolean
      {
         return this._locked;
      }
      
      public function set locked(param1:Boolean) : void
      {
         var _loc2_:Boolean = false;
         var _loc3_:BattleBoardTrigger = null;
         if(this._locked != param1)
         {
            this._locked = param1;
            if(this._locked)
            {
               if(this.addingDeferred)
               {
                  throw new IllegalOperationError("locked while addingDeferred");
               }
               if(this.deferredAdds.length > 0)
               {
                  throw new IllegalOperationError("locked while deferredAdds.length=" + this.deferredAdds.length);
               }
            }
            else
            {
               this.addingDeferred = true;
               for each(_loc3_ in this.deferredAdds)
               {
                  this.triggers.push(_loc3_);
                  _loc3_.updateTurnEntity(this._turnEntity);
                  _loc2_ = true;
               }
               this.deferredAdds.splice(0,this.deferredAdds.length);
               this.addingDeferred = false;
               _loc2_ = this.purgeRemoved() || _loc2_;
               if(_loc2_)
               {
                  this.board.dispatchEvent(new BattleBoardEvent(BattleBoardEvent.TRIGGERS));
               }
            }
         }
      }
      
      private function purgeRemoved() : Boolean
      {
         var _loc1_:int = 0;
         if(this.deferredRemoves > 0)
         {
            _loc1_ = 0;
            while(_loc1_ < this.triggers.length && this.deferredRemoves > 0)
            {
               if(!this.triggers[_loc1_])
               {
                  this.triggers.splice(_loc1_,1);
                  --this.deferredRemoves;
               }
               else
               {
                  _loc1_++;
               }
            }
            this.board.dispatchEvent(new BattleBoardEvent(BattleBoardEvent.TRIGGERS));
            return true;
         }
         return false;
      }
      
      public function addTrigger(param1:IBattleBoardTrigger) : void
      {
         if(!param1)
         {
            return;
         }
         if(this.locked)
         {
            this.deferredAdds.push(param1);
            return;
         }
         this.triggers.push(param1);
         param1.updateTurnEntity(this._turnEntity);
         if(param1.def.incorporeal && param1.def.ignoreIncorporealOnFadeIn)
         {
            param1.fadeAlpha = 1;
         }
         this._board.dispatchEvent(new BattleBoardEvent(BattleBoardEvent.TRIGGERS));
         dispatchEvent(new BattleBoardTriggersEvent(BattleBoardTriggersEvent.ADDED,param1));
      }
      
      public function removeTrigger(param1:IBattleBoardTrigger) : void
      {
         if(!param1)
         {
            return;
         }
         var _loc2_:int = this.triggers.indexOf(param1);
         if(_loc2_ < 0)
         {
            return;
         }
         this.removeTriggerSelection(param1);
         if(this.locked)
         {
            ++this.deferredRemoves;
            this.triggers[_loc2_] = null;
            dispatchEvent(new BattleBoardTriggersEvent(BattleBoardTriggersEvent.REMOVED,param1));
            return;
         }
         param1.clearVars();
         this.triggers.splice(_loc2_,1);
         this.board.dispatchEvent(new BattleBoardEvent(BattleBoardEvent.TRIGGERS));
         dispatchEvent(new BattleBoardTriggersEvent(BattleBoardTriggersEvent.REMOVED,param1));
      }
      
      public function checkTriggers(param1:IBattleEntity, param2:TileRect, param3:Boolean) : void
      {
         var _loc4_:IBattleBoardTrigger = null;
         if(!this._board || !this._triggers)
         {
            return;
         }
         if(param1.isSubmerged || param1.isTeleporting)
         {
            return;
         }
         this.locked = true;
         this.setTriggeringEntity(param1);
         for each(_loc4_ in this._triggers)
         {
            if(!(!_loc4_ || param3 && !_loc4_.enabled))
            {
               this.setTriggering(_loc4_);
               _loc4_.check(param1,param2);
               this.setTriggering(null);
            }
         }
         this.setTriggeringEntity(null);
         this.locked = false;
         this._board.dispatchEvent(new BattleBoardEvent(BattleBoardEvent.BOARD_ENTITY_TILE_TRIGGER,param1));
      }
      
      public function hasTriggerOnTile(param1:Tile, param2:Boolean) : Boolean
      {
         var _loc3_:BattleBoardTrigger = null;
         for each(_loc3_ in this.triggers)
         {
            if(_loc3_.rect.contains(param1.x,param1.y))
            {
               return true;
            }
         }
         return false;
      }
      
      public function removeTriggerSelection(param1:IBattleBoardTrigger) : void
      {
         var _loc2_:int = this._selectedTriggers.indexOf(param1);
         if(_loc2_ >= 0)
         {
            this._selectedTriggers.splice(_loc2_,1);
            this.board.dispatchEvent(new BattleBoardEvent(BattleBoardEvent.SELECTED_TRIGGERS));
         }
      }
      
      public function selectTriggersOnTile(param1:Tile) : void
      {
         var _loc2_:BattleBoardTrigger = null;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:Boolean = false;
         if(!param1)
         {
            if(this._selectedTriggers.length)
            {
               this._selectedTriggers.splice(0,this._selectedTriggers.length);
               this.board.dispatchEvent(new BattleBoardEvent(BattleBoardEvent.SELECTED_TRIGGERS));
            }
            return;
         }
         this._beginTriggers.splice(0,this._beginTriggers.length);
         for each(_loc2_ in this._selectedTriggers)
         {
            this._beginTriggers.push(_loc2_);
         }
         this._selectedTriggers.splice(0,this._beginTriggers.length);
         _loc3_ = param1.x;
         _loc4_ = param1.y;
         for each(_loc2_ in this.triggers)
         {
            if(_loc2_.rect.contains(_loc3_,_loc4_))
            {
               if(this._selectedTriggers.indexOf(_loc2_) < 0)
               {
                  if(this._beginTriggers.indexOf(_loc2_) < 0)
                  {
                     _loc5_ = true;
                  }
                  this._selectedTriggers.push(_loc2_);
               }
            }
         }
         for each(_loc2_ in this._beginTriggers)
         {
            if(this._selectedTriggers.indexOf(_loc2_) < 0)
            {
               _loc5_ = true;
               break;
            }
         }
         if(_loc5_)
         {
            this.board.dispatchEvent(new BattleBoardEvent(BattleBoardEvent.SELECTED_TRIGGERS));
         }
      }
      
      public function checkTrigger(param1:IBattleBoardTrigger) : void
      {
         var _loc8_:int = 0;
         var _loc9_:Tile = null;
         var _loc10_:Tile = null;
         var _loc11_:IBattleEntity = null;
         var _loc12_:int = 0;
         var _loc13_:IBattleEntity = null;
         if(!param1 || !param1.enabled)
         {
            return;
         }
         this.locked = true;
         var _loc2_:TileRect = param1.rect;
         var _loc3_:Tiles = this.board.tiles;
         var _loc4_:Vector.<Tile> = new Vector.<Tile>();
         var _loc5_:int = _loc2_.left;
         while(_loc5_ < _loc2_.right)
         {
            _loc8_ = _loc2_.front;
            while(_loc8_ < _loc2_.back)
            {
               _loc9_ = _loc3_.getTile(_loc5_,_loc8_);
               if(Boolean(_loc9_) && _loc9_._numResidents > 0)
               {
                  _loc4_.push(_loc9_);
               }
               _loc8_++;
            }
            _loc5_++;
         }
         var _loc6_:Vector.<IBattleEntity> = new Vector.<IBattleEntity>();
         var _loc7_:int = 0;
         while(_loc7_ < _loc4_.length)
         {
            _loc10_ = _loc4_[_loc7_];
            if(_loc10_.numResidents != 0)
            {
               _loc6_.length = 0;
               for each(_loc11_ in _loc10_.residents)
               {
                  _loc6_.push(_loc11_);
               }
               _loc12_ = 0;
               while(_loc12_ < _loc6_.length)
               {
                  _loc13_ = _loc6_[_loc12_];
                  if(!(!_loc13_ || _loc13_.isSubmerged))
                  {
                     this.setTriggeringEntity(_loc13_);
                     this.setTriggering(param1);
                     param1.check(_loc13_,_loc13_.rect);
                     this.setTriggering(null);
                     this.setTriggeringEntity(null);
                  }
                  _loc12_++;
               }
            }
            _loc7_++;
         }
         this.locked = false;
      }
      
      public function checkPulsingTriggers(param1:IBattleEntity, param2:TileRect) : void
      {
         var _loc3_:IBattleBoardTrigger = null;
         if(param1.isSubmerged)
         {
            return;
         }
         this.locked = true;
         this.setTriggeringEntity(param1);
         for each(_loc3_ in this.triggers)
         {
            if(!(!_loc3_ || !_loc3_.enabled))
            {
               this.setTriggering(_loc3_);
               _loc3_.pulseCheck(param1,param2);
               this.setTriggering(null);
            }
         }
         this.setTriggeringEntity(null);
         this.locked = false;
      }
      
      public function clearEntitiesHitThisTurn() : void
      {
         var _loc1_:IBattleBoardTrigger = null;
         for each(_loc1_ in this.triggers)
         {
            if(_loc1_ != null)
            {
               _loc1_.clearEntitiesHitThisTurn();
            }
         }
      }
      
      public function get board() : IBattleBoard
      {
         return this._board;
      }
      
      public function get triggers() : Vector.<IBattleBoardTrigger>
      {
         return this._triggers;
      }
      
      public function get triggeringEntityId() : String
      {
         return !!this._triggeringEntity ? String(this._triggeringEntity.id) : null;
      }
      
      public function get triggeringEntity() : IBattleEntity
      {
         return this._triggeringEntity;
      }
      
      private function setTriggeringEntity(param1:IBattleEntity) : void
      {
         if(param1 == this._triggeringEntity)
         {
            return;
         }
         this._triggeringEntity = param1;
      }
      
      public function get triggering() : IBattleBoardTrigger
      {
         return this._triggering;
      }
      
      private function setTriggering(param1:IBattleBoardTrigger) : void
      {
         if(param1 == this._triggering)
         {
            return;
         }
         this._triggering = param1;
      }
      
      public function onStartedTurn() : void
      {
         this.expireTriggers();
         this.checkTriggerVars();
      }
      
      public function checkTriggerVars() : void
      {
         var _loc1_:IBattleBoardTrigger = null;
         for each(_loc1_ in this._triggers)
         {
            if(_loc1_)
            {
               _loc1_.checkResetCounts();
            }
         }
      }
      
      private function expireTriggers(param1:int = 1) : void
      {
         var _loc3_:IBattleBoardTrigger = null;
         var _loc2_:Vector.<IBattleBoardTrigger> = this._triggers.concat();
         for each(_loc3_ in _loc2_)
         {
            if(_loc3_)
            {
               _loc3_.turnCountIncrease(param1);
               if(_loc3_.expired)
               {
                  this.removeTrigger(_loc3_);
               }
            }
         }
      }
      
      public function handleTriggerEnabled(param1:IBattleBoardTrigger) : void
      {
         dispatchEvent(new BattleBoardTriggersEvent(BattleBoardTriggersEvent.ENABLED,param1));
      }
      
      public function updateTurnEntity(param1:IBattleEntity) : void
      {
         var _loc2_:IBattleBoardTrigger = null;
         if(this._turnEntity == param1)
         {
            if(!this._turnEntity || this._turnEntity.incorporeal == param1.incorporeal)
            {
               return;
            }
         }
         this._turnEntity = param1;
         for each(_loc2_ in this._triggers)
         {
            _loc2_.updateTurnEntity(param1);
         }
      }
   }
}
