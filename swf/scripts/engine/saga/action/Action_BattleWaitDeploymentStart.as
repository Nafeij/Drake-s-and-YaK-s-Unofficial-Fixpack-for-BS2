package engine.saga.action
{
   import engine.saga.Saga;
   
   public class Action_BattleWaitDeploymentStart extends Action
   {
       
      
      public function Action_BattleWaitDeploymentStart(param1:ActionDef, param2:Saga)
      {
         super(param1,param2);
      }
      
      override protected function handleStarted() : void
      {
         this.checkReady();
      }
      
      override public function triggerBattleDeploymentStart(param1:String) : void
      {
         this.checkReady();
      }
      
      override public function handleTriggerSceneVisible(param1:String, param2:int) : void
      {
         this.checkReady();
      }
      
      private function checkReady() : void
      {
         if(saga.isBattleDeploymentStarted() && saga.isSceneVisible())
         {
            end();
         }
      }
   }
}
