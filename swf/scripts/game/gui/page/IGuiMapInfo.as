package game.gui.page
{
   import flash.display.MovieClip;
   import flash.events.IEventDispatcher;
   import game.gui.IGuiContext;
   
   public interface IGuiMapInfo extends IEventDispatcher
   {
       
      
      function init(param1:IGuiContext) : void;
      
      function showMapInfo(param1:String, param2:String) : void;
      
      function cleanup() : void;
      
      function get movieClip() : MovieClip;
      
      function closeMapInfo() : void;
   }
}
