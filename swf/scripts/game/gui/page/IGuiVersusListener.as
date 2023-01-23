package game.gui.page
{
   import game.session.actions.VsType;
   
   public interface IGuiVersusListener
   {
       
      
      function guiVersusExit() : void;
      
      function guiVersusLaunch() : void;
      
      function get guiVsType() : VsType;
   }
}
