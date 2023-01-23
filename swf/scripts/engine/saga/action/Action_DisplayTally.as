package engine.saga.action
{
   import engine.saga.Saga;
   
   public class Action_DisplayTally extends Action
   {
       
      
      public function Action_DisplayTally(param1:ActionDef, param2:Saga)
      {
         super(param1,param2);
      }
      
      override protected function handleStarted() : void
      {
         if(!def || !def.param || !saga)
         {
            end();
            return;
         }
         saga.performTally(def.param,this.onTallyComplete,true);
      }
      
      private function onTallyComplete() : void
      {
         end();
      }
   }
}
