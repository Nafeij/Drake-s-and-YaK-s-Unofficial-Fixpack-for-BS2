package engine.saga.action
{
   import engine.saga.Saga;
   
   public class Action_BattleSnapshotLoad extends Action implements IActionListener
   {
       
      
      public var a:Action;
      
      public function Action_BattleSnapshotLoad(param1:ActionDef, param2:Saga)
      {
         super(param1,param2);
      }
      
      override protected function handleStarted() : void
      {
         this.a = saga.battleSnapshotLoad(def.id,null);
         if(!this.a || this.a.ended || def.instant)
         {
            end();
            return;
         }
         this.a.listener = this;
      }
      
      public function actionListenerHandleActionEnded(param1:Action) : void
      {
         if(!this.a || this.a.ended)
         {
            if(this.a)
            {
               this.a.listener = null;
            }
            this.a = null;
            end();
         }
      }
   }
}
