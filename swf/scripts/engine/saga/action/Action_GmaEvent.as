package engine.saga.action
{
   import engine.core.analytic.GmA;
   import engine.saga.Saga;
   
   public class Action_GmaEvent extends Action
   {
       
      
      public function Action_GmaEvent(param1:ActionDef, param2:Saga)
      {
         super(param1,param2);
      }
      
      override protected function handleStarted() : void
      {
         if(!def.id)
         {
            throw new ArgumentError("Id required for " + this);
         }
         GmA.trackCustom(def.id,def.varvalue);
         end();
      }
   }
}
