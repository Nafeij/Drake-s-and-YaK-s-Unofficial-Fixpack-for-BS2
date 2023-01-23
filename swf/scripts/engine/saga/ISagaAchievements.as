package engine.saga
{
   import engine.achievement.AchievementDef;
   import engine.achievement.AchievementType;
   import engine.battle.board.model.IBattleEntity;
   
   public interface ISagaAchievements
   {
       
      
      function setSaga(param1:ISaga) : void;
      
      function removeSaga(param1:ISaga) : void;
      
      function cleanup() : void;
      
      function setStat(param1:String, param2:Number) : void;
      
      function getStat(param1:String) : Number;
      
      function incrementProgress(param1:AchievementType, param2:int) : void;
      
      function setProgress(param1:AchievementType, param2:int) : Boolean;
      
      function unlockAchievementById(param1:String, param2:Boolean = true) : Boolean;
      
      function clearAchievementById(param1:String) : void;
      
      function unlockAchievement(param1:AchievementDef, param2:Boolean = true) : Boolean;
      
      function clearAchievement(param1:AchievementDef) : void;
      
      function clearAllAchievements() : void;
      
      function getProgress(param1:AchievementType) : int;
      
      function handlePlayerKill(param1:IBattleEntity) : void;
      
      function showPlatformAchievements() : void;
      
      function get canShowPlatformAchievements() : Boolean;
      
      function get unlocked() : Vector.<String>;
      
      function isUnlocked(param1:String) : Boolean;
      
      function clearLocals() : void;
   }
}
