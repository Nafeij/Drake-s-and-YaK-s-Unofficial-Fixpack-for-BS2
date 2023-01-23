package engine.battle.ability.def
{
   import engine.battle.ability.effect.def.EffectDef;
   import engine.battle.ability.effect.def.EffectDefVars;
   import engine.battle.ability.effect.def.EffectTagReqsVars;
   import engine.stat.def.StatRange;
   import engine.stat.def.StatRangeVars;
   import engine.stat.model.StatsVars;
   import flash.errors.IllegalOperationError;
   
   public class BattleAbilityDefVars
   {
       
      
      public function BattleAbilityDefVars()
      {
         super();
      }
      
      public static function save(param1:BattleAbilityDef) : Object
      {
         var _loc3_:EffectDef = null;
         var _loc4_:int = 0;
         var _loc5_:BattleAbilityDef = null;
         var _loc6_:StatRange = null;
         var _loc2_:Object = {
            "id":param1.id,
            "rangeMin":param1.rangeMin,
            "rangeMax":param1.rangeMax,
            "targetRule":param1.targetRule.name,
            "targetCount":param1.targetCount,
            "rangeType":param1.rangeType.name,
            "tag":param1.tag.name,
            "maxMove":param1.maxMove
         };
         if(param1._rangeModAsAttack)
         {
            _loc2_.rangeModAsAttack = param1._rangeModAsAttack;
         }
         if(param1._rangemodsDisabled)
         {
            _loc2_.rangemodsDisabled = param1._rangemodsDisabled;
         }
         if(param1.conditions)
         {
            _loc2_.conditions = param1.conditions.save();
         }
         if(param1.abilityPopupAnimId)
         {
            _loc2_.abilityPopupAnimId = param1.abilityPopupAnimId;
         }
         if(param1.aiRulesAbilityId)
         {
            _loc2_.aiRulesAbilityId = param1.aiRulesAbilityId;
         }
         if(param1.targetDelay)
         {
            _loc2_.targetDelay = param1.targetDelay;
         }
         if(param1.rotationRule != BattleAbilityRotationRule.FIRST_TARGET)
         {
            _loc2_.rotationRule = param1.rotationRule.name;
         }
         if(param1.displayDamageUI)
         {
            _loc2_.displayDamageUI = param1.displayDamageUI;
         }
         if(param1.iconUrl)
         {
            _loc2_.icon = param1.iconUrl;
         }
         if(param1.iconLargeUrl)
         {
            _loc2_.iconLarge = param1.iconLargeUrl;
         }
         if(param1.iconBuffUrl)
         {
            _loc2_.iconBuff = param1.iconLargeUrl;
         }
         if(param1.tileTargetUrl)
         {
            _loc2_.tileTargetUrl = param1.tileTargetUrl;
         }
         if(param1.targetRotationRule != BattleAbilityTargetRotationRule.FACE_CASTER)
         {
            _loc2_.targetRotationRule = param1.targetRotationRule.name;
         }
         if(Boolean(param1.effects) && Boolean(param1.effects.length))
         {
            _loc2_.effects = [];
            for each(_loc3_ in param1.effects)
            {
               _loc2_.effects.push(EffectDefVars.save(_loc3_));
            }
         }
         if(Boolean(param1.levels) && param1.levels.length > 1)
         {
            _loc2_.levels = [];
            _loc4_ = 1;
            while(_loc4_ < param1.levels.length)
            {
               _loc5_ = param1.levels[_loc4_] as BattleAbilityDef;
               if(_loc5_ == param1)
               {
                  throw new IllegalOperationError("the thing that should not be");
               }
               _loc2_.levels.push(BattleAbilityDefVars.save(_loc5_));
               _loc4_++;
            }
         }
         if(!param1.suppressOptionalStars)
         {
            _loc2_.suppressOptionalStars = param1.suppressOptionalStars;
         }
         if(param1.requiresGuaranteedHit)
         {
            _loc2_.requiresGuaranteedHit = param1.requiresGuaranteedHit;
         }
         if(param1.targetStatRanges)
         {
            _loc2_.targetStatRanges = [];
            for each(_loc6_ in param1.targetStatRanges)
            {
               _loc2_.targetStatRanges.push(StatRangeVars.save(_loc6_));
            }
         }
         if(Boolean(param1.casterEffectTagReqs) || Boolean(param1.targetEffectTagReqs))
         {
            _loc2_.effectTagReqs = {};
            if(param1.casterEffectTagReqs)
            {
               _loc2_.effectTagReqs.caster = EffectTagReqsVars.save(param1.casterEffectTagReqs);
            }
            if(param1.targetEffectTagReqs)
            {
               _loc2_.effectTagReqs.target = EffectTagReqsVars.save(param1.targetEffectTagReqs);
            }
         }
         if(param1.costs)
         {
            _loc2_.costs = StatsVars.save(param1.costs);
         }
         if(param1.artifactChargeCost)
         {
            _loc2_.horn = param1.artifactChargeCost;
         }
         if(param1.maxMove)
         {
            _loc2_.maxMove = param1.maxMove;
         }
         if(param1.moveTag != BattleAbilityMoveTag.NONE)
         {
            _loc2_.moveTag = param1.moveTag.name;
         }
         if(param1.minResultDistance)
         {
            _loc2_.minResultDistance = param1.minResultDistance;
         }
         if(param1.maxResultDistance)
         {
            _loc2_.maxResultDistance = param1.maxResultDistance;
         }
         if(param1.optionalStars)
         {
            _loc2_.optionalStars = param1.optionalStars;
         }
         if(param1.aiRulesAbilityId)
         {
            _loc2_.aiRulesAbilityId = param1.aiRulesAbilityId;
         }
         if(param1.aiPositionalRule != BattleAbilityAiPositionalRuleType.NONE)
         {
            _loc2_.aiPositionalRule = param1.aiPositionalRule.name;
         }
         if(param1.aiUseRule != BattleAbilityAiUseRuleType.NONE)
         {
            _loc2_.aiUseRule = param1.aiUseRule.name;
         }
         if(param1.aiTargetRule != BattleAbilityAiTargetRuleType.NONE)
         {
            _loc2_.aiTargetRule = param1.aiTargetRule.name;
         }
         if(param1.aiFrequency != BattleAbilityDef.DEFAULT_AI_FREQUENCY)
         {
            _loc2_.aiFrequency = param1.aiFrequency;
         }
         return _loc2_;
      }
      
      public static function replaceVars(param1:Object, param2:String, param3:Object) : void
      {
         var _loc8_:String = null;
         var _loc9_:String = null;
         var _loc10_:int = 0;
         var _loc11_:String = null;
         var _loc12_:int = 0;
         var _loc13_:Array = null;
         var _loc14_:Object = null;
         var _loc4_:int = param2.indexOf("[");
         var _loc5_:int = param2.indexOf("]");
         if(_loc4_ >= 0 || _loc5_ >= 0)
         {
            throw new ArgumentError("BattleAbilityDef.replaceVars: braces are deprecated.  feel my wrath.");
         }
         var _loc6_:int = param2.indexOf(".");
         var _loc7_:int = param2.indexOf("(");
         if(_loc7_ == 0)
         {
            _loc10_ = param2.indexOf(")");
            _loc11_ = param2.substring(_loc7_ + 1,_loc10_);
            _loc12_ = int(_loc11_);
            _loc13_ = param1 as Array;
            if(_loc13_.length <= _loc12_)
            {
               throw new ArgumentError("bad vars index " + param2);
            }
            _loc9_ = param2.substring(_loc10_ + 1);
            if(!_loc9_)
            {
               _loc13_[_loc12_] = param3;
            }
            else
            {
               if(_loc9_.charAt(0) != ".")
               {
                  throw new ArgumentError("dot must follow )");
               }
               _loc9_ = _loc9_.substring(1);
               replaceVars(_loc13_[_loc12_],_loc9_,param3);
            }
            return;
         }
         if(_loc7_ > 0 && (_loc7_ < _loc6_ || _loc6_ < 0))
         {
            _loc8_ = param2.substr(0,_loc7_);
            _loc9_ = param2.substr(_loc7_);
         }
         if(_loc6_ > 0 && (_loc6_ < _loc7_ || _loc7_ < 0))
         {
            _loc8_ = param2.substr(0,_loc6_);
            _loc9_ = param2.substr(_loc6_ + 1);
         }
         if(Boolean(_loc8_) && Boolean(_loc9_))
         {
            if(!(_loc8_ in param1))
            {
               throw new ArgumentError("could not find child " + param2);
            }
            _loc14_ = param1[_loc8_];
            replaceVars(_loc14_,_loc9_,param3);
            return;
         }
         param1[param2] = param3;
      }
   }
}
