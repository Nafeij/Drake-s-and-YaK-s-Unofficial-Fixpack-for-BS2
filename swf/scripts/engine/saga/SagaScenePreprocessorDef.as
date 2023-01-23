package engine.saga
{
   import engine.core.logging.ILogger;
   import engine.core.util.ArrayUtil;
   import engine.def.EngineJsonDef;
   import flash.utils.Dictionary;
   
   public class SagaScenePreprocessorDef
   {
      
      public static const schema:Object = {
         "name":"SagaScenePreprocessorDef",
         "type":"object",
         "properties":{"entries":{
            "type":"array",
            "items":SagaScenePreprocessorEntryDef.schema
         }}
      };
       
      
      public var entries:Vector.<SagaScenePreprocessorEntryDef>;
      
      public var id2Entry:Dictionary;
      
      public function SagaScenePreprocessorDef()
      {
         this.id2Entry = new Dictionary();
         super();
      }
      
      public function getEntry(param1:String) : SagaScenePreprocessorEntryDef
      {
         return this.id2Entry[param1];
      }
      
      public function fromJson(param1:Object, param2:ILogger) : SagaScenePreprocessorDef
      {
         EngineJsonDef.validateThrow(param1,schema,param2);
         ArrayUtil.arrayToDefVector(param1.entries,SagaScenePreprocessorEntryDef,param2,null,this.registerEntry);
         return this;
      }
      
      public function registerEntry(param1:SagaScenePreprocessorEntryDef, param2:int) : void
      {
         if(this.id2Entry[param1.id])
         {
            throw new ArgumentError("duplicate id");
         }
         this.id2Entry[param1.id] = param1;
      }
      
      public function toJson() : Object
      {
         return {"entries":ArrayUtil.defVectorToArray(this.entries,true)};
      }
   }
}
