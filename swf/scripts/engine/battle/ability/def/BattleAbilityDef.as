package engine.battle.ability.def
{
   import engine.ability.def.AbilityDef;
   import engine.ability.def.AbilityDefFactory;
   import engine.battle.ability.effect.def.EffectDef;
   import engine.battle.ability.effect.def.EffectDefVars;
   import engine.battle.ability.effect.def.EffectStackRule;
   import engine.battle.ability.effect.def.EffectTagReqs;
   import engine.battle.ability.effect.def.EffectTagReqsVars;
   import engine.battle.ability.effect.def.IEffectDef;
   import engine.battle.ability.model.BattleAbilityValidation;
   import engine.battle.board.model.IBattleEntity;
   import engine.core.locale.Localizer;
   import engine.core.logging.ILogger;
   import engine.core.util.Enum;
   import engine.core.util.StableJson;
   import engine.def.BooleanVars;
   import engine.def.EngineJsonDef;
   import engine.stat.def.StatRange;
   import engine.stat.def.StatRangeVars;
   import engine.stat.def.StatRanges;
   import engine.stat.def.StatType;
   import engine.stat.model.IStatsProvider;
   import engine.stat.model.Stats;
   import engine.stat.model.StatsVars;
   
   public class BattleAbilityDef extends AbilityDef implements IBattleAbilityDef
   {
      
      public static const schema:Object = {
         "name":"BattleAbilityDefVars",
         "type":"object",
         "properties":{
            "id":{"type":"string"},
            "rangeMin":{"type":"number"},
            "rangeMax":{"type":"number"},
            "rangemodsDisabled":{
               "type":"boolean",
               "optional":true
            },
            "targetRule":{"type":"string"},
            "targetCount":{"type":"number"},
            "rangeType":{"type":"string"},
            "tag":{"type":"string"},
            "rangeModAsAttack":{
               "type":"boolean",
               "optional":true
            },
            "targetDelay":{
               "type":"number",
               "optional":true
            },
            "rotationRule":{
               "type":"string",
               "optional":true
            },
            "displayDamageUI":{
               "type":"boolean",
               "optional":true
            },
            "icon":{
               "type":"string",
               "optional":true
            },
            "iconLarge":{
               "type":"string",
               "optional":true
            },
            "iconBuff":{
               "type":"string",
               "optional":true
            },
            "tileTargetUrl":{
               "type":"string",
               "optional":true
            },
            "targetRotationRule":{
               "type":"string",
               "optional":true
            },
            "effects":{
               "type":"array",
               "items":EffectDefVars.schema,
               "optional":true
            },
            "levels":{
               "type":"array",
               "items":"any",
               "optional":true,
               "skip":true
            },
            "suppressOptionalStars":{
               "type":"boolean",
               "optional":true
            },
            "requiresGuaranteedHit":{
               "type":"boolean",
               "optional":true
            },
            "targetStatRanges":{
               "type":"array",
               "items":StatRangeVars.schema,
               "optional":true
            },
            "pgHide":{
               "type":"boolean",
               "optional":true
            },
            "abilityPopupAnimId":{
               "type":"string",
               "optional":true
            },
            "conditions":{
               "type":AbilityExecutionConditions.schema,
               "optional":true
            },
            "autolevels":{
               "type":"array",
               "optional":true,
               "items":{
                  "type":"object",
                  "properties":{"overrides":{
                     "type":"array",
                     "items":{"properties":{
                        "key":{"type":"string"},
                        "value":{"type":"any"}
                     }}
                  }}
               }
            },
            "effectTagReqs":{
               "type":{"properties":{
                  "caster":{
                     "type":EffectTagReqsVars.schema,
                     "optional":true
                  },
                  "target":{
                     "type":EffectTagReqsVars.schema,
                     "optional":true
                  }
               }},
               "optional":true
            },
            "costs":{
               "type":StatsVars.schema,
               "optional":true
            },
            "horn":{
               "type":"number",
               "optional":true
            },
            "maxMove":{"type":"number"},
            "moveTag":{
               "type":"string",
               "optional":true
            },
            "minResultDistance":{
               "type":"number",
               "optional":true
            },
            "maxResultDistance":{
               "type":"number",
               "optional":true
            },
            "optionalStars":{
               "type":"number",
               "optional":true
            },
            "aiRulesAbilityId":{
               "type":"string",
               "optional":true
            },
            "aiPositionalRule":{
               "type":"string",
               "optional":true
            },
            "aiUseRule":{
               "type":"string",
               "optional":true
            },
            "aiTargetRule":{
               "type":"string",
               "optional":true
            },
            "aiFrequency":{
               "type":"number",
               "optional":true
            },
            "localizeName":{
               "type":"boolean",
               "optional":true
            },
            "localizeRanks":{
               "type":"boolean",
               "optional":true
            }
         }
      };
      
      public static const DEFAULT_AI_FREQUENCY:Number = 0.5;
       
      
      public var _rangeMin:int;
      
      public var _rangeMax:int;
      
      public var _rangemodsDisabled:Boolean;
      
      public var _targetRule:BattleAbilityTargetRule;
      
      public var _targetCount:int;
      
      public var rangeType:BattleAbilityRangeType;
      
      public var casterEffectTagReqs:EffectTagReqs;
      
      public var targetEffectTagReqs:EffectTagReqs;
      
      public var maxMove:int;
      
      public var _targetDelay:int;
      
      public var _tag:BattleAbilityTag;
      
      public var _rangeModAsAttack:Boolean;
      
      public var stackRule:EffectStackRule;
      
      public var _effects:Vector.<IEffectDef>;
      
      public var _rotationRule:BattleAbilityRotationRule;
      
      public var _targetRotationRule:BattleAbilityTargetRotationRule;
      
      public var tileTargetUrl:String = "common/battle/tile/enemy_target_1.png";
      
      public var _requiresGuaranteedHit:Boolean;
      
      public var moveTag:BattleAbilityMoveTag;
      
      public var suppressOptionalStars:Boolean = true;
      
      public var _minResultDistance:int = 0;
      
      public var _maxResultDistance:int = 0;
      
      public var aiPositionalRule:BattleAbilityAiPositionalRuleType;
      
      public var aiUseRule:BattleAbilityAiUseRuleType;
      
      public var aiFrequency:Number = 0.5;
      
      public var aiTargetRule:BattleAbilityAiTargetRuleType;
      
      public var aiRulesAbility:BattleAbilityDef;
      
      public var aiRulesAbilityId:String;
      
      public var targetStatRanges:StatRanges;
      
      public var abilityPopupAnimId:String;
      
      public var pgHide:Boolean;
      
      public var _conditions:AbilityExecutionConditions;
      
      public function BattleAbilityDef(param1:BattleAbilityDef, param2:Localizer)
      {
         this._effects = new Vector.<IEffectDef>();
         this._rotationRule = BattleAbilityRotationRule.FIRST_TARGET;
         this._targetRotationRule = BattleAbilityTargetRotationRule.FACE_CASTER;
         this.moveTag = BattleAbilityMoveTag.NONE;
         this.aiPositionalRule = BattleAbilityAiPositionalRuleType.NONE;
         this.aiUseRule = BattleAbilityAiUseRuleType.NONE;
         this.aiTargetRule = BattleAbilityAiTargetRuleType.NONE;
         super(param1,param2);
      }
      
      public function getTileTargetUrl() : String
      {
         return this.tileTargetUrl;
      }
      
      private function getRangeModStatType() : StatType
      {
         if(this.tag == BattleAbilityTag.ATTACK_ARM || this.tag == BattleAbilityTag.ATTACK_STR || this._rangeModAsAttack)
         {
            if(this.rangeType == BattleAbilityRangeType.MELEE)
            {
               return StatType.RANGEMOD_MELEE;
            }
            if(this.rangeType == BattleAbilityRangeType.RANGED)
            {
               return StatType.RANGEMOD_RANGED;
            }
         }
         return null;
      }
      
      public function rangeMin(param1:IStatsProvider) : int
      {
         return this._rangeMin;
      }
      
      public function rangeMax(param1:IStatsProvider) : int
      {
         if(this._rangemodsDisabled)
         {
            return this._rangeMax;
         }
         var _loc2_:int = param1.stats.getValue(StatType.RANGEMOD_GLOBAL);
         var _loc3_:StatType = this.getRangeModStatType();
         if(_loc3_)
         {
            return this._rangeMax + param1.stats.getValue(_loc3_) + _loc2_;
         }
         return this._rangeMax + _loc2_;
      }
      
      public function getBattleAbilityDefLevel(param1:int) : IBattleAbilityDef
      {
         return super.getAbilityDefForLevel(param1) as IBattleAbilityDef;
      }
      
      public function getIBattleAbilityDefLevel(param1:int) : IBattleAbilityDef
      {
         return super.getAbilityDefForLevel(param1) as IBattleAbilityDef;
      }
      
      public function get battleAbilityDefRoot() : BattleAbilityDef
      {
         return super.root as BattleAbilityDef;
      }
      
      override public function link(param1:AbilityDefFactory) : void
      {
         var _loc2_:IEffectDef = null;
         var _loc3_:EffectDef = null;
         for each(_loc2_ in this.effects)
         {
            _loc3_ = _loc2_ as EffectDef;
            if(_loc3_)
            {
               _loc3_.link(param1 as BattleAbilityDefFactory);
            }
         }
         if(this.aiRulesAbilityId)
         {
            this.aiRulesAbility = param1.fetch(this.aiRulesAbilityId) as BattleAbilityDef;
         }
      }
      
      public function getEffectDefByName(param1:String) : IEffectDef
      {
         var _loc2_:IEffectDef = null;
         for each(_loc2_ in this.effects)
         {
            if(_loc2_.name == param1)
            {
               return _loc2_;
            }
         }
         return null;
      }
      
      public function checkTargetStatRanges(param1:Stats) : Boolean
      {
         var _loc3_:StatRange = null;
         var _loc4_:int = 0;
         if(!this.targetStatRanges)
         {
            return true;
         }
         var _loc2_:int = 0;
         while(_loc2_ < this.targetStatRanges.numStatRanges)
         {
            _loc3_ = this.targetStatRanges.getStatRangeByIndex(_loc2_);
            _loc4_ = param1.getValue(_loc3_.type);
            if(_loc3_.min > _loc4_ || _loc3_.max < _loc4_)
            {
               return false;
            }
            _loc2_++;
         }
         return true;
      }
      
      public function checkCasterExecutionConditions(param1:IBattleEntity, param2:ILogger, param3:Boolean) : Boolean
      {
         var _loc5_:BattleAbilityValidation = null;
         var _loc4_:BattleAbilityDef = this;
         if(_loc4_.casterEffectTagReqs)
         {
            if(!_loc4_.casterEffectTagReqs.checkTags(param1.effects,param2,null))
            {
               return false;
            }
         }
         if(_loc4_.conditions)
         {
            _loc5_ = _loc4_.conditions.checkExecutionConditions(null,_loc4_,param1,null,param2,param3);
            if(Boolean(_loc5_) && !_loc5_.ok)
            {
               return false;
            }
         }
         return true;
      }
      
      public function checkTargetExecutionConditions(param1:IBattleEntity, param2:ILogger, param3:Boolean) : Boolean
      {
         var _loc5_:BattleAbilityValidation = null;
         var _loc4_:BattleAbilityDef = this;
         if(_loc4_.targetEffectTagReqs)
         {
            if(!_loc4_.targetEffectTagReqs.checkTags(param1.effects,param2,null))
            {
               return false;
            }
         }
         if(!_loc4_.checkTargetStatRanges(param1.stats))
         {
            return false;
         }
         if(_loc4_.conditions)
         {
            _loc5_ = _loc4_.conditions.checkExecutionConditions(null,_loc4_,null,param1,param2,param3);
            if(Boolean(_loc5_) && !_loc5_.ok)
            {
               return false;
            }
         }
         return true;
      }
      
      public function get effects() : Vector.<IEffectDef>
      {
         return this._effects;
      }
      
      public function get targetDelay() : int
      {
         return this._targetDelay;
      }
      
      public function get targetCount() : int
      {
         return this._targetCount;
      }
      
      public function get minResultDistance() : int
      {
         return this._minResultDistance;
      }
      
      public function get maxResultDistance() : int
      {
         return this._maxResultDistance;
      }
      
      public function get targetRule() : BattleAbilityTargetRule
      {
         return this._targetRule;
      }
      
      public function get rotationRule() : BattleAbilityRotationRule
      {
         return this._rotationRule;
      }
      
      public function get targetRotationRule() : BattleAbilityTargetRotationRule
      {
         return this._targetRotationRule;
      }
      
      public function get tag() : BattleAbilityTag
      {
         return this._tag;
      }
      
      public function get conditions() : AbilityExecutionConditions
      {
         return this._conditions;
      }
      
      public function get requiresGuaranteedHit() : Boolean
      {
         return this._requiresGuaranteedHit;
      }
      
      public function init(param1:Object, param2:ILogger, param3:int = 1, param4:Boolean = false) : BattleAbilityDef
      {
         var localizeName:Boolean;
         var localizeRanks:Boolean;
         var isPassive:Boolean;
         var isActive:Boolean;
         var hasPersistence:Boolean = false;
         var srv:Object = null;
         var ed:Object = null;
         var effect:IEffectDef = null;
         var levIndex:int = 0;
         var lvlv:Object = null;
         var lvlad:BattleAbilityDef = null;
         var index:int = 0;
         var autolevelv:Object = null;
         var lvlvars:Object = null;
         var child_abl_rank:int = 0;
         var ad:BattleAbilityDef = null;
         var willpowerCost:int = 0;
         var ovr:Object = null;
         var key:String = null;
         var val:Object = null;
         var vars:Object = param1;
         var logger:ILogger = param2;
         var abl_rank:int = param3;
         var assignAutoLevels:Boolean = param4;
         EngineJsonDef.validateThrow(vars,schema,logger);
         this._tag = Enum.parse(BattleAbilityTag,vars.tag) as BattleAbilityTag;
         this._rangeModAsAttack = vars.rangeModAsAttack;
         this.pgHide = BooleanVars.parse(vars.pgHide,this.pgHide);
         localizeName = Boolean(vars.localizeName);
         localizeRanks = Boolean(vars.localizeRanks);
         isPassive = this.tag == BattleAbilityTag.PASSIVE;
         isActive = this.tag == BattleAbilityTag.SPECIAL;
         setId(vars.id,abl_rank,true,true,logger);
         this.abilityPopupAnimId = vars.abilityPopupAnimId;
         this.rangeType = Enum.parse(BattleAbilityRangeType,vars.rangeType) as BattleAbilityRangeType;
         _iconUrl = vars.icon;
         _iconLargeUrl = vars.iconLarge;
         _iconBuffUrl = vars.iconBuff;
         this.tileTargetUrl = vars.tileTargetUrl;
         this._rangeMin = vars.rangeMin;
         this._rangeMax = vars.rangeMax;
         this._rangemodsDisabled = vars.rangemodsDisabled;
         this._targetRule = Enum.parse(BattleAbilityTargetRule,vars.targetRule) as BattleAbilityTargetRule;
         this.maxMove = vars.maxMove;
         this._targetCount = vars.targetCount;
         displayDamageUI = vars.displayDamageUI;
         this.suppressOptionalStars = BooleanVars.parse(vars.suppressOptionalStars);
         this._requiresGuaranteedHit = BooleanVars.parse(vars.requiresGuaranteedHit,this._requiresGuaranteedHit);
         if(vars.conditions)
         {
            this._conditions = new AbilityExecutionConditions().fromJson(vars.conditions,logger);
         }
         if(vars.aiFrequency != undefined)
         {
            this.aiFrequency = vars.aiFrequency;
         }
         if(vars.aiPositionalRule)
         {
            this.aiPositionalRule = Enum.parse(BattleAbilityAiPositionalRuleType,vars.aiPositionalRule) as BattleAbilityAiPositionalRuleType;
         }
         this.aiRulesAbilityId = vars.aiRulesAbilityId;
         if(vars.aiUseRule)
         {
            this.aiUseRule = Enum.parse(BattleAbilityAiUseRuleType,vars.aiUseRule) as BattleAbilityAiUseRuleType;
         }
         if(vars.aiTargetRule)
         {
            this.aiTargetRule = Enum.parse(BattleAbilityAiTargetRuleType,vars.aiTargetRule) as BattleAbilityAiTargetRuleType;
         }
         if(vars.effectTagReqs)
         {
            if(vars.effectTagReqs.caster)
            {
               this.casterEffectTagReqs = new EffectTagReqsVars(vars.effectTagReqs.caster,logger);
            }
            if(vars.effectTagReqs.target)
            {
               this.targetEffectTagReqs = new EffectTagReqsVars(vars.effectTagReqs.target,logger);
            }
         }
         if(vars.moveTag != undefined)
         {
            this.moveTag = Enum.parse(BattleAbilityMoveTag,vars.moveTag) as BattleAbilityMoveTag;
         }
         if(vars.minResultDistance != undefined)
         {
            this._minResultDistance = int(vars.minResultDistance);
         }
         if(vars.maxResultDistance != undefined)
         {
            this._maxResultDistance = int(vars.maxResultDistance);
         }
         if(vars.optionalStars != undefined)
         {
            _optionalStars = int(vars.optionalStars);
         }
         if(vars.targetDelay != undefined)
         {
            this._targetDelay = int(vars.targetDelay);
         }
         if(vars.rotationRule != undefined)
         {
            this._rotationRule = Enum.parse(BattleAbilityRotationRule,vars.rotationRule) as BattleAbilityRotationRule;
         }
         if(vars.targetRotationRule != undefined)
         {
            this._targetRotationRule = Enum.parse(BattleAbilityTargetRotationRule,vars.targetRotationRule) as BattleAbilityTargetRotationRule;
         }
         if(vars.targetStatRanges != undefined)
         {
            this.targetStatRanges = new StatRanges();
            for each(srv in vars.targetStatRanges)
            {
               StatRangeVars.parseInto(this.targetStatRanges,srv,logger);
            }
         }
         if(vars.costs == undefined)
         {
            if(this.tag == BattleAbilityTag.SPECIAL)
            {
               _costs = new Stats(null,true);
               _costs.addStat(StatType.WILLPOWER,1);
            }
         }
         else
         {
            _costs = StatsVars.parse(null,vars.costs,logger);
         }
         _artifactChargeCost = vars.horn;
         if(vars.effects)
         {
            try
            {
               for each(ed in vars.effects)
               {
                  effect = new EffectDefVars(ed,this,logger);
                  this.effects.push(effect);
                  if(effect.persistent)
                  {
                     hasPersistence = true;
                  }
               }
            }
            catch(e:Error)
            {
               logger.error("BattleAbilityDefVars fail " + id + " " + e);
               throw e;
            }
         }
         if(hasPersistence && Boolean(this.iconBuffUrl))
         {
         }
         if(this.root == this)
         {
            this.addLevel(this);
            if(vars.hasOwnProperty("levels"))
            {
               levIndex = 1;
               for each(lvlv in vars.levels)
               {
                  levIndex++;
                  lvlad = new BattleAbilityDef(this.battleAbilityDefRoot,this.localizer).init(lvlv,logger,levIndex);
                  addLevel(lvlad);
               }
            }
            else if(vars.hasOwnProperty("autolevels"))
            {
               index = 0;
               for each(autolevelv in vars.autolevels)
               {
                  lvlvars = StableJson.parse(StableJson.stringify(vars));
                  lvlvars.levels = [];
                  try
                  {
                     for each(ovr in autolevelv.overrides)
                     {
                        key = String(ovr.key);
                        val = ovr.value;
                        BattleAbilityDefVars.replaceVars(lvlvars,key,val);
                     }
                  }
                  catch(e:Error)
                  {
                     logger.error("Failure to replace overrides for " + this.id + " level " + index + ": " + e);
                     throw e;
                  }
                  if(assignAutoLevels)
                  {
                     if(vars.levels == undefined)
                     {
                        vars.levels = [];
                     }
                     vars.levels.push(lvlvars);
                  }
                  index++;
                  child_abl_rank = index + 1;
                  ad = new BattleAbilityDef(this.battleAbilityDefRoot,this.localizer).init(lvlvars,logger,child_abl_rank);
                  willpowerCost = 0;
                  if(ad.tag == BattleAbilityTag.SPECIAL)
                  {
                     willpowerCost = ad.getCost(StatType.WILLPOWER) + index;
                  }
                  else if(ad.tag == BattleAbilityTag.ATTACK_ARM || ad.tag == BattleAbilityTag.ATTACK_STR)
                  {
                     willpowerCost = index;
                  }
                  if(willpowerCost)
                  {
                     ad.ensureCosts().addStat(StatType.WILLPOWER,willpowerCost);
                  }
                  addLevel(ad);
               }
               if(assignAutoLevels)
               {
                  delete vars["autolevels"];
               }
            }
         }
         return this;
      }
      
      public function getAiPositionalRule() : BattleAbilityAiPositionalRuleType
      {
         return this.aiPositionalRule;
      }
      
      public function getAiTargetRule() : BattleAbilityAiTargetRuleType
      {
         return this.aiTargetRule;
      }
      
      public function getMaxMove() : int
      {
         return this.maxMove;
      }
      
      public function getCasterEffectTagReqs() : EffectTagReqs
      {
         return this.casterEffectTagReqs;
      }
      
      public function getTargetEffectTagReqs() : EffectTagReqs
      {
         return this.targetEffectTagReqs;
      }
      
      public function getRangeType() : BattleAbilityRangeType
      {
         return this.rangeType;
      }
      
      public function getAiRulesAbility() : IBattleAbilityDef
      {
         return this.aiRulesAbility;
      }
   }
}
