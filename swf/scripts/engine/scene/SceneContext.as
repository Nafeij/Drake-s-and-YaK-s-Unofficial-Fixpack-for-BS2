package engine.scene
{
   import engine.battle.BattleAssetsDef;
   import engine.battle.ability.def.BattleAbilityDefFactory;
   import engine.battle.board.def.BattleBoardTriggerDefList;
   import engine.core.cmd.IKeyBinder;
   import engine.core.fsm.Fsm;
   import engine.core.locale.Locale;
   import engine.core.logging.ILogger;
   import engine.entity.UnitStatCosts;
   import engine.entity.def.EntityClassDefList;
   import engine.entity.def.IEntityAssetBundleManager;
   import engine.entity.def.IEntityDef;
   import engine.entity.def.IEntityListDef;
   import engine.entity.def.ItemListDef;
   import engine.gui.IGuiEventEater;
   import engine.heraldry.HeraldrySystem;
   import engine.landscape.ILandscapeContext;
   import engine.landscape.view.DisplayObjectWrapper;
   import engine.math.Rng;
   import engine.math.RngSampler_SeedArray;
   import engine.resource.ResourceManager;
   import engine.saga.ISaga;
   import engine.saga.SagaEvent;
   import engine.saga.SpeakEvent;
   import engine.scene.view.ISpeechBubblePositioner;
   import engine.scene.view.SpeechBubble;
   import engine.session.Chat;
   import engine.session.Session;
   import engine.sound.ISoundDriver;
   import engine.sound.view.ISoundController;
   import flash.events.Event;
   import flash.events.EventDispatcher;
   import flash.utils.getTimer;
   
   public class SceneContext extends EventDispatcher implements ILandscapeContext
   {
       
      
      private var _resman:ResourceManager;
      
      private var _logger:ILogger;
      
      private var _abilities:BattleAbilityDefFactory;
      
      private var _battleAssets:BattleAssetsDef;
      
      private var _soundDriver:ISoundDriver;
      
      private var _classes:EntityClassDefList;
      
      private var _session:Session;
      
      private var _locale:Locale;
      
      public var eater:IGuiEventEater;
      
      public var staticSoundController:ISoundController;
      
      public var chat:Chat;
      
      public var fsm:Fsm;
      
      public var animDispatcher:EventDispatcher;
      
      private var _triggers:BattleBoardTriggerDefList;
      
      public var sceneControllerConfig:SceneControllerConfig;
      
      private var _keybinder:IKeyBinder;
      
      private var _saga:ISaga;
      
      private var _spawnables:IEntityListDef;
      
      private var _itemDefs:ItemListDef;
      
      public var _speechBubbler:Function;
      
      private var _convoPortraitGenerator:Function;
      
      private var _rng:Rng;
      
      public var heraldrySystem:HeraldrySystem;
      
      public var developer:Boolean;
      
      public var globalAmbience:GlobalAmbience;
      
      public var textBitmapGenerator:ITextBitmapGenerator;
      
      public var _eabm:IEntityAssetBundleManager;
      
      public function SceneContext(param1:ResourceManager, param2:ResourceManager, param3:ILogger, param4:BattleAbilityDefFactory, param5:EntityClassDefList, param6:BattleAssetsDef, param7:ISoundDriver, param8:Session, param9:Locale, param10:IGuiEventEater, param11:Chat, param12:Fsm, param13:EventDispatcher, param14:BattleBoardTriggerDefList, param15:SceneControllerConfig, param16:IKeyBinder, param17:ISaga, param18:IEntityListDef, param19:ItemListDef, param20:Function, param21:HeraldrySystem, param22:Boolean, param23:GlobalAmbience, param24:ITextBitmapGenerator, param25:IEntityAssetBundleManager)
      {
         super();
         this._session = param8;
         this._resman = param1;
         this._logger = param3;
         this._abilities = param4;
         this._battleAssets = param6;
         this._soundDriver = param7;
         this._classes = param5;
         this._locale = param9;
         this.eater = param10;
         this.chat = param11;
         this.fsm = param12;
         this.animDispatcher = param13;
         this._triggers = param14;
         this.sceneControllerConfig = param15;
         this._keybinder = param16;
         this._saga = param17;
         this._spawnables = param18;
         this._convoPortraitGenerator = param20;
         this._itemDefs = param19;
         this.heraldrySystem = param21;
         this.developer = param22;
         this.globalAmbience = param23;
         this.textBitmapGenerator = param24;
         this._eabm = param25;
         this.setupRNG();
         if(this._saga)
         {
            this._saga.addEventListener(SagaEvent.EVENT_LOCALE,this.sagaLocaleHandler);
         }
      }
      
      public function cleanup() : void
      {
         if(this._saga)
         {
            this._saga.removeEventListener(SagaEvent.EVENT_LOCALE,this.sagaLocaleHandler);
         }
      }
      
      public function sagaLocaleHandler(param1:Event) : void
      {
         if(this._saga)
         {
            this.setLocale(this._saga.locale);
         }
      }
      
      public function get spawnables() : IEntityListDef
      {
         return this._spawnables;
      }
      
      public function get resman() : ResourceManager
      {
         return this._resman;
      }
      
      public function get logger() : ILogger
      {
         return this._logger;
      }
      
      public function get abilities() : BattleAbilityDefFactory
      {
         return this._abilities;
      }
      
      public function get battleAssets() : BattleAssetsDef
      {
         return this._battleAssets;
      }
      
      public function get soundDriver() : ISoundDriver
      {
         return this._soundDriver;
      }
      
      public function get classes() : EntityClassDefList
      {
         return this._classes;
      }
      
      public function get itemDefs() : ItemListDef
      {
         return this._itemDefs;
      }
      
      public function get session() : Session
      {
         return this._session;
      }
      
      public function set session(param1:Session) : void
      {
         this._session = param1;
      }
      
      public function get locale() : Locale
      {
         return this._locale;
      }
      
      public function get triggers() : BattleBoardTriggerDefList
      {
         return this._triggers;
      }
      
      public function get keybinder() : IKeyBinder
      {
         return this._keybinder;
      }
      
      public function get saga() : ISaga
      {
         return this._saga;
      }
      
      public function get unitStatCosts() : UnitStatCosts
      {
         return !!this._saga ? this._saga.unitStatCosts : null;
      }
      
      public function createSpeechBubble(param1:SpeakEvent, param2:*, param3:ISpeechBubblePositioner) : SpeechBubble
      {
         if(this._speechBubbler != null)
         {
            return this._speechBubbler(param1,param2,param3);
         }
         return null;
      }
      
      public function generateConvoPortrait(param1:IEntityDef, param2:Boolean, param3:Number) : DisplayObjectWrapper
      {
         return this._convoPortraitGenerator(param1,param2,param3);
      }
      
      public function get rng() : Rng
      {
         return this._rng;
      }
      
      public function setLocale(param1:Locale) : void
      {
         if(this._locale == param1)
         {
            return;
         }
         this._locale = param1;
         dispatchEvent(new SceneContextEvent(SceneContextEvent.LOCALE));
      }
      
      public function get entityAssetBundleManager() : IEntityAssetBundleManager
      {
         return this._eabm;
      }
      
      private function setupRNG() : void
      {
         var _loc1_:int = 0;
         if(this.saga)
         {
            this._rng = this.saga.rng;
            this._logger.i("RNG","SceneContext using saga RNG");
         }
         else
         {
            _loc1_ = getTimer();
            this._rng = RngSampler_SeedArray.ctor(_loc1_,this._logger);
            this._logger.i("RNG","SceneContext created new RNG. Seed: " + _loc1_);
         }
      }
   }
}
