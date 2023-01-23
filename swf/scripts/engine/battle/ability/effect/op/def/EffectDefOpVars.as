package engine.battle.ability.effect.op.def
{
   import engine.battle.ability.effect.def.EffectDefVars;
   import engine.core.logging.ILogger;
   import engine.core.util.Enum;
   import engine.def.BooleanVars;
   import engine.def.EngineJsonDef;
   
   public class EffectDefOpVars extends EffectDefOp
   {
      
      public static const schema:Object = {
         "name":"EffectDefOp",
         "properties":{
            "id":{"type":"string"},
            "name":{
               "type":"string",
               "optional":true
            },
            "enabled":{
               "type":"boolean",
               "optional":true
            },
            "params":{
               "type":{},
               "optional":true,
               "skip":true
            }
         }
      };
       
      
      public function EffectDefOpVars(param1:Object, param2:ILogger, param3:Object = null)
      {
         super();
         parse(this,param1,param2,param3);
      }
      
      public static function save(param1:EffectDefOp) : Object
      {
         var _loc2_:Object = {"id":param1.id.name};
         if(param1.name)
         {
            _loc2_.name = param1.name;
         }
         if(!param1.enabled)
         {
            _loc2_.enabled = param1.enabled;
         }
         if(param1.params)
         {
            _loc2_.params = param1.params;
         }
         return _loc2_;
      }
      
      public static function parse(param1:EffectDefOp, param2:Object, param3:ILogger, param4:Object = null) : void
      {
         var def:EffectDefOp = param1;
         var vars:Object = param2;
         var logger:ILogger = param3;
         var subSchema:Object = param4;
         EngineJsonDef.validateThrow(vars,schema,logger);
         def.id = Enum.parse(IdEffectOp,vars.id) as IdEffectOp;
         def.params = vars.params;
         def.name = vars.name;
         if(vars.enabled != undefined)
         {
            def.enabled = BooleanVars.parse(vars.enabled);
         }
         if(EngineJsonDef._validate == null)
         {
            return;
         }
         if(subSchema == null)
         {
            subSchema = def.id.schema;
         }
         try
         {
            if(def.name == "trigger_runicgale_vfx_str")
            {
               ;
            }
            if(!EffectDefVars.validateParams(def.params,subSchema,logger))
            {
               throw new ArgumentError("EffectDefOp " + def.id + "/" + def.name + " params failed validation");
            }
         }
         catch(e:Error)
         {
            throw new ArgumentError("EffectDefOp " + def.id + "/" + def.name + " params errored validation:\n" + e.getStackTrace());
         }
      }
   }
}
