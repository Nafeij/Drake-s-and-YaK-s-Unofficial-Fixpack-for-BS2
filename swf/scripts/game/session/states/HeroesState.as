package game.session.states
{
   import engine.core.fsm.Fsm;
   import engine.core.fsm.StateData;
   import engine.core.logging.ILogger;
   import game.gui.page.GuiProvingGroundsConfig;
   import game.session.GameState;
   
   public class HeroesState extends GameState
   {
       
      
      public var guiConfig:GuiProvingGroundsConfig;
      
      public function HeroesState(param1:StateData, param2:Fsm, param3:ILogger)
      {
         this.guiConfig = new GuiProvingGroundsConfig();
         super(param1,param2,param3);
         if(config.saga)
         {
            config.saga.sceneStateSave();
         }
      }
      
      override protected function handleEnteredState() : void
      {
         gameFsm.updateGameLocation("loc_heroes");
      }
      
      override protected function handleCleanup() : void
      {
         this.guiConfig.reset();
      }
   }
}
