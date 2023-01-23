package engine.saga.action
{
   import engine.saga.Saga;
   
   public class Action_WaitBattleSetup extends Action
   {
       
      
      public function Action_WaitBattleSetup(param1:ActionDef, param2:Saga)
      {
         super(param1,param2);
      }
      
      override protected function handleStarted() : void
      {
         if(saga.isBattleSetup())
         {
            end();
         }
      }
      
      override public function triggerBattleSetup(param1:String) : void
      {
         end();
      }
   }
}
