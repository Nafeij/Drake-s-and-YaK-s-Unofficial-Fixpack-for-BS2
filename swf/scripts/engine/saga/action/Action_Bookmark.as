package engine.saga.action
{
   import engine.saga.Saga;
   
   public class Action_Bookmark extends Action
   {
       
      
      public function Action_Bookmark(param1:ActionDef, param2:Saga)
      {
         super(param1,param2);
      }
      
      override protected function handleStarted() : void
      {
         saga.gotoBookmark(def.happeningId,false);
         end();
      }
   }
}
