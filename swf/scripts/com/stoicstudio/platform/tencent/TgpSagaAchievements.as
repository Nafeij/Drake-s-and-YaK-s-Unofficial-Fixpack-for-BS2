package com.stoicstudio.platform.tencent
{
   import air.tencent.ane.TencentAne;
   import air.tencent.ane.TgpEvent;
   import engine.achievement.AchievementDef;
   import engine.saga.ISaga;
   import engine.saga.NullSagaAchievements;
   import engine.saga.vars.IVariable;
   import flash.events.Event;
   import flash.utils.Dictionary;
   
   public final class TgpSagaAchievements extends NullSagaAchievements
   {
       
      
      private var tencent:TencentAne = null;
      
      private var fromTgp:Dictionary;
      
      public function TgpSagaAchievements(param1:TencentAne)
      {
         this.fromTgp = new Dictionary();
         super();
         this.tencent = param1;
      }
      
      override public function setSaga(param1:ISaga) : void
      {
         super.setSaga(param1);
         this.initAchievementsFromTgp();
      }
      
      override public function cleanup() : void
      {
         this.tencent.removeEventListener(TgpEvent.USER_STATS,this.tgpUserStatsHandler);
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
            _loc2_ = this.tencent.TencentAPI_ClearAchievement(param1.id);
            this.tencent.logger.i("TENCECNT","Result of clear: " + _loc2_);
            if(param1.progressVar)
            {
               _loc4_ = saga.getVar(param1.progressVar,null);
               if(Boolean(_loc4_) && Boolean(_loc4_.def.achievement_stat))
               {
                  this.tencent.TencentAPI_SetStatInt(_loc4_.def.achievement_stat,0,_loc4_.def.upperBound);
               }
            }
            _loc3_ = this.tencent.TencentAPI_StoreStats();
            this.tencent.logger.i("TENCENT","SagaAchievements.clearAchievement [" + param1.id + "] tgp " + _loc2_);
            this.tencent.logger.i("TENCENT","SagaAchievements.clearAchievement [" + param1.id + "] tgp stored " + _loc3_);
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
         var _loc2_:String = this.tencent.TencentAPI_GetStat(param1);
         var _loc3_:Object = JSON.parse(_loc2_);
         return _loc3_.cur_value as Number;
      }
      
      override protected function internal_unlockAchievement(param1:AchievementDef) : void
      {
         var _loc2_:Boolean = false;
         var _loc3_:Boolean = false;
         super.internal_unlockAchievement(param1);
         if(!this.fromTgp[param1.id] && !param1.local)
         {
            _loc2_ = this.tencent.TencentAPI_SetAchievement(param1.id);
            _loc3_ = this.tencent.TencentAPI_StoreStats();
            this.tencent.logger.i("TENCENT","SagaAchievements.unlockAchievement [" + param1.id + "] tgp set " + _loc2_);
            this.tencent.logger.i("TENCENT","SagaAchievements.unlockAchievement [" + param1.id + "] tgp stored " + _loc3_);
         }
      }
      
      override protected function internal_setStat(param1:String, param2:Number) : void
      {
         super.internal_setStat(param1,param2);
         if(!saga)
         {
            return;
         }
         var _loc3_:int = 0;
         this.tencent.TencentAPI_SetStatInt(param1,param2,_loc3_);
         var _loc4_:Boolean = this.tencent.TencentAPI_StoreStats();
      }
      
      private function initAchievementsFromTgp() : void
      {
         var _loc1_:AchievementDef = null;
         var _loc2_:Boolean = false;
         var _loc3_:String = null;
         var _loc4_:Boolean = false;
         var _loc5_:Boolean = false;
         var _loc6_:Boolean = false;
         if(!saga || !saga.def || !saga.def.achievements)
         {
            this.tencent.logger.i("TENCENT","Something wrong with cheeve init saga");
         }
         if(!this.tencent.userStatsReady)
         {
            this.tencent.logger.i("TENCENT","user stats are not ready");
            this.tencent.addEventListener(TgpEvent.USER_STATS,this.tgpUserStatsHandler);
            this.tencent.TencentAPI_AsyncRequestAchievement();
            return;
         }
         for each(_loc1_ in saga.def.achievements.defs)
         {
            _loc4_ = this.tencent.TencentAPI_GetAchievement(_loc1_.id);
            if(_loc4_)
            {
               this.fromTgp[_loc1_.id] = _loc1_.id;
               this.internal_unlockAchievement(_loc1_);
            }
         }
         _loc2_ = false;
         for each(_loc3_ in _unlocked)
         {
            if(!this.fromTgp[_loc3_])
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
                     _loc5_ = this.tencent.TencentAPI_SetAchievement(_loc3_);
                     if(!_loc5_)
                     {
                        this.tencent.logger.error("Could not set achievements locally with id: " + _loc3_);
                     }
                     _loc2_ = true;
                  }
               }
            }
         }
         if(_loc2_)
         {
            _loc6_ = this.tencent.TencentAPI_StoreStats();
            if(!_loc6_)
            {
               this.tencent.logger.error("Could not set achievemtn remotely with id: " + _loc3_);
            }
         }
      }
      
      private function tgpUserStatsHandler(param1:Event) : void
      {
         this.tencent.logger.i("TENCENT","tgpUserStatsHandler");
         this.tencent.removeEventListener(TgpEvent.USER_STATS,this.tgpUserStatsHandler);
         this.initAchievementsFromTgp();
      }
   }
}
