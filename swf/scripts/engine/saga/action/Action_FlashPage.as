package engine.saga.action
{
   import engine.saga.Saga;
   
   public class Action_FlashPage extends Action
   {
       
      
      private var disableCloseButton:Boolean;
      
      public function Action_FlashPage(param1:ActionDef, param2:Saga)
      {
         super(param1,param2);
      }
      
      override protected function handleStarted() : void
      {
         var _loc1_:String = translateMsg(def.msg);
         _loc1_ = saga.performStringReplacement_SagaVar(_loc1_);
         this.disableCloseButton = Boolean(def.param) && def.param.indexOf("disableCloseButton") >= 0;
         saga.performFlashPage(def.url,_loc1_,def.time,this.disableCloseButton);
      }
      
      override public function triggerFlashPageFinished(param1:String) : void
      {
         if(param1 == def.url && !this.disableCloseButton)
         {
            end();
         }
      }
      
      override public function triggerFlashPageReady(param1:String) : void
      {
         if(param1 == def.url)
         {
            if(def.instant || def.time <= 0 && !this.disableCloseButton)
            {
               end();
            }
         }
      }
   }
}
