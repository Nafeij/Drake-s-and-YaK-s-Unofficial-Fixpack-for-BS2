package engine.saga
{
   import engine.core.logging.ILogger;
   import engine.def.EngineJsonDef;
   
   public class SagaBannerLengthDefVars extends SagaBannerLengthDef
   {
      
      public static const schema:Object = {
         "name":"SagaBannerLengthDefVars",
         "type":"object",
         "properties":{
            "url":{"type":"string"},
            "min_population":{"type":"number"}
         }
      };
       
      
      public function SagaBannerLengthDefVars()
      {
         super();
      }
      
      public static function save(param1:SagaBannerLengthDef) : Object
      {
         return {
            "url":param1.url,
            "min_population":param1.min_population
         };
      }
      
      public function fromJson(param1:Object, param2:ILogger) : SagaBannerLengthDef
      {
         EngineJsonDef.validateThrow(param1,schema,param2);
         url = param1.url;
         min_population = param1.min_population;
         return this;
      }
   }
}
