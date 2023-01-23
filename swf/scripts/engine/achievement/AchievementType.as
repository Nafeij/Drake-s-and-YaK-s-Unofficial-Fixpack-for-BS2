package engine.achievement
{
   import engine.core.util.Enum;
   
   public class AchievementType extends Enum
   {
      
      public static const TEST:AchievementType = new AchievementType("TEST",enumCtorKey);
      
      public static const BATTLES:AchievementType = new AchievementType("BATTLES",enumCtorKey);
      
      public static const WINS:AchievementType = new AchievementType("WINS",enumCtorKey);
      
      public static const KILLS:AchievementType = new AchievementType("KILLS",enumCtorKey);
      
      public static const ELO:AchievementType = new AchievementType("ELO",enumCtorKey);
      
      public static const STREAK:AchievementType = new AchievementType("STREAK",enumCtorKey);
      
      public static const UNIT_KILL:AchievementType = new AchievementType("UNIT_KILL",enumCtorKey);
      
      public static const CLASS_UNLOCK:AchievementType = new AchievementType("CLASS_UNLOCK",enumCtorKey);
      
      public static const LOCATION:AchievementType = new AchievementType("LOCATION",enumCtorKey);
      
      public static const COMPLETE:AchievementType = new AchievementType("COMPLETE",enumCtorKey);
      
      public static const TRAINING:AchievementType = new AchievementType("TRAINING",enumCtorKey);
      
      public static const OBJECTIVE:AchievementType = new AchievementType("OBJECTIVE",enumCtorKey);
       
      
      public function AchievementType(param1:String, param2:Object)
      {
         super(param1,param2);
      }
   }
}
