package game.session.states
{
   import engine.core.fsm.Fsm;
   import engine.core.fsm.StateData;
   import engine.core.fsm.StatePhase;
   import engine.core.logging.ILogger;
   import game.session.GameState;
   
   public class ReadyState extends GameState
   {
       
      
      public function ReadyState(param1:StateData, param2:Fsm, param3:ILogger)
      {
         super(param1,param2,param3);
      }
      
      override protected function handleEnteredState() : void
      {
         data.setValue(GameStateDataEnum.BATTLE_SCENE_ID,config.options.versusForceScene);
         if(config.options.startInSaga)
         {
            config.fsm.current.data.setValue(GameStateDataEnum.SAGA_URL,config.options.startInSaga);
            config.fsm.current.data.setValue(GameStateDataEnum.HAPPENING_ID,config.options.startInSagaHappening);
            config.fsm.current.data.setValue(GameStateDataEnum.SAGA_SAVELOAD,config.options.startInSagaSaveLoad);
            config.fsm.current.data.setValue(GameStateDataEnum.SAGA_SAVELOAD_PROFILE,config.options.startInSagaSaveLoadProfile);
            config.fsm.transitionTo(SagaState,config.fsm.current.data);
            return;
         }
         if(config.options.startInFactions)
         {
            config.fsm.transitionTo(FactionsState,null);
            return;
         }
         phase = StatePhase.COMPLETED;
      }
   }
}
