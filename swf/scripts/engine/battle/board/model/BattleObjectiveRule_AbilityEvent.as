package engine.battle.board.model
{
   import engine.battle.ability.def.BattleAbilityTargetRule;
   import engine.battle.ability.effect.model.Effect;
   import engine.battle.ability.effect.model.PersistedEffects;
   import engine.battle.ability.model.BattleAbility;
   import engine.battle.ability.model.BattleAbilityEvent;
   import engine.battle.ability.model.BattleAbilityManager;
   import engine.battle.ability.model.BattleAbilityValidation;
   import engine.battle.ability.model.IBattleAbility;
   import engine.core.logging.ILogger;
   import engine.stat.def.StatRange;
   
   public class BattleObjectiveRule_AbilityEvent extends BattleObjectiveRule
   {
       
      
      public var subdef:Def_AbilityEvent;
      
      public function BattleObjectiveRule_AbilityEvent(param1:BattleObjective, param2:BattleObjectiveRuleDef)
      {
         super(param1,param2,_secret);
         this.subdef = param2.subdef as Def_AbilityEvent;
         manager.addEventListener(this.subdef.phase,this.abilityCompleteHandler);
      }
      
      public static function fromJson(param1:Object, param2:ILogger) : Object
      {
         return new Def_AbilityEvent().fromJson(param1,param2);
      }
      
      private static function checkAbilityCompleteObjective(param1:BattleAbility, param2:Effect, param3:Def_AbilityEvent) : Boolean
      {
         var _loc6_:Effect = null;
         var _loc7_:Boolean = false;
         var _loc8_:Object = null;
         var _loc9_:IBattleAbility = null;
         var _loc10_:int = 0;
         var _loc11_:StatRange = null;
         var _loc12_:int = 0;
         var _loc13_:int = 0;
         var _loc14_:int = 0;
         var _loc15_:IBattleEntity = null;
         var _loc16_:int = 0;
         var _loc17_:IBattleAbility = null;
         var _loc18_:BattleAbilityValidation = null;
         var _loc19_:PersistedEffects = null;
         if(!param1 || !param3)
         {
            return false;
         }
         var _loc4_:BattleAbilityManager = param1.manager as BattleAbilityManager;
         var _loc5_:ILogger = _loc4_.logger;
         if(param1.fake || _loc4_.faking)
         {
            return false;
         }
         if(Boolean(param3.abilities_) && !param3.abilities_.hasString(param1.def.id))
         {
            return false;
         }
         if(param3.minimumTargets)
         {
            _loc14_ = int(param1.targetSet.targets.length);
            if(param3.targetRule)
            {
               for each(_loc15_ in param1.targetSet.targets)
               {
                  if(!(param3.targetRule == BattleAbilityTargetRule.ENEMY && Boolean(_loc15_.isEnemy)))
                  {
                     if(!(param3.targetRule == BattleAbilityTargetRule.FRIENDLY && Boolean(_loc15_.isPlayer)))
                     {
                        if(!(param3.targetRule == BattleAbilityTargetRule.FRIENDLY_OTHER && Boolean(_loc15_.isPlayer) && _loc15_ != param1.caster))
                        {
                           _loc14_--;
                        }
                     }
                  }
               }
            }
            if(_loc14_ < param3.minimumTargets)
            {
               return false;
            }
         }
         if(param3.minimumChildren)
         {
            if(param1.children.length < param3.minimumChildren)
            {
               return false;
            }
         }
         if(param3.otherAbilitiesAny_)
         {
            _loc7_ = false;
            for(_loc8_ in _loc4_.incompleteAbilities)
            {
               _loc9_ = _loc8_ as IBattleAbility;
               if(param3.otherAbilitiesAny_.hasString(_loc9_.def.id))
               {
                  _loc7_ = true;
                  break;
               }
            }
            if(!_loc7_)
            {
               return false;
            }
         }
         if(param3.otherAbilitiesNone_)
         {
            for(_loc8_ in _loc4_.incompleteAbilities)
            {
               _loc9_ = _loc8_ as IBattleAbility;
               if(param3.otherAbilitiesNone_.hasString(_loc9_.def.id))
               {
                  return false;
               }
            }
         }
         if(param3.parentDepthMinimum > 0 || param3.parentDepthMaximum > 0)
         {
            _loc16_ = 0;
            _loc17_ = param1.parent;
            while(_loc17_)
            {
               _loc16_++;
               _loc17_ = _loc17_.parent;
            }
            _loc5_.info("AABBBBEEEE " + param1 + " depth=" + _loc16_ + " of min/max " + param3.parentDepthMinimum + "/" + param3.parentDepthMaximum);
            if(param3.parentDepthMinimum > 0 && _loc16_ < param3.parentDepthMinimum)
            {
               return false;
            }
            if(param3.parentDepthMaximum > 0 && _loc16_ > param3.parentDepthMaximum)
            {
               return false;
            }
         }
         if(param3.tags_ability)
         {
            if(!param3.tags_ability.checkTags(param1,_loc5_))
            {
               return false;
            }
         }
         if(param3.annotatedStats_ability)
         {
            _loc10_ = param3.annotatedStats_ability.numStatRanges;
            _loc12_ = 0;
            while(true)
            {
               if(_loc12_ < _loc10_)
               {
                  _loc7_ = false;
                  _loc11_ = param3.annotatedStats_ability.getStatRangeByIndex(_loc12_);
                  for each(_loc6_ in param1.effects)
                  {
                     _loc13_ = _loc6_.getAnnotatedStatChange(_loc11_.type);
                     if(_loc13_ >= _loc11_.min && _loc13_ <= _loc11_.max)
                     {
                        _loc7_ = true;
                        break;
                     }
                  }
                  continue;
               }
            }
            return false;
         }
         if(param3.tags_effect)
         {
            if(!param3.tags_effect.checkTags(param2,_loc5_))
            {
               return false;
            }
         }
         if(param3.annotatedStats_effect)
         {
            if(!param2)
            {
               return false;
            }
            _loc10_ = param3.annotatedStats_effect.numStatRanges;
            _loc12_ = 0;
            while(_loc12_ < _loc10_)
            {
               _loc7_ = false;
               _loc11_ = param3.annotatedStats_effect.getStatRangeByIndex(_loc12_);
               _loc13_ = param2.getAnnotatedStatChange(_loc11_.type);
               if(_loc13_ >= _loc11_.min && _loc13_ <= _loc11_.max)
               {
                  _loc7_ = true;
                  break;
               }
               _loc12_++;
            }
            if(!_loc7_)
            {
               return false;
            }
         }
         if(param3.conditions)
         {
            _loc15_ = !!param2 ? param2.target : null;
            _loc18_ = param3.conditions.checkExecutionConditions(param1,null,param1.caster,_loc15_,_loc5_,true);
            if(!_loc18_ || !_loc18_.ok)
            {
               _loc5_.info("BattleObjective_AbilityComplete SKIP validation " + _loc18_ + " abl " + param1);
               return false;
            }
         }
         if(param3.persisted_caster)
         {
            _loc19_ = param1.caster.effects as PersistedEffects;
            if(!param3.persisted_caster.checkPersistedRules(_loc19_))
            {
               return false;
            }
         }
         if(param3.parent)
         {
            return checkAbilityCompleteObjective(param1.parent as BattleAbility,null,param3.parent);
         }
         return true;
      }
      
      override protected function handleComplete() : void
      {
         manager.removeEventListener(this.subdef.phase,this.abilityCompleteHandler);
      }
      
      override public function cleanup() : void
      {
         manager.removeEventListener(this.subdef.phase,this.abilityCompleteHandler);
         super.cleanup();
      }
      
      private function abilityCompleteHandler(param1:BattleAbilityEvent) : void
      {
         if(complete)
         {
            return;
         }
         var _loc2_:BattleAbility = param1.ability as BattleAbility;
         if(_loc2_.fake || manager.faking)
         {
            return;
         }
         var _loc3_:Effect = param1.effect as Effect;
         if(checkAbilityCompleteObjective(_loc2_,_loc3_,this.subdef))
         {
            complete = true;
         }
      }
   }
}

