package engine.battle.ability.effect.op.model
{
   import engine.battle.ability.def.BattleAbilityDef;
   import engine.battle.ability.model.BattleAbility;
   import engine.battle.ability.model.BattleAbilityManager;
   import engine.battle.board.model.IBattleEntity;
   import engine.core.logging.ILogger;
   import engine.def.EngineJsonDef;
   
   public class MoveStateResponse
   {
      
      public static const schema:Object = {
         "name":"MoveStateResponse",
         "properties":{"ability":{"type":"string"}}
      };
       
      
      public var abilityId:String;
      
      public var abilityDef:BattleAbilityDef;
      
      public var manager:BattleAbilityManager;
      
      public function MoveStateResponse()
      {
         super();
      }
      
      public static function vctor() : Vector.<MoveStateResponse>
      {
         return new Vector.<MoveStateResponse>();
      }
      
      public function fromJson(param1:Object, param2:ILogger) : void
      {
         EngineJsonDef.validateThrow(param1,schema,param2);
         this.abilityId = param1.ability;
      }
      
      public function initialize(param1:BattleAbilityManager) : void
      {
         this.manager = param1;
         this.abilityDef = param1.factory.fetchBattleAbilityDef(this.abilityId);
         if(!this.abilityDef)
         {
            param1.logger.error("Op_WaitForMoveFinishing " + this + " invalid ability [" + this.abilityId + "]");
         }
      }
      
      public function performResponse(param1:IBattleEntity) : void
      {
         if(!this.abilityDef)
         {
            return;
         }
         var _loc2_:BattleAbility = new BattleAbility(param1,this.abilityDef,this.manager);
         _loc2_.targetSet.setTarget(param1);
         _loc2_.execute(null);
      }
   }
}
