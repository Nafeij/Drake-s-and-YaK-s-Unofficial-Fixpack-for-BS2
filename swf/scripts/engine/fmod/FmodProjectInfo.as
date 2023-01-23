package engine.fmod
{
   import engine.core.logging.ILogger;
   import engine.def.EngineJsonDef;
   
   public class FmodProjectInfo
   {
      
      public static const schema:Object = {
         "name":"FmodProjectInfo",
         "type":"object",
         "properties":{
            "masterBankUrl":{"type":"string"},
            "masterBankStringsUrl":{"type":"string"},
            "manifestUrl":{"type":"string"}
         }
      };
       
      
      public var masterBankUrl:String;
      
      public var masterBankStringsUrl:String;
      
      public var manifestUrl:String;
      
      public function FmodProjectInfo()
      {
         super();
      }
      
      public static function create(param1:String, param2:String) : FmodProjectInfo
      {
         var _loc3_:FmodProjectInfo = new FmodProjectInfo();
         _loc3_.masterBankUrl = param1 + "MasterBank_" + param2 + ".bank";
         _loc3_.masterBankStringsUrl = param1 + "MasterBank_" + param2 + ".strings.bank";
         _loc3_.manifestUrl = param1 + "fmod_manifest_" + param2 + ".json.z";
         return _loc3_;
      }
      
      public function fromJson(param1:Object, param2:ILogger) : FmodProjectInfo
      {
         EngineJsonDef.validateThrow(param1,schema,param2);
         this.masterBankUrl = param1.masterBankUrl;
         this.masterBankStringsUrl = param1.masterBankStringsUrl;
         this.manifestUrl = param1.manifestUrl;
         return this;
      }
      
      public function toJson() : Object
      {
         return {
            "masterBankUrl":this.masterBankUrl,
            "masterBankStringsUrl":this.masterBankStringsUrl,
            "manifestUrl":this.manifestUrl
         };
      }
   }
}
