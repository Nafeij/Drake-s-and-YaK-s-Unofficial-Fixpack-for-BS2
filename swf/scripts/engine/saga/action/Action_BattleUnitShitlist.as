package engine.saga.action
{
   import engine.battle.board.model.BattleBoard;
   import engine.battle.board.model.IBattleEntity;
   import engine.entity.model.IEntity;
   import engine.saga.Saga;
   import flash.errors.IllegalOperationError;
   
   public class Action_BattleUnitShitlist extends Action
   {
       
      
      public function Action_BattleUnitShitlist(param1:ActionDef, param2:Saga)
      {
         super(param1,param2);
      }
      
      override protected function handleStarted() : void
      {
         var _loc5_:IBattleEntity = null;
         if(!def.id)
         {
            return;
         }
         var _loc1_:String = def.id;
         var _loc2_:String = def.anchor;
         var _loc3_:BattleBoard = saga.getBattleBoard();
         if(!_loc3_)
         {
            throw new IllegalOperationError("no board");
         }
         logger.info("extracting entities...");
         logger.info("extracting entities from ids [" + _loc1_ + "]");
         var _loc4_:Vector.<IEntity> = extractEntities(_loc1_,false);
         for each(_loc5_ in _loc4_)
         {
            _loc5_.setShitlistId(_loc2_);
         }
         end();
      }
   }
}
