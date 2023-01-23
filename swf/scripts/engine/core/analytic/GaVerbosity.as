package engine.core.analytic
{
   import engine.core.util.Enum;
   
   public class GaVerbosity extends Enum
   {
      
      public static const MINIMAL:GaVerbosity = new GaVerbosity("minimal",0);
      
      public static const NORMAL:GaVerbosity = new GaVerbosity("normal",1);
      
      public static const VERBOSE:GaVerbosity = new GaVerbosity("verbose",2);
       
      
      private var _level:int = 0;
      
      public function GaVerbosity(param1:String, param2:int)
      {
         this._level = param2;
         super(param1,enumCtorKey);
      }
      
      public static function verbosityFromString(param1:String) : GaVerbosity
      {
         switch(param1)
         {
            case "verbose":
               return VERBOSE;
            case "normal":
               return NORMAL;
            case "minimal":
         }
         return MINIMAL;
      }
      
      public function get level() : int
      {
         return this._level;
      }
   }
}
