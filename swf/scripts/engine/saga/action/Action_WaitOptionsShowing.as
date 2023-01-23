package engine.saga.action
{
   import engine.saga.Saga;
   
   public class Action_WaitOptionsShowing extends Action
   {
       
      
      private var sneaky:Boolean;
      
      public function Action_WaitOptionsShowing(param1:ActionDef, param2:Saga)
      {
         super(param1,param2);
      }
      
      override protected function handleStarted() : void
      {
         var _loc1_:* = def.varvalue != 0;
         if(saga.isOptionsShowing == _loc1_)
         {
            end();
         }
      }
      
      override public function triggerOptionsShowing(param1:Boolean) : void
      {
         var _loc2_:* = def.varvalue != 0;
         if(param1 == _loc2_)
         {
            end();
         }
      }
   }
}
