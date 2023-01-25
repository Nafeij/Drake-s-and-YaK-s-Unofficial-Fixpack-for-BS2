package game.cfg
{
   import engine.achievement.AchievementListDef;
   import engine.achievement.AchievementListDefVars;
   import engine.battle.SceneListDef;
   import engine.battle.SceneListDefVars;
   import engine.core.cmd.CmdExec;
   import engine.core.logging.ILogger;
   import engine.core.util.EngineCoreContext;
   import engine.resource.def.DefWranglerWrangler;
   import engine.session.IIapManager;
   import engine.tourney.TourneyDefList;
   import flash.events.Event;
   import game.session.states.FriendLobbyState;
   import tbs.srv.util.InAppPurchaseItemListDef;
   
   public class FactionsConfig
   {
      
      private static const IAP_DEFS_URL:String = "factions/iap/in_app_purchase.json.z";
      
      private static const TOURNEY_DEF_LIST_URL:String = "factions/tourney/tourney_defs.json.z";
      
      private static const ACHIEVEMENT_DEFS_URL:String = "factions/achievement/achievement_defs.json.z";
      
      private static const SCENE_LIST_URL:String = "factions/battle/battle_scene_list.json.z";
      
      private static const STARTING_ROSTER_URL:String = "factions/character/starting_roster.json.z";
      
      public static var iapManagerClazz:Class;
       
      
      public var tourneys:TourneyManager;
      
      public var leaderboards:LeaderboardsManager;
      
      public var lobbyManager:LobbyManager;
      
      public var inAppPurchaseItemListDef:InAppPurchaseItemListDef;
      
      public var iapManager:IIapManager;
      
      public var tourneyDefList:TourneyDefList;
      
      public var ready:Boolean;
      
      private var readyCallback:Function;
      
      public var config:GameConfig;
      
      private var wranglers:DefWranglerWrangler;
      
      public var legend:FactionsLegend;
      
      public var vsmonitor:VsMonitor;
      
      public var achievementListDef:AchievementListDef;
      
      public var sceneListDef:SceneListDef;
      
      public var starting_roster:AccountInfoDef;
      
      public var namegen:NameGenerator;
      
      public function FactionsConfig(param1:GameConfig, param2:Function)
      {
         super();
         this.config = param1;
         this.readyCallback = param2;
         this.wranglers = new DefWranglerWrangler("FactionsConfig",param1.resman,param1.logger);
         this.legend = new FactionsLegend(param1.statCosts.roster_slots_per_row,this);
         param1.addEventListener(GameConfig.EVENT_ACCOUNT_INFO,this.accountInfoHandler);
         this.addShellCommands();
         this.leaderboards = new LeaderboardsManager(param1);
         this.lobbyManager = new LobbyManager(param1);
         this.tourneys = new TourneyManager(param1);
         this.vsmonitor = new VsMonitor(this);
         this.namegen = new NameGenerator(param1.resman,this.namegenCompleteHandler);
         this.lobbyManager.addEventListener(LobbyManagerEvent.CURRENT,this.lobbyManagerEventCurrentHandler);
      }
      
      public function cleanup() : void
      {
         this.lobbyManager.removeEventListener(LobbyManagerEvent.CURRENT,this.lobbyManagerEventCurrentHandler);
         this.config.removeEventListener(GameConfig.EVENT_ACCOUNT_INFO,this.accountInfoHandler);
         this.removeShellCommands();
         this.tourneys.cleanup();
         this.tourneys = null;
         this.lobbyManager.cleanup();
         this.lobbyManager = null;
         this.leaderboards.cleanup();
         this.leaderboards = null;
         this.vsmonitor.cleanup();
         this.vsmonitor = null;
         this.namegen.cleanup();
         this.namegen = null;
      }
      
      private function lobbyManagerEventCurrentHandler(param1:LobbyManagerEvent) : void
      {
         if(this.lobbyManager.current != this.lobbyManager.myLobby)
         {
            this.config.fsm.transitionTo(FriendLobbyState,this.config.fsm.current.data);
         }
      }
      
      private function addShellCommands() : void
      {
         this.config.shell.add("leaderboards",this.shellFuncLeaderboardsEvents);
         this.config.shell.add("iap",this.shellFuncIap);
         this.config.shell.add("vsmon",this.shellFuncVsmon);
      }
      
      private function removeShellCommands() : void
      {
         this.config.shell.removeShell("leaderboards");
         this.config.shell.removeShell("iap");
         this.config.shell.removeShell("vsmon");
      }
      
      private function accountInfoHandler(param1:Event) : void
      {
         this.iapManager.purchases = this.config.accountInfo.purchases;
         this.iapManager.sandbox = this.config.accountInfo.iap_sandbox;
         this.iapManager.gameData = this.config.factions.legend;
      }
      
      public function get context() : EngineCoreContext
      {
         return this.config.context;
      }
      
      public function get logger() : ILogger
      {
         return this.config.logger;
      }
      
      private function finishReady() : void
      {
         var _loc1_:AccountInfoDef = this.config.accountInfo;
         this.sceneListDef = new SceneListDefVars(this.wranglers.wrangled(SCENE_LIST_URL).vars,this.logger);
         this.achievementListDef = new AchievementListDefVars(this.wranglers.wrangled(ACHIEVEMENT_DEFS_URL).vars,this.logger,this.context.locale);
         this.inAppPurchaseItemListDef = new InAppPurchaseItemListDef(this.wranglers.wrangled(IAP_DEFS_URL).vars,this.context.locale,this.context.logger,this.config.abilityFactory,this.config.classes,this.config.itemDefs);
         this.tourneyDefList = new TourneyDefList(this.wranglers.wrangled(TOURNEY_DEF_LIST_URL).vars.vars,this.context.logger);
         this.createOfflineAccountInfo();
         var _loc2_:IIapManager = new iapManagerClazz(this.inAppPurchaseItemListDef,_loc1_.purchases,_loc1_.legend,this.config.fsm.session,this.config.client_language,this.context.locale,this.context.logger);
         _loc2_.sandbox = _loc1_.iap_sandbox;
         _loc2_.debugImmediateFinalize = this.config.options.debugTxnImmediateFinalize;
         this.iapManager = _loc2_;
         this.ready = true;
         this.readyCallback();
      }
      
      public function load() : void
      {
         this.namegen.load();
         this.wranglers.wrangle(ACHIEVEMENT_DEFS_URL);
         this.wranglers.wrangle(IAP_DEFS_URL);
         this.wranglers.wrangle(TOURNEY_DEF_LIST_URL);
         this.wranglers.wrangle(SCENE_LIST_URL);
         this.wranglers.wrangle(STARTING_ROSTER_URL);
         this.wranglers.addEventListener(Event.COMPLETE,this.wranglerHandler);
         this.wranglers.load();
      }
      
      private function namegenCompleteHandler(param1:NameGenerator) : void
      {
         this.checkReady();
      }
      
      private function checkReady() : void
      {
         if(this.wranglers.ready && this.namegen.ready)
         {
            this.finishReady();
         }
      }
      
      private function wranglerHandler(param1:Event) : void
      {
         this.wranglers.removeEventListener(Event.COMPLETE,this.wranglerHandler);
         this.checkReady();
      }
      
      private function shellFuncIap(param1:CmdExec) : void
      {
         var _loc2_:String = String(param1.param[1]);
         this.iapManager.purchase(_loc2_);
      }
      
      private function shellFuncVsmon(param1:CmdExec) : void
      {
         var _loc2_:String = String(param1.param[1]);
         var _loc3_:String = param1.param.length > 1 ? String(param1.param[2]) : null;
         var _loc4_:String = param1.param.length > 2 ? String(param1.param[3]) : null;
         this.vsmonitor.debugUpdateEnry(_loc2_,_loc3_,_loc4_);
      }
      
      private function shellFuncLeaderboardsEvents(param1:CmdExec) : void
      {
         this.leaderboards.refresh();
      }
      
      public function handleOneMessage(param1:Object) : Boolean
      {
         if(this.lobbyManager.handleOneMsg(param1))
         {
            return true;
         }
         if(this.tourneys.handleOneMsg(param1))
         {
            return true;
         }
         return false;
      }
      
      public function generateStartingRoster(param1:Boolean) : AccountInfoDef
      {
         var _loc2_:AccountInfoDef = new AccountInfoDefVars(this.wranglers.wrangled(STARTING_ROSTER_URL).vars,this.config);
         _loc2_.tutorial = param1;
         return _loc2_;
      }
      
      public function createOfflineAccountInfo() : void
      {
         this.starting_roster = this.generateStartingRoster(false);
         this.config.accountInfo = this.generateStartingRoster(false);
         if(this.config.options.partyOverride)
         {
            this.config.accountInfo.legend.party.reset(this.config.options.partyOverride);
         }
      }
   }
}
