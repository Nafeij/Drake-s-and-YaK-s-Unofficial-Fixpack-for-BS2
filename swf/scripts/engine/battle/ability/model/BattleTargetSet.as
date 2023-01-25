package engine.battle.ability.model
{
   import engine.battle.ability.def.BattleAbilityTargetRule;
   import engine.battle.board.model.IBattleEntity;
   import engine.tile.Tile;
   import flash.errors.IllegalOperationError;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   
   public class BattleTargetSet extends EventDispatcher
   {
       
      
      public var ability:IBattleAbility;
      
      public var targets:Vector.<IBattleEntity>;
      
      public var tiles:Vector.<Tile>;
      
      private var _supressEvents:Boolean;
      
      private var supressedEvents:Boolean;
      
      public function BattleTargetSet(param1:IBattleAbility)
      {
         this.targets = new Vector.<IBattleEntity>();
         this.tiles = new Vector.<Tile>();
         super();
         this.ability = param1;
      }
      
      public function clone(param1:IBattleAbility) : BattleTargetSet
      {
         var _loc2_:BattleTargetSet = new BattleTargetSet(param1);
         _loc2_.targets = this.targets.slice();
         _loc2_.tiles = this.tiles.slice();
         this.ability = param1;
         return _loc2_;
      }
      
      public function get baseTarget() : IBattleEntity
      {
         return this.targets.length > 0 ? this.targets[0] : null;
      }
      
      public function get lastTarget() : IBattleEntity
      {
         return this.targets.length > 0 ? this.targets[this.targets.length - 1] : null;
      }
      
      public function get baseTile() : Tile
      {
         return this.tiles.length > 0 ? this.tiles[0] : null;
      }
      
      public function get lastTile() : Tile
      {
         return this.tiles.length > 0 ? this.tiles[this.tiles.length - 1] : null;
      }
      
      public function get debugIds() : String
      {
         var _loc2_:IBattleEntity = null;
         var _loc1_:* = "";
         for each(_loc2_ in this.targets)
         {
            if(_loc1_.length > 0)
            {
               _loc1_ += ", ";
            }
            _loc1_ += _loc2_.id;
         }
         return "{" + _loc1_ + "}";
      }
      
      public function setTarget(param1:IBattleEntity) : void
      {
         if(this.ability.executed)
         {
            throw new IllegalOperationError("fail exe");
         }
         if(this.targets.length > 0)
         {
            this.targets.splice(0,this.targets.length);
         }
         if(param1)
         {
            this.targets.push(param1);
         }
         this.eventNotify();
      }
      
      public function setTile(param1:Tile) : void
      {
         if(this.ability.executed)
         {
            throw new IllegalOperationError("fail exe");
         }
         if(this.tiles.length > 0)
         {
            this.tiles.splice(0,this.tiles.length);
         }
         if(param1)
         {
            this.tiles.push(param1);
         }
         this.eventNotify();
      }
      
      private function eventNotify() : void
      {
         if(!this._supressEvents)
         {
            dispatchEvent(new Event(Event.CHANGE));
         }
         else
         {
            this.supressedEvents = true;
         }
      }
      
      public function toggleTarget(param1:IBattleEntity) : void
      {
         if(this.hasTarget(param1))
         {
            this.removeTarget(param1);
         }
         else if(this.ability.def.targetCount == this.targets.length)
         {
            this.removeTarget(this.targets[0]);
            this.addTarget(param1);
         }
         else
         {
            this.addTarget(param1);
         }
      }
      
      public function addTarget(param1:IBattleEntity) : void
      {
         var _loc2_:BattleAbilityTargetRule = null;
         if(!param1)
         {
            throw new ArgumentError("null target?");
         }
         if(this.ability.executed)
         {
            throw new IllegalOperationError("fail exe");
         }
         if(this.targets.length > 0)
         {
            _loc2_ = this.ability.def.targetRule;
            if(_loc2_.isTile && _loc2_ != BattleAbilityTargetRule.FORWARD_ARC)
            {
               throw new IllegalOperationError("tile rule can\'t have multiple targets for " + this.ability);
            }
         }
         if(this.hasTarget(param1))
         {
            throw new IllegalOperationError("target already in list for " + this.ability);
         }
         this.targets.push(param1);
         this.eventNotify();
      }
      
      public function addTile(param1:Tile) : void
      {
         if(this.ability.executed)
         {
            throw new IllegalOperationError("fail exe");
         }
         if(this.tiles.length > 0)
         {
            if(!this.ability.def.targetRule.isTile)
            {
               throw new IllegalOperationError("only tile rule can have multiple tiles");
            }
         }
         if(this.hasTile(param1))
         {
            throw new IllegalOperationError("tile [" + param1 + "] already in list for ability [" + this.ability + "]");
         }
         this.tiles.push(param1);
         this.eventNotify();
      }
      
      public function removeTarget(param1:IBattleEntity, param2:Boolean = true) : Boolean
      {
         if(this.ability.executed)
         {
            throw new IllegalOperationError("fail exe");
         }
         var _loc3_:int = this.targets.indexOf(param1);
         if(_loc3_ < 0)
         {
            if(param2)
            {
               throw new IllegalOperationError("targets not in list");
            }
            return false;
         }
         this.targets.splice(_loc3_,1);
         this.eventNotify();
         return true;
      }
      
      public function removeTile(param1:Tile) : void
      {
         if(this.ability.executed)
         {
            throw new IllegalOperationError("fail exe");
         }
         var _loc2_:int = this.tiles.indexOf(param1);
         if(_loc2_ < 0)
         {
            throw new IllegalOperationError("tile not in list");
         }
         this.tiles.splice(_loc2_,1);
         this.eventNotify();
      }
      
      public function hasTarget(param1:IBattleEntity) : Boolean
      {
         var _loc2_:int = this.targets.indexOf(param1);
         return _loc2_ >= 0;
      }
      
      public function hasAssociatedTarget(param1:IBattleEntity) : Boolean
      {
         var _loc2_:int = this.targets.indexOf(param1);
         return _loc2_ >= 0;
      }
      
      public function hasTile(param1:Tile) : Boolean
      {
         var _loc2_:int = !!param1 ? int(this.tiles.indexOf(param1)) : -1;
         return _loc2_ >= 0;
      }
      
      public function get supressEvents() : Boolean
      {
         return this._supressEvents;
      }
      
      public function set supressEvents(param1:Boolean) : void
      {
         if(this._supressEvents == param1)
         {
            return;
         }
         this._supressEvents = param1;
         if(!this._supressEvents)
         {
            if(this.supressedEvents)
            {
               this.supressedEvents = false;
               this.eventNotify();
            }
         }
      }
   }
}
