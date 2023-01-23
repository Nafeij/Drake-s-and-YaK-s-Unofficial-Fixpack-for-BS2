package engine.saga.action
{
   import engine.battle.board.model.BattleBoard;
   import engine.battle.board.model.IBattleEntity;
   import engine.entity.def.IEntityDef;
   import engine.saga.Saga;
   
   public class Action_BattleUnitOnEndTurn extends Action
   {
       
      
      public function Action_BattleUnitOnEndTurn(param1:ActionDef, param2:Saga)
      {
         super(param1,param2);
      }
      
      override protected function handleStarted() : void
      {
         var _loc3_:IEntityDef = null;
         var _loc1_:String = def.id;
         var _loc2_:BattleBoard = saga.getBattleBoard();
         _loc1_ = saga.performStringReplacement_SagaVar(_loc1_);
         _loc3_ = saga.getCastMember(_loc1_);
         if(_loc3_)
         {
            _loc1_ = _loc3_.id;
         }
         var _loc4_:IBattleEntity = _loc2_.getEntityByIdOrByDefId(_loc1_,null,false);
         if(Boolean(_loc4_) && Boolean(_loc4_.effects))
         {
            _loc4_.effects.handleEndTurn();
         }
         end();
      }
   }
}
