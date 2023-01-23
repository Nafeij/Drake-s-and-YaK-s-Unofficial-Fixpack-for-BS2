package game.session.states
{
   import engine.core.fsm.Fsm;
   import engine.core.fsm.StateData;
   import engine.core.logging.ILogger;
   import engine.scene.model.SceneEvent;
   
   public class MapCampState extends SceneState
   {
       
      
      public function MapCampState(param1:StateData, param2:Fsm, param3:ILogger)
      {
         super(param1,param2,param3);
      }
      
      override protected function sceneExitHandler(param1:SceneEvent) : void
      {
         if(config.saga)
         {
            config.saga.triggerSceneExit(loader.url,param1.sceneUniqueId);
            return;
         }
      }
      
      override protected function handleEnteredState() : void
      {
         gameFsm.updateGameLocation("map_camp");
         super.handleEnteredState();
      }
      
      override public function handleLandscapeClick(param1:String) : Boolean
      {
         if(super.handleLandscapeClick(param1))
         {
            return true;
         }
         var _loc2_:* = param1;
         switch(0)
         {
         }
         return false;
      }
   }
}
