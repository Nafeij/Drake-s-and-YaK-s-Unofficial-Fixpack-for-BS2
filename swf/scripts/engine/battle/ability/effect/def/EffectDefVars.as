package engine.battle.ability.effect.def
{
   import engine.battle.ability.def.AbilityExecutionConditions;
   import engine.battle.ability.def.BattleAbilityDef;
   import engine.battle.ability.effect.model.EffectTag;
   import engine.battle.ability.effect.op.def.EffectDefOp;
   import engine.battle.ability.effect.op.def.EffectDefOpVars;
   import engine.battle.ability.phantasm.def.ChainPhantasmsDef;
   import engine.battle.ability.phantasm.def.ChainPhantasmsDefVars;
   import engine.core.logging.ILogger;
   import engine.core.util.Enum;
   import engine.def.EngineJsonDef;
   
   public class EffectDefVars extends EffectDef
   {
      
      public static const schema:Object = {
         "name":"EffectDefVars",
         "properties":{
            "name":{"type":"string"},
            "conditions":{
               "type":"array",
               "items":EffectDefConditionsVars.schema,
               "optional":true
            },
            "ops":{
               "type":"array",
               "items":EffectDefOpVars.schema,
               "optional":true
            },
            "phantasms":{
               "type":"array",
               "items":ChainPhantasmsDefVars.schema,
               "optional":true
            },
            "persistent":{
               "type":EffectDefPersistenceVars.schema,
               "optional":true
            },
            "tags":{
               "type":"array",
               "items":"string",
               "optional":true
            },
            "targetCaster":{
               "type":"boolean",
               "optional":true
            },
            "targetCasterFirst":{
               "type":"boolean",
               "optional":true
            },
            "targetCasterLast":{
               "type":"boolean",
               "optional":true
            },
            "executionConditions":{
               "type":AbilityExecutionConditions.schema,
               "optional":true
            },
            "noValidateAbility":{
               "type":"boolean",
               "optional":true
            }
         }
      };
       
      
      public function EffectDefVars(param1:Object, param2:BattleAbilityDef, param3:ILogger)
      {
         var index:int = 0;
         var po:Object = null;
         var p:ChainPhantasmsDef = null;
         var opn:Object = null;
         var op:EffectDefOp = null;
         var co:Object = null;
         var c:EffectDefConditions = null;
         var st:String = null;
         var tag:EffectTag = null;
         var vars:Object = param1;
         var ad:BattleAbilityDef = param2;
         var logger:ILogger = param3;
         super();
         this._logger = logger;
         this._name = vars.name;
         EngineJsonDef.validateThrow(vars,schema,logger);
         if(vars.phantasms != undefined)
         {
            index = 0;
            for each(po in vars.phantasms)
            {
               try
               {
                  p = new ChainPhantasmsDefVars(po,ad,logger);
                  phantasms.push(p);
               }
               catch(e:Error)
               {
                  logger.error("Phantasm " + index + " failed for effect [" + name + "]: " + e);
                  throw e;
               }
               index++;
            }
         }
         _targetCasterLast = vars.targetCasterLast;
         _targetCasterFirst = vars.targetCasterFirst;
         _noValidateAbility = vars.noValidateAbility;
         if(vars.targetCaster != undefined)
         {
            _targetCasterFirst = vars.targetCaster;
         }
         try
         {
            if(vars.ops != undefined)
            {
               for each(opn in vars.ops)
               {
                  op = EffectDefOp.constructDef(opn,logger);
                  if(op.enabled == true)
                  {
                     ops.push(op);
                  }
               }
            }
            if(vars.persistent != undefined)
            {
               _persistent = new EffectDefPersistenceVars(vars.persistent,logger);
            }
            if(vars.executionConditions)
            {
               _executionConditions = new AbilityExecutionConditions().fromJson(vars.executionConditions,logger);
            }
            if(vars.conditions)
            {
               for each(co in vars.conditions)
               {
                  c = new EffectDefConditionsVars(co,logger);
                  conditions.push(c);
               }
            }
            if(vars.tags)
            {
               tag_vars = vars.tags;
               for each(st in vars.tags)
               {
                  tag = Enum.parse(EffectTag,st) as EffectTag;
                  tags[tag] = tag;
               }
            }
         }
         catch(e:Error)
         {
            logger.error("EffectDefVars failure for ability [" + ad + "] effect [" + name + "]\n" + e.getStackTrace());
            throw e;
         }
      }
      
      public static function save(param1:EffectDef) : Object
      {
         var _loc3_:EffectDefConditions = null;
         var _loc4_:EffectDefOp = null;
         var _loc5_:ChainPhantasmsDef = null;
         var _loc6_:EffectTag = null;
         var _loc2_:Object = {"name":param1.name};
         if(param1._executionConditions)
         {
            _loc2_.executionConditions = param1._executionConditions.save();
         }
         if(Boolean(param1.conditions) && Boolean(param1.conditions.length))
         {
            _loc2_.conditions = [];
            for each(_loc3_ in param1.conditions)
            {
               _loc2_.conditions.push(EffectDefConditionsVars.save(_loc3_));
            }
         }
         if(Boolean(param1.ops) && Boolean(param1.ops.length))
         {
            _loc2_.ops = [];
            for each(_loc4_ in param1.ops)
            {
               _loc2_.ops.push(EffectDefOpVars.save(_loc4_));
            }
         }
         if(Boolean(param1.phantasms) && Boolean(param1.phantasms.length))
         {
            _loc2_.phantasms = [];
            for each(_loc5_ in param1.phantasms)
            {
               _loc2_.phantasms.push(ChainPhantasmsDefVars.save(_loc5_));
            }
         }
         if(param1.noValidateAbility)
         {
            _loc2_.noValidateAbility = param1.noValidateAbility;
         }
         if(param1.persistent)
         {
            _loc2_.persistent = EffectDefPersistenceVars.save(param1.persistent);
         }
         if(Boolean(param1.tag_vars) && Boolean(param1.tag_vars.length))
         {
            _loc2_.tags = param1.tag_vars;
         }
         else if(param1.tags)
         {
            _loc2_.tags = [];
            for each(_loc6_ in _loc2_.tags)
            {
               _loc2_.tags.push(_loc6_.name);
            }
         }
         if(param1.targetCasterLast)
         {
            _loc2_.targetCasterLast = param1.targetCasterLast;
         }
         if(param1.targetCasterFirst)
         {
            _loc2_.targetCasterFirst = param1.targetCasterFirst;
         }
         return _loc2_;
      }
      
      public static function validateParams(param1:Object, param2:Object, param3:ILogger) : Boolean
      {
         if(param2 != null)
         {
            if(param1 == null)
            {
               throw new ArgumentError("EffectDefVars.validateParams paramsSchema but null params");
            }
            EngineJsonDef.validateThrow(param1,param2,param3);
         }
         else if(param1 != null)
         {
            throw new ArgumentError("EffectDefVars.validateParams null paramsSchema but params");
         }
         return true;
      }
   }
}
