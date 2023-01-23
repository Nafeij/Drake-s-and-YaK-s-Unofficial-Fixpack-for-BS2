package engine.battle.ability.effect.def
{
   import engine.battle.ability.def.BattleAbilityResponseTargetType;
   import engine.battle.ability.effect.model.EffectRemoveReason;
   import engine.core.logging.ILogger;
   import engine.core.util.Enum;
   import engine.def.BooleanVars;
   import engine.def.EngineJsonDef;
   import flash.utils.Dictionary;
   
   public class EffectDefPersistenceVars extends EffectDefPersistence
   {
      
      public static const schema:Object = {
         "name":"EffectDefPersistenceVars",
         "properties":{
            "numUses":{
               "type":"number",
               "minimum":"0"
            },
            "casterDuration":{
               "type":"number",
               "minimum":"0"
            },
            "targetDuration":{
               "type":"number",
               "minimum":"0"
            },
            "turnChangedDuration":{
               "type":"number",
               "minimum":"0",
               "optional":true
            },
            "stack":{"type":"string"},
            "linkedEffectName":{
               "type":"string",
               "optional":true
            },
            "durationOnTurnStart":{
               "type":"boolean",
               "optional":true
            },
            "expireOnDeath":{
               "type":"boolean",
               "optional":true
            },
            "expireOnDeathCaster":{
               "type":"boolean",
               "optional":true
            },
            "expireOnDeathTarget":{
               "type":"boolean",
               "optional":true
            },
            "expireAbility":{
               "type":"string",
               "optional":true
            },
            "expireAbilityResponseCaster":{
               "type":"string",
               "optional":true
            },
            "expireAbilityResponseTarget":{
               "type":"string",
               "optional":true
            },
            "expireAbilityResponseCasterRequireAlive":{
               "type":"boolean",
               "optional":true
            },
            "expireAbilityResponseTargetRequireAlive":{
               "type":"boolean",
               "optional":true
            },
            "expireAbilityReasons":{
               "type":"array",
               "items":"string",
               "optional":true
            }
         }
      };
       
      
      public function EffectDefPersistenceVars(param1:Object, param2:ILogger)
      {
         var _loc3_:String = null;
         var _loc4_:EffectRemoveReason = null;
         super();
         EngineJsonDef.validateThrow(param1,schema,param2);
         this.numUses = param1.numUses;
         this.casterDuration = param1.casterDuration;
         this.targetDuration = param1.targetDuration;
         this.turnChangedDuration = param1.turnChangedDuration;
         this.stack = Enum.parse(EffectStackRule,param1.stack) as EffectStackRule;
         this.expireOnDeath = BooleanVars.parse(param1.expireOnDeath,expireOnDeath);
         this.expireOnDeathCaster = BooleanVars.parse(param1.expireOnDeathCaster,expireOnDeathCaster);
         this.expireOnDeathTarget = BooleanVars.parse(param1.expireOnDeathTarget,expireOnDeathTarget);
         this.expireAbility = param1.expireAbility;
         if(param1.expireAbilityResponseCaster)
         {
            expireAbilityResponseCaster = Enum.parse(BattleAbilityResponseTargetType,param1.expireAbilityResponseCaster) as BattleAbilityResponseTargetType;
         }
         if(param1.expireAbilityResponseTarget)
         {
            expireAbilityResponseTarget = Enum.parse(BattleAbilityResponseTargetType,param1.expireAbilityResponseTarget) as BattleAbilityResponseTargetType;
         }
         this.expireAbilityResponseCasterRequireAlive = BooleanVars.parse(param1.expireAbilityResponseCasterRequireAlive,expireAbilityResponseCasterRequireAlive);
         this.expireAbilityResponseTargetRequireAlive = BooleanVars.parse(param1.expireAbilityResponseTargetRequireAlive,expireAbilityResponseTargetRequireAlive);
         expireAbilityReasonsArray = param1.expireAbilityReasons;
         if(Boolean(expireAbilityReasonsArray) && Boolean(expireAbilityReasonsArray.length))
         {
            expireAbilityReasons = new Dictionary();
            for each(_loc3_ in expireAbilityReasonsArray)
            {
               _loc4_ = Enum.parse(EffectRemoveReason,_loc3_) as EffectRemoveReason;
               expireAbilityReasons[_loc4_] = true;
            }
         }
         this.durationOnTurnStart = BooleanVars.parse(param1.durationOnTurnStart,durationOnTurnStart);
         if(param1.linkedEffectName != undefined)
         {
            this.linkedEffectName = param1.linkedEffectName;
         }
      }
      
      public static function save(param1:EffectDefPersistence) : Object
      {
         var _loc2_:Object = {
            "numUses":param1.numUses,
            "casterDuration":param1.casterDuration,
            "targetDuration":param1.targetDuration,
            "stack":param1.stack.name
         };
         if(param1.linkedEffectName)
         {
            _loc2_.linkedEffectName = param1.linkedEffectName;
         }
         if(!param1.durationOnTurnStart)
         {
            _loc2_.durationOnTurnStart = param1.durationOnTurnStart;
         }
         if(param1.expireOnDeath)
         {
            _loc2_.expireOnDeath = param1.expireOnDeath;
         }
         if(param1.expireOnDeathCaster)
         {
            _loc2_.expireOnDeathCaster = param1.expireOnDeathCaster;
         }
         if(param1.expireOnDeathTarget)
         {
            _loc2_.expireOnDeathTarget = param1.expireOnDeathTarget;
         }
         if(param1.expireAbility)
         {
            _loc2_.expireAbility = param1.expireAbility;
         }
         return _loc2_;
      }
   }
}
