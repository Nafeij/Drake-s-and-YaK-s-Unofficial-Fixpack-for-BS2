package engine.battle.board.model
{
   import engine.core.logging.ILogger;
   
   public class BattleObjectiveRule_FreeTurn extends BattleObjectiveRule
   {
       
      
      public var subdef:Def_FreeTurn;
      
      public function BattleObjectiveRule_FreeTurn(param1:BattleObjective, param2:BattleObjectiveRuleDef)
      {
         super(param1,param2,_secret);
         this.subdef = param2.subdef as Def_FreeTurn;
      }
      
      public static function fromJson(param1:Object, param2:ILogger) : Object
      {
         return new Def_FreeTurn().fromJson(param1,param2);
      }
      
      override public function cleanup() : void
      {
         super.cleanup();
      }
      
      override public function handleFreeTurn(param1:IBattleEntity) : void
      {
         if(param1.freeTurns >= this.subdef.turnMinimum)
         {
            if(param1.freeTurns <= this.subdef.turnMaximum)
            {
               complete = true;
            }
         }
      }
   }
}

import engine.battle.ability.def.AbilityExecutionEntityConditions;
import engine.core.logging.ILogger;
import engine.def.EngineJsonDef;

class Def_FreeTurn
{
   
   public static const schema:Object = {
      "name":"BattleObjective_FreeTurn",
      "type":"object",
      "properties":{
         "casterRequirements":{
            "type":AbilityExecutionEntityConditions.schema,
            "optional":true
         },
         "turnMinimum":{"type":"number"},
         "turnMaximum":{"type":"number"}
      }
   };
    
   
   public var casterRequirements:AbilityExecutionEntityConditions;
   
   public var turnMinimum:int;
   
   public var turnMaximum:int;
   
   public function Def_FreeTurn()
   {
      super();
   }
   
   public function fromJson(param1:Object, param2:ILogger) : Object
   {
      EngineJsonDef.validateThrow(param1,schema,param2);
      if(param1.casterRequirements)
      {
         this.casterRequirements = new AbilityExecutionEntityConditions().fromJson(param1.casterRequirements,param2);
      }
      this.turnMinimum = param1.turnMinimum;
      this.turnMaximum = param1.turnMaximum;
      return this;
   }
}
