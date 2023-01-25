package engine.saga.action
{
   import engine.battle.board.model.BattleBoard;
   import engine.battle.board.model.IBattleEntity;
   import engine.battle.fsm.IBattleTurn;
   import engine.entity.def.IEntityDef;
   import engine.saga.Saga;
   import engine.tile.def.TileRect;
   
   public class Action_BattleUnitInteract extends Action
   {
       
      
      public function Action_BattleUnitInteract(param1:ActionDef, param2:Saga)
      {
         super(param1,param2);
      }
      
      override protected function handleStarted() : void
      {
         var _loc2_:IBattleTurn = null;
         var _loc3_:IBattleEntity = null;
         var _loc4_:TileRect = null;
         var _loc5_:String = null;
         var _loc6_:IBattleEntity = null;
         var _loc7_:IEntityDef = null;
         var _loc1_:BattleBoard = saga.getBattleBoard();
         if(_loc1_)
         {
            _loc2_ = _loc1_.fsm.turn;
            _loc3_ = !!_loc2_ ? _loc2_.entity : null;
            _loc4_ = !!_loc3_ ? _loc3_.rect : null;
            _loc5_ = def.id;
            if(_loc5_)
            {
               _loc7_ = saga.getCastMember(_loc5_);
               if(_loc7_)
               {
                  _loc5_ = String(_loc7_.id);
               }
               _loc6_ = _loc1_.getEntityByIdOrByDefId(_loc5_,_loc4_,false);
               if(!_loc6_)
               {
                  throw new ArgumentError("No such interact id [" + _loc5_ + "]: " + this);
               }
            }
            _loc1_.fsm.interact = _loc6_;
         }
         end();
      }
   }
}
