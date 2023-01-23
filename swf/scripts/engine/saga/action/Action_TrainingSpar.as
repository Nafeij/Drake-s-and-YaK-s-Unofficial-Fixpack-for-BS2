package engine.saga.action
{
   import engine.saga.Saga;
   
   public class Action_TrainingSpar extends Action
   {
       
      
      public function Action_TrainingSpar(param1:ActionDef, param2:Saga)
      {
         super(param1,param2);
      }
      
      override protected function handleStarted() : void
      {
         saga.performTrainingBattle();
         end();
      }
   }
}
