package tbs.srv.data
{
   import engine.core.logging.ILogger;
   import engine.def.EngineJsonDef;
   import engine.entity.def.EntityDefVars;
   
   public class PurchasableUnitData
   {
      
      public static const schema:Object = {
         "name":"PurchasableUnitData",
         "type":"object",
         "properties":{
            "def":{"type":EntityDefVars.schema},
            "limit":{"type":"number"},
            "cost":{"type":"number"},
            "comment":{
               "type":"string",
               "optional":true
            },
            "class":{
               "type":"string",
               "optional":true
            }
         }
      };
       
      
      public var def:Object;
      
      public var limit:int;
      
      public var cost:int;
      
      public var comment:String;
      
      public function PurchasableUnitData()
      {
         super();
      }
      
      public function parseJson(param1:Object, param2:ILogger) : void
      {
         EngineJsonDef.validateThrow(param1,schema,param2);
         this.def = param1.def;
         this.limit = param1.limit;
         this.cost = param1.cost;
         this.comment = param1.comment;
      }
   }
}
