package engine.saga
{
   import engine.achievement.AchievementDef;
   import engine.achievement.AchievementType;
   import engine.battle.board.model.IBattleEntity;
   import engine.saga.vars.IVariable;
   import flash.utils.Dictionary;
   
   public class NullSagaAchievements implements ISagaAchievements
   {
       
      
      protected var progress:Dictionary;
      
      protected var _unlocked:Vector.<String>;
      
      protected var unlockedById:Dictionary;
      
      protected var saga:Saga;
      
      public function NullSagaAchievements()
      {
         this.progress = new Dictionary();
         this._unlocked = new Vector.<String>();
         this.unlockedById = new Dictionary();
         super();
         this._unlocked = new Vector.<String>();
         this.unlockedById = new Dictionary();
         this.progress = new Dictionary();
      }
      
      public function setSaga(param1:ISaga) : void
      {
         this.saga = param1 as Saga;
      }
      
      public function removeSaga(param1:ISaga) : void
      {
         if(this.saga == param1)
         {
            this.saga = null;
         }
      }
      
      public function cleanup() : void
      {
         this.saga = null;
      }
      
      public function incrementProgress(param1:AchievementType, param2:int) : void
      {
         var _loc3_:int = this.getProgress(param1);
         this.setProgress(param1,_loc3_ + param2);
      }
      
      public function setProgress(param1:AchievementType, param2:int) : Boolean
      {
         var _loc4_:AchievementDef = null;
         if(!this.saga)
         {
            return false;
         }
         var _loc3_:int = this.getProgress(param1);
         if(param2 == _loc3_)
         {
            return false;
         }
         this.progress[param1] = param2;
         if(!this.saga.def.achievements)
         {
            return true;
         }
         for each(_loc4_ in this.saga.def.achievements.defs)
         {
            if(_loc4_.type == param1)
            {
               if(_loc3_ < _loc4_.count && param2 >= _loc4_.count)
               {
                  this.unlockAchievement(_loc4_);
               }
            }
         }
         return true;
      }
      
      final public function setStat(param1:String, param2:Number) : void
      {
         if(this.saga.isAchievementsSuppressed)
         {
            this.saga.logger.i(" ACV","suppressing setStat " + param1 + " " + param2);
            return;
         }
         this.internal_setStat(param1,param2);
      }
      
      protected function internal_setStat(param1:String, param2:Number) : void
      {
         if(this.saga.logger.isDebugEnabled)
         {
            this.saga.logger.d(" ACV","setstat " + param1 + " = " + param2);
         }
      }
      
      public function getStat(param1:String) : Number
      {
         return 0;
      }
      
      final public function unlockAchievementById(param1:String, param2:Boolean = true) : Boolean
      {
         if(!this.saga || !this.saga.def.achievements)
         {
            return false;
         }
         var _loc3_:AchievementDef = this.saga.def.achievements.fetch(param1);
         return this.unlockAchievement(_loc3_,param2);
      }
      
      final public function clearAchievementById(param1:String) : void
      {
         if(!this.saga || !this.saga.def.achievements)
         {
            return;
         }
         var _loc2_:AchievementDef = this.saga.def.achievements.fetch(param1);
         this.clearAchievement(_loc2_);
      }
      
      final public function unlockAchievement(param1:AchievementDef, param2:Boolean = true) : Boolean
      {
         var _loc3_:Boolean = false;
         if(!param1 || !this.saga)
         {
            return false;
         }
         if(this.saga.isAchievementsSuppressed)
         {
            this.saga.logger.i(" ACV","suppressing unlock " + param1.id);
            return false;
         }
         if(param2)
         {
            _loc3_ = this.saga.getVarBool(param1.id);
            if(!_loc3_)
            {
               this.saga.setVar(param1.id,true);
            }
         }
         if(this.unlockedById[param1.id])
         {
            return false;
         }
         if(param2)
         {
            this.saga.setVar(param1.id + "_unlk",true);
         }
         this.internal_unlockAchievement(param1);
         return true;
      }
      
      protected function internal_unlockAchievement(param1:AchievementDef) : void
      {
         if(this.unlockedById[param1.id])
         {
            if(this.saga.logger.isDebugEnabled)
            {
               this.saga.logger.d(" ACV","already unlocked -- " + param1);
            }
            return;
         }
         this.saga.logger.i(" ACV","unlock " + param1);
         this.unlockedById[param1.id] = param1.id;
         this._unlocked.push(param1.id);
      }
      
      public function clearAchievement(param1:AchievementDef) : void
      {
         var _loc3_:IVariable = null;
         if(!param1)
         {
            return;
         }
         delete this.unlockedById[param1.id];
         var _loc2_:int = this._unlocked.indexOf(param1.id);
         if(_loc2_ >= 0)
         {
            this._unlocked.splice(_loc2_,1);
         }
         this.saga.setVar(param1.id,false);
         if(param1.progressVar)
         {
            _loc3_ = this.saga.getVar(param1.progressVar,null);
            if(_loc3_)
            {
               _loc3_.asInteger = 0;
            }
         }
      }
      
      public function clearAllAchievements() : void
      {
         var _loc1_:AchievementDef = null;
         for each(_loc1_ in this.saga.def.achievements.defs)
         {
            this.clearAchievement(_loc1_);
         }
      }
      
      public function getProgress(param1:AchievementType) : int
      {
         if(this.progress[param1] != undefined)
         {
            return this.progress[param1];
         }
         return 0;
      }
      
      public function handlePlayerKill(param1:IBattleEntity) : void
      {
         if(this.saga.isAchievementsSuppressed)
         {
            this.saga.logger.info("Acheivement suppressing player kill for " + param1);
            return;
         }
         var _loc2_:String = String(param1.def.entityClass.id);
         var _loc3_:String = "prg_class_" + _loc2_;
         this.saga.incrementGlobalVar(_loc3_,1);
      }
      
      public function get unlocked() : Vector.<String>
      {
         return this._unlocked;
      }
      
      public function isUnlocked(param1:String) : Boolean
      {
         return this.unlockedById[param1];
      }
      
      public function get canShowPlatformAchievements() : Boolean
      {
         return false;
      }
      
      public function showPlatformAchievements() : void
      {
         if(Boolean(this.saga) && Boolean(this.saga.logger))
         {
            this.saga.logger.info(">>> STATSBUTTON NullSagaAchievements showPlatformAchievements");
         }
      }
      
      public function clearLocals() : void
      {
         var _loc2_:String = null;
         var _loc3_:AchievementDef = null;
         if(!this.saga || !this.saga.def || !this._unlocked || !this.saga.def.achievements || !this.unlockedById)
         {
            return;
         }
         var _loc1_:int = 0;
         while(_loc1_ < this._unlocked.length)
         {
            _loc2_ = this._unlocked[_loc1_];
            _loc3_ = this.saga.def.achievements.fetch(_loc2_);
            if(_loc3_)
            {
               if(_loc3_.local)
               {
                  this._unlocked.splice(_loc1_,1);
                  _loc1_--;
                  delete this.unlockedById[_loc2_];
               }
            }
            _loc1_++;
         }
      }
   }
}
