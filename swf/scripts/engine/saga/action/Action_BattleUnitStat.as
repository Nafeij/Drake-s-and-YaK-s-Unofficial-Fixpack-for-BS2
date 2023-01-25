package engine.saga.action
{
   import engine.battle.board.model.BattleBoard;
   import engine.battle.board.model.IBattleEntity;
   import engine.core.util.Enum;
   import engine.entity.def.IEntityDef;
   import engine.saga.Saga;
   import engine.stat.def.StatType;
   import flash.errors.IllegalOperationError;
   
   public class Action_BattleUnitStat extends Action
   {
       
      
      public function Action_BattleUnitStat(param1:ActionDef, param2:Saga)
      {
         super(param1,param2);
      }
      
      override protected function handleStarted() : void
      {
         var _loc1_:String = def.id;
         var _loc2_:String = def.param;
         var _loc3_:int = def.varvalue;
         var _loc4_:StatType = Enum.parse(StatType,_loc2_) as StatType;
         if(!_loc4_.allowNegative && _loc3_ < 0)
         {
            logger.error("Cannot set stat " + _loc4_ + " below zero, clamping: " + this);
            _loc3_ = 0;
         }
         if(!_loc1_)
         {
            throw new IllegalOperationError("No id");
         }
         _loc1_ = saga.performStringReplacement_SagaVar(_loc1_);
         var _loc5_:IEntityDef = saga.getCastMember(_loc1_);
         if(_loc5_)
         {
            _loc1_ = String(_loc5_.id);
         }
         var _loc6_:BattleBoard = saga.getBattleBoard();
         if(!_loc6_)
         {
            throw new IllegalOperationError("No battle board");
         }
         var _loc7_:IBattleEntity = _loc6_.getEntityByIdOrByDefId(_loc1_,null,false);
         if(!_loc7_)
         {
            logger.info("Action_BattleUnitStat No such entity [" + _loc1_ + "]");
         }
         else
         {
            _loc7_.stats.setBase(_loc4_,_loc3_);
         }
         end();
      }
   }
}
