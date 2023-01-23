package game.gui.page
{
   public interface IGuiLoginListener
   {
       
      
      function guiLoginSetAttemptLogin(param1:String, param2:String) : void;
      
      function guiLoginCancelLogin() : void;
      
      function guiLoginGoOffline() : void;
      
      function guiLoginServerSelected(param1:String) : void;
   }
}
