package engine.battle.board.model
{
   import engine.core.logging.ILogger;
   
   public class BattleObjectiveRule_TurnStart extends BattleObjectiveRule
   {
       
      
      public var subdef:Def_TurnStart;
      
      public function BattleObjectiveRule_TurnStart(param1:BattleObjective, param2:BattleObjectiveRuleDef)
      {
         super(param1,param2,_secret);
         this.subdef = param2.subdef as Def_TurnStart;
      }
      
      public static function fromJson(param1:Object, param2:ILogger) : Object
      {
         return new Def_TurnStart().fromJson(param1,param2);
      }
      
      override public function cleanup() : void
      {
         super.cleanup();
      }
      
      override public function handleTurnStart(param1:IBattleEntity) : void
      {
         if(this.subdef.id)
         {
            if(param1.id != this.subdef.id && param1.def.id != this.subdef.id)
            {
               return;
            }
         }
         complete = true;
      }
   }
}

import engine.core.logging.ILogger;
import engine.def.EngineJsonDef;

class Def_TurnStart
{
   
   public static const schema:Object = {
      "name":"BattleObjective_TurnStart",
      "type":"object",
      "properties":{"id":{"type":"string"}}
   };
    
   
   public var id:String;
   
   public function Def_TurnStart()
   {
      super();
   }
   
   public function fromJson(param1:Object, param2:ILogger) : Object
   {
      EngineJsonDef.validateThrow(param1,schema,param2);
      this.id = param1.id;
      return this;
   }
}
