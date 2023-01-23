package engine.saga.action
{
   import engine.saga.Saga;
   
   public class Action_Scene extends Action
   {
       
      
      public function Action_Scene(param1:ActionDef, param2:Saga)
      {
         super(param1,param2);
      }
      
      override protected function handleStarted() : void
      {
         if(!def.scene)
         {
            logger.error("No such scene [" + def.scene + "] for " + this);
            end();
         }
         saga.performSceneStart(def.scene,def.happeningId,true);
         if(def.instant)
         {
            end();
         }
      }
      
      override protected function handleTriggerSceneLoaded(param1:String, param2:int) : void
      {
         if(param1 == def.scene)
         {
            end();
         }
      }
   }
}
