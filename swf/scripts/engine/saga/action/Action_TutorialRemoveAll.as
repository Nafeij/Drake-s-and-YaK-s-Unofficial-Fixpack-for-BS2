package engine.saga.action
{
   import engine.saga.Saga;
   
   public class Action_TutorialRemoveAll extends Action
   {
       
      
      public function Action_TutorialRemoveAll(param1:ActionDef, param2:Saga)
      {
         super(param1,param2);
      }
      
      override protected function handleStarted() : void
      {
         saga.performTutorialRemoveAll(this.toString());
         end();
      }
   }
}
