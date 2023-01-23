package game.gui.page
{
   import engine.session.NewsDef;
   import flash.events.IEventDispatcher;
   import game.gui.IGuiContext;
   
   public interface IGuiNews extends IEventDispatcher
   {
       
      
      function init(param1:IGuiContext) : void;
      
      function showNews(param1:NewsDef, param2:int) : void;
   }
}