import engine.battle.ability.def.AbilityExecutionConditions;
import engine.battle.ability.def.BattleAbilityTargetRule;
import engine.battle.ability.effect.def.EffectTagReqs;
import engine.battle.ability.effect.def.EffectTagReqsVars;
import engine.battle.ability.model.BattleAbilityEvent;
import engine.battle.board.model.PersistedRules;
import engine.core.logging.ILogger;
import engine.core.util.Enum;
import engine.def.EngineJsonDef;
import engine.stat.def.StatRangeVars;
import engine.stat.def.StatRanges;

class Def_AbilityEvent
{
   
   public static const schema_0:Object = {
      "name":"BattleObjective_AbilityEvent_0",
      "type":"object",
      "properties":{
         "phase":{
            "type":"string",
            "optional":true
         },
         "abilities":{"type":"string"},
         "minimumTargets":{
            "type":"number",
            "optional":true
         },
         "minimumChildren":{
            "type":"number",
            "optional":true
         },
         "targetRule":{
            "type":"string",
            "optional":true
         },
         "otherAbilitiesAny":{
            "type":"string",
            "optional":true
         },
         "otherAbilitiesNone":{
            "type":"string",
            "optional":true
         },
         "parentDepthMinimum":{
            "type":"number",
            "optional":true
         },
         "parentDepthMaximum":{
            "type":"number",
            "optional":true
         },
         "annotatedStats_ability":{
            "type":"array",
            "items":StatRangeVars.schema,
            "optional":true
         },
         "tags_ability":{
            "type":EffectTagReqsVars.schema,
            "optional":true
         },
         "annotatedStats_effect":{
            "type":"array",
            "items":StatRangeVars.schema,
            "optional":true
         },
         "tags_effect":{
            "type":EffectTagReqsVars.schema,
            "optional":true
         },
         "persisted_caster":{
            "type":PersistedRules.schema,
            "optional":true
         },
         "conditions":{
            "type":AbilityExecutionConditions.schema,
            "optional":true
         },
         "parent":{
            "type":"object",
            "optional":true,
            "ignore":true
         }
      }
   };
   
