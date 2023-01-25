package engine.saga.action
{
   import engine.ability.IAbilityDefLevel;
   import engine.battle.ability.def.BattleAbilityDef;
   import engine.battle.ability.def.BattleAbilityTargetRule;
   import engine.battle.ability.model.BattleAbility;
   import engine.battle.ability.model.BattleAbilityEvent;
   import engine.battle.ability.model.BattleAbilityValidation;
   import engine.battle.ability.model.IBattleAbilityManager;
   import engine.battle.board.model.BattleBoard;
   import engine.battle.board.model.IBattleEntity;
   import engine.battle.entity.model.BattleEntity;
   import engine.battle.sim.TileDiamond;
   import engine.entity.def.IEntityDef;
   import engine.math.MathUtil;
   import engine.saga.Saga;
   import engine.tile.Tile;
   import engine.tile.def.TileLocation;
   
   public class Action_BattleUnitAbility extends Action
   {
       
      
      private var _manager:IBattleAbilityManager;
      
      public function Action_BattleUnitAbility(param1:ActionDef, param2:Saga)
      {
         super(param1,param2);
      }
      
      public static function getAbilityId(param1:ActionDef) : String
      {
         return param1.param;
      }
      
      override protected function handleStarted() : void
      {
         var _loc7_:IEntityDef = null;
         var _loc1_:String = def.id;
         var _loc2_:String = getAbilityId(def);
         var _loc3_:int = Math.max(1,def.varvalue);
         var _loc4_:Vector.<String> = new Vector.<String>();
         var _loc5_:Vector.<TileLocation> = new Vector.<TileLocation>();
         var _loc6_:BattleBoard = saga.getBattleBoard();
         _loc1_ = saga.performStringReplacement_SagaVar(_loc1_);
         _loc7_ = saga.getCastMember(_loc1_);
         if(_loc7_)
         {
            _loc1_ = String(_loc7_.id);
         }
         var _loc8_:IBattleEntity = _loc6_.getEntityByIdOrByDefId(_loc1_,null,true);
         if(!_loc8_)
         {
            throw new ArgumentError("No such casterid [" + _loc1_ + "] for [" + def.id + "]");
         }
         _loc1_ = String(_loc8_.id);
         this._processTargets(_loc8_,_loc4_,_loc5_);
         var _loc9_:Function = def.instant ? null : this.battleAbilityHandler;
         saga.performBattleUnitAbility(_loc1_,_loc2_,_loc3_,_loc4_,_loc5_,_loc9_);
         if(def.instant)
         {
            end();
         }
      }
      
      private function _processTargets(param1:IBattleEntity, param2:Vector.<String>, param3:Vector.<TileLocation>) : void
      {
         var _loc11_:String = null;
         var _loc4_:String = def.id;
         var _loc5_:String = def.param;
         var _loc6_:BattleBoard = saga.getBattleBoard();
         var _loc7_:int = Math.max(1,def.varvalue);
         if(!def.anchor)
         {
            return;
         }
         var _loc8_:Array = def.anchor.split(":");
         var _loc9_:IAbilityDefLevel = !!param1.def.actives ? param1.def.actives.getAbilityDefLevelById(_loc5_) : null;
         var _loc10_:BattleAbilityDef = !!_loc9_ ? _loc9_.def.getAbilityDefForLevel(_loc7_) as BattleAbilityDef : null;
         for each(_loc11_ in _loc8_)
         {
            if(_loc11_)
            {
               if(!this._processTile(param1,_loc10_,_loc11_,param3))
               {
                  this._processTarget(param1,_loc10_,_loc11_,param2);
               }
            }
         }
      }
      
      private function _processTarget(param1:IBattleEntity, param2:BattleAbilityDef, param3:String, param4:Vector.<String>) : Boolean
      {
         if(!param3)
         {
            return false;
         }
         param4.push(param3);
         return true;
      }
      
      private function _processRandomTarget(param1:String, param2:BattleAbility, param3:BattleBoard) : String
      {
         var _loc5_:BattleEntity = null;
         var _loc6_:BattleAbilityValidation = null;
         var _loc7_:int = 0;
         if(!param1)
         {
            return param1;
         }
         if(param1.charAt(0) == "*")
         {
            param1 = param1.substr(1);
         }
         var _loc4_:Vector.<BattleEntity> = new Vector.<BattleEntity>();
         for each(_loc5_ in param3.entities)
         {
            if(param2._def.checkTargetExecutionConditions(_loc5_,logger,true))
            {
               _loc6_ = BattleAbilityValidation.validate(param2._def,param2.caster,null,_loc5_,null,false,false,true,true);
               if(!(!_loc6_ || !_loc6_.ok))
               {
                  if(!param2._targetSet.hasTarget(_loc5_))
                  {
                     _loc4_.push(_loc5_);
                  }
               }
            }
         }
         if(_loc4_.length)
         {
            _loc7_ = MathUtil.randomInt(0,_loc4_.length - 1);
            _loc5_ = _loc4_[_loc7_];
            return _loc5_.id;
         }
         return param1;
      }
      
      private function _processTile(param1:IBattleEntity, param2:BattleAbilityDef, param3:String, param4:Vector.<TileLocation>) : Boolean
      {
         var _loc10_:int = 0;
         if(!param3 || param3.charAt(0) != "@")
         {
            return false;
         }
         if(param3.indexOf("*") == 1)
         {
            _loc10_ = 1;
            if(param3.length > 2)
            {
               _loc10_ = int(param3.substring(2,3));
            }
            if(_loc10_ <= 0)
            {
               throw new ArgumentError("invalid tile num " + param3);
            }
            this.selectRandomTiles(param1,param2,param4,_loc10_);
            return true;
         }
         var _loc5_:String = param3.substring(1);
         var _loc6_:Array = _loc5_.split(",");
         if(_loc6_.length != 2)
         {
            throw new ArgumentError("Malformed tile [" + param3 + "] in targets [" + def.anchor + "]");
         }
         var _loc7_:int = int(_loc6_[0]);
         var _loc8_:int = int(_loc6_[1]);
         var _loc9_:TileLocation = TileLocation.fetch(_loc7_,_loc8_);
         param4.push(_loc9_);
         return true;
      }
      
      private function selectRandomTiles(param1:IBattleEntity, param2:BattleAbilityDef, param3:Vector.<TileLocation>, param4:int) : void
      {
         var _loc9_:Vector.<TileLocationInfo> = null;
         var _loc10_:TileLocation = null;
         var _loc11_:Tile = null;
         var _loc12_:int = 0;
         var _loc13_:TileLocationInfo = null;
         var _loc5_:BattleBoard = param1.board as BattleBoard;
         var _loc6_:int = param2.rangeMax(param1);
         var _loc7_:int = param2.rangeMin(param1);
         var _loc8_:TileDiamond = new TileDiamond(_loc5_.tiles,param1.rect,_loc7_,_loc6_,null,0);
         for each(_loc10_ in _loc8_.hugs)
         {
            if(param2.targetRule == BattleAbilityTargetRule.TILE_EMPTY)
            {
               _loc11_ = _loc5_.tiles.getTileByLocation(_loc10_);
               if(_loc11_.findResident(null))
               {
                  continue;
               }
               if(_loc5_.triggers.hasTriggerOnTile(_loc11_,true))
               {
                  continue;
               }
            }
            if(!(Boolean(param3) && param3.indexOf(_loc10_) >= 0))
            {
               if(!_loc9_)
               {
                  _loc9_ = new Vector.<TileLocationInfo>();
               }
               _loc9_.push(new TileLocationInfo(param1,_loc10_,true));
            }
         }
         if(Boolean(_loc9_) && _loc9_.length > 0)
         {
            _loc9_.sort(TileLocationInfo.comparatorEnemyProximity);
            _loc12_ = 0;
            while(_loc12_ < param4)
            {
               if(_loc9_.length)
               {
                  _loc13_ = _loc9_.pop();
                  param3.push(_loc13_.tl);
               }
               _loc12_++;
            }
         }
      }
      
      override protected function handleEnded() : void
      {
         if(this._manager)
         {
            this._manager.removeEventListener(BattleAbilityEvent.FINAL_COMPLETE_MANAGED,this.finalCompleteManagedHandler);
            this._manager = null;
         }
      }
      
      private function battleAbilityHandler(param1:BattleAbility) : void
      {
         if(!param1)
         {
            end();
            return;
         }
         this._manager = param1.manager;
         this._manager.addEventListener(BattleAbilityEvent.FINAL_COMPLETE_MANAGED,this.finalCompleteManagedHandler);
      }
      
      private function finalCompleteManagedHandler(param1:BattleAbilityEvent) : void
      {
         end();
      }
   }
}

