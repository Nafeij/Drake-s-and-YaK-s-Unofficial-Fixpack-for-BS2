package game.cfg
{
   import engine.core.logging.ILogger;
   import engine.core.util.Enum;
   import engine.entity.def.EntityListDef;
   import engine.entity.def.EntityListDefVars;
   import engine.entity.def.IEntityDef;
   import engine.session.Alert;
   import engine.session.AlertEvent;
   import engine.session.AlertManager;
   import engine.session.AlertOrientationType;
   import engine.session.AlertStyleType;
   import engine.session.Chat;
   import game.session.actions.LobbyInviteTxn;
   import game.session.actions.LobbyOptionsTxn;
   import game.session.actions.LobbyTxn;
   import tbs.srv.data.LobbyData;
   import tbs.srv.data.LobbyDataType;
   import tbs.srv.data.LobbyOptionsData;
   import tbs.srv.data.LobbyPartyData;
   import tbs.srv.data.LobbyVariationData;
   
   public class Lobby implements ILobby
   {
       
      
      private var _options:LobbyOptionsData;
      
      private var _members:Vector.<LobbyMemberInfo>;
      
      private var _manager:LobbyManager;
      
      private var _joined:Boolean;
      
      private var _alert:Alert;
      
      private var _terminated:Boolean;
      
      private var _alertManager:AlertManager;
      
      private var _local_account_id:int;
      
      public function Lobby(param1:LobbyManager, param2:LobbyOptionsData, param3:AlertManager)
      {
         var _loc5_:String = null;
         var _loc6_:* = null;
         var _loc7_:String = null;
         this._members = new Vector.<LobbyMemberInfo>();
         super();
         this._manager = param1;
         this._options = param2;
         this._alertManager = param3;
         this._local_account_id = param1.config.fsm.credentials.userId;
         var _loc4_:LobbyMemberInfo = this.doAdd(param2.lobby_id,param2.display_name);
         _loc4_.joined = true;
         if(this._local_account_id != this._options.lobby_id)
         {
            _loc5_ = this._manager.config.gameGuiContext.translate("alert_to_battle");
            _loc6_ = this._manager.config.gameGuiContext.translateTaunt(param2.msg) + "...";
            _loc7_ = _loc6_ + "\n<p align=\'right\'>" + _loc5_;
            this._alert = Alert.create(param2.lobby_id,param2.display_name,_loc7_,"Go Now","Decline",AlertOrientationType.RIGHT,AlertStyleType.NORMAL,param2);
            param3.addAlert(this._alert);
            this._alert.addEventListener(AlertEvent.ALERT_RESPONSE,this.inviteAlertResponseHandler);
         }
      }
      
      public function get manager() : ILobbyManager
      {
         return this._manager;
      }
      
      private function inviteAlertResponseHandler(param1:AlertEvent) : void
      {
         if(param1.alert.response == Alert.RESPONSE_OK)
         {
            this.join();
         }
         else
         {
            this.decline();
         }
      }
      
      public function cleanup() : void
      {
         if(this._alert)
         {
            this._alert.removeEventListener(AlertEvent.ALERT_RESPONSE,this.inviteAlertResponseHandler);
            this._alert.response = Alert.RESPONSE_EXIT;
         }
      }
      
      public function get other() : LobbyMemberInfo
      {
         if(this._members.length > 1)
         {
            if(this == this._manager.myLobby)
            {
               return this._members[1];
            }
            return this._members[0];
         }
         return null;
      }
      
      public function invite(param1:int, param2:String, param3:String) : void
      {
         this.doAdd(param1,param2);
         this._options.account_display_name = param2;
         this._options.account_id = param1;
         this._options.msg = param3;
         new LobbyInviteTxn(this._manager.config.fsm.credentials,this.logger,this._options).send(this._manager.config.fsm.communicator);
      }
      
      public function uninvite(param1:int) : void
      {
         this.doRemove(param1);
         new LobbyTxn(this._manager.config.fsm.credentials,this.logger,"uninvite",param1).send(this._manager.config.fsm.communicator);
      }
      
      public function join() : void
      {
         if(this._joined)
         {
            return;
         }
         this._joined = true;
         this._manager.current = this;
         new LobbyTxn(this._manager.config.fsm.credentials,this.logger,"join",this._options.lobby_id).send(this._manager.config.fsm.communicator);
      }
      
      public function decline() : void
      {
         if(this._joined)
         {
            return;
         }
         new LobbyTxn(this._manager.config.fsm.credentials,this.logger,"decline",this._options.lobby_id).send(this._manager.config.fsm.communicator);
      }
      
      public function exit() : void
      {
         if(this._terminated)
         {
            return;
         }
         if(this == this._manager.myLobby)
         {
            this.doFlushLobby();
         }
         else
         {
            if(!this._joined)
            {
               return;
            }
            this._joined = false;
            this._manager.current = this._manager.myLobby;
            this.doRemove(this._manager.config.fsm.credentials.userId);
         }
         new LobbyTxn(this._manager.config.fsm.credentials,this.logger,"exit",this._options.lobby_id).send(this._manager.config.fsm.communicator);
      }
      
      public function set ready(param1:Boolean) : void
      {
         var _loc2_:LobbyMemberInfo = this.getLobbyMemberInfo(this.local_account_id);
         if(_loc2_)
         {
            param1 = param1 && _loc2_.party.length > 0;
         }
         this.doReady(this.local_account_id,param1);
         if(param1)
         {
            new LobbyTxn(this._manager.config.fsm.credentials,this.logger,"ready",this._options.lobby_id).send(this._manager.config.fsm.communicator);
         }
         else
         {
            new LobbyTxn(this._manager.config.fsm.credentials,this.logger,"unready",this._options.lobby_id).send(this._manager.config.fsm.communicator);
         }
      }
      
      public function get ready() : Boolean
      {
         var _loc1_:LobbyMemberInfo = this.getLobbyMemberInfo(this._manager.config.fsm.credentials.userId);
         return Boolean(_loc1_) && _loc1_.ready && _loc1_.party.length > 0;
      }
      
      public function set scene(param1:String) : void
      {
         this._options.scene = param1;
      }
      
      public function set timer(param1:String) : void
      {
         this._options.scene = param1;
      }
      
      public function sendOptions() : void
      {
         new LobbyOptionsTxn(this._manager.config.fsm.credentials,this.logger,this._options).send(this._manager.config.fsm.communicator);
      }
      
      public function get logger() : ILogger
      {
         return this._manager.logger;
      }
      
      public function getLobbyMemberInfo(param1:int) : LobbyMemberInfo
      {
         var _loc2_:LobbyMemberInfo = null;
         for each(_loc2_ in this._members)
         {
            if(_loc2_.id == param1)
            {
               return _loc2_;
            }
         }
         return null;
      }
      
      public function handleData(param1:LobbyData) : void
      {
         var _loc2_:LobbyDataType = Enum.parse(LobbyDataType,param1.type) as LobbyDataType;
         switch(_loc2_)
         {
            case LobbyDataType.INVITE:
               throw new ArgumentError("Can\'t invite this way");
            case LobbyDataType.UNINVITE:
               this.doRemove(param1.account_id);
               break;
            case LobbyDataType.DECLINE:
               this.doAlert(param1,"alert_declined");
               this.doRemove(param1.account_id);
               break;
            case LobbyDataType.EXIT:
               this.doAlert(param1,"alert_exited");
               this.doRemove(param1.account_id);
               break;
            case LobbyDataType.READY:
               this.doReady(param1.account_id,true);
               break;
            case LobbyDataType.UNREADY:
               this.doReady(param1.account_id,false);
               break;
            case LobbyDataType.OPTIONS:
               this._options = param1 as LobbyOptionsData;
               this.ready = false;
               break;
            case LobbyDataType.JOIN:
               this.doPartyData(param1 as LobbyPartyData);
               this.doAlert(param1,"alert_joined");
               break;
            case LobbyDataType.PARTY:
               this.doPartyData(param1 as LobbyPartyData);
               break;
            case LobbyDataType.VARIATION:
               this.doVariationData(param1 as LobbyVariationData);
               break;
            case LobbyDataType.TERMINATED:
               this.doAlert(param1,"alert_terminated");
         }
      }
      
      private function doAlert(param1:LobbyData, param2:String) : void
      {
         var _loc6_:LobbyMemberInfo = null;
         if(this._local_account_id == param1.account_id)
         {
            return;
         }
         var _loc3_:ILobby = this._manager.getLobby(param1.lobby_id);
         var _loc4_:String = param1.account_display_name;
         if(!_loc4_)
         {
            _loc6_ = !!_loc3_ ? _loc3_.getLobbyMemberInfo(param1.account_id) : null;
            if(_loc6_)
            {
               _loc4_ = _loc6_.display_name;
            }
         }
         var _loc5_:String = this._manager.config.gameGuiContext.translate(param2);
         this._alert = Alert.create(param1.account_id,_loc4_,_loc5_,null,null,AlertOrientationType.RIGHT,AlertStyleType.NORMAL,param1);
         this._alertManager.addAlert(this._alert);
      }
      
      public function doAdd(param1:int, param2:String) : LobbyMemberInfo
      {
         var _loc3_:LobbyMemberInfo = this.getLobbyMemberInfo(param1);
         if(_loc3_)
         {
            return _loc3_;
         }
         if(!param2)
         {
            this.logger.error("No display name on: " + param1);
            return null;
         }
         _loc3_ = new LobbyMemberInfo(param1,param2);
         this._members.push(_loc3_);
         return _loc3_;
      }
      
      private function doFlushLobby() : void
      {
         this._members.splice(1,this._members.length);
      }
      
      private function doRemove(param1:int) : void
      {
         var _loc3_:int = 0;
         var _loc2_:LobbyMemberInfo = this.getLobbyMemberInfo(param1);
         if(_loc2_)
         {
            _loc3_ = this._members.indexOf(_loc2_);
            this._members.splice(_loc3_,1);
         }
      }
      
      private function doPartyData(param1:LobbyPartyData) : void
      {
         var _loc3_:GameConfig = null;
         var _loc4_:EntityListDef = null;
         var _loc2_:LobbyMemberInfo = this.getLobbyMemberInfo(param1.account_id);
         if(_loc2_)
         {
            _loc2_.joined = true;
            if(param1.party)
            {
               _loc3_ = this._manager.config;
               _loc4_ = new EntityListDefVars(_loc3_.context.locale,this.logger).fromJson({"defs":param1.party},this.logger,_loc3_.abilityFactory,_loc3_.classes,_loc3_,true,_loc3_.itemDefs);
               _loc2_.party = _loc4_.entityDefs;
            }
         }
      }
      
      private function doVariationData(param1:LobbyVariationData) : void
      {
         var _loc3_:IEntityDef = null;
         var _loc2_:LobbyMemberInfo = this.getLobbyMemberInfo(param1.account_id);
         if(_loc2_)
         {
            _loc2_.joined = true;
            for each(_loc3_ in _loc2_.party)
            {
               if(_loc3_.id == param1.unit_id)
               {
                  _loc3_.appearanceIndex = param1.variation;
                  break;
               }
            }
         }
      }
      
      private function doReady(param1:int, param2:Boolean) : void
      {
         var _loc3_:LobbyMemberInfo = this.getLobbyMemberInfo(param1);
         if(_loc3_)
         {
            _loc3_.ready = param2;
         }
      }
      
      public function get options() : LobbyOptionsData
      {
         return this._options;
      }
      
      public function get terminated() : Boolean
      {
         return this._terminated;
      }
      
      public function set terminated(param1:Boolean) : void
      {
         if(this._terminated == param1)
         {
            return;
         }
         this._terminated = param1;
         if(this._terminated)
         {
            if(this._alert)
            {
               this._alert.response = Alert.RESPONSE_EXIT;
            }
         }
      }
      
      public function get joined() : Boolean
      {
         return this._joined;
      }
      
      public function get local_account_id() : int
      {
         return this._local_account_id;
      }
      
      public function get chatRoomId() : String
      {
         return Chat.LOBBY_ROOM_PREFIX + "_" + this.options.lobby_id;
      }
   }
}
