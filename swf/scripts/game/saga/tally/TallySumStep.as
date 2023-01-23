package game.saga.tally
{
   import engine.resource.loader.SoundControllerManager;
   import engine.saga.SagaVar;
   
   public class TallySumStep extends TallyStep implements ITallyStep
   {
       
      
      public function TallySumStep(param1:String, param2:SoundControllerManager)
      {
         super(param1,SagaVar.VAR_DAYS_REMAINING,"",param2);
         text = param1;
         multValue = 1;
         startValue = 0;
         isSum = true;
         currentValue = 0;
      }
   }
}
