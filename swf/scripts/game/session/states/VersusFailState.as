package game.session.states
{
   import engine.core.fsm.Fsm;
   import engine.core.fsm.StateData;
   import engine.core.logging.ILogger;
   import game.session.GameState;
   
   public class VersusFailState extends GameState
   {
       
      
      public function VersusFailState(param1:StateData, param2:Fsm, param3:ILogger)
      {
         super(param1,param2,param3);
      }
      
      override protected function handleEnteredState() : void
      {
         var _loc1_:int = data.getValue(GameStateDataEnum.BATTLE_FRIEND_LOBBY_ID);
         if(Boolean(config.factions) && _loc1_ == config.factions.lobbyManager.current.options.lobby_id)
         {
            config.fsm.transitionTo(FriendLobbyState,null);
         }
         else if(config.runMode.town)
         {
            fsm.transitionTo(GreatHallState,data);
         }
         else
         {
            fsm.transitionTo(VersusFindMatchState,data);
         }
      }
   }
}
