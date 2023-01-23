package engine.saga
{
   import engine.core.logging.ILogger;
   import engine.def.EngineJsonDef;
   
   public class SagaCreditsTextDef
   {
      
      public static const schema:Object = {
         "name":"SagaCreditsTextDef",
         "type":"object",
         "properties":{
            "localeId":{"type":"string"},
            "textsUrls":{
               "type":"array",
               "items":"string"
            },
            "logoUrl":{
               "type":"string",
               "optional":true
            }
         }
      };
       
      
      public var localeId:String;
      
      public var logoUrl:String;
      
      public var textsUrls:Array;
      
      public function SagaCreditsTextDef()
      {
         this.textsUrls = [];
         super();
      }
      
      public static function vctor() : Vector.<SagaCreditsTextDef>
      {
         return new Vector.<SagaCreditsTextDef>();
      }
      
      public function fromJson(param1:Object, param2:ILogger) : SagaCreditsTextDef
      {
         EngineJsonDef.validateThrow(param1,schema,param2);
         this.localeId = param1.localeId;
         this.textsUrls = param1.textsUrls;
         this.logoUrl = param1.logoUrl;
         return this;
      }
      
      public function toJson() : Object
      {
         var _loc1_:Object = {
            "localeId":this.localeId,
            "textsUrls":this.textsUrls
         };
         if(this.logoUrl)
         {
            _loc1_.logoUrl = this.logoUrl;
         }
         return _loc1_;
      }
   }
}
