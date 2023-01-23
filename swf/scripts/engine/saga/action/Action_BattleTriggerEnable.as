package engine.saga.action
{
   import engine.battle.board.model.BattleBoard;
   import engine.battle.board.model.IBattleBoardTrigger;
   import engine.battle.fsm.BattleFsm;
   import engine.saga.Saga;
   import flash.errors.IllegalOperationError;
   
   public class Action_BattleTriggerEnable extends Action
   {
       
      
      public function Action_BattleTriggerEnable(param1:ActionDef, param2:Saga)
      {
         super(param1,param2);
      }
      
      override protected function handleStarted() : void
      {
         var _loc1_:BattleBoard = saga.getBattleBoard();
         var _loc2_:BattleFsm = !!_loc1_ ? _loc1_.fsm as BattleFsm : null;
         var _loc3_:String = def.id;
         var _loc4_:* = def.varvalue != 0;
         _loc3_ = saga.performStringReplacement_SagaVar(_loc3_);
         if(def.expression)
         {
            _loc4_ = 0 != saga.expression.evaluate(def.expression,false);
         }
         var _loc5_:IBattleBoardTrigger = _loc1_.triggers.getTriggerByUniqueIdOrId(_loc3_);
         if(!_loc5_)
         {
            throw new IllegalOperationError("No such trigger [" + _loc3_ + "] in " + _loc1_.triggers);
         }
         _loc5_.enabled = _loc4_;
         if(_loc5_.def.checkTriggerOnEnable)
         {
            _loc1_.triggers.checkTrigger(_loc5_);
         }
         end();
      }
   }
}
