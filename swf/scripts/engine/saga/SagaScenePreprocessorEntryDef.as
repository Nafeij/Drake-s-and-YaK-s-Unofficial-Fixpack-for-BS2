package engine.saga
{
   import engine.core.logging.ILogger;
   import engine.def.EngineJsonDef;
   
   public class SagaScenePreprocessorEntryDef
   {
      
      public static const schema:Object = {
         "name":"SagaScenePreprocessorEntryDef",
         "type":"object",
         "properties":{
            "id":{"type":"string"},
            "happening":{"type":"string"}
         }
      };
       
      
      public var id:String;
      
      public var happening:String;
      
      public function SagaScenePreprocessorEntryDef()
      {
         super();
      }
      
      public static function vctor() : Vector.<SagaScenePreprocessorEntryDef>
      {
         return new Vector.<SagaScenePreprocessorEntryDef>();
      }
      
      public function fromJson(param1:Object, param2:ILogger) : SagaScenePreprocessorEntryDef
      {
         EngineJsonDef.validateThrow(param1,schema,param2);
         this.id = param1.id;
         this.happening = param1.happening;
         return this;
      }
      
      public function toJson() : Object
      {
         return {
            "id":(!!this.id ? this.id : ""),
            "happening":(!!this.happening ? this.happening : "")
         };
      }
   }
}
