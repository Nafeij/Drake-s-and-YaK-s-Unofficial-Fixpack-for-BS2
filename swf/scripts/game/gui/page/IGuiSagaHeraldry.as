package game.gui.page
{
   import engine.heraldry.HeraldrySystem;
   import engine.resource.ResourceManager;
   import flash.display.MovieClip;
   import flash.events.IEventDispatcher;
   import game.gui.IGuiContext;
   
   public interface IGuiSagaHeraldry extends IEventDispatcher
   {
       
      
      function init(param1:IGuiContext, param2:ResourceManager) : void;
      
      function cleanup() : void;
      
      function get movieClip() : MovieClip;
      
      function showGuiHeraldry(param1:HeraldrySystem) : void;
      
      function hideGuiHeraldry() : void;
      
      function notifyOverlayChange(param1:Boolean) : void;
   }
}
