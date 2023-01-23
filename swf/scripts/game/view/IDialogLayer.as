package game.view
{
   import game.gui.IGuiDialog;
   
   public interface IDialogLayer
   {
       
      
      function get dialog() : IGuiDialog;
      
      function addDialog(param1:IGuiDialog) : void;
      
      function removeDialog(param1:IGuiDialog) : void;
      
      function clearDialogs() : void;
      
      function get isShowingDialog() : Boolean;
   }
}
