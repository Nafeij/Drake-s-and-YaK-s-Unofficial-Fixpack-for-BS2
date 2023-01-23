package engine.saga.action
{
   import engine.saga.Saga;
   
   public class Action_BattleWaitMoveStop extends Action_BattleWaitMove
   {
       
      
      public function Action_BattleWaitMoveStop(param1:ActionDef, param2:Saga)
      {
         super(param1,param2,false);
      }
   }
}
