package engine.battle.board.model
{
   import engine.core.logging.ILogger;
   
   public class BattleObjectiveRule_Win extends BattleObjectiveRule
   {
       
      
      public var subdef:Def_Win;
      
      public function BattleObjectiveRule_Win(param1:BattleObjective, param2:BattleObjectiveRuleDef)
      {
         super(param1,param2,_secret);
         this.subdef = param2.subdef as Def_Win;
      }
      
      public static function fromJson(param1:Object, param2:ILogger) : Object
      {
         return new Def_Win().fromJson(param1,param2);
      }
      
      override protected function handleComplete() : void
      {
         this.subdef = this.subdef;
      }
      
      override public function handleBattleWin() : void
      {
         complete = true;
      }
      
      override public function cleanup() : void
      {
         super.cleanup();
      }
   }
}

import engine.core.logging.ILogger;
import engine.def.EngineJsonDef;

class Def_Win
{
   
   public static const schema:Object = {
      "name":"BattleObjective_Win",
      "type":"object",
      "properties":{}
   };
    
   
   public function Def_Win()
   {
      super();
   }
   
   public function fromJson(param1:Object, param2:ILogger) : Object
   {
      if(!param1)
      {
         return this;
      }
      EngineJsonDef.validateThrow(param1,schema,param2);
      return this;
   }
}
