package engine.saga.action
{
   import engine.saga.Saga;
   
   public class Action_ShowCaravan extends Action
   {
       
      
      public function Action_ShowCaravan(param1:ActionDef, param2:Saga)
      {
         super(param1,param2);
      }
      
      override protected function handleStarted() : void
      {
         saga.showCaravan = def.varvalue != 0;
         end();
      }
   }
}
