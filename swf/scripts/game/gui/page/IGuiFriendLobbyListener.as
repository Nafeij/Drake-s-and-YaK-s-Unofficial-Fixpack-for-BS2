package game.gui.page
{
   import tbs.srv.data.FriendData;
   
   public interface IGuiFriendLobbyListener
   {
       
      
      function guiFriendLobbyExit() : void;
      
      function guiFriendLobbyInvite(param1:FriendData, param2:String) : void;
      
      function guiGoToProvingGrounds() : void;
   }
}
