package engine.saga.action
{
   import engine.saga.Saga;
   import engine.saga.SagaAchievements;
   
   public class Action_Achievement extends Action
   {
       
      
      public function Action_Achievement(param1:ActionDef, param2:Saga)
      {
         super(param1,param2);
      }
      
      override protected function handleStarted() : void
      {
         if(!saga.def.achievements.fetch(def.id))
         {
            logger.error("No such achievement for " + this);
         }
         else if(SagaAchievements.unlockAchievementById(def.id,saga.minutesPlayed,true))
         {
            logger.info("Unlocked! " + this);
         }
         end();
      }
   }
}
