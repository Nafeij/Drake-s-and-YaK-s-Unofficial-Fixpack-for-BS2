package game.session.states
{
   import engine.core.fsm.Fsm;
   import engine.core.fsm.StateData;
   import engine.core.logging.ILogger;
   import game.session.GameState;
   
   public class FriendLobbyState extends GameState
   {
       
      
      public function FriendLobbyState(param1:StateData, param2:Fsm, param3:ILogger)
      {
         super(param1,param2,param3);
      }
      
      override protected function handleCleanup() : void
      {
         super.handleCleanup();
         communicator.removePollTimeRequirement(this);
      }
      
      override protected function handleEnteredState() : void
      {
         super.handleEnteredState();
         gameFsm.updateGameLocation("loc_friend_lobby");
         communicator.setPollTimeRequirement(this,2000);
         if(config.factions)
         {
            config.factions.lobbyManager.current.ready = false;
         }
      }
   }
}
