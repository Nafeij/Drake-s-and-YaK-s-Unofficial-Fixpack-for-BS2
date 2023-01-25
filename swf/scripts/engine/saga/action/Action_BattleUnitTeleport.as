package engine.saga.action
{
   import engine.battle.board.model.BattleBoard;
   import engine.battle.board.model.IBattleEntity;
   import engine.battle.fsm.BattleMove;
   import engine.entity.def.IEntityDef;
   import engine.saga.Saga;
   import engine.tile.def.TileLocation;
   import engine.tile.def.TileRect;
   import flash.errors.IllegalOperationError;
   
   public class Action_BattleUnitTeleport extends Action
   {
       
      
      private var entity:IBattleEntity;
      
      public function Action_BattleUnitTeleport(param1:ActionDef, param2:Saga)
      {
         super(param1,param2);
      }
      
      override protected function handleStarted() : void
      {
         var _loc4_:IEntityDef = null;
         var _loc5_:Vector.<TileLocation> = null;
         var _loc6_:TileRect = null;
         var _loc7_:TileLocation = null;
         var _loc1_:String = def.id;
         if(Boolean(_loc1_) && _loc1_.charAt(0) == "$")
         {
            _loc4_ = saga.getCastMember(_loc1_);
            if(_loc4_)
            {
               _loc1_ = String(_loc4_.id);
            }
         }
         var _loc2_:BattleBoard = saga.getBattleBoard();
         if(!_loc2_)
         {
            throw new IllegalOperationError("No battle board");
         }
         var _loc3_:IBattleEntity = _loc2_.getEntityByIdOrByDefId(_loc1_,null,false);
         if(!_loc3_)
         {
            logger.info("Action_BattleUnitStat No such entity [" + _loc1_ + "]");
         }
         else
         {
            _loc5_ = Action_BattleUnitMove.parseTilesList(def.anchor,saga);
            if(!_loc5_ || !_loc5_.length)
            {
               throw new ArgumentError("Invalid tile list def.anchor [" + def.anchor + "]");
            }
            _loc6_ = _loc3_.rect.clone();
            for each(_loc7_ in _loc5_)
            {
               _loc6_.setLocation(_loc7_);
               if(!_loc2_.findAllRectIntersectionEntities(_loc6_,_loc3_,null))
               {
                  _loc3_.setPos(0,0);
                  end();
                  return;
               }
            }
            logger.info("Unable to find a suitable landing point for:" + this);
         }
         end();
      }
      
      private function moveCompleteHandler(param1:BattleMove) : void
      {
         end();
      }
   }
}
