package engine.battle.fsm.aimodule
{
   import engine.ability.def.AbilityDefLevel;
   import engine.battle.ability.BattleCalculationHelper;
   import engine.battle.ability.def.BattleAbilityAiPositionalRuleType;
   import engine.battle.ability.def.BattleAbilityDefLevels;
   import engine.battle.ability.def.BattleAbilityTag;
   import engine.battle.ability.def.IBattleAbilityDef;
   import engine.battle.board.model.IBattleEntity;
   import engine.battle.board.model.IBattleMove;
   import engine.battle.entity.model.BattleEntity;
   import engine.entity.def.Shitlist;
   import engine.math.MathUtil;
   import engine.stat.def.StatType;
   import engine.stat.model.Stats;
   import engine.tile.Tile;
   import engine.tile.def.TileLocation;
   import engine.tile.def.TileRect;
   import engine.tile.def.TileRectRange;
   
   public class AiPlanUtil
   {
       
      
      public function AiPlanUtil()
      {
         super();
      }
      
      public static function computeWillpowerDominanceWeight(param1:IBattleEntity, param2:IBattleEntity) : int
      {
         var _loc3_:int = int(param1.stats.getValue(StatType.WILLPOWER));
         var _loc4_:int = int(param2.stats.getValue(StatType.WILLPOWER));
         if(_loc3_ > _loc4_)
         {
            return (_loc3_ - _loc4_) * AiPlanConsts.WEIGHT_WILLPOWER_DOMINANCE;
         }
         return -100 * AiPlanConsts.WEIGHT_WILLPOWER_DOMINANCE;
      }
      
      public static function enemiesWhichHaveTileWeight(param1:IBattleEntity, param2:Vector.<IBattleEntity>) : Vector.<IBattleEntity>
      {
         var _loc4_:BattleEntity = null;
         var _loc3_:Vector.<IBattleEntity> = new Vector.<IBattleEntity>();
         for each(_loc4_ in param2)
         {
            if(!(!_loc4_.rect || !param1.awareOf(_loc4_)))
            {
               if(!(!_loc4_.mobile && (_loc4_.team == null || _loc4_.team == "prop")))
               {
                  _loc3_.push(_loc4_);
               }
            }
         }
         return _loc3_;
      }
      
      public static function computeTileAdjacentEnemyWeight(param1:IBattleEntity, param2:Tile, param3:Vector.<IBattleEntity>) : int
      {
         var _loc5_:BattleEntity = null;
         var _loc6_:int = 0;
         var _loc4_:int = 0;
         for each(_loc5_ in param3)
         {
            _loc6_ = TileRectRange.computeTileRange(param2.location,_loc5_.rect);
            if(_loc6_ == 0)
            {
               _loc4_ += 2;
            }
            else if(_loc6_ == 1)
            {
               _loc4_ += 1;
            }
         }
         return _loc4_;
      }
      
      public static function computeStarsWeight(param1:AiModuleBase, param2:IBattleAbilityDef, param3:IBattleMove) : int
      {
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:Stats = param1.caster.stats;
         var _loc6_:int = 0;
         if(param2)
         {
            _loc7_ = !!param2.costs ? int(param2.costs.getValue(StatType.WILLPOWER)) : 0;
            _loc6_ += _loc7_ * AiPlanConsts.WEIGHT_STAR_ABILITY;
         }
         if(Boolean(param3) && param3.numSteps > 1)
         {
            _loc8_ = _loc5_.getExertionRequiredForMove(param3.numSteps - 1);
            _loc6_ += _loc8_ * AiPlanConsts.WEIGHT_STAR_MOVE;
         }
         return int(_loc4_ + MathUtil.lerp(-_loc6_,_loc6_,param1.desperation));
      }
      
      public static function computePositionalEnemyWeight(param1:AiModuleBase, param2:IBattleAbilityDef, param3:TileLocation, param4:BattleEntity) : int
      {
         var _loc12_:int = 0;
         var _loc13_:int = 0;
         var _loc14_:int = 0;
         var _loc15_:int = 0;
         var _loc16_:BattleAbilityAiPositionalRuleType = null;
         var _loc17_:IBattleAbilityDef = null;
         var _loc18_:int = 0;
         var _loc19_:int = 0;
         var _loc20_:int = 0;
         var _loc21_:Shitlist = null;
         var _loc22_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:BattleAbilityDefLevels = param4.def.attacks as BattleAbilityDefLevels;
         if(!_loc6_)
         {
            return 0;
         }
         var _loc7_:AbilityDefLevel = _loc6_.getFirstAbilityByTag(BattleAbilityTag.ATTACK_STR);
         if(!_loc7_)
         {
            return 0;
         }
         var _loc8_:IBattleAbilityDef = _loc7_.def as IBattleAbilityDef;
         var _loc9_:TileRect = new TileRect(param3,param1.caster.rect.width,param1.caster.rect.length);
         var _loc10_:TileRect = param4.rect;
         if(!_loc10_)
         {
            return 0;
         }
         var _loc11_:int = TileRectRange.computeRange(_loc9_,_loc10_);
         if(_loc8_)
         {
            _loc12_ = _loc8_.rangeMin(param4);
            _loc13_ = _loc8_.rangeMax(param4);
            if(_loc11_ < _loc13_ && _loc11_ > _loc12_)
            {
               _loc14_ = BattleCalculationHelper.strengthNormalDamage(param4,param1.caster,0);
               _loc14_ += BattleCalculationHelper.calculatePunctureBonus(param4,param1.caster);
               _loc15_ = param4.stats.getValue(StatType.ARMOR_BREAK);
               _loc14_ = Math.min(_loc14_,param1.caster.stats.getValue(StatType.STRENGTH));
               _loc15_ = Math.min(_loc15_,param1.caster.stats.getValue(StatType.ARMOR));
               if(_loc14_ > param1.caster.stats.getValue(StatType.STRENGTH))
               {
                  _loc14_ *= 2;
               }
               _loc14_ *= AiPlanConsts.WEIGHT_ABL_DAMAGE_STR;
               _loc15_ *= AiPlanConsts.WEIGHT_ABL_DAMAGE_ARM;
               _loc5_ -= Math.max(_loc14_,_loc15_) * AiPlanConsts.WEIGHT_SELF_THREAT;
            }
         }
         if(param2)
         {
            _loc16_ = param2.getAiPositionalRule();
            if(_loc16_ == BattleAbilityAiPositionalRuleType.HIGHEST_ENEMY_THREAT || _loc16_ == BattleAbilityAiPositionalRuleType.AOE_DAMAGE_ALL)
            {
               _loc5_ += 100;
            }
            else if(_loc16_ == BattleAbilityAiPositionalRuleType.LOWEST_ENEMY_THREAT)
            {
               _loc5_ *= 4;
            }
         }
         if(param1.atkStrRoot)
         {
            _loc17_ = param1.atkStrRoot;
            _loc12_ = _loc17_.rangeMin(param1.caster);
            _loc13_ = _loc17_.rangeMax(param1.caster);
            if(_loc11_ < _loc13_ && _loc11_ > _loc12_)
            {
               _loc18_ = BattleCalculationHelper.strengthNormalDamage(param1.caster,param4,0);
               _loc18_ += BattleCalculationHelper.calculatePunctureBonus(param1.caster,param4);
               _loc19_ = param1.caster.stats.getValue(StatType.ARMOR_BREAK);
               _loc18_ = Math.min(_loc18_,param4.stats.getValue(StatType.STRENGTH));
               _loc19_ = Math.min(_loc19_,param4.stats.getValue(StatType.ARMOR));
               if(_loc18_ > param4.stats.getValue(StatType.STRENGTH))
               {
                  _loc18_ *= 2;
               }
               _loc18_ *= AiPlanConsts.WEIGHT_ABL_DAMAGE_STR;
               _loc19_ *= AiPlanConsts.WEIGHT_ABL_DAMAGE_ARM;
               _loc20_ = Math.max(_loc18_,_loc19_) * AiPlanConsts.WEIGHT_ENEMY_THREAT;
               _loc21_ = param1.shitlist;
               if(_loc21_)
               {
                  _loc22_ = _loc21_.getShitlistWeight(param4);
                  _loc20_ *= 1 + _loc22_;
               }
               _loc5_ += _loc20_;
            }
            if(!param1.isRanged)
            {
               _loc5_ = -_loc11_ * AiPlanConsts.WEIGHT_ENEMY_DISTANCE;
            }
         }
         return _loc5_;
      }
   }
}
