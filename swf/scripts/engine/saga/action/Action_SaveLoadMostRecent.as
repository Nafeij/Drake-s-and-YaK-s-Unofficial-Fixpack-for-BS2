package engine.saga.action
{
   import engine.saga.Saga;
   
   public class Action_SaveLoadMostRecent extends Action
   {
       
      
      public function Action_SaveLoadMostRecent(param1:ActionDef, param2:Saga)
      {
         super(param1,param2);
      }
      
      override protected function handleStarted() : void
      {
         saga.loadMostRecentSave(true,saga.profile_index);
         end();
      }
   }
}
