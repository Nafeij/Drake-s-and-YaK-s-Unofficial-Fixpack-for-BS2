package engine.saga.action
{
   import engine.saga.Saga;
   
   public class Action_WaitMapInfo extends Action
   {
       
      
      public function Action_WaitMapInfo(param1:ActionDef, param2:Saga)
      {
         super(param1,param2);
      }
      
      override protected function handleStarted() : void
      {
      }
      
      override public function triggerMapInfo(param1:String) : void
      {
         if(def.id == "*" || param1 == def.id || !param1 && !def.id)
         {
            end();
         }
      }
      
      override public function fastForward() : Boolean
      {
         end();
         return true;
      }
   }
}
