package game.gui.combat.radial
{
   import engine.core.util.Enum;
   
   public class RadialAction extends Enum
   {
      
      public static const ATTACK_MELEE_STR:RadialAction = new RadialAction("ATTACK_MELEE_STR",enumCtorKey);
      
      public static const ATTACK_RANGED_STR:RadialAction = new RadialAction("ATTACK_RANGED_STR",enumCtorKey);
      
      public static const ATTACK_MELEE_ARM:RadialAction = new RadialAction("ATTACK_MELEE_ARM",enumCtorKey);
      
      public static const ATTACK_RANGED_ARM:RadialAction = new RadialAction("ATTACK_RANGED_ARM",enumCtorKey);
      
      public static const REST:RadialAction = new RadialAction("ATTACK_REST",enumCtorKey);
      
      public static const END:RadialAction = new RadialAction("ATTACK_END",enumCtorKey);
      
      public static const SPECIAL0:RadialAction = new RadialAction("ATTACK_SPECIAL0",enumCtorKey);
      
      public static const SPECIAL1:RadialAction = new RadialAction("ATTACK_SPECIAL1",enumCtorKey);
       
      
      public function RadialAction(param1:String, param2:Object)
      {
         super(param1,param2);
      }
   }
}
