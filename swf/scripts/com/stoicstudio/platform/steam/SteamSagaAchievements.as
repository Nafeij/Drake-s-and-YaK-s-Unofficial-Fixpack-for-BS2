package com.stoicstudio.platform.steam
{
   import air.steamworks.ane.SteamworksAne;
   import air.steamworks.ane.SteamworksEvent;
   import engine.achievement.AchievementDef;
   import engine.saga.ISaga;
   import engine.saga.NullSagaAchievements;
   import engine.saga.vars.IVariable;
   import flash.net.URLRequest;
   import flash.net.navigateToURL;
   import flash.utils.Dictionary;
   
   public final class SteamSagaAchievements extends NullSagaAchievements
   {
       
      
      private var steam_enabled:Boolean = true;
      
      private var steamworks:SteamworksAne;
      
      private var fromSteam:Dictionary;
      
      public var _statFloats:Dictionary;
      
      public function SteamSagaAchievements(param1:SteamworksAne)
      {
         this.fromSteam = new Dictionary();
         this._statFloats = new Dictionary();
         super();
         this.steamworks = param1;
      }
      
      override public function setSaga(param1:ISaga) : void
      {
         super.setSaga(param1);
         if(!saga)
         {
            return;
         }
         var _loc2_:IVariable = saga.getVar("previewbuild",null);
         if(_loc2_)
         {
            this.steam_enabled = !_loc2_.asBoolean;
         }
         this.initAchievementsFromSteam();
      }
      
      override public function cleanup() : void
      {
         if(this.steamworks)
         {
            this.steamworks.removeEventListener(SteamworksEvent.USER_STATS,this.steamUserStatsHandler);
            this.steamworks = null;
         }
         super.cleanup();
      }
      
      private function initAchievementsFromSteam() : void
      {
         var _loc1_:AchievementDef = null;
         var _loc2_:Boolean = false;
         var _loc3_:String = null;
         var _loc4_:Boolean = false;
         if(!saga || !saga.def || !saga.def.achievements || !this.steam_enabled)
         {
            return;
         }
         if(!this.steamworks)
         {
            return;
         }
         if(!this.steamworks.userStatsReady)
         {
            this.steamworks.addEventListener(SteamworksEvent.USER_STATS,this.steamUserStatsHandler);
            return;
         }
         saga.logger.debug("SteamSagaAchievements.initAchievementsFromSteam begin");
         for each(_loc1_ in saga.def.achievements.defs)
         {
            _loc4_ = this.steamworks.SteamUserStats_GetAchievement(_loc1_.id);
            if(_loc4_)
            {
               this.fromSteam[_loc1_.id] = _loc1_.id;
               this.internal_unlockAchievement(_loc1_);
            }
         }
         for each(_loc3_ in _unlocked)
         {
            if(!this.fromSteam[_loc3_])
            {
               _loc1_ = saga.def.achievements.fetch(_loc3_);
               if(Boolean(_loc1_) && !_loc1_.local)
               {
                  if(saga.isAchievementsSuppressed)
                  {
                     saga.logger.i(" ACV","suppressing offline steam unlock of [" + _loc3_ + "]");
                  }
                  else
                  {
                     this.steamworks.SteamUserStats_SetAchievement(_loc3_);
                     _loc2_ = true;
                  }
               }
            }
         }
         if(_loc2_ && Boolean(this.steamworks))
         {
            _loc4_ = this.steamworks.SteamUserStats_StoreStats();
            saga.logger.debug("SagaAchievements.initAchievementsFromSteam steam stored " + _loc4_);
         }
      }
      
      private function steamUserStatsHandler(param1:SteamworksEvent) : void
      {
         if(this.steamworks)
         {
            this.steamworks.removeEventListener(SteamworksEvent.USER_STATS,this.steamUserStatsHandler);
            this.initAchievementsFromSteam();
         }
      }
      
      override protected function internal_unlockAchievement(param1:AchievementDef) : void
      {
         var _loc2_:Boolean = false;
         var _loc3_:Boolean = false;
         super.internal_unlockAchievement(param1);
         if(Boolean(this.steamworks) && !this.fromSteam[param1.id])
         {
            if(!param1.local)
            {
               _loc2_ = this.steamworks.SteamUserStats_SetAchievement(param1.id);
               _loc3_ = this.steamworks.SteamUserStats_StoreStats();
               if(saga.logger.isDebugEnabled)
               {
                  saga.logger.debug("SagaAchievements.unlockAchievement [" + param1.id + "] steam set " + _loc2_);
                  saga.logger.debug("SagaAchievements.unlockAchievement [" + param1.id + "] steam stored " + _loc3_);
               }
            }
         }
      }
      
      override public function clearAchievement(param1:AchievementDef) : void
      {
         var _loc2_:Boolean = false;
         var _loc3_:Boolean = false;
         var _loc4_:IVariable = null;
         if(!param1)
         {
            return;
         }
         super.clearAchievement(param1);
         if(this.steamworks)
         {
            if(!param1.local)
            {
               _loc2_ = this.steamworks.SteamUserStats_ClearAchievement(param1.id);
               if(param1.progressVar)
               {
                  _loc4_ = saga.getVar(param1.progressVar,null);
                  if(_loc4_)
                  {
                     if(_loc4_.def.achievement_stat)
                     {
                        this.steamworks.SteamUserStats_SetStatInt(_loc4_.def.achievement_stat,0);
                     }
                  }
               }
               _loc3_ = this.steamworks.SteamUserStats_StoreStats();
               if(saga.logger.isDebugEnabled)
               {
                  saga.logger.debug("SagaAchievements.clearAchievement [" + param1.id + "] steam " + _loc2_);
                  saga.logger.debug("SagaAchievements.clearAchievement [" + param1.id + "] steam stored " + _loc3_);
               }
            }
         }
      }
      
      override public function get canShowPlatformAchievements() : Boolean
      {
         return true;
      }
      
      override public function showPlatformAchievements() : void
      {
         var _loc1_:int = 0;
         var _loc2_:* = null;
         var _loc3_:String = null;
         var _loc4_:URLRequest = null;
         if(!saga || !saga.logger)
         {
            return;
         }
         saga.logger.info(">>> STATSBUTTON SteamSagaAchievements showPlatformAchievements steamworks=" + this.steamworks);
         if(this.steamworks)
         {
            _loc1_ = this.steamworks.appid;
            if(!this.steamworks.enabled)
            {
               _loc2_ = "http://steamcommunity.com/stats/" + _loc1_ + "/achievements/compare";
               saga.logger.info(">>> STATSBUTTON SteamSagaAchievements disabled fallback [" + _loc2_ + "]");
            }
            else
            {
               if(this.steamworks.SteamUtils_IsOverlayEnabled())
               {
                  saga.logger.info(">>> STATSBUTTON SteamSagaAchievements opening overlay to Achievements");
                  this.steamworks.SteamFriends_ActivateGameOverlay("Achievements");
                  return;
               }
               _loc3_ = this.steamworks.SteamUser_GetSteamID();
               saga.logger.info(">>> STATSBUTTON SteamSagaAchievements sid [" + _loc3_ + "]");
               if(_loc3_)
               {
                  _loc2_ = "http://steamcommunity.com/profiles/" + _loc3_ + "/stats/" + _loc1_ + "/achievements/";
               }
               else
               {
                  _loc2_ = "http://steamcommunity.com/stats/" + _loc1_ + "/achievements/compare";
               }
            }
            saga.logger.info(">>> STATSBUTTON SteamSagaAchievements navigate to [" + _loc2_ + "]");
            if(_loc2_)
            {
               _loc4_ = new URLRequest(_loc2_);
               navigateToURL(_loc4_);
            }
         }
      }
      
      public function isStatFloat(param1:String) : Boolean
      {
         return this._statFloats[param1];
      }
      
      override protected function internal_setStat(param1:String, param2:Number) : void
      {
         var _loc3_:Boolean = false;
         if(!saga || !saga.logger)
         {
            return;
         }
         saga.logger.info("SteamSagaAchievements.setStat " + param1 + " " + param2);
         if(this.steamworks)
         {
            if(this.isStatFloat(param1))
            {
               this.steamworks.SteamUserStats_SetStatFloat(param1,param2);
            }
            else
            {
               this.steamworks.SteamUserStats_SetStatInt(param1,param2);
            }
            _loc3_ = this.steamworks.SteamUserStats_StoreStats();
         }
      }
      
      override public function getStat(param1:String) : Number
      {
         if(!saga || !saga.logger)
         {
            return 0;
         }
         if(this.steamworks)
         {
            if(this.isStatFloat(param1))
            {
               return this.steamworks.SteamUserStats_GetStatFloat(param1);
            }
            return this.steamworks.SteamUserStats_GetStatInt(param1);
         }
         return 0;
      }
   }
}
