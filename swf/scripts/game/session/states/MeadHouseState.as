package game.session.states
{
   import engine.core.fsm.Fsm;
   import engine.core.fsm.State;
   import engine.core.fsm.StateData;
   import engine.core.logging.ILogger;
   import engine.entity.def.IEntityDef;
   import game.gui.page.GuiMeadHouseConfig;
   import game.session.GameState;
   
   public class MeadHouseState extends GameState
   {
       
      
      public var guiConfig:GuiMeadHouseConfig;
      
      public function MeadHouseState(param1:StateData, param2:Fsm, param3:ILogger)
      {
         this.guiConfig = new GuiMeadHouseConfig();
         super(param1,param2,param3);
      }
      
      override protected function handleEnteredState() : void
      {
         gameFsm.updateGameLocation("loc_mead_house");
      }
      
      public function handleHired(param1:IEntityDef) : void
      {
      }
      
      public function handleGoToProvingGrounds() : void
      {
         var _loc1_:State = config.fsm.current;
         config.fsm.transitionTo(ProvingGroundsState,_loc1_.data);
      }
   }
}
