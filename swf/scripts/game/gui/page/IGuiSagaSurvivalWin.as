package game.gui.page
{
   import engine.core.util.AppInfo;
   import engine.saga.Saga;
   import flash.events.IEventDispatcher;
   import game.gui.IGuiContext;
   
   public interface IGuiSagaSurvivalWin extends IEventDispatcher
   {
       
      
      function init(param1:IGuiContext, param2:IGuiSagaSurvivalWinListener, param3:Saga, param4:AppInfo) : void;
      
      function resizeHandler(param1:Number, param2:Number) : void;
      
      function cleanup() : void;
   }
}
