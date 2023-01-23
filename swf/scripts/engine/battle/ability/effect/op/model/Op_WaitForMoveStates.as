package engine.battle.ability.effect.op.model
{
   import engine.battle.ability.effect.model.Effect;
   import engine.battle.ability.effect.model.EffectResult;
   import engine.battle.ability.effect.op.def.EffectDefOp;
   import engine.battle.board.model.IBattleEntity;
   import engine.battle.board.model.IBattleEntityMobility;
   import engine.battle.entity.model.BattleEntityEvent;
   import engine.core.util.ArrayUtil;
   import flash.utils.Dictionary;
   
   public class Op_WaitForMoveStates extends Op
   {
      
      public static const schema:Object = {
         "name":"Op_WaitForMoveStates",
         "properties":{"triggers":{
            "type":"array",
            "items":MoveStateTrigger.schema
         }}
      };
       
      
      public var triggers:Vector.<MoveStateTrigger>;
      
      public var triggersByType:Dictionary;
      
      public function Op_WaitForMoveStates(param1:EffectDefOp, param2:Effect)
      {
         var def:EffectDefOp = param1;
         var effect:Effect = param2;
         this.triggers = new Vector.<MoveStateTrigger>();
         this.triggersByType = new Dictionary();
         super(def,effect);
         ArrayUtil.arrayToDefVector(def.params.triggers,MoveStateTrigger,logger,this.triggers,function(param1:MoveStateTrigger, param2:int):void
         {
            param1.initialize(manager);
            var _loc3_:Vector.<MoveStateTrigger> = triggersByType[param1.type];
            if(!_loc3_)
            {
               _loc3_ = new Vector.<MoveStateTrigger>();
               triggersByType[param1.type] = _loc3_;
            }
            _loc3_.push(param1);
         });
      }
      
      override public function execute() : EffectResult
      {
         return EffectResult.OK;
      }
      
      override public function apply() : void
      {
         if(this.triggersByType[MoveStateTriggerType.EXECUTING])
         {
            board.addEventListener(BattleEntityEvent.MOVE_EXECUTING,this.moveExecutingHandler);
         }
         if(this.triggersByType[MoveStateTriggerType.FINISHING])
         {
            board.addEventListener(BattleEntityEvent.MOVE_FINISHING,this.moveFinishingHandler);
         }
      }
      
      override public function remove() : void
      {
         board.removeEventListener(BattleEntityEvent.MOVE_EXECUTING,this.moveExecutingHandler);
         board.removeEventListener(BattleEntityEvent.MOVE_FINISHING,this.moveFinishingHandler);
      }
      
      private function _checkTriggerValidity(param1:IBattleEntity) : Boolean
      {
         if(!board || !board.fsm.turn)
         {
            return false;
         }
         if(param1 != target)
         {
            return false;
         }
         if(!target.alive || effect.removed)
         {
            return false;
         }
         var _loc2_:IBattleEntityMobility = target.mobility;
         if(!_loc2_)
         {
            return false;
         }
         return true;
      }
      
      private function _performTriggerResponses(param1:MoveStateTriggerType, param2:IBattleEntity) : void
      {
         var _loc4_:Boolean = false;
         var _loc5_:MoveStateTrigger = null;
         if(!this._checkTriggerValidity(param2))
         {
            return;
         }
         var _loc3_:Vector.<MoveStateTrigger> = this.triggersByType[param1];
         if(!_loc3_)
         {
            return;
         }
         for each(_loc5_ in _loc3_)
         {
            _loc4_ = _loc5_.performTriggerResponse(param2) || _loc4_;
         }
         if(_loc4_)
         {
            effect.handleOpUsed(this);
         }
      }
      
      private function moveFinishingHandler(param1:BattleEntityEvent) : void
      {
         this._performTriggerResponses(MoveStateTriggerType.FINISHING,param1.entity);
      }
      
      private function moveExecutingHandler(param1:BattleEntityEvent) : void
      {
         this._performTriggerResponses(MoveStateTriggerType.EXECUTING,param1.entity);
      }
   }
}
