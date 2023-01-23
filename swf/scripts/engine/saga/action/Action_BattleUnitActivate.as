package engine.saga.action
{
   import engine.battle.board.model.BattleBoard;
   import engine.battle.board.model.IBattleEntity;
   import engine.entity.def.IEntityDef;
   import engine.saga.Saga;
   
   public class Action_BattleUnitActivate extends Action
   {
       
      
      public function Action_BattleUnitActivate(param1:ActionDef, param2:Saga)
      {
         super(param1,param2);
      }
      
      override protected function handleStarted() : void
      {
         var _loc4_:Array = null;
         var _loc5_:* = false;
         var _loc6_:String = null;
         var _loc7_:IBattleEntity = null;
         var _loc8_:IEntityDef = null;
         if(!def.id)
         {
            return;
         }
         var _loc1_:String = def.param;
         var _loc2_:Boolean = Boolean(_loc1_) && _loc1_.indexOf("allowDead") >= 0;
         var _loc3_:BattleBoard = saga.getBattleBoard();
         if(_loc3_)
         {
            _loc4_ = def.id.split(",");
            _loc5_ = def.varvalue != 0;
            for each(_loc6_ in _loc4_)
            {
               if(Boolean(_loc6_) && _loc6_.charAt(0) == "$")
               {
                  _loc8_ = saga.getCastMember(_loc6_);
                  if(_loc8_)
                  {
                     _loc6_ = _loc8_.id;
                  }
               }
               _loc7_ = _loc3_.getEntityByIdOrByDefId(_loc6_,null,_loc2_);
               if(_loc7_)
               {
                  if(_loc7_.active != _loc5_)
                  {
                     logger.info("Action_BattleUnitActivate " + (_loc5_ ? "ACTIVATING " : "DEACTIVATING ") + _loc7_ + ": " + this);
                     _loc7_.active = _loc5_;
                     if(_loc5_)
                     {
                        if(Boolean(_loc3_.fsm) && Boolean(_loc3_.fsm.order))
                        {
                           _loc3_.fsm.order.addEntity(_loc7_);
                        }
                     }
                  }
               }
               else
               {
                  logger.info("Action_BattleUnitActivate NOT FOUND ID [" + _loc6_ + "]: " + this);
               }
            }
         }
         end();
      }
   }
}
