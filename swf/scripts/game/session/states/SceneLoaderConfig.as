package game.session.states
{
   import engine.core.fsm.StateData;
   import engine.entity.def.IEntityListDef;
   import engine.landscape.travel.def.TravelLocator;
   import engine.landscape.travel.model.Travel_FallData;
   import engine.saga.convo.Convo;
   import engine.scene.SceneContext;
   import engine.scene.model.SceneLoaderBattleInfo;
   import game.cfg.GameConfig;
   import game.session.GameFsm;
   import tbs.srv.battle.data.BattlePartyData;
   import tbs.srv.battle.data.client.BattleCreateData;
   
   public class SceneLoaderConfig
   {
       
      
      public var context:SceneContext;
      
      public var _cfg:GameConfig;
      
      public var gameFsm:GameFsm;
      
      public var sceneLoaderComplete:Function;
      
      public var setupLocalPartyCallback:Function;
      
      public var convoPortraitGenerator:Function;
      
      public var opponentId:int;
      
      public var opponentName:String;
      
      public var localBattleOrder:int;
      
      public var opponentOrder:int;
      
      public var opponentPartyDef:IEntityListDef;
      
      public var convo:Convo;
      
      public var happeningId:String;
      
      public var battle_info:SceneLoaderBattleInfo;
      
      public var battleMusicDefUrl:String;
      
      public var battleMusicOverride:Boolean;
      
      public var battle_vitalities:String;
      
      public var isOnline:Boolean;
      
      public var bcd:BattleCreateData;
      
      public var opponent:BattlePartyData = null;
      
      public var stripHappenings:Boolean = true;
      
      public var travel_locator:TravelLocator;
      
      public var fallData:Travel_FallData;
      
      public function SceneLoaderConfig(param1:GameFsm, param2:Function, param3:Function, param4:Function, param5:StateData)
      {
         this.isOnline = !!this.opponentName ? true : false;
         super();
         this.gameFsm = param1;
         this._cfg = param1.config;
         this.sceneLoaderComplete = param2;
         this.setupLocalPartyCallback = param3;
         this.convoPortraitGenerator = param4;
         this.fromData(param5);
         this.generateContext();
      }
      
      public function fromData(param1:StateData) : void
      {
         if(!param1)
         {
            return;
         }
         this.opponentId = param1.getValue(GameStateDataEnum.OPPONENT_ID);
         this.opponentName = param1.getValue(GameStateDataEnum.OPPONENT_NAME);
         this.localBattleOrder = param1.getValue(GameStateDataEnum.PLAYER_ORDER);
         this.opponentOrder = this.localBattleOrder == 0 ? 1 : 0;
         this.opponentPartyDef = param1.getValue(GameStateDataEnum.OPPONENT_PARTY);
         this.convo = param1.getValue(GameStateDataEnum.CONVO);
         this.happeningId = param1.getValue(GameStateDataEnum.HAPPENING_ID);
         this.battle_info = param1.getValue(GameStateDataEnum.BATTLE_INFO);
         this.battleMusicDefUrl = param1.getValue(GameStateDataEnum.BATTLE_MUSIC_DEF_URL);
         this.battleMusicOverride = param1.getValue(GameStateDataEnum.BATTLE_MUSIC_OVERRIDE);
         this.battle_vitalities = param1.getValue(GameStateDataEnum.BATTLE_VITALITIES);
         this.isOnline = !!this.opponentName ? true : false;
         this.bcd = param1.getValue(GameStateDataEnum.BATTLE_CREATE_DATA);
         if(this.isOnline)
         {
            this.opponent = !!this.bcd ? this.bcd.parties[this.opponentOrder] : null;
         }
         this.travel_locator = param1.getValue(GameStateDataEnum.TRAVEL_LOCATOR);
         this.fallData = param1.getValue(GameStateDataEnum.TRAVEL_FALL_DATA);
      }
      
      private function generateContext() : void
      {
         this.context = new SceneContext(this._cfg.resman,null,this._cfg.logger,this._cfg.abilityFactory,this._cfg.classes,this._cfg.assets.battle,this._cfg.soundSystem.driver,this.gameFsm.session,this._cfg.context.locale,this._cfg.eater,this.gameFsm.chat,this.gameFsm,this._cfg.animDispatcher,this._cfg.triggers,this._cfg.sceneControllerConfig,this._cfg.keybinder,this._cfg.saga,this._cfg.spawnables,this._cfg.itemDefs,this.convoPortraitGenerator,this._cfg.heraldrySystem,this._cfg.options.developer,this._cfg.globalAmbience,this._cfg.textBitmapGenerator,this._cfg._eabm);
         this.context.staticSoundController = this.gameFsm.config.soundSystem.controller;
      }
   }
}
