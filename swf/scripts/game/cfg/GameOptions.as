package game.cfg
{
   import engine.core.locale.LocaleId;
   
   public class GameOptions
   {
       
      
      public var debugTxnImmediateFinalize:Boolean;
      
      public var testTutorial:Boolean;
      
      public var newMusic:Boolean;
      
      public var assetPath:String;
      
      public var localesPath:String;
      
      public var guiPath:String;
      
      public var soundEnabled:Boolean;
      
      public var partyOverride:Vector.<String>;
      
      public var softwareMouse:Boolean;
      
      public var fmodPort:int = 0;
      
      public var fmodProfile:Boolean;
      
      public var fmodStudio:Boolean;
      
      public var alwaysOffline:Boolean;
      
      public var overrideTurnLengthSecs:int = -1;
      
      public var overrideVersusCountdownSecs:int = -1;
      
      public var accountChildNumber:int = 0;
      
      public var overrideSteamId:String;
      
      public var versusForceOpponentId:int;
      
      public var versusForceTourneyId:int;
      
      public var versusForceScene:String;
      
      public var startInCombat:String = null;
      
      public var startInVersus:Boolean;
      
      public var lite:Boolean;
      
      public var startInSaga:String;
      
      public var startInSagaHappening:String;
      
      public var startInSagaSaveLoad:String;
      
      public var startInSagaSaveLoadProfile:int = -1;
      
      public var startInFactions:Boolean;
      
      public var screenFlashErrors:Boolean = true;
      
      public var developer:Boolean;
      
      public var locale_id:LocaleId;
      
      public var locale_id_system:LocaleId;
      
      public var mod_ids:Array;
      
      public var mod_root:String;
      
      public var programText:String;
      
      public var globalAssetPreloaderPaths:Array;
      
      public var under_construction:String;
      
      public function GameOptions()
      {
         this.locale_id = new LocaleId("en");
         this.locale_id_system = new LocaleId("en");
         this.mod_ids = [];
         super();
      }
      
      public function consumeGlobalAssetPreloaderPaths(param1:String) : void
      {
         if(!param1)
         {
            return;
         }
         this.globalAssetPreloaderPaths = param1.split(",");
         if(Boolean(this.globalAssetPreloaderPaths) && !this.globalAssetPreloaderPaths.length)
         {
            this.globalAssetPreloaderPaths = null;
         }
      }
   }
}
