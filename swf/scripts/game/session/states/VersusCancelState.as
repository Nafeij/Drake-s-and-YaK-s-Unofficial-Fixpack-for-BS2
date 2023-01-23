package game.session.states
{
   import engine.battle.fsm.txn.BattleTxnSurrenderSend;
   import engine.core.fsm.Fsm;
   import engine.core.fsm.StateData;
   import engine.core.logging.ILogger;
   import game.session.GameState;
   import tbs.srv.battle.data.client.BattleCreateData;
   
   public class VersusCancelState extends GameState
   {
       
      
      private var txn:BattleTxnSurrenderSend;
      
      public function VersusCancelState(param1:StateData, param2:Fsm, param3:ILogger)
      {
         super(param1,param2,param3);
      }
      
      override protected function handleCleanup() : void
      {
         if(this.txn)
         {
            this.txn.abort();
            this.txn = null;
         }
      }
      
      override protected function handleEnteredState() : void
      {
         var _loc1_:BattleCreateData = data.getValue(GameStateDataEnum.BATTLE_CREATE_DATA);
         if(_loc1_)
         {
            logger.info("VersusCancelState SENDING SURRENDER: " + _loc1_.battle_id);
            this.txn = new BattleTxnSurrenderSend(_loc1_.battle_id,credentials,this.surrenderSendHandler,null,logger);
            this.txn.send(communicator);
         }
         else
         {
            logger.info("VersusCancelState NO BATTLE, FINISHING");
            this.doFinish();
         }
      }
      
      private function doFinish() : void
      {
         var _loc1_:int = data.getValue(GameStateDataEnum.BATTLE_FRIEND_LOBBY_ID);
         var _loc2_:Boolean = data.getValue(GameStateDataEnum.VERSUS_RESTART);
         data.removeValue(GameStateDataEnum.VERSUS_RESTART);
         if(_loc2_)
         {
            config.fsm.transitionTo(VersusFindMatchState,config.fsm.current.data);
         }
         else if(Boolean(config.factions) && _loc1_ == config.factions.lobbyManager.current.options.lobby_id)
         {
            config.fsm.transitionTo(FriendLobbyState,null);
         }
         else if(config.runMode.town)
         {
            config.fsm.transitionTo(GreatHallState,config.fsm.current.data);
         }
         else
         {
            config.context.appInfo.exitGame("VersusCancelState.doFinish runMode=" + config.runMode);
         }
      }
      
      private function surrenderSendHandler(param1:BattleTxnSurrenderSend) : void
      {
         if(param1.success)
         {
            this.doFinish();
         }
      }
   }
}
