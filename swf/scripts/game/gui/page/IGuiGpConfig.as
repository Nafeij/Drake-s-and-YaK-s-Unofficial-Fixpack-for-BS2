package game.gui.page
{
   import flash.display.MovieClip;
   import flash.events.IEventDispatcher;
   import game.gui.IGuiContext;
   
   public interface IGuiGpConfig extends IEventDispatcher
   {
       
      
      function init(param1:IGuiContext) : void;
      
      function cleanup() : void;
      
      function get movieClip() : MovieClip;
      
      function closeGpConfig() : Boolean;
      
      function update(param1:int) : void;
      
      function get visible() : Boolean;
   }
}
