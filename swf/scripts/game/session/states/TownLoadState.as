package game.session.states
{
   import engine.core.fsm.Fsm;
   import engine.core.fsm.StateData;
   import engine.core.logging.ILogger;
   
   public class TownLoadState extends SceneLoadState
   {
       
      
      public function TownLoadState(param1:StateData, param2:Fsm, param3:ILogger)
      {
         param1.setValue(GameStateDataEnum.SCENELOADER_PRESERVE,true);
         param1.setValue(GameStateDataEnum.SCENE_IS_TOWN,true);
         param1.setValue(GameStateDataEnum.SCENE_URL,"common/town/strand/strand.json.z");
         super(param1,param2,param3);
      }
      
      override protected function handleEnteredState() : void
      {
         super.handleEnteredState();
      }
      
      override protected function handleCleanup() : void
      {
         super.handleCleanup();
      }
   }
}
