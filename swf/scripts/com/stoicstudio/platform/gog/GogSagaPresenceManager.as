package com.stoicstudio.platform.gog
{
   import air.gog.ane.GogAne;
   import engine.core.locale.LocaleCategory;
   import engine.core.util.AppInfo;
   import engine.saga.NullSagaPresenceManager;
   import engine.saga.SagaPresenceManager;
   import flash.utils.Dictionary;
   import game.cfg.GameConfig;
   
   public class GogSagaPresenceManager extends NullSagaPresenceManager
   {
       
      
      private var _config:GameConfig = null;
      
      private var galaxy:GogAne = null;
      
      private var presenceTable:Dictionary;
      
      public function GogSagaPresenceManager(param1:GogAne, param2:AppInfo)
      {
         super(param2);
         this.galaxy = param1;
         this.presenceTable = new Dictionary();
         this.presenceTable[SagaPresenceManager.StateInBattle] = "platform_status_battle";
         this.presenceTable[SagaPresenceManager.StateCamping] = "platform_status_camping";
         this.presenceTable[SagaPresenceManager.StateInConversation] = "platform_status_convo";
         this.presenceTable[SagaPresenceManager.StateDecision] = "platform_status_decision";
         this.presenceTable[SagaPresenceManager.StateAtMarket] = "platform_status_market";
         this.presenceTable[SagaPresenceManager.StateStartingGame] = "platform_status_starting";
         this.presenceTable[SagaPresenceManager.StateTraveling] = "platform_status_traveling";
      }
      
      public function set config(param1:GameConfig) : void
      {
         this._config = param1;
      }
      
      override protected function resolveStateChange(param1:String) : void
      {
         var _loc2_:String = null;
         if(param1 != SagaPresenceManager.StateNone)
         {
            _loc2_ = this.lookUpPresenceText(param1);
            this.galaxy.logger.info("Sending " + _loc2_ + " down to GOG");
            this.galaxy.GalaxyAPI_SetRichPresenceState("status",_loc2_);
         }
      }
      
      private function lookUpPresenceText(param1:String) : String
      {
         var _loc2_:String = String(this.presenceTable[param1]);
         var _loc3_:String = "";
         if(!_loc2_)
         {
            this.galaxy.logger.info("Could not find presence id from state: " + param1);
         }
         else
         {
            _loc3_ = this._config.gameGuiContext.translateCategory(_loc2_,LocaleCategory.PLATFORM);
         }
         return _loc3_;
      }
   }
}
