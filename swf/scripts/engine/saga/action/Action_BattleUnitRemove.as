package engine.saga.action
{
   import engine.battle.board.model.IBattleBoard;
   import engine.battle.board.model.IBattleEntity;
   import engine.entity.def.IEntityDef;
   import engine.saga.Saga;
   import flash.errors.IllegalOperationError;
   
   public class Action_BattleUnitRemove extends Action
   {
       
      
      public function Action_BattleUnitRemove(param1:ActionDef, param2:Saga)
      {
         super(param1,param2);
      }
      
      override protected function handleStarted() : void
      {
         var _loc1_:String = def.id;
         if(!_loc1_)
         {
            throw new IllegalOperationError("No id");
         }
         _loc1_ = saga.performStringReplacement_SagaVar(_loc1_);
         var _loc2_:IEntityDef = saga.getCastMember(_loc1_);
         if(_loc2_)
         {
            _loc1_ = String(_loc2_.id);
         }
         var _loc3_:IBattleBoard = saga.getIBattleBoard();
         if(!_loc3_)
         {
            throw new IllegalOperationError("No battle board");
         }
         var _loc4_:String = def.param;
         var _loc5_:Boolean = Boolean(_loc4_) && _loc4_.indexOf("allowDead") >= 0;
         var _loc6_:IBattleEntity = _loc3_.getEntityByIdOrByDefId(_loc1_,null,_loc5_);
         if(!_loc6_)
         {
            logger.info("Action_BattleUnitStat No such entity [" + _loc1_ + "]");
         }
         else
         {
            _loc3_.removeEntity(_loc6_);
            _loc6_.cleanup();
         }
         end();
      }
   }
}