import engine.battle.board.model.BattleBoard;
import engine.battle.board.model.IBattleEntity;
import engine.tile.def.TileLocation;
import engine.tile.def.TileRect;
import engine.tile.def.TileRectRange;

class TileLocationInfo
{
    
   
   public var tl:TileLocation;
   
   private var enemyProximity:int;
   
   private var allyProximity:int;
   
   private var casterDistance:int;
   
   private var PROX_LIMIT:int = 5;
   
   public function TileLocationInfo(param1:IBattleEntity, param2:TileLocation, param3:Boolean)
   {
      var _loc7_:IBattleEntity = null;
      var _loc8_:int = 0;
      var _loc9_:int = 0;
      var _loc10_:int = 0;
      super();
      this.tl = param2;
      var _loc4_:TileRect = new TileRect(param2,1,1);
      var _loc5_:int = TileRectRange.computeRange(param1.rect,_loc4_);
      var _loc6_:BattleBoard = param1.board as BattleBoard;
      for each(_loc7_ in _loc6_.entities)
      {
         if(!(!_loc7_.mobile || !_loc7_.attackable || !_loc7_.alive))
         {
            _loc8_ = TileRectRange.computeRange(_loc7_.rect,_loc4_);
            if(_loc8_ < this.PROX_LIMIT)
            {
               _loc9_ = TileRectRange.computeRange(param1.rect,_loc7_.rect);
               if(param3)
               {
                  if(_loc9_ < _loc5_)
                  {
                     continue;
                  }
               }
               _loc10_ = this.PROX_LIMIT - _loc8_;
               if(_loc7_.party == param1.party)
               {
                  this.allyProximity += _loc10_ * _loc10_ * _loc10_;
               }
               else
               {
                  this.enemyProximity += _loc10_ * _loc10_ * _loc10_;
               }
               this.casterDistance = _loc5_;
            }
         }
      }
   }
   
   public static function comparatorEnemyProximity(param1:TileLocationInfo, param2:TileLocationInfo) : int
   {
      var _loc3_:int = param1.enemyProximity - param2.enemyProximity;
      if(_loc3_ == 0)
      {
         return param2.casterDistance - param1.casterDistance;
      }
      return _loc3_;
   }
}
