package engine.saga.action
{
   import engine.battle.board.def.IBattleAttractor;
   import engine.battle.board.model.BattleBoard;
   import engine.saga.Saga;
   import flash.errors.IllegalOperationError;
   
   public class Action_BattleAttractorEnable extends Action
   {
       
      
      public function Action_BattleAttractorEnable(param1:ActionDef, param2:Saga)
      {
         super(param1,param2);
      }
      
      override protected function handleStarted() : void
      {
         var _loc1_:BattleBoard = saga.getBattleBoard();
         if(!_loc1_)
         {
            throw new IllegalOperationError("no board");
         }
         var _loc2_:String = def.anchor;
         var _loc3_:IBattleAttractor = _loc1_.getAttractorById(_loc2_);
         if(!_loc3_)
         {
            throw new IllegalOperationError("invalid attractor [" + _loc2_ + "]");
         }
         var _loc4_:* = def.varvalue != 0;
         _loc3_.enabled = _loc4_;
         end();
      }
   }
}
