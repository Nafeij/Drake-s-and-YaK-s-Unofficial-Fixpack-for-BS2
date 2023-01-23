package game.session
{
   import engine.core.fsm.Fsm;
   import engine.core.http.HttpAction;
   import engine.core.http.HttpCommunicator;
   import engine.core.http.HttpJsonAction;
   import engine.core.util.Enum;
   import engine.session.Chat;
   import engine.session.ChatMsg;
   import engine.session.ChatRoomMsg;
   import engine.session.Credentials;
   import engine.session.ServerStatusData;
   import engine.session.Session;
   import engine.session.TxnGet;
   import game.cfg.GameConfig;
   import game.gui.IGuiDialog;
   import game.session.actions.GameLocationTxn;
   import game.session.actions.LogoutTxn;
   import game.session.actions.VsType;
   import game.session.states.AccountInfoState;
   import game.session.states.AssembleHeroesState;
   import game.session.states.AuthBuildMismatchState;
   import game.session.states.AuthFailedState;
   import game.session.states.AuthState;
   import game.session.states.FactionsState;
   import game.session.states.FlashState;
   import game.session.states.FriendLobbyState;
   import game.session.states.GreatHallState;
   import game.session.states.HallOfValorState;
   import game.session.states.HeroesState;
   import game.session.states.LoadGameState;
   import game.session.states.LoginQueueState;
   import game.session.states.MainMenuState;
   import game.session.states.MapCampLoadState;
   import game.session.states.MapCampState;
   import game.session.states.MeadHouseState;
   import game.session.states.OfflineState;
   import game.session.states.PreAuthState;
   import game.session.states.ProvingGroundsState;
   import game.session.states.ReadyState;
   import game.session.states.SagaNewGameState;
   import game.session.states.SagaSelectorState;
   import game.session.states.SagaState;
   import game.session.states.SagaSurvivalStartState;
   import game.session.states.SagaSurvivalWinState;
   import game.session.states.SceneLoadState;
   import game.session.states.SceneState;
   import game.session.states.StartState;
   import game.session.states.StartupWarningState;
   import game.session.states.TownLoadState;
   import game.session.states.TownState;
   import game.session.states.VersusCancelState;
   import game.session.states.VersusFailState;
   import game.session.states.VersusFindMatchState;
   import game.session.states.VersusMatchedState;
   import game.session.states.VideoQueueState;
   import game.session.states.VideoState;
   import game.session.states.VideoTutorial1State;
   import game.session.states.VideoTutorial2State;
   import game.session.states.tutorial.RegisterTutorialStates;
   import tbs.srv.battle.data.BattleNotification;
   import tbs.srv.data.FriendData;
   import tbs.srv.data.FriendOnlineData;
   import tbs.srv.data.GameLocationData;
   import tbs.srv.data.PurchasableUnitsData;
   import tbs.srv.data.VsQueueData;
   import tbs.srv.util.AchievementProgressData;
   import tbs.srv.util.CurrencyData;
   import tbs.srv.util.RenownMsg;
   import tbs.srv.util.SystemMsg;
   import tbs.srv.util.UnitAddData;
   import tbs.srv.util.UnlockData;
   
   public class GameFsm extends Fsm
   {
       
      
      public var config:GameConfig;
      
      public var _communicator:HttpCommunicator;
      
      public var credentials:Credentials;
      
      public var session:Session;
      
      public var chat:Chat;
      
      public var playersOnline:int;
      
      private var lastRenownMsgTimestamp:int;
      
      private var disconnectingDialog:IGuiDialog;
      
      public function GameFsm(param1:GameConfig)
      {
         super("GameFsm",param1.logger);
         this.config = param1;
         this.credentials = new Credentials(param1.username,param1.options.accountChildNumber,param1.gameServerUrl,GameConfig.PROTOCOL_VERSION,param1.logger);
         useMsgQueue();
         registerState(StartState);
         registerState(PreAuthState);
         registerState(FactionsState);
         registerState(SagaState);
         registerState(AuthState);
         registerState(AuthBuildMismatchState);
         registerState(AuthFailedState);
         registerState(AccountInfoState);
         registerState(OfflineState);
         registerState(ReadyState);
         registerState(MainMenuState);
         registerState(TownState);
         registerState(TownLoadState);
         registerState(MapCampState);
         registerState(MapCampLoadState);
         registerState(SceneState);
         registerState(SceneLoadState);
         registerState(GreatHallState);
         registerState(MeadHouseState);
         registerState(HallOfValorState);
         registerState(LoginQueueState);
         registerState(VersusFindMatchState);
         registerState(VersusCancelState);
         registerState(VersusMatchedState);
         registerState(ProvingGroundsState);
         registerState(AssembleHeroesState);
         registerState(HeroesState);
         registerState(SagaSelectorState);
         registerState(VersusFailState);
         registerState(FriendLobbyState);
         registerState(VideoQueueState);
         registerState(FlashState);
         registerState(VideoState);
         registerState(VideoTutorial1State);
         registerState(VideoTutorial2State);
         registerState(LoadGameState);
         registerState(SagaNewGameState);
         registerState(SagaSurvivalStartState);
         registerState(SagaSurvivalWinState);
         registerState(StartupWarningState);
         registerTransition(OfflineState,ReadyState,TRANS_COMPLETE);
         registerTransition(StartState,PreAuthState,TRANS_COMPLETE);
         registerTransition(PreAuthState,AuthState,TRANS_COMPLETE);
         registerTransition(AuthBuildMismatchState,AccountInfoState,TRANS_COMPLETE);
         registerTransition(AuthBuildMismatchState,AuthFailedState,TRANS_FAILED);
         registerTransition(AuthState,AccountInfoState,TRANS_COMPLETE);
         registerTransition(AuthState,AuthFailedState,TRANS_FAILED);
         registerTransition(AuthFailedState,PreAuthState,TRANS_COMPLETE);
         registerTransition(AccountInfoState,ReadyState,TRANS_COMPLETE);
         registerTransition(StartupWarningState,ReadyState,TRANS_COMPLETE);
         registerTransition(ReadyState,MainMenuState,TRANS_COMPLETE);
         registerTransition(FactionsState,TownLoadState,TRANS_COMPLETE);
         registerTransition(VideoQueueState,VideoState,TRANS_COMPLETE);
         registerTransition(SceneLoadState,SceneState,TRANS_COMPLETE);
         registerTransition(TownLoadState,TownState,TRANS_COMPLETE);
         registerTransition(MapCampLoadState,MapCampState,TRANS_COMPLETE);
         registerTransition(VersusFindMatchState,VersusMatchedState,TRANS_COMPLETE);
         registerTransition(VersusFindMatchState,VersusFailState,TRANS_FAILED);
         registerTransition(VersusMatchedState,SceneLoadState,TRANS_COMPLETE);
         registerTransition(VersusMatchedState,VersusFindMatchState,TRANS_FAILED);
         registerTransition(VideoTutorial1State,TownState,TRANS_COMPLETE);
         registerTransition(VideoTutorial2State,TownState,TRANS_COMPLETE);
         RegisterTutorialStates.register(this);
         clobberStates[AssembleHeroesState] = true;
         clobberStates[SceneLoadState] = true;
         clobberStates[TownLoadState] = true;
         clobberStates[MapCampLoadState] = true;
         clobberStates[SagaState] = true;
         clobberStates[FlashState] = true;
         clobberStates[SagaNewGameState] = true;
         initialState = StartState;
         this._communicator = new HttpCommunicator(logger,this.credentials.gameServerUrl,this.txnProcessedCallback,this.txnPollCallback);
         this.session = new Session(this._communicator,this.credentials);
         this.chat = new Chat(this.session,param1.friends,param1.logger);
      }
      
      public function get communicator() : HttpCommunicator
      {
         return this.session.communicator;
      }
      
      override protected function cleanup() : void
      {
         this.config.runShutdownFunctions();
         this.logout();
      }
      
      public function logout() : void
      {
         var _loc1_:LogoutTxn = null;
         if(this.session.credentials.sessionKey)
         {
            _loc1_ = new LogoutTxn(this.session.credentials,null,logger);
            this.session.credentials.sessionKey = null;
            _loc1_.send(this.session.communicator);
            if(this.session.communicator)
            {
               this.session.communicator.connected = false;
            }
            this.session.credentials.offline = true;
         }
      }
      
      public function get currentGameState() : GameState
      {
         return current as GameState;
      }
      
      override public function handleOneMessage(param1:Object) : Boolean
      {
         var _loc2_:VsQueueData = null;
         var _loc3_:VsType = null;
         var _loc4_:AchievementProgressData = null;
         var _loc5_:GameLocationData = null;
         var _loc6_:FriendOnlineData = null;
         var _loc7_:FriendData = null;
         var _loc8_:ChatMsg = null;
         var _loc9_:FriendData = null;
         var _loc10_:PurchasableUnitsData = null;
         var _loc11_:ServerStatusData = null;
         var _loc12_:ChatMsg = null;
         var _loc13_:ChatRoomMsg = null;
         var _loc14_:SystemMsg = null;
         var _loc15_:BattleNotification = null;
         var _loc16_:RenownMsg = null;
         var _loc17_:UnlockData = null;
         var _loc18_:UnitAddData = null;
         var _loc19_:CurrencyData = null;
         if(!current)
         {
            return false;
         }
         if(this.config.factions)
         {
            if(this.config.factions.handleOneMessage(param1))
            {
               return true;
            }
         }
         if(param1["class"] == "tbs.srv.data.VsQueueData")
         {
            if(this.config.factions)
            {
               _loc2_ = new VsQueueData().parseJson(param1,logger);
               _loc3_ = Enum.parse(VsType,_loc2_.type,false) as VsType;
               this.config.factions.vsmonitor.updateEntry(_loc3_,_loc2_.powers,_loc2_.counts);
            }
            return true;
         }
         if(param1["class"] == "tbs.srv.util.AchievementProgressData")
         {
            _loc4_ = new AchievementProgressData();
            _loc4_.parseJson(param1,logger);
            logger.debug("handleOneMessage: " + _loc4_);
            return true;
         }
         if(param1["class"] == "tbs.srv.data.GameLocationData")
         {
            _loc5_ = new GameLocationData();
            _loc5_.parseJson(param1,logger);
            this.config.friends.updateLocation(_loc5_);
            return true;
         }
         if(param1["class"] == "tbs.srv.data.FriendOnlineData")
         {
            _loc6_ = new FriendOnlineData();
            _loc6_.parseJson(param1,logger);
            _loc7_ = this.config.friends.updateOnline(_loc6_);
            if(_loc7_)
            {
               _loc8_ = new ChatMsg();
               _loc8_.room = Chat.GLOBAL_ROOM;
               _loc8_.username = "FRIEND";
               if(_loc6_.online)
               {
                  _loc8_.msg = _loc7_.display_name + " has logged in.";
               }
               else
               {
                  _loc8_.msg = _loc7_.display_name + " has logged out.";
               }
               this.chat.handleChatMsg(_loc8_);
            }
            return true;
         }
         if(param1["class"] == "tbs.srv.data.FriendData")
         {
            _loc9_ = new FriendData();
            _loc9_.parseJson(param1,logger);
            this.config.friends.addFriendData(_loc9_);
            return true;
         }
         if(param1["class"] == "tbs.srv.data.FriendsData")
         {
            this.config.friends.parseJson(param1,logger);
            return true;
         }
         if(param1["class"] == "tbs.srv.data.PurchasableUnitsData")
         {
            _loc10_ = new PurchasableUnitsData();
            _loc10_.parseJson(param1,logger);
            this.config.purchasableUnits.update(_loc10_);
            return true;
         }
         if(param1["class"] == "tbs.srv.data.ServerStatusData")
         {
            _loc11_ = ServerStatusData.parse(param1);
            logger.debug("ServerStatusData: " + _loc11_);
            this.playersOnline = _loc11_.session_count;
            dispatchEvent(new GameFsmEvent(GameFsmEvent.PLAYERS_ONLINE));
            return true;
         }
         if(param1["class"] == "tbs.srv.chat.ChatMsg")
         {
            _loc12_ = ChatMsg.parse(param1);
            this.chat.handleChatMsg(_loc12_);
            return true;
         }
         if(param1["class"] == "tbs.srv.chat.ChatRoomMsg")
         {
            _loc13_ = new ChatRoomMsg();
            _loc13_.parseJson(param1,logger);
            this.chat.handleChatRoomMsg(_loc13_);
            return true;
         }
         if(param1["class"] == "tbs.srv.util.SystemMsg")
         {
            _loc14_ = new SystemMsg();
            _loc14_.parseJson(param1,logger);
            this.config.systemMessage.msg = _loc14_.msg;
            return true;
         }
         if(param1["class"] == "tbs.srv.battle.data.BattleNotification")
         {
            _loc15_ = new BattleNotification();
            _loc15_.parseJson(param1,logger);
            return true;
         }
         if(param1["class"] == "tbs.srv.util.RenownMsg")
         {
            _loc16_ = new RenownMsg();
            _loc16_.parseJson(param1,logger);
            if(_loc16_.timestamp > this.lastRenownMsgTimestamp)
            {
               this.lastRenownMsgTimestamp = _loc16_.timestamp;
               logger.debug("RenownMsg: " + _loc16_);
               if(this.config.accountInfo)
               {
                  this.config.accountInfo.legend.renown = _loc16_.total;
               }
               if(this.config.factions)
               {
                  this.config.factions.legend.renown = _loc16_.total;
               }
            }
            else
            {
               logger.debug("RenownMsg IGNORE OLD: " + _loc16_);
            }
            return true;
         }
         if(param1["class"] == "tbs.srv.util.UnlockData")
         {
            _loc17_ = new UnlockData();
            _loc17_.parseJson(param1,logger);
            this.config.accountInfo.handleUnlock(_loc17_);
            return true;
         }
         if(param1["class"] == "tbs.srv.util.UnitAddData")
         {
            _loc18_ = new UnitAddData();
            _loc18_.parseJson(param1,logger);
            this.config.legend.handleUnitAdd(_loc18_);
            return true;
         }
         if(param1["class"] == "tbs.srv.util.CurrencyData")
         {
            _loc19_ = new CurrencyData();
            _loc19_.parseJson(param1,logger);
            if(this.config.accountInfo)
            {
               this.config.accountInfo.handleCurrencyData(_loc19_);
            }
            return true;
         }
         if(!super.handleOneMessage(param1))
         {
            if(param1.error_msg != undefined)
            {
               return true;
            }
            return false;
         }
         return true;
      }
      
      override public function startFsm(param1:Object) : void
      {
         super.startFsm(param1);
      }
      
      private function disconnectedDialogCallback(param1:String) : void
      {
         this.disconnectingDialog = null;
         transitionTo(PreAuthState,!!current ? current.data : null);
      }
      
      private function maintenanceDialogCallback(param1:String) : void
      {
         this.disconnectingDialog = null;
         this.config.context.appInfo.exitGame("Server Maintenance");
      }
      
      private function showDisconnectingDialog() : void
      {
         var _loc1_:String = null;
         var _loc2_:String = null;
         var _loc3_:String = null;
         if(!this.disconnectingDialog)
         {
            this.communicator.connected = false;
            this.session.credentials.offline = true;
            this.disconnectingDialog = this.config.gameGuiContext.createDialog();
            _loc1_ = this.config.gameGuiContext.translate("disconnected_title");
            _loc2_ = this.config.gameGuiContext.translate("disconnected_body");
            _loc3_ = this.config.gameGuiContext.translate("ok");
            this.disconnectingDialog.openDialog(_loc1_,_loc2_,_loc3_,this.disconnectedDialogCallback);
         }
      }
      
      private function txnProcessedCallback(param1:HttpAction) : void
      {
         var _loc2_:* = false;
         var _loc3_:* = false;
         var _loc4_:String = null;
         var _loc5_:String = null;
         var _loc6_:String = null;
         var _loc7_:HttpJsonAction = null;
         if(param1.responseCode == 401)
         {
            if(currentClass != PreAuthState && currentClass != AuthState && currentClass != AuthFailedState)
            {
               param1.abort();
               this.showDisconnectingDialog();
               return;
            }
         }
         else if(param1.isMaintenance)
         {
            _loc2_ = param1.response.indexOf("Offline for Maintenance") >= 0;
            _loc3_ = param1.response.indexOf("game_rebooting") >= 0;
            if(_loc2_ || _loc3_)
            {
               param1.abort();
               if(!this.disconnectingDialog)
               {
                  this.communicator.connected = false;
                  this.session.credentials.offline = true;
                  this.disconnectingDialog = this.config.gameGuiContext.createDialog();
                  _loc6_ = this.config.gameGuiContext.translate("ok");
                  if(_loc2_)
                  {
                     _loc4_ = this.config.gameGuiContext.translate("server_offline_title");
                     _loc5_ = this.config.gameGuiContext.translate("server_offline_body");
                     this.disconnectingDialog.openDialog(_loc4_,_loc5_,_loc6_,this.maintenanceDialogCallback);
                  }
                  else
                  {
                     _loc4_ = this.config.gameGuiContext.translate("server_rebooting_title");
                     _loc5_ = this.config.gameGuiContext.translate("server_rebooting_body");
                     this.disconnectingDialog.openDialog(_loc4_,_loc5_,_loc6_,this.maintenanceDialogCallback);
                  }
               }
               return;
            }
         }
         if(param1 is HttpJsonAction)
         {
            _loc7_ = param1 as HttpJsonAction;
            if(_loc7_.jsonObject)
            {
               logger.debug("GameFsm INCOMING MSG " + current + ": " + _loc7_.response);
               handleMessage(_loc7_.jsonObject);
            }
         }
      }
      
      private function txnPollCallback() : HttpJsonAction
      {
         if(Boolean(this.session.credentials.sessionKey) && !this.session.credentials.offline)
         {
            return new TxnGet(this.session.credentials,null,logger);
         }
         return null;
      }
      
      public function updateGameLocation(param1:String) : void
      {
         var _loc2_:GameLocationTxn = null;
         if(Boolean(this.session.credentials.sessionKey) && !this.session.credentials.offline)
         {
            _loc2_ = new GameLocationTxn(this.session.credentials,param1,logger);
            _loc2_.send(this.session.communicator);
         }
      }
   }
}
