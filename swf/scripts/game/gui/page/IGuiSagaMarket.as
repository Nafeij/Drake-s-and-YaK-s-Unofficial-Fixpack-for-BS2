package game.gui.page
{
   import engine.saga.Saga;
   import flash.display.MovieClip;
   import flash.events.IEventDispatcher;
   import game.gui.IGuiContext;
   
   public interface IGuiSagaMarket extends IEventDispatcher
   {
       
      
      function init(param1:IGuiContext) : void;
      
      function showMarket() : void;
      
      function cleanup() : void;
      
      function get movieClip() : MovieClip;
      
      function set saga(param1:Saga) : void;
      
      function get saga() : Saga;
      
      function update(param1:int) : void;
   }
}
