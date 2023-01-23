package engine.battle.ability.phantasm.def
{
   import engine.core.util.Enum;
   
   public class TextToken extends Enum
   {
      
      public static const ABILITY_NAME:TextToken = new TextToken("ABILITY_NAME",enumCtorKey);
      
      public static const CASTER_NAME:TextToken = new TextToken("CASTER_NAME",enumCtorKey);
      
      public static const TARGET_NAME:TextToken = new TextToken("TARGET_NAME",enumCtorKey);
      
      public static const STARS_COST:TextToken = new TextToken("STARS_COST",enumCtorKey);
      
      public static const OPVAR:TextToken = new TextToken("OPVAR",enumCtorKey);
       
      
      public function TextToken(param1:String, param2:Object)
      {
         super(param1,param2);
      }
      
      public function get token() : String
      {
         return name;
      }
   }
}
