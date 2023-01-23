package engine.battle.ability.model
{
   import engine.battle.BattleUtilFunctions;
   import engine.battle.ability.def.BattleAbilityRangeType;
   import engine.battle.ability.def.BattleAbilityTag;
   import engine.battle.ability.def.BattleAbilityTargetRule;
   import engine.battle.ability.def.IBattleAbilityDef;
   import engine.battle.ability.effect.def.EffectTagReqs;
   import engine.battle.ability.effect.model.BattleFacing;
   import engine.battle.ability.effect.op.model.Op_DamageStrHelper;
   import engine.battle.board.model.IBattleBoard;
   import engine.battle.board.model.IBattleEntity;
   import engine.battle.board.model.IBattleMove;
   import engine.core.logging.ILogger;
   import engine.core.logging.Logger;
   import engine.stat.def.StatType;
   import engine.stat.model.Stat;
   import engine.tile.ITileResident;
   import engine.tile.Tile;
   import engine.tile.def.TileRect;
   import engine.tile.def.TileRectRange;
   
   public class BattleAbilityValidation
   {
      
      public static const OK:BattleAbilityValidation = new BattleAbilityValidation("OK",true);
      
      public static const OUT_OF_RANGE:BattleAbilityValidation = new BattleAbilityValidation("OUT_OF_RANGE");
      
      public static const INSUFFICIENT_TILE:BattleAbilityValidation = new BattleAbilityValidation("INSUFFICIENT_TILE");
      
      public static const INVALID_TARGET_TARGETRULE:BattleAbilityValidation = new BattleAbilityValidation("INVALID_TARGET_TARGETRULE");
      
      public static const INVALID_TARGET_TILE:BattleAbilityValidation = new BattleAbilityValidation("INVALID_TARGET_TILE");
      
      public static const INVALID_TARGET_UNATTACKABLE:BattleAbilityValidation = new BattleAbilityValidation("INVALID_TARGET_UNATTACKABLE");
      
      public static const INVALID_TARGET_NOWHERE:BattleAbilityValidation = new BattleAbilityValidation("INVALID_TARGET_NOWHERE");
      
      public static const MOVED:BattleAbilityValidation = new BattleAbilityValidation("MOVED");
      
      public static const INSUFFICIENT_STARS:BattleAbilityValidation = new BattleAbilityValidation("INSUFFICIENT_STARS");
      
      public static const INAPPROPRIATE_TAGS:BattleAbilityValidation = new BattleAbilityValidation("INAPPROPRIATE_TAGS");
      
      public static const NONGUARANTEED:BattleAbilityValidation = new BattleAbilityValidation("NONGUARANTEED");
      
      public static const TOO_MANY_ENEMIES:BattleAbilityValidation = new BattleAbilityValidation("TOO_MANY_ENEMIES");
      
      public static const TOO_FEW_ENEMIES:BattleAbilityValidation = new BattleAbilityValidation("TOO_FEW_ENEMIES");
      
      public static const PILLAGED:BattleAbilityValidation = new BattleAbilityValidation("PILLAGED");
      
      public static const ABILITY_LEVEL_LOW:BattleAbilityValidation = new BattleAbilityValidation("ABILITY_LEVEL_LOW");
      
      public static const ABILITY_LEVEL_HIGH:BattleAbilityValidation = new BattleAbilityValidation("ABILITY_LEVEL_HIGH");
      
      public static const INCORRECT_CASTER:BattleAbilityValidation = new BattleAbilityValidation("INCORRECT_CASTER");
      
      public static const INCORRECT_TARGET:BattleAbilityValidation = new BattleAbilityValidation("INCORRECT_TARGET");
      
      public static const INCORRECT_EFFECTS:BattleAbilityValidation = new BattleAbilityValidation("INCORRECT_EFFECTS");
      
      public static const VISIBLE:BattleAbilityValidation = new BattleAbilityValidation("VISIBLE");
      
      public static const SAGA_PREREQS:BattleAbilityValidation = new BattleAbilityValidation("SAGA_PREREQS");
      
      public static const NULL:BattleAbilityValidation = new BattleAbilityValidation("NULL",true);
       
      
      public var name:String;
      
      public var ok:Boolean;
      
      public function BattleAbilityValidation(param1:String, param2:Boolean = false)
      {
         super();
         this.name = param1;
         this.ok = param2;
      }
      
      private static function validateMovement(param1:IBattleAbilityDef, param2:IBattleMove) : Boolean
      {
         var _loc3_:int = param1.getMaxMove();
         if(_loc3_ >= 0)
         {
            if(Boolean(param2) && !param2.executed)
            {
               if(param2.numSteps - 1 > _loc3_)
               {
                  return false;
               }
            }
         }
         return true;
      }
      
      public static function validateCosts(param1:IBattleAbilityDef, param2:IBattleEntity, param3:IBattleMove, param4:ILogger) : Boolean
      {
         var _loc7_:Stat = null;
         var _loc8_:int = 0;
         var _loc9_:int = 0;
         var _loc5_:Boolean = true;
         var _loc6_:int = 0;
         if(Boolean(param3) && !param3.committed)
         {
            _loc6_ = int(param2.stats.getExertionRequiredForMove(param3.numSteps - 1));
         }
         if(param1.artifactChargeCost)
         {
            if(param2.party.artifactChargeCount < param1.artifactChargeCost)
            {
               if(param4)
               {
                  param4.error("Not enough HORN");
               }
               return false;
            }
         }
         if(!param1.costs)
         {
            return true;
         }
         for each(_loc7_ in param1.costs)
         {
            _loc8_ = int(param2.stats.getValue(_loc7_.type));
            if(_loc7_.type == StatType.WILLPOWER)
            {
               _loc9_ = int(param2.stats.getValue(StatType.EXERTION));
               if(_loc9_ < _loc7_.value)
               {
                  if(!param4)
                  {
                     return false;
                  }
                  param4.error("Not enough EXERTION (" + _loc9_ + "/" + _loc7_.value + ") for " + param1.id + " by " + param2.id);
               }
               _loc8_ -= _loc6_;
            }
            if(_loc7_.value > _loc8_)
            {
               _loc5_ = false;
               if(!param4)
               {
                  return false;
               }
               param4.error("Not enough " + _loc7_.type + " (" + _loc8_ + "/" + _loc7_.value + ") for " + param1.id + " by " + param2.id);
            }
         }
         return _loc5_;
      }
      
      private static function validateTags(param1:IBattleAbilityDef, param2:IBattleEntity, param3:IBattleEntity) : Boolean
      {
         var _loc4_:EffectTagReqs = param1.getCasterEffectTagReqs();
         var _loc5_:EffectTagReqs = param1.getTargetEffectTagReqs();
         if(_loc4_)
         {
            if(!_loc4_.checkTags(param2.effects,param2.logger))
            {
               return false;
            }
         }
         if(_loc5_)
         {
            if(!param3 || !_loc5_.checkTags(param3.effects,param2.logger))
            {
               return false;
            }
         }
         return true;
      }
      
      public static function validate(param1:IBattleAbilityDef, param2:IBattleEntity, param3:IBattleMove, param4:IBattleEntity, param5:Tile, param6:Boolean, param7:Boolean, param8:Boolean, param9:Boolean = true, param10:Boolean = true) : BattleAbilityValidation
      {
         var _loc12_:BattleAbilityValidation = null;
         var _loc13_:BattleAbilityValidation = null;
         if(!validateMovement(param1,param3))
         {
            return MOVED;
         }
         if(param7 && !validateCosts(param1,param2,param3,null))
         {
            return INSUFFICIENT_STARS;
         }
         if(param1.conditions)
         {
            _loc12_ = param1.conditions.checkExecutionConditions(null,param1,param2,param4,Logger.instance,param8);
            if(Boolean(_loc12_) && !_loc12_.ok)
            {
               return _loc12_;
            }
         }
         if(!validateTags(param1,param2,param4))
         {
            return INAPPROPRIATE_TAGS;
         }
         if(param1.requiresGuaranteedHit)
         {
            if(!validateRequiresGuaranteedHit(param1,param2,param4))
            {
               return NONGUARANTEED;
            }
         }
         var _loc11_:TileRect = Boolean(param3) && !param3.interrupted ? param3.lastTileRect : param2.rect;
         if(!param1.targetRule.isValid(param2,_loc11_,param4,param5,param6,param1,param10))
         {
            return INVALID_TARGET_TARGETRULE;
         }
         if(param9)
         {
            _loc13_ = validateRange(param1,param2,param3,param4,param5);
            if(_loc13_ != OK)
            {
               return _loc13_;
            }
         }
         if(!validateTile(param2,param1.targetRule,param5))
         {
            return INVALID_TARGET_TILE;
         }
         return OK;
      }
      
      public static function validateTile(param1:IBattleEntity, param2:BattleAbilityTargetRule, param3:Tile) : Boolean
      {
         var _loc4_:ITileResident = null;
         var _loc5_:BattleFacing = null;
         if(param2 == BattleAbilityTargetRule.TILE_EMPTY || param2 == BattleAbilityTargetRule.TILE_ANY)
         {
            if(param3)
            {
               _loc4_ = param3.findResident(param1);
               if(_loc4_ != null && Boolean(param1.awareOf(_loc4_)))
               {
                  if(param2 == BattleAbilityTargetRule.TILE_EMPTY || !_loc4_.attackable)
                  {
                     return false;
                  }
               }
            }
         }
         if(param2 == BattleAbilityTargetRule.TILE_EMPTY_1x2_FACING_CASTER)
         {
            if(param3)
            {
               if(param3.numResidents)
               {
                  _loc4_ = param3.findResident(param1);
                  if(param1.awareOf(_loc4_))
                  {
                     return false;
                  }
               }
               _loc5_ = findValidFacingFor1x2(param1,param3);
               if(!_loc5_)
               {
                  return false;
               }
            }
         }
         return true;
      }
      
      public static function findValidFacingFor1x2(param1:IBattleEntity, param2:Tile) : BattleFacing
      {
         var _loc4_:Tile = null;
         var _loc13_:BattleFacing = null;
         if(!param2 || Boolean(param2._numResidents))
         {
            return null;
         }
         var _loc3_:IBattleBoard = param1.board;
         var _loc5_:int = Number(param1.x) - param2.x;
         var _loc6_:int = Number(param1.y) - param2.y;
         var _loc7_:BattleFacing = BattleFacing.findFacing(_loc5_,_loc6_);
         if(_checkTileTail(_loc3_,param2,_loc7_))
         {
            return _loc7_;
         }
         var _loc8_:BattleFacing = _loc7_.clockwiseBattleFacing();
         var _loc9_:BattleFacing = _loc7_.flipBattleFacing;
         var _loc10_:BattleFacing = _loc9_.clockwiseBattleFacing();
         var _loc11_:Number = _loc8_.angleRadiansToPoint(_loc5_,_loc6_);
         var _loc12_:Number = _loc10_.angleRadiansToPoint(_loc5_,_loc6_);
         if(_loc12_ < _loc11_)
         {
            _loc13_ = _loc10_;
            _loc10_ = _loc8_;
            _loc8_ = _loc13_;
         }
         if(_checkTileTail(_loc3_,param2,_loc8_))
         {
            return _loc8_;
         }
         if(_checkTileTail(_loc3_,param2,_loc10_))
         {
            return _loc10_;
         }
         if(_checkTileTail(_loc3_,param2,_loc9_))
         {
            return _loc9_;
         }
         return null;
      }
      
      private static function _checkTileTail(param1:IBattleBoard, param2:Tile, param3:BattleFacing) : Boolean
      {
         var _loc4_:Tile = param1.tiles.getTile(param2.x - param3.x,param2.y - param3.y);
         if(Boolean(_loc4_) && !_loc4_.numResidents)
         {
            return true;
         }
         return false;
      }
      
      public static function validateRequiresGuaranteedHit(param1:IBattleAbilityDef, param2:IBattleEntity, param3:IBattleEntity) : Boolean
      {
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         if(param1.requiresGuaranteedHit)
         {
            if(!param3)
            {
               return false;
            }
            _loc4_ = Op_DamageStrHelper.computePunctureBonus(param2,param3,true);
            _loc5_ = int(param2.stats.getValue(StatType.STRENGTH));
            _loc6_ = int(param3.stats.getValue(StatType.ARMOR));
            _loc7_ = _loc5_ + _loc4_;
            return _loc7_ >= _loc6_;
         }
         return true;
      }
      
      public static function validateRange(param1:IBattleAbilityDef, param2:IBattleEntity, param3:IBattleMove, param4:IBattleEntity, param5:Tile) : BattleAbilityValidation
      {
         var _loc9_:int = 0;
         var _loc10_:TileRect = null;
         if(Boolean(param3) && param3.executed)
         {
            param3 = null;
         }
         var _loc6_:BattleAbilityRangeType = param1.getRangeType();
         if(BattleAbilityRangeType.NONE == _loc6_)
         {
            return OK;
         }
         if(param2.incorporeal && param1.tag != BattleAbilityTag.SPECIAL_NOCOST)
         {
            return INVALID_TARGET_UNATTACKABLE;
         }
         if(param4 != null)
         {
            if(param4 != param2 && !param4.attackable)
            {
               if(param1.targetRule != BattleAbilityTargetRule.USABLE)
               {
                  return INVALID_TARGET_UNATTACKABLE;
               }
            }
            if(param4.tile == null)
            {
               return INVALID_TARGET_NOWHERE;
            }
         }
         var _loc7_:int = param1.rangeMax(param2);
         var _loc8_:int = param1.rangeMin(param2);
         if(_loc6_ != BattleAbilityRangeType.NONE && (_loc7_ > 0 || _loc8_ > 0))
         {
            _loc9_ = -1;
            if(Boolean(param3) && !param3.interrupted)
            {
               _loc10_ = param3.lastTileRect;
            }
            else
            {
               _loc10_ = param2.rect;
            }
            if(param1.targetRule.isTile)
            {
               if(param5 != null)
               {
                  _loc9_ = TileRectRange.computeRange(_loc10_,param5.rect);
               }
            }
            else if(param1.targetRule == BattleAbilityTargetRule.SPECIAL_BATTERING_RAM)
            {
               _loc9_ = TileRectRange.computeRange(_loc10_,param4.rect);
            }
            else if(param4 != null)
            {
               _loc9_ = TileRectRange.computeRange(_loc10_,param4.rect);
            }
            if(_loc9_ >= 0)
            {
               if(_loc9_ > _loc7_)
               {
                  return OUT_OF_RANGE;
               }
               if(_loc9_ < _loc8_)
               {
                  return OUT_OF_RANGE;
               }
            }
            if(param4 != null && param1.targetRule.isAxial)
            {
               if(param1.targetRule == BattleAbilityTargetRule.SPECIAL_PLAYER_DRUMFIRE)
               {
                  if(param4 == param2)
                  {
                     return OK;
                  }
               }
               if(BattleUtilFunctions.isAxialEntity2Entity(_loc10_,param4) == false)
               {
                  return OUT_OF_RANGE;
               }
            }
         }
         return OK;
      }
      
      public function toString() : String
      {
         return "[" + this.name + "]";
      }
   }
}
