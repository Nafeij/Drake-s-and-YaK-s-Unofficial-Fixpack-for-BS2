package game.gui
{
   import engine.session.Alert;
   import flash.display.MovieClip;
   
   public interface IGuiAlert
   {
       
      
      function init(param1:IGuiContext, param2:Alert, param3:IGuiAlertListener) : void;
      
      function get movieClip() : MovieClip;
      
      function get leaderWidth() : Number;
      
      function get alert() : Alert;
      
      function maximize() : void;
      
      function minimize() : void;
      
      function depart() : void;
      
      function cleanup() : void;
   }
}
