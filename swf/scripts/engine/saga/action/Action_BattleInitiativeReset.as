package engine.saga.action
{
   import engine.battle.board.model.BattleBoard;
   import engine.battle.board.model.IBattleEntity;
   import engine.battle.fsm.IBattleTurnOrder;
   import engine.entity.def.IEntityDef;
   import engine.saga.Saga;
   
   public class Action_BattleInitiativeReset extends Action
   {
       
      
      public function Action_BattleInitiativeReset(param1:ActionDef, param2:Saga)
      {
         super(param1,param2);
      }
      
      override protected function handleStarted() : void
      {
         var _loc3_:String = null;
         var _loc4_:IBattleEntity = null;
         var _loc5_:IEntityDef = null;
         var _loc6_:int = 0;
         var _loc1_:BattleBoard = saga.getBattleBoard();
         var _loc2_:IBattleTurnOrder = Boolean(_loc1_) && Boolean(_loc1_.fsm) ? _loc1_.fsm.order : null;
         if(_loc2_)
         {
            _loc2_.resetTurnOrder();
            _loc3_ = def.id;
            if(_loc3_)
            {
               if(Boolean(_loc3_) && _loc3_.charAt(0) == "$")
               {
                  _loc5_ = saga.getCastMember(_loc3_);
                  if(_loc5_)
                  {
                     _loc3_ = String(_loc5_.id);
                  }
               }
               _loc4_ = _loc1_.getEntityByIdOrByDefId(_loc3_,null,false);
               if(!_loc4_)
               {
                  logger.info("Action_BattleUnitStat No such entity [" + _loc3_ + "]");
               }
               else
               {
                  _loc6_ = _loc1_.fsm.order.aliveOrder.indexOf(_loc4_);
                  if(_loc6_ >= 0)
                  {
                  }
               }
            }
         }
         end();
      }
   }
}
