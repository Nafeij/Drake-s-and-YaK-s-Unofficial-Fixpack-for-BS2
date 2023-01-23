package engine.battle.board.model
{
   import engine.core.util.Enum;
   
   public class BattleObjectiveRuleType extends Enum
   {
      
      public static const ABILITY_ACTIVE:BattleObjectiveRuleType = new BattleObjectiveRuleType("ABILITY_ACTIVE",BattleObjectiveRule_AbilityActive,enumCtorKey);
      
      public static const ABILITY_EVENT:BattleObjectiveRuleType = new BattleObjectiveRuleType("ABILITY_EVENT",BattleObjectiveRule_AbilityEvent,enumCtorKey);
      
      public static const WIN:BattleObjectiveRuleType = new BattleObjectiveRuleType("WIN",BattleObjectiveRule_Win,enumCtorKey);
      
      public static const KILL:BattleObjectiveRuleType = new BattleObjectiveRuleType("KILL",BattleObjectiveRule_Kill,enumCtorKey);
      
      public static const FREE_TURN:BattleObjectiveRuleType = new BattleObjectiveRuleType("FREE_TURN",BattleObjectiveRule_FreeTurn,enumCtorKey);
      
      public static const TURN_START:BattleObjectiveRuleType = new BattleObjectiveRuleType("TURN_START",BattleObjectiveRule_TurnStart,enumCtorKey);
       
      
      public var clazz:Class;
      
      public function BattleObjectiveRuleType(param1:String, param2:Class, param3:Object)
      {
         super(param1,param3);
         this.clazz = param2;
      }
      
      public function ctor(param1:BattleObjective, param2:BattleObjectiveRuleDef) : BattleObjectiveRule
      {
         return new this.clazz(param1,param2) as BattleObjectiveRule;
      }
   }
}
