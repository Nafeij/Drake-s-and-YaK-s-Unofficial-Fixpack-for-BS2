package engine.saga.action
{
   import engine.saga.Saga;
   import engine.saga.happening.Happening;
   
   public class Action_HappeningStop extends Action
   {
       
      
      public function Action_HappeningStop(param1:ActionDef, param2:Saga)
      {
         super(param1,param2);
      }
      
      override protected function handleStarted() : void
      {
         var _loc1_:Happening = null;
         for each(_loc1_ in saga.happenings)
         {
            if(_loc1_.def.id == def.happeningId)
            {
               _loc1_.end(true);
            }
         }
         end();
      }
   }
}
