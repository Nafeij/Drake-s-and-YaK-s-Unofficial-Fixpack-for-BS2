package engine.saga.action
{
   import engine.saga.Saga;
   
   public class Action_WaitClick extends Action
   {
       
      
      private var sneaky:Boolean;
      
      public function Action_WaitClick(param1:ActionDef, param2:Saga)
      {
         super(param1,param2);
      }
      
      override protected function handleStarted() : void
      {
         this.sneaky = Boolean(def.param) && def.param.indexOf("sneaky") >= 0;
      }
      
      override public function triggerClick(param1:String) : Boolean
      {
         if(param1 == def.id)
         {
            end();
            return !this.sneaky;
         }
         return false;
      }
      
      override public function triggerSceneExit(param1:String, param2:int) : void
      {
         logger.info("Action_WaitClick.triggerSceneExit stopping our parent happening: " + this);
         happening.end(true);
      }
   }
}
