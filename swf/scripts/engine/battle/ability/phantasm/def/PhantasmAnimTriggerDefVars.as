package engine.battle.ability.phantasm.def
{
   import engine.core.logging.ILogger;
   import engine.core.util.Enum;
   import engine.def.BooleanVars;
   import engine.def.EngineJsonDef;
   
   public class PhantasmAnimTriggerDefVars extends PhantasmAnimTriggerDef
   {
      
      public static const schema:Object = {
         "name":"PhantasmAnimTriggerDefVars",
         "type":"object",
         "properties":{
            "animTargetMode":{"type":"string"},
            "animId":{"type":"string"},
            "animEventId":{"type":"string"},
            "guaranteed":{
               "type":"boolean",
               "optional":true
            },
            "deltaMs":{
               "type":"number",
               "optional":true
            }
         }
      };
       
      
      public function PhantasmAnimTriggerDefVars(param1:Object, param2:ILogger)
      {
         super();
         EngineJsonDef.validateThrow(param1,schema,param2);
         this.animTargetMode = Enum.parse(PhantasmTargetMode,param1.animTargetMode) as PhantasmTargetMode;
         this.animId = param1.animId;
         this.animEventId = param1.animEventId;
         this.guaranteed = BooleanVars.parse(param1.guaranteed);
         this.deltaMs = param1.deltaMs != undefined ? int(param1.deltaMs) : 0;
      }
      
      public static function save(param1:PhantasmAnimTriggerDef) : Object
      {
         var _loc2_:Object = {
            "animTargetMode":param1.animTargetMode.name,
            "animId":param1.animId,
            "animEventId":param1.animEventId
         };
         if(param1.guaranteed)
         {
            _loc2_.guaranteed = param1.guaranteed;
         }
         if(param1.deltaMs)
         {
            _loc2_.deltaMs = param1.deltaMs;
         }
         return _loc2_;
      }
   }
}
