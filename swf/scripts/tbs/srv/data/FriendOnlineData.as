package tbs.srv.data
{
   import engine.core.logging.ILogger;
   
   public class FriendOnlineData
   {
       
      
      public var account_id:int;
      
      public var online:Boolean;
      
      public function FriendOnlineData()
      {
         super();
      }
      
      public function parseJson(param1:Object, param2:ILogger) : void
      {
         this.account_id = param1.account_id;
         this.online = param1.online;
      }
   }
}
