package engine.saga.action
{
   import engine.battle.board.model.BattleBoard;
   import engine.saga.Saga;
   
   public class Action_BattleSuppressFinish extends Action
   {
       
      
      public function Action_BattleSuppressFinish(param1:ActionDef, param2:Saga)
      {
         super(param1,param2);
      }
      
      override protected function handleStarted() : void
      {
         var _loc2_:String = null;
         var _loc3_:Action = null;
         var _loc4_:Action_Battle = null;
         var _loc1_:BattleBoard = saga.getBattleBoard();
         if(_loc1_)
         {
            _loc2_ = _loc1_.scene.def.url;
            for each(_loc3_ in saga.actions)
            {
               _loc4_ = _loc3_ as Action_Battle;
               if(_loc4_)
               {
                  _loc4_.handleSuppressFinish(def.varvalue != 0);
               }
            }
         }
         end();
      }
   }
}
