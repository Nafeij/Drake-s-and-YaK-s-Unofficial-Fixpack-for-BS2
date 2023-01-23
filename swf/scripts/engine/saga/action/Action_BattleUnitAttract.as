package engine.saga.action
{
   import engine.battle.board.def.IBattleAttractor;
   import engine.battle.board.model.BattleBoard;
   import engine.battle.board.model.IBattleEntity;
   import engine.entity.model.IEntity;
   import engine.saga.Saga;
   import flash.errors.IllegalOperationError;
   
   public class Action_BattleUnitAttract extends Action
   {
       
      
      public function Action_BattleUnitAttract(param1:ActionDef, param2:Saga)
      {
         super(param1,param2);
      }
      
      override protected function handleStarted() : void
      {
         var _loc6_:IBattleEntity = null;
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
         var _loc4_:IBattleAttractor = _loc3_.getAttractorById(_loc2_);
         if(!_loc4_)
         {
            throw new IllegalOperationError("invalid attractor [" + _loc2_ + "]");
         }
         var _loc5_:Vector.<IEntity> = extractEntities(_loc1_,false);
         for each(_loc6_ in _loc5_)
         {
            _loc6_.attractor = _loc4_;
         }
         end();
      }
   }
}
