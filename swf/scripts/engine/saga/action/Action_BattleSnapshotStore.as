package engine.saga.action
{
   import engine.saga.Saga;
   
   public class Action_BattleSnapshotStore extends Action
   {
       
      
      public function Action_BattleSnapshotStore(param1:ActionDef, param2:Saga)
      {
         super(param1,param2);
      }
      
      override protected function handleStarted() : void
      {
         saga.battleSnapshotStore(def.id);
         end();
      }
   }
}