   public static const schema:Object = {
      "name":"BattleObjective_AbilityEvent",
      "type":"object",
      "properties":{
         "phase":{
            "type":"string",
            "optional":true
         },
         "abilities":{"type":"string"},
         "minimumTargets":{
            "type":"number",
            "optional":true
         },
         "minimumChildren":{
            "type":"number",
            "optional":true
         },
         "targetRule":{
            "type":"string",
            "optional":true
         },
         "otherAbilitiesAny":{
            "type":"string",
            "optional":true
         },
         "otherAbilitiesNone":{
            "type":"string",
            "optional":true
         },
         "parentDepthMinimum":{
            "type":"number",
            "optional":true
         },
         "parentDepthMaximum":{
            "type":"number",
            "optional":true
         },
         "annotatedStats_ability":{
            "type":"array",
            "items":StatRangeVars.schema,
            "optional":true
         },
         "tags_ability":{
            "type":EffectTagReqsVars.schema,
            "optional":true
         },
         "annotatedStats_effect":{
            "type":"array",
            "items":StatRangeVars.schema,
            "optional":true
         },
         "tags_effect":{
            "type":EffectTagReqsVars.schema,
            "optional":true
         },
         "persisted_caster":{
            "type":PersistedRules.schema,
            "optional":true
         },
         "conditions":{
            "type":AbilityExecutionConditions.schema,
            "optional":true
         },
         "parent":{
            "type":Def_AbilityEvent.schema_0,
            "optional":true
         }
      }
   };
    
   
   public var phase:String = "BattleAbilityEvent.ABILITY_POST_COMPLETE";
   
   public var abilities_:StringSet;
   
   public var minimumTargets:int = 1;
   
   public var minimumChildren:int;
   
   public var targetRule:BattleAbilityTargetRule;
   
   public var otherAbilitiesAny_:StringSet;
   
   public var otherAbilitiesNone_:StringSet;
   
   public var parentDepthMinimum:int;
   
