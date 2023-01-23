package engine.saga.action
{
   import engine.saga.Saga;
   
   public class Action_BattleLoseMusic extends Action
   {
       
      
      public function Action_BattleLoseMusic(param1:ActionDef, param2:Saga)
      {
         super(param1,param2);
      }
      
      override protected function handleStarted() : void
      {
         saga.performBattleFinishMusic(false);
         end();
      }
   }
}
