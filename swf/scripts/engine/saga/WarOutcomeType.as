package engine.saga
{
   import engine.core.util.Enum;
   
   public class WarOutcomeType extends Enum
   {
      
      public static const VICTORY:WarOutcomeType = new WarOutcomeType("VICTORY",enumCtorKey);
      
      public static const DEFEAT:WarOutcomeType = new WarOutcomeType("DEFEAT",enumCtorKey);
      
      public static const RETREAT:WarOutcomeType = new WarOutcomeType("RETREAT",enumCtorKey);
       
      
      public function WarOutcomeType(param1:String, param2:Object)
      {
         super(param1,param2);
      }
   }
}
