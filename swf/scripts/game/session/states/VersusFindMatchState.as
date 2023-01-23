package game.session.states
{
   import engine.battle.SceneListItemDef;
   import engine.core.fsm.Fsm;
   import engine.core.fsm.StateData;
   import engine.core.fsm.StatePhase;
   import engine.core.logging.ILogger;
   import engine.core.pref.PrefBag;
   import engine.entity.def.EntityListDefVars;
   import engine.scene.model.SceneLoaderBattleInfo;
   import game.cfg.GameConfig;
   import game.gui.GuiGamePrefs;
   import game.session.GameFsm;
   import game.session.GameState;
   import game.session.actions.VersusCancelTxn;
   import game.session.actions.VersusStartMatchTxn;
   import game.session.actions.VsType;
   import tbs.srv.battle.data.BattlePartyData;
   import tbs.srv.battle.data.client.BattleCreateData;
   import tbs.srv.util.Tourney;
   
   public class VersusFindMatchState extends GameState
   {
      
      private static const MAX_DELAY:int = 5000;
      
      private static var last_match_handle:int = 0;
       
      
      private var txn:VersusStartMatchTxn;
      
      private var nextDelay:int = 500;
      
      private var match_handle:int;
      
      public var vs_type:VsType;
      
      public var vs_power:int;
      
      public function VersusFindMatchState(param1:StateData, param2:Fsm, param3:ILogger)
      {
         super(param1,param2,param3);
      }
      
      public static function restartFind(param1:VsType, param2:GameConfig) : void
      {
         var _loc7_:Tourney = null;
         var _loc3_:GameFsm = param2.fsm;
         var _loc4_:StateData = _loc3_.current.data;
         _loc4_.setValue(GameStateDataEnum.VERSUS_TYPE,param1);
         var _loc5_:int = 0;
         if(param1 == VsType.TOURNEY)
         {
            _loc7_ = param2.factions.tourneys.tourney;
            _loc5_ = !!_loc7_ ? _loc7_.tourney_id : 0;
            _loc4_.setValue(GameStateDataEnum.VERSUS_TOURNEY_ID,_loc5_);
         }
         else
         {
            _loc4_.removeValue(GameStateDataEnum.VERSUS_TOURNEY_ID);
         }
         var _loc6_:int = computeTimer(_loc5_,param2.globalPrefs);
         _loc4_.setValue(GameStateDataEnum.BATTLE_TIMER_SECS,_loc6_);
         _loc4_.setValue(GameStateDataEnum.FORCE_OPPONENT_ID,param2.options.versusForceOpponentId);
         _loc4_.setValue(GameStateDataEnum.SCENE_URL,param2.options.versusForceScene);
         if(_loc3_.currentClass == VersusFindMatchState)
         {
            _loc4_.setValue(GameStateDataEnum.VERSUS_RESTART,true);
            _loc3_.transitionTo(VersusCancelState,_loc4_);
         }
         else
         {
            _loc3_.transitionTo(VersusFindMatchState,_loc4_);
         }
      }
      
      public static function computeTimer(param1:int, param2:PrefBag) : int
      {
         var _loc3_:int = 45;
         var _loc4_:int = 30;
         var _loc5_:int = _loc3_;
         if(param2.getPref(GuiGamePrefs.PREF_EXPERT_MODE) || Boolean(param1))
         {
            _loc5_ = _loc4_;
         }
         return _loc5_;
      }
      
      override protected function handleCleanup() : void
      {
         communicator.removePollTimeRequirement(this);
         if(config.factions)
         {
            config.factions.vsmonitor.setPlayerQueuePower(this.vs_type,0);
         }
         this.match_handle = 0;
         if(this.txn)
         {
            this.txn.abort();
            this.txn = null;
         }
         if(phase != StatePhase.COMPLETED)
         {
            new VersusCancelTxn(credentials,this.match_handle,null,gameFsm.config).send(communicator);
         }
      }
      
      override public function handleMessage(param1:Object) : Boolean
      {
         var _loc2_:BattleCreateData = null;
         var _loc3_:int = 0;
         var _loc4_:String = null;
         var _loc5_:EntityListDefVars = null;
         var _loc6_:int = 0;
         var _loc7_:EntityListDefVars = null;
         var _loc8_:BattlePartyData = null;
         var _loc9_:int = 0;
         var _loc10_:SceneLoaderBattleInfo = null;
         var _loc11_:SceneListItemDef = null;
         var _loc12_:String = null;
         var _loc13_:BattlePartyData = null;
         var _loc14_:Object = null;
         var _loc15_:Object = null;
         if(!config.factions)
         {
            return false;
         }
         if(param1["class"] == "tbs.srv.battle.data.BattleCreateData")
         {
            _loc2_ = new BattleCreateData();
            _loc2_.parseJson(param1,logger);
            _loc3_ = 0;
            logger.info("VersusFindMatchState starting Battle " + _loc2_.battle_id + " url=" + param1.scene);
            _loc9_ = 0;
            while(_loc9_ < _loc2_.parties.length)
            {
               _loc13_ = _loc2_.parties[_loc9_];
               logger.info("   Party " + _loc9_ + ": " + _loc13_);
               if(_loc13_.user == credentials.userId)
               {
                  logger.info("     ME!");
                  _loc3_ = _loc9_;
                  if(_loc13_.match_handle != this.match_handle)
                  {
                     logger.info("VersusFindMatchState We already gave up on match_handle " + _loc13_.match_handle);
                     return true;
                  }
                  _loc8_ = _loc13_;
                  _loc14_ = {"defs":_loc13_.defs};
                  _loc7_ = new EntityListDefVars(config.context.locale,logger).fromJson(_loc14_,logger,config.abilityFactory,config.classes,config,true,config.itemDefs);
               }
               else
               {
                  _loc6_ = _loc13_.user;
                  _loc4_ = _loc13_.display_name;
                  _loc15_ = {"defs":_loc13_.defs};
                  _loc5_ = new EntityListDefVars(config.context.locale,logger).fromJson(_loc15_,logger,config.abilityFactory,config.classes,config,true,config.itemDefs);
               }
               _loc9_++;
            }
            data.setValue(GameStateDataEnum.OPPONENT_ID,_loc6_);
            data.setValue(GameStateDataEnum.OPPONENT_NAME,_loc4_);
            data.setValue(GameStateDataEnum.OPPONENT_PARTY,_loc5_);
            data.setValue(GameStateDataEnum.LOCAL_PARTY,_loc7_);
            data.setValue(GameStateDataEnum.LOCAL_TIMER_SECS,_loc8_.timer);
            data.setValue(GameStateDataEnum.BATTLE_CREATE_DATA,_loc2_);
            data.removeValue(GameStateDataEnum.VERSUS_RESTART);
            data.setValue(GameStateDataEnum.SCENE_AUTOPAN,false);
            _loc10_ = new SceneLoaderBattleInfo();
            _loc10_.battle_board_id = "board0";
            data.setValue(GameStateDataEnum.BATTLE_INFO,_loc10_);
            _loc11_ = config.factions.sceneListDef.fetch(_loc2_.scene);
            if(!_loc11_)
            {
               logger.error("Invalid scene id: " + _loc2_.scene);
               phase = StatePhase.FAILED;
               return true;
            }
            _loc12_ = _loc11_.url;
            data.setValue(GameStateDataEnum.SCENE_URL,_loc12_);
            data.setValue(GameStateDataEnum.PLAYER_ORDER,_loc3_);
            phase = StatePhase.COMPLETED;
            return true;
         }
         return false;
      }
      
      override protected function handleEnteredState() : void
      {
         gameFsm.updateGameLocation("loc_versus");
         communicator.setPollTimeRequirement(this,2000);
         logger.info("Entering VS...");
         this.match_handle = ++last_match_handle;
         data.setValue(GameStateDataEnum.BATTLE_CREATE_DATA,null);
         data.setValue(GameStateDataEnum.LOCAL_PARTY,null);
         data.removeValue(GameStateDataEnum.BATTLE_INFO);
         data.setValue(GameStateDataEnum.LOCAL_TIMER_SECS,0);
         var _loc1_:int = data.getValue(GameStateDataEnum.FORCE_OPPONENT_ID);
         var _loc2_:String = data.getValue(GameStateDataEnum.BATTLE_SCENE_ID);
         var _loc3_:int = data.getValue(GameStateDataEnum.BATTLE_TIMER_SECS);
         var _loc4_:int = data.getValue(GameStateDataEnum.VERSUS_TOURNEY_ID);
         this.vs_type = data.getValue(GameStateDataEnum.VERSUS_TYPE);
         this.vs_power = config.legend.party.totalPower;
         config.factions.vsmonitor.setPlayerQueuePower(this.vs_type,this.vs_power);
         this.txn = new VersusStartMatchTxn(credentials,_loc1_,_loc2_,this.match_handle,_loc3_,_loc4_,this.vs_type,null,gameFsm.config);
         this.txn.send(communicator);
      }
   }
}
