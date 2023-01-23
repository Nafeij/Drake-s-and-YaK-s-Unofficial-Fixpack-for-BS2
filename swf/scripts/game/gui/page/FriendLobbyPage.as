package game.gui.page
{
   import engine.core.fsm.State;
   import engine.core.fsm.StateData;
   import flash.display.MovieClip;
   import flash.geom.Point;
   import game.cfg.GameConfig;
   import game.cfg.ILobby;
   import game.cfg.LobbyManagerEvent;
   import game.gui.GamePage;
   import game.session.actions.VsType;
   import game.session.states.GameStateDataEnum;
   import game.session.states.GreatHallState;
   import game.session.states.ProvingGroundsState;
   import game.session.states.VersusFindMatchState;
   import tbs.srv.data.FriendData;
   import tbs.srv.data.LobbyDataType;
   
   public class FriendLobbyPage extends GamePage implements IGuiFriendLobbyListener
   {
       
      
      private var gui:IGuiFriendLobby;
      
      private var chatHelper:GlobalChatHelper;
      
      public function FriendLobbyPage(param1:GameConfig)
      {
         super(param1);
         this.chatHelper = new GlobalChatHelper(this,param1,this.currentId);
         this.chatHelper.align = "topcenter";
         this.chatHelper.showChatButton = false;
         this.updateChatAlignment();
      }
      
      private function get current() : ILobby
      {
         if(config.factions)
         {
            return config.factions.lobbyManager.current;
         }
         return null;
      }
      
      private function get currentId() : String
      {
         if(config.factions)
         {
            return config.factions.lobbyManager.current.chatRoomId;
         }
         return null;
      }
      
      override public function cleanup() : void
      {
         super.cleanup();
         if(config.factions)
         {
            config.factions.lobbyManager.removeEventListener(LobbyManagerEvent.DATA,this.lobbyManagerEventDataHandler);
            config.factions.lobbyManager.removeEventListener(LobbyManagerEvent.CURRENT,this.lobbyManagerEventCurrentHandler);
         }
         this.chatHelper.cleanup();
      }
      
      override protected function handleStart() : void
      {
      }
      
      override protected function handleLoaded() : void
      {
         if(!this.gui)
         {
            if(fullScreenMc)
            {
               this.gui = fullScreenMc as IGuiFriendLobby;
               this.gui.init(config.gameGuiContext,this);
               this.gui.lobby = this.current;
            }
         }
      }
      
      public function guiFriendLobbyExit() : void
      {
         config.fsm.transitionTo(GreatHallState,config.fsm.current.data);
      }
      
      override protected function handleDelayStart() : void
      {
         if(config.factions)
         {
            config.factions.lobbyManager.addEventListener(LobbyManagerEvent.DATA,this.lobbyManagerEventDataHandler);
            config.factions.lobbyManager.addEventListener(LobbyManagerEvent.CURRENT,this.lobbyManagerEventCurrentHandler);
         }
         this.updateChatAlignment();
         this.chatHelper.bringToFront();
      }
      
      private function lobbyManagerEventCurrentHandler(param1:LobbyManagerEvent) : void
      {
         this.chatHelper.chatroom = this.currentId;
         if(this.gui)
         {
            this.gui.lobby = this.current;
         }
      }
      
      override protected function resizeHandler() : void
      {
         super.resizeHandler();
         this.updateChatAlignment();
      }
      
      private function updateChatAlignment() : void
      {
         var _loc1_:Point = null;
         var _loc2_:Point = null;
         if(this.gui)
         {
            _loc1_ = new Point(545,0);
            _loc2_ = (this.gui as MovieClip).localToGlobal(_loc1_);
            this.chatHelper.alignLeftGlobal = _loc2_.x - 50;
         }
         this.chatHelper.align = "upperleft";
         this.chatHelper.resize();
      }
      
      public function guiFriendLobbyInvite(param1:FriendData, param2:String) : void
      {
         if(config.factions)
         {
            config.factions.lobbyManager.myLobby.invite(param1.id,param1.display_name,param2);
         }
      }
      
      private function lobbyManagerEventDataHandler(param1:LobbyManagerEvent) : void
      {
         var _loc2_:ILobby = null;
         if(Boolean(this.gui) && Boolean(this.gui.lobby))
         {
            if(param1.data.lobby_id == this.gui.lobby.options.lobby_id)
            {
               if(param1.data.type == LobbyDataType.DECLINE.name || param1.data.type == LobbyDataType.EXIT.name)
               {
                  if(Boolean(this.gui.friend) && this.gui.friend.id == param1.data.account_id)
                  {
                     this.gui.friend = null;
                  }
               }
            }
            this.gui.update();
            if(param1.data.account_id != config.fsm.credentials.userId)
            {
            }
            _loc2_ = this.current;
            if(_loc2_.ready && _loc2_.other.ready)
            {
               this.launchMatch();
            }
         }
      }
      
      private function launchMatch() : void
      {
         var _loc1_:StateData = config.fsm.current.data;
         var _loc2_:ILobby = this.current;
         _loc1_.setValue(GameStateDataEnum.FORCE_OPPONENT_ID,_loc2_.other.id);
         _loc1_.setValue(GameStateDataEnum.BATTLE_SCENE_ID,_loc2_.options.scene);
         _loc1_.setValue(GameStateDataEnum.BATTLE_TIMER_SECS,_loc2_.options.timer);
         _loc1_.setValue(GameStateDataEnum.BATTLE_FRIEND_LOBBY_ID,_loc2_.options.lobby_id);
         _loc1_.setValue(GameStateDataEnum.VERSUS_TOURNEY_ID,0);
         _loc1_.setValue(GameStateDataEnum.VERSUS_TYPE,VsType.FRIEND);
         config.fsm.transitionTo(VersusFindMatchState,_loc1_);
      }
      
      public function guiGoToProvingGrounds() : void
      {
         var _loc1_:State = config.fsm.current;
         config.fsm.transitionTo(ProvingGroundsState,_loc1_.data);
      }
   }
}
