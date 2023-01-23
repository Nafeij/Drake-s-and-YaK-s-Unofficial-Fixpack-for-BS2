package engine.battle.ability.phantasm.def
{
   import engine.battle.ability.effect.def.BooleanValueReqs;
   import engine.battle.ability.effect.def.EffectTagReqsVars;
   import engine.battle.ability.effect.op.def.EffectDirectionalFlag;
   import engine.core.logging.ILogger;
   import engine.core.util.Enum;
   import engine.def.EngineJsonDef;
   
   public class PhantasmDefVars
   {
      
      public static const schema:Object = {
         "name":"PhantasmDef",
         "type":"object",
         "properties":{
            "time":{"type":"number"},
            "targetMode":{"type":"string"},
            "animTrigger":{
               "type":PhantasmAnimTriggerDefVars.schema,
               "optional":true
            },
            "sync":{
               "type":"string",
               "optional":true
            },
            "casterTagReqs":{
               "type":EffectTagReqsVars.schema,
               "optional":true
            },
            "effectTagReqs":{
               "type":EffectTagReqsVars.schema,
               "optional":true
            },
            "targetTagReqs":{
               "type":EffectTagReqsVars.schema,
               "optional":true
            },
            "largeTargetReq":{
               "type":BooleanValueReqs.schema,
               "optional":true
            },
            "directionalFlagReqs":{
               "type":"array",
               "items":"string",
               "optional":true
            },
            "directionalFlags":{
               "type":"number",
               "optional":true
            },
            "guaranteed":{
               "type":"boolean",
               "optional":true
            }
         }
      };
       
      
      public function PhantasmDefVars()
      {
         super();
      }
      
      public static function save(param1:PhantasmDef) : Object
      {
         var _loc2_:Object = {
            "time":param1.time,
            "targetMode":param1.targetMode.name
         };
         if(param1.guaranteed)
         {
            _loc2_.guaranteed = param1.guaranteed;
         }
         if(param1.animTrigger)
         {
            _loc2_.animTrigger = PhantasmAnimTriggerDefVars.save(param1.animTrigger);
         }
         if(param1.sync)
         {
            _loc2_.sync = param1.sync;
         }
         if(param1.casterTagReqs)
         {
            _loc2_.casterTagReqs = EffectTagReqsVars.save(param1.casterTagReqs);
         }
         if(param1.effectTagReqs)
         {
            _loc2_.effectTagReqs = EffectTagReqsVars.save(param1.effectTagReqs);
         }
         if(param1.targetTagReqs)
         {
            _loc2_.targetTagReqs = EffectTagReqsVars.save(param1.targetTagReqs);
         }
         if(param1.largeTargetReq)
         {
            _loc2_.largetTargetReq = param1.largeTargetReq.save();
         }
         if(param1.directionalFlags)
         {
            _loc2_.directionalFlags = param1.directionalFlags;
         }
         return _loc2_;
      }
      
      public static function parse(param1:PhantasmDef, param2:Object, param3:ILogger) : void
      {
         var _loc4_:String = null;
         var _loc5_:EffectDirectionalFlag = null;
         EngineJsonDef.validateThrow(param2,schema,param3);
         param1.guaranteed = param2.guaranteed;
         param1.time = param2.time;
         param1.targetMode = Enum.parse(PhantasmTargetMode,param2.targetMode) as PhantasmTargetMode;
         if(param2.animTrigger)
         {
            param1.animTrigger = new PhantasmAnimTriggerDefVars(param2.animTrigger,param3);
         }
         param1.sync = param2.sync;
         param1.casterTagReqs = EffectTagReqsVars.factory(param2.casterTagReqs,param3);
         param1.effectTagReqs = EffectTagReqsVars.factory(param2.effectTagReqs,param3);
         param1.targetTagReqs = EffectTagReqsVars.factory(param2.targetTagReqs,param3);
         if(param2.largeTargetReq)
         {
            param1.largeTargetReq = new BooleanValueReqs().fromJson(param2.largeTargetReq,param3);
         }
         if(param2.directionalFlags != undefined)
         {
            param1.directionalFlags = param2.directionalFlags;
         }
         else if(param2.directionalFlagReqs)
         {
            param1.directionalFlags = 0;
            for each(_loc4_ in param2.directionalFlagReqs)
            {
               _loc5_ = Enum.parse(EffectDirectionalFlag,_loc4_) as EffectDirectionalFlag;
               param1.directionalFlags |= _loc5_.bit;
            }
         }
      }
   }
}
