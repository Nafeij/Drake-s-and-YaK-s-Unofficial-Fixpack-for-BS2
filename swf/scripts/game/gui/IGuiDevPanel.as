package game.gui
{
   import flash.display.MovieClip;
   
   public interface IGuiDevPanel
   {
       
      
      function get movieClip() : MovieClip;
      
      function init(param1:IGuiContext, param2:IGuiDevPanelListener) : void;
      
      function resizeHandler(param1:Number, param2:Number) : void;
   }
}
