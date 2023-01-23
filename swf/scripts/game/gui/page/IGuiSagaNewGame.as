package game.gui.page
{
   import engine.core.util.AppInfo;
   import engine.saga.Saga;
   import flash.events.IEventDispatcher;
   import game.gui.IGuiContext;
   
   public interface IGuiSagaNewGame extends IEventDispatcher
   {
       
      
      function init(param1:IGuiContext, param2:IGuiSagaNewGameListener, param3:Saga, param4:AppInfo) : void;
      
      function resizeHandler(param1:Number, param2:Number) : void;
      
      function cleanup() : void;
      
      function get selection() : String;
      
      function showWaitPopup() : void;
      
      function hideWaitPopup() : void;
      
      function showImportFailedPopup(param1:String) : void;
   }
}
