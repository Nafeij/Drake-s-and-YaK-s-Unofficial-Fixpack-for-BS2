package game.gui.page
{
   import flash.display.MovieClip;
   import flash.events.IEventDispatcher;
   import game.gui.IGuiContext;
   
   public interface IGuiMarketplace extends IEventDispatcher
   {
       
      
      function init(param1:IGuiContext) : void;
      
      function get movieClip() : MovieClip;
      
      function showPage(param1:String, param2:String) : void;
      
      function get EVENT_PROVING_GROUND() : String;
      
      function cleanup() : void;
   }
}
