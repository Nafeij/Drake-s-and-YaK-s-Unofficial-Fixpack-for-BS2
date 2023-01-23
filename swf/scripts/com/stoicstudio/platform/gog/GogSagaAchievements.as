package com.stoicstudio.platform.gog
{
   import air.gog.ane.GogAne;
   import air.gog.ane.GogEvent;
   import engine.achievement.AchievementDef;
   import engine.saga.ISaga;
   import engine.saga.NullSagaAchievements;
   import engine.saga.vars.IVariable;
   import flash.events.Event;
   import flash.utils.Dictionary;
   
   public class GogSagaAchievements extends NullSagaAchievements
   {
       
      
      private var galaxy:GogAne = null;
      
      private var fromGog:Dictionary;
      
      public function GogSagaAchievements(param1:GogAne)
      {
         this.fromGog = new Dictionary();
         super();
         this.galaxy = param1;
      }
      
      override public function setSaga(param1:ISaga) : void
      {
         super.setSaga(param1);
         this.initAchievementsFromGog();
      }
      
      override public function cleanup() : void
      {
         this.galaxy.removeEventListener(GogEvent.USER_STATS,this.gogUserStatsHandler);
         super.cleanup();
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
         if(!param1.local)
         {
            _loc2_ = this.galaxy.GalaxyAPI_ClearAchievement(param1.id);
            if(param1.progressVar)
            {
               _loc4_ = saga.getVar(param1.progressVar,null);
               if(Boolean(_loc4_) && Boolean(_loc4_.def.achievement_stat))
               {
                  this.galaxy.GalaxyAPI_SetStatInt(_loc4_.def.achievement_stat,0);
               }
            }
            _loc3_ = this.galaxy.GalaxyAPI_StoreAchievements();
            this.galaxy.logger.i("GOG","SagaAchievements.clearAchievement [" + param1.id + "] gog " + _loc2_);
            this.galaxy.logger.i("GOG","SagaAchievements.clearAchievement [" + param1.id + "] gog stored " + _loc3_);
         }
      }
      
      override public function showPlatformAchievements() : void
      {
         super.showPlatformAchievements();
      }
      
      override public function getStat(param1:String) : Number
      {
         if(!saga || !saga.logger)
         {
            return 0;
         }
         var _loc2_:Object = this.galaxy.GalaxyAPI_GetStat(param1);
         return _loc2_ as Number;
      }
      
      override protected function internal_unlockAchievement(param1:AchievementDef) : void
      {
         var _loc2_:Boolean = false;
         var _loc3_:Boolean = false;
         super.internal_unlockAchievement(param1);
         if(!this.fromGog[param1.id] && !param1.local)
         {
            _loc2_ = this.galaxy.GalaxyAPI_SetAchievement(param1.id);
            _loc3_ = this.galaxy.GalaxyAPI_StoreAchievements();
            this.galaxy.logger.i("GOG","SagaAchievements.unlockAchievement [" + param1.id + "] gog set " + _loc2_);
            this.galaxy.logger.i("GOG","SagaAchievements.unlockAchievement [" + param1.id + "] gog stored " + _loc3_);
         }
      }
      
      override protected function internal_setStat(param1:String, param2:Number) : void
      {
         super.internal_setStat(param1,param2);
         if(!saga)
         {
            return;
         }
         this.galaxy.GalaxyAPI_SetStatInt(param1,param2);
      }
      
      private function initAchievementsFromGog() : void
      {
         var _loc1_:AchievementDef = null;
         var _loc2_:Boolean = false;
         var _loc3_:String = null;
         var _loc4_:Boolean = false;
         var _loc5_:Boolean = false;
         var _loc6_:Boolean = false;
         if(!saga || !saga.def || !saga.def.achievements)
         {
            this.galaxy.logger.i("GOG","Something wrong with cheeve init saga");
         }
         if(!this.galaxy.userStatsReady)
         {
            this.galaxy.logger.i("GOG","user stats are not ready");
            this.galaxy.addEventListener(GogEvent.USER_STATS,this.gogUserStatsHandler);
            this.galaxy.GalaxyAPI_AsyncRequestAchievement();
            return;
         }
         for each(_loc1_ in saga.def.achievements.defs)
         {
            _loc4_ = this.galaxy.GalaxyAPI_GetAchievement(_loc1_.id);
            if(_loc4_)
            {
               this.fromGog[_loc1_.id] = _loc1_.id;
               this.internal_unlockAchievement(_loc1_);
            }
         }
         _loc2_ = false;
         for each(_loc3_ in _unlocked)
         {
            if(!this.fromGog[_loc3_])
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
                     _loc5_ = this.galaxy.GalaxyAPI_SetAchievement(_loc3_);
                     if(!_loc5_)
                     {
                        this.galaxy.logger.error("Could not set achievements locally with id: " + _loc3_);
                     }
                     _loc2_ = true;
                  }
               }
            }
         }
         if(_loc2_)
         {
            _loc6_ = this.galaxy.GalaxyAPI_StoreAchievements();
            if(!_loc6_)
            {
               this.galaxy.logger.error("Could not set achievement remotely with id: " + _loc3_);
            }
         }
      }
      
      private function gogUserStatsHandler(param1:Event) : void
      {
         this.galaxy.removeEventListener(GogEvent.USER_STATS,this.gogUserStatsHandler);
         this.initAchievementsFromGog();
      }
   }
}
