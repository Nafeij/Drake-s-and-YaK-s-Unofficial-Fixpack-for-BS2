package engine.saga
{
   import engine.core.logging.ILogger;
   import engine.def.EngineJsonDef;
   
   public class SagaDlcEntryVars extends SagaDlcEntry
   {
      
      public static const schema:Object = {
         "name":"SagaDlcEntryVars",
         "type":"object",
         "properties":{
            "id":{"type":"string"},
            "vars":{
               "type":"array",
               "items":SagaDlcVariableDataVars.schema
            },
            "steam_appid":{"type":"number"},
            "gog_appid":{
               "type":"number",
               "optional":true
            },
            "apple_productid":{"type":"string"},
            "google_android_productid":{"type":"string"},
            "amazon_android_productid":{"type":"string"},
            "xbl_productid":{
               "type":"string",
               "optional":true
            },
            "psn_productid":{
               "type":"string",
               "optional":true
            },
            "nx_productid":{
               "type":"number",
               "optional":true
            },
            "ownedDefault":{
               "type":"boolean",
               "optional":true
            }
         }
      };
       
      
      public function SagaDlcEntryVars()
      {
         super();
      }
      
      public function fromJson(param1:Object, param2:ILogger) : SagaDlcEntry
      {
         var _loc3_:Object = null;
         var _loc4_:SagaDlcVariableData = null;
         EngineJsonDef.validateThrow(param1,schema,param2);
         this.id = param1.id;
         this.platform_id_steam_appid = param1.steam_appid;
         if(param1.gog_appid != undefined)
         {
            this.platform_id_gog_appid = param1.gog_appid;
         }
         this.platform_id_apple_productid = param1.apple_productid;
         this.platform_id_google_android_productid = param1.google_android_productid;
         this.platform_id_amazon_productid = param1.amazon_android_productid;
         this.platform_id_xbl_productid = param1.xbl_productid;
         this.platform_id_psn_productid = param1.psn_productid;
         if(param1.nx_productid != undefined)
         {
            this.platform_id_nx_productid = param1.nx_productid;
         }
         for each(_loc3_ in param1.vars)
         {
            _loc4_ = new SagaDlcVariableDataVars().fromJson(_loc3_,param2);
            vars.push(_loc4_);
         }
         this.ownedDefault = param1.ownedDefault;
         return this;
      }
   }
}
