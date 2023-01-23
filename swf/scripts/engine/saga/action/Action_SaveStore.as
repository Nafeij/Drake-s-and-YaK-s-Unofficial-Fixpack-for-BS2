package engine.saga.action
{
   import engine.saga.Saga;
   
   public class Action_SaveStore extends Action
   {
       
      
      public function Action_SaveStore(param1:ActionDef, param2:Saga)
      {
         super(param1,param2);
      }
      
      override protected function handleStarted() : void
      {
         var _loc1_:Boolean = false;
         if(saga.profile_index >= 0)
         {
            _loc1_ = Boolean(def.param) && def.param.indexOf("force") >= 0;
            if(!saga.saveSaga(def.id,this.happening,def.happeningId,_loc1_))
            {
               saga.logger.error("Unable to save: [" + def.id + "]:[" + def.happeningId + "] reason [" + saga.cannotSaveReason + "]");
            }
         }
         end();
      }
   }
}
