package game.cfg
{
   import tbs.srv.data.LobbyData;
   import tbs.srv.data.LobbyOptionsData;
   
   public interface ILobby
   {
       
      
      function invite(param1:int, param2:String, param3:String) : void;
      
      function get manager() : ILobbyManager;
      
      function get options() : LobbyOptionsData;
      
      function get other() : LobbyMemberInfo;
      
      function set ready(param1:Boolean) : void;
      
      function get ready() : Boolean;
      
      function exit() : void;
      
      function sendOptions() : void;
      
      function getLobbyMemberInfo(param1:int) : LobbyMemberInfo;
      
      function get terminated() : Boolean;
      
      function set terminated(param1:Boolean) : void;
      
      function get joined() : Boolean;
      
      function get local_account_id() : int;
      
      function get chatRoomId() : String;
      
      function handleData(param1:LobbyData) : void;
   }
}
