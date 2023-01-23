package engine.anim.def
{
   import engine.core.logging.ILogger;
   import engine.def.EngineJsonDef;
   
   public class AnimMixEntryDefVars extends AnimMixEntryDef
   {
      
      public static const schema:Object = {
         "name":"AnimMixEntryDefVars",
         "type":"object",
         "properties":{
            "anim":{"type":"string"},
            "weight":{
               "type":"number",
               "optional":true
            },
            "lengthMinMs":{
               "type":"number",
               "optional":true
            },
            "lengthMaxMs":{
               "type":"number",
               "optional":true
            },
            "repeatsMin":{
               "type":"number",
               "optional":true
            },
            "repeatsMax":{
               "type":"number",
               "optional":true
            }
         }
      };
       
      
      public function AnimMixEntryDefVars(param1:Object, param2:ILogger)
      {
         super();
         EngineJsonDef.validateThrow(param1,schema,param2);
         anim = param1.anim;
         weight = param1.weight;
         if(!weight)
         {
            weight = 1;
         }
         lengthMinMs = param1.lengthMinMs;
         lengthMaxMs = param1.lengthMaxMs;
         repeatsMin = param1.repeatsMin;
         repeatsMax = param1.repeatsMax;
      }
      
      public static function save(param1:AnimMixEntryDef) : Object
      {
         return {
            "anim":param1.anim,
            "weight":param1.weight,
            "lengthMinMs":param1.lengthMinMs,
            "lengthMaxMs":param1.lengthMaxMs,
            "repeatsMin":param1.repeatsMin,
            "repeatsMax":param1.repeatsMax
         };
      }
   }
}
