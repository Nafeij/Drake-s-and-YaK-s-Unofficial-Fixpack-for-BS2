package engine.saga.action
{
   import engine.battle.Fastall;
   import engine.saga.Saga;
   
   public class Action_Fastall extends Action
   {
       
      
      public function Action_Fastall(param1:ActionDef, param2:Saga)
      {
         super(param1,param2);
      }
      
      override protected function handleStarted() : void
      {
         Fastall.fastall = def.varvalue != 0;
         end();
      }
   }
}
