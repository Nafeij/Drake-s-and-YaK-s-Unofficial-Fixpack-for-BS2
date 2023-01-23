package game.gui
{
   import flash.display.MovieClip;
   
   public interface IGuiSagaNewsToggle
   {
       
      
      function init(param1:IGuiContext, param2:IGuiSagaNews) : void;
      
      function cleanup() : void;
      
      function get movieClip() : MovieClip;
      
      function handleNewsUpdated() : void;
   }
}
