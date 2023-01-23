package engine.battle.sim
{
   import engine.core.util.Enum;
   
   public class BattleSimState extends Enum
   {
      
      public static const SUSPENDED:BattleSimState = new BattleSimState("SUSPENDED",enumCtorKey);
      
      public static const ACTIVE:BattleSimState = new BattleSimState("ACTIVE",enumCtorKey);
      
      public static const QUIT:BattleSimState = new BattleSimState("QUIT",enumCtorKey);
       
      
      public function BattleSimState(param1:String, param2:Object)
      {
         super(param1,param2);
      }
   }
}
