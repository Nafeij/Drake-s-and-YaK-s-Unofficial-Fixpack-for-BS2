package engine.saga.action
{
   import engine.battle.board.model.BattleBoard;
   import engine.saga.Saga;
   
   public class Action_BattleMoraleEnable extends Action
   {
       
      
      public function Action_BattleMoraleEnable(param1:ActionDef, param2:Saga)
      {
         super(param1,param2);
      }
      
      override protected function handleStarted() : void
      {
         var _loc1_:BattleBoard = saga.getBattleBoard();
         if(_loc1_)
         {
            _loc1_.moraleDisabled = def.varvalue == 0;
         }
         end();
      }
   }
}
