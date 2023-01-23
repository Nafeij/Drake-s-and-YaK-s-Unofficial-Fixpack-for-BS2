package engine.battle.fsm
{
   import flash.events.Event;
   import flash.events.EventDispatcher;
   
   public class BattleFsmConfig
   {
      
      public static var globalPlayerAi:Boolean = false;
      
      public static var globalEnableAi:Boolean = true;
      
      public static var sceneEnableAi:Boolean = true;
      
      public static const EVENT_GUI_VISIBLE:String = "BattleFsmConfig.EVENT_GUI_VISIBLE";
      
      public static const EVENT_GUI_HUD_ENABLE:String = "BattleFsmConfig.EVENT_GUI_HUD_ENABLE";
      
      public static const EVENT_GUI_TILES_ENABLE:String = "BattleFsmConfig.EVENT_GUI_TILES_ENABLE";
      
      public static const EVENT_GUI_FLYTEXT_ENABLE:String = "BattleFsmConfig.EVENT_GUI_FLYTEXT_ENABLE";
      
      public static const EVENT_GUI_WAVE_DEPLOY_ENABLE:String = "BattleFsmConfig.EVENT_GUI_WAVE_DEPLOY_ENABLE";
      
      private static var _guiFlytextEnabled:Boolean = true;
      
      private static var _guiHudEnabled:Boolean = true;
      
      private static var _guiTilesEnabled:Boolean = true;
      
      private static var _guiWaveDeployEnabled:Boolean = true;
      
      private static var _guiVisible:Boolean = true;
      
      public static var dispatcher:EventDispatcher = new EventDispatcher();
       
      
      public var deployTimeoutMs:int = 60000;
      
      public var startPartyId:String = "XXXXXX";
      
      public function BattleFsmConfig()
      {
         super();
      }
      
      public static function get aiEnabled() : Boolean
      {
         return globalEnableAi && sceneEnableAi;
      }
      
      public static function get playerAi() : Boolean
      {
         return globalPlayerAi;
      }
      
      public static function reset() : void
      {
         _guiFlytextEnabled = true;
         _guiHudEnabled = true;
         _guiTilesEnabled = true;
      }
      
      public static function get guiVisible() : Boolean
      {
         return _guiVisible;
      }
      
      public static function set guiVisible(param1:Boolean) : void
      {
         _guiVisible = param1;
         dispatcher.dispatchEvent(new Event(EVENT_GUI_VISIBLE));
      }
      
      public static function get guiHudShouldRender() : Boolean
      {
         return _guiHudEnabled && _guiVisible;
      }
      
      public static function get guiHudEnabled() : Boolean
      {
         return _guiHudEnabled;
      }
      
      public static function set guiHudEnabled(param1:Boolean) : void
      {
         _guiHudEnabled = param1;
         dispatcher.dispatchEvent(new Event(EVENT_GUI_HUD_ENABLE));
      }
      
      public static function get guiTilesShouldRender() : Boolean
      {
         return _guiTilesEnabled && _guiVisible;
      }
      
      public static function get guiTilesEnabled() : Boolean
      {
         return _guiTilesEnabled;
      }
      
      public static function set guiTilesEnabled(param1:Boolean) : void
      {
         _guiTilesEnabled = param1;
         dispatcher.dispatchEvent(new Event(EVENT_GUI_TILES_ENABLE));
      }
      
      public static function get guiFlytextShouldRender() : Boolean
      {
         return _guiFlytextEnabled && _guiVisible;
      }
      
      public static function get guiFlytextEnabled() : Boolean
      {
         return _guiFlytextEnabled;
      }
      
      public static function set guiFlytextEnabled(param1:Boolean) : void
      {
         _guiFlytextEnabled = param1;
         dispatcher.dispatchEvent(new Event(EVENT_GUI_FLYTEXT_ENABLE));
      }
      
      public static function get guiWaveDeployEnabled() : Boolean
      {
         return _guiWaveDeployEnabled;
      }
      
      public static function set guiWaveDeployEnabled(param1:Boolean) : void
      {
         _guiWaveDeployEnabled = param1;
         dispatcher.dispatchEvent(new Event(EVENT_GUI_WAVE_DEPLOY_ENABLE));
      }
   }
}
