package game.session.states
{
   import engine.core.fsm.Fsm;
   import engine.core.fsm.StateData;
   import engine.core.fsm.StatePhase;
   import engine.core.logging.ILogger;
   import engine.entity.def.IEntityListDef;
   import game.session.GameState;
   import tbs.srv.battle.data.client.BattleAbortedData;
   import tbs.srv.battle.data.client.BattleCreateData;
   
   public class VersusMatchedState extends GameState
   {
      
      private static const inputDataKeys:Array = [GameStateDataEnum.OPPONENT_ID,GameStateDataEnum.OPPONENT_NAME,GameStateDataEnum.OPPONENT_PARTY,GameStateDataEnum.SCENE_URL,GameStateDataEnum.LOCAL_PARTY,GameStateDataEnum.BATTLE_INFO];
       
      
      public var battleCreateData:BattleCreateData;
      
      public function VersusMatchedState(param1:StateData, param2:Fsm, param3:ILogger)
      {
         super(param1,param2,param3);
      }
      
      override protected function handleEnteredState() : void
      {
         communicator.setPollTimeRequirement(this,2000);
         this.battleCreateData = data.getValue(GameStateDataEnum.BATTLE_CREATE_DATA);
      }
      
      override protected function handleCleanup() : void
      {
         communicator.removePollTimeRequirement(this);
      }
      
      override protected function getRequiredInputDataKeys() : Array
      {
         return inputDataKeys;
      }
      
      public function get opponentName() : String
      {
         return data.getValue(GameStateDataEnum.OPPONENT_NAME);
      }
      
      public function get opponentId() : int
      {
         return data.getValue(GameStateDataEnum.OPPONENT_ID);
      }
      
      public function get opponentParty() : IEntityListDef
      {
         return data.getValue(GameStateDataEnum.OPPONENT_PARTY);
      }
      
      override public function handleMessage(param1:Object) : Boolean
      {
         var _loc2_:BattleAbortedData = null;
         var _loc3_:BattleCreateData = null;
         var _loc4_:int = 0;
         if(param1["class"] == "tbs.srv.battle.data.client.BattleAbortedData")
         {
            _loc2_ = new BattleAbortedData();
            _loc2_.parseJson(param1,logger);
            _loc3_ = data.getValue(GameStateDataEnum.BATTLE_CREATE_DATA);
            if(Boolean(_loc3_) && _loc2_.battle_id == _loc3_.battle_id)
            {
               logger.info("VersusMatchedState GOT ABORTED " + _loc2_);
               _loc4_ = data.getValue(GameStateDataEnum.BATTLE_FRIEND_LOBBY_ID);
               if(Boolean(config.factions) && _loc4_ == config.factions.lobbyManager.current.options.lobby_id)
               {
                  config.fsm.transitionTo(FriendLobbyState,null);
               }
               else
               {
                  phase = StatePhase.FAILED;
               }
               return true;
            }
         }
         return false;
      }
   }
}
