package engine.saga
{
   import engine.achievement.AchievementDef;
   import engine.achievement.AchievementListDef;
   import engine.battle.board.model.IBattleEntity;
   import engine.core.analytic.Ga;
   
   public class SagaAchievements
   {
      
      private static var _impl:ISagaAchievements;
       
      
      public function SagaAchievements()
      {
         super();
      }
      
      public static function clearLocals() : void
      {
         _impl.clearLocals();
      }
      
      public static function get impl() : ISagaAchievements
      {
         if(_impl == null)
         {
            throw new Error("SagaAchievements impl has not been set.");
         }
         return _impl;
      }
      
      public static function set impl(param1:ISagaAchievements) : void
      {
         SagaAchievements._impl = param1;
      }
      
      public static function setSaga(param1:ISaga) : void
      {
         _impl.setSaga(param1);
      }
      
      public static function removeSaga(param1:ISaga) : void
      {
         _impl.removeSaga(param1);
      }
      
      public static function setStat(param1:String, param2:Number) : void
      {
         _impl.setStat(param1,param2);
      }
      
      public static function getStat(param1:String) : Number
      {
         return _impl.getStat(param1);
      }
      
      public static function unlockAchievementById(param1:String, param2:int, param3:Boolean) : Boolean
      {
         var _loc4_:Boolean = _impl.unlockAchievementById(param1,param3);
         if(param3 && _loc4_)
         {
            Ga.normal("game","achievement",param1,param2);
            if(Saga.instance)
            {
               Saga.instance.handleAchievementUnlocked(param1);
            }
         }
         return _loc4_;
      }
      
      public static function clearAchievementById(param1:String) : void
      {
         _impl.clearAchievementById(param1);
      }
      
      public static function unlockAchievementLocal(param1:AchievementDef, param2:int) : Boolean
      {
         Ga.normal("game","achievement",param1.id,param2);
         if(Saga.instance)
         {
            Saga.instance.handleAchievementUnlocked(param1.id);
         }
         return true;
      }
      
      public static function unlockAchievement(param1:AchievementDef, param2:int, param3:Boolean) : Boolean
      {
         if(!param1)
         {
            return false;
         }
         var _loc4_:Boolean = Boolean(param1) && _impl.unlockAchievement(param1,param3);
         if(param3 && _loc4_)
         {
            Ga.normal("game","achievement",param1.id,param2);
            if(Saga.instance)
            {
               Saga.instance.handleAchievementUnlocked(param1.id);
            }
         }
         return _loc4_;
      }
      
      public static function clearAchievement(param1:AchievementDef) : void
      {
         _impl.clearAchievement(param1);
      }
      
      public static function clearAllAchievements() : void
      {
         _impl.clearAllAchievements();
      }
      
      public static function handlePlayerKill(param1:IBattleEntity) : void
      {
         return _impl.handlePlayerKill(param1);
      }
      
      public static function get unlocked() : Vector.<String>
      {
         return _impl.unlocked;
      }
      
      public static function isUnlocked(param1:String) : Boolean
      {
         return _impl.isUnlocked(param1);
      }
      
      public static function showPlatformAchievements() : void
      {
         _impl.showPlatformAchievements();
      }
      
      public static function get canShowPlatformAchievements() : Boolean
      {
         return _impl.canShowPlatformAchievements;
      }
      
      public static function setupSaga(param1:ISaga) : void
      {
         var _loc3_:AchievementDef = null;
         var _loc2_:AchievementListDef = param1.achievements;
         for each(_loc3_ in _loc2_.defs)
         {
            if(isUnlocked(_loc3_.id))
            {
               param1.setVar(_loc3_.id,true);
            }
         }
      }
   }
}
