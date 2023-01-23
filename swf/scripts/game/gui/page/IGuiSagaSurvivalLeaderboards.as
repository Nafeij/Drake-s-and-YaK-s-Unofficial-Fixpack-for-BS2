package game.gui.page
{
   import engine.core.util.AppInfo;
   import engine.gui.IGuiButton;
   import engine.saga.Saga;
   import game.gui.IGuiContext;
   
   public interface IGuiSagaSurvivalLeaderboards
   {
       
      
      function init(param1:IGuiContext, param2:IGuiSagaSurvivalLeaderboardsListener, param3:Saga, param4:AppInfo, param5:IGuiButton) : void;
      
      function resizeHandler(param1:Number, param2:Number) : void;
      
      function cleanup() : void;
   }
}
