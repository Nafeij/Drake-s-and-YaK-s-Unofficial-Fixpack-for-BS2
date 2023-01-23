package engine.saga
{
   import engine.achievement.AchievementListDef;
   import engine.battle.board.model.IBattleBoard;
   import engine.battle.board.model.IBattleEntity;
   import engine.core.locale.Locale;
   import engine.core.logging.ILogger;
   import engine.entity.UnitStatCosts;
   import engine.entity.def.IEntityDef;
   import engine.entity.def.IEntityListDef;
   import engine.entity.def.ItemDef;
   import engine.entity.def.ItemListDef;
   import engine.math.Rng;
   import engine.saga.action.IActionProvider;
   import engine.saga.convo.def.audio.ConvoAudioListDef;
   import engine.saga.happening.IHappeningDefProvider;
   import engine.saga.happening.IHappeningProvider;
   import engine.saga.vars.IVariableBag;
   import engine.saga.vars.IVariableProvider;
   import engine.scene.model.SceneLoader;
   import flash.events.IEventDispatcher;
   
   public interface ISaga extends IVariableProvider, IHappeningProvider, IActionProvider, IEventDispatcher
   {
       
      
      function get logger() : ILogger;
      
      function get global() : IVariableBag;
      
      function get icaravan() : ICaravan;
      
      function get camped() : Boolean;
      
      function get halted() : Boolean;
      
      function get halting() : Boolean;
      
      function get resting() : Boolean;
      
      function get haltToCamp() : Boolean;
      
      function get hudTravelHidden() : Boolean;
      
      function get soundDaySuppressed() : Boolean;
      
      function get doomsdayChoiceSoundEnabled() : Boolean;
      
      function get caravanAnimBaseUrl() : String;
      
      function get caravanClosePoleUrl() : String;
      
      function get bannerHudName() : String;
      
      function set devBookmarked(param1:Boolean) : void;
      
      function get isDevCheat() : Boolean;
      
      function get iSagaSound() : ISagaSound;
      
      function get mapCamp() : Boolean;
      
      function get mapCampCinema() : Boolean;
      
      function handleSceneDestruction(param1:*) : void;
      
      function get startUrl() : String;
      
      function get rng() : Rng;
      
      function get unitStatCosts() : UnitStatCosts;
      
      function addHappeningDefProvider(param1:IHappeningDefProvider) : void;
      
      function removeHappeningDefProvider(param1:IHappeningDefProvider) : void;
      
      function get convoNodeIdSuffix() : String;
      
      function get convoAudioListDef() : ConvoAudioListDef;
      
      function get sound() : ISagaSound;
      
      function getCastMember(param1:String) : IEntityDef;
      
      function get locale() : Locale;
      
      function get isSurvival() : Boolean;
      
      function get expression() : ISagaExpression;
      
      function performSpeak(param1:IBattleEntity, param2:IEntityDef, param3:String, param4:Number, param5:String, param6:String, param7:Boolean) : void;
      
      function get achievements() : AchievementListDef;
      
      function get cast() : IEntityListDef;
      
      function get roster() : IEntityListDef;
      
      function incrementGlobalVar(param1:String, param2:int = 1) : int;
      
      function modifyGlobalVar(param1:String, param2:Number) : Number;
      
      function setMaxGlobalVar(param1:String, param2:Number) : Number;
      
      function get isDebugger() : Boolean;
      
      function get caravanVars() : IVariableBag;
      
      function get itemDefs() : ItemListDef;
      
      function generateRandomItemDefForPartyRanks() : ItemDef;
      
      function getSagaBucket(param1:String) : SagaBucket;
      
      function performTutorialRemoveAll(param1:String) : void;
      
      function get paused() : Boolean;
      
      function triggerBattleAbilityCompleted(param1:String, param2:String, param3:Boolean) : void;
      
      function triggerBattleAbilityExecuted(param1:String, param2:String, param3:Boolean) : void;
      
      function triggerBattleKillStop(param1:IBattleEntity) : void;
      
      function triggerBattleImmortalStopped(param1:IBattleEntity) : void;
      
      function triggerBattleWaveLowTurnWarning() : void;
      
      function getIBattleBoard() : IBattleBoard;
      
      function get scenePreprocessor() : ISagaScenePreprocessor;
      
      function ctorSceneLoader(param1:String, param2:Function) : SceneLoader;
      
      function isSceneLoaded() : Boolean;
      
      function get isOptionsShowing() : Boolean;
   }
}
