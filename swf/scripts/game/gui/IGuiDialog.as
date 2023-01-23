package game.gui
{
   public interface IGuiDialog
   {
       
      
      function init(param1:IGuiContext) : void;
      
      function openDialog(param1:String, param2:String, param3:String, param4:Function = null) : void;
      
      function openTwoBtnDialog(param1:String, param2:String, param3:String, param4:String, param5:Function = null) : void;
      
      function openNoButtonDialog(param1:String, param2:String, param3:Function = null) : void;
      
      function closeDialog(param1:String) : void;
      
      function notifyClosed(param1:String) : void;
      
      function setColors(param1:uint, param2:uint) : void;
      
      function setSounds(param1:String, param2:String) : void;
      
      function scaleToScreen() : void;
      
      function cleanup() : void;
      
      function setCloseButtonVisible(param1:Boolean) : void;
      
      function get buttonOne() : String;
      
      function pressOk() : void;
      
      function pressCancel() : void;
      
      function pressEscape() : void;
      
      function set disableEscape(param1:Boolean) : void;
   }
}
