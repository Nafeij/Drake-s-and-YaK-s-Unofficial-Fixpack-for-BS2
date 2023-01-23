package tbs.srv.util
{
   import engine.core.logging.ILogger;
   
   public class PurchaseCountData
   {
      
      public static const schema:Object = {
         "name":"UnlockData",
         "type":"object",
         "properties":{
            "account_id":{"type":"number"},
            "item_id":{"type":"string"},
            "purchase_count":{"type":"number"}
         }
      };
       
      
      public var account_id:int;
      
      public var item_id:String;
      
      public var purchase_count:int;
      
      public function PurchaseCountData()
      {
         super();
      }
      
      public function parseJson(param1:Object, param2:ILogger) : void
      {
         this.account_id = param1.account_id;
         this.item_id = param1.item_id;
         this.purchase_count = param1.purchase_count;
      }
   }
}