   public var parentDepthMaximum:int;
   
   public var annotatedStats_ability:StatRanges;
   
   public var tags_ability:EffectTagReqs;
   
   public var annotatedStats_effect:StatRanges;
   
   public var tags_effect:EffectTagReqs;
   
   public var parent:Def_AbilityEvent;
   
   public var conditions:AbilityExecutionConditions;
   
   public var persisted_caster:PersistedRules;
   
   public function Def_AbilityEvent()
   {
      super();
   }
   
   private function translatePhase(param1:String) : String
   {
      if(!param1)
      {
         return null;
      }
      var _loc2_:String = "BattleAbilityEvent." + param1;
      if(_loc2_ != BattleAbilityEvent[param1])
      {
         throw new ArgumentError("Invalid BattleAbilityEvent: " + param1);
      }
      return _loc2_;
   }
   
   public function fromJson(param1:Object, param2:ILogger) : Def_AbilityEvent
   {
      var _loc3_:Object = null;
      EngineJsonDef.validateThrow(param1,schema,param2);
      if(param1.abilities)
      {
         this.abilities_ = new StringSet(param1.abilities);
      }
      if(param1.persisted_caster)
      {
         this.persisted_caster = new PersistedRules().fromJson(param1.persisted_caster,param2);
      }
      if(param1.otherAbilitiesAny)
      {
         this.otherAbilitiesAny_ = new StringSet(param1.otherAbilitiesAny);
      }
      if(param1.otherAbilitiesNone)
      {
         this.otherAbilitiesNone_ = new StringSet(param1.otherAbilitiesNone);
      }
      this.parentDepthMinimum = param1.parentDepthMinimum;
      this.parentDepthMaximum = param1.parentDepthMaximum;
      if(param1.phase)
      {
         this.phase = this.translatePhase(param1.phase);
      }
      if(param1.targetRule)
      {
         this.targetRule = Enum.parse(BattleAbilityTargetRule,param1.targetRule) as BattleAbilityTargetRule;
      }
      if(param1.conditions)
      {
         this.conditions = new AbilityExecutionConditions().fromJson(param1.conditions,param2);
      }
      if(param1.minimumTargets != undefined)
      {
         this.minimumTargets = param1.minimumTargets;
      }
      this.minimumChildren = param1.minimumChildren;
      if(param1.annotatedStats_ability)
      {
         this.annotatedStats_ability = new StatRanges();
         for each(_loc3_ in param1.annotatedStats_ability)
         {
            StatRangeVars.parseInto(this.annotatedStats_ability,_loc3_,param2);
         }
      }
      if(param1.tags_ability)
      {
         this.tags_ability = new EffectTagReqsVars(param1.tags_ability,param2);
      }
      if(param1.annotatedStats_effect)
      {
         this.annotatedStats_effect = new StatRanges();
         for each(_loc3_ in param1.annotatedStats_effect)
         {
            StatRangeVars.parseInto(this.annotatedStats_effect,_loc3_,param2);
         }
      }
      if(param1.tags_effect)
      {
         this.tags_effect = new EffectTagReqsVars(param1.tags_effect,param2);
      }
      if(param1.parent)
      {
         this.parent = new Def_AbilityEvent().fromJson(param1.parent,param2);
      }
      return this;
   }
}

import engine.core.util.ArrayUtil;
import flash.utils.Dictionary;

class StringSet
{
    
   
   private var list:Array;
   
   private var dict:Dictionary;
   
   public function StringSet(param1:*)
   {
      super();
      if(param1)
      {
         if(param1 is Array)
         {
            this.list = (param1 as Array).concat();
         }
         else
         {
            if(!(param1 is String))
            {
               throw new ArgumentError("String set doesn\'t know what to do with " + param1);
            }
            this.list = ArrayUtil.stringToArray(param1 as String);
            this.dict = ArrayUtil.makeArrayDict(this.list);
         }
         return;
      }
      throw new ArgumentError("Null");
   }
   
   public function hasString(param1:String) : Boolean
   {
      return Boolean(this.dict) && Boolean(this.dict[param1]);
   }
}
