package engine.saga.action
{
   import engine.saga.Saga;
   
   public class Action_StartPage extends Action
   {
       
      
      public function Action_StartPage(param1:ActionDef, param2:Saga)
      {
         super(param1,param2);
      }
      
      override protected function handleStarted() : void
      {
         var _loc1_:* = def.varvalue != 0;
         saga.showStartPage(_loc1_);
         end();
      }
   }
}
