package engine.battle.ability.effect.op.model
{
   import engine.battle.ability.def.BattleAbilityDef;
   import engine.battle.ability.def.BattleAbilityResponseTargetType;
   import engine.battle.ability.effect.model.Effect;
   import engine.battle.ability.effect.model.EffectResult;
   import engine.battle.ability.effect.op.def.EffectDefOp;
   import engine.battle.ability.model.BattleAbility;
   import engine.battle.ability.model.BattleAbilityValidation;
   import engine.battle.board.model.BattleBoard;
   import engine.battle.board.model.BattleBoardTiles;
   import engine.battle.board.model.BattleTile;
   import engine.battle.board.model.IBattleEntity;
   import engine.battle.entity.model.BattleEntity;
   import engine.battle.sim.TileDiamond;
   import engine.core.util.StableJson;
   import engine.def.BooleanVars;
   import engine.entity.def.IEntityDef;
   import engine.tile.Tile;
   import engine.tile.Tiles;
   import engine.tile.def.TileLocation;
   import engine.tile.def.TileRect;
   import engine.tile.def.TileRectRange;
   import flash.utils.Dictionary;
   
   public class Op_TargetAoe extends Op
   {
      
      public static const range_chema:Object = {
         "name":"Op_TargetAoe.Range",
         "properties":{
            "distance":{"type":"number"},
            "abilityEntity":{"type":"string"},
            "entityMustHaveAbility":{
               "type":"boolean",
               "optional":true
            },
            "abilityCaster":{
               "type":"string",
               "optional":true
            },
            "abilityTarget":{
               "type":"string",
               "optional":true
            },
            "abilityTile":{
               "type":"string",
               "optional":true
            },
            "aoeTargetOtherRule":{
               "type":"string",
               "optional":true
            },
            "aoeCasterOtherRule":{
               "type":"string",
               "optional":true
            }
         }
      };
      
      public static const schema:Object = {
         "name":"Op_TargetAoe",
         "properties":{
            "ranges":{
               "type":"array",
               "items":range_chema
            },
            "entityHitOnce":{
               "type":"boolean",
               "defaultValue":false,
               "optional":true
            },
            "abilityEntityRank":{
               "type":"number",
               "optional":true
            },
            "allowMultiplePeers":{
               "type":"boolean",
               "optional":true
            }
         }
      };
      
      public static var DEBUG_TARGET_AOE:Boolean;
       
      
      protected var hits:Dictionary;
      
      public var ranges:Vector.<Range_TargetAOE>;
      
      protected var entityHitOnce:Boolean = true;
      
      protected var allowMultiplePeers:Boolean;
      
      public var maxRange:int = 0;
      
      public var minRange:int = 100000;
      
      public function Op_TargetAoe(param1:EffectDefOp, param2:Effect)
      {
         var abilityRank:int;
         var range_index:int = 0;
         var ro:Object = null;
         var r:Range_TargetAOE = null;
         var ld:Number = NaN;
         var range_json:String = null;
         var def:EffectDefOp = param1;
         var effect:Effect = param2;
         this.hits = new Dictionary();
         this.ranges = new Vector.<Range_TargetAOE>();
         super(def,effect);
         this.allowMultiplePeers = def.params.allowMultiplePeers;
         abilityRank = 1;
         if(def.params.abilityEntityRank != undefined)
         {
            abilityRank = int(def.params.abilityEntityRank);
         }
         range_index = 0;
         for each(ro in def.params.ranges)
         {
            try
            {
               r = new Range_TargetAOE(ro,manager.factory,effect.ability.caster.logger,abilityRank);
               if(this.ranges.length > 0)
               {
                  ld = this.ranges[this.ranges.length - 1].distance;
                  if(r.distance <= ld)
                  {
                     effect.ability.caster.logger.error("Op_TargetAOE index " + this.ranges.length + " range [" + r.distance + "] out of order vs [" + ld + "] in " + def);
                  }
               }
               this.ranges.push(r);
               this.maxRange = Math.max(this.maxRange,r.distance);
               this.minRange = Math.min(this.minRange,r.distance);
            }
            catch(e:Error)
            {
               range_json = StableJson.stringify(ro,null);
               logger.error("Op_TargetAOE Range index " + range_index + " invalid: " + range_json + "\n" + e.getStackTrace());
            }
            range_index++;
         }
         if(this.ranges.length == 0)
         {
            effect.ability.caster.logger.error("Op_TargetAOE has no ranges: " + def);
         }
         this.entityHitOnce = BooleanVars.parse(def.params.entityHitOnce,this.entityHitOnce);
      }
      
      public static function computeAoeTargets(param1:IBattleEntity, param2:Dictionary, param3:int, param4:int, param5:Boolean, param6:Boolean, param7:Boolean) : Dictionary
      {
         var _loc12_:TileLocation = null;
         var _loc13_:IBattleEntity = null;
         var _loc14_:* = false;
         if(param4 != 1 || param3 != 1)
         {
            param1.logger.error("Can\'t handle this range: " + param3 + "/" + param4);
            return param2;
         }
         var _loc8_:BattleBoard = param1.board as BattleBoard;
         var _loc9_:BattleBoardTiles = _loc8_.tiles as BattleBoardTiles;
         var _loc10_:TileRect = param1.rect;
         var _loc11_:TileDiamond = new TileDiamond(_loc9_,_loc10_,param3,param4,null,-1);
         for each(_loc12_ in _loc11_.hugs)
         {
            _loc13_ = _loc8_.findEntityOnTile(_loc12_.x,_loc12_.y,true,param1);
            if(_loc13_)
            {
               if(!(!_loc13_.alive || !_loc13_.active || !_loc13_.enabled || !_loc13_.attackable || !param1.awareOf(_loc13_)))
               {
                  if(!param2[_loc13_])
                  {
                     if(!param5)
                     {
                        _loc14_ = _loc13_.team == param1.team;
                        if(!param6)
                        {
                           if(!_loc14_)
                           {
                              continue;
                           }
                        }
                        if(!param7)
                        {
                           if(_loc14_)
                           {
                              continue;
                           }
                        }
                     }
                     param2[_loc13_] = true;
                  }
               }
            }
         }
         return param2;
      }
      
      private static function _visitAdjacents(param1:int, param2:int, param3:Object) : void
      {
         var _loc9_:IBattleEntity = null;
         var _loc4_:IBattleEntity = param3.bt;
         var _loc5_:Dictionary = param3.associatedTargets;
         var _loc6_:BattleBoard = _loc4_.board as BattleBoard;
         var _loc7_:BattleTile = _loc6_.tiles.getTile(param1,param2) as BattleTile;
         var _loc8_:int = int(param3.depth);
         if(_loc7_)
         {
            for each(_loc9_ in _loc7_.residents)
            {
               if(!_loc5_[_loc9_])
               {
                  _loc5_[_loc9_] = _loc9_;
               }
            }
         }
      }
      
      override public function execute() : EffectResult
      {
         return EffectResult.OK;
      }
      
      private function applyGlobally() : void
      {
         var be:BattleEntity = null;
         for each(be in caster.board.entities)
         {
            if(target != be)
            {
               try
               {
                  this.applyOnTarget(be);
               }
               catch(e:Error)
               {
                  logger.error("Op_TargetAoe.applyGlobally failed to apply to " + be);
                  logger.error(e.getStackTrace());
               }
            }
         }
      }
      
      override public function apply() : void
      {
         var _loc7_:TileLocation = null;
         var _loc8_:IBattleEntity = null;
         var _loc9_:Range_TargetAOE = null;
         var _loc10_:IBattleEntity = null;
         var _loc11_:Tile = null;
         if(!target)
         {
            return;
         }
         if(this.ranges.length == 1)
         {
            _loc9_ = this.ranges[0];
            if(DEBUG_TARGET_AOE)
            {
               logger.debug("Op_TargetAoe.apply range[0]=" + _loc9_ + " distance=" + _loc9_.distance);
            }
            if(_loc9_.distance < 0)
            {
               this.applyGlobally();
               return;
            }
         }
         var _loc1_:TileRect = target.rect;
         var _loc2_:Tiles = target.board.tiles;
         var _loc3_:TileDiamond = new TileDiamond(_loc2_,_loc1_,this.minRange,this.maxRange,null,-1);
         var _loc4_:Dictionary = new Dictionary();
         var _loc5_:Array = [];
         var _loc6_:Array = [];
         if(DEBUG_TARGET_AOE)
         {
            logger.debug("Op_TargetAoe.apply hugs=" + _loc3_.hugs.length);
         }
         for each(_loc7_ in _loc3_.hugs)
         {
            _loc10_ = caster.board.findEntityOnTile(_loc7_.x,_loc7_.y,true,target);
            if(Boolean(_loc10_) && Boolean(_loc10_.attackable))
            {
               if(!_loc4_[_loc10_])
               {
                  _loc4_[_loc10_] = _loc10_;
                  _loc5_.push(_loc10_);
               }
            }
            else
            {
               _loc11_ = caster.board.tiles.getTile(_loc7_.x,_loc7_.y);
               if(_loc11_)
               {
                  _loc6_.push(_loc11_);
               }
            }
         }
         if(this.minRange < 1)
         {
            this.applyOnTarget(target);
         }
         for each(_loc8_ in _loc5_)
         {
            this.applyOnTarget(_loc8_);
         }
         effect.handleOpUsed(this);
      }
      
      private function getRange(param1:int) : Range_TargetAOE
      {
         var _loc3_:Range_TargetAOE = null;
         if(this.ranges.length == 0)
         {
            return null;
         }
         var _loc2_:int = 0;
         while(_loc2_ < this.ranges.length)
         {
            _loc3_ = this.ranges[_loc2_];
            if(_loc3_.distance > param1)
            {
               return this.ranges[Math.max(0,_loc2_ - 1)];
            }
            _loc2_++;
         }
         return this.ranges[this.ranges.length - 1];
      }
      
      private function computeEntity(param1:BattleAbilityResponseTargetType, param2:IBattleEntity) : IBattleEntity
      {
         switch(param1)
         {
            case BattleAbilityResponseTargetType.SELF:
            case BattleAbilityResponseTargetType.TARGET:
               return target;
            case BattleAbilityResponseTargetType.CASTER:
               return caster;
            case BattleAbilityResponseTargetType.OTHER:
               return param2;
            default:
               throw new ArgumentError("what?");
         }
      }
      
      private function applyOnTarget(param1:IBattleEntity) : void
      {
         var _loc9_:IEntityDef = null;
         var _loc10_:String = null;
         if(DEBUG_TARGET_AOE)
         {
            logger.debug("Op_TargetAoe.applyOnTarget caster=" + caster + " target=" + target + " other=" + param1);
         }
         var _loc2_:int = TileRectRange.computeRange(param1.rect,target.rect);
         var _loc3_:Range_TargetAOE = this.getRange(_loc2_);
         if(!_loc3_ || !_loc3_.abilityEntityDef)
         {
            if(DEBUG_TARGET_AOE)
            {
               logger.debug("Op_TargetAoe.applyOnTarget SKIP no range or range ability r=" + _loc3_);
            }
            return;
         }
         if(_loc3_.entityMustHaveAbility)
         {
            _loc9_ = param1.def;
            _loc10_ = _loc3_.abilityEntityDef.id;
            if((!_loc9_.actives || !_loc9_.actives.hasAbility(_loc10_)) && (!_loc9_.attacks || !_loc9_.attacks.hasAbility(_loc10_)))
            {
               if(DEBUG_TARGET_AOE)
               {
                  logger.debug("Op_TargetAoe.applyOnTarget SKIP entity does not have ability " + _loc3_.abilityEntityDef.id);
               }
               return;
            }
         }
         if(!_loc3_.aoeTargetOtherRule.isValid(target,target.rect,param1,null,true,_loc3_.abilityEntityDef,true))
         {
            if(DEBUG_TARGET_AOE)
            {
               logger.debug("Op_TargetAoe.applyOnTarget SKIP target rule invalid " + _loc3_.aoeTargetOtherRule);
            }
            return;
         }
         if(!_loc3_.aoeCasterOtherRule.isValid(caster,caster.rect,param1,null,true,_loc3_.abilityEntityDef,true))
         {
            if(DEBUG_TARGET_AOE)
            {
               logger.debug("Op_TargetAoe.applyOnTarget SKIP caster rule invalid " + _loc3_.aoeCasterOtherRule);
            }
            return;
         }
         var _loc4_:IBattleEntity = this.computeEntity(_loc3_.abilityCaster,param1);
         var _loc5_:IBattleEntity = this.computeEntity(_loc3_.abilityTarget,param1);
         if(DEBUG_TARGET_AOE)
         {
            logger.debug("Op_TargetAoe.applyOnTarget response caster/target " + _loc4_ + "/" + _loc5_);
         }
         var _loc6_:Boolean = true;
         if(this.hits[param1])
         {
            if(this.entityHitOnce == true)
            {
               if(DEBUG_TARGET_AOE)
               {
                  logger.debug("Op_TargetAoe.applyOnTarget SKIP already hit");
               }
               return;
            }
         }
         this.hits[param1] = param1;
         if(!this.allowMultiplePeers)
         {
            if(!this.checkPeers(param1,_loc3_.abilityEntityDef))
            {
               if(DEBUG_TARGET_AOE)
               {
                  logger.debug("Op_TargetAoe.applyOnTarget SKIP checkPeers");
               }
               return;
            }
         }
         var _loc7_:BattleAbilityValidation = BattleAbilityValidation.validateRange(_loc3_.abilityEntityDef,_loc4_,null,_loc5_,null);
         if(!_loc7_.ok)
         {
            if(DEBUG_TARGET_AOE)
            {
               logger.debug("Op_TargetAoe.applyOnTarget out of range [" + _loc4_ + "] -> [" + _loc5_ + "] range " + _loc7_);
            }
            return;
         }
         if(!_loc3_.abilityEntityDef.checkCasterExecutionConditions(_loc4_,logger,true))
         {
            if(DEBUG_TARGET_AOE)
            {
               logger.debug("Op_TargetAoe.applyOnTarget caster execution conditions failed for [" + _loc4_ + "]");
            }
            return;
         }
         var _loc8_:BattleAbility = new BattleAbility(_loc4_,_loc3_.abilityEntityDef,manager);
         _loc8_.targetSet.setTarget(_loc5_);
         effect.ability.addChildAbility(_loc8_);
      }
      
      private function checkPeers(param1:IBattleEntity, param2:BattleAbilityDef) : Boolean
      {
         var _loc5_:int = 0;
         var _loc6_:BattleAbility = null;
         var _loc3_:BattleAbility = ability.root as BattleAbility;
         var _loc4_:Array = [];
         _loc4_.push(_loc3_);
         while(_loc4_.length > 0)
         {
            _loc3_ = _loc4_.pop();
            if(_loc3_ != effect.ability)
            {
               if(_loc3_.def == param2)
               {
                  if(_loc3_.caster == param1 || _loc3_.targetSet.hasTarget(param1))
                  {
                     return false;
                  }
               }
               _loc5_ = 0;
               while(_loc5_ < _loc3_.children.length)
               {
                  _loc6_ = _loc3_.children[_loc5_];
                  _loc4_.push(_loc6_);
                  _loc5_++;
               }
            }
         }
         return true;
      }
   }
}

