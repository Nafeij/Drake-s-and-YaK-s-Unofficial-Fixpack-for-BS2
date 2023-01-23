package engine.saga.action
{
   import engine.saga.Saga;
   
   public class Action_WipeInConfig extends Action
   {
       
      
      public function Action_WipeInConfig(param1:ActionDef, param2:Saga)
      {
         super(param1,param2);
      }
      
      override protected function handleStarted() : void
      {
         saga.performWipeInConfig(def.time,def.varvalue);
         end();
      }
   }
}
