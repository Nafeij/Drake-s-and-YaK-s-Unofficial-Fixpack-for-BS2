package game.session.actions
{
   import engine.core.util.Enum;
   
   public class VsType extends Enum
   {
      
      public static const NONE:VsType = new VsType("NONE",enumCtorKey);
      
      public static const QUICK:VsType = new VsType("QUICK",enumCtorKey);
      
      public static const RANKED:VsType = new VsType("RANKED",enumCtorKey);
      
      public static const TOURNEY:VsType = new VsType("TOURNEY",enumCtorKey);
      
      public static const FRIEND:VsType = new VsType("FRIEND",enumCtorKey);
       
      
      public function VsType(param1:String, param2:Object)
      {
         super(param1,param2);
      }
   }
}