import engine.battle.ability.def.BattleAbilityDef;
import engine.battle.ability.def.BattleAbilityDefFactory;
import engine.battle.ability.def.BattleAbilityResponseTargetType;
import engine.battle.ability.def.BattleAbilityTargetRule;
import engine.core.logging.ILogger;
import engine.core.util.Enum;
import engine.def.BooleanVars;

class Range_TargetAOE
{
    
   
   public var distance:Number = 0;
   
   public var entityMustHaveAbility:Boolean;
   
   public var abilityEntityDef:BattleAbilityDef;
   
   public var abilityTileDef:BattleAbilityDef;
   
   public var abilityCaster:BattleAbilityResponseTargetType;
   
   public var abilityTarget:BattleAbilityResponseTargetType;
   
   public var aoeTargetOtherRule:BattleAbilityTargetRule;
   
   public var aoeCasterOtherRule:BattleAbilityTargetRule;
   
   public function Range_TargetAOE(param1:Object, param2:BattleAbilityDefFactory, param3:ILogger, param4:int)
   {
      var _loc5_:BattleAbilityDef = null;
      var _loc6_:BattleAbilityDef = null;
      this.abilityCaster = BattleAbilityResponseTargetType.TARGET;
      this.abilityTarget = BattleAbilityResponseTargetType.OTHER;
      this.aoeTargetOtherRule = BattleAbilityTargetRule.ANY;
      this.aoeCasterOtherRule = BattleAbilityTargetRule.ANY;
      super();
      if(param1.distance != undefined)
      {
         this.distance = param1.distance;
      }
      if(param1.abilityCaster != undefined)
      {
         this.abilityCaster = Enum.parse(BattleAbilityResponseTargetType,param1.abilityCaster) as BattleAbilityResponseTargetType;
      }
      if(param1.abilityTarget != undefined)
      {
         this.abilityTarget = Enum.parse(BattleAbilityResponseTargetType,param1.abilityTarget) as BattleAbilityResponseTargetType;
      }
      if(param1.abilityEntity)
      {
         _loc5_ = param2.fetchBattleAbilityDef(param1.abilityEntity);
         this.abilityEntityDef = _loc5_.getAbilityDefForLevel(param4) as BattleAbilityDef;
      }
      if(param1.abilityTile != undefined)
      {
         _loc6_ = param2.fetchBattleAbilityDef(param1.abilityTile);
         this.abilityTileDef = _loc6_.getAbilityDefForLevel(param4) as BattleAbilityDef;
      }
      if(param1.aoeTargetOtherRule != undefined)
      {
         this.aoeTargetOtherRule = Enum.parse(BattleAbilityTargetRule,param1.aoeTargetOtherRule) as BattleAbilityTargetRule;
      }
      if(param1.aoeCasterOtherRule != undefined)
      {
         this.aoeCasterOtherRule = Enum.parse(BattleAbilityTargetRule,param1.aoeCasterOtherRule) as BattleAbilityTargetRule;
      }
      this.entityMustHaveAbility = BooleanVars.parse(param1.entityMustHaveAbility,this.entityMustHaveAbility);
   }
   
   public function toString() : String
   {
      return "distance=" + this.distance.toFixed(1) + " abilityEntityDef=" + this.abilityEntityDef;
   }
}
