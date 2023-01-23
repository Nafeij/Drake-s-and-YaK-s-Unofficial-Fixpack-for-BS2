package game.session.states
{
   import engine.core.fsm.Fsm;
   import engine.core.fsm.StateData;
   import engine.core.logging.ILogger;
   
   public class MapCampLoadState extends SceneLoadState
   {
       
      
      public function MapCampLoadState(param1:StateData, param2:Fsm, param3:ILogger)
      {
         super(param1,param2,param3);
      }
   }
}
