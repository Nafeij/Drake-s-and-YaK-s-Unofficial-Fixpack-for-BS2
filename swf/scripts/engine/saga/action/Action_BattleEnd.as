package engine.saga.action
{
   import engine.battle.board.model.BattleBoard;
   import engine.battle.fsm.BattleFsm;
   import engine.saga.Saga;
   
   public class Action_BattleEnd extends Action
   {
       
      
      public function Action_BattleEnd(param1:ActionDef, param2:Saga)
      {
         super(param1,param2);
      }
      
      override protected function handleStarted() : void
      {
         var _loc1_:BattleBoard = saga.getBattleBoard();
         var _loc2_:BattleFsm = !!_loc1_ ? _loc1_.fsm as BattleFsm : null;
         var _loc3_:Boolean = Boolean(def.param) && def.param.indexOf("defeat") >= 0;
         var _loc4_:Boolean = !def.param || (!_loc3_ || def.param.indexOf("victory") >= 0);
         if(_loc2_)
         {
            _loc2_.abortBattle(_loc4_);
         }
         end();
      }
   }
}
