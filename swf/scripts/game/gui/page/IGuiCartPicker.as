package game.gui.page
{
   import flash.display.MovieClip;
   import flash.events.IEventDispatcher;
   import game.gui.IGuiContext;
   
   public interface IGuiCartPicker extends IEventDispatcher
   {
       
      
      function init(param1:IGuiContext) : void;
      
      function cleanup() : void;
      
      function get movieClip() : MovieClip;
      
      function showGuiCartPicker() : void;
      
      function hideGuiCartPicker() : void;
      
      function notifyOverlayChange(param1:Boolean) : void;
      
      function update(param1:int) : void;
   }
}
