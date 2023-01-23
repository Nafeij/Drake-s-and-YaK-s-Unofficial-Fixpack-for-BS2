package engine.battle.ability.effect.def
{
   import engine.battle.ability.def.AbilityExecutionEntityConditions;
   import engine.battle.ability.effect.model.EffectResult;
   import engine.core.logging.ILogger;
   import engine.core.util.Enum;
   import engine.def.EngineJsonDef;
   
   public class EffectDefConditionsVars extends EffectDefConditions
   {
      
      public static const schema:Object = {
         "name":"EffectDefConditions",
         "properties":{
            "other":{"type":"string"},
            "results":{
               "type":"array",
               "items":"string",
               "optional":true
            },
            "tag":{
               "type":EffectTagReqsVars.schema,
               "optional":true
            },
            "minLevel":{
               "type":"number",
               "optional":true
            },
            "target":{
               "type":AbilityExecutionEntityConditions.schema,
               "optional":true
            }
         }
      };
       
      
      public function EffectDefConditionsVars(param1:Object, param2:ILogger)
      {
         var _loc3_:String = null;
         var _loc4_:EffectResult = null;
         super();
         EngineJsonDef.validateThrow(param1,schema,param2);
         other = param1.other;
         if(param1.results)
         {
            for each(_loc3_ in param1.results)
            {
               _loc4_ = Enum.parse(EffectResult,_loc3_) as EffectResult;
               results.push(_loc4_);
            }
         }
         if(param1.tag)
         {
            this.tag = new EffectTagReqsVars(param1.tag,param2);
         }
         minLevel = param1.minLevel;
         if(param1.target)
         {
            target = new AbilityExecutionEntityConditions().fromJson(param1.target,param2);
         }
      }
      
      public static function save(param1:EffectDefConditions) : Object
      {
         var _loc3_:EffectResult = null;
         var _loc2_:Object = {"other":param1.other};
         if(Boolean(param1.results) && Boolean(param1.results.length))
         {
            _loc2_.results = [];
            for each(_loc3_ in param1.results)
            {
               _loc2_.results.push(_loc3_.name);
            }
         }
         if(param1.tag)
         {
            _loc2_.tag = EffectTagReqsVars.save(param1.tag);
         }
         if(param1.minLevel)
         {
            _loc2_.minLevel = param1.minLevel;
         }
         if(param1.target)
         {
            _loc2_.target = param1.target.save();
         }
         return _loc2_;
      }
   }
}
