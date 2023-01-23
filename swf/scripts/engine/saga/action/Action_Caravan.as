package engine.saga.action
{
   import engine.saga.Saga;
   
   public class Action_Caravan extends Action
   {
       
      
      public function Action_Caravan(param1:ActionDef, param2:Saga)
      {
         super(param1,param2);
      }
      
      override protected function handleStarted() : void
      {
         saga.setCaravanById(def.id);
         end();
      }
   }
}
