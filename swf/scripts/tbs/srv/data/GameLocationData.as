package tbs.srv.data
{
   import engine.core.logging.ILogger;
   
   public class GameLocationData
   {
       
      
      public var account_id:int;
      
      public var location:String;
      
      public function GameLocationData()
      {
         super();
      }
      
      public function parseJson(param1:Object, param2:ILogger) : void
      {
         this.account_id = param1.account_id;
         this.location = param1.location;
      }
   }
}
