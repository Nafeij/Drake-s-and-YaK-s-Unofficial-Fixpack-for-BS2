package game.gui
{
   public interface IGuiAlertListener
   {
       
      
      function guiAlertMaximized(param1:IGuiAlert) : void;
      
      function guiAlertMinimized(param1:IGuiAlert) : void;
      
      function guiAlertDeparted(param1:IGuiAlert) : void;
   }
}
