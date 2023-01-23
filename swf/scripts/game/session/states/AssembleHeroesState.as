package game.session.states
{
   import engine.core.fsm.Fsm;
   import engine.core.fsm.StateData;
   import engine.core.logging.ILogger;
   import engine.saga.Saga;
   import game.gui.page.GuiProvingGroundsConfig;
   import game.session.GameState;
   
   public class AssembleHeroesState extends GameState
   {
      
      public static const EVENT_AUTO_NAME:String = "ProvingGroundsState.EVENT_AUTO_NAME";
      
      public static const EVENT_SHOW_CLASS:String = "ProvingGroundsState.EVENT_SHOW_CLASS";
       
      
      public var guiConfig:GuiProvingGroundsConfig;
      
      public function AssembleHeroesState(param1:StateData, param2:Fsm, param3:ILogger)
      {
         this.guiConfig = new GuiProvingGroundsConfig();
         super(param1,param2,param3);
      }
      
      override protected function handleEnteredState() : void
      {
         gameFsm.updateGameLocation("loc_assemble_heroes");
         var _loc1_:Saga = config.saga;
         if(Boolean(_loc1_) && Boolean(_loc1_.sound))
         {
            _loc1_.sound.releaseCurrentMusicBundle("AssembleHeroesState");
         }
      }
      
      override protected function handleCleanup() : void
      {
         this.guiConfig.reset();
      }
   }
}
