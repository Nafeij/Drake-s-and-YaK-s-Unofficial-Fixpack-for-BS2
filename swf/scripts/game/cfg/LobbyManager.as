package game.cfg
{
   import engine.battle.SceneListDef;
   import engine.core.logging.ILogger;
   import flash.events.EventDispatcher;
   import flash.utils.Dictionary;
   import tbs.srv.data.LobbyData;
   import tbs.srv.data.LobbyDataType;
   import tbs.srv.data.LobbyOptionsData;
   import tbs.srv.data.LobbyPartyData;
   import tbs.srv.data.LobbyVariationData;
   
   public class LobbyManager extends EventDispatcher implements ILobbyManager
   {
       
      
      public var config:GameConfig;
      
      private var lobbies:Dictionary;
      
      private var _myLobby:Lobby;
      
      private var _current:Lobby;
      
      public function LobbyManager(param1:GameConfig)
      {
         this.lobbies = new Dictionary();
         super();
         this.config = param1;
      }
      
      public function cleanup() : void
      {
      }
      
      public function get logger() : ILogger
      {
         return this.config.logger;
      }
      
      public function handleOneMsg(param1:Object) : Boolean
      {
         var _loc3_:LobbyData = null;
         var _loc4_:LobbyOptionsData = null;
         var _loc5_:LobbyPartyData = null;
         var _loc6_:LobbyVariationData = null;
         var _loc2_:String = String(param1["class"]);
         switch(_loc2_)
         {
            case "tbs.srv.data.LobbyData":
               _loc3_ = new LobbyData();
               _loc3_.parseJson(param1,this.logger);
               this.handleData(_loc3_);
               return true;
            case "tbs.srv.data.LobbyOptionsData":
               _loc4_ = new LobbyOptionsData();
               _loc4_.parseJson(param1,this.logger);
               this.handleData(_loc4_);
               return true;
            case "tbs.srv.data.LobbyPartyData":
               _loc5_ = new LobbyPartyData();
               _loc5_.parseJson(param1,this.logger);
               this.handleData(_loc5_);
               return true;
            case "tbs.srv.data.LobbyUnitVariationData":
               _loc6_ = new LobbyVariationData();
               _loc6_.parseJson(param1,this.logger);
               this.handleData(_loc6_);
               return true;
            default:
               return false;
         }
      }
      
      public function handleData(param1:LobbyData) : void
      {
         var _loc2_:Lobby = null;
         var _loc3_:Lobby = null;
         var _loc4_:Lobby = null;
         if(param1.type == LobbyDataType.INVITE.name)
         {
            if(param1.lobby_id == this.myLobby.options.lobby_id)
            {
               return;
            }
            _loc3_ = this.lobbies[param1.lobby_id];
            if(_loc3_)
            {
               _loc3_.cleanup();
            }
            _loc2_ = new Lobby(this,param1 as LobbyOptionsData,this.config.alerts);
            _loc2_.doAdd(this.config.fsm.credentials.userId,this.config.fsm.credentials.displayName);
            this.lobbies[_loc2_.options.lobby_id] = _loc2_;
         }
         else if(param1.type == LobbyDataType.TERMINATED.name)
         {
            if(param1.lobby_id != this.myLobby.options.lobby_id)
            {
               _loc4_ = this.lobbies[param1.lobby_id];
               if(_loc4_)
               {
                  _loc4_.terminated = true;
                  if(_loc4_ == this.current)
                  {
                     this.current = this.myLobby;
                  }
                  _loc4_.cleanup();
                  delete this.lobbies[param1.lobby_id];
               }
            }
         }
         else
         {
            _loc2_ = this.getLobby(param1.lobby_id) as Lobby;
            if(_loc2_)
            {
               _loc2_.handleData(param1);
            }
         }
         dispatchEvent(new LobbyManagerEvent(LobbyManagerEvent.DATA,param1));
      }
      
      public function get myLobby() : ILobby
      {
         var _loc1_:SceneListDef = null;
         var _loc2_:LobbyOptionsData = null;
         var _loc3_:int = 0;
         if(!this._myLobby)
         {
            if(this.config.factions)
            {
               _loc1_ = this.config.factions.sceneListDef;
               _loc2_ = new LobbyOptionsData();
               _loc2_.lobby_id = this.config.fsm.credentials.userId;
               _loc2_.display_name = this.config.fsm.credentials.displayName;
               _loc3_ = int(Math.random() * _loc1_.items.length - 0.5);
               _loc2_.scene = _loc1_.items[_loc3_].id;
               this._myLobby = new Lobby(this,_loc2_,this.config.alerts);
               this.lobbies[this._myLobby.options.lobby_id] = this._myLobby;
            }
         }
         return this._myLobby;
      }
      
      public function get current() : ILobby
      {
         return !!this._current ? this._current : this.myLobby;
      }
      
      public function set current(param1:ILobby) : void
      {
         if(this._current == param1)
         {
            return;
         }
         if(this._current)
         {
            this._current.exit();
         }
         this._current = param1 as Lobby;
         if(!this._current)
         {
         }
         dispatchEvent(new LobbyManagerEvent(LobbyManagerEvent.CURRENT,null));
      }
      
      public function getLobby(param1:int) : ILobby
      {
         var _loc2_:Lobby = this.lobbies[param1];
         if(_loc2_)
         {
         }
         return _loc2_;
      }
   }
}
