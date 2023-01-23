package engine.saga.action
{
   import engine.battle.board.model.BattleBoard;
   import engine.battle.board.model.IBattleEntity;
   import engine.entity.model.IEntity;
   import engine.saga.Saga;
   
   public class Action_BattleUnitEnable extends Action
   {
       
      
      public function Action_BattleUnitEnable(param1:ActionDef, param2:Saga)
      {
         super(param1,param2);
      }
      
      override protected function handleStarted() : void
      {
         var _loc4_:* = false;
         var _loc5_:Vector.<String> = null;
         var _loc6_:Vector.<IEntity> = null;
         var _loc7_:IBattleEntity = null;
         var _loc8_:String = null;
         var _loc9_:IBattleEntity = null;
         if(!def.id)
         {
            return;
         }
         var _loc1_:String = def.param;
         var _loc2_:Boolean = Boolean(_loc1_) && _loc1_.indexOf("allowDead") >= 0;
         var _loc3_:BattleBoard = saga.getBattleBoard();
         if(_loc3_)
         {
            _loc4_ = def.varvalue != 0;
            _loc5_ = new Vector.<String>();
            _loc6_ = extractEntities(def.id,_loc2_,_loc5_);
            for each(_loc7_ in _loc6_)
            {
               _loc9_ = _loc7_ as IBattleEntity;
               if(_loc9_.enabled != _loc4_)
               {
                  logger.info("Action_BattleUnitEnable " + (_loc4_ ? "ENABLING " : "DISABLING ") + _loc9_ + ": " + this);
                  _loc9_.enabled = _loc4_;
                  if(_loc4_)
                  {
                     if(Boolean(_loc3_.fsm) && Boolean(_loc3_.fsm.order))
                     {
                        _loc3_.fsm.order.addEntity(_loc9_);
                     }
                  }
               }
            }
            for each(_loc8_ in _loc5_)
            {
               logger.info("Action_BattleUnitEnable NOT FOUND ID [" + _loc8_ + "]: " + this);
            }
         }
         end();
      }
   }
}
