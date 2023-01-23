package engine.battle.board.model
{
   import engine.battle.ability.model.BattleAbility;
   import engine.battle.ability.model.BattleAbilityEvent;
   import engine.core.logging.ILogger;
   
   public class BattleObjectiveRule_AbilityActive extends BattleObjectiveRule
   {
       
      
      public var subdef:Def_AbilityActive;
      
      public function BattleObjectiveRule_AbilityActive(param1:BattleObjective, param2:BattleObjectiveRuleDef)
      {
         super(param1,param2,_secret);
         this.subdef = param2.subdef as Def_AbilityActive;
         manager.addEventListener(BattleAbilityEvent.PERSISTED_ADDED,this.abilityPersistedChangedHandler);
      }
      
      public static function fromJson(param1:Object, param2:ILogger) : Object
      {
         return new Def_AbilityActive().fromJson(param1,param2);
      }
      
      override protected function handleComplete() : void
      {
         manager.removeEventListener(BattleAbilityEvent.PERSISTED_ADDED,this.abilityPersistedChangedHandler);
      }
      
      override public function cleanup() : void
      {
         manager.removeEventListener(BattleAbilityEvent.PERSISTED_ADDED,this.abilityPersistedChangedHandler);
         super.cleanup();
      }
      
      private function abilityPersistedChangedHandler(param1:BattleAbilityEvent) : void
      {
         var _loc3_:int = 0;
         var _loc2_:BattleAbility = param1.ability as BattleAbility;
         if(_loc2_.fake || manager.faking)
         {
            return;
         }
         if(param1.ability.def.id == this.subdef.ability)
         {
            _loc3_ = int(manager.persistedAbilityCounts[param1.ability.def.id]);
            complete = true;
         }
      }
   }
}

import engine.core.logging.ILogger;
import engine.def.EngineJsonDef;

class Def_AbilityActive
{
   
   public static const schema:Object = {
      "name":"BattleObjective_AbilityActive",
      "type":"object",
      "properties":{"ability":{"type":"string"}}
   };
    
   
   public var ability:String;
   
   public function Def_AbilityActive()
   {
      super();
   }
   
   public function fromJson(param1:Object, param2:ILogger) : Object
   {
      EngineJsonDef.validateThrow(param1,schema,param2);
      this.ability = param1.ability;
      return this;
   }
}
