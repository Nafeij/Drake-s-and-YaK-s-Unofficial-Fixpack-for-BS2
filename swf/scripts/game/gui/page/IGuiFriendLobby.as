package game.gui.page
{
   import game.cfg.ILobby;
   import game.gui.IGuiContext;
   import tbs.srv.data.FriendData;
   
   public interface IGuiFriendLobby
   {
       
      
      function init(param1:IGuiContext, param2:IGuiFriendLobbyListener) : void;
      
      function set lobby(param1:ILobby) : void;
      
      function get lobby() : ILobby;
      
      function update() : void;
      
      function set friend(param1:FriendData) : void;
      
      function get friend() : FriendData;
   }
}
