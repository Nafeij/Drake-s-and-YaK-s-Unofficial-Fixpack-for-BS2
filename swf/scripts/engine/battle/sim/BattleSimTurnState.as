package engine.battle.sim
{
   import engine.core.util.Enum;
   
   public class BattleSimTurnState extends Enum
   {
      
      public static const MOVE:BattleSimTurnState = new BattleSimTurnState("MOVE",enumCtorKey);
      
      public static const MOVING:BattleSimTurnState = new BattleSimTurnState("MOVING",enumCtorKey);
      
      public static const TRIGGERING:BattleSimTurnState = new BattleSimTurnState("TRIGGERING",enumCtorKey);
      
      public static const ACTION:BattleSimTurnState = new BattleSimTurnState("ACTION",enumCtorKey);
      
      public static const TARGETING:BattleSimTurnState = new BattleSimTurnState("TARGETING",enumCtorKey);
      
      public static const TARGETED:BattleSimTurnState = new BattleSimTurnState("TARGETED",enumCtorKey);
      
      public static const ACTING:BattleSimTurnState = new BattleSimTurnState("ACTING",enumCtorKey);
       
      
      public function BattleSimTurnState(param1:String, param2:Object)
      {
         super(param1,param2);
      }
   }
}
