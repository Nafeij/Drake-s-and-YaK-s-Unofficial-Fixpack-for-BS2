package engine.battle.ability.effect.op.model
{
   import engine.battle.ability.effect.def.BooleanValueReqs;
   import engine.battle.ability.model.BattleAbilityManager;
   import engine.battle.board.model.IBattleEntity;
   import engine.battle.board.model.IBattleEntityMobility;
   import engine.core.logging.ILogger;
   import engine.core.util.ArrayUtil;
   import engine.core.util.Enum;
   import engine.def.EngineJsonDef;
   
   public class MoveStateTrigger
   {
      
      public static const schema:Object = {
         "name":"MoveStateTrigger",
         "properties":{
            "type":{"type":"string"},
            "forced":{
               "type":BooleanValueReqs.schema,
               "optional":true
            },
            "interrupted":{
               "type":BooleanValueReqs.schema,
               "optional":true
            },
            "responses":{
               "type":"array",
               "items":MoveStateResponse.schema
            }
         }
      };
       
      
      public var type:MoveStateTriggerType;
      
      public var forced:BooleanValueReqs;
      
      public var interrupted:BooleanValueReqs;
      
      public var responses:Vector.<MoveStateResponse>;
      
      public function MoveStateTrigger()
      {
         super();
      }
      
      public function fromJson(param1:Object, param2:ILogger) : void
      {
         EngineJsonDef.validateThrow(param1,schema,param2);
         this.type = Enum.parse(MoveStateTriggerType,param1.type) as MoveStateTriggerType;
         this.forced = BooleanValueReqs.ctorFromJson(param1.forced,param2);
         this.interrupted = BooleanValueReqs.ctorFromJson(param1.interrupted,param2);
         this.responses = ArrayUtil.arrayToDefVector(param1.responses,MoveStateResponse,param2,this.responses) as Vector.<MoveStateResponse>;
      }
      
      public function initialize(param1:BattleAbilityManager) : void
      {
         var _loc2_:MoveStateResponse = null;
         if(this.responses)
         {
            for each(_loc2_ in this.responses)
            {
               _loc2_.initialize(param1);
            }
         }
      }
      
      private function _checkTriggerResponse(param1:IBattleEntity) : Boolean
      {
         var _loc2_:IBattleEntityMobility = param1.mobility;
         if(!_loc2_)
         {
            return false;
         }
         if(!BooleanValueReqs.check(this.forced,_loc2_.forcedMove))
         {
            return false;
         }
         if(!BooleanValueReqs.check(this.interrupted,_loc2_.interrupted))
         {
            return false;
         }
         return true;
      }
      
      public function performTriggerResponse(param1:IBattleEntity) : Boolean
      {
         var _loc2_:MoveStateResponse = null;
         if(!this._checkTriggerResponse(param1))
         {
            return false;
         }
         if(!this.responses)
         {
            return false;
         }
         for each(_loc2_ in this.responses)
         {
            _loc2_.performResponse(param1);
         }
         return true;
      }
   }
}
