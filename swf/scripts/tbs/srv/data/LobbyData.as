package tbs.srv.data
{
   import engine.core.logging.ILogger;
   
   public class LobbyData
   {
       
      
      public var lobby_id:int;
      
      public var account_id:int;
      
      public var account_display_name:String;
      
      public var type:String;
      
      public function LobbyData()
      {
         super();
      }
      
      public function parseJson(param1:Object, param2:ILogger) : void
      {
         this.lobby_id = param1.lobby_id;
         this.account_id = param1.account_id;
         this.account_display_name = param1.account_display_name;
         this.type = param1.type;
      }
   }
}
