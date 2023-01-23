package engine.saga.action
{
   import engine.saga.Saga;
   
   public class Action_WaitPage extends Action
   {
       
      
      public function Action_WaitPage(param1:ActionDef, param2:Saga)
      {
         super(param1,param2);
      }
      
      override protected function handleStarted() : void
      {
         var _loc1_:String = saga.currentPageName;
         this.triggerPageStarted(_loc1_);
      }
      
      override public function triggerPageStarted(param1:String) : void
      {
         if(param1 == def.id)
         {
            end();
         }
      }
   }
}
