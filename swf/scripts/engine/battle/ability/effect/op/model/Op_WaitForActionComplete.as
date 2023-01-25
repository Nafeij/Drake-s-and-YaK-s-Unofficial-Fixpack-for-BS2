package engine.battle.ability.effect.op.model
{
   import engine.battle.ability.def.BattleAbilityAiTargetRuleType;
   import engine.battle.ability.def.BattleAbilityDef;
   import engine.battle.ability.def.BattleAbilityResponseTargetType;
   import engine.battle.ability.def.BattleAbilityTargetRule;
   import engine.battle.ability.def.IBattleAbilityDef;
   import engine.battle.ability.effect.def.EffectTagReqs;
   import engine.battle.ability.effect.def.EffectTagReqsVars;
   import engine.battle.ability.effect.model.Effect;
   import engine.battle.ability.effect.model.EffectTag;
   import engine.battle.ability.effect.op.def.EffectDefOp;
   import engine.battle.ability.model.BattleAbility;
   import engine.battle.ability.model.BattleAbilityEvent;
   import engine.battle.ability.model.BattleAbilityResponsePhase;
   import engine.battle.ability.model.BattleAbilityValidation;
   import engine.battle.ability.model.IBattleAbility;
   import engine.battle.board.model.BattleBoard_SpatialUtil;
   import engine.battle.board.model.IBattleEntity;
   import engine.battle.entity.model.BattleEntity;
   import engine.core.logging.ILogger;
   import engine.core.util.Enum;
   import engine.def.BooleanVars;
   import engine.def.NumberVars;
   import engine.math.Rng;
   import engine.stat.def.StatType;
   import flash.utils.Dictionary;
   
   public class Op_WaitForActionComplete extends Op
   {
      
      public static const schema:Object = {
         "name":"Op_WaitForActionComplete",
         "properties":{
            "ability":{"type":"string"},
            "abilityLevel":{
               "type":"number",
               "optional":true,
               "minimum":"1"
            },
            "targetRule":{"type":"string"},
            "targetRulePov":{
               "type":"string",
               "optional":true
            },
            "casterRule":{"type":"string"},
            "casterRulePov":{
               "type":"string",
               "optional":true
            },
            "responseTarget":{"type":"string"},
            "responseCaster":{
               "type":"string",
               "optional":true
            },
            "responsePhase":{"type":"string"},
            "tagReqs":{
               "type":EffectTagReqsVars.schema,
               "optional":true
            },
            "respondsToSameAbilityDef":{
               "type":"boolean",
               "optional":true
            },
            "responseTargetMustBeAlive":{
               "type":"boolean",
               "optional":true
            },
            "ownerMustBeAlive":{
               "type":"boolean",
               "optional":true
            },
            "effectMustBeIntact":{
               "type":"boolean",
               "optional":true
            },
            "responseCountLimit":{
               "type":"number",
               "optional":true
            },
            "allowSameParent":{
               "type":"boolean",
               "optional":true
            },
            "stats":{
               "type":"array",
               "optional":true,
               "items":{"properties":{
                  "stat":{"type":"string"},
                  "delta":{"type":"number"},
                  "comparator":{"type":"string"},
                  "globally":{
                     "type":"boolean",
                     "optional":true
                  }
               }}
            }
         }
      };
      
      public static var DEBUG_WAIT:Boolean = false;
       
      
      private var ablDef:BattleAbilityDef;
      
      private var ablLevel:int = 1;
      
      private var targetRule:BattleAbilityTargetRule;
      
      private var casterRule:BattleAbilityTargetRule;
      
      private var targetRulePov:BattleAbilityResponseTargetType;
      
      private var casterRulePov:BattleAbilityResponseTargetType;
      
      private var responseTarget:BattleAbilityResponseTargetType;
      
      private var responseCaster:BattleAbilityResponseTargetType;
      
      private var responsePhase:BattleAbilityResponsePhase;
      
      private var tagReqs:EffectTagReqs;
      
      private var operants:Dictionary;
      
      private var respondsToSameAbilityDef:Boolean = false;
      
      private var responseTargetMustBeAlive:Boolean = true;
      
      private var ownerMustBeAlive:Boolean = true;
      
      private var effectMustBeIntact:Boolean = true;
      
      private var responseCountLimit:int = 1;
      
      private var watchStats:Vector.<WatchStat>;
      
      public var allowSameParent:Boolean = false;
      
      public function Op_WaitForActionComplete(param1:EffectDefOp, param2:Effect)
      {
         var _loc3_:Object = null;
         var _loc4_:StatType = null;
         var _loc5_:int = 0;
         var _loc6_:String = null;
         var _loc7_:Boolean = false;
         var _loc8_:WatchStat = null;
         this.targetRulePov = BattleAbilityResponseTargetType.CASTER;
         this.casterRulePov = BattleAbilityResponseTargetType.CASTER;
         this.responseCaster = BattleAbilityResponseTargetType.SELF;
         this.operants = new Dictionary();
         this.watchStats = new Vector.<WatchStat>();
         super(param1,param2);
         this.ablDef = manager.factory.fetchBattleAbilityDef(param1.params.ability);
         this.targetRule = Enum.parse(BattleAbilityTargetRule,param1.params.targetRule) as BattleAbilityTargetRule;
         this.casterRule = Enum.parse(BattleAbilityTargetRule,param1.params.casterRule) as BattleAbilityTargetRule;
         this.responseTarget = Enum.parse(BattleAbilityResponseTargetType,param1.params.responseTarget) as BattleAbilityResponseTargetType;
         this.allowSameParent = BooleanVars.parse(param1.params.allowSameParent,this.allowSameParent);
         if(param1.params.targetRulePov)
         {
            this.targetRulePov = Enum.parse(BattleAbilityResponseTargetType,param1.params.targetRulePov) as BattleAbilityResponseTargetType;
         }
         if(param1.params.casterRulePov)
         {
            this.casterRulePov = Enum.parse(BattleAbilityResponseTargetType,param1.params.casterRulePov) as BattleAbilityResponseTargetType;
         }
         if(param1.params.stats)
         {
            for each(_loc3_ in param1.params.stats)
            {
               _loc4_ = Enum.parse(StatType,_loc3_.stat) as StatType;
               _loc5_ = int(_loc3_.delta);
               _loc6_ = String(_loc3_.comparator);
               _loc7_ = BooleanVars.parse(_loc3_.globally,false);
               _loc8_ = new WatchStat(_loc4_,_loc6_,_loc5_,_loc7_);
               this.watchStats.push(_loc8_);
            }
         }
         if(param1.params.abilityLevel)
         {
            this.ablLevel = NumberVars.parse(param1.params.abilityLevel,1);
            this.ablDef = this.ablDef.getBattleAbilityDefLevel(this.ablLevel) as BattleAbilityDef;
         }
         if(param1.params.responseCaster)
         {
            this.responseCaster = Enum.parse(BattleAbilityResponseTargetType,param1.params.responseCaster) as BattleAbilityResponseTargetType;
         }
         this.responsePhase = Enum.parse(BattleAbilityResponsePhase,param1.params.responsePhase) as BattleAbilityResponsePhase;
         this.respondsToSameAbilityDef = BooleanVars.parse(param1.params.respondsToSameAbilityDef,this.respondsToSameAbilityDef);
         this.responseCountLimit = NumberVars.parse(param1.params.responseCountLimit,this.responseCountLimit);
         this.responseTargetMustBeAlive = BooleanVars.parse(param1.params.responseTargetMustBeAlive,this.responseTargetMustBeAlive);
         this.ownerMustBeAlive = BooleanVars.parse(param1.params.ownerMustBeAlive,this.ownerMustBeAlive);
         this.effectMustBeIntact = BooleanVars.parse(param1.params.effectMustBeIntact,this.effectMustBeIntact);
         if(param1.params.tagReqs)
         {
            this.tagReqs = new EffectTagReqsVars(param1.params.tagReqs,manager.logger);
         }
      }
      
      private static function captureTagSet(param1:Array, param2:Dictionary) : void
      {
         var _loc3_:String = null;
         var _loc4_:EffectTag = null;
         for each(_loc3_ in param1)
         {
            _loc4_ = Enum.parse(EffectTag,_loc3_) as EffectTag;
            param2[_loc4_] = _loc4_;
         }
      }
      
      private static function addRandomTarget(param1:IBattleEntity, param2:Vector.<IBattleEntity>, param3:BattleAbility, param4:Boolean, param5:ILogger) : void
      {
         var _loc7_:IBattleEntity = null;
         var _loc8_:BattleAbilityValidation = null;
         var _loc9_:Rng = null;
         var _loc10_:int = 0;
         var _loc11_:IBattleEntity = null;
         var _loc6_:Vector.<IBattleEntity> = new Vector.<IBattleEntity>();
         for each(_loc7_ in param1.board.entities)
         {
            if(param4 && !_loc7_.alive)
            {
               if(DEBUG_WAIT)
               {
                  param5.debug("--->> Op_WaitForActionComplete.addRandomTarget " + param3 + " target=" + _loc7_ + " SKIP target not alive");
               }
            }
            else if(!param3.def.checkTargetStatRanges(_loc7_.stats))
            {
               if(DEBUG_WAIT)
               {
                  param5.debug("--->> Op_WaitForActionComplete.addRandomTarget " + param3 + " target=" + _loc7_ + " SKIP target stat ranges");
               }
            }
            else
            {
               _loc8_ = BattleAbilityValidation.validate(param3.def,param1,null,_loc7_,null,false,true,true);
               if(_loc8_ != BattleAbilityValidation.OK)
               {
                  if(DEBUG_WAIT)
                  {
                     param5.debug("--->> Op_WaitForActionComplete.addRandomTarget " + param3 + " target=" + _loc7_ + " SKIP validation " + _loc8_);
                  }
               }
               else
               {
                  _loc6_.push(_loc7_);
               }
            }
         }
         if(_loc6_.length > 0)
         {
            _loc9_ = param3.manager.rng;
            _loc10_ = _loc9_.nextMax(_loc6_.length - 1);
            _loc11_ = _loc6_[_loc10_];
            param2.push(_loc11_);
         }
      }
      
      public static function checkTargetValidity(param1:IBattleEntity, param2:BattleAbilityDef, param3:Boolean, param4:ILogger) : Boolean
      {
         if(param3 && !param1.alive)
         {
            return false;
         }
         if(!param2.checkTargetStatRanges(param1.stats))
         {
            return false;
         }
         if(!param2.checkTargetExecutionConditions(param1,param4,true))
         {
            return false;
         }
         return true;
      }
      
      private static function addTargets(param1:Vector.<IBattleEntity>, param2:BattleAbility, param3:IBattleEntity, param4:Boolean, param5:ILogger) : void
      {
         var _loc6_:IBattleEntity = null;
         var _loc8_:Boolean = false;
         var _loc7_:Vector.<IBattleEntity> = new Vector.<IBattleEntity>();
         var _loc9_:BattleAbilityDef = param2.def as BattleAbilityDef;
         if(_loc9_.targetRule == BattleAbilityTargetRule.ALL_ALLIES)
         {
            for each(_loc6_ in param3.board.entities)
            {
               if(_loc6_ != param3 && _loc6_.team == param3.team)
               {
                  if(checkTargetValidity(_loc6_,_loc9_,param4,param5))
                  {
                     if(_loc9_.aiTargetRule == BattleAbilityAiTargetRuleType.TILE_MAX_ADJACENT_ENEMY)
                     {
                        if(!BattleBoard_SpatialUtil.checkAdjacentEnemies(_loc6_,_loc7_,true))
                        {
                           continue;
                        }
                     }
                     param1.push(_loc6_);
                  }
               }
            }
         }
         else if(_loc9_.targetRule == BattleAbilityTargetRule.ALL_ENEMIES)
         {
            for each(_loc6_ in param3.board.entities)
            {
               if(_loc6_ != param3 && _loc6_.team != param3.team)
               {
                  if(checkTargetValidity(_loc6_,_loc9_,param4,param5))
                  {
                     if(_loc9_.aiTargetRule == BattleAbilityAiTargetRuleType.TILE_MAX_ADJACENT_ENEMY)
                     {
                        if(!BattleBoard_SpatialUtil.checkAdjacentEnemies(_loc6_,_loc7_,true))
                        {
                           continue;
                        }
                     }
                     param1.push(_loc6_);
                  }
               }
            }
         }
         else if(!param4 || param3.alive)
         {
            param1.push(param3);
         }
      }
      
      override public function apply() : void
      {
         if(this.responsePhase == BattleAbilityResponsePhase.PRE_COMPLETE)
         {
            manager.addEventListener(BattleAbilityEvent.ABILITY_PRE_COMPLETE,this.abilityCompleteHandler);
         }
         else if(this.responsePhase == BattleAbilityResponsePhase.POST_COMPLETE)
         {
            manager.addEventListener(BattleAbilityEvent.ABILITY_POST_COMPLETE,this.abilityCompleteHandler);
         }
         manager.addEventListener(BattleAbilityEvent.ABILITY_AND_CHILDREN_COMPLETE,this.abilityAndChildrenCompleteHandler);
      }
      
      override public function remove() : void
      {
         if(manager)
         {
            manager.removeEventListener(BattleAbilityEvent.ABILITY_PRE_COMPLETE,this.abilityCompleteHandler);
            manager.removeEventListener(BattleAbilityEvent.ABILITY_POST_COMPLETE,this.abilityCompleteHandler);
            manager.removeEventListener(BattleAbilityEvent.ABILITY_AND_CHILDREN_COMPLETE,this.abilityAndChildrenCompleteHandler);
         }
      }
      
      private function checkParents(param1:IBattleAbility) : Boolean
      {
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         if(this.allowSameParent)
         {
            return true;
         }
         var _loc2_:IBattleAbility = param1;
         var _loc3_:IBattleAbilityDef = effect.ability.def.root as IBattleAbilityDef;
         var _loc4_:IBattleAbilityDef = this.ablDef.root as IBattleAbilityDef;
         while(_loc2_)
         {
            if(_loc2_ == effect.ability)
            {
               return false;
            }
            if(!this.respondsToSameAbilityDef)
            {
               if(_loc2_.def.root == _loc3_)
               {
                  return false;
               }
               if(_loc2_.def.root == _loc4_)
               {
                  if(_loc2_.caster == caster)
                  {
                     return false;
                  }
               }
            }
            _loc5_ = _loc2_.getId;
            _loc6_ = _loc5_ in this.operants ? int(this.operants[_loc5_]) : 0;
            if(this.responseCountLimit > 0 && _loc6_ >= this.responseCountLimit)
            {
               return false;
            }
            _loc2_ = _loc2_.parent;
         }
         return true;
      }
      
      protected function abilityAndChildrenCompleteHandler(param1:BattleAbilityEvent) : void
      {
         if(this.responsePhase == BattleAbilityResponsePhase.POST_CHILDREN_COMPLETE)
         {
         }
         var _loc2_:int = !!param1.ability ? param1.ability.getId : 0;
         delete this.operants[_loc2_];
      }
      
      private function checkWatchStats(param1:BattleAbility) : Boolean
      {
         var _loc2_:WatchStat = null;
         var _loc3_:int = 0;
         var _loc4_:Effect = null;
         for each(_loc2_ in this.watchStats)
         {
            _loc3_ = 0;
            for each(_loc4_ in param1.effects)
            {
               if(_loc2_.globally || _loc4_.target == this.target)
               {
                  _loc3_ += _loc4_.getAnnotatedStatChange(_loc2_.type);
               }
            }
            if(_loc2_.check(_loc3_))
            {
               return true;
            }
         }
         return this.watchStats.length == 0;
      }
      
      private function determineTargetRulePov(param1:BattleAbilityResponseTargetType) : IBattleEntity
      {
         var _loc2_:IBattleEntity = null;
         switch(param1)
         {
            case BattleAbilityResponseTargetType.CASTER:
               _loc2_ = caster;
               break;
            case BattleAbilityResponseTargetType.TARGET:
               _loc2_ = target;
               break;
            default:
               throw new ArgumentError("Invalid pov [" + param1 + "]");
         }
         return _loc2_;
      }
      
      private function determineResponseCasterEntity(param1:Effect) : IBattleEntity
      {
         switch(this.responseCaster)
         {
            case BattleAbilityResponseTargetType.SELF:
            case BattleAbilityResponseTargetType.ORIGIN_CASTER:
               return caster;
            case BattleAbilityResponseTargetType.CASTER:
            case BattleAbilityResponseTargetType.TRIGGER_CASTER:
               return param1.ability.caster;
            case BattleAbilityResponseTargetType.TARGET:
            case BattleAbilityResponseTargetType.TRIGGER_TARGET:
               return param1.target;
            case BattleAbilityResponseTargetType.ORIGIN_TARGET:
               return target;
            default:
               logger.error("Unsupported responseCaster " + this.responseCaster + " for " + this);
               return null;
         }
      }
      
      private function determineResponseTargetEntities(param1:BattleAbility, param2:Effect) : Vector.<IBattleEntity>
      {
         var _loc3_:BattleEntity = null;
         var _loc4_:Vector.<IBattleEntity> = new Vector.<IBattleEntity>();
         switch(this.responseTarget)
         {
            case BattleAbilityResponseTargetType.SELF:
            case BattleAbilityResponseTargetType.ORIGIN_CASTER:
               addTargets(_loc4_,param1,caster,this.responseTargetMustBeAlive,logger);
               break;
            case BattleAbilityResponseTargetType.CASTER:
            case BattleAbilityResponseTargetType.TRIGGER_CASTER:
               addTargets(_loc4_,param1,param2.ability.caster,this.responseTargetMustBeAlive,logger);
               break;
            case BattleAbilityResponseTargetType.TARGET:
            case BattleAbilityResponseTargetType.TRIGGER_TARGET:
               addTargets(_loc4_,param1,param2.target,this.responseTargetMustBeAlive,logger);
               break;
            case BattleAbilityResponseTargetType.ORIGIN_TARGET:
               addTargets(_loc4_,param1,target,this.responseTargetMustBeAlive,logger);
               break;
            case BattleAbilityResponseTargetType.RANDOM:
               addRandomTarget(param1.caster,_loc4_,param1,this.responseTargetMustBeAlive,logger);
               break;
            default:
               logger.error("Unsupported responseTarget " + this.responseTarget + " for " + this);
         }
         return _loc4_;
      }
      
      protected function abilityCompleteHandler(param1:BattleAbilityEvent) : void
      {
         var _loc6_:Effect = null;
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         var _loc9_:IBattleEntity = null;
         var _loc10_:BattleAbility = null;
         var _loc11_:BattleEntity = null;
         var _loc12_:Vector.<IBattleEntity> = null;
         var _loc2_:BattleAbility = param1.ability as BattleAbility;
         if(effect.ability.fake || manager.faking || _loc2_.fake)
         {
            return;
         }
         if(DEBUG_WAIT)
         {
            logger.debug("--->> Op_WaitForActionComplete " + this + " SAW  " + _loc2_);
         }
         if(_loc2_.def.root == effect.ability.def.root)
         {
            if(DEBUG_WAIT)
            {
               logger.debug("--->> Op_WaitForActionComplete " + this + " RETURN roots");
            }
            return;
         }
         if(_loc2_.finalCompleted)
         {
            if(DEBUG_WAIT)
            {
               logger.debug("--->> Op_WaitForActionComplete " + this + " CONCERNED other.finalCompleted");
            }
         }
         if(!this.checkWatchStats(_loc2_))
         {
            return;
         }
         var _loc3_:IBattleAbility = _loc2_.root;
         if(!this.checkParents(_loc2_))
         {
            if(DEBUG_WAIT)
            {
               logger.debug("--->> Op_WaitForActionComplete " + this + " RETURN !checkParents");
               this.checkParents(_loc2_);
            }
            return;
         }
         var _loc4_:IBattleEntity = this.determineTargetRulePov(this.casterRulePov);
         if(DEBUG_WAIT)
         {
            logger.debug("--->> Op_WaitForActionComplete casterRulePovEntity " + this.casterRulePov + " " + _loc4_);
         }
         if(!this.casterRule.isValid(_loc4_,_loc4_.rect,_loc2_.caster,null,true,null,false))
         {
            if(DEBUG_WAIT)
            {
               if(ability.def.id == "abl_track")
               {
                  this.casterRule.isValid(_loc4_,_loc4_.rect,_loc2_.caster,null,true,null,false);
               }
               logger.debug("--->> Op_WaitForActionComplete " + this + " RETURN !casterRule.isValid");
            }
            return;
         }
         if(this.ownerMustBeAlive && (!caster.alive || !target.alive))
         {
            if(DEBUG_WAIT)
            {
               logger.debug("--->> Op_WaitForActionComplete " + this + " RETURN ownerMustBeAlive");
            }
            return;
         }
         if(this.effectMustBeIntact && effect.removed)
         {
            if(DEBUG_WAIT)
            {
               logger.debug("--->> Op_WaitForActionComplete " + this + " RETURN effectMustBeIntact");
            }
            return;
         }
         _loc2_.blockComplete();
         var _loc5_:IBattleEntity = this.determineTargetRulePov(this.targetRulePov);
         if(DEBUG_WAIT)
         {
            logger.debug("--->> Op_WaitForActionComplete targetRulePovEntity " + this.targetRulePov + " " + _loc5_);
         }
         for each(_loc6_ in _loc2_.effects)
         {
            if(!this.targetRule.isValid(_loc5_,_loc5_.rect,_loc6_.target,_loc6_.tile,false,null,false))
            {
               if(DEBUG_WAIT)
               {
                  logger.debug("--->> Op_WaitForActionComplete " + this + " SKIP " + _loc6_ + " !targetRule.isValid");
               }
            }
            else if(Boolean(this.tagReqs) && !this.tagReqs.checkTags(_loc6_,logger))
            {
               if(DEBUG_WAIT)
               {
                  logger.debug("--->> Op_WaitForActionComplete " + this + " SKIP " + _loc6_ + " !tagReqs.checkTags req=" + this.tagReqs + " abletags=" + _loc6_.tagsToString());
               }
            }
            else
            {
               _loc7_ = !!_loc3_ ? _loc3_.getId : 0;
               _loc8_ = _loc7_ in this.operants ? int(this.operants[_loc7_]) : 0;
               this.operants[_loc7_] = ++_loc8_;
               _loc9_ = this.determineResponseCasterEntity(_loc6_);
               _loc10_ = new BattleAbility(_loc9_,this.ablDef,manager);
               _loc12_ = this.determineResponseTargetEntities(_loc10_,_loc6_);
               if(_loc12_.length == 0)
               {
                  if(DEBUG_WAIT)
                  {
                     logger.debug("--->> Op_WaitForActionComplete " + this + " SKIP " + _loc6_ + " no valid targets found for responseTarget=" + this.responseTarget);
                  }
               }
               else
               {
                  for each(_loc11_ in _loc12_)
                  {
                     _loc10_.targetSet.addTarget(_loc11_);
                  }
                  logger.info("--->> Op_WaitForActionComplete " + this + "  RESPONDED TO " + _loc2_ + "/" + _loc6_ + " WITH " + _loc10_);
                  _loc2_.addChildAbility(_loc10_);
                  effect.handleOpUsed(this);
               }
            }
         }
         _loc2_.unblockComplete();
      }
   }
}

import engine.stat.def.StatType;

class WatchStat
{
    
   
   public var type:StatType;
   
   public var comparator:String;
   
   public var delta:int;
   
   public var globally:Boolean = false;
   
   public function WatchStat(param1:StatType, param2:String, param3:int, param4:Boolean)
   {
      super();
      this.type = param1;
      this.comparator = param2;
      this.delta = param3;
      this.globally = param4;
   }
   
   public function check(param1:int) : Boolean
   {
      switch(this.comparator)
      {
         case "=":
            return param1 == this.delta;
         case "<":
            return param1 < this.delta;
         case "<=":
            return param1 <= this.delta;
         case ">":
            return param1 > this.delta;
         case ">=":
            return param1 >= this.delta;
         case "!=":
         case "<>":
            return param1 != this.delta;
         default:
            return false;
      }
   }
}
