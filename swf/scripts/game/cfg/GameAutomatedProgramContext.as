package game.cfg
{
   import engine.automator.AutomatedProgramContext;
   import engine.automator.IFastForward;
   
   public class GameAutomatedProgramContext extends AutomatedProgramContext implements IFastForward
   {
       
      
      private var config:GameConfig;
      
      private var gameClicker:GameAutomatedProgramClicker;
      
      public function GameAutomatedProgramContext(param1:GameConfig)
      {
         super();
         this.config = param1;
         this.gameClicker = new GameAutomatedProgramClicker(param1);
         setLogger(param1.logger);
         setKeyBinder(param1.keybinder);
         setFastForward(this);
         setClicker(this.gameClicker);
      }
      
      public function performFastForward() : void
      {
      }
      
      override public function exit(param1:Boolean) : void
      {
         if(Boolean(logger.numErrors) || !param1)
         {
            logger.e("AUTO","Exit with errors");
            this.config.context.appInfo.terminateError("automation exiting with errors");
         }
         else
         {
            logger.i("AUTO","Exit clean");
            this.config.context.appInfo.exitGame("automation exiting clean");
         }
      }
   }
}
