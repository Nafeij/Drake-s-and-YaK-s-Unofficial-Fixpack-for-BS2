package game.gui
{
   import engine.gui.SagaNews;
   import flash.display.MovieClip;
   
   public interface IGuiSagaNews
   {
       
      
      function init(param1:IGuiContext) : void;
      
      function setNews(param1:SagaNews) : void;
      
      function cleanup() : void;
      
      function get movieClip() : MovieClip;
      
      function get isShowing() : Boolean;
      
      function set isShowing(param1:Boolean) : void;
      
      function set guiToggle(param1:IGuiSagaNewsToggle) : void;
      
      function handleResize() : void;
      
      function get numVisibleNews() : int;
   }
}
