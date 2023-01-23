package tbs.srv.util
{
   import engine.core.logging.ILogger;
   
   public class UnlockData
   {
      
      public static const schema:Object = {
         "name":"UnlockData",
         "type":"object",
         "properties":{
            "account_id":{"type":"number"},
            "unlock_id":{"type":"string"},
            "unlock_time":{"type":"number"},
            "unlock_duration":{"type":"number"}
         }
      };
       
      
      public var account_id:int;
      
      public var unlock_id:String;
      
      public var unlock_time:Number;
      
      public var unlock_duration:Number;
      
      public function UnlockData()
      {
         super();
      }
      
      public function parseJson(param1:Object, param2:ILogger) : void
      {
         this.account_id = param1.account_id;
         this.unlock_id = param1.unlock_id;
         this.unlock_time = param1.unlock_time;
         this.unlock_duration = param1.unlock_duration;
      }
   }
}
