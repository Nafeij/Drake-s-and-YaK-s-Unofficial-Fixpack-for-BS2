package engine.core.analytic
{
   public class GaConfig
   {
      
      public static const PREF_GA_OPTSTATE:String = "ga_optstate";
      
      public static const PREF_GA_VERBOSITY:String = "ga_verbosity";
      
      private static var _verbosity:GaVerbosity = GaVerbosity.MINIMAL;
      
      private static var _optState:GaOptState = GaOptState.NA;
       
      
      public function GaConfig()
      {
         super();
      }
      
      public static function getDebugString(param1:String = "    ", param2:String = "\n") : String
      {
         param1 = !!param1 ? param1 : "    ";
         param2 = !!param2 ? param2 : "\n";
         return "" + param1 + "GaConfig.optState = " + _optState + param2;
      }
      
      public static function setVerbosityFromString(param1:String) : GaVerbosity
      {
         var _loc2_:GaVerbosity = GaVerbosity.verbosityFromString(param1);
         _verbosity = _loc2_;
         return _loc2_;
      }
      
      public static function set verbosity(param1:GaVerbosity) : void
      {
         _verbosity = param1;
      }
      
      public static function get verbosity() : GaVerbosity
      {
         return _verbosity;
      }
      
      public static function optStateFromString(param1:String) : GaOptState
      {
         if(!param1)
         {
            return null;
         }
         var _loc2_:GaOptState = GaOptState.optStateFromString(param1);
         if(_loc2_)
         {
            optState = _loc2_;
         }
         return _loc2_;
      }
      
      public static function set optState(param1:GaOptState) : void
      {
         Ga.minimal("sys","ga_optstate",param1.name,1);
         _optState = param1;
         Ga.deferSends = _optState.isDefer;
         Ga.checkStartSend();
      }
      
      public static function get optState() : GaOptState
      {
         return _optState;
      }
   }
}
