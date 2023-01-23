package engine.saga
{
   import engine.core.logging.ILogger;
   import engine.core.util.StableJson;
   import engine.core.util.StringUtil;
   import engine.def.EngineJsonDef;
   
   public class SagaRecapDef
   {
      
      public static const schema:Object = {
         "name":"SagaRecapDef",
         "type":"object",
         "properties":{
            "flv":{"type":"string"},
            "vo":{"type":"string"},
            "subtitle":{"type":"string"},
            "supertitle":{"type":"string"}
         }
      };
       
      
      public var videoParams:VideoParams;
      
      public function SagaRecapDef()
      {
         this.videoParams = new VideoParams();
         super();
      }
      
      public function toString() : String
      {
         return StableJson.stringifyObject(this.toJson());
      }
      
      public function fromJson(param1:Object, param2:ILogger) : SagaRecapDef
      {
         EngineJsonDef.validateThrow(param1,schema,param2);
         this.videoParams.url = param1.flv;
         this.videoParams.vo = param1.vo;
         this.videoParams.subtitle = param1.subtitle;
         this.videoParams.supertitle = param1.supertitle;
         return this;
      }
      
      public function toJson() : Object
      {
         return {
            "flv":StringUtil.nonnull(this.videoParams.url),
            "vo":StringUtil.nonnull(this.videoParams.vo),
            "subtitle":StringUtil.nonnull(this.videoParams.subtitle),
            "supertitle":StringUtil.nonnull(this.videoParams.supertitle)
         };
      }
   }
}
